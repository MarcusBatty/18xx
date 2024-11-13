# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/share_buying'
require_relative '../../../action/buy_shares'

module Engine
  module Game
    module G18IL
      module Step
        class Corporate41BuyShares < Engine::Step::BuySellParShares

          def setup
          super
          end

          def can_buy_any_from_player?(_entity)
            false
          end

            def process_buy_shares(action)
            @round.players_bought[action.entity][action.bundle.corporation] += action.bundle.percent
            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.purchase_for || action.entity, action.bundle,
                       swap: action.swap, borrow_from: action.borrow_from,
                       allow_president_change: @game.pres_change_ok?(action.bundle.corporation))
            track_action(action, action.bundle.corporation)
          end

          def actions(entity)
          super
          end

          def description
            'Buy a Share'
          end

          def auto_actions(_entity); end

          def log_pass(entity)
            return @log << "#{entity.name} passes corporate sell/buy" if @round.current_actions.empty?
            return if bought? && sold?

            action = bought? ? 'to sell' : 'to buy'
            @log << "#{entity.name} declines #{action} shares"
          end

          def pass_description
            if @round.current_actions.empty?
              'Pass (Corporate Share)'
            else
              'Done (Corporate Share)'
            end
          end

          def can_buy_any_from_market?(entity)
            @game.share_pool.shares.any? { |s| can_buy?(entity, s.to_bundle) }
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              return true if corporation.shares.any? { |s| can_buy?(entity, s.to_bundle) }
            end

            false
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return if entity == bundle.corporation
            return unless bundle
            return unless bundle.buyable
            return if bundle.owner.corporation? && bundle.owner != bundle.corporation # can't buy non-IPO shares in treasury
            return if bundle.owner.player? && entity.player? && !@game.allow_player2player_sales?
            return if bundle.owner.player? && entity.corporation?
            super
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            corporation = bundle.corporation
            @game.num_certs(entity) < @game.cert_limit(entity)
          end

          def purchaseable_companies(_entity)
            []
          end

          def buyable_bank_owned_companies(_entity)
            []
          end

          def redeemable_shares(_entity)
            []
          end
        end
      end
    end
  end
end