# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18IL
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? || @game.route_trains(entity).empty? || !@game.can_run_route?(entity)

            actions = []
            return actions unless entity.corporation?

            @game.train_marker_adjustment(entity)
            return [] if entity.receivership?

            actions << 'run_routes'
            actions << 'scrap_train' unless scrappable_trains(entity).count < 2
            actions
          end

          def scrappable_trains(entity)
            entity.trains
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def process_scrap_train(action)
            raise GameError, 'Can only scrap trains owned by the corporation' if action.entity != action.train.owner

            @game.scrap_train(action.train)
          end
        end
      end
    end
  end
end
