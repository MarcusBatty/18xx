# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18IL
      module Step
        class Convert < Engine::Step::Base

          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity || @round.converts[-1] == entity

            actions = []
            actions << 'convert' if [2, 5].include?(entity.total_shares)
            actions << 'pass' if actions.any?
            actions
          end

          #TODO: fix padding?
          def description
            'Convert'
          end

          def pass_description
            'Skip (Convert)'
          end

          def others_acted?
            !@round.converts.empty?
          end

          def process_convert(action)
            corporation = action.entity
            before = corporation.total_shares
            @game.convert(corporation)
            after = corporation.total_shares
            @log << "#{corporation.name} converts from a #{before}-share to a #{after}-share corporation"

            tokens = corporation.tokens.size

            @round.tokens_needed =
              case after
              when 5
                1
              when 10
                3
              else
                0
              end

            @round.converts << corporation
            @round.converted = corporation
          end

          def round_state
            {
              converted: nil,
              tokens_needed: nil,
              converts: [],
            }
          end

        end
      end
    end
  end
end