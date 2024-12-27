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
                (can_token_stl?(entity) && @game.class::STL_TOKEN_HEX.include?(hex.id))
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

          def place_token(entity, city, token, connected: true, extra_action: false, special_ability: nil, check_tokenable: true)
            hex = city.hex

            if @game.class::STL_TOKEN_HEX.include?(hex.id)
              # Check for STL connection
              stl_token_errors(entity, token)

              # allows corporations to replace a corporation's flipped token
              flipped_token = hex.tile.cities.map { |c| c.tokens.find { |t| t&.status == :flipped } }.first
              if flipped_token && city.tokens.none?(&:nil?) &&
                hex.tile.cities.none? { |c| c.tokens.any? { |t| t&.corporation == entity && t&.status != :flipped } }

                raise GameError, 'Not enough cash to replace flipped token' if entity.cash < TOKEN_REPLACEMENT_COST

                payee, verb = flipped_token.corporation == entity ? [@game.bank, 'flips'] : [flipped_token.corporation, 'replaces']
                entity.spend(TOKEN_REPLACEMENT_COST, payee)
                @log << "#{entity.name} pays #{@game.format_currency(TOKEN_REPLACEMENT_COST)} to "\
                        "#{payee.name} and #{verb} its permit marker in #{hex.name}"
                # flips the token back to normal and returns it to the corp
                flipped_token.status = nil
                flipped_token.remove!
                # places new token
                city.place_token(entity, entity.tokens.reject(&:used).first, free: true, check_tokenable: false)
                @round.tokened = true
                return
              end

              # Remove blocker token based on phase restrictions
              found_replaceable_token = false

              city.tokens.each_with_index do |t, index|
                next unless t&.corporation&.name == 'STLBC'

                replace_token = case index
                                when 0 then phase_colors.include?('yellow')
                                when 1 then phase_colors.include?('green')
                                when 2 then phase_colors.include?('brown')
                                when 3 then phase_colors.include?('gray')
                                else false
                                end

                next unless replace_token

                city.tokens[index] = nil
                found_replaceable_token = true
                break
              end

              raise GameError, 'No permit token slot available until phase color change' unless found_replaceable_token

              # Place the new token if a slot is available
              if city.tokens.any?(&:nil?)
                city.place_token(entity, token, free: true, check_tokenable: check_tokenable)
                @log << "#{entity.name} places a permit token in St. Louis (B15)"
                @round.tokened = true
                return
              end
            end

            check_connected(entity, city, hex) if connected

            # allows corporations to replace a corporation's flipped token
            flipped_token = hex.tile.cities.map { |c| c.tokens.find { |t| t&.status == :flipped } }.first
            if flipped_token && city.tokens.none?(&:nil?) &&
              hex.tile.cities.none? { |c| c.tokens.any? { |t| t&.corporation == entity && t&.status != :flipped } }
              # check for STL connection
              stl_token_errors(entity, token) if @game.class::STL_TOKEN_HEX.include?(hex.id)

              raise GameError, 'Not enough cash to replace flipped token' if entity.cash < TOKEN_REPLACEMENT_COST

              payee, verb = flipped_token.corporation == entity ? [@game.bank, 'flips'] : [flipped_token.corporation, 'replaces']
              entity.spend(TOKEN_REPLACEMENT_COST, payee)
              @log << "#{entity.name} pays #{@game.format_currency(TOKEN_REPLACEMENT_COST)} to "\
                      "#{payee.name} and #{verb} its token in #{hex.name}"
              # flips the token back to normal and returns it to the corp
              flipped_token.status = nil
              flipped_token.remove!
              # places new token
              city.place_token(entity, entity.tokens.reject(&:used).first, free: true, check_tokenable: false)
              @round.tokened = true
              return
            end

            raise GameError, "Must flip one of the corporation's abandoned stations" if entity.tokens.all?(&:used)

            extra_action ||= special_ability.extra_action if %i[teleport token].include?(special_ability&.type)
    
            if special_ability&.type == :token && special_ability.city && special_ability.city != city.index
              raise GameError, "#{special_ability.owner.name} can only place token on #{hex.name} city "\
                               "#{special_ability.city}, not on city #{city.index}"
            end
    
            if special_ability&.type == :teleport &&
               !special_ability.hexes.empty? &&
               !special_ability.hexes.include?(hex.id)
              raise GameError, "#{special_ability.owner.name} cannot place token in "\
                               "#{hex.name} (#{hex.location_name}) with teleport"
            end
    
            raise GameError, 'Token already placed this turn' if !extra_action && @round.tokened
    
            token, ability = adjust_token_price_ability!(entity, token, hex, city, special_ability: special_ability)
            tokener = entity.name
            if ability
              tokener += " (#{ability.owner.sym})" if ability.owner != entity
              entity.remove_ability(ability)
            end
    
            raise GameError, 'Token is already used' if token.used
    
            free = !token.price.positive?
            if ability&.type == :token
              cheater = ability.cheater
              extra_slot = ability.extra_slot
            end
            city.place_token(entity, token, free: free, check_tokenable: check_tokenable,
                                            cheater: cheater, extra_slot: extra_slot, spender: spender,
                                            same_hex_allowed: same_hex_allowed)
            unless free
              pay_token_cost(spender || entity, token.price, city)
              price_log = " for #{@game.format_currency(token.price)}"
            end

              hex_description = hex.location_name ? "#{hex.name} (#{hex.location_name}) " : "#{hex.name} "
              @log << "#{tokener} places a token on #{hex_description}#{price_log}"
    
            @round.tokened = true unless extra_action
            @game.clear_token_graph_for_entity(entity)
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
