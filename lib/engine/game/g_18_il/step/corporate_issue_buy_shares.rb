# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18IL
      module Step
        class CorporateIssueBuyShares < Engine::Step::BuySellParShares

          def actions(entity)
            return [] if @game.last_set_triggered
            return [] unless entity == current_entity
            return [] if entity == @game.ic && @game.ic_in_receivership?
            actions = []
            actions << 'buy_shares' if can_buy_any?(entity) && !@bought
            actions << 'sell_shares' if !issuable_shares(entity).empty? && !@issued && !@game.sp_used
            actions << 'pass' unless actions.empty?
            actions
          end

          def process_pass(entity)
            @game.sp_used = nil
            super
          end

          def setup
            super
            @issued = nil
            @bought = nil
          end

          def description
            'Corporate Issue/Buy a Share'
          end
          
          def can_sell?(_entity, _bundle)
            true
          end

          def log_skip(entity)
            @log << "#{entity.name} skips #{description.downcase}"
          end

          def visible_corporations
            corps = @game.corporations.select { |c| c.ipoed && !c.ipo_shares.empty?}

            corps = corps.reject {|c| c == current_entity} if current_entity == @game.sp_used
            corps
          end

          def redeemable_shares
            []
          end

          def pass_description
            'Pass'
          end

          def issuable_shares(entity)
            # Done via Sell Shares
            @game.issuable_shares(entity)
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle, allow_president_change: false, swap: nil, movement: :left_share)
            @issued = true
          end

          def can_sell?(entity, bundle)
            return unless bundle
            return true if bundle.owner == entity && bundle.corporation == entity && bundle.num_shares == 1 && !@issued
            false
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return if entity == bundle.owner
            return unless bundle.owner == bundle.corporation
            available_cash(entity) >= bundle.price
          end

          def process_buy_shares(action)
            buy_shares(action.purchase_for || action.entity, action.bundle,
                       swap: action.swap, borrow_from: action.borrow_from,
                       allow_president_change: allow_president_change?(action.bundle.corporation),
                       discounter: action.discounter)
           @bought = true
           @game.sp_used = nil
          end

          def auto_actions(_entity); end

          def can_buy_any?(entity)
            can_buy_any_from_ipo?(entity)
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              next if corporation == entity
              return true if can_buy_shares?(entity, corporation.ipo_shares)
            end
            false
          end

          def can_buy_shares?(entity, shares)
            return false if shares.empty?
    
            sample_share = shares.first
            corporation = sample_share.corporation
            owner = sample_share.owner    
            min_share = nil
            shares.each do |share|
              next unless share.buyable
    
              min_share = share if !min_share || share.percent < min_share.percent
            end
    
            bundle = min_share&.to_bundle
            return unless bundle
    
            available_cash(entity) >= bundle.price
          end

          def allow_president_change?(_corporation)
            false
          end

        end
      end
    end
  end
end