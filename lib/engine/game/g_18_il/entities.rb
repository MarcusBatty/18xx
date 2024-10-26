# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Entities
        COMPANIES = [
          {
            name: 'Extra Station',
            sym: 'ES',
            value: 5,
            revenue: 0,
            desc: 'Place an additional station marker on the charter for free. Once this ability is used, the private company closes. ',
            color: nil,
            #TODO:  fix
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
                when: 'token',
                closed_when_used_up: true,
                extra_slot: true,
                special: true,
              },
            ],
          },

          {
            name: 'Illinois Steel Bridge Company',
            value: 10,
            revenue: 0,
            desc: '$20 discount for hexes with rivers and/or lakes.',
            sym: 'ISBC',
            abilities: [
                {
                type: 'tile_discount',
                terrain: 'water',
                owner_type: 'corporation',
                discount: 20,
                },
              ],
            },

            {
              name: 'Frink, Walker, & Co.',
              value: 10,
              revenue: 0,
              desc: 'During the tile-laying step of the corporation operating turn, place the G tile in Galena for free, ignoring terrain costs. It '\
              'does not have to be connected to a station marker and does not count as a tile lay. Place a mine marker on the corporation charter. Once'\
              ' this ability is used, the private company closes.',
              sym: 'FW&C',

              #TODO:  place mine marker
              abilities: [
                {
                type: 'tile_lay',
                hexes: ['C2'],
                tiles: ['IL2'],
                when: 'track',
                discount: 60,
                owner_type: 'corporation',
                count: 1,
                consume_tile_lay: false,
                closed_when_used_up: true,
                special: true,
                },
              ],
            },

            {
              name: 'Train Subsidy',
              value: 5,
              revenue: 0,
              desc: 'When buying trains from the bank, receive a 25% discount on non-permanent trains and a 20% discount on permanent trains.',
              sym: 'TS',

              #TODO:  fix
              abilities: [
                  {
                  type: 'train_discount',
                  owner_type: 'corporation',
                  discount: 30,
                  trains: %w['2'],
                  count: 1,
                  when: 'buying_train',
                  closed_when_used_up: true,
                  special: true,
                  },
              ],
            },

            {
              name: 'Share Premium',
              value: 10,
              revenue: 0,
              desc: 'When issuing a share during the Issue a Share step, receive double the current share price from the bank to the corporation treasury.'\
                    ' Once this ability is used, the private companY closes',
              sym: 'SP',
            },
        ].freeze


        CORPORATIONS = [
          {
            float_percent: 100,
            sym: 'PSBV',
            name: 'Peoria and Bureau Valley Railroad',
            logo: '18_va/BO',
            simple_logo: '18_va/BO.alt',
            shares: [100],
            tokens: [0],
            coordinates: 'E8',
            color: '#025aaa',
            type: 'two_share',
            max_ownership_percent: 100,
            always_market_price: true,
          },
          {
            float_percent: 40,
            sym: 'RI',
            name: 'Rock Island',
            logo: '1849/RCS',
            simple_logo: '1849/RCS.alt',
            shares: [40,20,20,20],
            tokens: [0,0],
            coordinates: 'C6',
            color: '#f48221',
            type: 'five_share',
            always_market_price: true,
          },
          {
            float_percent: 40,
            sym: 'G&CU',
            name: 'Galena and Chicago Union Railroad',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            shares: [40,20,20,20],
            tokens: [0,0],
            coordinates: 'E2',
            color: :red,
            type: 'five_share',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'WAB',
            name: 'Wabash Railroad',
            logo: '1828/WAB',
            simple_logo: '1828/WAB.alt',
            shares: [20,10,10,10,10,10,10,10,10],
            tokens: [0,0,0],
            coordinates: 'I6',
            color: '#DDA0DD',
            text_color: 'black',
            type: 'ten_share',
            always_market_price: true,
          },
          {
            float_percent: 40,
            sym: 'V',
            name: 'Vandalia Railroad',
            logo: '1849/CTL',
            simple_logo: '1849/CTL.alt',
            shares: [40,20,20,20],
            tokens: [0,0],
            coordinates: 'G16',
            color: '#FFF500',
            type: 'five_share',
            always_market_price: true,
            text_color: 'black',
          },

          {
            float_percent: 40,
            sym: 'C&A',
            name: 'Chicago and Alton Railroad',
            logo: '1849/SFA',
            simple_logo: '1849/SFA.alt',
            shares: [40,20,20,20],
            tokens: [0,0],
            coordinates: 'D15',
            color: :lightgreen,
            type: 'five_share',
            always_market_price: true,
            text_color: 'black',
          },

          {
            float_percent: 100,
            sym: 'NC',
            name: 'Northern Cross Railroad',
            logo: '18_il/NC_token',
            simple_logo: '18_il/NC',
            shares: [100],
            tokens: [0],
            coordinates: 'E12',
            color: :black,
            type: 'two_share',
            max_ownership_percent: 100,
            always_market_price: true,
          },

          {
            float_percent: 20,
            sym: 'C&EI',
            name: 'Chicago and Eastern Illinois Railroad',
            logo: '18_mex/UdY',
            simple_logo: '18_mex/UdY.alt',
            shares: [20,10,10,10,10,10,10,10,10],
            tokens: [0,0,0],
            coordinates: 'H21',
            color: :mahogany,
            type: 'ten_share',
            always_market_price: true,
            text_color: 'black',
          },

          {
            float_percent: 20,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '1846/IC',
            simple_logo: '1846/IC.alt',
            shares: [20,10,10,10,10,10,10,10,10],
            tokens: [0,0,0],
            coordinates: 'H7',
            color: :green,
            type: 'ten_share',
            always_market_price: true,
            abilities: [type: 'no_buy'],
          },

        ].freeze
      end
    end
  end
end
