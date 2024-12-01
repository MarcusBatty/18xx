# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/share_buying'
require_relative '../../../action/buy_shares'
require_relative '../../../action/par'

module Engine
  module Game
    module G18IL
      module Step
        class BaseBuySellParShares < Engine::Step::BuySellParShares

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
            return false if entity == bundle.owner
            #can only buy from corporations the player owns
            return if bundle.owner.is_a?(Corporation) && bundle.owner != bundle.corporation && bundle.owner.owner != entity
            return if bundle.owner == @game.ic
            if entity.corporation?
              entity.cash >= bundle.price && redeemable_shares(entity).include?(bundle)
            else
              corporation = bundle.corporation
              if corporation != bundle.owner
                available_cash(entity) >= modify_purchase_price(bundle) &&
                !@round.players_sold[entity][corporation] &&
                can_buy_multiple?(entity, corporation, bundle.owner) && can_gain?(entity, bundle) 
                #(can_buy_multiple?(entity, corporation, bundle.owner) || !bought?) &&
              else
                available_cash(entity) >= modify_purchase_price(bundle) &&
                !@round.players_sold[entity][corporation] && !bought?
              end
            end
          end

          def can_buy_multiple?(player, bundle_corporation, bundle_owner)
            return unless player == bundle_owner.owner
            return true if bundle_owner.is_a?(Corporation) && bundle_owner != bundle_corporation
           # bundle_corporation.buy_multiple? &&
             @round.current_actions.none? { |x| x.is_a?(Action::Par) } &&
             @round.current_actions.none? { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation != bundle_corporation }
             false
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
            return false if bundle.corporation == @game.ic && @game.ic_in_receivership?
            super && !@corporate_action
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return false if bundle.owner.player? && !@game.can_gain_from_player?(entity, bundle)
    
            corporation = bundle.corporation
    
            corporation.holding_ok?(entity, bundle.common_percent) &&
              (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity)) #TODO: edit to allow going above cert limit when buying reserve shares
          end

          def process_buy_shares(action)
            entity = action.entity
            bundle = action.bundle
            corporation = bundle.corporation

            if entity.player?
              @round.players_bought[action.entity][action.bundle.corporation] += action.bundle.percent
              @round.bought_from_ipo = true if action.bundle.owner.corporation? && action.bundle.owner == action.bundle.corporation
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
            @game.add_ic_operating_ability if corporation == @game.ic && !@game.ic_in_receivership?
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

          def post_share_pass_step!
            corp = @round.corp_started
            if @game.closed_corporations.include?(corp)
              @game.closed_corporations.delete(corp)
            else
              case corp.total_shares
              when 10
                min = 2
                max = 5
                @log << "#{corp.name} must buy between #{min} and #{max} tokens"
              when 5
                min = 1
                max = 1
                @log << "#{corp.name} must buy 1 token"
              when 2
                @log << "#{corp.name} does not buy tokens"
                return
              end
                price = 40
                @log << "Each token costs $40"
                @round.buy_tokens << {
                  entity: corp,
                  type: :start,
                  first_price: price,
                  price: price,
                  min: min,
                  max: max,
                }
            end
          end
        end
      end
    end
  end
end