# frozen_string_literal: true

require_relative 'entities'
require_relative 'companies'
require_relative 'map'
require_relative 'meta'
require_relative 'tiles'
require_relative 'trains'
require_relative 'market'
require_relative 'phases'

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

        attr_accessor :stl_nodes, :blocking_token, :ic_lines_built, :ic_lines_progress

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
          'pullman_strike' => ['Pullman Strike','4+2P is downgraded to 4', '5+1P is downgraded to 5'], #TODO: not showing up on info page
          'signal_end_game' => ['Signal End Game','Game Ends 3 ORs after purchase/export of first D train']
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
        DISCARDED_TRAINS = :remove

        GAME_END_CHECK = { final_phase: :one_more_full_or_set }.freeze
        SELL_AFTER = :p_any_operate
        SELL_MOVEMENT = :none

        SOLD_OUT_INCREASE = true
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        CLOSED_CORP_TRAINS_REMOVED = false
        CLOSED_CORP_TOKENS_REMOVED = false
        CLOSED_CORP_RESERVATIONS_REMOVED = false

        PORT_HEXES = %w[B1 D23 H1 I2].freeze
        MINE_HEXES = %w[D9 D13 D17 E6 E14 F5 F13 F21 G22 H11].freeze
        GALENA = ['C2'].freeze
        DETROIT = ['I6'].freeze
        ST_PAUL = ['B1'].freeze
        PORT_OF_MEMPHIS = ['D23'].freeze
        LAKE_MICHIGAN = ['H1'].freeze
        CLASS_A_COMPANIES = %w[].freeze
        CLASS_B_COMPANIES = %w[].freeze
        PORT_TILES = %w[SPH POM].freeze
        PORT_TILE_HEXES = %w[B1 D23].freeze
        STL_HEXES = %w[B15 B17 C16 C18].freeze
        STL_TOKEN_HEXES = %w[C18].freeze
        EXTRA_STATION_PRIVATE_NAME = 'ES'.freeze
        PORT_MARKER_ICON = 'port'.freeze
        MINE_MARKER_ICON = 'mine'.freeze
        SPRINGFIELD_HEX = 'E12'.freeze
        CORPORATION_SIZES = { 2 => :small, 5 => :medium, 10 => :large }.freeze
       # CORPORATIONS = %w[P&BV NC G&CU RI C&A V WAB C&EI].freeze

       PORT_TILE_FOR_HEX = {
        'B1' => ['SPH', 0],
        'D23' => ['POM', 0],
        }.freeze

        ASSIGNMENT_TOKENS = {
          'port' => '/icons/18_il/port.svg',
          'mine' => '/icons/18_il/mine.svg',
        }.freeze

        IC_LINE_COUNT = 10
        IC_LINE_ORIENTATION = {
          'H7' => [1, 3],
          'G8' => [4, 0],
          'G10' => [3, 0],
          'G12' => [3, 0],
          'G14' => [1, 3],
          'F15' => [4, 0],
          'F17' => [3, 0],
          'F19' => [1, 3],
          'E20' => [4, 0],
          'E22' => [3, 0],
        }.freeze
      
        @port_log = []
        @mine_log = []
        
        def corporation_size(entity)
          # For display purposes is a corporation small, medium or large
          CORPORATION_SIZES[entity.total_shares]
        end

        def corporation_size_name(entity)
          entity.total_shares.to_s
        end

        def float_str(entity)
          "2 shares to start"
        end
        
        def nc
          @nc ||= corporation_by_id('NC')
        end

         def setup_preround
          super

          #creates corp that places blocking tokens (phase colors) in STL
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
         
          @port_marker_ability =
          Engine::Ability::Description.new(type: 'description', description: 'Port marker', desc_detail: 'Gains revenue from ports')

          @mine_marker_ability =
          Engine::Ability::Description.new(type: 'description', description: 'Mine marker', desc_detail: 'Gains revenue from mines')

          @option_cube_ability =
           Engine::Ability::Description.new(type: 'description', description: 'Option cube', desc_detail: 'When IC forms, the corporation may trade this cube for a share of IC', count: 1)

          if optional_rules.include?(:intro_game) then
            @port_corporations ||= @corporations.min_by(4) { rand }
            @mine_corporations ||= @corporations - @port_corporations
            @port_tile_for_hex ||= PORT_TILE_FOR_HEX.min_by(1) { rand }
          else
            @port_corporations ||= []
            @mine_corporations ||= []
          end


        end

        def setup
          @ic_lines_built = 0
          @ic_line_progress = {
            'H7' => 0,
            'G8' => 0,
            'G10' => 0,
            'G12' => 0,
            'G14' => 0,
            'F15' => 0,
            'F17' => 0,
            'F19' => 0,
            'E20' => 0,
            'E22' => 0,
          }

          # Northern Cross starts with the 'Rogers' train
          train = @depot.upcoming[0]
          train.buyable = false
          buy_train(nc, train, :free)
          
          @stl_nodes = STL_HEXES.map do |h| 
            hex_by_id(h).tile.nodes.find { |n| n.offboard? && n.groups.include?('STL') }
          end

          #assigns port and mine markers to corporations
          if optional_rules.include?(:intro_game) then
            assign_port_markers(port_corporations)
            assign_mine_markers(mine_corporations)

            #place random port tile on map and remove the other
            hex = @hexes.find { |h| h.id == PORT_TILE_HEXES.min_by { rand } }
            assign_port_tile(hex)
            remove_port_tiles
          end
        end

        def assign_port_tile(hex)
          tile_name, rotation = PORT_TILE_FOR_HEX[hex.id]
          hex.lay(@tiles.find { |t| t.name == tile_name }.rotate!(rotation))
          @log << "#{tile_name} tile is placed on #{hex.id}"
        end

        def remove_port_tiles
            @all_tiles.each { |tile| tile.hide if tile.color == :blue }
        end

        def assign_port_markers(entity)
          port_log = []
          port_corporations.each { |c| 
          c.add_ability(@port_marker_ability.dup)
          port_log << c.name
          port_log << ", " if port_log.count < 6
          port_log << 'and ' if port_log.count == 6
        }
        @log << "#{port_log.join} receive port markers"
        end

        def assign_mine_markers(entity)
          mine_log = []
          mine_corporations.each { |c| 
          c.add_ability(@mine_marker_ability.dup)
          mine_log << c.name
          mine_log << ", " if mine_log.count < 6
          mine_log << 'and ' if mine_log.count == 6
        }
        @log << "#{mine_log.join} receive mine markers"
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def ipo_verb(_entity = nil)
          'starts'
        end

        def ipo_reserved_name(_entity = nil)
          'Reserve'
        end

        def status_str(corp)
          str = ''
            company = @companies.find { |c| c.sym == corp.name }
            str += if company&.owner&.player?
                     "Concession: #{company.owner.name} "
                   else
                     ''
                   end
            str.strip
        end

        #TODO: add stuff to this
        def timeline
          []
        end

        def port_corporations
          @port_corporations.each { |c| corporation_by_id(c) }
        end

        def mine_corporations
          @mine_corporations.each { |c| corporation_by_id(c) }
        end

        def game_end_blocking_corp
          game_end_blocking_corp ||= corporation_by_id('GEB')
        end

        #allows blue tile lays at any time
        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          return true if tile.name == 'SPH' || tile.name == 'POM'
          super
        end

        #allows blue-on-blue tile lays
        def upgrades_to?(from, to, special = false, selected_company: nil)
         if from.hex.name == 'B1' || from.hex.name =='D23'
          return true if from.color == :blue && to.color == :blue
         end
          super
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Auction
              reorder_players
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = 2
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              if @ic_formation_triggered
                @ic_formation_triggered = false
                form_ic
              end
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_concession_round
              end
            when init_round.class
              init_round_finished
              new_stock_round
            end
        end
 
        def concession_round
          G18IL::Round::Auction.new(self, [
            G18IL::Step::ConcessionAuction,
          ])
        end

        def stock_round
          G18IL::Round::Stock.new(self, [
            G18IL::Step::BuyNewTokens,
            #Engine::Step::DiscardTrain,
            #Engine::Step::Exchange,
            #Engine::Step::SpecialTrack,
            G18IL::Step::BaseBuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::HomeToken,
            Engine::Step::DiscardTrain,
            G18IL::Step::Conversion,
            G18IL::Step::PostConversionShares,
            G18IL::Step::BuyNewTokens,
            G18IL::Step::IssueShares,
            G18IL::Step::Track,
            G18IL::Step::Token,
            G18IL::Step::Route,
            G18IL::Step::Dividend,
            #G18IL::Step::EmergencyMoneyRaising,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_round
          new_concession_round
        end

        def new_concession_round
          @log << "-- Concession Round #{@turn} --"
          concession_round
        end

        def can_par?(corporation, entity)
          return false unless concession_ok?(entity, corporation)
          super
        end

        def concession_ok?(player, corp)
          return false unless player.player?

          player.companies.any? { |c| c.sym == corp.name }
        end

        def return_concessions!
          companies.each do |c|
            next unless c&.owner&.player?
            player = c.owner
            player.companies.delete(c)
            c.owner = nil
            @log << "#{c.name} (#{c.sym}) has not been used by #{player.name} and is returned to the bank"
          end
        end

        def finish_stock_round
          return_concessions!
        end

        def form_ic; end

        def initial_auction_companies
          companies
        end
        
        def company_header(_company)
          'CONCESSION'
        end

        # def allow_player2player_sales?
        #   @player2player ||= true #@optional_rules&.include?(:p2p_purchases)
        # end

        def tokens_needed(corporation)
          tokens_needed = { 2 => 1, 5 => 2, 10 => 5 }[corporation.total_shares] - corporation.tokens.size
          tokens_needed += 1 if corporation.companies.any? { |c| c.id == EXTRA_STATION_PRIVATE_NAME }
          tokens_needed
        end

        def close_corporation(corp)
          return if corp.closed?
          @closed_corporations ||= []
          @closed_corporations << corp
          @log << "#{corp.name} closes"

          # un-IPO the corporation
          corp.share_price.corporations.delete(corp)
          corp.share_price = nil
          corp.par_price = nil
          corp.ipoed = false
          corp.unfloat!

          # return shares to IPO
          corp.share_holders.keys.each do |share_holder| #TODO: place reserve shares in open market
            next if share_holder == corp

            shares = share_holder.shares_by_corporation[corp].compact
            corp.share_holders.delete(share_holder)
            shares.each do |share|
              share_holder.shares_by_corporation[corp].delete(share)
              share.owner = corp
              corp.shares_by_corporation[corp] << share
            end
          end
          corp.shares_by_corporation[corp].sort_by!(&:index)
          corp.share_holders[corp] = 100
          corp.owner = nil

          # remove home station and flip any other tokens for corporation placed on map
          #TODO: considering a rules change to also flip home token. Upon par, corp flips any one flipped token it has on the map. If it has none, it instead places one in any free token slot.
          corp.tokens.first.remove!
          corp.tokens.each do |token|
          token.status = :flipped if token.used
          end
          hex_by_id(corp.coordinates).tile.add_reservation!(corp, 0)
          company = company_by_id(corp.name)
          company.owner = nil
          @companies << company
          @companies = @companies.sort

          @round.force_next_entity! if @round.operating?
        end

        def trade_assets
         #@log << "#{current_entity.name} skips Trade Assets"
        end

        def mine_company?(company)
          self.class::MINE_COMPANIES.include?(company.id)
        end

        def port_company?(company)
          self.class::PORT_COMPANIES.include?(company.id)
        end

        def ic_line_hex?(hex)
          IC_LINE_ORIENTATION[hex.name]
        end

        def ic_line_improvement(action)
          #ic_line_icon = action.hex.tile.icons.find {IC_LINE_ICON}
          #return if !ic_line_icon || !connects_ic_line?(action.hex)
          hex = action.hex
          tile = action.hex.tile
          icons = action.hex.tile.icons
          corp = action.entity.corporation

          return false if (@ic_line_progress[hex] == 1)

          result = ic_line_connections(hex)
          if (result > 0) then
            if tile.color == 'yellow'
              @log << "#{corp.name} receives $20 subsidy for IC Line improvement"
              corp.cash += 20
            end
            lines = @ic_lines_built
            if (result == 2) then
              @ic_line_progress[hex] = 1
              icons.each do |icon|
                if (icon.sticky) then 
                  icons.delete(icon)
                  assign_option_cube(corp)
                end
              end

              @ic_lines_built = lines + 1
              @log << "IC Line hexes built: #{ic_lines_built} of 10"
              if (@ic_lines_built == 10) then
                @log << "IC Line is complete"
                @log << "The Illinois Central Railroad will form at the end of this operating round"
              end
            end
          end
          result
        end

=begin
        def self.remove_sticky_icon
          print "remove_sticky_icon"
          @icons.each do |icon| 
            if (icon.sticky == 1) then 
              icons.reject(icon)
            end
          end
        end
=end

        def ic_line_connections(hex)
          #@log << "connects_ic_line?"

          return 0 unless (orientation = IC_LINE_ORIENTATION[hex.name])
          paths = hex.tile.paths
          exits = [orientation[0], orientation[1]]

          #@log << "orientation  #{orientation}"
          #paths.each do |path| 
          #  @log << "path #{path.exits}"
          #end

          count = 0
          paths.each do |path|
            path.exits.each do |exit|
              (count += 1) if exits.include? exit
            end
          end
          #@log << "count #{count}"
          return count
  
          #paths.any? { |path| (path.exits & exits).size == 2 } ||
           # (path_to_city(paths, orientation[0]) && path_to_city(paths, orientation[1]))
        end

        def path_to_city(paths, edge)
          paths.find { |p| p.exits == [edge] }
        end

        def ic_line_completed?()
          @ic_lines_built == IC_LINE_COUNT
        end

        def remove_icon(hex, icon_names)
          icon_names.each do |name|
            icons = hex.tile.icons
            icons.reject! { |i| name == i.name }
            hex.tile.icons = icons
          end
        end

        def emergency_issuable_shares(entity)
          bundles = bundles_for_corporation(entity, entity).select { |bundle| @share_pool.fit_in_bank?(bundle) }
          bundles.each { |b| b.share_price = entity.share_price.price / 2.0 }
          return bundles
        end

        def purchase_tokens!(corporation, count, total_cost)
          (count).times { corporation.tokens << Token.new(corporation, price: 0) }
          auto_emr(corporation, total_cost) if corporation.cash < total_cost
          corporation.spend(total_cost, @bank) unless total_cost == 0
          @log << "#{corporation.name} buys #{count} #{count == 1 ? "token" : "tokens"} for #{format_currency(total_cost)}"
        end

        # sell IPO shares to make up shortfall
        def auto_emr(corp, total_cost)
          diff = total_cost - corp.cash
          return unless diff.positive?

          num_shares = ((2.0 * diff) / corp.share_price.price).ceil
          raise GameError, 'Corporation cannot raise enough money to convert - please undo' if num_shares > corp.shares_of(corp).size #TODO: move this to convert step

          bundle = ShareBundle.new(corp.shares_of(corp).take(num_shares))
          bundle.share_price = corp.share_price.price / 2.0
          sell_shares_and_change_price(bundle)
          old = bundle.corporation.share_price.price
          stock_market.move_down(bundle.corporation) 
          new = bundle.corporation.share_price.price
          @log << "#{corp.name} raises #{format_currency(bundle.price)} and completes EMR"
          @log << "#{bundle.corporation.name}'s share price moves left diagonally from $#{old} to $#{new}"
          @round.recalculate_order if @round.respond_to?(:recalculate_order)
        end
        
        # def emergency_issuable_bundles(entity)
        #   return [] unless entity.corporation?
        #   return [] if entity.num_ipo_shares.zero? && entity.total_shares == 10
        #   if entity.total_shares == 2
        #     convert(entity)
        #     @converted = true
        #   end

        #   if emergency_issuable_shares(entity)[-1].share_price + entity.cash < @depot.min_depot_price && entity.total_shares == 5
        #      convert(entity) 
        #      @log << "#{entity.name} is forced to convert from a #{@converted ? "2-share to a 10-share" : "5-share to a 10-share"} corporation"
        #   end
        #   return [] unless entity.cash < @depot.min_depot_price
        #   eligible, remaining = emergency_issuable_shares(entity).partition { |bundle| bundle.price + entity.cash < @depot.min_depot_price }
        #   eligible_shares = eligible.each { |n| n.price }
        #   return remaining.empty? ? eligible.last(1) : remaining.take(1)
        # end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] if entity.num_ipo_shares.zero?
          return bundles_for_corporation(entity, entity).take(1)
        end

        def scrap_train(train)
          owner = train.owner
          @log << "#{owner.name} scraps a #{train.name} train"
          @depot.reclaim_train(train)
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
            event_pullman_strike!
          end
        end

        def init_stock_market
          StockMarket.new(self.class::MARKET, [], zigzag: :flip)
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += ew_ns_bonus(stops)[:revenue] + p_bonus(route, stops)
          revenue = revenue - mine_revenue_removal(route, stops) - port_revenue_removal(route, stops)
          return revenue
        end

        def mine_revenue_removal(route, stops)
          return 0 if @mine_corporations.include?(route.train.owner)
          stop_hexes = stops.map(&:hex).map { |hex| hex.name }
          mines = stop_hexes & MINE_HEXES
          galena = stop_hexes & GALENA
          return mines.count * 10 + galena.count * 30
        end

        def port_revenue_removal(route, stops)
          return 0 if @port_corporations.include?(route.train.owner)
          stop_hexes = stops.map(&:hex).map { |hex| hex.name }
          st_paul = stop_hexes & ST_PAUL
          pom = stops.map(&:hex).find { |hex| hex.name == PORT_OF_MEMPHIS }
         # @log << "#{pom}"
         # pom.revenue == 0 ? 0 : port_of_memphis = stop_hexes & PORT_OF_MEMPHIS
          lake_michigan = stop_hexes & LAKE_MICHIGAN
          return st_paul.count * 50 #+ port_of_memphis.count * 30 + lake_michigan.count * 20
        end

        def p_bonus(route, stops)
          return 0 unless route.train.name.include?("P")
          cities = stops.select { |s| s.city? }
          count = route.train.name[-2]
          bonus = cities.map { |stop| stop.route_revenue(route.phase, route.train) }.max(count.to_i)
          return bonus.sum
        end

        def ew_ns_bonus(stops)
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

            return bonus
        end

         def revenue_str(route)
           str = super
           bonus = ew_ns_bonus(route.stops)[:description]
           str += " + #{bonus}" if bonus
           return str
         end

        def route_distance_str(route)
          stop_hexes = route.stops.map(&:hex).map { |hex| hex.name}
          mines = (stop_hexes & MINE_HEXES).count
          galena = (stop_hexes & GALENA).count
          ports = (stop_hexes & PORT_HEXES).count
          others = route_distance(route) - mines - ports- galena
          str = others.to_s
          str += "+#{mines}m" if (mines.positive? || galena.positive?) && @mine_corporations.include?(route.train.owner)
          str += "+#{ports}p" if ports.positive? && @port_corporations.include?(route.train.owner)
          return str
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
        
        def check_distance(route, visits)
          #checks STL for permit token
          check_stl(visits)

          #disallows 3P trains from running to red areas
          raise GameError, 'Cannot visit red areas' if visits.first.tile.color == :red || visits.last.tile.color == :red if route.train.name == '3P'
          return super
        end

        def convert(corporation)
          shares = @_shares.values.select { |share| share.corporation == corporation }
          corporation.share_holders.clear
          case corporation.total_shares
          when 2
            shares[0].percent = 40
            new_shares = Array.new(3) { |i| Share.new(corporation, percent: 20, index: i + 1) }
          when 5
            shares.each { |share| share.percent = 10 }
            shares[0].percent = 20
            new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          else
            raise GameError, 'Cannot convert 10-share corporation'
          end
          corporation.max_ownership_percent = 60
          shares.each { |share| corporation.share_holders[share.owner] += share.percent }
          new_shares.each do |share| add_new_share(share) end
          new_shares
        end
        
        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def event_signal_end_game!
          # Play one more OR, then Pullman Strike and blocking token events occur, then play one final set (CR, SR, 2 ORs)
          @final_operating_rounds = 2
          game_end_check
          @operating_rounds = 3 if phase.name == 'D' && round.round_num == 2
          @log << "First D train bought/exported, game ends at the end of #{@turn + 1}.#{@final_operating_rounds}"
        end

        def remove_unparred_corporations!
          @blocking_log = []
          @removed_corp_log = []
          @corporations.reject(&:ipoed).reject(&:closed?).each do |corporation|
            place_home_blocking_token(corporation)
            @removed_corp_log << corporation.name
            @corporations.delete(corporation)
            company = company_by_id(corporation.name)
            @companies.delete(company)
            @cert_limit -= 1
          end
          @log << "#{@removed_corp_log.join(', ')} removed from the game"
          @log << "Blocking #{@blocking_log.count == 1 ? "token" : "tokens"} placed on #{@blocking_log.join(', ')}"
          @log << "Concessions removed from the game"
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
          @blocking_log << "#{hex.name} (#{hex.location_name})"
           city ||= hex.tile.cities[0]
           token = Token.new(game_end_blocking_corp, price: 0, logo: "/logos/18_il/#{corporation.name}.svg", simple_logo: "/logos/18_il/#{corporation.name}.svg", type: :blocking)
           token.status = :flipped
           city.place_token(game_end_blocking_corp, token, check_tokenable: false) }
        end

        def final_operating_rounds
          @final_operating_rounds || super
        end

        # Pullman Strike: Flip all 5+1P trains over to their 5-train
        # side and flip all 4+2P trains over to their 4-train side.
        # TODO:   illegal access of class variables
        def event_pullman_strike!
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

        def assign_option_cube(entity)
          if has_option_cube?(entity) #TODO: if corp has action cube, increment count rather than adding additional cube (if possible)
            @log << "#{entity.name} gains an option cube"
            entity.add_ability(@option_cube_ability.dup)
          else
            entity.add_ability(@option_cube_ability.dup)
           @log << "#{entity.name} gains an option cube"
          end
        end

        def has_option_cube?(entity)
        #  ability = abilities(entity)        #TODO: figure out how to check if corp already has option cube
        #  @log << "#{ability.type}"
        #  @log << "#{@option_cube_ability}"
         # ability.include?(@option_cube_ability)
        end
      end
    end
  end
end