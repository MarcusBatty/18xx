# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'

module Engine
  module Game
    module G18IL2
      module Step
        class Conversion < Engine::Step::Base
          def actions(entity)
            return [] if @game.last_set
            return [] if !entity.corporation? || entity != current_entity || entity == @round.converts[-1]

            price = entity.share_price.price
            shares = entity.total_shares
            cash = entity.cash

            # can't convert if corp would not have enough money to purchase tokens after issuing all shares
            return [] if (shares == 2 && (price * 1.5) + cash < 40) || (shares == 5 && (price * 2.5) + cash < 120)

            actions = []
            actions << 'convert' if [2, 5].include?(shares)
            actions << 'pass' if actions.any?
            actions
          end

          def description
            'Convert'
          end

          def help
            [
              "Convert #{current_entity.name} to a #{current_entity.total_shares == 2 ? '5' : '10'}-share corporation or pass:",
            ]
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
            @round.converts << corporation
            @round.converted = corporation
          end

          def show_other_players
            false
          end

          def round_state
            {
              converted: nil,
              converts: [],
            }
          end
        end
      end
    end
  end
end
