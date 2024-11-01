# frozen_string_literal: true

module Engine
    module Game
      module G18IL
        module Companies

          MINE_HEXES = %w[C2 D9 D17 D13 E14 F13 H11 E6 F5 F21 G22]

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
                  when: 'owning_corp_track',
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
                { type: 'reservation', remove: 'sold', hex: 'H3', city: 1},
                #fix
                { type: 'close', on_phase: '4' },
              ],
            },

            #TODO:  place port marker, write code so blue can be upgraded to blue (and change hexes and tiles to be blue)  
            {
              name: 'Steamboat',
              value: 5,
              revenue: 0,
              desc: 'At any time during the tile-laying step of the corporation’s operating turn, place either the “St. Paul Harbor” tile at B1 or the “Port of Memphis” tile at D23.'\
              ' It does not have to be connected to a station marker and does not count as a tile lay. Place two port markers on the charter. Once this ability is used, the private company closes.',
              sym: 'SMBT',
              abilities: [
                {
                type: 'tile_lay',
                hexes: %w[B1 D23],
                tiles: %w[SPH POM],
                when: 'track',
                free: true,
                owner_type: 'corporation',
                count: 1,
                closed_when_used_up: true,
                },
             ],
           },
  
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
                    discount: 0.25,
                    owner_type: 'corporation',
                    trains: %w[2 3 4 3P],
                    count: 2,
                    closed_when_used_up: true,
                    when: 'buy_train',
                  },
                  {
                    type: 'train_discount',
                    owner_type: 'corporation',
                    use_across_ors: false,
                    when: 'buying_train',
                    discount: 0.2,
                    trains: %w[4+2P 5+1P 6 D],
                    count: 4,
                  },
                ],
              },
              {
                name: 'Chicago-Virden Coal Company',
                value: 5,
                revenue: 0,
                desc: 'During the tile-laying step of the corporation’s operating turn, place a yellow mine tile. This is an extra tile lay and is free but must otherwise follow the rules. Place a mine marker on the corporation’s charter. Once this ability is used, the private company closes.',
                sym: 'CV',
                abilities: [
                {
                    type: 'tile_lay',
                    hexes: MINE_HEXES,
                    tiles: ['IL1'],
                    when: 'track',
                    owner_type: 'corporation',
                    count: 1,
                    consume_tile_lay: false,
                    reachable: true,
                    closed_when_used_up: true,
                    #special: true,
                    },
                ],
                }
          ].freeze
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
=end 
  
  