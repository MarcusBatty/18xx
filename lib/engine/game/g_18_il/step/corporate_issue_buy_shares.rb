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

          def setup
            super
            @issued = nil
            @bought = nil
          end

          def description
            'Corporate Issue/Buy a Share'
          end

          def log_skip(entity)
            if @game.sp_used == @game.share_premium.owner
              @game.share_premium.close!
              @log << "#{@game.share_premium.name} (#{entity.name}) closes"
            else
              @log << "#{entity.name} skips #{description.downcase}"
            end
          end

          def visible_corporations
            corps = @game.corporations.select do |c|
              c.ipoed && !c.ipo_shares.empty? && c.share_price.price <= current_entity.cash
            end
            corps = [current_entity] if @bought
            corps = corps.reject { |c| c == current_entity } if @game.sp_used == @game.share_premium.owner

            corps
          end

          def help
            if current_entity.num_ipo_shares.zero? || @issued || @game.sp_used == @game.share_premium.owner
              return [
                'Buy a share of another corporation:',
              ]
            end
            if @bought
              return [
                "Issue a share of #{current_entity.name}:",
                 ]
            end

            [
            "Issue a share of #{current_entity.name} and/or buy a share of another corporation:",
             ]
          end

          def redeemable_shares(_entity)
            []
          end

          def pass_description
            if current_entity.num_ipo_shares.zero? || @issued || @game.sp_used == @game.share_premium.owner
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

          def process_pass(action)
            if @game.sp_used == @game.share_premium.owner
              @game.share_premium.close!
              @log << "#{@game.share_premium.name} (#{action.entity.name}) closes"
            end
            super
          end

          def process_buy_shares(action)
            buy_shares(action.entity, action.bundle)
            @bought = true
            return unless @game.sp_used == @game.share_premium.owner

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

          # TODO: this is included to bypass check_cash, which was throwing false messages during testing. Remove if not needed
          # def buy_shares(entity, shares)
          #   @log << "#{entity.name} buys a #{shares.corporation.share_percent}% share of "\
          #           "#{shares.owner.name} from the Treasury for #{@game.format_currency(shares.price)}"
          #   shares.owner.share_holders[shares.owner] -= shares.percent
          #   shares.owner.share_holders[entity] += shares.percent
          #   entity.spend(shares.price, shares.owner, check_cash: false)
          #   shares.shares.each { |s| move_share(s, entity) }
          # end

          # def move_share(share, to_entity)
          #   corporation = share.corporation
          #   share.owner.shares_by_corporation[corporation].delete(share)
          #   to_entity.shares_by_corporation[corporation] << share
          #   share.owner = to_entity
          # end

          def allow_president_change?(_corporation)
            false
          end
        end
      end
    end
  end
end
