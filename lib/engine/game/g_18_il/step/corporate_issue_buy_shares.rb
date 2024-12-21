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
            return [] if entity == @game.ic

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity) && !@bought
            actions << 'sell_shares' if issuable_share_available(entity)
            actions << 'pass' unless actions.empty?
            actions
          end

          def setup
            super
            @issued = nil
            @bought = nil
            @game.corporate_buy = nil
          end

          def description
            'Corporate Issue/Buy a Share'
          end

          def log_skip(entity)
            if !@game.optional_rules&.include?(:intro_game) && @game.sp_used == @game.share_premium.owner
              @game.share_premium.close!
              @log << "#{@game.share_premium.name} (#{entity.name}) closes"
            else
              @log << "#{entity.name} skips #{description.downcase}"
            end
          end

          def visible_corporations
            corps = @game.corporations.select do |c|
              c.ipoed && !c.ipo_shares.empty? && c != current_entity && c != @game.ic
            end
            corps << current_entity if issuable_share_available(current_entity)
            corps = [current_entity] if @bought
            corps
          end

          def issuable_share_available(entity)
            return false if issuable_shares(entity).empty?
            return false if @issued
            return true if @game.optional_rules.include?(:intro_game)
            return false if @game.sp_used == @game.share_premium.owner

            true
          end

          def help
            return ['Buy a share of another corporation:'] unless issuable_share_available(current_entity)

            return ["Issue a share of #{current_entity.name}:"] if @bought

            ["Issue a share of #{current_entity.name} and/or buy a share of another corporation:"]
          end

          def redeemable_shares(_entity)
            []
          end

          def pass_description
            unless issuable_share_available(current_entity)
              return [
                'Pass (Buy)',
              ]
            end
            if @bought
              return [
                'Pass (Issue)',
                 ]
            end
            [
            'Pass (Issue/Buy)',
             ]
          end

          def issuable_shares(entity)
            # Done via Sell Shares
            @game.issuable_shares(entity)
          end

          def process_sell_shares(action)
            old_price = action.entity.share_price.price
            @game.sell_shares_and_change_price(action.bundle, allow_president_change: false, swap: nil, movement: :left_share)
            new_price = action.entity.share_price.price
            @log << "#{action.entity.name}'s share price moves left from #{@game.format_currency(old_price)} to "\
                    "#{@game.format_currency(new_price)}"
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

          def log_pass(entity)
            @log << "#{entity.name} passes #{description.downcase}"
          end

          def process_pass(action)
            log_pass(action.entity)
            if !@game.optional_rules&.include?(:intro_game) && @game.sp_used == @game.share_premium.owner
              @game.share_premium.close!
              @log << "#{@game.share_premium.name} (#{action.entity.name}) closes"
            end
            pass!
          end

          def process_buy_shares(action)
            buy_shares(action.entity, action.bundle)
            @game.corporate_buy = action.bundle
            @bought = true
            return if @game.optional_rules&.include?(:intro_game) || @game.sp_used != @game.share_premium.owner

            @issued = true
            @game.share_premium.close!
            @log << "#{@game.share_premium.name} (#{action.entity.name}) closes"
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
