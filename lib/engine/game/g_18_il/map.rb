# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Map
        TILES = {
          # yellow
          '1' => 1,
          '2' => 1,
          '3' => 2,
          '4' => 2,
          '7' => 4,
          '8' => 8,
          '9' => 7,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 2,
          '69' => 1,
          # green
          '14' => 3,
          '15' => 2,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '53' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=C',
          },
          '54' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=P',
          },
          '59' => 1,
          # brown
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '61' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:1,b:_0;label=C',
          },
          '62' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:2;city=revenue:80,slots:2;path=a:0,b:_0;'\
                      'path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;label=P',
          },
          '63' => 2,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '70' => 1,

          'LM2' => {
            'count' => 1,
            'color' => 'blue',
            'code' => 'label=LM;junction;path=a:0,b:_0,terminal:1,track:thin;'\
                      'path=a:0,b:_0,track:thin;path=a:1,b:_0,track:thin;path=a:2,b:_0,track:thin;' \
                      'path=a:3,b:_0,track:thin;path=a:4,b:_0,track:thin;path=a:5,b:_0,track:thin;', \
          },
=begin
          '4201' =>
          {  
            'count' => 4,
            'color' => 'yellow',
            'code' => 'path=a:0,b:1; path=a:0,b:5',
          },
         
          '4202' =>
          {  
            'count' => 4,
            'color' => 'brown',
            'code' => 'path=a:0,b:2,a_lane:0.0;path=a:0,b:3,a_lane:0.1;path=a:0, b:4, a_lane:0.2; path=a:0, b:5, a_lane:0.3',
          },
         
          '4203' =>
          {
            'count'=> 4,
            'color'=> 'green',
            'code'=> 'path=a:0, b:1, a_lane: 0.0; path=a:0, b:5, a_lane:0.1',
          }


          '4205' =>
          {
             'count' => 4,
             'color' => gray,
             'code'=> 'path= a:1, b:3; path= a:2, b:4; path= a:0, b:5; path = a:5, b:3',
          }
=end
        }.freeze

        LOCATION_NAMES = {
          'C2' => 'Tabarka',
          'E2' => 'Bizerte',
          'F1' => 'Port of Bizerte',
          'F5' => 'Tunis',
          'G4' => 'Port of Rades',
          'D5' => 'Beja',
          'D3' => 'Mateur',
          'E4' => 'Djedeida',
          'B5' => 'Ghardimaou',
          'B7' => 'La Kef',
          'H5' => 'Nabeul',
          'G8' => 'Sousse',
          'H7' => 'Port of Sousse',
          'C10' => 'Kasserine',
          'D15' => 'Gafsa',
          'B17' => 'Tozeur',
          'G14' => 'Sfax',
          'H15' => 'Port of Sfax',
          'F17' => 'Gabes',
          'G18' => 'Port of Gabes',
          'H9' => 'Mahdia',
          'F9' => 'Kairouan',
          'A6' => 'Souk Ahras, Algeria',
          'A12' => 'Tebessa, Algeria',
          'E12' => 'Sidi Bouzid',
          'C14' => 'Métlaoui',
        }.freeze

        HEXES = {
          blue: {
            ['F1'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:1,b:_0;icon=image:port',
            ['G4'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:1,b:_0;icon=image:port',
            ['H7'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:1,b:_0;icon=image:port',
            ['H15'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:2,b:_0;icon=image:port',
            ['G18'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:2,b:_0;icon=image:port',
          },
          white: {
            %w[C4 C6 C8 C12 C16 B9 B11 B13 B15 D7 D9 D11 D13 E6 E8 E10 E14 E16 F3 F7 F11 F13 F15] => '',
            %w[G6 G10 G12 H11] => '',
            #%w[H11] => 'path=track:future,a:3,b:5;frame=color:#ffa500',
            %w[E14 F13 C4 D3 B9 C8 E8 C10] => 'upgrade=cost:40,terrain:mountain',
            %w[E2 D5 G8 B7 C10 D15 F17 B17] => 'city=revenue:0',
            %w[B5 C2 D3 E4 H9 F9 E12 C14] => 'town=revenue:0',
          },
          yellow: {
            #['F5'] => 'city=revenue:10;path=a:2,b:_0;path=a:4,b:_0;label=C; grid',
            ['G14'] => 'city=revenue:10;path=a:3,b:_0;path=a:5,b:_0;label=C',
            ['F5'] => 'label=O;city=revenue:30;city=revenue:30;city=revenue:30;path=a:2,b:_1;path=a:4,b:_2',
          },

          gray: {
            ['H5'] => 'town=revenue:30;path=a:1,b:_0;'
          },

          red: {
            ['A6'] =>
                     'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0',
            ['A12'] =>
                     'offboard=revenue:yellow_20|brown_50;path=a:4,b:_0;path=a:5,b:_0',

          },


        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
