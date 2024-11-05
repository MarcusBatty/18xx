# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/emergency_money'

module Engine
  module Game
    module G18IL
      module Step
        class EmergencyMoneyRaising < Engine::Step::Base
          include Engine::Step::EmergencyMoney
          @@bundle = []

          def actions(entity)
            return [] unless entity.corporation?
            return [] unless entity == current_entity
            return [] unless entity.trains.empty?
            return [] unless entity.cash < @game.depot.min_depot_price
            @converted == false
            
            if entity.total_shares == 2
              @game.convert(entity)
              @converted = true
            end

            if @game.emergency_issuable_shares(entity)[-1].share_price + entity.cash < @game.depot.min_depot_price && entity.total_shares == 5
               @game.convert(entity) 
               @log << "#{entity.name} is forced to convert from a #{@converted ? "2-share to a 10-share" : "5-share to a 10-share"} corporation"
            end
              @@bundle = emergency_issuable_bundles(entity)
              actions = []
              actions << 'sell_shares'
              actions << 'pass'
              actions
          end

          def description
            'Emergency Money Raising'
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(@@bundle)
            old = action.bundle.corporation.share_price.price
            @game.stock_market.move_down(action.bundle.corporation) 
            new = action.bundle.corporation.share_price.price
            @log << "#{action.bundle.corporation.name}'s share price moves left diagonally from $#{old} to $#{new}"
            pass!
          end

          def emergency_issuable_bundles(entity)
            eligible, remaining = @game.emergency_issuable_shares(entity).partition { |bundle| bundle.price + entity.cash < @game.depot.min_depot_price }
            eligible_shares = eligible.each { |n| n.price }
            return remaining.empty? ? eligible.last(1) : remaining.take(1)
          end

        end
      end
    end
  end
end