# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G18IL
      module Round
        class Operating < Engine::Round::Operating

          def setup
          ic = @game.ic
          ic.owner = @game.priority_deal_player if @game.ic_in_receivership?
          super
          end

        end
      end
    end
  end
end