# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Step
        class DiverseCargoChoice < Engine::Step::Base
          def setup
            @diverse_cargo_pass = false
            super
          end

          def actions(entity)
            return [] if @game.last_set_triggered
            return [] unless entity == current_entity
            return [] unless @game.diverse_cargo&.owner == @round.current_operator
            return [] if @diverse_cargo_pass

            ['choose']
          end

          def active_entities
            return [] unless @game.diverse_cargo&.owner == @round.current_operator

            [@game.diverse_cargo&.owner].compact
          end

          def description
            "Use #{@game.diverse_cargo&.name} ability"
          end

          def choice_available?(entity)
            entity == @game.diverse_cargo&.owner
          end

          def choices
            choices = []
            choices << ['Mine'] unless current_entity.assignments.include?(@game.class::MINE_ICON)
            choices << ['Port'] unless current_entity.assignments.include?(@game.class::PORT_ICON)
            choices << ['Pass'] unless choices.empty?
            choices
          end

          def choice_name
            'Gain a mine or port marker (or pass)'
          end

          def process_choose(action)
            corp = action.entity
            company = @game.diverse_cargo
            case action.choice
            when 'Mine', 'Port'
              marker = action.choice.downcase.to_sym
              @log << "#{corp.name} gains a #{marker} marker"
              company.close!
              @log << "#{company.name} (#{corp.name}) closes"
              @game.send("assign_#{marker}_icon", corp)
            when 'Pass'
              @log << "#{corp.name} passes gaining marker"
              @diverse_cargo_pass = true
              pass!
            end
          end
        end
      end
    end
  end
end
