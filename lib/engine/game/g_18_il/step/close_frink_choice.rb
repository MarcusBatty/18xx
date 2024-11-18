module Engine
    module Game
      module G18IL
        module Step
          class CloseFrinkChoice < Engine::Step::Base
  
            def setup
              @frink_walker_co_pass = false
              super
            end
  
            def actions(entity)
              return [] unless entity == current_entity && !@frink_walker_co_pass
  
              ['choose']
            end
  
            def active_entities
                return [] unless @game.frink_walker_co.owner == @round.current_operator
                return [] unless @game.hex_by_id('C2').tile.name == 'G1'
                [@game.frink_walker_co.owner]
            end
  
            def description
              "Use Frink, Walker, & Co. ability"
            end
  
            def active?
              !active_entities.empty?
            end
  
            def choice_available?(entity)
              entity == @game.frink_walker_co.owner
            end
  
            def choices
              choices = []
              choices << ["Mine"]
              choices << ["Pass"]
              choices
            end
  
            def choice_name
              "Gain a mine marker, closing Frink, Walker, & Co. (or pass)"
            end
  
            def process_choose(action)
              corp = action.entity
              company = @game.companies.find { |c| c.name == "Frink, Walker, & Co." }
              case action.choice
                when "Mine"
                  @log << "#{corp.name} gains a mine marker"
                  company.close!
                  @log << "#{company.name} (#{corp.name}) closes"
                  @game.assign_mine_icon(corp)
                when "Pass"
                  @log << "#{corp.name} passes gaining marker"
                  @frink_walker_co_pass = true
                  pass!
              end
            end
  
          end
        end
      end
    end
  end