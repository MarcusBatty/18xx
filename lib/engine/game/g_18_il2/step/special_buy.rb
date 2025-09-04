# frozen_string_literal: true

require_relative '../../../step/special_buy'

module Engine
  module Game
    module G18IL2
      module Step
        class SpecialBuy < Engine::Step::SpecialBuy
          attr_reader :port_marker

          def buyable_items(entity)
            return [] if entity != current_entity
            return [@port_marker] if @game.loading || !@game.has_port_marker?(entity)

            []
          end

          def short_description
            'Port Marker'
          end

          def process_special_buy(action)
            corp = action.entity
            raise GameError, "Cannot buy unknown item: #{item.description}" if action.item != @port_marker
            @log << "#{corp.name} gains a port marker"
            corp.cash -= 40
            @game.assign_port_icon(corp)
          end

          def setup
            super
            @port_marker ||= Item.new(description: 'Port Marker', cost: 40)
          end
        end
      end
    end
  end
end