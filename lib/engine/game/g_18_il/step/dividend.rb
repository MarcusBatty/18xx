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
            return %i[withhold] if current_entity == @game.ic && @game.ic_in_receivership?
            return DIVIDEND_TYPES
          end

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
          #  return { share_direction: :left, share_times: 2 } if entity == @game.ic && @game.ic_in_receivership?
            return { share_direction: :down, share_times: 1 } if revenue == 0 && price == 20
            return { share_direction: :left, share_times: 1 } if revenue == 0
            return { share_direction: :down, share_times: 1 } if revenue < price / 2
            return { share_direction: :up, share_times: 1 } if revenue < price
            return { share_direction: :right, share_times: 1 } if revenue < price * 2
            return { share_direction: :right, share_times: 2 } if revenue < price * 3
            return { share_direction: :right, share_times: 3 } 
            #TODO: Overwrite 'up' and 'down' text with 'up diag' and 'down diag'
          end

          def log_run_payout(entity, kind, revenue, subsidy, action, payout)
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
            end
    
            if payout[:corporation].positive?
              if @game.train_borrowed
                @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])} (#{@game.format_currency(payout[:corporation])} paid to bank as lease payment)"
              else
                @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])}"
              end
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end
            @log << "#{entity.name} earns #{@game.subsidy_name} of #{@game.format_currency(subsidy)}" if subsidy.positive?
            @game.train_borrowed = nil
            @game.lincoln_funeral_car.close! if @game.lincoln_triggered
            @game.lincoln_triggered = nil
          end

          def dividend_options(entity)
            revenue = total_revenue
            revenue = total_revenue / 2 if @game.train_borrowed
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
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