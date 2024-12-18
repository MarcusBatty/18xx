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

            ACTIONS
          end

          def can_replace_token?(entity, token)
            available_hex(entity, token.city.hex) ||
            token.status == :flipped
          end

          def available_hex(entity, hex)
            @game.graph.reachable_hexes(entity)[hex] ||
              (can_token_stl?(entity) && @game.class::STL_TOKEN_HEXES.include?(hex.id))
          end

          def can_place_token?(entity)
            current_entity == entity &&
              !@round.tokened &&
              !available_tokens(entity).empty? &&
              (@game.graph.can_token?(entity) || can_token_stl?(entity))
          end

          def can_token_stl?(entity)
            !@game.stl_permit?(entity) && stl_reachable?(entity)
          end

          def stl_reachable?(entity)
            @game.stl_nodes.any? do |node|
              @game.graph.connected_nodes(entity)[node]
            end
          end

          def place_token(entity, city, token, connected: true, extra_action: false, special_ability: nil, check_tokenable: true)
            hex = city.hex

            if @game.class::STL_TOKEN_HEXES.include?(hex.id)

              # Check for STL connection
              stl_token_errors(entity, token)

              # Remove blocker token based on phase restrictions
              city.tokens.each_with_index do |t, index|
                next unless t&.corporation&.name == 'GSB'

                replace_token = case index
                                when 0 then true # Always replace the first token
                                when 1 then @game.phase.name != '2'
                                when 2 then !%w[2 3].include?(@game.phase.name)
                                when 3 then @game.phase.name == 'D'
                                else false
                                end

                city.tokens[index] = nil if replace_token
              end

              # Place the new token if a slot is available
              if city.tokens.any?(&:nil?)
                city.place_token(entity, token, free: true, check_tokenable: check_tokenable)
                @log << "#{entity.name} places a permit token in St. Louis (B15)"
                @round.tokened = true
                return
              end
            end

            # allows corporations to replace other corporation's flipped token
            flipped_token = hex.tile.cities.map { |c| c.tokens.find { |t| t&.status == :flipped } }.first
            if flipped_token && city.tokens.none?(&:nil?)
              # check for STL connection
              stl_token_errors(entity, token) if @game.class::STL_TOKEN_HEXES.include?(hex.id)
              raise GameError, 'Not enough cash to replace flipped token' if entity.cash < TOKEN_REPLACEMENT_COST

              entity.spend(TOKEN_REPLACEMENT_COST, flipped_token.corporation)
              @log << "#{entity.name} pays #{@game.format_currency(TOKEN_REPLACEMENT_COST)} to "\
                      "#{flipped_token.corporation.name} and replaces its token in #{hex.name}"
              # flips the token back to normal and returns it to the corp
              flipped_token.status = nil
              flipped_token.remove!
              # places new token
              city.place_token(entity, entity.tokens.reject(&:used).first, free: true, check_tokenable: false)
              @round.tokened = true
              return
            end

            super
          end

          def stl_token_errors(entity, token)
            raise GameError, 'Must be connected to St. Louis to place permit token' if !@game.loading && !stl_reachable?(entity)
            raise GameError, 'Permit token already placed this turn' if @round.tokened
            raise GameError, 'Already placed permit token in STL' if @game.stl_permit?(entity)
            raise GameError, 'Permit token is already used' if token.used
          end
        end
      end
    end
  end
end
