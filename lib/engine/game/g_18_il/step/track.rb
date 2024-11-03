# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18IL
      module Step
        class Track < Engine::Step::Track

          def setup
            super

            @ic_line_improvement = nil
            #@tile_lays = 0
          end

          def process_lay_tile(action)
            super
            return if action.entity.company?

            improvement = @game.ic_line_improvement(action)
            #@log << "#{improvement}"
            @ic_line_improvement = improvement if improvement

=begin
            return if (@tile_lays += 1) == 1
            unless @main_line_improvement
              raise GameError, 'Second tile lay or upgrade only allowed if first or second improves main lines!'
            end
            @log << "#{action.entity.name} did get the 2nd tile lay/upgrade due to a main line upgrade"
=end
          end

          def available_hex(entity, hex, normal: false)
            return nil if @game.class::STL_HEXES.include?(hex.id) && !@game.stl_permit?(current_entity) # highlight the STL hexes only when corp has permit token
            super
          end
          
        end
      end
    end
  end
end