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
        GAME_RULES_URL = 'https://www.dropbox.com/scl/fi/jxewu7qyu7fkka57sw0ni/18IL_Rulebook_v0.7.4.pdf?rlkey=jiadbkthxrx5ul1cqrq0ovawx&dl=0'
        #GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18SJ'
        #TODO: make wiki entry once in alpha
        PLAYER_RANGE = [2, 5].freeze #TODO: change to 3, 5

        OPTIONAL_RULES = [
          {
            sym: :intro_game,
            short_name: 'Introductory Game',
            desc: 'The private companies are removed from the game. Each corporation randomly receives a port or mine marker. One random port tile is placed on the map; the other is removed from the game.'
          },
          # {
          #   sym: :intro_game,
          #   short_name: 'Trading Variant',
          #   desc: 'Corporations are allowed to trade assets with other corporations.'
          # },
        ].freeze

      end
    end
  end
end
