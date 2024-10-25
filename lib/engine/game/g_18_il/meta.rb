# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18IL
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_DESIGNER = 'Scott Ninmer'
        GAME_LOCATION = 'Illinois'
        #GAME_RULES_URL = 'https://boardgamegeek.com/filepage/268508/rules-english'
        #GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1850jr'

        PLAYER_RANGE = [2, 5].freeze
=begin
        OPTIONAL_RULES = [
          {
            sym: :multiple_brown_from_ipo,
            short_name: 'Buy Multiple Brown Shares From IPO',
            desc: 'Multiple brown shares may be bought from IPO as well as from pool',
          },
          {
            sym: :optional_6_train,
            short_name: 'Optional extra 6-Train',
            desc: 'Adds a 3rd 6-train',
          },
        ].freeze
=end
      end
    end
  end
end
