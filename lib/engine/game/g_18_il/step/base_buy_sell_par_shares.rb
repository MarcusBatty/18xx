# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/share_buying'
require_relative '../../../action/buy_shares'
require_relative '../../../action/par'
require_relative 'corp_start'

module Engine
  module Game
    module G18IL
      module Step
        class BaseBuySellParShares < Engine::Step::BuySellParShares
          include CorpStart
          def description
            'Sell then Buy Shares'
          end

          def round_state
            super.merge({ corp_started: nil })
          end

          def setup
            super
            @round.corp_started = nil
          end

          def can_buy_any_from_player?(_entity)
            false
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return unless bundle.buyable
            return if bundle.owner.corporation? && bundle.owner != bundle.corporation # can't buy non-IPO shares in treasury
            return if bundle.owner.player? && entity.player? # && !@game.allow_player2player_sales?
            return if bundle.owner.player? && entity.corporation?

            super
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity

            corporation = bundle.corporation

            # can't exceed cert limit
            (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity))
          end

          def pass!
            super
            post_share_pass_step! if @round.corp_started
          end

          def can_sell_any_of_corporation?(entity, corporation)
            bundles = @game.bundles_for_corporation(entity, corporation).reject { |b| b.corporation == entity }
            bundles.any? { |bundle| can_sell?(entity, bundle) }
          end

          def process_buy_shares(action)
            @round.players_bought[action.entity][action.bundle.corporation] += action.bundle.percent
            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.purchase_for || action.entity, action.bundle,
                       swap: action.swap, borrow_from: action.borrow_from,
                       allow_president_change: true)
            track_action(action, action.bundle.corporation)
          end

          def get_par_prices(entity, corp)
            return super if corp.type == :major

            @game
              .stock_market
              .par_prices
              .select { |p| p.type == :par && p.price * 2 <= entity.cash }
          end

          def process_par(action)
            @round.corp_started = action.corporation
            super
          end

        end
      end
    end
  end
end