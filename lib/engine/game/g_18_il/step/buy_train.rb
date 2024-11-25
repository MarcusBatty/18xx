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
            return [] if entity == @game.ic && @game.ic.presidents_share.owner == @game.ic && @game.ic.trains.any?
            return ['sell_shares'] if entity == current_entity&.player
            return [] if entity != current_entity
            return %w[buy_train sell_shares] if must_sell_shares?(entity)
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
            return false if @ic_bought_train = true
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
              @game.log << "#{current_entity.name} returns #{borrowed_train.name}"
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

          def process_buy_train(action)
            check_spend(action)
            check_ic_last_train(action)
            buy_train_action(action)
            @game.ic.remove_ability(@game.ic.all_abilities.find { |a| a.type == :borrow_train }) if action.entity == @game.ic && @game.ic.trains.any?
            pass! if !can_buy_train?(action.entity) && pass_if_cannot_buy_train?(action.entity)
          end

          def buy_train_action(action, entity = nil, borrow_from: nil)
            #Check if the train is IC's last
            check_ic_last_train(entity)
            super
            @ic_bought_train = true if action.entity == @game.ic
          end

          def check_ic_last_train(entity)
            return unless entity == @game.ic && entity.trains.one?
            raise GameError, "Cannot buy IC's only train"
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

        end
      end
    end
  end
end