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
        GAME_RULES_URL = 'https://www.dropbox.com/scl/fi/lghbbz030fb1ekrqhuvnt/18IL_Rulebook_v0.7.11.pdf?rlkey=55t8zd4t40uap5a4monbg3mqe&dl=0'
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
          {
            sym: :fixed_setup,
            short_name: 'Fixed Setup',
            desc: 'Private companies are assigned to corporations deterministically (see Variants section in the '\
                  'back of the rulebook).',
          },
          {
            sym: :two_player_share_limit,
            short_name: '(2p only) 70% Corporation Holding Limit',
            desc: "When enabled, a player can gain up to 70% of a corporation's shares through normal means in a 2p game. "\
                  'Players can still gain more than 70% through corporation reserve share purchase.',
          },
        ].freeze
      end
    end
  end
end
