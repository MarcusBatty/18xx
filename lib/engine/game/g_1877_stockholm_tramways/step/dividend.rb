# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1877StockholmTramways
      module Step
        class Dividend < Engine::Step::Dividend
          def auto_actions(entity)
            return [Action::Dividend.new(entity, kind: 'payout')] if @game.sl

            super
          end

          def share_price_change(entity, revenue = 0)
            if revenue.positive?
              price = entity.share_price.price
              if revenue < price
                {}
              elsif revenue < price * 2
                { share_direction: :right, share_times: 1 }
              elsif revenue < price * 3
                { share_direction: :right, share_times: 2 }
              else
                { share_direction: :right, share_times: 3 }
              end
            else
              { share_direction: :left, share_times: 1 }
            end
          end

          def holder_for_corporation(_)
            @game.bank
          end
        end
      end
    end
  end
end
