# frozen_string_literal: true

module Engine
    module Game
      module G18IL
        module Trains
           TRAINS = [
            {
            name: 'Rogers (1+1)',
            distance: [
                { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1 },
                { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 }
                ],
            price: 0,
            num: 1
            },

            {
            name: '2',
            distance: [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                        { 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 }],
            price: 80,
            rusts_on: '4',
            num: 99
            },
            {
            name: '3',
            distance: [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                        { 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 }],
            price: 160,
            rusts_on: '5+1P',
            num: 6
            },
            {
            name: '4',
            distance: [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                        { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 }],
            price: 240,
            rusts_on: 'D',
            num: 5,
            variants: [{name: '3P',
                        distance: [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                                    { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 }],
                        price: 320 }],
            },
            {
            name: '4+2P',
            distance: [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                        { 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 }],
            price: 800,
            num: 2
            },
            {
            name: '5+1P',
            distance: [{  'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                        { 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 }],
                price: 700,
                num: 3,
            },
            {
            name: '6',
            distance: [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                        { 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 }],
            price: 600,
            num: 4
            },
            { name: 'D', distance: 999, price: 1000, num: 9,
              events: [{ 'type' => 'signal_end_game' }],},
            ].freeze
        end
      end
    end
end
