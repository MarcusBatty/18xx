# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18IL
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::HalfPay
          
          DIVIDEND_TYPES = %i[payout half withhold].freeze

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :down, share_times: 1 } if revenue == 0 && price == 20
            return { share_direction: :left, share_times: 1 } if revenue == 0
            return { share_direction: :down, share_times: 1 } if revenue < price / 2
            return { share_direction: :up, share_times: 1 } if revenue < price
            return { share_direction: :right, share_times: 1 } if revenue < price * 2
            return { share_direction: :right, share_times: 2 } if revenue < price * 3
            return { share_direction: :right, share_times: 3 } 
            #TODO: Overwrite 'up' and 'down' text with 'up diag' and 'down diag'
          end

        end
      end
    end
  end
end