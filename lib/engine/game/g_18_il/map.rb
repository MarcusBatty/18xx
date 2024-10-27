# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Map

        LAYOUT = :flat
        TILE_TYPE = :lawson

        TILES = {
          '5' => 4,
          '6' => 4,
          '7' => 5,
          '8' => 12,
          '9' => 12,
          '14' => 6,
          '15' => 6,
          '57' => 4,
          '80' => 5,
          '81' => 5,
          '82' => 8,
          '83' => 8,
          '544' => 4,
          '545' => 4,
          '546' => 4,
          '611' => 6,
          '619' => 6,
          'IL1' => 
          {
            'count' => 9,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;icon=image:18_co/mine',
          },

          'IL2' => 
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;icon=image:18_co/mine;label=G',
          },
          
          'IL3' => 
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:3,b:_0;label=Spi',
          },

          'IL11' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:0,b:_0;path=a:3,b:_0,track:future;label=C',
          },

          'IL12' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:2,b:_0;path=a:0,b:_0;path=a:3,b:_0,track:future;label=C',
          },

          'IL13' => 
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:3,b:_0;path=a:0,b:_0;label=C',
          },

          'IL14' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:4,b:_0;path=a:0,b:_0;path=a:3,b:_0,track:future;label=C',
          },

          'IL15' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:5,b:_0;path=a:0,b:_0;path=a:3,b:_0,track:future;label=C',
          },


          'IL16' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:1,b:_0;path=a:3,b:_0;label=K',
          },

          'IL17' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:1,b:_0;path=a:4,b:_0;path=a:3,b:_0,track:future;label=K',
          },

          'IL18' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:3,b:_0;path=a:4,b:_0;path=a:1,b:_0,track:future;label=K',
          },

          'IL21' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:1,b:0;path=a:4,b:0,track:future',
          },

          'IL22' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:2,b:0;path=a:4,b:0,track:future',
          },

          'IL23' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:3,b:0;path=a:4,b:0,track:future',
          },

          'IL24' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:5,b:0;path=a:4,b:0,track:future',
          },

          'IL25' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:1,b:0;path=a:2,b:0,track:future',
          },
          
          'IL26' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:3,b:0;path=a:2,b:0,track:future',
          },

          'IL27' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:4,b:0;path=a:2,b:0,track:future',
          },

          'IL28' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:5,b:0;path=a:2,b:0,track:future',
          },

          'IL29' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:1,b:0;path=a:3,b:0,track:future',
          },
          
          'IL30' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:2,b:0;path=a:3,b:0,track:future',
          },

          'IL31' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:4,b:0;path=a:3,b:0,track:future',
          },

          'IL32' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:5,b:0;path=a:3,b:0,track:future',
          },
=begin
          'IL50' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0;label=Memphis;icon=image:port',
          },
=end

          'IL50' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'offboard=revenue:30;path=a:3,b:5;label=Memphis;icon=image:port',
          },

          'IL51' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'offboard=revenue:50;path=a:5,b:_0;label=StPaul;icon=image:port',
          },

          'IL60' => 
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=P',
          },

          'IL61' => 
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Spi',
          },

          'IL62' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CHI;city=revenue:40,loc:1.5;city=revenue:40,loc:3.5;city=revenue:40,loc:5.5;path=a:1,b:_0;path=a:4,b:_1;path=a:0,b:_2',
          },
          
          'IL63' => 
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;label=C',
          },

          'IL64' => 
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=C',
          },

          'IL65' => 
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },

          # BROWN
          'IL70' => 
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=P',
          },

          'IL71' => 
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Spi',
          },

          'IL72' => 
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0,track:future;label=Chi',
          },

          'IL73' => 
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;label=C',
          },

          'IL74' => 
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=C',
          },

          'IL75' => 
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0;label=K',
          },

          'IL80' => 
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=P',
          },

          'IL81' => 
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:50,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Spi',
          },

          'IL82' => 
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0,track:future;label=Chi',
          },

        }.freeze

        LOCATION_NAMES = {
          'F3' => 'Rockford',
          'G4' => 'Aurora',
          'G6' => 'Joliet',
          'H7' => 'Kankakee',
          'F9' => 'Bloomington',
          'G10' => 'Champaign',
          'F11' => 'Decatur',
          'C6' => 'Rock Island',
          'E6' => 'Bureau Junction',
          'F5' => 'Ottawa',
          'C8' => 'Galesburg',
          'B11' => 'Quincy',
          'C2' => 'Galena',
          'E2' => 'Freeport',
          'H11' => 'Danville',
          'F13' => 'Pana',
          'E12' => 'Springfield',
          'D9' => 'Canton',
          'E8' => 'Peoria',
          'D13' => 'Jacksonville',
          'G16' => 'Effingham',
          'F17' => 'Centralia',
          'D17' => 'Belleville',
          'E22' => 'Cairo',
          'F21' => 'Marion',
          'G22' => 'Harrisburg',
          'E14' => 'Virden',
          'D15' => 'Alton',
          'H3' => 'Chicago',
          'C16'=> 'St Louis',
          'H21' => 'Evansville',
          'B3' => 'Sioux City +80 E/W', 
          'A10' => 'Omaha +80 E/W',
          'I18' => 'Louisville',
          'I12' => 'Indianapolis',
          'I6' => 'Detroit',
          'F25' => 'New Orleans',
          'G2' => 'Milwaukee +100 N/S',
          'I2' => 'Lake Michigan',
        }.freeze

        HEXES = {

          blue: {
              ['B1'] => 'offboard=revenue:yellow_0,groups:port;path=a:5,b:_0,',
              ['D21'] => 'path=a:3,b:0;border=edge:3,type:water,cost:20;border=edge:4,type:water;border=edge:5,type:water',
              ['D23'] => 'offboard=revenue:yellow_0,groups:port;path=a:3,b:_0',
              ['H1'] => 'town=revenue:20,groups:port;path=a:1,b:_0;path=a:5,b:_0;border=edge:5;icon=image:port',
              ['I2'] => 'offboard=revenue:yellow_0,groups:port;path=a:1,b:2;border=edge:0;border=edge:2',
              ['I4'] => 'offboard=revenue:yellow_0,groups:port;border=edge:3',
          },

          white: {
            %w[C10 C12 D7 D11 E4 E10 E16 E18 F7 G18 H9 H13 H15] => '',
            %w[E2 F3 F9 F11 G4 G16] => 'city=revenue:0',
            %w[D9 E14 F13 H11] => 'town=revenue:0;icon=image:18_co/mine',

              ['B9'] => 'border=edge:1,type:water,cost:20;border=edge:2,type:water;border=edge:3,type:water',  
              ['B11'] => 'city=revenue:0;border=edge:1,type:water;border=edge:2,type:water,cost:20',
              ['B13'] => 'border=edge:0,type:water;border=edge:1,type:water;border=edge:2,type:water',
              ['C2'] => 'label=G;town=revenue:0;upgrade=cost:60,terrain:mountain;icon=image:18_co/mine;border=edge:1,type:water,cost:20;border=edge:2,type:water',
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
              ['E12'] => 'label=Spi;city=revenue:20;path=a:1,b:_0',
              ['E20'] => 'path=a:4,b:0,track:future',
              ['E22'] => 'label=C;city=revenue:0;path=a:3,b:_0,track:future;path=a:0,b:_0,track:future;border=edge:0,type:water,cost:20;border=edge:1,type:water;border=edge:2,type:water;border=edge:5,type:water',
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
              ['G22'] => 'town=revenue:0;icon=image:18_co/mine;border=edge:5,type:water;border=edge:4,type:water;border=edge:0,type:water,cost:20;border=edge:1,type:water',
              ['H7'] => 'label=K;city=revenue:0;path=a:1,b:_0,track:future;path=a:3,b:_0,track:future',
              ['H17'] => 'border=edge:4,type:water;border=edge:5,type:water,cost:20',
              ['H19'] => 'border=edge:4,type:water,cost:20;border=edge:5,type:water',
          },

          yellow: {
              ['H3'] => 'label=CHI;city=revenue:10,loc:1.5;city=revenue:10,loc:3.5;city=revenue:10,loc:5.5;path=a:4,b:_1;path=a:0,b:_2',
              ['H5'] => 'path=a:3,b:0',
              ['E8'] => 'label=P;city=revenue:20;path=a:3,b:_0;upgrade=cost:20,terrain:water',
          },

          gray: {
              ['B5'] => 'path=a:3,b:5;border=edge:4;border=edge:5,type:water,cost:20',
              ['B15'] => 'path=a:4,b:5;border=edge:3,type:water;border=edge:4,type:water,cost:20',
              ['C4'] => 'border=edge:0,type:water;border=edge:1;border=edge:3,type:water;border=edge:4,type:water;border=edge:5,type:water',
              ['D1'] => 'path=a:1,b:5',
              ['F1'] => 'path=a:1,b:0',
              ['H21'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;border=edge:0,type:water;border=edge:1,type:water;border=edge:2,type:water,cost:20;border=edge:4,type:water;border=edge:5,type:water',
          },

          red: {
              ['A10'] => 'label=W;offboard=revenue:yellow_20|brown_50,groups:West;path=a:4,b:_0;path=a:5,b:_0;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
              ['B3'] => 'label=W;offboard=revenue:yellow_20|brown_40,groups:West;path=a:4,b:_0;path=a:0,b:_0;border=edge:4,type:water,cost:20',
              ['B17'] => 'offboard=revenue:yellow_0,groups:StLouis,hide:1;city=revenue:0;city=revenue:0;city=revenue:0;city=revenue:0;border=edge:4',
              ['C16'] => 'offboard=revenue:yellow_50|brown_100,groups:StLouis;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;border=edge:3,type:water,cost:20;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20;border=edge:1',
              ['E24'] => 'path=a:3,b:5;border=edge:5;border=edge:4;path=a:2,b:5;border=edge:3,type:water,cost:20',
              ['F23'] => 'path=a:3,b:0;border=edge:0;border=edge:1;border=edge:5;border=edge:3,type:water,cost:20;border=edge:2,type:water;border=edge:4,type:water',
              ['F25'] => 'label=S;offboard=revenue:yellow_50|brown_60,groups:South;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;border=edge:2;border=edge:3;border=edge:4',
              ['G2'] =>  'label=N;offboard=revenue:yellow_20|brown_40,groups:North;path=a:4,b:_0;path=a:5,b:_0',
              ['G24'] => 'path=a:3,b:1;border=edge:1;border=edge:2;border=edge:3,type:water,cost:20',
              ['I6'] => 'city=revenue:yellow_30|brown_40,groups:East;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;border=edge:0',
              ['I8'] => 'label=E;offboard=revenue:yellow_30|brown_40,groups:East,hide:1;path=a:1,b:_0;path=a:2,b:_0;border=edge:3',
              ['I12'] => 'label=E;offboard=revenue:yellow_20|brown_40,groups:East;path=a:1,b:_0;path=a:2,b:_0',
              ['I18'] => 'label=E;offboard=revenue:yellow_20|brown_50,groups:East;path=a:1,b:_0;path=a:2,b:_0;border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            },

        }.freeze

        LAYOUT = :flat

      end
    end
  end
end