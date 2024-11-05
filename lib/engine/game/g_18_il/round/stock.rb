# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18IL
      module Round
        class Stock < Engine::Round::Stock

          def sold_out_stock_movement(corp)
            @game.stock_market.move_up(corp)
            if corp.total_shares == 10             
                @game.stock_market.move_up(corp)
            end
          end

          def sold_out?(corporation)
            corporation.total_shares > 2 && corporation.player_share_holders.values.select(&:positive?).sum >= 100
          end
        end
      end
    end
  end
end