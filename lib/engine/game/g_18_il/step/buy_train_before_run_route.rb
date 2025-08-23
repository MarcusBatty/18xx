# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../game_error'

module Engine
  module Game
    module G18IL
      module Step
        class BuyTrainBeforeRunRoute < G18IL::Step::BuyTrain
          ACTIONS = %w[buy_train pass].freeze

          def actions(entity)
            return [] if @game.last_set_triggered
            return [] if @game.other_train_pass == true
            return [] unless entity == current_entity
            return [] if entity.cash < @depot.min_depot_price && entity.trains.any?

            actions = []
            actions << %w[buy_train sell_shares] if must_sell_shares?(entity)
            actions << %w[buy_train] if can_buy_train?(entity)
            actions << %w[pass] unless @acted

            actions.flatten
          end

          def must_buy_train?
            false
          end

          def round_state
            {
              premature_trains_bought: [],
            }
          end

          def active_entities
            return [] unless @game.rush_delivery&.owner == @round.current_operator

            [@game.rush_delivery&.owner].compact
          end

          def process_buy_train(action)
            raise GameError, 'Premature buys are only allowed from the Depot' unless action.train.from_depot?

            buy_train_action(action)

            @round.bought_trains << action.entity if @round.respond_to?(:bought_trains)
            @round.premature_trains_bought << action.entity

            @log << "#{@game.rush_delivery.name} (#{action.entity.name}) closes"
            @game.rush_delivery.close!
            pass!
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains

            depot_trains = [@depot.min_depot_train] if entity.cash < @depot.min_depot_price
            depot_trains
          end

          def description
            "Use #{@game.rush_delivery.name} ability"
          end

          def can_buy_train?(entity)
            return false unless @round.premature_trains_bought.empty?

            super
          end

          def help
            "#{@game.rush_delivery&.name} allows the corporation to buy one train from the Depot prior to running trains:"
          end

          def ability(entity)
            return if !@game.rush_delivery || !entity || @game.rush_delivery&.owner != entity

            @game.abilities(@game.rush_delivery, :train_buy)
          end

          def do_after_buy_train_action(action, _entity)
            action.train.operated = false
          end
        end
      end
    end
  end
end
