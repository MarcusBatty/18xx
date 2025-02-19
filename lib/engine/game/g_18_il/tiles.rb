# frozen_string_literal: true

module Engine
  module Game
    module G18IL
      module Tiles
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
          '58' => 9,
          '80' => 5,
          '81' => 5,
          '82' => 8,
          '83' => 8,
          '544' => 4,
          '545' => 4,
          '546' => 4,
          '611' => 6,
          '619' => 6,

          # YELLOW
          'G1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=G',
          },

          'S1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:1,b:_0;path=a:3,b:_0;label=S',
          },

          'C11' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:1,b:_0;path=a:0,b:_0;label=C',
          },

          'C12' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:2,b:_0;path=a:0,b:_0;label=C',
          },

          'C13' =>
          {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:3,b:_0;path=a:0,b:_0;label=C',
          },

          'K11' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:1,b:_0;path=a:0,b:_0;label=K',
          },

          'K12' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:2,b:_0;path=a:0,b:_0;label=K',
          },

          'K13' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:3,b:_0;path=a:0,b:_0;label=K',
          },

          # GREEN
          'P2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=P',
          },

          'S2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
          },

          'J1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=J',
          },

          'CHI2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=Chi;city=revenue:40,loc:1.5;city=revenue:40,loc:3.5;city=revenue:40,'\
                      'loc:5.5;path=a:1,b:_0;path=a:4,b:_1;path=a:0,b:_2',
          },

          'C21' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;label=C',
          },

          'C22' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=C',
          },

          'K22' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=K',
          },

          'K21' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=K',
          },

          # BROWN
          'P3' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=P',
          },

          'S3' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
          },

          'CHI3' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0;label=Chi',
          },

          'C31' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:0,b:_0;label=C',
          },

          'C32' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=C',
          },

          'K3' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0;path=a:2,b:_0;label=K',
          },

          # GRAY
          'P4' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:4,blocks_lay:1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,'\
                      'b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=P',
          },

          'S4' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:4,blocks_lay:1;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
          },

          'CHI4' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0;label=Chi',
          },

          'M1' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },

          'X17a' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },

          # BLUE
          'POM' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'halt=revenue:30,symbol:30;path=a:3,b:_0;path=a:5,b:_0;icon=image:18_il/port,blocks_lay:true',
          },

          'SPH' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'halt=revenue:50,symbol:50;path=a:5,b:_0;icon=image:18_il/port,blocks_lay:true',
          },
        }.freeze
      end
    end
  end
end
