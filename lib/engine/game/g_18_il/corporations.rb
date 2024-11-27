# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Corporations
        
        def game_corporations
          corporations = [
              {
                float_percent: 100,
                sym: 'P&BV',
                name: 'Peoria and Bureau Valley Railroad',
                logo: '18_il/P&BV',
                simple_logo: '18_il/P&BV.alt',
                shares: [100],
                tokens: [0],
                coordinates: 'E8',
                color: '#4682B4',
                type: 'two_share',
                max_ownership_percent: 100,
                always_market_price: true,
              },
              {
                float_percent: 100,
                sym: 'NC',
                name: 'Northern Cross Railroad',
                logo: '18_il/NC',
                simple_logo: '18_il/NC.alt',
                shares: [100],
                tokens: [0],
                coordinates: 'E12',
                color: '#2600AA',
                type: 'two_share',
                max_ownership_percent: 100,
                always_market_price: true,
              },
              {
                float_percent: 40,
                sym: 'G&CU',
                name: 'Galena and Chicago Union Railroad',
                logo: '18_il/G&CU',
                simple_logo: '18_il/G&CU.alt',
                shares: [40,20,20,20],
                tokens: [0],
                coordinates: 'E2',
                color: '#F40006',
                type: 'five_share',
                always_market_price: true,
              },
              {
                float_percent: 40,
                sym: 'RI',
                name: 'Rock Island Line',
                logo: '18_il/RI',
                simple_logo: '18_il/RI.alt',
                shares: [40,20,20,20],
                tokens: [0],
                coordinates: 'C6',
                color: '#FF9007',
                type: 'five_share',
                always_market_price: true,
                text_color: 'black',
              },
              {
                float_percent: 40,
                sym: 'C&A',
                name: 'Chicago and Alton Railroad',
                logo: '18_il/C&A',
                simple_logo: '18_il/C&A.alt',
                shares: [40,20,20,20],
                tokens: [0],
                coordinates: 'D15',
                color: '#45DF00',
                type: 'five_share',
                always_market_price: true,
                text_color: 'black',
              },
              {
                float_percent: 40,
                sym: 'V',
                name: 'Vandalia Railroad',
                logo: '18_il/V',
                simple_logo: '18_il/V.alt',
                shares: [40,20,20,20],
                tokens: [0],
                coordinates: 'G16',
                color: '#FFFD44',
                type: 'five_share',
                always_market_price: true,
                text_color: 'black',
              },
              {
                float_percent: 20,
                sym: 'WAB',
                name: 'Wabash Railroad',
                logo: '18_il/WAB',
                simple_logo: '18_il/WAB.alt',
                shares: [20,10,10,10,10,10,10,10,10],
                tokens: [0],
                coordinates: 'I6',
                color: '#ABABAB',
                text_color: 'black',
                type: 'ten_share',
                always_market_price: true,
              },
              {
                float_percent: 20,
                sym: 'C&EI',
                name: 'Chicago and Eastern Illinois Railroad',
                logo: '18_il/C&EI',
                simple_logo: '18_il/C&EI.alt',
                shares: [20,10,10,10,10,10,10,10,10],
                tokens: [0],
                coordinates: 'H21',
                color: '#740013',
                type: 'ten_share',
                always_market_price: true,
                text_color: 'white',
              },
              {
              float_percent: 100,
              sym: 'IC',
              name: 'Illinois Central Railroad',
              logo: '18_il/IC',
              simple_logo: '18_il/IC.alt',
              shares: [20,10,10,10,10,10,10,10,10],
              tokens: [0],
              coordinates: 'H3',
              city: 2,
              color: "#006A14",
              type: 'ten_share',
              always_market_price: true,
              floatable: false,
              abilities: [
                {
                  type: 'description',
                  description: 'Modified train buy',
                  desc_detail: "IC can only buy trains from the bank and can only buy one train per round. "\
                  "IC is not required to own a train, but must buy a train if possible. "\
                  "IC's last train may not be bought by another corporation."
                },
                {
                  type: 'description',
                  description: 'Modified stock purchase',
                  desc_detail: "IC treasury shares are only available for purchase in concession rounds."
                },
              ],
            }
          ]
          corporations
        end
      end
    end
  end
end
