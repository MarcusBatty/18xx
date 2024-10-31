# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Map

        LOCATION_NAMES = {
          'A10' => 'Omaha +80 E/W',
          'B1' => 'St. Paul Harbor',
          'B3' => 'Sioux City +80 E/W', 
          'B11' => 'Quincy',
          'C2' => 'Galena',
          'C6' => 'Rock Island',
          'C8' => 'Galesburg',
          'C16'=> 'St Louis',
          'D9' => 'Canton',
          'D13' => 'Jacksonville',
          'D15' => 'Alton',
          'D17' => 'Belleville',
          'E2' => 'Freeport',
          'E6' => 'Bureau Junction',
          'E8' => 'Peoria',
          'E12' => 'Springfield',
          'E14' => 'Virden',
          'E22' => 'Cairo',
          'F3' => 'Rockford',
          'F5' => 'Ottawa',
          'F9' => 'Bloomington',
          'F11' => 'Decatur',
          'F13' => 'Pana',
          'F17' => 'Centralia',
          'F21' => 'Marion',
          'F25' => 'New Orleans',
          'G2' => 'Milwaukee +100 N/S',
          'G4' => 'Aurora',
          'G6' => 'Joliet',
          'G10' => 'Champaign',
          'G16' => 'Effingham',
          'G22' => 'Harrisburg',
          'H3' => 'Chicago',
          'H7' => 'Kankakee',
          'H11' => 'Danville',
          'H21' => 'Evansville',
          'I2' => 'Lake Michigan',
          'I6' => 'Detroit',
          'I12' => 'Indianapolis',
          'I18' => 'Louisville',
        }.freeze

        HEXES = {

          blue: {
              ['B1'] => 'town=revenue:0;icon=image:port,blocks_lay:1;path=a:5,b:_0',
              ['D23'] => 'town=revenue:0;icon=image:port,blocks_lay:1;path=a:3,b:_0;path=a:5,b:_0',
              ['H1'] => 'town=revenue:20;path=a:1,b:_0;path=a:5,b:_0;border=edge:5;icon=image:port',
              ['I2'] => 'offboard=revenue:0;path=a:1,b:2;border=edge:0;border=edge:2',
              ['I4'] => 'offboard=revenue:0;border=edge:3',
          },

          white: {
            %w[C10 C12 D7 D11 E4 E10 E16 E18 F7 G18 H9 H13 H15] => '',
            %w[E2 F3 F9 F11 G4 G16] => 'city=revenue:0',
            %w[D9 E14 F13 H11] => 'town=revenue:0;icon=image:18_co/mine',
              ['B9'] => 'border=edge:1,type:water,cost:20;border=edge:2,type:water;border=edge:3,type:water',  
              ['B11'] => 'city=revenue:0;border=edge:1,type:water;border=edge:2,type:water,cost:20',
              ['B13'] => 'border=edge:0,type:water;border=edge:1,type:water;border=edge:2,type:water',
              ['C2'] => 'label=G;town=revenue:0;upgrade=cost:60,terrain:mountain;icon=image:18_co/mine;border=edge:1,type:water,cost:20',
              ['C6'] => 'city=revenue:0;border=edge:1,type:water;border=edge:2,cost:20,type:water;border=edge:3,type:water',
              ['C8'] => 'city=revenue:0;border=edge:2,type:water',
              ['C14'] => 'border=edge:1,type:water,cost:20;border=edge:0,type:water,cost:20',
              ['D3'] => 'border=edge:1,type:water',
              ['D5'] => 'border=edge:2,type:water',
              ['D13'] => 'town=revenue:10;path=a:4,b:_0;icon=image:18_co/mine',
              ['D15'] => 'city=revenue:0;border=edge:1,type:water,cost:20',
              ['D17'] => 'town=revenue:0;border=edge:1,type:water;border=edge:2,type:water,cost:20;icon=image:18_co/mine',
              ['D19'] => 'border=edge:1,type:water;border=edge:2,type:water;border=edge:0,type:water,cost:20', 
              ['E6'] => 'town=revenue:0;upgrade=cost:20,terrain:water;icon=image:18_co/mine',
              ['E12'] => 'label=S;city=revenue:20;path=a:1,b:_0',
              ['E20'] => 'path=a:4,b:0,track:future',
              ['E22'] => 'label=C;city=revenue:0;path=a:3,b:_0,track:future;path=a:0,b:_0,track:future;border=edge:0,type:water,cost:20;border=edge:5,type:water',
              ['F5'] => 'town=revenue:0;upgrade=cost:20,terrain:water;icon=image:18_co/mine',
              ['F15'] => 'path=a:4,b:0,track:future',
              ['F17'] => 'city=revenue:0;path=a:3,b:_0,track:future;path=a:0,b:_0,track:future;upgrade=cost:20,terrain:water',
              ['F19'] => 'path=a:1,b:3,track:future;upgrade=cost:20,terrain:water',
              ['F21'] => 'town=revenue:0;border=edge:0,type:water,cost:20;icon=image:18_co/mine',           
              ['G6'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
              ['G8'] => 'path=a:4,b:0,track:future',
              ['G12'] => 'path=a:3,b:0,track:future',
              ['G14'] => 'path=a:1,b:3,track:future;upgrade=cost:20,terrain:water',
              ['G10'] => 'label=C;city=revenue:0;path=a:3,b:_0,track:future;path=a:0,b:_0,track:future',
              ['G20'] => 'border=edge:5,type:water,cost:20',
              ['G22'] => 'town=revenue:0;icon=image:18_co/mine;border=edge:5,type:water;border=edge:4,type:water;border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:20',
              ['H7'] => 'label=K;city=revenue:0;path=a:1,b:_0,track:future;path=a:3,b:_0,track:future',
              ['H17'] => 'border=edge:4,type:water;border=edge:5,type:water,cost:20',
              ['H19'] => 'border=edge:4,type:water,cost:20;border=edge:5,type:water',
          },

          yellow: {
              ['H3'] => 'label=Chi;city=revenue:10,loc:1.5;city=revenue:10,loc:3.5;city=revenue:10,loc:5.5;path=a:4,b:_1;path=a:0,b:_2',
              ['H5'] => 'path=a:3,b:0',
              ['E8'] => 'label=P;city=revenue:20;path=a:3,b:_0;upgrade=cost:20,terrain:water',
          },

          gray: {
              ['D1'] => 'path=a:1,b:5',
              ['D21'] => 'path=a:3,b:0;border=edge:3,type:water,cost:20;border=edge:4,type:water;border=edge:5,type:water',
              ['F1'] => 'path=a:1,b:0',
              ['H21'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;border=edge:0,type:water;border=edge:1,type:water;border=edge:2,type:water,cost:20;border=edge:4,type:water;border=edge:5,type:water',
          },

          red: {
              ['A10'] => 'label=W;offboard=revenue:yellow_20|brown_50,groups:West;path=a:4,b:_0;path=a:5,b:_0;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
              ['B3'] => 'label=W;offboard=revenue:yellow_20|brown_40,groups:West;path=a:4,b:_0;path=a:0,b:_0;border=edge:0;border=edge:4,type:water,cost:20;border=edge:5',
              ['B5'] => 'path=a:3,b:5;border=edge:3;border=edge:4;border=edge:5,type:water,cost:20',
              ['B15'] => 'offboard=revenue:yellow_50|brown_100,groups:STL,hide:1;path=a:4,b:_0,terminal:1;border=edge:5;city=revenue:0,slots:4;border=edge:3,type:water;border=edge:4,type:water,cost:20',
              ['C4'] => 'border=edge:0,type:water;border=edge:1;border=edge:2;border=edge:3,type:water;border=edge:4,type:water;border=edge:5,type:water',
              ['C16'] => 'offboard=revenue:yellow_50|brown_100,groups:STL;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;border=edge:2;border=edge:3,type:water,cost:20;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20;border=edge:1',
              ['E24'] => 'path=a:3,b:5;border=edge:5;border=edge:4;path=a:2,b:5;border=edge:3,type:water,cost:20',
              ['F23'] => 'path=a:3,b:0;path=a:4,b:0;border=edge:0;border=edge:1;border=edge:3,type:water,cost:20;border=edge:2,type:water;border=edge:4,type:water,cost:20;border=edge:5',
              ['F25'] => 'label=S;offboard=revenue:yellow_50|brown_60,groups:South;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:2;border=edge:3;border=edge:4',
              ['G2'] =>  'label=N;offboard=revenue:yellow_20|brown_40,groups:North;path=a:4,b:_0;path=a:5,b:_0',
              ['G24'] => 'path=a:3,b:1;border=edge:1;border=edge:2;border=edge:3,type:water,cost:20',
              ['I6'] => 'city=revenue:yellow_30|brown_40,groups:East;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;border=edge:0',
              ['I8'] => 'label=E;offboard=revenue:yellow_30|brown_40,groups:East,hide:1;path=a:1,b:_0;path=a:2,b:_0;border=edge:3',
              ['I12'] => 'label=E;offboard=revenue:yellow_20|brown_40,groups:East;path=a:1,b:_0;path=a:2,b:_0',
              ['I18'] => 'label=E;offboard=revenue:yellow_20|brown_50,groups:East;path=a:1,b:_0;path=a:2,b:_0;border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            },

        }.freeze
      end
    end
  end
end