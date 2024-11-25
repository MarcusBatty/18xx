# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative '../../../game_error'

module Engine
  module Game
    module G18IL
      module Step
        class BuyTrainBeforeRunRoute < Engine::Step::BuyTrain

          ACTIONS = %w[buy_train pass].freeze

          def actions(entity)
            return ACTIONS if can_buy_train?(entity)

            []
          end

          def round_state
            {
              premature_trains_bought: [],
            }
          end

          def active_entities
            return [] unless @game.rush_delivery&.owner == @round.current_operator
              [@game.rush_delivery.owner]
            end

          def process_buy_train(action)
            from_depot = action.train.from_depot?
            raise GameError, 'Premature buys are only allowed from the Depot' unless from_depot

            buy_train_action(action)

            @round.bought_trains << corporation if from_depot && @round.respond_to?(:bought_trains)
            @round.premature_trains_bought << action.entity

            pass! unless can_buy_train?(action.entity)
          end

          def description
            "Use #{@game.rush_delivery.name} ability"
          end

          def pass!
            super
            return if @round.premature_trains_bought.empty?

            ability = ability(@game.rush_delivery.owner)
            return unless ability

            ability.use!
            @log << "#{@game.rush_delivery.name} (#{current_entity.name}) closes"
            @game.rush_delivery.close!
          end

          def can_buy_train?
            return false if !@round.premature_trains_bought.empty?
            super
          end

          def help
            "#{@game.rush_delivery.name} allows corporation to buy one train from the Depot prior to running trains:"
          end

          def ability(entity)
            return if !@game.rush_delivery || !entity || @game.rush_delivery.owner != entity

            @game.abilities(@game.rush_delivery, :train_buy)
          end

          def do_after_buy_train_action(action, _entity)
            # Trains bought with this ability can be run even if they have already run this OR
            action.train.operated = false
          end
        end
      end
    end
  end
end