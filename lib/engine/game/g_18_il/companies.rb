# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18IL
      module Companies
        MINES = %w[D9 D17 E6 E14 E16 F5 F13 F21 G22 H11].freeze

        def game_companies
          companies = [
            {
              name: 'Peoria and Bureau Valley Railroad',
              sym: 'P&BV',
              value: 10,
              revenue: 0,
              corporation: 'P&BV',
              color: '#4682B4',
              text_color: 'white',
              meta: { type: :concession, share_count: 2 },
            },
            {
              name: 'Northern Cross Railroad',
              sym: 'NC',
              value: 10,
              revenue: 0,
              corporation: 'NC',
              color: '#2600AA',
              text_color: 'white',
              meta: { type: :concession, share_count: 2 },
            },
            {
              name: 'Galena and Chicago Union Railroad',
              sym: 'G&CU',
              value: 10,
              revenue: 0,
              corporation: 'G&CU',
              color: '#F40006',
              text_color: 'white',
              meta: { type: :concession, share_count: 5 },
            },
            {
              name: 'Rock Island Line',
              sym: 'RI',
              value: 10,
              revenue: 0,
              corporation: 'RI',
              color: '#FF9007',
              text_color: 'black',
              meta: { type: :concession, share_count: 5 },
            },
            {
              name: 'Chicago and Alton Railroad',
              sym: 'C&A',
              value: 10,
              revenue: 0,
              corporation: 'C&A',
              color: '#45DF00',
              text_color: 'black',
              meta: { type: :concession, share_count: 5 },
            },
            {
              name: 'Vandalia Railroad',
              sym: 'V',
              value: 10,
              revenue: 0,
              corporation: 'V',
              color: '#FFFD44',
              text_color: 'black',
              meta: { type: :concession, share_count: 5 },
            },
            {
              name: 'Wabash Railroad',
              sym: 'WAB',
              value: 10,
              revenue: 0,
              corporation: 'WAB',
              color: '#ABABAB',
              text_color: 'black',
              meta: { type: :concession, share_count: 10 },
            },
            {
              name: 'Chicago and Eastern Illinois Railroad',
              sym: 'C&EI',
              value: 10,
              revenue: 0,
              corporation: 'C&EI',
              color: '#740013',
              text_color: 'white',
              meta: { type: :concession, share_count: 10 },
            },
            {
              name: "IC President's Share",
              sym: 'ICP',
              value: 0,
              revenue: 0,
              desc: "President's Share (20%) of IC",
              corporation: 'IC',
              color: '#006A14',
              text_color: 'white',
              meta: { type: :presidents_share },
            },
            {
              name: 'IC Share',
              sym: 'IC1',
              value: 0,
              revenue: 0,
              desc: 'Ordinary Share (10%) of IC',
              corporation: 'IC',
              color: '#006A14',
              text_color: 'white',
              meta: { type: :share },
            },
            {
              name: 'IC Share',
              sym: 'IC2',
              value: 0,
              revenue: 0,
              desc: 'Ordinary Share (10%) of IC',
              corporation: 'IC',
              color: '#006A14',
              text_color: 'white',
              meta: { type: :share },
            },
            {
              name: 'IC Share',
              sym: 'IC3',
              value: 0,
              revenue: 0,
              desc: 'Ordinary Share (10%) of IC',
              corporation: 'IC',
              color: '#006A14',
              text_color: 'white',
              meta: { type: :share },
            },
          ]
          return companies if @optional_rules&.include?(:intro_game)

          companies.concat([
            {
              name: 'Share Premium',
              value: 0,
              revenue: 0,
              desc: 'When issuing a share during the Issue a Share step, receive double the current '\
                    'share price from the bank to the corporation treasury. When this corporation is a '\
                    '10-share corporation, one of its treasury shares is reserved. This reservation is '\
                    'removed when the ability is used, which closes the company.',
              sym: 'SP',
              meta: { type: :private, class: :A },
              abilities: [
                {
                  type: 'description',
                  owner_type: 'corporation',
                  count: 1,
                  closed_when_used_up: true,
                  when: 'issue_share',
                },
              ],
            },
            {
              name: 'Station Subsidy',
              value: 0,
              revenue: 0,
              desc: 'This company starts with four subsidies. When starting or converting a '\
                    'corporation, one, two, three, or four subsidies are used in lieu of payment '\
                    'for one, two, three or four station tokens, respectively. A corporation may '\
                    'use the ability to gain five station tokens at a total cost of $40.',
              sym: 'SS',
              meta: { type: :private, class: :A },
              abilities: [
                {
                  type: 'description',
                  desc_detail: 'Station Subsidy',
                  hexes: [],
                  owner_type: 'corporation',
                  count: 4,
                  closed_when_used_up: true,
                },
              ],
            },
            {
              name: 'Steamboat',
              value: 0,
              revenue: 0,
              desc: 'At any time during the tile-laying step of the corporation’s operating '\
                    'turn, place either the “St. Paul Harbor” tile at B1 or the “Port of Memphis” '\
                    'tile at D23. It does not have to be connected to a station marker and does '\
                    'not count as a tile lay. The corporation receives a port marker. Steamboat '\
                    'additionally grants the corporation a $20 bonus per port.',
              sym: 'SMBT',
              meta: { type: :private, class: :A },
              abilities: [
                {
                  type: 'tile_lay',
                  hexes: %w[B1 D23],
                  tiles: %w[SPH POM],
                  when: 'track',
                  free: true,
                  owner_type: 'corporation',
                  count: 1,
                },
              ],
            },
            {
              name: 'Extra Station',
              sym: 'ES',
              value: 0,
              revenue: 0,
              desc: 'Receive an additional station marker. Once this ability is used, '\
                    'the company closes.',
              color: nil,
              meta: { type: :private, class: :A },
              abilities: [
                {
                  type: 'additional_token',
                  count: 1,
                  owner_type: 'corporation',
                  when: 'track',
                  closed_when_used_up: true,
                  extra_slot: true,
                },
              ],
            },
            {
              name: 'U.S. Mail Line',
              value: 0,
              revenue: 0,
              desc: 'When running trains, receive $10 multiplied by the number of cities and offboards '\
                    'each train visits. This amount is paid from the bank to the corporation\'s treasury. At '\
                    'the beginning of its turn, the corporation may choose to close this company in exchange '\
                    'for a mine marker.',
              sym: 'USML',
              meta: { type: :private, class: :A },
              abilities: [
                {
                  type: 'description',

                },
              ],
            },
            {
              name: 'Goodrich Transit Line',
              value: 0,
              revenue: 0,
              desc: 'Place an available station marker in Chicago (H3) in the indicated GTL '\
                    'station slot. The corporation receives a port marker. Once this ability is '\
                    'used, the company closes. If this company is still open when Chicago is '\
                    'upgraded with a brown tile, it closes immediately.',
              sym: 'GTL',
              meta: { type: :private, class: :A },
              abilities: [
                {
                  type: 'token',
                  when: %w[track token route buying_train bought_train],
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
                { type: 'reservation', remove: 'sold', hex: 'H3', city: 1 },
              ],
            },
            {
              name: 'Train Subsidy',
              value: 0,
              revenue: 0,
              desc: 'Receive a 25% discount on non-permanent trains and a 20% discount '\
                    'on permanent trains during a single train-buying step. Once this ability '\
                    'is used, the company closes.',
              sym: 'TS',
              meta: { type: :private, class: :A },
              abilities: [
                {
                  type: 'train_discount',
                  discount: {
                    '2' => 0.25,
                    '3' => 0.25,
                    '4' => 0.25,
                    '3P' => 0.25,
                    '4+2P' => 0.2,
                    '5+1P' => 0.2,
                    '6' => 0.2,
                    'D' => 0.2,
                  },
                  owner_type: 'corporation',
                  use_across_ors: false,
                  trains: %w[2 3 4 3P 4+2P 5+1P 6 D],
                  count: 99,
                  closed_when_used_up: true,
                  when: 'buy_train',
                },
              ],
            },
            {
              name: 'Rush Delivery',
              value: 0,
              revenue: 0,
              desc: 'Buy one train from the bank prior to the Run Trains step during this '\
                    'operating round. The corporation may use emergency money raising if it does '\
                    'not own a train. Once this ability is used, the private company closes.',
              sym: 'RD',
              meta: { type: :private, class: :A },
              abilities: [
                {
                  type: 'train_buy',
                  owner_type: 'corporation',
                  count: 1,
                  when: 'buy_train',
                },
              ],
            },
            {
              name: 'Chicago-Virden Coal Co.',
              value: 0,
              revenue: 0,
              desc: 'During the tile-laying step of the corporation’s operating turn, lay or upgrade '\
                    'in a mine hex (except Galena) with the #M1 tile, paying any terrain costs. It must be '\
                    'connected to one of the corporation’s existing station markers but does not count as a '\
                    'tile lay. The corporation receives a mine marker. Once this ability is used, the '\
                    'company closes. At the beginning of its turn, the corporation may choose to close '\
                    'this company in exchange for a mine marker.',
              sym: 'CVCC',
              meta: { type: :private, class: :B },
              abilities: [
                {
                  type: 'tile_lay',
                  tiles: %w[M1],
                  hexes: MINES,
                  when: 'track',
                  owner_type: 'corporation',
                  count: 1,
                  consume_tile_lay: false,
                  reachable: true,
                  closed_when_used_up: true,
                },
              ],
            },
            {
              name: 'Diverse Cargo',
              value: 0,
              revenue: 0,
              desc: 'The corporation receives either a mine or port marker. Once this ability is used, '\
                    'the private company closes.',
              sym: 'DC',
              meta: { type: :private, class: :B },
            },
            {
              name: 'Central IL Boom',
              value: 0,
              revenue: 0,
              desc: 'In phase D, upgrade Peoria or Springfield using the matching gray tile. '\
                    'It does not have to be connected to a station marker, does not count as a tile '\
                    'lay, and may be upgraded regardless of the current city color. The unused tile '\
                    'is removed from the game. Once this ability is used, the company closes.',
              sym: 'CIB',
              meta: { type: :private, class: :B },
              abilities: [
                {
                  type: 'tile_lay',
                  blocks: true,
                  tiles: %w[P4 S4],
                  hexes: %w[E8 E12],
                  when: 'track',
                  owner_type: 'corporation',
                  count: 1,
                  consume_tile_lay: false,
                  reachable: false,
                  closed_when_used_up: true,
                  special: false,
                },
              ],
            },
            {
              name: 'Frink, Walker, & Co.',
              value: 0,
              revenue: 0,
              desc: 'During the tile-laying step of the corporation operating turn, place the G tile '\
                    'in Galena for free, ignoring terrain costs. It does not have to be connected to a '\
                    'station marker and does not count as a tile lay. The corporation receives a mine '\
                    'marker. Once this ability is used, the private company closes. At the beginning of '\
                    'its turn, the corporation may choose to close this company in exchange for a mine marker.',
              sym: 'FWC',
              meta: { type: :private, class: :B },
              abilities: [
              {
                type: 'tile_lay',
                hexes: ['C2'],
                tiles: ['G1'],
                when: 'track',
                free: true,
                owner_type: 'corporation',
                count: 1,
                closed_when_used_up: true,
              },
            ],
            },
            {
              name: 'Engineering Mastery',
              value: 0,
              revenue: 0,
              desc: 'During the tile-laying step of the corporation’s operating turn, upgrade two tiles '\
                    '(instead of two lays or one lay and one upgrade), paying a $30 fee (instead of $20) '\
                    'and any terrain costs. This may not be used to upgrade two incomplete IC Line hexes '\
                    'in one turn.',
              sym: 'EM',
              meta: { type: :private, class: :B },
            },
            {
              name: 'Advanced Track',
              value: 0,
              revenue: 0,
              desc: 'During the tile-laying step of its operating turn, the owning corporation may lay or upgrade an '\
                    'additional tile to which it has a route for free (paying terrain costs as normal). This ability may be '\
                    'used to lay or upgrade a tile already acted upon during the same turn. '\
                    'Once this ability has been used twice, the private company closes.',
              sym: 'AT',
              meta: { type: :private, class: :B },
              abilities: [
                {
                  type: 'tile_lay',
                  when: 'track',
                  owner_type: 'corporation',
                  tiles: [],
                  hexes: [],
                  count: 2,
                  count_per_or: 1,
                  consume_tile_lay: false,
                  reachable: true,
                  closed_when_used_up: true,
                  special: false,
                },
              ],
            },
            {
              name: 'Lincoln Funeral Car',
              value: 0,
              revenue: 0,
              desc: 'During the “Run Trains” step of the corporation’s operating turn, one of the corporation’s '\
                    'trains earns an additional $20/$40/$60 for each of the following cities in its route '\
                    'during a green/brown/gray phase, respectively: Chicago (H3), Joliet (G6), '\
                    'Bloomington (F9), and Springfield (E12). Once this ability is used, the company closes.',
              sym: 'LFC',
              meta: { type: :private, class: :B },
              abilities: [
                  {
                    type: 'hex_bonus',
                    when: 'route',
                    owner_type: 'corporation',
                    hexes: %w[H3 G6 F9 E12],
                    amount: 20,
                    count: 1,
                  },
                ],
            },
            {
              name: 'Illinois Steel Bridge Co.',
              value: 0,
              revenue: 0,
              desc: 'Receive a $20 discount when laying a tile in a hex containing a river or a lake.',
              sym: 'ISBC',
              meta: { type: :private, class: :B },
              abilities: [
                  {
                    type: 'tile_discount',
                    terrain: 'water',
                    owner_type: 'corporation',
                    discount: 20,
                  },
                ],
            },
          ])
          companies
        end
      end
    end
  end
end
