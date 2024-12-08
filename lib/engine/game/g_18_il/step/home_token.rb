# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18IL
      module Step
        class HomeToken < Engine::Step::HomeToken
          TOKEN_REPLACEMENT_COST = 40

          def available_hex(_entity, hex)
            pending_token[:hexes].include?(hex)
          end

          def can_replace_token?(entity, token)
            @game.home_token_locations(entity).include?(token.city.hex)
          end

          def process_place_token(action)
            hex = action.city.hex
            raise GameError, "Cannot place token on #{hex.name} as the hex is not available" unless available_hex(action.entity,
                                                                                                                  hex)

            if @game.eligible_tokens?(action.entity)
              replace_token(action)
            else
              place_token(token.corporation, action.city, token, connected: false, extra_action: true)
            end
            @round.pending_tokens.shift
          end

          def replace_token(action)
            hex = action.city.hex
            token = action.entity.tokens.find { |t| t.hex == hex }
            token.status = nil
            @log << "#{action.entity.name} flips token in #{hex.name}"
          end
        end
      end
    end
  end
end
