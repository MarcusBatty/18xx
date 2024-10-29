# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18IL
      module Step
        class Token < Engine::Step::Token

          def can_place_token?(entity)
            current_entity == entity &&
              !@round.tokened &&
              !available_tokens(entity).empty? &&
              (@game.graph.can_token?(entity) || can_token_STL?(entity))
          end

          def can_token_STL?(entity)
            !@game.STL_permit?(entity) && STL_reachable?(entity)
          end

          def STL_reachable?(entity)
             @game.STL_nodes.any? do |node|
             @game.graph.connected_nodes(entity)[node]
            end
          end

          def place_token(entity, city, token, connected: true, extra_action: false,
                          special_ability: nil, check_tokenable: true)
            hex = city.hex
            return super unless @game.class::STL_TOKEN_HEXES.include?(hex.id)

            raise GameError, 'Must be connected to St. Louis to place permit token' if !@game.loading && !STL_reachable?(entity)
            raise GameError, 'Permit token already placed this turn' if @round.tokened
            raise GameError, 'Already placed permit token in STL' if @game.STL_permit?(entity)
            raise GameError, 'Permit token is already used' if token.used

            city.place_token(entity, token, free: true, check_tokenable: check_tokenable)

            @log << "#{entity.name} places a permit token in STL"

            @round.tokened = true
          end

          def available_hex(entity, hex)
            @game.graph.reachable_hexes(entity)[hex] ||
              (can_token_STL?(entity) && @game.class::STL_TOKEN_HEXES.include?(hex.id))
          end
        end
      end
    end
  end
end