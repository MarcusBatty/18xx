# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Step
        class LincolnChoice < Engine::Step::Base
          def setup
            super
            @lincoln_pass = nil
          end

          def actions(entity)
            return [] if @game.last_set_triggered
            return [] unless entity == current_entity
            return [] unless @game.lincoln_funeral_car&.owner == @round.current_operator
            return [] if @lincoln_pass
            return [] if @game.lincoln_triggered

            ['choose']
          end

          def active_entities
            return [] unless @game.lincoln_funeral_car&.owner == @round.current_operator

            [@game.lincoln_funeral_car&.owner].compact
          end

          def description
            "Use #{@game.lincoln_funeral_car&.name} ability"
          end

          def active?
            !active_entities.empty?
          end

          def choice_available?(entity)
            entity == @game.diverse_cargo&.owner
          end

          def choices
            choices = []
            choices << ['Use']
            choices << ['Pass']
            choices
          end

          def choice_name
            "Use Lincoln Funeral Car ability during this 'run trains' step (or pass)"
          end

          def process_choose(action)
            corp = action.entity
            case action.choice
            when 'Use'
              @log << "#{corp.name} chooses to use Lincoln Funeral Car ability"
              @game.lincoln_triggered = true
            when 'Pass'
              @log << "#{corp.name} passes using Lincoln Funeral Car ability"
              @lincoln_pass = true
              pass!
            end
          end
        end
      end
    end
  end
end
