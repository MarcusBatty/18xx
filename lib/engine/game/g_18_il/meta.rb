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
        GAME_RULES_URL = 'https://www.dropbox.com/scl/fi/icbibjic7tg0khd20xal5/18IL_Rulebook_v0.7.3.pdf?rlkey=bd3ockc6xe8rsrvkwg9lt5x18&dl=0'
        #GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18SJ'
        #TODO: make wiki entry once in alpha
        PLAYER_RANGE = [2, 5].freeze #TODO: change to 3, 5

        OPTIONAL_RULES = [
          {
            sym: :intro_game,
            short_name: 'Introductory game',
            desc: 'No private companies or asset trading. Each corporation randomly receives a port or mine marker. One random port tile is placed on the map; the other is removed from the game.'
          },
        ].freeze

      end
    end
  end
end
