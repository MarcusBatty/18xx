# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G18IL
      module Step
        class BuyCompany < Engine::Step::BuyCompany

      ACTIONS = %w[buy_company pass].freeze
      ACTIONS_NO_PASS = %w[buy_company].freeze
      PASS = %w[pass].freeze

      def actions(entity)
        return [] if entity == @game.ic && @game.ic.presidents_share.owner == @game.ic && @game.ic.trains.any?
        return blocks? ? ACTIONS : ACTIONS_NO_PASS if can_buy_company?(entity)

        return PASS if blocks? && entity.corporation? && @game.abilities(entity, passive_ok: false)

        []
      end

          def pass!
            super
            @game.event_ic_formation! if @game.ic_formation_pending?
          end
          
        end
      end
    end
  end
end