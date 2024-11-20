# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18IL
      module Step
        class BuyTrain < Engine::Step::BuyTrain

          def setup

            super
          end

          def actions(entity)
            return [] if entity.receivership? && entity.trains.any?
            return [] if entity != current_entity
            actions = []
            actions << 'buy_train' if can_buy_train?(entity)
            actions << 'pass' unless actions.empty? || must_buy_train?(entity)
            actions
          end

          def description
            'Buy Trains'
          end

          def pass_description
            @acted ? 'Done (Trains)' : 'Skip (Trains)'
          end

          def pass!
            company = @game.train_subsidy
            company.close! if company.ability_uses.first < 4
            @last_share_sold_price = nil
            @last_share_issued_price = nil
            super
          end

          def check_spend(action)
            return unless action.train.owned_by_corporation?

            min, max = spend_minmax(action.entity, action.train)
            return if (min..max).cover?(action.price)

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
          
          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def process_buy_train(action)
            check_spend(action)
            buy_train_action(action)
            pass! if !can_buy_train?(action.entity) && pass_if_cannot_buy_train?(action.entity)
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

        end
      end
    end
  end
end