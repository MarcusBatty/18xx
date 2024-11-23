# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G18IL
      module Round
        class ICFormation < Engine::Round::Merger

          def self.round_name
            'IC Formation Round'
          end

          def self.short_name
            'IC'
          end

          def select_entities
            [@game.ic_corporation]
          end

           def force_next_entity!
             clear_cache!
           end

        end
      end
    end
  end
end