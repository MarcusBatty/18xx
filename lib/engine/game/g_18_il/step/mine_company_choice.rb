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
              return [] unless entity == current_entity && (!@mine_pass)
  
              ['choose']
            end
  
            def active_entities
              if @game.chicago_virden_coal_company.owner == @round.current_operator
                @active_company = @game.chicago_virden_coal_company
                return [@game.chicago_virden_coal_company.owner] 
              end

               if @game.frink_walker_co.owner == @round.current_operator
                @active_company = @game.frink_walker_co
                return [@game.frink_walker_co.owner] 
               end
                []
            end
  
            def description
              "Use Frink, Walker, & Co. ability"
            end
  
            def active?
              !active_entities.empty?
            end
  
            def choice_available?(entity)
              entity == @active_company.owner
            end
  
            def choices
              choices = []
              choices << ["Mine"]
              choices << ["Pass"]
              choices
            end
  
            def choice_name
              "Gain a mine marker (or pass)"
            end

            def help
              [
              "In this step, #{@active_company.name} can be closed without using its main ability."
            ]
            end
  
            def process_choose(action)
              corp = action.entity
              company = @active_company
              case action.choice
                when "Mine"
                  @log << "#{corp.name} gains a mine marker"
                  company.close!
                  @log << "#{company.name} (#{corp.name}) closes"
                  @game.assign_mine_icon(corp)
                when "Pass"
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