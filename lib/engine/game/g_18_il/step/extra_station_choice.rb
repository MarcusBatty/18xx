# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Step
        class ExtraStationChoice < Engine::Step::Base
          def setup
            @extra_station_pass = false
            super
          end

          def actions(entity)
            return [] if entity != current_entity || @extra_station_pass

            ['choose']
          end

          def active_entities
            return [] unless @game.extra_station&.owner == @round.current_operator

            [@game.extra_station&.owner].compact
          end

          def description
            "Use #{@game.extra_station&.name} ability"
          end

          def choice_available?(entity)
            entity == @game.extra_station&.owner
          end

          def choices
            choices = []
            choices << ['Extra Station']
            choices << ['Pass']
            choices
          end

          def choice_name
            'Gain an extra station (or pass)'
          end

          def process_choose(action)
            corp = action.entity
            company = @game.extra_station
            case action.choice
            when 'Extra Station'
              @log << "#{corp.name} gains an extra station"
              @log << "#{company.name} (#{corp.name}) closes"
              company.close!

              corp.tokens << Engine::Token.new(corp, price: 0)

            when 'Pass'
              @log << "#{corp.name} passes gaining extra station"
              @extra_station_pass = true
              pass!
            end
          end
        end
      end
    end
  end
end
