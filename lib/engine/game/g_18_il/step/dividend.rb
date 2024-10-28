# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18IL
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def share_price_change(entity, revenue = 0)
            print "Dividends"
            price = entity.share_price.price
            print revenue, price
            return { share_direction: :left, share_times: 1 } if revenue == 0
            return { share_direction: :down, share_times: 1 } if revenue < price / 2
            return { share_direction: :up, share_times: 1 } if revenue < price
            return { share_direction: :right, share_times: 1 } if revenue < price * 2
            return { share_direction: :right, share_times: 2 } if revenue < price * 3
            return { share_direction: :right, share_times: 3 } 
        end
=begin
          def share_price_change(entity, revenue = 0)
            return { share_direction: :right, share_times: 1 } if revenue >= entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            {}
          end
=end
        end
      end
    end
  end
end