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
            name: 'Champlain & St.Lawrence',
            sym: 'CS',
            value: 40,
            revenue: 10,
            desc: "A corporation owning the CS may",
            color: nil,
          },
          {
            name: 'Delaware & Hudson',
            sym: 'DH',
            value: 70,
            revenue: 15,
            desc: "A corporation owning the DH",
            color: nil,
          },
=begin
          {
            name: 'Mohawk & Hudson',
            sym: 'MH',
            value: 110,
            revenue: 20,
            desc: 'A player owning the MH may exchange it for a 10% share of the NYC if they do not already hold 60%'\
                  ' of the NYC and there is NYC stock available in the Bank or the Pool. The exchange may be made during'\
                  " the player's turn of a stock round or between the turns of other players or corporations in either "\
                  'stock or operating rounds. This action closes the MH. Blocks D18 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D18'] },
                        {
                          type: 'exchange',
                          corporations: ['NYC'],
                          owner_type: 'player',
                          when: 'any',
                          from: %w[ipo market],
                        }],
            color: nil,
          },
          {
            name: 'Camden & Amboy',
            sym: 'CA',
            value: 160,
            revenue: 25,
            desc: 'The initial purchaser of the CA immediately receives a 10% share of PRR stock without further'\
                  ' payment. This action does not close the CA. The PRR corporation will not be running at this point,'\
                  ' but the stock may be retained or sold subject to the ordinary rules of the game.'\
                  ' Blocks H18 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['H18'] },
                        { type: 'shares', shares: 'PRR_1' }],
            color: nil,
          },
          {
            name: 'Baltimore & Ohio',
            sym: 'BO',
            value: 220,
            revenue: 30,
            desc: "The owner of the BO private company immediately receives the President's certificate of the"\
                  ' B&O without further payment. The BO private company may not be sold to any corporation, and does'\
                  ' not exchange hands if the owning player loses the Presidency of the B&O.'\
                  ' When the B&O purchases its first train the private company is closed.'\
                  ' Blocks I13 & I15 while owned by a player.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[I13 I15] },
                        { type: 'close', when: 'bought_train', corporation: 'B&O' },
                        { type: 'no_buy' },
                        { type: 'shares', shares: 'B&O_0' }],
            color: nil,
          },
=end
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
            coordinates: 'H3',
            color: :green,
            type: 'ten_share',
            always_market_price: true,
          },

        ].freeze
      end
    end
  end
end
