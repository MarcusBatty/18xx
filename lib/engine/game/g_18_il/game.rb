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

        attr_accessor :stl_nodes, :blocking_token, :ic_lines_built, :ic_lines_progress, :mine_corp, :port_corp, :exchange_choice_player, :exchange_choice_corp, :exchange_choice_corps, :diverse_cargo_corp
        attr_reader :merged_corporation

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

        ENGINEERING_MASTERY_TILE_LAYS = [
          { lay: true, upgrade: true, cost:0},
          { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true },
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
        PORT_ICON = 'port'.freeze
        MINE_ICON = 'mine'.freeze
        IC_STARTING_PRICE = 80.freeze
        IC_LINE_HEXES = %w[H7 G10 F17 E22].freeze
        

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
        

        def next_round!
          @round =
            case @round
            when Engine::Round::Auction
              #reorder_players
              new_stock_round
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
                new_concession_round
              end
            when init_round.class
              init_round_finished
              new_stock_round
            end
        end

        def concession_round
          G18IL::Round::Auction.new(self, [
            G18IL::Step::ConcessionAuction
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
           # G18IL::Step::Assign,
           G18IL::Step::DiverseCargoChoice,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::HomeToken,
            G18IL::Step::ExchangeChoiceCorp,
            G18IL::Step::ExchangeChoicePlayer,
            G18IL::Step::Merge,
            Engine::Step::DiscardTrain,
            G18IL::Step::Conversion,
            G18IL::Step::PostConversionShares,
            G18IL::Step::BuyNewTokens,
            G18IL::Step::IssueShares,
            G18IL::Step::CorporateBuyShares,
          #  G18IL::Step::CorporateBuySellShares,
          # G18IL::Step::Corporate41BuyShares,
            G18IL::Step::Track,
            G18IL::Step::Token,
            G18IL::Step::Route,
            G18IL::Step::Dividend,
          #  G18IL::Step::EmergencyMoneyRaising,
            Engine::Step::SpecialBuyTrain,
            G18IL::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def tile_lays(entity)
          return ENGINEERING_MASTERY_TILE_LAYS if engineering_mastery.owner == entity

          super
        end
        
          def status_str(corp)
          str = ''
          company = @companies.find { |c| !c.closed? && c.sym == corp.name }
          if company&.owner&.player?
           str += "Concession: #{company.owner.name} "
           str.strip
          end
           return if @option_cubes[corp] == 0
           "Option cubes: #{@option_cubes[corp]}"
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

        def initial_auction_companies
          companies
        end

        def company_status_str(_company)
          return if @optional_rules&.include?(:intro_game)
          if _company.meta[:type] == :private
            if _company.meta[:class] == :A   
              "Class A"
            else
              "Class B"
            end
          elsif _company.meta[:type] == :concession
            (@corporations.select { |c| c.name == _company.sym }).each do |corp|
              return sprintf("A: %s B: %s", corp.companies[0].name, corp.companies[1].name)
            end
          end
        end

        
        def company_header(_company)
          if _company.meta[:type] == :concession
            'CONCESSION'
          elsif _company.meta[:type] == :private
            if _company.meta[:class] == :A   
              'CLASS A'
            else
              'CLASS B'
            end
          else
            'IC SHARE'
          end
          
        end

        # def allow_player2player_sales?
        #   @player2player ||= true #@optional_rules&.include?(:p2p_purchases)
        # end

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
          @ic_formation_triggered = nil
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
         
          @port_corporations = []
          @mine_corporations = []

          if @optional_rules&.include?(:intro_game)
            @port_corporations = @corporations.min_by(4) { rand }
            @mine_corporations = @corporations - @port_corporations
            @port_tile_for_hex = PORT_TILE_FOR_HEX.min_by(1) { rand }
          else
            _classA = [8,9,10,11,12,13,14,15]
            _classB = [16,17,18,19,20,21,22,23]
            classA = _classA.min_by(_classA.count) {rand}
            classB = _classB.min_by(_classB.count) {rand}
            @log << "-- Auction Lot Formation --"
            8.times do |i|
                str = []
                entity = @corporations[i]
                c = companies[classA[i]]
                c.owner = entity
                str << "#{c.name} and "
                entity.companies << c
                c = companies[classB[i]]
                c.owner = entity
                str << "#{c.name} assigned to #{entity.name} concession"
                entity.companies << c

                if c.name == "Diverse Cargo"
                  @diverse_cargo_corp = entity
                end

              @log << str.join
            end
          end
        end

        def setup          
          @ic_formation_pending = nil
          @option_cubes ||= Hash.new(0)
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

          
          if @optional_rules&.include?(:intro_game)
             #assigns port and mine markers to corporations
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
          @log << "Port tile is placed on #{hex.id}"
        end

        def remove_port_tiles
            @all_tiles.each { |tile| tile.hide if tile.color == :blue }
        end

        def assign_port_markers(entity)
          port_log = []
          port_corporations.each { |c| 
          assign_port_icon(c)
          port_log << c.name
          port_log << ", " if port_log.count < 6
          port_log << 'and ' if port_log.count == 6
          }
          @log << "#{port_log.join} receive port markers"
        end

        def assign_mine_markers(entity)
          mine_log = []
          mine_corporations.each { |c| 
          assign_mine_icon(c)
          mine_log << c.name
          mine_log << ", " if mine_log.count < 6
          mine_log << 'and ' if mine_log.count == 6
          }
          @log << "#{mine_log.join} receive mine markers"
        end

        def assign_mine_icon(corp)
          corp.assign!(MINE_ICON)
        end

        def assign_port_icon(corp)
          corp.assign!(PORT_ICON)
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

          # @corporations(&:floated).each do |c|
          #   if c.owner == corp
          # end

          # return shares to IPO
          corp.share_holders.keys.each do |share_holder|
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
          #TODO: implement rules change to also flip home token. Upon par, corp flips any one flipped token it has on the map. If it has none, it instead places one in any free token slot.
          corp.tokens.first.remove!
          corp.tokens.each do |token|
          token.status = :flipped if token.used
          end
          hex_by_id(corp.coordinates).tile.add_reservation!(corp, 0)

         #reactivate concession
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
              @log << "#{corp.name} receives a #{format_currency("20")} subsidy for IC Line improvement"
              corp.cash += 20
            end
            lines = @ic_lines_built
            if (result == 2) then
              @ic_line_progress[hex] = 1
              icons.each do |icon|
                if (icon.sticky) then 
                  icons.delete(icon)
                  
                  @option_cubes[corp] += 1
                  @log << "#{corp.name} receives an option cube"
                end
              end

              @ic_lines_built = lines + 1
              @log << "IC Line hexes built: #{ic_lines_built} of 10"
              if (@ic_lines_built == 10) then
                @log << "IC Line is complete"
                @log << "The Illinois Central Railroad will form at the end of #{action.entity.name}'s turn"
                @ic_formation_triggered = true
                @ic_formation_pending = true
              end
            end
          end
          result
        end

        def event_pending_ic_formation?
          @ic_formation_pending
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
        
        def convert(corporation)
          return unless corporation == current_entity
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
          @log << "#{bundle.corporation.name}'s share price moves left diagonally from #{format_currency(old)} to #{format_currency(new)}"
          @round.recalculate_order if @round.respond_to?(:recalculate_order)
        end
        
        def emergency_issuable_cash(corporation)
          emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
        end

        def emergency_issuable_bundles(entity)
          return [] unless entity.cash < @depot.min_depot_price
          bundles = bundles_for_corporation(entity, entity)
          bundles.each { |b| b.share_price = entity.share_price.price / 2.0 }
          eligible, remaining = bundles.partition { |bundle| bundle.price + entity.cash < @depot.min_depot_price }
            return remaining.empty? ? eligible.last(1) : remaining.take(1)
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] if entity.num_ipo_shares.zero?
          return bundles_for_corporation(entity, entity).take(1)
        end

        # def emergency_issuable_shares(entity)
        #   bundles = bundles_for_corporation(entity, entity).select { |bundle| @share_pool.fit_in_bank?(bundle) }
        #   bundles.each { |b| b.share_price = entity.share_price.price / 2.0 }
        #   return bundles
        # end


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

        def mine_revenue_removal(route, stops)
          return 0 if route.corporation.assignments.include?(MINE_ICON)
          stop_hexes = stops.map(&:hex).map { |hex| hex.name }
          mines = stop_hexes & MINE_HEXES
          galena = stop_hexes & GALENA
          return mines.count * 10 + galena.count * 30
        end

        def port_revenue_removal(route, stops)
          return 0 if route.corporation.assignments.include?(PORT_ICON)
          stop_hexes = stops.map(&:hex).map { |hex| hex.name }
          st_paul = stop_hexes & ST_PAUL
          lake_michigan = stop_hexes & LAKE_MICHIGAN
          port_of_memphis = [0]
          port_of_memphis << stop_hexes & PORT_OF_MEMPHIS unless hex_by_id('D23').tile.name == 'D23'
          return ((st_paul.count * 50) + ((port_of_memphis.count - 1) * 30) + (lake_michigan.count * 20))
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

        def revenue_for(route, stops)
          revenue = super
          revenue += ew_ns_bonus(stops)[:revenue] + p_bonus(route, stops)
          revenue = revenue - mine_revenue_removal(route, stops) - port_revenue_removal(route, stops)
          return revenue
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
          others = route_distance(route) - mines - ports - galena
          str = others.to_s
          str += "+#{mines + galena}m" if (mines.positive? || galena.positive?) && route.corporation.assignments.include?(MINE_ICON)
          str += "+#{ports}p" if ports.positive? && route.corporation.assignments.include?(PORT_ICON)
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
        
        def check_3P(route, visits)
          return unless route.train.name == '3P'
          raise GameError, 'Cannot visit red areas' if visits.first.tile.color == :red || visits.last.tile.color == :red
        end

        def check_rogers(route, visits)
          return unless route.train.name == 'Rogers (1+1)'  
          return if ( visits.first.hex.name == 'E12' && visits.last.hex.name == 'D13' ) || ( visits.last.hex.name == 'E12' && visits.first.hex.name == 'D13' )
          raise GameError, "'Rogers' train can only run between Springfield and Jacksonville"
        end

        def check_distance(route, visits)
          #checks STL for permit token
          check_stl(visits)

          #disallows 3P trains from running to red areas
          check_3P(route, visits)

          #disallows Rogers train from running outside of Springfield/Jacksonville
          check_rogers(route, visits)

          return super
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

        def process_single_action(action)
          if action.user && action.user != acting_for_player(action.entity&.player)&.id && action.type != 'message'
            @log << "• Action(#{action.type}) via Master Mode by: #{player_by_id(action.user)&.name || 'Owner'}"
          end
  
          preprocess_action(action)

          case action
            when Action::PlaceToken
              #@log << "action processed ****** #{action}  #{action.class} #{action.entity}"
              if action.entity.kind_of? Company
                if (action.entity.sym == "GTL") 
                  _corp = get_owner("GTL")
                end
              end
            when Action::LayTile
              if action.entity.kind_of? Company
                if ((action.entity.sym == "SMBT") ||
                    (action.entity.sym == "FWC") ||
                    (action.entity.sym == "CVCC")) 
                    _corp = get_owner(action.entity.sym)
                end
              end
          end
  
          @round.process_action(action)
  
          action_processed(action)

          case action
            when Action::PlaceToken
              #@log << "action processed ****** #{action}  #{action.class} #{action.entity}"
              if action.entity.kind_of? Company
                if (action.entity.sym == "GTL") 
                  _corp.assign!(PORT_ICON) if _corp
                  log << "#{_corp.name} receives a port marker"
                end
              end
            when Action::LayTile
            if action.entity.kind_of? Company
              if (action.entity.sym == "SMBT") 
                _corp.assign!(PORT_ICON) if _corp
                _corp.assign!(PORT_ICON.dup) if _corp
                log << "#{_corp.name} receives two port markers"
              elsif
                if ((action.entity.sym == "FWC") || 
                    (action.entity.sym == "CVCC"))
                  _corp.assign!(MINE_ICON) if _corp
                  log << "#{_corp.name} receives a mine marker"
                end
              end
            end
          end
      
          end_timing = game_end_check&.last
          end_game! if end_timing == :immediate
  
          while @round.finished? && !@finished
            @round.entities.each(&:unpass!)
  
            if end_now?(end_timing) || @turn >= 100
              end_game!
            else
              transition_to_next_round!
            end
          end
          # rescue Engine::GameError => e
          #  rescue_exception(e, action)
        end

        def get_owner(sym)
          corporations.each do |corp|
            corp.companies.each do |c|
              #@log << "#{c.sym}  #{sym}"
              if (c.sym == sym) 
                #log << "match"
                return corp
              end
            end
          end
          nil
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.is_a?(Engine::Step::BuySellParShares) }.active?
          return [] if entity.share_price.acquisition? || entity.share_price.liquidation?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        #--------------------------------IC Formation-------------------------------------------------------#

        def ic
          @ic_corporation ||= corporation_by_id('IC')
        end

        def ic_setup
          float_corporation(ic)
          bundle = ShareBundle.new(ic.shares[4..8])
          @share_pool.transfer_shares(bundle, @share_pool)

          stock_market.set_par(ic, @stock_market.par_prices.find do |p|
              p.price == IC_STARTING_PRICE
          end)
          @bank.spend(IC_STARTING_PRICE * 10,ic)
          @log << "#{ic.name} is parred at #{format_currency(IC_STARTING_PRICE)} and receives #{format_currency(IC_STARTING_PRICE * 10)} from the bank"

          no_buy = abilities(ic, :no_buy)
          ic.remove_ability(no_buy)
      
          ic.tokens << Engine::Token.new(ic, price:0)
          place_home_token(ic)  
        end

        def event_ic_formation!
          @log << "-- Event: Illinois Central Formation --"
          @mergeable_candidates = mergeable_corporations

          ic_setup

          option_cube_exchange

          if @mergeable_candidates.any?
            @log << "Merge candidates: #{present_mergeable_candidates(@mergeable_candidates)}"
          else
            @log << "IC forms with no merger"
          end
        end

        def option_cube_exchange
          #option cubes are exchanged for IC shares from the market at a rate of 2:1
          @corporations.each do |corp|
            while @option_cubes[corp] > 1
              @option_cubes[corp] -= 2
              bundle = ShareBundle.new(@share_pool.shares_of(ic).last)
              @share_pool.transfer_shares(bundle, corp)
              @log << "#{corp.name} exchanges two option cubes for a 10% share of #{ic.name}"
             @option_cubes.delete(corp) if @option_cubes[corp] == 0
            end
          end

          #each corp with one remaining option cube is given a choice between exchanging it for $40 or paying $40 for a share of IC
          @exchange_choice_corps ||= []
          @corporations.each { |corp|
            if @option_cubes[corp] == 1
              @exchange_choice_corps << corp
            end
          }
          @exchange_choice_corps.sort!
          @exchange_choice_corps.each { |corp|
            @exchange_choice_corp = corp
          }
        end

        def option_exchange(corp)
          cost = ic.share_price.price / 2
          corp.spend(cost, @bank)
          bundle = ShareBundle.new(@share_pool.shares_of(ic).last)
          @share_pool.transfer_shares(bundle, corp)
          @log << "#{corp.name} pays #{format_currency(cost)} and exchanges option cube for a 10% share of #{ic.name}"
          @option_cubes[corp] -= 1
        end

        def option_sell(corp)
          refund = ic.share_price.price / 2
          @bank.spend(refund, corp)
          if ic.num_market_shares.positive?
            @log << "#{corp.name} sells option cube for #{format_currency(refund)}"
          else
            @log << "#{corp.name} sells option cube for #{format_currency(refund)} (#{ic.name} has no market shares to exchange)"
          end
          @option_cubes[corp] -= 1
        end

        def decline_merge(corporation)
          @log << "#{corporation.name} declines"
          @mergeable_candidates.delete(corporation)
          post_ic_formation if @mergeable_candidates.empty?
        end

        def merge_decider
          @mergeable_candidates.first
        end
        
        def mergeable_candidates
          @mergeable_candidates ||= []
        end

        def mergeable_corporations
          ic_line_corporations = []
          corp = @corporations.select {|c| c.tokens.find {|t| t.hex == hex_by_id('H7')}}.first
          ic_line_corporations << corp unless corp.nil?
          corp = @corporations.select {|c| c.tokens.find {|t| t.hex == hex_by_id('G10')}}.first
          ic_line_corporations << corp unless corp.nil?
          corp = @corporations.select {|c| c.tokens.find {|t| t.hex == hex_by_id('F17')}}.first
          ic_line_corporations << corp unless corp.nil?
          corp = @corporations.select {|c| c.tokens.find {|t| t.hex == hex_by_id('E22')}}.first
          ic_line_corporations << corp unless corp.nil?
          ic_line_corporations
        end

        def present_mergeable_candidates(mergeable_candidates)
          mergeable_candidates.map do |c|
            controller_name = c.player.name
            "#{c.name} (#{controller_name})"
          end.join(', ')
        end

        def merge_corporation_part_one(corporation = nil)
          @mergeable_candidates.delete(corporation)
          @merged_corporation = corporation
          @log << "-- #{corporation.name} merges into #{ic.name} --"

          # Shares other than president's share are refunded- non-president-owned shares at full price, president-owned shares at half price.
          refund = corporation.share_price.price
          @merge_share_prices ||= [ic.share_price.price]
          @merge_share_prices << refund
          @total_refund = 0.0

          #Check if corporation has enough cash to compensate shareholders. If not, all of its money is returned to the bank.
          (@players + @corporations).each do |entity|
            entity.shares_of(corporation).dup.each do |share|
              next unless share
              if corporation != entity  && !share.president
                modifier = 1.0 if corporation.owner != entity
                modifier = 0.5 if corporation.owner == entity #President's shares would be compensated at half value.
                @total_refund += (refund * modifier)
              end
            end
          end

          (@players + @corporations).each do |entity|
            entity.shares_of(corporation).dup.each do |share|
              next unless share
                @exchange_choice_player = entity if share.president #president is given option of exchange corp's president's share for share of IC or the corp's current value
            end
          end
        end

        def presidency_exchange(player)
          bundle = ShareBundle.new(ic.shares_of(ic).first)
          @share_pool.transfer_shares(bundle, player)
          @log << "#{player.name} exchanges the president's share of #{@merged_corporation.name} for a 10% share of #{ic.name}"
        end

        def presidency_sell(player)
          refund = @merged_corporation.share_price.price
          @bank.spend(refund,player)
          @log << "#{player.name} discards the president's share of #{@merged_corporation.name} for #{format_currency(refund)}"
        end

        def merge_corporation_part_two
          corporation = @merged_corporation
          if corporation.cash < @total_refund
              @log << "#{corporation.name} does not have enough cash to compensate shares. #{corporation.name}'s cash is returned to the bank. The bank will guarantee non-president shares"
              corporation.cash = 0
          end

          refund = corporation.share_price.price
          #Player's shares are compensated from the corporation if it has enough money; otherwise, they are compensated from the bank.
          (@players + @corporations).each do |entity|
            refund_amount = 0.0
            entity.shares_of(corporation).dup.each do |share|
              next unless share        
              # Refund 10% share
              refund_amount += refund if corporation != entity && !share.president
            end
            next unless refund_amount.positive?
            if corporation.cash == 0
              if corporation.owner != entity
                @bank.spend(refund_amount,entity)
                @log << "#{entity.name} receives #{format_currency(refund_amount)} in share compensation from bank"
              end
            else
              refund_amount = refund_amount / 2 if corporation.owner == entity
              refund_amount = refund_amount.ceil
              corporation.spend(refund_amount,entity)
              @log << "#{entity.name} receives #{format_currency(refund_amount)} in share compensation from #{corporation.name}"
            end
          end

          #The merging corporation's token is found and replaced with IC's token
          ic_tokens = ic.tokens.reject(&:city)
          corporation_token = corporation.tokens.find {|t| t.hex == hex_by_id('H7')} ||
          corporation.tokens.find {|t| t.hex == hex_by_id('G10')} ||
          corporation.tokens.find {|t| t.hex == hex_by_id('F17')} ||
          corporation.tokens.find {|t| t.hex == hex_by_id('E22')}
          ic.tokens << Engine::Token.new(ic, price:0)
          replace_token(corporation, corporation_token, ic_tokens)

          # If the corporation has any money, it is transferred to IC
          if corporation.cash.positive?
            treasury = format_currency(corporation.cash)
            @log << "#{ic.name} receives the #{corporation.name} treasury of #{treasury}"
            corporation.spend(corporation.cash, ic)
          end

          # If the corporation has any trains, they are transferred to IC
          if corporation.trains.any?
            trains_transfered = transfer(:trains, corporation, ic).map(&:name)
            @log << "#{ic.name} receives #{trains_transfered.one? ? "a train" : "trains"} from #{corporation.name}: #{trains_transfered.join(", ")}"
          end

          close_corporation(corporation)
          post_ic_formation if @mergeable_candidates.empty?
        end
      
        def receivership?(corporation)
          corporation.shares[0].owner == corporation
        end

        def ic_reserve_tokens
          @slot_open = true
          count = ic.tokens(&:city).count - 2
          ic.tokens << Engine::Token.new(ic, price:0)
          ic_tokens = ic.tokens.reject(&:city)
          while count < 2
            hex = ic_line_token_locations(ic)
            city = hex.tile.cities.first
            if @slot_open == true
              city.place_token(ic, ic_tokens.first, free: true, check_tokenable: false)
            else
              city.place_token(ic, ic_tokens.first, free: true, check_tokenable: false, cheater: false, extra_slot: true) 
            end
            @log << "#{ic.name} places a token in #{city.hex.name} (#{hex.tile.location_name})"
            count += 1
          end
          #IC gets additional tokens
          while ic.tokens.count < 7
            ic.tokens << Engine::Token.new(ic, price:0)
          end
        end

        def ic_line_token_locations(corporation)
          selected_hexes = hexes.select do |hex|
          IC_LINE_HEXES.include?(hex.id) && hex.tile.cities.any? { |city| !city.tokened_by?(ic) && city.tokenable?(corporation, free: true) }
          end
          @slot_open = true
          if selected_hexes.empty?
            selected_hexes = hexes.select do |hex|
              IC_LINE_HEXES.include?(hex.id) && hex.tile.cities.any? { |city| !city.tokened_by?(ic) && city.tokenable?(corporation, free: true, tokens: corporation.tokens_by_type, cheater: false, extra_slot: true) }
            end
            @slot_open = false
          end
          selected_hexes.last
        end

        def post_ic_formation
          #IC gains station markers and places additional markers if fewer than two mergers occur
          ic_reserve_tokens

          #calculate IC's new share price - the average of merged corporations' share prices and $80
          if @merge_share_prices == nil
            price = ic.share_price.price
          else
          price = @merge_share_prices.sum/@merge_share_prices.count
          end
          ic_new_share_price = @stock_market.market.first.max_by { |p| p.price <= price ? p.price : 0 }
          @log << "#{ic.name}'s new share price is #{format_currency(ic_new_share_price.price)}"
          ic.share_price.corporations.delete(ic)
          stock_market.set_par(ic, ic_new_share_price)

          #IC enters receivership if there is no president
          if receivership?(ic)
            @log << "#{ic.name} enters receivership (it has no president)"
            #TODO: how to actually flag it as in receivership?
          end
          @log << "-- Event: Illinois Central Formation complete --"
        end

        def replace_token(corporation, corporation_token, ic_tokens)
          city = corporation_token.city
          @log << "#{corporation.name}'s token in #{city.hex.name} (#{city.hex.tile.location_name}) is replaced with an #{ic.name} token"
          ic_replacement = ic_tokens.first
          corporation_token.remove!
          city.place_token(ic, ic_replacement, free: true, check_tokenable: false)
          ic_tokens.delete(ic_replacement)
        end
        #-------------------------------------------------------------------------------------------#

        def extra_station
          @extra_station = @companies.find { |c| c.name == "Extra Station" }
        end

        def goodrich_transit_line
          @goodrich_transit_line = @companies.find { |c| c.name == "Goodrich Transit Line" }
        end

        def rush_delivery
          @rush_delivery = @companies.find { |c| c.name == "Rush Delivery" }
        end

        def station_subsidy
          @station_subsidy = @companies.find { |c| c.name == "Station Subsidy" }
        end

        def share_premium
          @share_premium = @companies.find { |c| c.name == "Share Premium" }
        end

        def steamboat
          @steamboat = @companies.find { |c| c.name == "Steamboat" }
        end

        def train_subsidy
          @train_subsidy = @companies.find { |c| c.name == "Train Subsidy" }
        end

        def us_mail_line
          @us_mail_line = @companies.find { |c| c.name == "U.S. Mail Line" }
        end

        def advanced_track
          @advanced_track = @companies.find { |c| c.name == "Advanced Track" }
        end

        def central_illinois_boom
          @central_illinois_boom = @companies.find { |c| c.name == "Central Illinois Boom" }
        end

        def chicago_virden_coal_company
          @chicago_virden_coal_company = @companies.find { |c| c.name == "Chicago-Virden Coal Company" }
        end

        def diverse_cargo
          @diverse_cargo = @companies.find { |c| c.name == "Diverse Cargo" }
        end

        def engineering_mastery
          @engineering_mastery = @companies.find { |c| c.name == "Engineering Mastery" }
        end

        def frink_walker_co
          @frink_walker_co = @companies.find { |c| c.name == "Frink, Walker, & Co." }
        end

        def illinois_steel_bridge_company
          @illinois_steel_bridge_company = @companies.find { |c| c.name == "Illinois Steel Bridge Company" }
        end

        def lincoln_funeral_car
          @lincoln_funeral_car = @companies.find { |c| c.name == "Lincoln Funeral Car" }
        end

      end
    end
  end
end