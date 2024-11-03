# frozen_string_literal: true

module Engine
    module Game
      module G18IL
        module Phases

          STATUS_TEXT = Base::STATUS_TEXT.merge(
            'pullman_strike' => [
              'Pullman Strike',
              '4+2P downgrades to 4; 5+1P downgrades to 5'
            ],
          ).freeze

            PHASES = [
                {
                  name: '2',
                  train_limit: 4,
                  tiles: [:yellow],
                  status: ['can_buy_companies'],
                  operating_rounds: 2
                },
                {
                  name: '3',
                  on: '3',
                  train_limit: 4,
                  tiles: %i[yellow green],
                  status: ['can_buy_companies'],
                  operating_rounds: 2,
                },
                {
                  name: '4',
                  on: '4',
                  train_limit: 3,
                  tiles: %i[yellow green],
                  status: ['can_buy_companies'],
                  operating_rounds: 2
                },
                {
                  name: '4+2P',
                  on: '4+2P',
                  train_limit: 2,
                  tiles: %i[yellow green brown],
                  status: ['can_buy_companies'],
                  operating_rounds: 2
                },
                {
                  name: '5',
                  on: '5+1P',
                  train_limit: 2,
                  tiles: %i[yellow green brown],
                  status: ['can_buy_companies'],
                  operating_rounds: 2
                },
                {
                  name: '6',
                  on: '6',
                  train_limit: 2,
                  tiles: %i[yellow green brown],
                  status: ['can_buy_companies'],
                  operating_rounds: 2
                },
                {
                  name: 'D',
                  on: 'D',
                  train_limit: 2,
                  tiles: %i[yellow green brown gray],
                  status: ['can_buy_companies'],
                  operating_rounds: 2
                }
              ].freeze
        end
      end
    end
end