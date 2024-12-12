# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18IL
      module Step
        class PostConversionShares < Engine::Step::Base
          include Engine::Step::ShareBuying

          def setup
            super
            @game.players.each(&:unpass!)
          end

          def actions(entity)
            return [] if !entity.player? || !@round.converted

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'sell_shares' if can_sell?(entity, nil)
            actions << 'pass' if actions.any?
            actions
          end

          def pass!
            super
            post_convert_pass_step! if @round.converted
            @round.converted = nil
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return false if bundle.owner.player? && !@game.can_gain_from_player?(entity, bundle)

            corporation = bundle.corporation

            corporation.holding_ok?(entity, bundle.common_percent)
          end

          def log_pass(entity)
            @log << "#{entity.name} declines to buy shares"
          end

          def visible_corporations
            [corporation]
          end

          def show_other_players
            true
          end

          def process_buy_shares(action)
            player = action.entity
            buy_shares(player, action.bundle)
            player.pass! if !corporation.president?(player.owner) || !can_buy_any?(player)
            return if corporation.president?(player.owner)

            @game.players.insert((@game.players.size - 1), @game.players.delete_at(@game.players.index(player)))
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

          def help
            ['Select the corporation to buy a share or pass:']
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
            'Buy/Sell Shares Post Conversion'
          end

          def corporation
            @round.converted
          end

          def active?
            corporation
          end

          def issuable_shares
            []
          end

          def active_entities
            return [] unless corporation

            [@game.players.unshift(@game.players.delete(corporation.owner)).find do |p|
               p.active? && (can_buy_any?(p) || can_sell?(p, nil))
             end].compact
          end

          def post_convert_pass_step!
            return unless @round.converted

            corp = @round.converted
            case corp.total_shares
            when 10
              min = 3
              max = 3
              @log << "#{corp.name} must buy 3 tokens"
            when 5
              min = 1
              max = 1
              @log << "#{corp.name} must buy 1 token"
            end

            price = 40
            @round.buy_tokens << {
              entity: corp,
              type: :convert,
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
