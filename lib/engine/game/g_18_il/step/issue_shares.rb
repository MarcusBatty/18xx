# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18IL
      module Step
        class IssueShares < Engine::Step::IssueShares
          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
            old = action.bundle.corporation.share_price.price
            @game.stock_market.move_left(action.bundle.corporation) 
            new = action.bundle.corporation.share_price.price
            @log << "#{action.bundle.corporation.name}'s share price moves left from $#{old} to $#{new}"
            pass!
          end
        end
      end
    end
  end
end
