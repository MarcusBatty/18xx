# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18IL
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            super
          end

           def available_hex(entity, hex, normal: false)
             return nil if @game.class::STL_TOKEN_HEXES.include?(hex.id) # never highlight the STL hexes
             super
           end
        end
      end
    end
  end
end