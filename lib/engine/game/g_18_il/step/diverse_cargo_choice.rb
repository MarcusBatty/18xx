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
            return [] unless entity == current_entity && !@diverse_cargo_pass

            ['choose']
          end

          def active_entities
          return [] unless @game.diverse_cargo.owner == @round.current_operator
            [@game.diverse_cargo.owner]
          end

          def description
            "Use Diverse Cargo ability"
          end

          def active?
            !active_entities.empty?
          end

          def choice_available?(entity)
            entity == @game.diverse_cargo.owner
          end

          def choices
            choices = []
            choices << ["Mine"]
            choices << ["Port"]
            choices << ["Pass"]
            choices
          end

          def choice_name
            "Gain a mine or port marker (or pass)"
          end

          def process_choose(action)
            corp = action.entity
            company = @game.companies.find { |c| c.name == "Diverse Cargo" }
            case action.choice
              when "Mine"
                @log << "#{corp.name} gains a mine marker"
                company.close!
                @log << "#{company.name} (#{corp.name}) closes"
                #@game.diverse_cargo_corp = nil
                @game.assign_mine_icon(corp)
              when "Port"
                @log << "#{corp.name} gains a port marker"
                company.close!
                @log << "#{company.name} (#{corp.name}) closes"
                #@game.diverse_cargo_corp = nil
                @game.assign_port_icon(corp)
              when "Pass"
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