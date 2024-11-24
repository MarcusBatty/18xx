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

          def dividend_types
            return %i[withhold] if current_entity == @game.ic && @game.ic.presidents_share.owner == @game.ic
            return DIVIDEND_TYPES
          end

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :left, share_times: 2 } if entity == @game.ic && @game.ic.presidents_share.owner == @game.ic
            return { share_direction: :down, share_times: 1 } if revenue == 0 && price == 20
            return { share_direction: :left, share_times: 1 } if revenue == 0
            return { share_direction: :down, share_times: 1 } if revenue < price / 2
            return { share_direction: :up, share_times: 1 } if revenue < price
            return { share_direction: :right, share_times: 1 } if revenue < price * 2
            return { share_direction: :right, share_times: 2 } if revenue < price * 3
            return { share_direction: :right, share_times: 3 } 
            #TODO: Overwrite 'up' and 'down' text with 'up diag' and 'down diag'
          end

          def skip!
            super

            return unless current_entity.receivership?
            return if current_entity.trains.any?
            return if current_entity.share_price.price.zero?

            @log << "#{current_entity.name} is in receivership and does not own a train."
            share_price_change(current_entity)
          end

        end
      end
    end
  end
end