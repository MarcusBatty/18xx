# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
require_relative '../cities_plus_towns_route_distance_str'
require_relative 'step/buy_tokens'
require_relative 'step/token'


module Engine
  module Game
    module G18IL
      class Game < Game::Base
        include_meta(G18IL::Meta)
        include Entities
        include Map
        include CitiesPlusTownsRouteDistanceStr

        attr_accessor :STL_nodes

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
        STARTING_CASH = { 2 => 10000, 3 => 480, 4 => 420, 5 => 360 }.freeze

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
      SOLD_OUT_TOP_ROW_MOVEMENT = :down_right

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
                    status: ['can_buy_companies'],
                    operating_rounds: 2
                  },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    status: ['can_buy_companies'],
                    operating_rounds: 2
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

          TRAINS = [

                  {
                    name: 'Rogers (1+1)',
                    distance: [
                      { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1 },
                      { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 }
                      ], 
                    price: 0,
                  #  abilities: [{ type: 'close', on_phase: '3' }],
                    num: 1
                  },

                  {
                    name: '2',
                    distance: [{ 'nodes' => %w[halt town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 }], 
                    price: 80,
                    rusts_on: '4',
                    num: 99
                  },
                  {
                    name: '3',
                    distance: [{ 'nodes' => %w[halt town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 }], 
                    price: 160,
                    rusts_on: '5+1P',
                    num: 6 
                  },
                  {
                    name: '4',
                    distance: [{ 'nodes' => %w[halt town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 }], 
                    price: 240,
                    rusts_on: 'D',
                    num: 5,
                    variants: [{name: '3P',
                                distance: [{ 'nodes' => %w[halt town], 'pay' => 99, 'visit' => 99 },
                                            { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 }], 
                                price: 320 },],
                  },
                  {
                    name: '4+2P',
                    distance: [{ 'nodes' => %w[halt town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 }],
                    price: 800,
                    num: 2
                  },
                  {
                    name: '5+1P',
                    distance: [{  'nodes' => %w[halt town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 }],
                      price: 700,
                      num: 3    
                  },
                  {
                    name: '6',
                    distance: [{ 'nodes' => %w[halt town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 }], 
                    price: 600,
                    num: 4 
                  },
                  { name: 'D', distance: 999, price: 1000, num: 99 },
                          ].freeze
                                                                
        PORT_HEXES = %w[B1 D23 H1 I2]
        MINE_HEXES = %w[C2 D9 D13 D17 E6 E14 F5 F13 F21 G22 H11]
        DETROIT = ['I6']
        CLASS_A_COMPANIES = %w[]
        CLASS_B_COMPANIES = %w[]
        PORT_TILES = %w[SPH POM]
        STL_HEXES = %w[B15 C16]
        STL_TOKEN_HEXES = %w[B15]

        def nc
          @nc ||= corporation_by_id('NC')
        end

        def setup
          # Northern Cross comes with the 'Rogers' train
          train = @depot.upcoming[0]
          train.buyable = false
          buy_train(nc, train, :free)

          @STL_nodes = STL_HEXES.map do |h|
            hex_by_id(h).tile.nodes.find { |n| n.offboard? && n.groups.include?('STL') }
          end
        end

        #allows blue-on-blue tile lays
        #TO DO: tie track lays to specific hexes, then only allow via private
        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          return true if tile.name == 'SPH' or 'POM'
          super
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
         if from.hex.name == 'B1' or 'D23'
          return true if from.color == :blue && to.color == :blue 
         end
          super
        end

        def operating_round(round_num)
          G18IL::Round::Operating.new(self, [
            #Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            G18IL::Step::Convert,
            G18IL::Step::IssueShares,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18IL::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def steamboat
          @steamboat ||= company_by_id('SMBT')
        end
        
        def trade_assets
         #@log << "#{current_entity.name} skips Trade Assets."
        end
        
        def stock_round
          print "hello dolly"
          G18IL::Round::Stock.new(self, [
            #Engine::Step::DiscardTrain,
            #Engine::Step::Exchange,
            #Engine::Step::SpecialTrack,
            G18IL::Step::BuySellParShares,
          ])
        end

        def issuable_shares(entity)

          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G18IL::Step::IssueShares) }.active?

          num_shares = entity.total_shares - (entity.num_player_shares + entity.num_market_shares)
          bundles = bundles_for_corporation(entity, entity)

          #@log << "#{entity.share_price}"
          #share_price = stock_market.find_share_price(entity, :left).price

          bundles
            .each { |bundle| bundle.share_price = entity.share_price.price }
            .reject { |bundle| bundle.num_shares > 1 }
            #.reject { |bundle| bundle.num_shares > num_shares }
        end

=begin
        def issuable_shares(entity)
          @log << "issuable_shares"
          i_shares = entity.total_shares - (entity.num_player_shares + entity.num_market_shares)
          if (i_shares > 0) then
            i_shares = 1 
          end
          i_shares
        end
=end

        def or_round_finished
          return if @depot.upcoming.empty?
          #phase 3 starts in OR1.2, which exports all 2-trains and rusts the 'Rogers' train
          if @depot.upcoming.first.name == '2'
            depot.export_all!('2')
            phase.next!
            nc.trains.delete_at(0)
            @log << "-- Event: Rogers (1+1) train rusts --"
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
=begin
        #from 18JP-T
        def revenue_for(route, stops)
          revenue = super

          # Double revenue of corporation's destination hexes
          if (ability = abilities(route.train, :hex_bonus))
            stops.each do |stop|
              next unless ability.hexes.include?(stop.hex.name)

              revenue += stop.route_revenue(route.phase, route.train)
            end
          end

=end

        def revenue_for(route, stops)
          revenue = super
      
          #revenue += P_bonus(route, stops)[:revenue]
          revenue += EW_NS_bonus(stops)[:revenue]
      
          revenue
      end
      
      def EW_NS_bonus(stops)
          bonus = { revenue: 0 }
      
          east = stops.find { |stop| stop.groups.include?('East') }
          west = stops.find { |stop| stop.groups.include?('West') }
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

      def revenue_str(route)
        str = super

        bonus = EW_NS_bonus(route.stops)[:description]
        str += " + #{bonus}" if bonus

        str
      end

      def STL_permit?(entity)
        STL_TOKEN_HEXES.any? { |hexid| hex_by_id(hexid).tile.cities.any? { |c| c.tokened_by?(entity) } }
      end

      def STL_hex?(stop)
        @STL_nodes.include?(stop)
      end

      def check_STL(visits)
        return if !STL_hex?(visits.first) && !STL_hex?(visits.last)
        raise GameError, 'Train cannot visit St. Louis without a permit token' unless STL_permit?(current_entity)
      end

      def check_distance(route, visits)
       #use for P trains!! 
       #raise GameError, 'Local train cannot visit an offboard' if train_type(route.train) == :local && visits.any?(&:offboard?)
        check_STL(visits)
        return super
      end

=begin     
            #checks 3P run to see if it visits offboard hex
            def three_P_name?(name)
              name == '3P'
            end
   
            def three_P_train?(train)
              three_P_name?(train.name)
            end

            def check_other(route)
              if three_P_train?(route.train)
              raise GameError, 'Cannot visit offboard hexes' if route.stops.any? { |stop| stop.tile.color == :red }
            end


      def P_bonus(route, stops)
        bonus = { revenue: 0 }
    
        if train.name == '5+1P'
          bonus[:revenue] = stops.map { |stop| stop.route_revenue(route.phase, route.train) }.max
        end
        
        bonus
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


      def process_convert(action)
        #@log << "process_convert in game.rb"
        @game.convert(action.entity)
      end
=end

      def convert(corporation)
        #@log << "convert in game.rb"
        before = corporation.total_shares
        shares = @_shares.values.select { |share| share.corporation == corporation }

        corporation.share_holders.clear

        case corporation.type
        when :five_share
          shares.each { |share| share.percent = 10 }
          shares[0].percent = 20
          new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          corporation.type = :ten_share
          corporation.float_percent = 20
          2.times { corporation.tokens << Engine::Token.new(corporation, price: 0) }
        when :two_share
          shares.each { |share| share.percent = 20 }
          shares[0].percent = 40
          new_shares = Array.new(3) { |i| Share.new(corporation, percent: 20, index: i + 1) }
          corporation.type = :five_share
          corporation.float_percent = 20
          1.times { corporation.tokens << Engine::Token.new(corporation, price: 0) }
        else
          raise GameError, 'Cannot convert 10 share corporation'
        end

        shares.each { |share| corporation.share_holders[share.owner] += share.percent }

        new_shares.each do |share|
          add_new_share(share)
        end

        after = corporation.total_shares
        @log << "#{corporation.name} converts from #{before} to #{after} shares"

        new_shares
      end

      def add_new_share(share)
        owner = share.owner
        corporation = share.corporation
        corporation.share_holders[owner] += share.percent if owner
        owner.shares_by_corporation[corporation] << share
        @_shares[share.id] = share
      end

      def status_array(corp)
        return ['5-Share'] if corp.type == :five_share
        return ['10-Share'] if corp.type == :ten_share
      end

      end
    end
  end
end
