# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18IL
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_SUBTITLE = 'The Formation of the Illinois Central Railroad'
        GAME_DESIGNER = 'Scott Ninmer'
        GAME_PUBLISHER = :self_published
        GAME_LOCATION = 'Illinois, USA'
        GAME_RULES_URL = 'https://www.dropbox.com/scl/fi/yokl67tz84id9ps03quqk/18IL_Rulebook_v0.7.6.pdf?rlkey=qoeqx0optqkghry03r0o42blx&dl=0'
        GAME_INFO_URL = ''
        # GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18IL'
        # TODO: make wiki entry once in alpha
        PLAYER_RANGE = [2, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :intro_game,
            short_name: 'Introductory Game',
            desc: 'The private companies are removed from the game. Each corporation randomly receives a port or mine marker. '\
                  'One random port tile is placed on the map; the other is removed from the game.',
          },
        ].freeze
      end
    end
  end
end
