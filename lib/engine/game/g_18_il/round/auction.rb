# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G18IL
      module Round
        class Auction < Engine::Round::Auction

          def name
            'Auction Round'
          end

          def self.short_name
            'CR'
          end

          def auction?
            true
          end

          def select_entities
            @game.players
          end

        end
      end
    end
  end
end