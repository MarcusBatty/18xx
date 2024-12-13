# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18IL
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def setup
            @ic_bought_train = nil
            @emr = nil
            super
          end

          def actions(entity)
            return [] if @game.last_set_triggered
            return ['sell_shares'] if entity == current_entity&.player
            return [] if entity != current_entity
            return %w[buy_train sell_shares] if must_sell_shares?(entity) && @game.other_train_pass.nil?
            return %w[buy_train] if must_buy_train?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def must_sell_shares?(corporation)
            return false if corporation.cash > @game.depot.min_depot_price
            return false unless must_buy_train?(corporation)
            return false unless @game.emergency_issuable_cash(corporation) < @game.depot.min_depot_price

            must_issue_before_ebuy?(corporation)
          end

          def must_buy_train?(entity)
            return (entity.cash > @game.depot.min_depot_price) if entity == @game.ic

            entity.trains.empty?
          end

          def ebuy_president_can_contribute?(corporation)
            return false unless @game.emergency_issuable_cash(corporation) < @game.depot.min_depot_price

            !must_issue_before_ebuy?(corporation)
          end

          def can_buy_train?(entity)
            return false if @ic_bought_train

            super
          end

          def description
            'Buy Trains'
          end

          def pass_description
            @acted ? 'Done (Trains)' : 'Skip (Trains)'
          end

          def pass!
            if (borrowed_train = @game.borrowed_trains[current_entity])
              @game.log << "#{current_entity.name} returns a #{borrowed_train.name} train"
              @game.depot.reclaim_train(borrowed_train)
              @game.borrowed_trains[current_entity] = nil
            end
            company = @game.train_subsidy
            if company.ability_uses.first < 99
              @log << "#{company.name} (#{@round.current_operator.name}) closes" if company.closed?
              company.close!
            end
            super
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def check_spend(action)
            return unless action.train.owned_by_corporation?

            min, max = spend_minmax(action.entity, action.train)
            return if (min..max).cover?(action.price)

            max = 0 if action.entity == @game.ic

            if max.zero? && !@game.class::EBUY_OTHER_VALUE
              raise GameError, "#{action.entity.name} may not buy a train from "\
                               'another corporation.'
            else
              raise GameError, "#{action.entity.name} may not spend "\
                               "#{@game.format_currency(action.price)} on "\
                               "#{action.train.owner.name}'s #{action.train.name} "\
                               'train; may only spend between '\
                               "#{@game.format_currency(min)} and "\
                               "#{@game.format_currency(max)}."
            end
          end

          def train_variant_helper(train, _entity)
            train.variants.values
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            depot_trains = [@depot.min_depot_train] if entity.cash < @depot.min_depot_price
            depot_trains = [] if @game.other_train_pass
            other_trains = other_trains(entity)
            other_trains = [] if entity.cash.zero? || @emr || entity == @game.ic
            depot_trains + other_trains
          end

          def process_sell_shares(action)
            @emr = true
            super
          end

          def process_buy_train(action)
            check_spend(action)
            check_ic_last_train(action.train)
            buy_train_action(action)
            @round.bought_trains << action.entity if @round.respond_to?(:bought_trains)
            @game.ic_owns_train if action.entity == @game.ic
            pass! unless can_buy_train?(action.entity)
          end

          def buy_train_action(action, entity = nil, borrow_from: nil)
            @ic_bought_train = true if action.entity == @game.ic

            entity ||= action.entity
            train = action.train
            train.variant = action.variant
            price = action.price
            raise GameError, 'Must issue shares before the president may contribute' if entity.cash < price &&
             !entity.num_ipo_shares.zero? && must_buy_train?(entity)

            remaining = price - buying_power(entity)
            player = entity.owner
            if remaining.positive? && must_buy_train?(entity)
              check_for_cheapest_train(train)

              raise GameError, 'Cannot buy for more than cost' if price > train.price

              player = entity.owner

              if player.cash < remaining
                raise GameError, 'Must sell shares before buying train' if sellable_shares?(player)

                try_take_loan(entity, price)
              else
                player.spend(remaining, entity)
                @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
              end
            end

            check_for_cheapest_train(train) if entity == @game.ic

            @log << "#{entity.name} buys a #{train.name} train for "\
                    "#{@game.format_currency(price)} from #{train.owner.name}"

            @game.buy_train(entity, train, price)
            train.buyable = false if entity == @game.ic && !train.rusts_on
            @game.phase.buying_train!(entity, train, train.owner)
          end

          def check_ic_last_train(train)
            return if train.owner != @game.ic || !@game.ic.trains.one?

            raise GameError, "Cannot buy IC's only train"
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

          def try_take_loan(entity, price)
            remaining = price - buying_power(entity)

            @game.take_loan(entity, remaining) if remaining.positive?
          end

          def must_take_loan?(corporation)
            return false if sellable_shares?(corporation.owner)

            price = @game.depot.min_depot_price
            (@game.buying_power(corporation) + @game.buying_power(corporation.owner)) < price
          end

          def sellable_shares?(player)
            (@game.liquidity(player, emergency: true) - player.cash).positive?
          end
        end
      end
    end
  end
end
