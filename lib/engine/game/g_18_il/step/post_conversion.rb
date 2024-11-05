# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G18IL
      module Step
        class PostConversion < Engine::Step::Base
          include Engine::Step::ShareBuying

          def actions(entity)
            return [] if !entity.player? || !@converted

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'sell_shares' if can_sell?(entity, nil)
            actions << 'pass' if actions.any?
            actions
          end

          def process_buy_shares(action)
            player = action.entity
            buy_shares(player, action.bundle)

            player.pass! if !corporation.president?(player.owner) || !can_buy_any?(player)
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
            action.entity.pass!
          end

          def process_pass(action)
            log_pass(action.entity)
            action.entity.pass!
          end

          def can_buy_any?(entity)
            can_buy?(entity, corporation.shares[0])
          end

          def can_buy?(entity, bundle)
            return unless bundle

            corporation == bundle.corporation &&
              bundle.owner != @game.share_pool &&
              entity.cash >= bundle.price &&
              can_gain?(entity, bundle)
          end

          def can_sell?(entity, _bundle)
            !corporation.president?(entity) &&
              entity.shares_of(corporation).any? { |share| share.percent.positive? }
          end

          def description
            'Buy/Sell Shares After Conversion'
          end

          def corporation
            @converted
          end

          def active?
            corporation
          end

          def active_entities
            return [] unless corporation

            [@game.players.rotate(@game.players.index(corporation.owner))
            .find { |p| p.active? && (can_buy_any?(p) || can_sell?(p, nil)) }].compact
          end

        end
      end
    end
  end
end