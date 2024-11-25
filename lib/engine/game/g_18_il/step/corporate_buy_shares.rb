# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Step
        class CorporateBuyShares < Engine::Step::CorporateBuyShares

          PURCHASE_ACTIONS = [Action::CorporateBuyShares].freeze

          def description
            'Buy a Share'
          end
    
          def round_state
            { corporations_bought: Hash.new { |h, k| h[k] = [] } }
          end
    
          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity == @game.ic && @game.ic.presidents_share.owner == @game.ic
    
            actions = []
            actions << 'corporate_buy_shares' if can_buy_any?(entity)
            actions << 'pass' if actions.any?
    
            actions
          end
    
          def help
            [ "Select a corporation to buy a share or pass:"]
          end

          def pass_description
            'Pass (Share Buy)'
          end
    
          def log_pass(entity)
            @log << "#{entity.name} passes buying shares"
          end
    
          def log_skip(entity)
            @log << "#{entity.name} skips corporate share buy"
          end
    
          def can_buy_any?(entity)
            can_buy_any_from_market?(entity) || can_buy_any_from_president?(entity)
          end
    
          def can_buy_any_from_market?(entity)
            @game.share_pool.shares.any? { |s| can_buy?(entity, s.to_bundle) }
          end
    
          def can_buy_corp_from_market?(entity, corporation)
            @game.share_pool.shares_by_corporation[corporation].any? { |s| can_buy?(entity, s.to_bundle) }
          end
    
          def can_buy_any_from_president?(entity)
            return unless @game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT
    
            entity.owner.shares.any? { |s| can_buy?(entity, s.to_bundle) }
          end
    
          def can_buy?(entity, bundle)
            return unless bundle
            return unless bundle.buyable
            return unless bundle.corporation.ipoed
            return if bundle.presidents_share
            return if entity == bundle.corporation
            return if bought?(entity)
            entity.cash >= bundle.price
          end
    
          def process_corporate_buy_shares(action)
            buy_shares(action.entity, action.bundle)
            @round.corporations_bought[action.entity] << action.bundle.corporation
            pass! unless can_buy_any?(action.entity)
          end
    
          def source_list(entity)
            source = if @game.class::CORPORATE_BUY_SHARE_SINGLE_CORP_ONLY && bought?(entity)
                       @game.sorted_corporations.select do |corp|
                         corp == last_bought(entity) &&
                           !corp.num_market_shares.zero? &&
                           can_buy_corp_from_market?(entity, corp)
                       end
                     else
                       @game.sorted_corporations.select do |corp|
                         corp != entity &&
                           corp.floated? &&
                           !corp.closed? &&
                           !corp.num_market_shares.zero? &&
                           can_buy_corp_from_market?(entity, corp)
                       end
                     end
    
            source << entity.owner if @game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT && can_buy_any_from_president?(entity)
    
            source
          end
    
          def bought?(entity)
            @round.corporations_bought[entity].any?
          end
    
          def last_bought(entity)
            @round.corporations_bought[entity].last
          end

        end
      end
    end
  end
end