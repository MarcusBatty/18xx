require_relative '../../../step/track'

module Engine
  module Game
    module G18IL
      module Step
        class Track < Engine::Step::Track

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

          ACTIONS = %w[lay_tile pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.company? || !can_lay_tile?(entity)
            return [] if entity == @game.ic && @game.ic.presidents_share.owner == @game.ic
    
            ACTIONS
          end

          def setup
            super
            @ic_line_improvement = nil
          end

          def process_lay_tile(action)
            lay_tile_action(action)
            return if action.entity.company?
            improvement = @game.ic_line_improvement(action)
            @ic_line_improvement = improvement if improvement
            hex = action.hex
            tile = action.hex.tile
            city = tile.cities.first
            ic = @game.ic

            if @game.ic_line_hex?(hex)
              case tile.color
                when 'yellow'
                  #checks for one IC Line connection when laying yellow
                  if @game.ic_line_connections(hex) < 1
                    raise GameError, "Tile must overlay at least one dashed path"
                  end
                when 'green'
                  #checks for both IC Line connections when laying green
                  if @game.ic_line_connections(hex) < 2
                    raise GameError, "Tile must complete IC Line"
                  end
                  #adds reservation to IC Line hex when new tile is green city
                  tile.add_reservation!(ic, city) if @game.class::IC_LINE_HEXES.include?(hex.id)
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
            return nil if @game.class::STL_HEXES.include?(hex.id) && !@game.stl_permit?(current_entity) # highlight the STL hexes only when corp has permit token
            return nil if hex.id != @game.class::SPRINGFIELD_HEX && @game.hex_by_id(entity.coordinates).tile.color == :white && entity == @game.nc #forces NC to lay in its home hex first if it's not yellow
            super
          end
          
        end
      end
    end
  end
end