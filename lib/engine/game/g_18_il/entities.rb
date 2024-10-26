# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Entities
        COMPANIES = [
          {
            name: 'Schuylkill Valley',
            sym: 'SV',
            value: 20,
            revenue: 5,
            desc: 'No special abilities. ',
            color: nil,
          },

          {
            name: 'Illinois Steel Bridge Company',
            value: 10,
            revenue: 0,
            desc: 'Ignore terrain costs for rivers and lakes.',
            sym: 'ISBC',
=begin
            abilities: [
                {
                type: 'tile_discount',
                terrain: 'water',
                owner_type: 'corporation',
                },
              ],
=end
            },

            {
              name: 'Frink, Walker, & Co.',
              value: 10,
              revenue: 0,
              desc: 'During the tile-laying step of the corporation operating turn, place the G tile in Galena for free, ignoring terrain costs'\
              'It does not have to be connected to a station marker and does not count as a tile lay. Place a mine marker on the corporation charter.'\
              'Once this ability is used, the private company closes.',
              sym: 'FW&C',
=begin
              abilities: [
                {
                type: 'tile_lay',
                hexes: ['C2'],
                tiles: ['IL2'],
                when: 'track',
                owner_type: 'corporation',
                count: 1,
                consume_tile_lay: true,
                closed_when_used_up: true,
                special: true,
                },
              ],
=end
            },

          {
            name: 'Delaware & Hudson',
            sym: 'DH',
            value: 70,
            revenue: 15,
            desc: "A corporation owning the DH",
            color: nil,
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
