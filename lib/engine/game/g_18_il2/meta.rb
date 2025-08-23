# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18IL2
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        PROTOTYPE = true

        GAME_SUBTITLE = 'The Formation of the Illinois Central Railroad'
        GAME_DESIGNER = 'Scott Ninmer'
        GAME_PUBLISHER = :self_published
        GAME_LOCATION = 'Illinois, USA'
        GAME_RULES_URL = 'https://www.dropbox.com/scl/fi/i89i7qvld12isrzb0ew4l/18IL_Rulebook_v0.8.0.pdf?rlkey=wxo269h3h9vxh8z2fyihngxa0&st=utu6pi1z&dl=0'
        GAME_INFO_URL = ''
        # GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18IL'
        # TODO: make wiki entry once in alpha
        PLAYER_RANGE = [2, 6].freeze

        OPTIONAL_RULES = [
          {
            sym: :intro_game,
            short_name: 'Introductory Game',
            desc: 'Private companies are not used. The #G1 tile begins the game on the Galena (C2) hex.',
          },
          {
            sym: :fixed_setup,
            short_name: 'Fixed Setup',
            desc: 'Private companies are assigned to corporations deterministically.',
          },
          {
            sym: :two_player_share_limit,
            short_name: '(2p only) 70% Corporation Holding Limit',
            desc: "A player can gain up to 70% of a corporation's shares.",
          },
          {
            sym: :big_lots_variant,
            short_name: '(2p only) Big Lots Variant',
            desc: 'Two lots consisting of one 10-share, two 5-share, and one 2-share concessions are formed '\
                  'for the first concession round.',
          },
        ].freeze
      end
    end
  end
end
