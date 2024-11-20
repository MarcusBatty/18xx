# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G18IL
      class Corporation < Engine::Corporation

        def floated?
          @floated
        end

        def float!
          @floated = true
        end
        
      end
    end
  end
end