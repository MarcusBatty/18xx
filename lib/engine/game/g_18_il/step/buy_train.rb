# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18IL
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def setup
            @ic_bought_train = nil
            super
          end
          
          def actions(entity)
            return ['sell_shares'] if entity == current_entity&.player
            return [] if entity != current_entity
            return %w[buy_train sell_shares] if must_sell_shares?(entity) && @game.other_train_pass == nil
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

          def ebuy_president_can_contribute?(corporation)
            return false unless @game.emergency_issuable_cash(corporation) < @game.depot.min_depot_price

            !must_issue_before_ebuy?(corporation)
          end

          def can_buy_train?
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
            company.close! if company.ability_uses.first < 4
            super
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def must_buy_train?(entity)
            return super unless entity == @game.ic
            entity.cash > @game.depot.min_depot_price
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

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            depot_trains = [@depot.min_depot_train] if entity.cash < @depot.min_depot_price
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
            @game.ic_owns_train if action.entity == @game.ic
            pass! if !can_buy_train?(action.entity) && pass_if_cannot_buy_train?(action.entity)
          end

          def buy_train_action(action, entity = nil, borrow_from: nil)
            @ic_bought_train = true if action.entity == @game.ic

            entity ||= action.entity
            train = action.train
            train.variant = action.variant
            price = action.price
    
            # Check if the train is actually buyable in the current situation
            if !(@game.depot.available(entity).include?(train) || buyable_trains(entity).include?(train))
              raise GameError, "Not a buyable train: #{train.id}"
            end
            raise GameError, 'Must pay face value' if must_pay_face_value?(train, entity, price)
            raise GameError, 'An entity cannot buy a train from itself' if train.owner == entity
    
            remaining = price - buying_power(entity)
            if remaining.positive? && president_may_contribute?(entity, action.shell)
              check_for_cheapest_train(train)
    
              raise GameError, 'Cannot buy for more than cost' if price > train.price
    
              player = entity.owner
    
              if player.cash < remaining
                raise GameError, "Must sell shares before buying train" if sellable_shares?(player)
                extra_needed = remaining - player.cash
                try_take_loan(entity, price)
              else
                player.spend(remaining, entity)
                @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
              end
            end
    
            @log << "#{entity.name} buys a #{train.name} train for "\
                    "#{@game.format_currency(price)} from #{train.owner.name}"
    
            @game.buy_train(entity, train, price)
            @game.phase.buying_train!(entity, train, train.owner)
            pass! if !can_buy_train?(entity) && pass_if_cannot_buy_train?(entity)
          end

          def check_ic_last_train(train)
            return unless train.owner == @game.ic && @game.ic.trains.one?
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
            @game.buying_power(corporation) < price
          end

          def sellable_shares?(player)
            (@game.liquidity(player, emergency: true) - player.cash).positive?
          end
          
        end
      end
    end
  end
end