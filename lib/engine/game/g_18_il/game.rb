# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18IL
      class Game < Game::Base
        include_meta(G18IL::Meta)
        include Entities
        include Map

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 98_000
        
        CAPITALIZATION = :incremental

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        MARKET = [%w[0c 20 22 24 26g 28 30 32 34 36 38 40p 50 60p 67 74 80p 85 90 95 100p 104 208 112 116 120p 122 124 126 129 132 135 139 143 147],
        %w[152 157 163 169 176 183 191 200 208 218 229 241 254 268 283 300 316 334 354 376 400],].freeze

        STOCKMARKET_COLORS = {
            #par: :yellow,
            close: :black,
          }.freeze

          PHASES = [{
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_companies_from_other_players'],
          },
                    {
                      name: '2%',
                      on: "2'",
                      train_limit: 4,
                      tiles: [:yellow],
                      operating_rounds: 2,
                      status: %w[can_buy_companies can_buy_companies_from_other_players],
                    },         
                    {
                      name: '3',
                      on: '3',
                      train_limit: 4,
                      tiles: %i[yellow green],
                      operating_rounds: 2,
                      status: %w[can_buy_companies can_buy_companies_from_other_players],
                    },
                    {
                      name: '4',
                      on: '4',
                      train_limit: 3,
                      tiles: %i[yellow green],
                      operating_rounds: 2,
                      status: %w[can_buy_companies can_buy_companies_from_other_players],
                    },
                    {
                      name: '4+2P',
                      on: '4+2P',
                      train_limit: 2,
                      tiles: %i[yellow green brown],
                      operating_rounds: 2,
                    },
                    {
                      name: '5',
                      on: '5+1P',
                      train_limit: 2,
                      tiles: %i[yellow green brown],
                      operating_rounds: 2,
                    },
                    {
                      name: '6',
                      on: '6',
                      train_limit: 2,
                      tiles: %i[yellow green brown],
                      operating_rounds: 2,
                    },
                    {
                      name: 'D',
                      on: 'D',
                      train_limit: 2,
                      tiles: %i[yellow green brown gray],
                      operating_rounds: 2,
                    }].freeze
  
          TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 99 },
                    { name: '3', distance: 3, price: 160, rusts_on: '6', num: 6 },
                    { name: '4', distance: 4, price: 240, rusts_on: 'D', num: 5,
                    variants: [
                        {
                          name: '3P',
                          price: 320,
                          distance: [{ 'nodes' => %w[city], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                                    {
                                     'nodes' => ['town'],
                                     'pay' => 99,
                                     'visit' => 99,
                                     'multiplier' => 2,
                                   }],
                        },
                      ],
                    },
                    { name: '4+2P',
                      distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                        { 'nodes' => %w[city], 'pay' => 2, 'visit' => 2, 'multiplier' => 2 },
                        { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99}],
                      price: 800, num: 2 },
                    { name: '5+1P',
                      distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                        { 'nodes' => %w[city], 'pay' => 1, 'visit' => 1, 'multiplier' => 2 },
                        { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99}],
                      price: 700, num: 3 },
                    { name: '6', distance: 6, price: 600, num: 4 },
                    { name: 'D', distance: 999, price: 1000, num: 99 },
          ].freeze

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          print "hello"
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G18IL::Step::BuySellParShares,
          ])
        end

        STATUS_TEXT = Base::STATUS_TEXT.merge(
         'can_buy_companies_from_other_players' => ['Interplayer Company Buy',
                                                    'Companies can be bought between players after first stock round'],
       ).freeze

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end

        def num_trains(train)
          return train[:num] unless train[:name] == '6'

          optional_6_train ? 3 : 2
        end

        def optional_6_train
          @optional_rules&.include?(:optional_6_train)
        end
=begin
        def init_stock_market
          print "Hello market"
          StockMarket.new(self.class::MARKET, [], zigzag: true, ledge_movement: true)
        end
=end
      end
    end
  end
end
