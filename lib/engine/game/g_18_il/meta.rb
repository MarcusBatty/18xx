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
=begin
        OPTIONAL_RULES = [
          {
            sym: :p2p_purchases,
            short_name: 'Player to player purchases',
            desc: 'Allow players to buy stock/concessions directly from other players',
          },
        ].freeze
=end
      end
    end
  end
end
