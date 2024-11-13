require_relative '../../../step/track'

module Engine
  module Game
    module G18IL
      module Step
        class Track < Engine::Step::Track

          FUTURE_PATH_TILES = [
            'C11', 'C12', 'C13', 'C14', 'C15', 'K11', 'K12', 'K13', 'IC1', 'IC2', 'IC3', 'IC4', 'IC5', 'IC6', 'IC7', 'IC8', 
            'IC9', 'IC10', 'IC11', 'IC12', 
          ]

          IC_LINE_HEXES = [
            [7, 6], 
            [6, 7],
            [6, 9],
            [6, 11],
            [6, 13],
            [5, 14],
            [5, 16],
            [5, 18],
            [4, 19],
            [4, 21]
          ].freeze

          def setup
            super
            @ic_line_improvement = nil
            #@tile_lays = 0
          end

          def upgradeable_tiles(entity, ui_hex)
            real_tiles = super
            tiles = real_tiles
            if !IC_LINE_HEXES.include?([ui_hex.x, ui_hex.y]) then
              tiles.delete_if {|t| (FUTURE_PATH_TILES.include?(t.name))}
            end
            tiles
          end

          def process_lay_tile(action)
            lay_tile_action(action)
            return if action.entity.company?
            improvement = @game.ic_line_improvement(action)
            #@log << "#{improvement}"
            @ic_line_improvement = improvement if improvement

            hex = action.hex
            tile = action.hex.tile
            if @game.ic_line_hex?(hex)
              case tile.color
                when 'yellow' #one must match
                if @game.ic_line_connections(hex) < 1
                  raise GameError, "Tile must overlay at least one dashed path"
                end
                when'green' #both must match
                if @game.ic_line_connections(hex) < 2
                  raise GameError, "Tile must complete IC Line"
                end
              end
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
            return nil if @game.class::STL_HEXES.include?(hex.id) && !@game.stl_permit?(current_entity) # highlight the STL hexes only when corp has permit token
            return nil if hex.id != @game.class::SPRINGFIELD_HEX && @game.hex_by_id(entity.coordinates).tile.color == :white && entity == @game.nc #forces NC to lay in its home hex first if it's not yellow
            super
          end
          
        end
      end
    end
  end
end