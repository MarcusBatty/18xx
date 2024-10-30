# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18IL
      module Step
        class Convert < Engine::Step::Base
          def actions(entity)
            if entity.corporation? then
              #@log << "actions in convert.rb"
              #@log << "#{entity.total_shares}"
            end
            return %w[convert pass] if can_convert?(entity)
            []
          end

          def description
            'Convert'
          end

          def pass_description
            'Skip'
          end 

          def can_convert?(entity)
            #@log << "can_convert in convert.rb"
            #@log << "#{entity.corporation?}"
            (entity.corporation? && entity.total_shares == 5) || (entity.corporation? && entity.total_shares == 2)
          end


          def process_convert(action)
            #@log << "process_convert"
            #@log << "#{action.entity.corporation?}"
            #@log << "#{action.entity.total_shares}"
            if action.entity.corporation? then
               @game.convert(action.entity)
               pass!
            else
              pass!
            end
          end

        end
      end
    end
  end
end
