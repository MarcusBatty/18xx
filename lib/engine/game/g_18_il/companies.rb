# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18IL
      module Companies

        #TODO: reference game.rb's version instead of having redundancy (dunno how...)
        MINE_HEXES = %w[D9 D13 D17 E6 E14 F5 F13 F21 G22 H11].freeze

        def game_companies
        companies = [
          {
            name: '1 Peoria and Bureau Valley Railroad',
            sym: 'P&BV',
            value: 0,
            revenue: 0,
            desc: 'Can start P&BV',
            corporation: 'P&BV',
            color: '#4682B4',
            text_color: 'white',
          },
          {
            name: '2 Northern Cross Railroad',
            sym: 'NC',
            value: 0,
            revenue: 0,
            desc: 'Can start NC',
            corporation: 'P&BV',
            color: '#2600AA',
            text_color: 'white',
          },
        ]
          companies << {
            name: '3 Galena and Chicago Union Railroad',
            sym: 'G&CU',
            value: 0,
            revenue: 0,
            desc: 'Can start G&CU',
            corporation: 'G&CU',
            color: '#F40006',
            text_color: 'white',
          }
          companies << {
            name: '4 Rock Island Line',
            sym: 'RI',
            value: 0,
            revenue: 0,
            desc: 'Can start RI',
            corporation: 'RI',
            color: '#FF9007',
            text_color: 'black',
          }
          companies << {
            name: '5 Chicago and Alton Railroad',
            sym: 'C&A',
            value: 0,
            revenue: 0,
            desc: 'Can start C&A',
            corporation: 'C&A',
            color: '#45DF00',
            text_color: 'black',
          }
          companies << {
            name: '6 Vandalia Railroad',
            sym: 'V',
            value: 0,
            revenue: 0,
            desc: 'Can start V',
            corporation: 'V',
            color: '#FFFD44',
            text_color: 'black',
          }
          companies << {
            name: '7 Wabash Railroad',
            sym: 'WAB',
            value: 0,
            revenue: 0,
            desc: 'Can start WAB',
            corporation: 'WAB',
            color: '#ABABAB',
            text_color: 'black',
          }
          companies << {
            name: '8 Chicago and Eastern Illinois Railroad',
            sym: 'C&EI',
            value: 0,
            revenue: 0,
            desc: 'Can start C&EI',
            corporation: 'C&EI',
            color: '#740013',
            text_color: 'white',
          }
          # #TODO:  fix
          # {
          #   name: 'Extra Station',
          #   sym: 'ES',
          #   value: 5,
          #   revenue: 0,
          #   desc: 'Place an additional station marker on the charter for free. Once this ability is used, the private company closes. ',
          #   color: nil,

          #   abilities: [
          #     {
          #       type: 'additional_token',
          #       count: 1,
          #       owner_type: 'corporation',
          #       when: 'owning_corp_track',
          #       closed_when_used_up: true,
          #       extra_slot: true,
          #     },
          #   ],
          # },
         # {
            #TODO:  add port marker to charter
            #TODO:  closes on brown CHI tile
        #     name: 'Goodrich Transit Line',
        #     value: 5,
        #     revenue: 0,
        #     desc: 'Place an available station marker in Chicago (H3) in the indicated GTL station slot. A port marker is placed on the charter. '\
        #     'Once this ability is used, the private company closes. If this company is still open when Chicago is upgraded with a brown tile, it closes immediately.',
        #     sym: 'GTL',
        #     abilities: [
        #       {
        #         type: 'token',
        #         when: 'owning_corp_or_turn',
        #         owner_type: 'corporation',
        #         hexes: ['H3'],
        #         city: 2,
        #         price: 0,
        #         teleport_price: 0,
        #         from_owner: true,
        #         count: 1,
        #         extra_action: true,
        #         closed_when_used_up: true,
        #       },
        #       { type: 'reservation', remove: 'sold', hex: 'H3', city: 1}
        #     ],
        #   },
        #   #TODO:  place port marker
        #   {
        #     name: 'Steamboat',
        #     value: 5,
        #     revenue: 0,
        #     desc: 'At any time during the tile-laying step of the corporation’s operating turn, place either the “St. Paul Harbor” tile at B1 or the “Port of Memphis” tile at D23.'\
        #     ' It does not have to be connected to a station marker and does not count as a tile lay. Place two port markers on the charter. Once this ability is used, the private company closes.',
        #     sym: 'SMBT',
        #     abilities: [
        #       {
        #       type: 'tile_lay',
        #       hexes: %w[B1 D23],
        #       tiles: %w[SPH POM],
        #       when: 'track',
        #       free: true,
        #       owner_type: 'corporation',
        #       count: 1,
        #       closed_when_used_up: true,
        #       },
        #     ],
        #   },
        #   {
        #     name: 'Illinois Steel Bridge Company',
        #     value: 5,
        #     revenue: 0,
        #     desc: 'Receive a $20 discount when laying a tile in a hex containing a river or a lake.',
        #     sym: 'ISBC',
        #     abilities: [
        #         {
        #         type: 'tile_discount',
        #         terrain: 'water',
        #         owner_type: 'corporation',
        #         discount: 20,
        #         },
        #       ],
        #     },
        #     {
        #       #TODO:  place mine marker
        #       name: 'Frink, Walker, & Co.',
        #       value: 5,
        #       revenue: 0,
        #       desc: 'During the tile-laying step of the corporation operating turn, place the G tile in Galena for free, ignoring terrain costs. It '\
        #       'does not have to be connected to a station marker and does not count as a tile lay. Place a mine marker on the corporation charter. Once'\
        #       ' this ability is used, the private company closes.',
        #       sym: 'FWC',
        #       abilities: [
        #         {
        #         type: 'tile_lay',
        #         hexes: ['C2'],
        #         tiles: ['G1'],
        #         when: 'track',
        #         free: true,
        #         owner_type: 'corporation',
        #         count: 1,
        #         closed_when_used_up: true,
        #         },
        #       ],
        #     },
        #     {
        #       name: 'Train Subsidy',
        #       value: 5,
        #       revenue: 0,
        #       desc: 'Receive a 25% discount on non-permanent trains and a 20% discount on permanent trains. Once this ability is used, the private company closes.',
        #       sym: 'TS',
        #       #TODO:  fix
        #       abilities: [
        #         {
        #           type: 'train_discount',
        #           discount: 0.25,
        #           owner_type: 'corporation',
        #           use_across_ors: false,
        #           trains: %w[2 3 4 3P],
        #           count: 4,
        #           closed_when_used_up: true,
        #           when: 'buy_train',
        #         },
        #         {
        #           type: 'train_discount',
        #           discount: 0.2,
        #           owner_type: 'corporation',
        #           use_across_ors: false,
        #           trains: %w[4+2P 5+1P 6 D],
        #           count: 4,
        #           closed_when_used_up: true,
        #           when: 'buy_train',
        #         },
        #       ],
        #     },
        #     #TODO:  regardless of current city color
        #     #TODO:  remove other tile
        #     #"special: true" tag may be needed
        #     {
        #       name: 'Central Illinois Boom',
        #       value: 5,
        #       revenue: 0,
        #       desc: 'In phase D, upgrade Peoria or Springfield using the matching gray tile. It does not have to be connected to a station marker, '\
        #       ' does not count as a tile lay, and may be upgraded regardless of the current city color. The unused tile is removed from the game. Once'\
        #       ' this ability is used, the private company closes.',
        #       sym: 'CIB',
        #       abilities: [
        #         {
        #           type: 'tile_lay',
        #           #tiles: %w[P4 S4],
        #           tiles: %w[P2 S2],
        #           hexes: %w[E8 E12],
        #           when: 'track',
        #           owner_type: 'corporation',
        #           count: 1,
        #           consume_tile_lay: false,
        #           reachable: false,
        #           closed_when_used_up: true,
        #         },
        #       ],
        #     },

        #     {
        #       name: 'Chicago-Virden Coal Company',
        #       value: 5,
        #       revenue: 0,
        #       desc: 'During the tile-laying step of the corporation’s operating turn, place a mine tile in a mine hex (except Galena), paying any terrain costs. '\
        #       'It must be connected to one of the corporation’s existing station markers but does not count as a tile lay. Place a mine marker '\
        #       'on the corporation’s charter. Once this ability is used, the private company closes.',
        #       sym: 'CVCC',
        #       abilities: [
        #       {
        #           type: 'tile_lay',
        #           tiles: ['58'],
        #           hexes: MINE_HEXES,
        #           when: 'track',
        #           owner_type: 'corporation',
        #           count: 1,
        #           consume_tile_lay: false,
        #           reachable: true,
        #           closed_when_used_up: true,
        #           },
        #       ],
        #       }
        # ].freeze
          companies
        end
       # MINE_COMPANIES = %w[FWC CIB CVCC].freeze
       # PORT_COMPANIES = %w[GTL SMBT].freeze
        #TODO: DC can be either, SMBT gets two tokens
      end
    end
  end
end

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
              {
                name: 'U.S. Mail Line',
                value: 5
                revenue: 0,
                desc: 'After the “Run Trains” step of the corporation’s operating turn, receive $5 from the bank to the corporation’s treasury per stop that each train visited. '\
                'Multiple trains visiting the same stop grant $5 per visit. The corporation may choose to receive a mine marker at any time.  When it does, the private company closes.',
                sym: 'USML',
                abilities: [
                  {

                  },
                ],
              },
              {
                name: 'Advanced Track',
                value: 5,
                revenue: 0,
                desc: 'This company starts with two subsidy cubes on it. At any time during the tile-laying step of the corporation's operating turn, discard one cube to lay or upgrade one additional tile for free,'\
                'except for any terrain costs. Only one cube may be used per turn. Once the second cube has been used, the private company closes.',
                sym: 'AT',
                abilities: [
                  {

                  },            
                ],
              },
              {
                name: 'Diverse Cargo',
                value: 5,
                revenue: 0,
                desc: 'Place either a mine or port marker on the corporation’s charter. Once this ability is used, the private company closes.',
                sym: 'DC',
                abilities: [
                  {

                  },            
                ],
              },
              {
                name: 'Engineering Mastery',
                value: 5,
                revenue: 0,
                desc: 'During the tile-laying step of the corporation's operating turn, upgrade two tiles from yellow to green (instead of two lays or one lay and one upgrade), paying the normal $20 fee and any terrain costs.',
                sym: 'EM',
                abilities: [
                  {

                  },            
                ],
              },
              {
                name: 'Lincoln Funeral Car',
                value: 5,
                revenue: 0,
                desc: 'During the “Run Trains” step of the corporation’s operating turn, one of the corporation’s trains earns an additional $20/$30/$40 for each of the following cities in its route dur-ing a yellow/green/brown phase, '\
                'respectively: Chicago (H3), Joliet (G6), Bloomington (F9), and Springfield (E12). Once this ability is used, the private company closes.',
                sym: 'LFC',
                abilities: [
                  {

                  },            
                ],
              },
=end 

