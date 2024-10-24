# frozen_string_literal: true

module Engine
  module Game
    module G1850JR
      module Entities
        COMPANIES = [
          {
            name: 'Pickering Company of Britain',
            sym: 'PK',
            value: 20,
            revenue: 5,
            desc: 'No special abilities. Blocks B5 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['B5'] }],
            color: nil,
          },
          {
            name: 'Métlaoui Phosphates Concession',
            sym: 'MPC',
            value: 40,
            revenue: 10,
            desc: 'A corporation owning the MPC may lay a tile on C14 without cost, even if this hex is not connected'\
                  " to the corporation's track. This free tile placement is in addition to the corporation's normal tile"\
                  ' placement. Blocks C14 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C14'] },
                        {
                          type: 'tile_lay',
                          owner_type: 'corporation',
                          hexes: ['C14'],
                          free: true,
                          tiles: %w[7 8 9],
                          when: 'owning_corp_or_turn',
                          count: 1,
                        }],
            color: nil,
          },

          {
            name: 'Kasserine Pass',
            sym: 'KP',
            value: 70,
            revenue: 15,
            desc: 'A corporation owning the KP may place a tile and station token in the Kasserine hex C10 for only the $40'\
                  " cost of the mountain. The station does not have to be connected to the remainder of the corporation's"\
                  " route. The tile laid is the owning corporation's one tile placement for the turn. The hex must be empty"\
                  ' to use this ability. Blocks C10 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C10'] },
                        {
                          type: 'teleport',
                          owner_type: 'corporation',
                          tiles: ['57'],
                          hexes: ['C10'],
                        }],
            color: nil,
          },
=begin          
          {
            name: 'Sousse',
            sym: 'SOU',
            value: 110,
            revenue: 20,
            desc: 'A player owning the SOU may exchange it for a 10% share of the Port of Sousse (PoS) if they do not already hold 60%'\
                  ' of the PoS and there is PoS stock available in the Bank or the Pool. The exchange may be made during'\
                  " the player's turn of a stock round or between the turns of other players or corporations in either "\
                  'stock or operating rounds. This action closes the private company. Blocks G6 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['G6'] },
                        {
                          type: 'exchange',
                          corporations: ['SOU'],
                          owner_type: 'player',
                          when: 'any',
                          from: %w[ipo market],
                        }],
            color: nil,
          },

          {
            name: 'Mancardi Concession',
            sym: 'MC',
            value: 220,
            revenue: 30,
            desc: "The owner of this private company immediately receives the President's certificate of the"\
                  ' Port of Rades (PoR) without further payment. This private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the PoR.'\
                  ' When the PoR purchases its first train the private company is closed.'\
                  ' Blocks F6 & G5 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[F6 G5] },
                        { type: 'close', when: 'bought_train', corporation: 'PoR' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'PoR_0' }],
            color: nil,
          },
=end
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'PoB',
            name: 'Port of Bizerte',
            logo: '1849/IFT',
            simple_logo: '1849/IFT.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'E2',
            color: '#0189d1',
          },
          {
            float_percent: 60,
            sym: 'PoR',
            name: 'Port of Rades',
            logo: '1849/SFA',
            simple_logo: '1849/SFA.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F5',
            color: :pink,
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'PoS',
            name: 'Port of Sousa',
            logo: '1849/CTL',
            simple_logo: '1849/CTL.alt',
            tokens: [0, 40, 100],
            coordinates: 'G8',
            color: :'#FFF500',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'PoX',
            name: 'Port of Sfax',
            logo: '1849/RCS',
            simple_logo: '1849/RCS.alt',
            tokens: [0, 40, 100],
            coordinates: 'G14',
            city: 1,
            color: '#f48221',
          },
          {
            float_percent: 60,
            sym: 'PoG',
            name: 'Port of Gabes',
            logo: '1849/RCS',
            simple_logo: '1849/RCS.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F17',
            city: 1,
            color: '#f48221',
          },

        ].freeze
      end
    end
  end
end






