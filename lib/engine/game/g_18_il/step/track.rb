# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18IL
      module Step
        class Track < Engine::Step::Track

          def available_hex(entity, hex, normal: false)
            return nil if @game.class::STL_HEXES.include?(hex.id) && !@game.stl_permit?(current_entity) # highlight the STL hexes only when corp has permit token
            super
          end
          
        end
      end
    end
  end
end