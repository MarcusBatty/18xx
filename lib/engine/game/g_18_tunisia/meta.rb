# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18TUN
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_DESIGNER = 'Marcus Batty'
        GAME_LOCATION = 'Tunisia'
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/268508/rules-english'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1850jr'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
