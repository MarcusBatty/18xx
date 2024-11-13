# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18IL
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_SUBTITLE = 'The Formation of the Illinois Central Railroad'
        GAME_DESIGNER = 'Scott Ninmer'
        GAME_LOCATION = 'Illinois, USA'
        #GAME_RULES_URL = 'https://boardgamegeek.com/filepage/268508/rules-english'
        #GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1850jr'

        PLAYER_RANGE = [2, 5].freeze

        OPTIONAL_RULES = [
          {
            sym: :intro_game,
            short_name: 'Introductory game',
            desc: 'No private companies or asset trading. Each corporation randomly receives a port or mine marker. One random port tile is placed on the map; the other is removed from the game.'
          },
        ].freeze

=begin
        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)
          return
          #return unless (optional_rules & %i[first_ed second_ed_co]).length == 2
          #{ error: 'Cannot guarantee 2nd Edition companies if using 1st Edition' }
        end
=end

      end
    end
  end
end
