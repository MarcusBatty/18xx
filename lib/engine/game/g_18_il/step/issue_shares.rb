# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18IL
      module Step
        class IssueShares < Engine::Step::IssueShares
          
          def description
            'Issue a Share'
          end

          def actions(entity)
            actions = []
            return [] if entity == @game.ic && @game.ic_in_receivership?
            return actions unless entity.corporation?
            return actions unless entity == current_entity
    
            actions << 'sell_shares' unless issuable_shares(entity).empty?
            actions << 'pass' if blocks? && !actions.empty?
    
            actions
          end

          def pass_description
            'Skip (Issue)'
          end

          def issuable_shares(entity)
            # Done via Sell Shares
            @game.issuable_shares(entity)
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle, allow_president_change: false, swap: nil, movement: :left_share)
            pass!
          end

        end
      end
    end
  end
end
