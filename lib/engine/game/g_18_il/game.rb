# frozen_string_literal: true

require_relative 'entities'
require_relative 'companies'
require_relative 'map'
require_relative 'meta'
require_relative 'tiles'
require_relative 'trains'
require_relative 'market'
require_relative 'phases'
require_relative '../base'
require_relative '../cities_plus_towns_route_distance_str'
require_relative 'step/buy_tokens'
require_relative 'step/token'
require_relative 'step/track'

module Engine
  module Game
    module G18IL
      class Game < Game::Base
        include_meta(G18IL::Meta)
        include Entities
        include Companies
        include Map
        include Tiles
        include Trains
        include Market
        include Phases
        include CitiesPlusTownsRouteDistanceStr

        attr_accessor :stl_nodes, :blocking_token

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

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'pullman_strike' => ['4+2P is downgraded to 4', '5+1P is downgraded to 5']
        ).freeze

        POOL_SHARE_DROP = :down_share
        BANKRUPTCY_ALLOWED = false
        CERT_LIMIT_INCLUDES_PRIVATES = false
        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true

        TILE_LAYS = [
          { lay: true, upgrade: true, cost:0},
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :always

        # TODO:  first D only
        GAME_END_CHECK = { final_phase: :one_more_full_or_set }.freeze
        SELL_AFTER = :p_any_operate
        SELL_MOVEMENT = :none
        POOL_SHARE_DROP = :down_share

        # TODO:  depends on share type 2 vs 5 vs 10
        SOLD_OUT_INCREASE = true

        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        CLOSED_CORP_TRAINS_REMOVED = false
        CLOSED_CORP_TOKENS_REMOVED = false
        CLOSED_CORP_RESERVATIONS_REMOVED = false

        PORT_HEXES = %w[B1 D23 H1 I2].freeze
        MINE_HEXES = %w[C2 D9 D13 D17 E6 E14 F5 F13 F21 G22 H11].freeze
        DETROIT = ['I6'].freeze
        CLASS_A_COMPANIES = %w[].freeze
        CLASS_B_COMPANIES = %w[].freeze
        PORT_TILES = %w[SPH POM].freeze
        STL_HEXES = %w[B15 B17 C16 C18].freeze
        STL_TOKEN_HEXES = %w[C18].freeze
        

        def setup_preround
          super
          #places blocking tokens (phase colors) in STL
          blocking_logo = ["/logos/18_il/yellow_blocking.svg","/logos/18_il/green_blocking.svg","/logos/18_il/brown_blocking.svg","/logos/18_il/gray_blocking.svg"]
          game_start_blocking_corp = Corporation.new(sym: 'GSB', name: 'game_start_blocking_corp', logo: blocking_logo[0], simple_logo: blocking_logo[0], tokens: [0])
          game_start_blocking_corp.owner = @bank
          city = @hexes.find { |hex| hex.id == 'C18' }.tile.cities.first
          blocking_logo.each do |n| 
           token = Token.new(game_start_blocking_corp, price: 0, logo: "#{n}", simple_logo: "#{n}", type: :blocking) 
           city.place_token(game_start_blocking_corp, token, check_tokenable: false)          
          end

          #creates corp that adds blocking tokens at the start of the final cycle
          game_end_blocking_corp = Corporation.new(sym: 'GEB', name: 'game_end_blocking_corp', logo: '18_il/yellow_blocking', tokens: [0])
        end

        def setup
          # Northern Cross starts with the 'Rogers' train
          train = @depot.upcoming[0]
          train.buyable = false
          buy_train(nc, train, :free)

          @stl_nodes = STL_HEXES.map do |h| 
            hex_by_id(h).tile.nodes.find { |n| n.offboard? && n.groups.include?('STL') }
          end
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = 2
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            when init_round.class
              reorder_players
              new_stock_round
            end
        end


        def nc
          @nc ||= corporation_by_id('NC')
        end
        
        def game_end_blocking_corp
          game_end_blocking_corp ||= corporation_by_id('GEB')
        end

        #allows blue tile lays at any time
        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          return true if tile.name == 'SPH' or 'POM'
          super
        end

        #allows blue-on-blue tile lays
        def upgrades_to?(from, to, special = false, selected_company: nil)
         if from.hex.name == 'B1' or 'D23'
          return true if from.color == :blue && to.color == :blue
         end
          super
        end
        
        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            #Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            G18IL::Step::Convert,
            G18IL::Step::IssueShares,
            G18IL::Step::Track,
            G18IL::Step::Token,
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

        def or_set_finished
          if phase.name == 'D'
            @log << "-- Event: Removing unopened corporations and placing blocking tokens --"
            #remove unopened corporations and decrement cert limit
            remove_unparred_corporations!
            @log << "-- Certificate limit adjusted to #{@cert_limit} --"

            #Pullman Strike
            @log << "-- Event: Pullman Strike --"
            pullman_strike
          end
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: :flip)
        end

        #adds E/W and N/S bonus, and doubles 3P train revenue
        def revenue_for(route, stops)
          revenue = super

          if three_p_train?(route.train)
            p_bonus_revenue = revenue
            revenue += p_bonus_revenue
          end

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

        def stl_permit?(entity)
          STL_TOKEN_HEXES.any? { |hexid| hex_by_id(hexid).tile.cities.any? { |c| c.tokened_by?(entity) } }
        end

        def stl_hex?(stop)
          @stl_nodes.include?(stop)
        end

        def check_stl(visits)
          return if !stl_hex?(visits.first) && !stl_hex?(visits.last)
          raise GameError, 'Train cannot visit St. Louis without a permit token' unless stl_permit?(current_entity)
        end

        def three_p_train?(train)
          train.name == '3P'
        end

        def check_three_p_train(route, visits)     
          raise GameError, 'Cannot visit red areas' if visits.first.tile.color == :red || visits.last.tile.color == :red if three_p_train?(route.train)
        end
        
        def check_distance(route, visits)
          #checks STL for permit token
          check_stl(visits)
          #disallows 3P trains from running to red areas
          check_three_p_train(route, visits)
          return super
        end

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

        def event_signal_end_game!
          # Play one more OR, then Pullman Strike and blocking token events occur, then play one final set (CR, SR, 2 ORs)
          @final_operating_rounds = 2
          game_end_check
          @operating_rounds = 3 if phase.name == 'D' && round.round_num == 2
          @log << "First D train bought/exported, game ends at the end of #{@turn + 1}.#{@final_operating_rounds}"
        end

        def remove_unparred_corporations!
          @corporations.reject(&:ipoed).reject(&:closed?).each do |corporation|
            place_home_blocking_token(corporation)
            @log << "#{corporation.name} removed from the game"
            @corporations.delete(corporation)
            @cert_limit -= 1
          end
        end

        def place_home_blocking_token(corporation)
          cities = []

          hex = hex_by_id(corporation.coordinates)
          if hex.tile.reserved_by?(corporation)
            cities.concat(hex.tile.cities)
          else
            cities << hex.tile.cities.find { |city| city.reserved_by?(corporation) }
            cities.first.remove_reservation!(corporation)
          end

          cities.each { |city| 
          @log << "Blocking token placed on #{hex.name} (#{hex.location_name})"
           city ||= hex.tile.cities[0]
           token = Token.new(game_end_blocking_corp, price: 0, logo: "/logos/18_il/#{corporation.name}_blocking.svg", simple_logo: "/logos/18_il/#{corporation.name}_blocking.svg", type: :blocking)
           city.place_token(game_end_blocking_corp, token, check_tokenable: false) }
        end

        def final_operating_rounds
          @final_operating_rounds || super
        end

        # Pullman Strike: Flip all 5+1P trains over to their 5-train
        # side and flip all 4+2P trains over to their 4-train side.
        # TODO:   illegal access of class variables
        def pullman_strike
          downgraded_trains = []
          owners = Hash.new(0)
          self.corporations.each do |cp|
            cp.trains.each do |train|
              if train.name == '4+2P' then
                @log << "#{train.name} train downgraded to a 4-train (#{cp.name})"
                train.name = '4'
                train.distance = [{'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                                  {'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 }]

              elsif train.name == '5+1P' then
                @log << "#{train.name} train downgraded to a 5-train (#{cp.name})"
                train.name = '5'
                train.distance = [{'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                                  {'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 }]
              end
            end
          end
        end  
      end
    end
  end
end