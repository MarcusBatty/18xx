# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18IL
      module Step
        class Track < Engine::Step::Track
          ACTIONS = %w[lay_tile pass].freeze

          def actions(entity)
            return [] if @game.last_set_triggered
            return [] unless entity == current_entity
            return [] if entity.company? || !can_lay_tile?(entity)
            return [] if entity == @game.ic && @game.ic_in_receivership?

            ACTIONS
          end

          def process_lay_tile(action)
            lay_tile_action(action)
            return if action.entity.company?

            hex = action.hex
            tile = action.hex.tile
            city = tile.cities.first

            if @game.ic_line_hex?(hex)
              old_count = @game.ic_line_completed_hexes.size
              @game.ic_line_improvement(action)
              new_count = @game.ic_line_completed_hexes.size
              case tile.color
              when 'yellow'
                # checks for one IC Line connection when laying yellow
                raise GameError, 'Tile must overlay at least one dashed path' if @game.ic_line_connections(hex) < 1
              when 'green'
                # checks for both IC Line connections when laying green
                raise GameError, 'Tile must complete IC Line' if @game.ic_line_connections(hex) < 2
                # disallows Engineering Master corp from upgrading two incomplete IC Line hexes
                if old_count != new_count && @round.upgraded_track &&
                  @round.num_laid_track > 1 && @game.ic_line_connections(hex) == 2
                  raise GameError, 'Cannot upgrade two incomplete IC Line hexes in one turn'
                end

                # adds reservation to IC Line hex when new tile is green city
                tile.add_reservation!(@game.ic, city) if @game.class::IC_LINE_HEXES.include?(hex.id)
              end
            end

            if tile.name == 'CHI3' && !@game.goodrich_transit_line.closed?
              company = @game.goodrich_transit_line
              @log << "#{company.name} (#{company.owner.name}) closes"
              company.close!
            end

            pass! unless can_lay_tile?(action.entity)
          end

          def can_lay_tile?(entity)
            return true if tile_lay_abilities_should_block?(entity)
            return true if can_buy_tile_laying_company?(entity, time: type)

            action = get_tile_lay(entity)
            return false unless action

            !entity.tokens.empty? && (buying_power(entity) >= action[:cost]) && (action[:lay] || action[:upgrade])
          end

          def available_hex(entity, hex, normal: false)
            # highlight the STL hexes only when corp has permit token
            return nil if @game.class::STL_HEXES.include?(hex.id) && !@game.stl_permit?(current_entity)
            # forces NC to lay in its home hex first if it's not yellow
            if hex.id != @game.class::SPRINGFIELD_HEX &&
              @game.hex_by_id(entity.coordinates).tile.color == :white && entity == @game.nc
              return nil
            end

            super
          end
        end
      end
    end
  end
end
