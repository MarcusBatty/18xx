# frozen_string_literal: true

require_relative '../../../step/corporate_sell_shares'
require_relative 'buy_train'

module Engine
  module Game
    module G18IL
      module Step
        class CorporateSellShares < Engine::Step::BuyTrain

          def description
            'Emergency Sell Shares'
          end

          def setup
            @game.other_train_pass = nil
            super
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.cash > @game.depot.min_depot_price
            return [] unless entity.shares != entity.ipo_shares
            actions = []
            actions << 'corporate_sell_shares' if entity.cash < @game.depot.min_depot_price && entity.trains.empty?
            actions << 'pass' if !other_trains(entity).empty?
            #actions << 'buy_train' if !other_trains(entity).empty? && entity.trains.empty?
    
            actions
          end

          def bought?(entity, corporation); end

          def log_skip(entity); end

          def pass_description
            'Pass'
          end

          def help
            [
            "If emergency money raising, corporation must sell reserve shares before issuing.",
            "Pass if buying a train from another corporation"
          ]
          end

          def pass!
            @game.other_train_pass = true
            super
          end

          def process_corporate_sell_shares(action)
            sell_shares(action.entity, action.bundle, swap: action.swap)
          end

          def can_sell_any?(entity)
            entity.corporate_shares.select { |share| can_sell?(entity, share.to_bundle) }.any?
          end
    
          def can_sell?(entity, bundle)
            return unless bundle
            return false if entity != bundle.owner
    
            entity != bundle.corporation
          end
    
          def sell_shares(entity, shares, swap: nil)
            raise GameError, "Cannot sell shares of #{shares.corporation.name}" if !can_sell?(entity, shares) && !swap
    
            @game.sell_shares_and_change_price(shares, swap: swap)
          end
    
          def source_list(entity)
            entity.corporate_shares.map do |share|
              share.corporation
            end.compact.uniq
          end
          
        end
      end
    end
  end
end