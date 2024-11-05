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
            print "step.upgradeable_tiles"
            real_tiles = super
            tiles = real_tiles
            if !IC_LINE_HEXES.include?([ui_hex.x, ui_hex.y]) then
              print "removing future path tiles from tile selector"
              tiles.delete_if {|t| (FUTURE_PATH_TILES.include?(t.name))}
            end
            tiles
          end

          def process_lay_tile(action)
            super
            return if action.entity.company?
            improvement = @game.ic_line_improvement(action)
            #@log << "#{improvement}"
            @ic_line_improvement = improvement if improvement

=begin
            return if (@tile_lays += 1) == 1
            unless @main_line_improvement
              raise GameError, 'Second tile lay or upgrade only allowed if first or second improves main lines!'
            end
            @log << "#{action.entity.name} did get the 2nd tile lay/upgrade due to a main line upgrade"
=end
          end

          def available_hex(entity, hex, normal: false)
            return nil if @game.class::STL_HEXES.include?(hex.id) && !@game.stl_permit?(current_entity) # highlight the STL hexes only when corp has permit token
            return nil if hex.id != 'E12' && @game.hex_by_id(entity.coordinates).tile.color == :white && entity == @game.nc #forces NC to lay in its home hex first if it's not yellow
            super
          end
          
        end
      end
    end
  end
end