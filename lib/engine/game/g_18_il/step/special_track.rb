# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18IL
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            super
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
          end
        end
      end
    end
  end
end