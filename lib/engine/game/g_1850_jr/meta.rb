# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1850JR
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_DESIGNER = 'MarcusBatty'
        GAME_LOCATION = 'Tunisia'
        #GAME_RULES_URL = 'https://boardgamegeek.com/filepage/268508/rules-english'
        #GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1850jr'

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
