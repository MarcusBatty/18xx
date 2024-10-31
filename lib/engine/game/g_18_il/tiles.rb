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
                'code' => 'city=revenue:20;path=a:1,b:_0;path=a:3,b:_0;label=S',
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
                'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=S',
              },
    
              'IL62' =>
              {
                'count' => 1,
                'color' => 'green',
                'code' => 'label=Chi;city=revenue:40,loc:1.5;city=revenue:40,loc:3.5;city=revenue:40,loc:5.5;path=a:1,b:_0;path=a:4,b:_1;path=a:0,b:_2',
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
                'city=revenue:40,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=P',
              },
    
              'IL71' => 
              {
                'count' => 1,
                'color' => 'brown',
                'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
              },
    
              'IL72' => 
              {
                'count' => 1,
                'color' => 'brown',
                'code' => 'city=revenue:70,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0;label=Chi',
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
                'city=revenue:50,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=S',
              },
    
              'IL82' => 
              {
                'count' => 1,
                'color' => 'gray',
                'code' =>
                'city=revenue:100,slots:4;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0;label=Chi',
              },
    
              #BLUE
              'POM' =>
              {
                'count' => 1,
                'color' => 'blue',
                'code' => 'town=revenue:30;path=a:3,b:_0;path=a:5,b:_0;icon=image:port,blocks_lay:true',
              },
    
              'SPH' =>
              {
                'count' => 1,
                'color' => 'blue',
                'code' => 'town=revenue:50;path=a:5,b:_0;icon=image:port,blocks_lay:true',                       
              },
            }.freeze
        end
      end
    end
end
