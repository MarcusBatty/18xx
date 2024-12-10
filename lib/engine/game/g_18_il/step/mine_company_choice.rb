# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Step
        class MineCompanyChoice < Engine::Step::Base
          def setup
            @mine_pass = false
            @active_company = nil
            super
          end

          def actions(entity)
            return [] if @game.last_set_triggered
            return [] unless entity == current_entity
            return [] if @mine_pass
            return [] if entity.assignments.include?(@game.class::MINE_ICON)

            ['choose']
          end

          def active_entities
            case @round.current_operator
            when @game.chicago_virden_coal_company&.owner
              @active_company = @game.chicago_virden_coal_company

            when @game.frink_walker_co&.owner
              @active_company = @game.frink_walker_co

            when @game.us_mail_line&.owner
              @active_company = @game.us_mail_line
            else
              return []
            end

            [@active_company&.owner].compact
          end

          def log_skip(entity); end

          def description
            "Use #{@active_company&.name} ability"
          end

          # def active?
          #   !active_entities.empty?
          # end

          def choice_available?(entity)
            entity == @active_company&.owner
          end

          def choices
            choices = []
            choices << ['Mine']
            choices << ['Pass']
            choices
          end

          def choice_name
            'Gain a mine marker (or pass)'
          end

          def help
            [
            "In this step, #{@active_company&.name} can be closed without using its main ability.",
          ]
          end

          def process_choose(action)
            corp = action.entity
            case action.choice
            when 'Mine'
              @log << "#{corp.name} gains a mine marker"
              @active_company.close!
              @log << "#{@active_company.name} (#{corp.name}) closes"
              @game.assign_mine_icon(corp)
            when 'Pass'
              @log << "#{corp.name} passes gaining marker"
              @mine_pass = true
              pass!
            end
          end
        end
      end
    end
  end
end
