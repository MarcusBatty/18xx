# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Entities
        COMPANIES = [
          #TODO:  fix
          {
            name: 'Extra Station',
            sym: 'ES',
            value: 5,
            revenue: 0,
            desc: 'Place an additional station marker on the charter for free. Once this ability is used, the private company closes. ',
            color: nil,

            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
                when: 'any',
                closed_when_used_up: true,
                extra_slot: true,
              },
            ],
          },
          {
            #TODO:  add port marker to charter
            #TODO:  closes on brown CHI tile
            name: 'Goodrich Transit Line',
            value: 5,
            revenue: 0,
            desc: 'Place an available station marker in Chicago (H3) in the indicated station slot- GTL. Place a port marker on the charter.'\
            ' Once this ability is used, the private company closes. If this company is still open when Chicago is upgraded with a brown tile, it closes immediately.',
            sym: 'GTL',
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                hexes: ['H3'],
                city: 2,
                price: 0,
                teleport_price: 0,
                from_owner: true,
                count: 1,
                extra_action: true,
                closed_when_used_up: true,
              },
              {type: 'reservation', remove: 'sold', hex: 'H3', city: 1},
            ],
        },
=begin
        {
          name: 'Rush Delivery',
          value: 5
          revenue: 0,
          desc: 'Buy one train from the bank prior to the “Run Trains” step during this operating round. The corporation may use emergency money raising if'\
          ' it does not own a train. Once this ability is used, the private company closes.',
          sym: 'RD',
          abilities: [
            {

            },
          ],
        },
        {
          name: 'Station Subsidy',
          value: 5
          revenue: 0,
          desc: 'This company starts with four subsidy cubes on it. When starting or converting a corporation, one, two, three, or four cubes may be discarded to receive a discount of $40,'\ 
          ' $80, $120, or $160 respectively, when buying station markers. Once the fourth cube has been used, the private company closes.',
          sym: 'SS',
          abilities: [
            {

            },
          ],
        },
        {
          name: 'Share Premium',
          value: 5,
          revenue: 0,
          desc: 'When issuing a share during the Issue a Share step, receive double the current share price from the bank to the corporation treasury.'\
                ' Once this ability is used, the private company closes.',
          sym: 'SP',
          abilities: [
            {

            },            
          ],
        },
=end 

          #TODO:  place port marker, write code so blue can be upgraded to blue (and change hexes and tiles to be blue)  
          # {
          #   name: 'Steamboat',
          #   value: 5,
          #   revenue: 0,
          #   desc: 'At any time during the tile-laying step of the corporation’s operating turn, place either the “St. Paul Harbor” tile at B1 or the “Port of Memphis” tile at D23.'\
          #   ' It does not have to be connected to a station marker and does not count as a tile lay. Place two port markers on the charter. Once this ability is used, the private company closes.',
          #   sym: 'SMBT',
          #   abilities: [
          #     {
          #     type: 'tile_lay',
          #     #hexes: %w[B1 D23],
          #     hexes: ['B1'],
          #     #tiles: %w[SPH POM],
          #     tiles: ['SPH'],
          #     when: 'track',
          #     free: true,
          #     owner_type: 'corporation',
          #     count: 1,
          #     closed_when_used_up: true,
          #     },
           #   {
       #         type: 'tile_lay',

       #         when: 'track',
      #          free: true,
      #          owner_type: 'corporation',
      #          count: 1,
      #          closed_when_used_up: true,
      #        },
      #      ],
       #   },

          {
            name: 'Illinois Steel Bridge Company',
            value: 5,
            revenue: 0,
            desc: 'Receive a $20 discount when laying a tile in a hex containing a river or a lake.',
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
              #TODO:  place mine marker
              name: 'Frink, Walker, & Co.',
              value: 5,
              revenue: 0,
              desc: 'During the tile-laying step of the corporation operating turn, place the G tile in Galena for free, ignoring terrain costs. It '\
              'does not have to be connected to a station marker and does not count as a tile lay. Place a mine marker on the corporation charter. Once'\
              ' this ability is used, the private company closes.',
              sym: 'FW&C',
              abilities: [
                {
                type: 'tile_lay',
                hexes: ['C2'],
                tiles: ['IL2'],
                when: 'track',
                free: true,
                owner_type: 'corporation',
                count: 1,
                closed_when_used_up: true,
                },
              ],
            },
=begin
            {
              name: 'Tredegar Iron Works',
              value: 60,
              revenue: 15,
              desc: 'Closing this private grants the operating Corporation a $200 discount '\
                    'when buying a train from the depot',
              sym: 'P2',
              color: nil,
              abilities: [
                {
                  type: 'train_discount',
                  discount: 200,
                  owner_type: 'corporation',
                  trains: %w[2 3 4 5 6 4D],
                  count: 1,
                  closed_when_used_up: true,
                  when: 'buy_train',
                },
              ],
            },
=end
            {
              name: 'Train Subsidy',
              value: 5,
              revenue: 0,
              desc: 'Receive a 25% discount on non-permanent trains and a 20% discount on permanent trains. Once this ability is used, the private company closes.',
              sym: 'TS',

              #TODO:  fix
              abilities: [
                  {
                  type: 'train_discount',
                  owner_type: 'corporation',
                  use_across_ors: false,
                  when: 'buying_train',
                  discount: 0.25,
                  trains: %w[2 3 4 3P],
                  count: 4,
                  },
                  {
                    type: 'train_discount',
                    owner_type: 'corporation',
                    use_across_ors: false,
                    when: 'buying_train',
                    discount: 0.20,
                    trains: %w[4+2P 5+1P 6 D],
                    count: 2,
                    },
              ],
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
=begin
          {
            float_percent: 20,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '1846/IC',
            simple_logo: '1846/IC.alt',
            shares: [20,10,10,10,10,10,10,10,10],
            tokens: [0,0,0],
            coordinates: 'H3',
            city: 2,
            color: :green,
            type: 'ten_share',
            always_market_price: true,
            abilities: [
              { type:'close',when: 'never' },
              {
                type: 'borrow_train',
                train_types: %w[2 3 4 3P 4+2P 5+1P 6 D],
                description: 'May borrow a train when trainless',
              },
            ],
          },
=end
        ].freeze
      end
    end
  end
end
