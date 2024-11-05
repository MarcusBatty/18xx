# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18IL
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares

          def purchasable_companies(entity)
            return []
          end
          
        end
      end
    end
  end
end
