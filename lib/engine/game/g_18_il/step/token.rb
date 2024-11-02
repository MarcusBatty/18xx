# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18IL
      module Step
        class Token < Engine::Step::Token
          
          def can_replace_token?(entity, token)
            available_hex(entity, token.city.hex)
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

            return super unless @game.class::STL_TOKEN_HEXES.include?(hex.id)
            raise GameError, 'Must be connected to St. Louis to place permit token' if !@game.loading && !stl_reachable?(entity)
            raise GameError, 'Permit token already placed this turn' if @round.tokened
            raise GameError, 'Already placed permit token in STL' if @game.stl_permit?(entity)
            raise GameError, 'Permit token is already used' if token.used

            #swaps dummy corp token in STL for tokening corp's token if slot available
             case @game.class::STL_TOKEN_HEXES.include?(hex.id)
                when city.tokens[0].corporation.name == 'GSB' then city.tokens[0] = nil 
                when @game.phase.name != '2' && city.tokens[1].corporation.name == 'B' then city.tokens[1] = nil
                when (@game.phase.name != '2' or '3') && city.tokens[2].corporation.name == 'B' then city.tokens[2] = nil
                when @game.phase.name == 'D' && city.tokens[3].corporation.name == 'B' then city.tokens[3] = nil
             end
              
            city.place_token(entity, token, free: true, check_tokenable: check_tokenable)
            @log << "#{entity.name} places a permit token in St. Louis (B15)"

            @round.tokened = true
          end

        end
      end
    end
  end
end