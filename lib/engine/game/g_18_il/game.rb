# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
include CitiesPlusTownsRouteDistanceStr
require_relative '../cities_plus_towns_route_distance_str'

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
        SELL_BUY_ORDER = :sell_buy
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '$%s'
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        BANK_CASH = 99_000
        CAPITALIZATION = :incremental
        CERT_LIMIT = { 2 => 22, 3 => 18, 4 => 15, 5 => 13 }.freeze
        STARTING_CASH = { 2 => 540, 3 => 480, 4 => 420, 5 => 360 }.freeze

        POOL_SHARE_DROP = :down_share
        BANKRUPTCY_ALLOWED = false
        CERT_LIMIT_INCLUDES_PRIVATES = false
        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true

        # From 17:
        # Two lays with one being an upgrade, second tile costs 20
        #TILE_COST = 0
        TILE_LAYS = [
          { lay: true, upgrade: true, cost:0},
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        # TODO: verify
        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :always

        # TODO:  first D only
        GAME_END_CHECK = {
          #bankrupt: :immediate,
          #bank: :full_or,
          #all_closed: :immediate,
        }.freeze

      # TODO:  two rules on selling shares
      # when can a share holder sell shares
      # first            -- after first stock round
      # after_sr_floated -- after stock round in which company floated
      # operate          -- after operation
      # full_or_turn     -- after corp completes a full OR turn
      # p_any_operate    -- pres any time, share holders after operation
      # any_time         -- at any time
      # round            -- after the stock round the share was purchased in
      #SELL_AFTER = :operate
      SELL_AFTER = :p_any_operate

      # down_share -- down one row per share
      # down_per_10 -- down one row per 10% sold
      # down_block -- down one row per block
      # left_share -- left one column per share
      # left_share_pres -- left one column per share if president
      # left_block -- one row per block
      # down_block_pres -- down one row per block if president
      # left_block_pres -- left one column per block if president
      # left_per_10_if_pres_else_left_one -- left_share_pres + left_block
      # none -- don't drop price
      SELL_MOVEMENT = :none

      # do shares in the pool drop the price?
      # none, down_block, left_block, down_share
      POOL_SHARE_DROP = :down_share

      # TODO:  depends on share type 2 vs 5 vs 10
      # do sold out shares increase the price?
      SOLD_OUT_INCREASE = true

      # :none -- No movement
      # :down_right -- Moves down and right
      #SOLD_OUT_TOP_ROW_MOVEMENT = :down_right

      # TODO: big time changes here
      #GAME_END_CHECK = { final_phase: :one_more_full_or_set }.freeze

      #MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
      #CLOSED_CORP_TRAINS_REMOVED = false 
      #CLOSED_CORP_TOKENS_REMOVED = false
      #CLOSED_CORP_RESERVATIONS_REMOVED = false
      #commented because issuing/closing/insolvency not implemented yet

      MARKET_SHARE_LIMIT = 100

        MARKET = [
          %w[0c 
            20 
            22 
            24 
            26g 
            28 
            30 
            32 
            34 
            36 
            38 
            40p 
            50 
            60p 
            67 
            74 
            80p 
            85 
            90 
            95 
            100p 
            104 
            108
            112 
            116 
            120p 
            122 
            124 
            126 
            129 
            132 
            135 
            139 
            143 
            147
            152 
            157 
            163 
            169 
            176 
            183 
            191 
            200 
            208 
            218 
            229 
            241 
            254 
            268 
            283 
            300 
            316 
            334 
            354 
            376 
            400],
          ].freeze

        # TODO: Remove empty grey legend
         STOCKMARKET_COLORS = {
            par: :yellow,
            close: :black,
          }.freeze

          PHASES = [
                  {
                    name: '2',
                    train_limit: 4,
                    tiles: [:yellow],
                    operating_rounds: 2
                  },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2
                    
                  },
                  {
                    name: '4+2P',
                    on: '4+2P',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 2
                  },
                  {
                    name: '5',
                    on: '5+1P',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 2
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 2
                  },
                  {
                    name: 'D',
                    on: 'D',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                    operating_rounds: 2,
                  }
                ].freeze

       TRAINS = [
=begin
                    {
                      name: 'Rogers',
                      distance: [
                        { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1 },
                        { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 }
                       ], 
                      price: 0,
                      rusts_on: '3',
                      num: 1
                    },
=end
                    {
                      name: '2',
                      distance: [
                        { 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                        { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }
                       ], 
                      price: 80,
                      rusts_on: '4',
                      num: 99
                    },
                    {
                      name: '3',
                      distance: [
                        { 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                        { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }
                       ], 
                      price: 160,
                      rusts_on: '5+1P',
                      num: 6 
                    },
                    {
                      name: '4',
                      distance: [
                        { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                        { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }
                       ], 
                      price: 240,
                      rusts_on: 'D',
                      num: 5,
                      variants: [
                                 {
                                  name: '3P',
                                  distance: [
                                             { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                                             { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }
                                            ], 
                                  price: 320
                                 },
                                ],
                    },
                    {
                      name: '4+2P',
                      distance: [
                                 { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                                 { 'nodes' => ['city'], 'pay' => 2, 'visit' => 2, 'multiplier' => 2 },
                                 { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }
                                ],
                      price: 800,
                      num: 2
                    },
                    {
                      name: '5+1P',
                      distance: [
                                 { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                                 { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1, 'multiplier' => 2 },
                                 { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }
                                ],
                       price: 700,
                       num: 3    
                    },
                    {
                      name: '6',
                      distance: [
                        { 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                        { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }
                       ], 
                      price: 600,
                      num: 4 
                    },
                    { 
                      name: 'D',
                      distance: 999,
                      price: 1000,
                      num: 99 
                    },
                  ].freeze
          
        def operating_round(round_num)
          Round::Operating.new(self, [
            #Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            #trade_assets here,
            G18IL::Step::Convert,
            Engine::Step::IssueShares,
            # and/or buy a share into the reserve
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18IL::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def trade_assets
         #@log << "#{current_entity.name} skips Trade Assets."
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

        def or_round_finished
          return if @depot.upcoming.empty?

          if @depot.upcoming.first.name == '2'
            depot.export_all!('2')
            phase.next!
          else
            depot.export!
          end
        end


        def init_stock_market
          print "Hello market"
          StockMarket.new(self.class::MARKET, [], zigzag: :flip)
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend = 0', '1 ←'],
            ['Dividend < 1/2 stock price', '1 ⤪'],
            ['Dividend ≥ 1/2 stock price but < stock price', '1 ⤨'],
            ['Dividend ≥ stock price', '1 →'],
            ['Dividend ≥ 2X stock price', '2 →'],
            ['Dividend ≥ 3X stock price', '3 →'],
            ['Voluntary Issue','Full Amount, then 1 ←'],
            ['Emergency Issue','Half Amount, then ⤪ for each'],
           # ['Corporation director sells any number of shares', '1 ←'],
            ['Corporation is sold out at end of an SR', '1 ⤨ (5 share) or 1 → (10 share)'],
            ['Corporation has any shares in the Market at end of an SR', '⤪ for each'],
          ]
        end


        def revenue_for(route, stops)
          revenue = super
      
          revenue += EW_NS_bonus(stops)[:revenue]
      
          revenue
      end
      
      def EW_NS_bonus(stops)
          bonus = { revenue: 0 }
      
          east = stops.find { |stop| stop.groups.include?('West') }
          west = stops.find { |stop| stop.groups.include?('East') }
          north = stops.find { |stop| stop.groups.include?('North') }
          south = stops.find { |stop| stop.groups.include?('South') }
      
          if east && west
            bonus[:revenue] = 80
            bonus[:description] = 'E/W'
          end
      
          if north && south
            bonus[:revenue] = 100
            bonus[:description] = 'N/S'
          end
      
          bonus
      end
=begin
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
=end

      end
    end
  end
end

=begin
def share_price_change(entity, revenue = 0)
  print "Dividends"
  #return {} if entity.minor?
  price = entity.share_price.price
  print revenue, price
  return { share_direction: :left, share_times: 2 } if revenue == 0
  return { share_direction: :left, share_times: 1 } if revenue < price / 2
  return { share_direction: :right, share_times: 1 } if revenue < price

  times = 0
  times = 1 if revenue >= price
  times = 2 if revenue >= price * 2
  times = 3 if revenue >= price * 3 
  if times.positive?
    { share_direction: :right, share_times: times }
  else
    {}
  end
end
=end
