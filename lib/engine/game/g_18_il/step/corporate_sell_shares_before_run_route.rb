# frozen_string_literal: true

require_relative 'corporate_sell_shares'

module Engine
  module Game
    module G18IL
      module Step
        class CorporateSellSharesBeforeRunRoute < G18IL::Step::CorporateSellShares
          def actions(entity)
            return [] unless entity == @game.rush_delivery.owner

            super
          end
        end
      end
    end
  end
end
