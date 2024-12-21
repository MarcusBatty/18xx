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

            hex = action.hex
            tile = action.hex.tile
            city = tile.cities.first

            ic_line_tile(action, hex, tile, city) if @game.ic_line_hex?(action.hex)

            # Closes GTL if Chicago is upgraded to brown
            if !@game.optional_rules&.include?(:intro_game) && tile.name == 'CHI3' && !@game.goodrich_transit_line.closed?
              company = @game.goodrich_transit_line
              @log << "#{company.name} (#{company.owner.name}) closes"
              company.close!
            end

            pass! unless can_lay_tile?(action.entity)
          end

          def ic_line_tile(action, hex, tile, city)
            @game.ic_line_improvement(action)

            case tile.color
            when :yellow
              # Checks for one IC Line connection when laying yellow
              raise GameError, 'Tile must overlay at least one dashed path' if @game.ic_line_connections(hex) < 1

              @log << "#{action.entity.name} receives a #{@game.format_currency(20)} subsidy for IC Line improvement"
              action.entity.cash += 20

            when :green
              # Checks for both IC Line connections when laying green
              raise GameError, 'Tile must complete IC Line' if @game.ic_line_connections(hex) < 2

              # Disallows Engineering Master corp from upgrading two incomplete IC Line hexes
              if @round.num_laid_track > 1 && @round.laid_hexes.first.tile.color == :green &&
                @game.class::IC_LINE_HEXES.include?(@round.laid_hexes.first)
                raise GameError, 'Cannot upgrade two incomplete IC Line hexes in one turn'
              end

              # Adds reservation to IC Line hex when new tile is green city
              tile.add_reservation!(@game.ic, city) if @game.class::IC_LINE_HEXES.include?(hex.id) &&
                                                      !@game.ic.tokens.find { |t| t.hex == hex }

            when :brown
              # Removes reservation from IC Line hex when new tile is brown city
              tile.remove_reservation!(@game.ic) if @game.class::IC_LINE_HEXES.include?(hex.id)
            end
          end

          def can_lay_tile?(entity)
            return true if tile_lay_abilities_should_block?(entity)
            return true if can_buy_tile_laying_company?(entity, time: type)

            action = get_tile_lay(entity)
            return false unless action

            !entity.tokens.empty? && (buying_power(entity) >= action[:cost]) && (action[:lay] || action[:upgrade])
          end

          def available_hex(entity, hex, normal: false)
            # Highlight the STL hexes only when corp has permit token
            return nil if @game.class::STL_HEXES.include?(hex.id) && !@game.stl_permit?(current_entity)

            # Forces NC to lay in its home hex first if it is not yellow
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
