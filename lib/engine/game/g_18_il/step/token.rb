# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18IL
      module Step
        class Token < Engine::Step::Token
          TOKEN_REPLACEMENT_COST = 40

          ACTIONS = %w[place_token pass].freeze

          def actions(entity)
            return [] if @game.last_set_triggered
            return [] unless entity == current_entity
            return [] unless can_place_token?(entity)
            return [] if entity == @game.ic && @game.ic_in_receivership?
            return [] unless @game.hexes.find {|hex| available_hex(entity, hex) }

            ACTIONS
          end

          def can_replace_token?(entity, token)
            available_hex(entity, token.city.hex) ||
            token.status == :flipped
          end

          def available_hex(entity, hex)
            if entity.tokens.all?(&:used)
              nodes = []
              @game.stl_nodes.each do |node|
                nodes << @game.graph.connected_nodes(entity)[node]
              end
              hex.tile.cities.each do |city|
                nodes << @game.token_graph_for_entity(entity).connected_nodes(entity)[city]
              end
              return false unless @game.loading || nodes.any?
              entity.tokens.select { |t| t.status == :flipped }.map(&:hex).include?(hex)
            else
              @game.graph.reachable_hexes(entity)[hex] ||
                (can_token_stl?(entity) && stl_token_hex?(hex))
            end
          end

          def pass_description
            'Pass (Token)'
          end
    

          def can_place_token?(entity)
            (current_entity == entity &&
              !@round.tokened &&
              !available_tokens(entity).empty? &&
              (@game.graph.can_token?(entity) || can_token_stl?(entity))) || 
              entity.tokens.any? { |t| t.status == :flipped }
          end

          def can_token_stl?(entity)
            !@game.stl_permit?(entity) && stl_reachable?(entity)
          end

          def stl_reachable?(entity)
            @game.stl_nodes.any? do |node|
              @game.graph.connected_nodes(entity)[node]
            end
          end

          def phase_colors
            @game.phase.current[:tiles]
          end

          def available_tokens(entity)
            token_holder = entity.company? ? entity.owner : entity
            token_holder.tokens.reject { |t| t.used && t.status != :flipped }.uniq(&:type)
          end

          def replace_flipped_token(entity, city, token, flipped_token, stl_hex = false)
            hex = city.hex
            raise GameError, 'Not enough cash to replace flipped token' if entity.cash < TOKEN_REPLACEMENT_COST

            payee, verb = flipped_token.corporation == entity ? [@game.bank, 'flips'] : [flipped_token.corporation, 'replaces']
            entity.spend(TOKEN_REPLACEMENT_COST, payee)
            if stl_token_hex?(hex)
              @log << "#{entity.name} pays #{@game.format_currency(TOKEN_REPLACEMENT_COST)} to "\
                      "#{payee.name} and #{verb} its permit token in #{hex.name} (St. Louis)"
            else
              @log << "#{entity.name} pays #{@game.format_currency(TOKEN_REPLACEMENT_COST)} to "\
                      "#{payee.name} and #{verb} its token in #{hex.name} (#{hex.tile.location_name})"
            end
            # flips the token back to normal and returns it to the corp
            flipped_token.status = nil
            flipped_token.remove!
            # places new token
            city.place_token(entity, entity.tokens.reject(&:used).first, free: true, check_tokenable: false)
            @round.tokened = true
          end

          def stl_token_hex?(hex)
            @game.class::STL_TOKEN_HEX.include?(hex.id)
          end

          def place_token(entity, city, token, connected: true, extra_action: false, special_ability: nil, check_tokenable: true)
            hex = city.hex
            flipped_token = hex.tile.cities.map { |c| c.tokens.find { |t| t&.status == :flipped } }.first
          
            # STL-specific logic
            if stl_token_hex?(hex)
              stl_token_errors(entity, token)
          
              if should_replace_flipped_token?(entity, city, flipped_token)
                replace_flipped_token(entity, city, token, flipped_token)
                return
              end
          
              found_replaceable_token = city.tokens.each_with_index.any? do |t, index|
                next unless t&.corporation&.name == 'STLBC'
              
                replaceable = case index
                              when 0 then phase_colors.include?('yellow')
                              when 1 then phase_colors.include?('green')
                              when 2 then phase_colors.include?('brown')
                              when 3 then phase_colors.include?('gray')
                              else false
                              end
              
                city.tokens[index] = nil if replaceable
                replaceable
              end
          
              raise GameError, 'No permit token slot available until phase color change' unless found_replaceable_token
          
              if city.tokens.any?(&:nil?)
                city.place_token(entity, token, free: true, check_tokenable: check_tokenable)
                @log << "#{entity.name} places a permit token in #{city.hex.name} (St. Louis)"
                @round.tokened = true
                return
              end
            end
          
            check_connected(entity, city, hex) if connected
          
            if should_replace_flipped_token?(entity, city, flipped_token)
              replace_flipped_token(entity, city, token, flipped_token)
              return
            end
          
            raise GameError, "Must flip one of the corporation's abandoned stations" if entity.tokens.all?(&:used)
          
            super
          end

          def should_replace_flipped_token?(entity, city, flipped_token)
            hex = city.hex
            flipped_token && city.tokens.none?(&:nil?) &&
               hex.tile.cities.none? { |c| c.tokens.any? { |t| t&.corporation == entity && t&.status != :flipped } }
          end

          def stl_token_errors(entity, token)
            raise GameError, 'Must be connected to St. Louis to place permit token' if !@game.loading && !stl_reachable?(entity)
            raise GameError, 'Permit token already placed this turn' if @round.tokened
            raise GameError, 'Already placed permit token in STL' if @game.stl_permit?(entity)
          end
        end
      end
    end
  end
end
