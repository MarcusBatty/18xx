# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18IL
      module Step
        class CorporateBuySellShares < Engine::Step::BuySellParShares

          def actions(entity)
            return [] if entity.corporation? && entity.receivership?
            return [] unless entity == current_entity
    
            actions = []
            @log << "can_buy_any: #{can_buy_any?(entity)}"
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'sell_shares' unless issuable_shares(entity).empty?
            actions << 'pass' unless actions.empty?
            actions
          end

          def redeemable_shares(_corp)
                        @log << "redeemable_shares"
            []
          end

          def description
            'Issue and/or Buy a Share'
          end

          def pass_description
            'Pass'
          end

          def auto_actions(_entity); end

          def can_buy_any?(entity)
            @log << "can_buy_any?"
            @log << "can_buy_any_from_ipo? #{can_buy_any_from_ipo?(entity)}"
            (can_buy_any_from_market?(entity) ||
            can_buy_any_from_ipo?(entity) ||
            can_buy_any_from_player?(entity))
          end

          def can_buy_any_from_ipo?(entity)
            @log << "can_buy_any_from_ipo?"
            count = 0
            @game.corporations.each do |corporation|
              count += 1
              @log << "#{count}"
              next unless corporation.ipoed
              @log<< "can_buy_shares? #{can_buy_shares?(entity, corporation.ipo_shares)}"
              return true if can_buy_shares?(entity, corporation.ipo_shares)
            end

            false
          end
          
          def can_buy_shares?(entity, shares)
                        @log << "can_buy_shares?"
                        @log << "shares.empty? #{shares.empty?}"
            return false if shares.empty?
    
            sample_share = shares.first
            corporation = sample_share.corporation
            owner = sample_share.owner
            @log << "bought? #{bought?}"
            return false if bought?
    
            min_share = nil
            shares.each do |share|
              @log << "share: #{share}"
              next unless share.buyable
    
              min_share = share if !min_share || share.percent < min_share.percent
            end
            @log << "min_share: #{min_share}"
            bundle = min_share&.to_bundle
            @log << "bundle: #{bundle}"
            return unless bundle
            available_cash(entity) >= modify_purchase_price(bundle) && can_gain?(entity, bundle)
          end

          def can_gain?(entity, bundle, exchange: false)
                        @log << "can_gain?"
            return if !bundle || !entity
            return false if bundle.owner.player? && !@game.can_gain_from_player?(entity, bundle)
    
            corporation = bundle.corporation
            @log << "corp: #{corporation.name}"
            corporation.holding_ok?(entity, bundle.common_percent)
          end

          def can_buy?(entity, bundle)
            @log << "can buy?"
            return unless bundle

            # can't buy from own IPO
            return if entity == bundle.corporation && bundle.owner == bundle.corporation.ipo_owner

            # can't buy from other corporations
            return if bundle.owner.corporation?

            super
          end

          def issuable_shares(entity)
            # Done via Sell Shares
            @game.issuable_shares(entity)
          end

          # FIXME: move to common location
          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil,
                         discounter: nil)
                         @log << "buy_shares"
            corp = shares.corporation
            if shares.owner == corp.ipo_owner
              # IPO shares pay corporation
              @game.share_pool.buy_shares(entity,
                                          shares,
                                          exchange: exchange,
                                          swap: swap,
                                          allow_president_change: allow_president_change)
              price = corp.share_price.price * shares.num_shares
              @game.bank.spend(price, corp)
            else
              super
            end
          end

#delete
          def visible_corporations
          @game.corporations.select(&:ipoed)
          end


          def process_buy_shares(action)
            @log << "process_buy_shares"
            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: false)
            track_action(action, action.bundle.corporation)
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
            old = action.bundle.corporation.share_price.price
            @game.stock_market.move_left(action.bundle.corporation) 
            new = action.bundle.corporation.share_price.price
            @log << "#{action.bundle.corporation.name}'s share price moves left horizontally from $#{old} to $#{new}"
            pass!
          end

          def share_str(bundle)
            num_shares = bundle.num_shares
            return "a #{bundle.percent}% IPO share" if num_shares == 1

            "#{num_shares} IPO shares"
          end

        end
      end
    end
  end
end