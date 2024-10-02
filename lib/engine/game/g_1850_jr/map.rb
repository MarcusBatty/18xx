# frozen_string_literal: true

module Engine
  module Game
    module G1850Jr
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
          'D11' => 'Kasserine',
          'D15' => 'Gafsa',
          'B15' => 'Tozeur',
          'G14' => 'Sfax',
          'H15' => 'Port of Sfax',
          'E18' => 'Gabes',
          'F19' => 'Port of Gabes',
          'H9' => 'Mahdia',
          'F9' => 'Kairouan',
        }.freeze

        HEXES = {
          blue: {
            ['F1'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:0,b:_0;icon=image:port',
            ['G4'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:1,b:_0;icon=image:port',
            ['H7'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:2,b:_0;icon=image:port',
            ['H15'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:2,b:_0;icon=image:port',
            ['F19'] => 'offboard=revenue:yellow_0,groups:port,route:never;path=a:2,b:_0;icon=image:port',
          },
          white: {
            %w[C4 C6 C8 C10 C12 C14 C16 B9 B11 B13 D7 D9 D13 E6 E8 E10 E12 E14 E16 F3 F7 F11 F13 F15] => '',
            %w[G2 G6 G10 G12 G16 H3 H11 H13] => '',
            %w[C5 D4 F4 G7] => 'upgrade=cost:120,terrain:mountain',
            %w[E2 D5 F5 H5 G8 B7 D11 G14 D16 B15 E18] => 'city=revenue:0',
            %w[C2 D3 E4 H9 F9 ] => 'town=revenue:0;upgrade=cost:120,terrain:mountain',
            ['G3'] => 'upgrade=cost:120,terrain:mountain;border=edge:0,type:impassable',
            ['C3'] => 'town=revenue:0;town=revenue:0;border=edge:3,type:impassable',
            ['E5'] => 'city=revenue:0;upgrade=cost:120,terrain:mountain',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
