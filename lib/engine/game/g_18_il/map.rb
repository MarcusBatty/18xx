# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Map

        LAYOUT = :pointy
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
          '593' => 'unlimited',
          '611' => 6,
          '619' => 6,
          'X00' =>
          {
            'count' => 0,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },

          'IL1' => 
          {
            'count' => 9,
            'color' => 'yellow',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:2;icon=image:18_co/mine',
          },

          'IL2' => 
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:6,b:_0;icon=image:18_co/mine;label=G',
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
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:6,b:_0;path=a:3,b:_0,track:future;label=C',
          },

          'IL12' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:2,b:_0;path=a:6,b:_0;path=a:3,b:_0,track:future;label=C',
          },

          'IL13' => 
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:3,b:_0;path=a:6,b:_0;label=C',
          },

          'IL14' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:4,b:_0;path=a:6,b:_0;path=a:3,b:_0,track:future;label=C',
          },

          'IL15' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:5,b:_0;path=a:6,b:_0;path=a:3,b:_0,track:future;label=C',
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
            'code' => 'path=a:1,b:6;path=a:4,b:6,track:future',
          },

          'IL22' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:2,b:6;path=a:4,b:6,track:future',
          },

          'IL23' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:3,b:6;path=a:4,b:6,track:future',
          },

          'IL24' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:5,b:6;path=a:4,b:6,track:future',
          },

          'IL25' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:1,b:6;path=a:2,b:6,track:future',
          },
          
          'IL26' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:3,b:6;path=a:2,b:6,track:future',
          },

          'IL27' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:4,b:6;path=a:2,b:6,track:future',
          },

          'IL28' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:5,b:6;path=a:2,b:6,track:future',
          },

          'IL29' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:1,b:6;path=a:3,b:6,track:future',
          },
          
          'IL30' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:2,b:6;path=a:3,b:6,track:future',
          },

          'IL31' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:4,b:6;path=a:3,b:6,track:future',
          },

          'IL32' => 
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'path=a:5,b:6;path=a:3,b:6,track:future',
          },
=begin
          'IL50' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=revenue:30;path=a:3,b:_0,track:thin;path=a:5,b:_0,track:thin;label=Memphis;icon=image:port',
          },
=end

          'IL50' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'offboard=revenue:30;path=a:3,b:5,track:thin;label=Memphis;icon=image:port',
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
            'code' => 'city=revenue:40;city=revenue:40;city=revenue:40;label=Chi;path=a:6,b:_0;path=a:2,b:_1;path=a:4,b:_2',
          },

          'IL63' => 
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:6,b:_0;label=C',
          },

          'IL64' => 
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:3,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=C',
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
            'city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:6,b:_0;path=a:4,b:_0,track:future;label=Chi',
          },

          'IL73' => 
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:6,b:_0;label=C',
          },

          'IL74' => 
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:3,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=C',
          },

          'IL75' => 
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:6,b:_0;label=K',
          },

          'IL80' => 
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:6,b:_0;label=P',
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
            'city=revenue:100,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:6,b:_0;path=a:4,b:_0,track:future;label=Chi',
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
          'D21' => 'to Memphis',
        }.freeze

        HEXES = {
          blue: {

          # from PNW
          # %w[D9] => 'junction;path=a:4,b:_0,terminal:1;path=a:0,b:4,track:thin;icon=image:anchor',

            ['B1'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:5,b:_0',
            ['H1'] => 'offboard=revenue:20,groups:port;path=a:1,b:5,track:thin;border=edge:5;path=a:1,b:_0',
            ['I2'] => 'offboard=revenue:yellow_0,groups:port;path=a:1,b:2,track:thin;icon=image:port;border=edge:6;border=edge:2;'\
                      'path=a:1,b:_0',
            ['I4'] => 'offboard=revenue:yellow_0,groups:port,route:never;border=edge:3',
            ['D23'] => 'offboard=revenue:0,groups:port,route:never;path=a:3,b:_0;path=a:5,b:_0 ',
          },
          white: {
            %w[D3 D5 D7 E4 F7 H9 H13 H15 G18 C10 C12 C14 E10 D11 E18 E16 G20] => '',
            %w[F3 E2 G4 F9 F11 D15 G16] => 'city=revenue:0',
            %w[D9 H11 E14 F13] => 'town=revenue:0;icon=image:18_co/mine',
            ['H7'] => 'label=K;city=revenue:0;path=a:1,b:_0,track:future;path=a:3,b:_0,track:future',
            #['E22'] => 'label=C;city=revenue:0;path=a:3,b:6;border=edge:6,type:water,cost:20',
            ['E22'] => 'label=C;city=revenue:0;path=a:3,b:6,track:future',
            ['E12'] => 'label=Spi;city=revenue:20;path=a:1,b:_0',
            ['D13'] => 'town=revenue:10;path=a:4,b:_0;icon=image:18_co/mine',
            ['G10'] => 'label=C;city=revenue:0;path=a:3,b:6,track:future',


           # ['C2'] => 'label=G;town=revenue:0;upgrade=cost:60,terrain:mountain;icon=image:18_co/mine;border=edge:1,type:water,cost:20;'\
            #           'border=edge:6,type:water,cost:20',
            ['C2'] => 'label=G;town=revenue:0;upgrade=cost:60,terrain:mountain;icon=image:18_co/mine;border=edge:1,type:water,cost:40',

            ['C6'] => 'city=revenue:0;border=edge:1,type:water;border=edge:2,cost:20,type:water;border=edge:3,type:water',
            ['C8'] => 'city=revenue:0;border=edge:2,type:water',
            ['E6'] => 'town=revenue:0;upgrade=cost:20,terrain:water;icon=image:18_co/mine',
            ['F5'] => 'town=revenue:0;upgrade=cost:20,terrain:water;icon=image:18_co/mine',
            ['G6'] => 'city=revenue:0;upgrade=cost:20,terrain:water',
            ['B9'] => 'border=edge:1,type:water,cost:20;border=edge:2,type:water;border=edge:3,type:water',  
            ['B11'] => 'city=revenue:0;border=edge:2,type:water,cost:20;border=edge:1,type:water',
            ['B13'] =>  'border=edge:1,type:water;border=edge:2,type:water',
            ['D17'] => 'town=revenue:0;border=edge:1,type:water;icon=image:18_co/mine',
            ['D19'] => 'border=edge:1,type:water;border=edge:2,type:water', 
            ['G22'] => 'town=revenue:0;icon=image:18_co/mine;border=edge:5,type:water;border=edge:4,type:water',
            ['G20'] => 'border=edge:5,type:water,cost:20',
            ['H19'] =>  'border=edge:4,type:water,cost:20;border=edge:5,type:water',
            ['H17'] =>  'border=edge:4,type:water',
            ['G8'] => 'path=a:4,b:6,track:future',
            ['G12'] => 'path=a:3,b:6,track:future',
            ['G14'] => 'path=a:1,b:3,track:future;upgrade=cost:20,terrain:water',
            ['F15'] => 'path=a:4,b:6,track:future',
            ['F19'] => 'path=a:1,b:3,track:future;upgrade=cost:20,terrain:water',
            ['E20'] => 'path=a:4,b:6,track:future',
            ['F17'] => 'city=revenue:0;path=a:3,b:6,track:future;upgrade=cost:20,terrain:water',
            #['C14'] => 'border=edge:1,type:water,cost:20;border=edge:6,type:water,cost:20',
            ['F21'] => 'town=revenue:0;icon=image:18_co/mine',
          },
          yellow: {
            ['H5'] => 'path=a:3,b:6',
            #['H3'] => 'label=CHI;city=revenue:10;city=revenue:10;city=revenue:10;path=a:6,b:_1;path=a:4,b:_2',
            ['H3'] => 'label=CHI;city=revenue:10;city=revenue:10;city=revenue:10;path=a:2,b:_0;path=a:6,b:_1;path=a:4,b:_2',
            ['E8'] => 'label=P;city=revenue:20;path=a:3,b:_0;upgrade=cost:20,terrain:water',

          },

          gray: {
            ['B15'] => 'path=a:4,b:5;border=edge:3,type:water;border=edge:4,type:water,cost:20',

            ['B5'] => 'path=a:3,b:5;border=edge:5,type:water,cost:20',
            ['D1'] => 'path=a:1,b:5',
            ['F1'] => 'path=a:1,b:6',

            ['C4'] => 'path=a:2,b:3;border=edge:4,type:water;border=edge:5,type:water',
            
            ['D21'] => 'path=a:3,b:6,track:thin;border=edge:3,type:water,cost:20;border=edge:4,type:water;border=edge:5,type:water',
          #  ['H21'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;border=edge:2,type:water,cost:20;border=edge:1,type:water;'\
           #           'border=edge:4,type:water;border=edge:5,type:water;border=edge:6,type:water',

             ['H21'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;border=edge:2,type:water,cost:20;border=edge:1,type:water;'\
                        'border=edge:4,type:water;border=edge:5,type:water',
                        # 'border=edge:2,type:water,cost:20;border=edge:1,type:water;border=edge:4,type:water;border=edge:5,type:water;border=edge:6,type:water',
          },

          red: {
            ['B3'] =>
                    'label=W;offboard=revenue:yellow_20|brown_40;path=a:4,b:_0;path=a:5,b:_0;path=a:6,b:_0;'\
                    'border=edge:4,type:water,cost:40',

            ['C16'] => 
                      'label=W;offboard=revenue:yellow_50|brown_100,groups:StLouis;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'border=edge:3,type:water,cost:20;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20;'\
                      'border=edge:1',
            ['B17'] =>
                      'offboard=revenue:yellow_50|brown_100,groups:StLouis,hide:1;'\
                      'city=revenue:0,slots:4;border=edge:4',
            ['A10'] =>
                     'label=W;offboard=revenue:yellow_20|brown_50;path=a:4,b:_0;path=a:5,b:_0;'\
                     'border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20',
            ['I18'] =>
                     'label=E;offboard=revenue:yellow_20|brown_50,groups:East;path=a:1,b:_0;path=a:2,b:_0;'\
                     'border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20',
            ['I12'] =>
                     'label=E;offboard=revenue:yellow_20|brown_40,groups:East;path=a:1,b:_0;path=a:2,b:_0',
            ['I6'] =>
                     'city=revenue:yellow_30|brown_40,groups:East;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;border=edge:6',
            ['I8'] =>
                    'label=E;offboard=revenue:yellow_30|brown_40,groups:East,hide:1;path=a:1,b:_0;path=a:2,b:_0;border=edge:3',
            ['F25'] =>
                     'label=S;offboard=revenue:yellow_50|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                     'border=edge:2;border=edge:3;border=edge:4',
            ['G2'] =>
                     'label=N;offboard=revenue:yellow_20|brown_40;path=a:4,b:_0;path=a:5,b:_0',
            ['E24'] =>
                     'path=a:3,b:5;border=edge:5;border=edge:4;path=a:2,b:5,track:thin;border=edge:3,type:water,cost:20',
            ['G24'] =>
                     'path=a:3,b:1;border=edge:1;border=edge:2;border=edge:3,type:water,cost:20',
            ['F23'] =>
                     'path=a:3,b:0;border=edge:6;border=edge:1;border=edge:5;border=edge:3,type:water,cost:20;'\
                     'border=edge:2,type:water;border=edge:4,type:water',
          },

        }.freeze

        LAYOUT = :flat

      end
    end
  end
end
