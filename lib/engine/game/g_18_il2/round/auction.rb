# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G18IL2
      module Round
        class Auction < Engine::Round::Auction
          def name
            'Concession Round'
          end

          def self.short_name
            'CR'
          end
        end
      end
    end
  end
end
