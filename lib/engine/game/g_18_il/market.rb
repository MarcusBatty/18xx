# frozen_string_literal: true

module Engine
    module Game
      module G18IL
        module Market
            MARKET_SHARE_LIMIT = 100
            MARKET = [
              %w[0c
                20
                22
                24
                26g
                28
                30
                32
                34
                36
                38
                40p
                50
                60p
                67
                74
                80p
                85
                90
                95
                100p
                104
                108
                112
                116
                120p
                122
                124
                126
                129
                132
                135
                139
                143
                147
                152
                157
                163
                169
                176
                183
                191
                200
                208
                218
                229
                241
                254
                268
                283
                300
                316
                334
                354
                376
                400],
              ].freeze
    
            # TODO: Remove empty grey legend
             STOCKMARKET_COLORS = {
                par: :yellow,
                close: :black,
              }.freeze
    
              MARKET_TEXT = {
                par: 'Par values',
                close: 'Corporation closes',
              }.freeze

            def price_movement_chart
            [
                ['Action', 'Share Price Change'],
                ['Dividend = 0', '1 ←'],
                ['Dividend < 1/2 stock price', '1 ⤪'],
                ['Dividend ≥ 1/2 stock price but < stock price', '1 ⤨'],
                ['Dividend ≥ stock price', '1 →'],
                ['Dividend ≥ 2X stock price', '2 →'],
                ['Dividend ≥ 3X stock price', '3 →'],
                ['Voluntary Issue','Full Amount, then 1 ←'],
                ['Emergency Issue','Half Amount, then ⤪ for each'],
                ['Corporation is sold out at end of an SR', '1 ⤨ (5 share) or 1 → (10 share)'],
                ['Corporation has any shares in the Market at end of an SR', '⤪ for each'],
            ]
            end
        end
      end
    end
end