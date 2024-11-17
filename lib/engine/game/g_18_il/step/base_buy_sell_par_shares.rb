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

          def actions(entity)
            return corporate_actions(entity) if !entity.player? && entity.owned_by?(current_entity)
            return [] unless entity.player?

            if @corporate_action
              return [] unless entity.owner == current_entity
              return ['pass'] if any_corporate_actions?(entity)
              return []
            end

            return [] unless entity == current_entity
            actions = super
  
            if (actions.any? || any_corporate_actions?(entity)) && !actions.include?('pass') && !must_sell?(entity)
              actions << 'pass'
            end

            actions
          end

          def log_pass(entity)
            if @corporate_action
              @log << "#{entity.name} finishes acting for #{@corporate_action.entity.name}"
            else
              super
            end
          end

          def can_sell_order?
            !bought?
          end

          def corporate_actions(entity)
            return [] if @corporate_action && @corporate_action.entity != entity

            actions = []
            if @round.current_actions.none?
              actions << 'buy_shares' unless @game.redeemable_shares(entity).empty?
            end
            actions
          end

          def any_corporate_actions?(entity)
            @game.corporations.any? { |corp| corp.owner == entity && !corporate_actions(corp).empty? }
          end

          def description
            'Sell then Buy Shares'
          end

          def round_state
            super.merge({ corp_started: nil})
          end

          def setup
            super
            @round.corp_started = nil
            @corporate_action = nil
          end

          def visible_corporations
            started_corps = @game.corporations.select(&:ipoed)
            potential_corps = @game.corporations.select { |corp| @game.players.find { |player| @game.can_par?(corp, player)}}
            return (started_corps + potential_corps)
          end

          def can_buy_any_from_player?(_entity)
            false
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return unless bundle.buyable

            if entity.corporation?
              entity.cash >= bundle.price && redeemable_shares(entity).include?(bundle)
            else
              super
            end
          end

          def pass!
            @round.current_actions << @corporate_action
            super
            post_share_pass_step! if @round.corp_started
          end

          def can_sell_any_of_corporation?(entity, corporation)
            bundles = @game.bundles_for_corporation(entity, corporation).reject { |b| b.corporation == entity }
            bundles.any? { |bundle| can_sell?(entity, bundle) }
          end

          def can_sell?(entity, bundle)
            super && !@corporate_action
          end

          def process_buy_shares(action)
            entity = action.entity
            bundle = action.bundle
            corporation = bundle.corporation

            if entity.player?
              @round.players_bought[action.entity][action.bundle.corporation] += action.bundle.percent
              @round.bought_from_ipo = true if action.bundle.owner.corporation?
              buy_shares(action.purchase_for || action.entity, action.bundle,
                         swap: action.swap, borrow_from: action.borrow_from,
                         allow_president_change: allow_president_change?(action.bundle.corporation),
                         discounter: action.discounter)
              track_action(action, action.bundle.corporation)
            else
              buy_shares(entity, bundle)
              track_action(action, corporation, false)
              @corporate_action = action
            end
          end
          
          def redeemable_shares(entity)
            return [] if @corporate_action && entity != @corporate_action.entity

            # Done via Buy Shares
            @game.redeemable_shares(entity)
          end

          def process_par(action)
            @round.corp_started = action.corporation
            super
            company = @game.company_by_id(action.corporation.name)
            @game.companies.delete(company)
            company.close!
          end

        end
      end
    end
  end
end