# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Step
        class CorporateBuyShares < Engine::Step::CorporateBuyShares

          def description
            'Buy a Share'
          end

          def round_state
            { corporations_bought: Hash.new { |h, k| h[k] = [] } }
          end

          def actions(entity)
            return [] unless entity == current_entity
            actions = []
            actions << 'corporate_buy_shares' if can_buy_any?(entity)
            actions << 'pass' if actions.any?
            actions
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
            can_buy_any_from_ipo?(entity)
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
            return unless bundle.buyable
            return unless bundle.corporation.ipoed
            return if bundle.presidents_share
            return if entity == bundle.corporation
            return if bought?(entity)
            entity.cash >= bundle.price
          end

          def process_corporate_buy_shares(action)
            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: false)
            track_action(action, action.bundle.corporation)
          end

          def source_list(entity)
            source = @game.sorted_corporations.select do |corp|
              corp != entity && corp.floated? && !corp.closed?
            end
            source
          end

          def bought?(entity)
            @round.corporations_bought[entity].any?
          end

          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil, discounter: nil)
            corp = shares.corporation
            @game.share_pool.buy_shares(entity, shares, exchange: exchange, swap: swap, allow_president_change: allow_president_change)
            price = corp.share_price.price * shares.num_shares
            @game.bank.spend(price, corp)
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