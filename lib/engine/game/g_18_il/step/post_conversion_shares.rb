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
            @acted_players = []
            @conversion_order = nil
            @old_order = @game.totem_order.dup
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

            @acted_players << player.owner
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
            ['Select the corporation to see buy/sell options, or pass:']
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

            @conversion_order ||= [corporation.owner, *@game.totem_order.reject { |p| p == corporation.owner }]
            [@conversion_order.find { |p| p.active? && (can_buy_any?(p) || can_sell?(p, nil)) }].compact
          end

          def post_convert_pass_step!
            return unless @round.converted

            # add non-president players that acted to the back of the totem line
            @acted_players.each { |p| @game.totem_order << @game.totem_order.delete(p) }
            unless @old_order == @game.totem_order
              @log << "New conversion priority order: #{@game.totem_order.map(&:name).join(', ')}"
            end
            corp = @round.converted

            token_counts = {
              10 => [3, 3],
              5 => [1, 1],
            }

            min, max = token_counts[corp.total_shares] || [0, 0]

            @log << "#{corp.name} must buy #{min} token#{min == 1 ? '' : 's'}"
            price = 40
            @round.buy_tokens << { entity: corp, type: :convert, first_price: price, price: price, min: min, max: max }
          end
        end
      end
    end
  end
end
