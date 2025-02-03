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
            actions << 'scrap_train' if scrappable_trains(entity).count > 1 && !@game.last_set_triggered
            if choosing?(entity) && entity == @game.lincoln_funeral_car.owner && !@game.lfc_train && @game.phase.name != '2'
              actions << 'choose'
            end
            actions
          end

          def choosing?(entity)
            !lfc_train_choices(entity).empty?
          end

          def lfc_train_choices(entity)
            @game.route_trains(entity)
          end

          def choice_name
            'Choose train to be Lincoln Funeral Car'
          end

          def choices
            choices = {}
            lfc_train_choices(current_entity).each_with_index do |train, index|
              choices[index.to_s] =
                case train.name
                when '2', '3', '4', '5', '6'
                  "#{train.name}-train"
                else
                  "#{train.name} train"
                end
            end
            choices
          end

          def scrappable_trains(entity)
            entity.trains
          end

          def process_choose(action)
            entity = action.entity
            @game.lfc_train = lfc_train_choices(entity)[action.choice.to_i]
            train_name =
              case @game.lfc_train.name
              when '2', '3', '4', '5', '6'
                '-train'
              else
                ' train'
              end
            @log << "#{@game.lfc_train.name}#{train_name} becomes the Lincoln Funeral Car"
            @original_lfc_name = @game.lfc_train.name
            @game.lfc_train.name += ' (LFC)'
          end

          def scrap_info(_train)
            ''
          end

          def process_run_routes(action)
            super

            return unless @game.lfc_train

            @game.lfc_train.name = @original_lfc_name
            @game.lfc_train = nil
            @log << "#{@game.lincoln_funeral_car.name} (#{action.entity.name}) closes"
            @game.lincoln_funeral_car.close!
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def help
            return super if current_entity != @game.ic || !@game.ic_in_receivership?

            "#{current_entity.name} is in receivership (it has no president). Most of its "\
              'actions are automated, but it must have a player manually run its trains. '\
              "Please enter the best route you see for #{current_entity.name}."
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
