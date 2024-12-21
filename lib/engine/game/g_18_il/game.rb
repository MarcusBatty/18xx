# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'corporations'
require_relative 'companies'
require_relative 'map'
require_relative 'tiles'
require_relative 'trains'
require_relative 'market'
require_relative 'phases'
require_relative '../../loan'

module Engine
  module Game
    module G18IL
      class Game < Game::Base
        include_meta(G18IL::Meta)
        include Corporations
        include Companies
        include Map
        include Tiles
        include Trains
        include Market
        include Phases

        attr_accessor :stl_nodes, :blocking_token, :exchange_choice_player, :exchange_choice_corp,
                      :exchange_choice_corps, :sp_used, :borrowed_trains, :train_borrowed, :closed_corporations,
                      :other_train_pass, :lincoln_triggered, :corporate_buy, :emr_active

        attr_reader :merged_corporation, :last_set_triggered, :ic_line_completed_hexes, :insolvent_corporations,
                    :port_corporations, :mine_corporations

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '$%s'
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        BANK_CASH = 99_999
        CAPITALIZATION = :incremental
        CERT_LIMIT = { 2 => 24, 3 => 18, 4 => 15, 5 => 13, 6 => 11 }.freeze
        STARTING_CASH = { 2 => 800, 3 => 640, 4 => 480, 5 => 360, 6 => 300 }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'signal_end_game' => ['Signal End Game', 'Game Ends 3 ORs after purchase of first D train']
          # 'signal_end_game' => ['Signal End Game', 'Game Ends 3 ORs after purchase/export of first D train']
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'pullman_strike' => ['Pullman Strike (after end of next OR)', '4+2P and 5+1P trains are downgraded to 4- and 5-trains'],
        )

        POOL_SHARE_DROP = :down_share
        BANKRUPTCY_ALLOWED = false
        CERT_LIMIT_INCLUDES_PRIVATES = false
        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true

        TILE_LAYS = [
          { lay: true, upgrade: true, cost: 0 },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :always
        DISCARDED_TRAINS = :remove

        GAME_END_CHECK = {
          final_phase: :one_more_full_or_set,
          stock_market: :current_or,
        }.freeze

        SELL_AFTER = :operate
        SELL_MOVEMENT = :none
        SOLD_OUT_INCREASE = true
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        CLOSED_CORP_TRAINS_REMOVED = false
        CLOSED_CORP_TOKENS_REMOVED = false
        CLOSED_CORP_RESERVATIONS_REMOVED = false

        PORT_HEXES = %w[B1 D23 H1 I2].freeze
        MINE_HEXES = %w[C2 D9 D13 D17 E6 E14 E16 F5 F13 F21 G22 H11].freeze
        DETROIT = ['I6'].freeze
        ST_PAUL = ['B1'].freeze
        PORT_OF_MEMPHIS = ['D23'].freeze
        LAKE_MICHIGAN = ['H1'].freeze
        CLASS_A_COMPANIES = %w[].freeze
        CLASS_B_COMPANIES = %w[].freeze
        PORT_TILES = %w[SPH POM].freeze
        STL_HEXES = %w[B15 B17 C16 C18].freeze
        STL_TOKEN_HEX = ['C18'].freeze
        CHICAGO_HEX = ['H3'].freeze
        SPRINGFIELD_HEX = 'E12'.freeze
        CORPORATION_SIZES = { 2 => :small, 5 => :medium, 10 => :large }.freeze
        PORT_ICON = 'port'.freeze
        MINE_ICON = 'mine'.freeze
        IC_STARTING_PRICE = 80.freeze
        IC_LINE_HEXES = %w[H7 G10 F17 E22].freeze
        BOOM_HEXES = %w[E8 E12].freeze

        PORT_TILE_HEXES = {
          'B1' => ['SPH', 0],
          'D23' => ['POM', 0],
        }.freeze

        ASSIGNMENT_TOKENS = {
          'port' => '/icons/18_il/port.svg',
          'port ' => '/icons/18_il/port.svg',
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

        BLOCKING_LOGOS = [
          '/logos/18_il/yellow_blocking.svg', '/logos/18_il/green_blocking.svg',
          '/logos/18_il/brown_blocking.svg', '/logos/18_il/gray_blocking.svg'
        ].freeze

        IMMOBILE_SHARE_PRICE_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'Share price may not change',
          desc_detail: 'Share price may not change while IC is trainless.'
        )
        FORCED_WITHHOLD_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'May not pay dividends',
          desc_detail: 'Must withhold earnings while IC is trainless.'
        )
        BORROW_TRAIN_ABILITY = Ability::BorrowTrain.new(
          type: 'borrow_train',
          train_types: %w[2 3 4 4+2P 5+1P 6 D],
          description: 'Must borrow train',
          desc_detail: 'While trainless, IC must borrow the cheapest-available train from the Depot when running trains.'
        )
        RECEIVERSHIP_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'Modified oper. turn (receivership)',
          desc_detail: 'IC only performs the "run trains" and "buy trains" steps during '\
                       'its operating turns while in receivership.'
        )
        OPERATING_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'Modified operating turn',
          desc_detail: 'IC only performs the "lay track", "place token", "scrap trains", "run trains", '\
                       ' and "buy trains" steps during its operating turns.'
        )
        TRAIN_BUY_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'Modified train buy',
          desc_detail: 'IC can only buy trains from the bank and can only buy one train per round. '\
                       'IC is not required to own a train, but must buy a train if possible. '\
                       'Corporations may not purchase permanent trains from IC.'
        )
        TRAIN_LIMIT_ABILITY = Ability::TrainLimit.new(
          type: 'train_limit',
          increase: 1,
          description: 'Train limit + 1',
          desc_detail: "IC's train limit is one higher than the current limit"
        )
        STOCK_PURCHASE_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'Modified stock purchase',
          desc_detail: 'IC treasury shares are only available for purchase in concession rounds.'
        )
        FORMATION_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'Unavailable until IC Formation',
          desc_detail: 'IC is unavailable until the IC Formation, which occurs immediately after the operating turn '\
                       ' of the corporation that completes the IC Line.'
        )

        def next_round!
          @round =
            case @round
            when Engine::Round::Auction
              clear_programmed_actions
              new_stock_round
            when Engine::Round::Stock
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
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
            G18IL::Step::ConcessionAuction,
          ])
        end

        def stock_round
          G18IL::Round::Stock.new(self, [
            G18IL::Step::HomeToken,
            G18IL::Step::BuyNewTokens,
            G18IL::Step::BaseBuySellParShares,
          ])
        end

        def operating_round(round_num)
          if @optional_rules.include?(:intro_game)
            Engine::Round::Operating.new(self, [
              Engine::Step::Exchange,
              G18IL::Step::SpecialTrack,
              Engine::Step::SpecialToken,
              Engine::Step::HomeToken,
              G18IL::Step::ExchangeChoiceCorp,
              G18IL::Step::ExchangeChoicePlayer,
              G18IL::Step::Merge,
              Engine::Step::DiscardTrain,
              G18IL::Step::Conversion,
              G18IL::Step::PostConversionShares,
              G18IL::Step::BuyNewTokens,
              G18IL::Step::CorporateIssueBuyShares,
              G18IL::Step::Track,
              G18IL::Step::Token,
              G18IL::Step::BorrowTrain,
              G18IL::Step::CorporateSellShares,
              G18IL::Step::Route,
              G18IL::Step::Dividend,
              G18IL::Step::SpecialBuyTrain,
              G18IL::Step::BuyTrain,
              [G18IL::Step::BuyCompany, { blocks: true }],
            ], round_num: round_num)
          else
            Engine::Round::Operating.new(self, [
              G18IL::Step::DiverseCargoChoice,
              G18IL::Step::MineCompanyChoice,
              Engine::Step::Exchange,
              G18IL::Step::SpecialTrack,
              Engine::Step::SpecialToken,
              Engine::Step::HomeToken,
              G18IL::Step::ExchangeChoiceCorp,
              G18IL::Step::ExchangeChoicePlayer,
              G18IL::Step::Merge,
              Engine::Step::DiscardTrain,
              G18IL::Step::Conversion,
              G18IL::Step::PostConversionShares,
              G18IL::Step::BuyNewTokens,
              G18IL::Step::SpecialIssueShares,
              G18IL::Step::CorporateIssueBuyShares,
              G18IL::Step::Track,
              G18IL::Step::ExtraStationChoice,
              G18IL::Step::Token,
              G18IL::Step::LincolnChoice,
              G18IL::Step::BorrowTrain,
              G18IL::Step::CorporateSellShares,
              G18IL::Step::BuyTrainBeforeRunRoute,
              G18IL::Step::Route,
              G18IL::Step::Dividend,
              G18IL::Step::SpecialBuyTrain,
              G18IL::Step::BuyTrain,
              [G18IL::Step::BuyCompany, { blocks: true }],
            ], round_num: round_num)
          end
        end

        def tile_lays(entity)
          return super if @optional_rules.include?(:intro_game) || engineering_mastery&.owner != entity

          # Base tile lay for Engineering Mastery
          tile_lays = [{ lay: true, upgrade: true, cost: 0, cannot_reuse_same_hex: true }]

          # Add an upgrade option for $30 (if the first upgrade was used)
          if @round.upgraded_track
            tile_lays << { lay: true, upgrade: true, cost: 20, upgrade_cost: 30, cannot_reuse_same_hex: true }
          else
            # Add an upgrade option for $20 (if the first upgrade as not used)
            tile_lays << { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true } unless @round.upgraded_track
          end
          tile_lays
        end

        def company_closing_after_using_ability(company, silent = false)
          @log << "#{company.name} (#{company.owner.name}) closes" unless silent
        end

        def status_array(corp)
          status = []
          company = @companies.find { |c| !c.closed? && c.sym == corp.name }
          status << "Concession: #{company.owner.name}" if company&.owner&.player?
          status << "Option cubes: #{@option_cubes[corp]}" if (@option_cubes[corp]).positive?
          status << "Loan amount: #{format_currency(corp.loans.first.amount)}" unless corp.loans.empty?
          status << 'Has not operated' if !corp.operated? && corp.floated?
          if @round.is_a?(G18IL::Round::Stock)
            reserve_players = @players.reject { |p| @round.reserve_bought[p][corp].empty? }.map(&:name)
            status << "#{reserve_players.join(', ')} may not sell shares" unless reserve_players.empty?
          end
          status.empty? ? nil : status
        end

        def init_round
          new_concession_round
        end

        def corporations_can_ipo?
          # This override ensures the corporate_buy_sell_shares view is used
          true
        end

        def next_sr_position(entity)
          player_order = @round.current_entity&.player? ? @round.pass_order : @players
          player_order.index(entity)
        end

        def new_concession_round
          @log << "-- Concession Round #{@turn} --"
          concession_round
        end

        def can_par?(corporation, entity)
          return false unless concession_ok?(entity, corporation)

          super
        end

        def ic
          @ic ||= corporation_by_id('IC')
        end

        def concession_ok?(player, corp)
          return false unless player.player?

          player.companies.any? { |c| c.sym == corp.name }
        end

        def return_concessions!
          companies.select { |company| company.meta[:type] == :concession }.each do |c|
            next unless c&.owner&.player?

            player = c.owner
            player.companies.delete(c)
            c.owner = nil
            @log << "#{c.name} (#{c.sym}) has not been used by #{player.name} and is returned to the concession row"
          end
        end

        def finish_stock_round
          return_concessions!

          return if !ic_in_receivership? || !ic_formation_triggered?

          ic.owner = @players.min_by { rand }
          @log << "#{ic.name} is in receivership and will be operated "\
                  "by the player with priority deal (#{priority_deal_player.name})"
        end

        def initial_auction_companies
          companies
        end

        def company_status_str(company)
          return if company.owner || company.meta[:type] != :private

          if @optional_rules&.include?(:intro_game)
            corporation = corporation_by_id(company.sym)
            return 'Starts with mine marker' if mine_corporation?(corporation)
            return 'Starts with port marker' if port_corporation?(corporation)
          else
            case company.meta[:type]
            when :private
              company.meta[:class] == :A ? 'Class A' : 'Class B'
            when :concession
              corp = @corporations.find { |c| c.name == company.sym }
              return unless corp

              a = corp.companies[0]
              b = corp.companies[1]
              [].tap do |status|
                status << "A: #{a.name}" if a
                status << "B: #{b.name}" if b
              end.join(' ')
            end
          end
        end

        def company_header(company)
          case company.meta[:type]
          when :share then 'ORDINARY SHARE'
          when :presidents_share then "PRESIDENT'S SHARE"
          when :concession then 'CONCESSION'
          end
        end

        def corporation_size(entity)
          # change stock market token size based on share count of corporation
          CORPORATION_SIZES[entity.total_shares]
        end

        def corporation_size_name(entity)
          entity.total_shares.to_s
        end

        def float_str(_entity)
          '2 shares to start'
        end

        def nc
          @nc ||= corporation_by_id('NC')
        end

        def ic_formation_triggered?
          @ic_formation_triggered
        end

        def stlbc
          @stl_blocking_corp
        end

        def find_company_by_name(name)
          @companies.find { |c| c&.name == name }
        end

        def optional_hexes
          return game_hexes unless @optional_rules.include?(:intro_game)

          hexes = game_hexes

          hexes[:white].delete(['C2'])
          hexes[:yellow][['C2']] = 'town=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=G'
          hexes[:red][['B3']] = 'label=W;offboard=revenue:yellow_30|brown_40,groups:West;path=a:4,b:_0;path=a:0,b:_0;'\
                                'border=edge:0;border=edge:5'
          hexes
        end

        def setup_preround
          super

          # Create and initialize the blocking corporation for placing blocking tokens in STL
          create_blocking_corp

          # Set up corporations for intro game or regular game setup
          @optional_rules&.include?(:intro_game) ? intro_game_setup : initial_auction_lot
        end

        # Create the corporation that places blocking tokens in St. Louis
        def create_blocking_corp
          # Initialize the blocking corporation with its logos and tokens
          @stl_blocking_corp = Corporation.new(
            sym: 'STLBC', name: 'stl_blocking_corp', logo: BLOCKING_LOGOS[0],
            simple_logo: BLOCKING_LOGOS[0], tokens: [0]
          )
          @stl_blocking_corp.owner = @bank

          # Find the city where the blocking tokens will be placed
          city = @hexes.find { |hex| hex.id == 'C18' }.tile.cities.first

          # Place blocking tokens in the city for each color
          BLOCKING_LOGOS.each do |logo|
            token = Token.new(@stl_blocking_corp, price: 0, logo: logo, simple_logo: logo, type: :blocking)
            city.place_token(@stl_blocking_corp, token, check_tokenable: false)
          end
        end

        # Setup corporations for intro game
        def intro_game_setup
          @marker_corporations = @corporations.select(&:floatable)
          @port_corporations = @marker_corporations.min_by(4) { rand }
          @mine_corporations = @marker_corporations - @port_corporations
        end

        # Set up corporations for auction lot formation in the regular game
        def initial_auction_lot
          class_a = @companies.select { |c| c.meta[:class] == :A }
          class_b = @companies.select { |c| c.meta[:class] == :B }

          class_a = class_a.sort_by { rand }
          class_b = class_b.sort_by { rand }

          @log << '-- Auction Lot Formation --'

          @corporations.select(&:floatable).each_with_index do |corp, index|
            [class_a, class_b].each do |class_list|
              company = class_list[index]
              company.owner = corp
              corp.companies << company
            end
            @log << "#{class_a[index].name} and #{class_b[index].name} assigned to #{corp.name} concession"
          end
        end

        def setup
          @companies.each do |c|
            if c.meta[:type] == :private
              method_name = c.name.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
              self.class.send(:define_method, method_name) { c }
            end
          end

          ic.add_ability(self.class::FORMATION_ABILITY)
          ic.owner = nil
          @corporation_debts = Hash.new { |h, k| h[k] = 0 }
          @insolvent_corporations = []
          @lincoln_triggered = nil
          @last_set_triggered = nil
          @ic_president = nil
          @ic_owns_train = false
          @ic_formation_triggered = nil
          @closed_corporations = []
          @train_borrowed = nil
          @borrowed_trains = {}
          @merged_corps = []
          @ic_trigger_entity = nil
          @emr_active = nil
          @ic_formation_pending = false
          @option_cubes ||= Hash.new(0)
          @ic_line_completed_hexes = []

          # Northern Cross starts with the 'Rogers' train
          train = @depot.upcoming[0]
          train.buyable = false
          buy_train(nc, train, :free)

          @corporations.select { |corp| corp.type == :two_share }.each { |c| c.max_ownership_percent = 100 }

          if !@optional_rules&.include?(:intro_game) && (share_premium&.owner&.total_shares == 10)
            share_premium&.owner&.ipo_shares&.last&.buyable = false
          end

          @stl_nodes = STL_HEXES.map do |h|
            hex_by_id(h).tile.nodes.find { |n| n.offboard? && n.groups.include?('STL') }
          end

          return unless @optional_rules&.include?(:intro_game)

          # Assigns port and mine markers to corporations
          assign_port_markers(port_corporations)
          assign_mine_markers(mine_corporations)

          # Place random port tile on map
          selected_port = PORT_TILE_HEXES.keys.min_by { rand }
          selected_hex = hexes.find { |h| h.name == selected_port }
          lay_starting_port_tile(selected_hex)

          # Removes other port tile, M1 tile, and G1 tile
          @all_tiles.each { |tile| tile.hide if tile.color == :blue || tile.name == 'G1' || tile.name == 'M1' }
        end

        def lay_starting_port_tile(hex)
          tile_name, rotation = PORT_TILE_HEXES[hex.name]
          hex.lay(@all_tiles.find { |t| t.name == tile_name }.rotate!(rotation))
          @log << "Port tile ##{tile_name} with rotation #{rotation} is laid on #{hex.id}"
        end

        def assign_port_markers(_entity)
          port_log = []

          port_corporations.each do |c|
            assign_port_icon(c)
            port_log << c.name
          end

          if port_corporations.size > 1
            last_item = port_log.pop
            port_log[-1] = "#{port_log[-1]}, and #{last_item}"
          end

          @log << "#{port_log.join(', ')} receive port markers"
        end

        def assign_mine_markers(_entity)
          mine_log = []

          mine_corporations.each do |c|
            assign_mine_icon(c)
            mine_log << c.name
          end

          if mine_corporations.size > 1
            last_item = mine_log.pop
            mine_log[-1] = "#{mine_log[-1]}, and #{last_item}"
          end

          @log << "#{mine_log.join(', ')} receive mine markers"
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

        def emr_active?
          @emr_active
        end

        def company_sellable(company); end

        # allows blue tile lays at any time
        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          return true if tile.name == 'SPH' || tile.name == 'POM'

          return true if tile.name == 'M1'

          super
        end

        # allows blue-on-blue tile lays
        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if PORT_TILE_HEXES.include?(from.hex.id) && (from.color == :blue && to.color == :blue)

          # P4 and S4 are available in intro game, but only available to Central Illinois Boom in normal game
          if !@optional_rules&.include?(:intro_game) && BOOM_HEXES.include?(from.hex.id)
            if selected_company != central_illinois_boom || phase.name != 'D'
              return false if to.name == 'P4' || to.name == 'S4'
            else
              case from.hex.id
              when 'E8'
                return to.name == 'P4'
              when 'E12'
                return to.name == 'S4'
              end
            end
          end

          return true if !@optional_rules.include?(:intro_game) && MINE_HEXES.include?(from.hex.id) &&
          to.name == 'M1' && selected_company == chicago_virden_coal_company

          super
        end

        def eligible_tokens?(corporation)
          corporation.tokens.find { |t| t.used && !STL_TOKEN_HEX.include?(t.hex.id) }
        end

        def place_home_token(corporation)
          return super unless @closed_corporations.include?(corporation)

          @log << if eligible_tokens?(corporation)
                    "#{corporation.name} must choose token to flip"
                  else
                    "#{corporation.name} must choose city for home token"
                  end
          @round.pending_tokens << {
            entity: corporation,
            hexes: home_token_locations(corporation),
            token: corporation.tokens.first,
          }
          @round.clear_cache!
        end

        def home_token_locations(corporation)
          # if reopened corp has no flipped tokens on map, it can place token in any available city slot except in CHI or STL
          if eligible_tokens?(corporation)
            # if reopened corp has flipped token(s) on map, it can flip one of these tokens (except for STL)
            hexes.select { |hex| hex.tile.cities.find { |c| c.tokened_by?(corporation) && !STL_TOKEN_HEX.include?(hex.id) } }
          else
            hexes.select do |hex|
              hex.tile.cities.any? && hex.tile.cities.select { |c| c.reservations.any? }.empty? &&
              !STL_TOKEN_HEX.include?(hex.id) && !CHICAGO_HEX.include?(hex.id)
            end
          end
        end

        def ic_owns_train
          return if @ic_owns_train

          @ic_owns_train = true
          abilities_to_remove = [
            self.class::FORCED_WITHHOLD_ABILITY,
            self.class::IMMOBILE_SHARE_PRICE_ABILITY,
            self.class::BORROW_TRAIN_ABILITY,
          ]

          abilities_to_remove.each { |ability| ic.remove_ability(ability) }
        end

        def ic_needs_train
          return if @ic_needs_train

          @ic_needs_train = true
          abilities_to_add = [
            self.class::FORCED_WITHHOLD_ABILITY,
            self.class::IMMOBILE_SHARE_PRICE_ABILITY,
            self.class::BORROW_TRAIN_ABILITY,
          ]

          abilities_to_add.each { |ability| ic.add_ability(ability) }
        end

        def close_corporation(corporation)
          @closed_corporations << corporation
          @log << "#{corporation.name} closes"
          @round.force_next_entity! if @round.current_entity == corporation

          # un-IPO the corporation
          corporation.share_price&.corporations&.delete(corporation)
          corporation.share_price = nil
          corporation.par_price = nil
          corporation.ipoed = false
          corporation.unfloat!

          # move owned shares of other corporations to market
          @corporations.each do |c|
            next if c == corporation

            c.share_holders.keys.each do |share_holder|
              next unless share_holder == corporation

              shares = share_holder.shares_by_corporation[c].compact
              c.share_holders.delete(share_holder)
              shares.each do |share|
                share_holder.shares_by_corporation[c].delete(share)
                share.owner = c
                c.shares_by_corporation[c] << share
                @share_pool.transfer_shares(share.to_bundle, @share_pool)
              end
              c.shares_by_corporation[c].sort_by!(&:index)
            end
          end

          # return shares to IPO
          corporation.share_holders.keys.each do |share_holder|
            next if share_holder == corporation

            shares = share_holder.shares_by_corporation[corporation].compact
            corporation.share_holders.delete(share_holder)
            shares.each do |share|
              share_holder.shares_by_corporation[corporation].delete(share)
              share.owner = corporation
              corporation.shares_by_corporation[corporation] << share
            end
          end
          corporation.shares_by_corporation[corporation].sort_by!(&:index)
          corporation.share_holders[corporation] = 100
          corporation.owner = nil

          # flip all of the corporation's tokens on the map
          corporation.tokens.each do |token|
            token.status = :flipped if token.used
          end

          # home location is removed
          corporation.coordinates = nil

          # reactivate concession
          company = company_by_id(corporation.name)
          company.owner = nil
          @companies << company
          @companies = @companies.sort

          @round.entities.delete(corporation)

          close_corporations_in_close_cell!
        end

        def ic_line_hex?(hex)
          IC_LINE_ORIENTATION[hex.name]
        end

        def ic_line_improvement(action)
          hex = action.hex
          icons = hex.tile.icons
          corp = action.entity.corporation

          return if @ic_line_completed_hexes.include?(hex)

          connection_count = ic_line_connections(hex)
          return unless connection_count == 2

          complete_ic_line_for(hex, icons, corp)
          log_ic_line_progress

          return unless ic_line_completed?

          trigger_ic_formation(action)
        end

        def complete_ic_line_for(hex, icons, corp)
          @ic_line_completed_hexes << hex

          icons.each do |icon|
            next unless icon.sticky

            icons.delete(icon)
            @option_cubes[corp] += 1
            @log << "#{corp.name} receives an option cube"
          end
        end

        def log_ic_line_progress
          @log << "IC Line hexes completed: #{@ic_line_completed_hexes.size} of 10"
        end

        def trigger_ic_formation(action)
          @log << 'IC Line is complete'
          @log << "-- The Illinois Central Railroad will form at the end of #{action.entity.name}'s turn --"
          @ic_formation_triggered = true
          @ic_formation_pending = true
          @ic_trigger_entity = action.entity
        end

        def ic_formation_pending?
          @ic_formation_pending
        end

        def ic_line_connections(hex)
          return 0 unless (exits = IC_LINE_ORIENTATION[hex.name])

          paths = hex.tile.paths
          count = 0
          paths.each do |path|
            path.exits.each do |exit|
              (count += 1) if exits.include?(exit)
            end
          end
          count
        end

        def path_to_city(paths, edge)
          paths.find { |p| p.exits == [edge] }
        end

        def ic_line_completed?
          @ic_line_completed_hexes.size == IC_LINE_COUNT
        end

        def remove_icon(hex, icon_names)
          icon_names.each do |name|
            icons = hex.tile.icons
            icons.reject! { |i| name == i.name }
            hex.tile.icons = icons
          end
        end

        def corporation_opts
          two_player? && @optional_rules&.include?(:two_player_share_limit) ? { max_ownership_percent: 70 } : {}
        end

        def convert(corporation)
          shares = @_shares.values.select { |share| share.corporation == corporation }
          corporation.share_holders.clear
          size = corporation.total_shares
          case size
          when 2
            shares[0].percent = 40
            corporation.float_percent = 40
            new_shares = Array.new(3) { |i| Share.new(corporation, percent: 20, index: i + 1) }
          when 5
            shares.each { |share| share.percent = 10 }
            shares[0].percent = 20
            corporation.float_percent = 20
            new_shares = Array.new(5) { |i| Share.new(corporation, percent: 10, index: i + 4) }
          else
            raise GameError, 'Cannot convert 10-share corporation'
          end
          corporation.max_ownership_percent = 60
          corporation.max_ownership_percent = (two_player? && @optional_rules&.include?(:two_player_share_limit) ? 70 : 60)
          shares.each { |share| corporation.share_holders[share.owner] += share.percent }
          new_shares.each { |share| add_new_share(share) }
          if !@optional_rules&.include?(:intro_game) && corporation == share_premium.owner && corporation.total_shares == 10
            corporation.ipo_shares.last.buyable = false
          end
          new_shares
        end

        def add_new_share(share)
          owner = share.owner
          corporation = share.corporation
          corporation.share_holders[owner] += share.percent if owner
          owner.shares_by_corporation[corporation] << share
          @_shares[share.id] = share
        end

        def purchase_tokens!(corporation, count, total_cost, quiet = false)
          count.times { corporation.tokens << Token.new(corporation, price: 0) }
          auto_emr(corporation, total_cost) if corporation.cash < total_cost
          if !@optional_rules.include?(:intro_game) && corporation == station_subsidy.owner
            @log << "#{corporation.name} uses #{station_subsidy.name} and buys"\
                    " #{count} #{count == 1 ? 'token' : 'tokens'} for #{format_currency(total_cost)}"
            token_ability = corporation.all_abilities.find { |a| a.desc_detail == 'Station Subsidy' }
            count.times { token_ability.use! }
            unless token_ability.count.positive?
              station_subsidy.close!
              @log << "#{station_subsidy.name} (#{corporation.name}) closes"
            end
          else
            corporation.spend(total_cost, @bank)
            unless quiet
              @log << "#{corporation.name} buys #{count} #{count == 1 ? 'token' : 'tokens'} for #{format_currency(total_cost)}"
            end
          end
        end

        # sell IPO shares to make up shortfall
        def auto_emr(corp, total_cost)
          diff = total_cost - corp.cash
          return unless diff.positive?

          num_shares = ((2.0 * diff) / corp.share_price.price).ceil
          bundle = ShareBundle.new(corp.shares_of(corp).take(num_shares))
          bundle.share_price = corp.share_price.price / 2.0
          old_price = corp.share_price.price
          sell_shares_and_change_price(bundle, movement: :down_share)
          new_price = corp.share_price.price
          @log << "#{corp.name} raises #{format_currency(bundle.price)} and completes EMR"
          @log << "#{corp.name}'s share price moves down from #{format_currency(old_price)} to #{format_currency(new_price)}"
          @round.recalculate_order if @round.respond_to?(:recalculate_order)
        end

        def all_bundles_for_corporation(share_holder, corporation, shares: nil)
          return [] unless corporation.ipoed

          shares ||= share_holder.shares_of(corporation)
          return [] if shares.empty?

          shares = shares.sort_by { |h| [h.president ? 1 : 0, h.percent] }
          bundle = []
          percent = 0
          all_bundles = shares.each_with_object([]) do |share, bundles|
            bundle << share
            percent += share.percent
            bundles << Engine::ShareBundle.new(bundle, percent)
          end
          if !@optional_rules.include?(:intro_game) && corporation == share_premium.owner &&
            @round.steps.find do |step|
              step.instance_of?(G18IL::Step::SpecialIssueShares)
            end&.active?
            all_bundles.each do |b|
              b.share_price = corporation.share_price.price * 2.0
            end
          # halves the value of corporate-held shares if EMRing
          elsif @round.steps.find do |step|
                  step.instance_of?(G18IL::Step::CorporateSellShares)
                end&.active? &&
            !@round.steps.find do |step|
               step.instance_of?(G18IL::Step::CorporateIssueBuyShares)
             end&.active? &&
             share_holder.is_a?(Corporation)
            all_bundles.each do |b|
              b.share_price = corporation.share_price.price / 2.0
            end
          end
          all_bundles.concat(partial_bundles_for_presidents_share(corporation, bundle, percent)) if shares.last.president

          all_bundles.sort_by(&:percent)
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          corporation = bundle.corporation
          movement = :down_share if emr_active? && bundle.owner == corporation
          @share_pool.sell_shares(bundle, allow_president_change: allow_president_change, swap: swap)
          case movement || sell_movement(corporation)
          when :down_share
            bundle.num_shares.times { @stock_market.move_down(corporation) }
          when :left_share
            bundle.num_shares.times { @stock_market.move_left(corporation) }
          when :none
            nil
          else
            raise NotImplementedError
          end
        end

        def emergency_issuable_cash(corporation)
          return 0 if corporation.trains.any? || @other_train_pass

          emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
        end

        def emergency_issuable_bundles(entity)
          return [] unless entity.cash < @depot.min_depot_price
          return [] unless entity.corporation?
          return [] if entity.num_ipo_shares.zero?

          # @emr_active = true
          bundles = bundles_for_corporation(entity, entity)
          bundles.each { |b| b.share_price = entity.share_price.price / 2.0 }
          eligible, remaining = bundles.partition { |bundle| bundle.price + entity.cash < @depot.min_depot_price }
          remaining.empty? ? [eligible.last].compact : [remaining.first].compact
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] if entity.num_treasury_shares.zero?

          bundles_for_corporation(entity, entity).take(1)
        end

        def borrow_train(action)
          entity = action.entity
          train = action.train
          buy_train(entity, train, :free)
          train.operated = false
          @borrowed_trains[entity] = train
          @log << "#{entity.name} borrows a #{train.name} train"
          @train_borrowed = true
        end

        def scrap_train(train)
          owner = train.owner
          @log << "#{owner.name} scraps a #{train.name} train"
          @depot.reclaim_train(train)
        end

        def or_round_finished
          return if @depot.upcoming.empty?

          # phase 3 starts in OR1.2, which exports all 2-trains and rusts the 'Rogers' train
          return unless @depot.upcoming.first.name == '2'

          depot.export_all!('2')
          phase.next!
          nc.trains.shift
          @log << '-- Event: Rogers (1+1) train rusts --'
          # TODO: remove if not used
          # One train is exported at the end of every OR
          # depot.export! unless phase.name == 'D'
        end

        def or_set_finished
          # no one owns IC if in receivership
          ic.owner = nil if ic_in_receivership?

          # TODO: remove if not used
          # One train is exported at the end of every OR set
          # depot.export! unless phase.name == 'D'

          # convert unstarted corporations at the appropriate time.
          if %w[4 4+2P 5 6 D].include?(@phase.name)
            @corporations.reject { |c| c.floated? || @closed_corporations.include?(c) }.each do |c|
              convert(c) if c.total_shares == 2

              convert(c) if c.total_shares == 5 && @phase.name != '4'
            end
          end

          return unless phase.name == 'D'

          # remove unopened corporations and decrement cert limit
          remove_unparred_corporations!

          @log << "-- Event: Certificate limit adjusted to #{@cert_limit} --"

          @log << '-- Event: All companies close --'

          @companies.select { |company| company.meta[:type] == :private }
          .each do |company|
            next unless @corporations.include?(company.owner)

            company.close!
          end

          # Pullman Strike
          @log << '-- Event: Pullman Strike --'
          event_pullman_strike!
          @last_set_triggered = true
        end

        def init_stock_market
          stock_market = G18IL::StockMarket.new(self.class::MARKET, [], zigzag: :flip)
          stock_market.game = self
          stock_market
        end

        def p_bonus(route, stops)
          return 0 unless route.train.name.include?('P')

          cities = stops.select(&:city?)
          count = route.train.name[-2]
          bonus = cities.map { |stop| stop.route_revenue(route.phase, route.train) }.max(count.to_i)
          bonus.sum
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

          bonus
        end

        def mine_stops
          MINE_HEXES.map { |h| hex_by_id(h).tile.stops }.reject!(&:empty?).flatten
        end

        def port_stops
          PORT_HEXES.map { |h| hex_by_id(h).tile.stops }.reject!(&:empty?).flatten
        end

        def mine_corporation?(corporation)
          return true if corporation.assignments.include?(MINE_ICON)

          false
        end

        def port_corporation?(corporation)
          return true if corporation.assignments.include?(PORT_ICON)

          false
        end

        def train_marker_adjustment(corporation)
          return unless corporation.trains.any?

          corporation.trains.each do |train|
            next if train.name == 'D'

            if train.name == 'Rogers (1+1)'
              next unless mine_corporation?(corporation)

              train.distance = [{ 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                                { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1 }]
              next
            end
            train_num = train.name[0].to_i
            train_num = 6 if train.name == '5+1P' || train.name == '4+2P'

            train.distance = if mine_corporation?(corporation)
                               [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard halt], 'pay' => train_num, 'visit' => train_num }]
                             else
                               [{ 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 },
                                { 'nodes' => %w[city offboard halt], 'pay' => train_num, 'visit' => train_num }]
                             end
          end
        end

        def routes_subsidy(routes)
          routes.sum(&:subsidy)
        end

        def subsidy_for(route, _stops)
          return 0 if @optional_rules&.include?(:intro_game) || route.corporation != u_s_mail_line.owner

          (route.visited_stops & regular_stops).count * 10
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += ew_ns_bonus(stops)[:revenue] + p_bonus(route, stops)
          return revenue if @optional_rules&.include?(:intro_game)

          if (ability = abilities(route.corporation, :hex_bonus)) && @lincoln_triggered
            stops.each do |stop|
              next unless ability.hexes.include?(stop.hex.name)

              revenue +=
                case phase.current[:tiles].last
                when 'yellow' then 20
                when 'green' then 30
                when 'brown' then 40
                when 'gray' then 50
                end
            end
          end

          if route.corporation == steamboat.owner
            route.hexes.each do |hex|
              revenue += 20 if PORT_HEXES.include?(hex.name)
            end
          end

          revenue
        end

        def revenue_str(route)
          str = super
          bonus = ew_ns_bonus(route.stops)[:description]
          str += " + #{bonus}" if bonus

          return str if @optional_rules&.include?(:intro_game)

          # LFC bonus logic
          if (ability = abilities(route.corporation, :hex_bonus))
            route.hexes.each do |hex|
              if ability.hexes.include?(hex.name)
                str += ' + LFC bonus'
                break
              end
            end
          end

          if route.corporation == steamboat.owner
            route.hexes.each do |hex|
              if PORT_HEXES.include?(hex.name)
                str += ' + SMBT bonus'
                break
              end
            end
          end

          str
        end

        def route_distance_str(route)
          corporation = route.corporation
          mines = (route.visited_stops & mine_stops).count
          ports = (route.visited_stops & port_stops).count
          others = (route.visited_stops & regular_stops).count

          str = others.to_s
          str += "+#{mines}m" if mines.positive? && mine_corporation?(corporation)
          str += "+#{ports}p" if ports.positive? && port_corporation?(corporation)

          str
        end

        def regular_stops
          marker_stops = (MINE_HEXES + PORT_HEXES).map { |h| hex_by_id(h).tile.stops }.reject!(&:empty?).flatten
          all_stops = hexes.map { |h| h.tile.stops }.reject!(&:empty?).flatten
          all_stops - marker_stops
        end

        def stl_permit?(entity)
          STL_TOKEN_HEX.any? { |h| hex_by_id(h).tile.cities.any? { |c| c.tokened_by?(entity) } }
        end

        def stl_hex?(stop)
          @stl_nodes.include?(stop)
        end

        def check_stl(visits)
          return if !stl_hex?(visits.first) && !stl_hex?(visits.last)
          raise GameError, 'Train cannot visit St. Louis without a permit token' unless stl_permit?(current_entity)
        end

        def check_three_p(route, visits)
          return unless route.train.name == '3P'
          raise GameError, 'Cannot visit red areas' if visits.first.tile.color == :red || visits.last.tile.color == :red
        end

        def check_rogers(route, visits)
          return unless route.train.name == 'Rogers (1+1)'
          if (visits.first.hex.name == 'E12' && visits.last.hex.name == 'D13') ||
            (visits.last.hex.name == 'E12' && visits.first.hex.name == 'D13')
            return
          end

          raise GameError, "'Rogers' train can only run between Springfield and Jacksonville"
        end

        def check_port(route, visits)
          return if visits.none? { |v| PORT_HEXES.find { |h| v.hex == hex_by_id(h) } } || port_corporation?(route.corporation)

          raise GameError, 'Corporation must own a port marker to visit a port'
        end

        def check_distance(route, visits)
          # checks STL for permit token
          check_stl(visits)

          # disallows 3P trains from running to red areas
          check_three_p(route, visits)

          # disallows Rogers train from running outside of Springfield/Jacksonville
          check_rogers(route, visits)

          # disallows corporations without a port token from running to a port
          check_port(route, visits)

          super
        end

        def init_loans
          # this is only used for view purposes
          Array.new(8) { |id| Loan.new(id, 0) }
        end

        def maximum_loans(_entity)
          1
        end

        def can_pay_interest?(_entity, _extra_cash = 0)
          false
        end

        def interest_owed(_entity)
          0
        end

        def can_go_bankrupt?(_player, _corp)
          false
        end

        def corporation_show_interest?(_corporation)
          false
        end

        def corporation_show_loans?(corporation)
          insolvent_corporations.include?(corporation)
        end

        def take_loan(corporation, loan)
          corporation.cash += loan

          if insolvent_corporations.include?(corporation)
            @log << "#{corporation.name} adds #{format_currency(loan)} to its existing loan"
            corporation.loans.first.amount += loan
          else
            @log << "-- #{corporation.name} is now insolvent --"
            @log << "#{corporation.name} takes a loan of #{format_currency(loan)}"
            corporation.loans << Loan.new(corporation, loan)
            @insolvent_corporations << corporation
          end
        end

        def payoff_loan(corporation, payoff_amount: nil)
          loan_balance = corporation.loans.first.amount
          payoff_amount ||= corporation.cash
          payoff_amount = [payoff_amount, loan_balance].min

          corporation.loans.shift
          remaining_loan = loan_balance - payoff_amount
          corporation.loans << Loan.new(corporation, remaining_loan)
          corporation.cash -= payoff_amount

          if remaining_loan.zero?
            @log << "#{corporation.name} pays off its loan of #{format_currency(loan_balance)}"
            @log << "-- #{corporation.name} is now solvent --"
            @insolvent_corporations.delete(corporation)
          else
            @log << "#{corporation.name} decreases its loan by #{format_currency(payoff_amount)} "\
                    "(#{format_currency(remaining_loan)} remaining)"
          end
        end

        def event_signal_end_game!
          # Play one more OR, then Pullman Strike and blocking token events occur, then play one final set (CR, SR, 3 ORs)
          @final_operating_rounds = 3
          game_end_check
          @operating_rounds = 3 if phase.name == 'D' && round.round_num == 2
          @log << "-- First D train bought, game ends at the end of OR #{@turn + 1}.#{@final_operating_rounds} --"
          #  @log << "-- First D train bought/exported, game ends at the end of OR #{@turn + 1}.#{@final_operating_rounds} --"
        end

        def remove_unparred_corporations!
          @blocking_log = []
          @removed_corp_log = []

          @corporations.reject(&:ipoed).reject(&:closed?).each do |corporation|
            place_home_blocking_token(corporation) if corporation.coordinates
            @removed_corp_log << corporation.name
            @corporations.delete(corporation)
            company = company_by_id(corporation.name)
            @companies.delete(company)
            @cert_limit -= 1
          end

          @log << if @blocking_log.empty?
                    '-- Event: Removing unopened corporations --'
                  else
                    '-- Event: Removing unopened corporations and placing blocking tokens --'
                  end

          @log << "#{@removed_corp_log.join(', ')} removed from the game"

          return nil if @blocking_log.empty?

          @log << "Blocking #{@blocking_log.count == 1 ? 'token' : 'tokens'} placed on #{@blocking_log.join(', ')}"
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
          cities.each do |city|
            @blocking_log << "#{hex.name} (#{hex.location_name})"
            city ||= hex.tile.cities[0]
            token = Token.new(corporation, price: 0, logo: "/logos/18_il/#{corporation.name}.svg",
                                           simple_logo: "/logos/18_il/#{corporation.name}.svg", type: :blocking)
            token.status = :flipped
            city.place_token(corporation, token, check_tokenable: false)
          end
        end

        def final_operating_rounds
          @final_operating_rounds || super
        end

        # Pullman Strike: 4+2P and 5+1P trains downgrade to 4- and 5-trains, respectively.
        def event_pullman_strike!
          @corporations.each do |c|
            c.trains.each do |train|
              next unless train.name.include?('P')

              train_num = train.name[0]
              @log << "#{train.name} train downgraded to a #{train_num}-train (#{c.name})"
              train.name = train_num
              train.distance = [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => train_num, 'visit' => train_num }]
            end
          end
        end

        def process_single_action(action)
          corp = action.entity.owner if action.entity.company?

          super

          return if @optional_rules.include?(:intro_game)

          if action.entity == central_illinois_boom
            tile = action.hex.tile
            tile_to_remove = case tile.name
                             when 'P4' then 'S4'
                             when 'S4' then 'P4'
                             end

            @log << "Tile ##{tile_to_remove} is removed from the game"
            tiles.delete_if { |t| t.name == tile_to_remove }
          end

          case action.entity
          when goodrich_transit_line, steamboat
            corp.assign!(PORT_ICON)
            log << "#{corp.name} receives a port marker"
          when frink_walker_co, chicago_virden_coal_company
            corp.assign!(MINE_ICON)
            log << "#{corp.name} receives a mine marker"
          end
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless @round.steps.find { |step| step.is_a?(G18IL::Step::BaseBuySellParShares) }.active?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def event_ic_formation!
          @log << '-- Event: Illinois Central Formation --'

          ic_setup

          option_cube_exchange

          @mergeable_candidates = mergeable_corporations

          if @mergeable_candidates.any?
            @log << "Merge candidates: #{present_mergeable_candidates(@mergeable_candidates)}"
          else
            @log << 'IC forms with no merger'
            post_ic_formation
          end
        end

        def ic_setup
          ic.add_ability(self.class::STOCK_PURCHASE_ABILITY)
          ic.add_ability(self.class::TRAIN_BUY_ABILITY)
          ic.add_ability(self.class::TRAIN_LIMIT_ABILITY)
          ic.remove_ability(self.class::FORMATION_ABILITY)

          bundle = ShareBundle.new(ic.shares.last(5))
          @share_pool.transfer_shares(bundle, @share_pool)
          ic.shares.each do |s|
            s.buyable = false
          end

          stock_market.set_par(ic, @stock_market.par_prices.find do |p|
            p.price == IC_STARTING_PRICE
          end)
          @bank.spend(IC_STARTING_PRICE * 10, ic)
          @merge_share_prices = [ic.share_price.price] # adds IC's share price to array to be averaged later
          @log << "#{ic.name} starts at #{format_currency(IC_STARTING_PRICE)} and "\
                  "receives #{format_currency(IC_STARTING_PRICE * 10)} from the bank"

          place_home_token(ic)
        end

        def option_cube_exchange
          # option cubes are exchanged for IC shares from the market at a rate of 2:1
          @corporations.each do |corp|
            while @option_cubes[corp] > 1
              @option_cubes[corp] -= 2
              bundle = ShareBundle.new(@share_pool.shares_of(ic).last)
              @share_pool.transfer_shares(bundle, corp)
              @log << "#{corp.name} exchanges two option cubes for a 10% share of #{ic.name}"
              @option_cubes.delete(corp) if (@option_cubes[corp]).zero?
            end
          end

          # each corp with one remaining option cube is given a choice between exchanging it for $40
          # or paying $40 for a share of IC
          @exchange_choice_corps ||= []
          @corporations.each do |corp|
            @exchange_choice_corps << corp if @option_cubes[corp] == 1
          end
          @exchange_choice_corps.sort!
          @exchange_choice_corps.each do |corp|
            @exchange_choice_corp = corp
          end
        end

        def option_exchange(corp)
          cost = ic.share_price.price / 2
          corp.spend(cost, @bank)
          bundle = ShareBundle.new(@share_pool.shares_of(ic).last)
          @share_pool.transfer_shares(bundle, corp)
          @log << "#{corp.name} pays #{format_currency(cost)} and exchanges option cube "\
                  "for a 10% share of #{ic.name}"
          @option_cubes[corp] -= 1
        end

        def option_sell(corp)
          refund = ic.share_price.price / 2
          @bank.spend(refund, corp)
          @log << if ic.num_market_shares.positive?
                    "#{corp.name} sells option cube for #{format_currency(refund)}"
                  else
                    "#{corp.name} sells option cube for #{format_currency(refund)} "\
                      "(#{ic.name} has no market shares to exchange)"
                  end
          @option_cubes[corp] -= 1
        end

        def decline_merge(corporation)
          @log << "#{corporation.name} declines to merge"
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
          4.times do |i|
            corp = @corporations.find { |c| c.tokens.find { |t| t.hex == hex_by_id(IC_LINE_HEXES[i]) } }
            ic_line_corporations << corp if corp && corp != ic
          end
          ic_line_corporations.uniq
        end

        def present_mergeable_candidates(mergeable_candidates)
          mergeable_candidates.map do |c|
            controller_name = c.player.name
            "#{c.name} (#{controller_name})"
          end.join(', ')
        end

        def merge_corporation_part_one(corporation = nil)
          @merged_corps << corporation
          @mergeable_candidates.delete(corporation)
          @merged_corporation = corporation
          @log << "-- #{corporation.name} merges into #{ic.name} --"

          refund = corporation.share_price.price
          @merge_share_prices << refund
          @total_refund = 0.0

          # Calculate total refund for non-president shares
          (@players + @corporations).each do |entity|
            entity.shares_of(corporation).dup.each do |share|
              next if !share || corporation == entity

              @total_refund += (refund * (share.president ? 0.5 : 1.0)) unless share.president
            end
          end

          # Check for exchange option for president's share
          (@players + @corporations).each do |entity|
            entity.shares_of(corporation).dup.each do |share|
              @exchange_choice_player = entity if share&.president
            end
          end
        end

        def presidency_exchange(player)
          bundle = ShareBundle.new(ic.shares_of(ic).last)
          @log << "#{player.name} exchanges the president's share of #{@merged_corporation.name} for a 10% share of #{ic.name}"
          @share_pool.transfer_shares(bundle, player)
        end

        def presidency_sell(player)
          refund = @merged_corporation.share_price.price
          @bank.spend(refund, player)
          @log << "#{player.name} discards the president's share of #{@merged_corporation.name} for #{format_currency(refund)}"
        end

        def merge_corporation_part_two
          corporation = @merged_corporation
          if corporation.cash < @total_refund
            @log << "#{corporation.name} does not have enough cash to compensate shares. "\
                    "#{corporation.name}'s cash is returned to the bank. The bank will guarantee non-president shares"
            corporation.cash = 0
          end

          refund = corporation.share_price.price
          # Handle share compensation for players and corporations
          (@players + @corporations).each do |entity|
            refund_amount = entity.shares_of(corporation).dup.reject(&:president).sum { refund }
            next unless refund_amount.positive?

            if corporation.cash.zero?
              @bank.spend(refund_amount, entity) if corporation.owner != entity
              @log << "#{entity.name} receives #{format_currency(refund_amount)} in share compensation from bank"
            else
              refund_amount /= 2 if corporation.owner == entity
              refund_amount = refund_amount.ceil
              corporation.spend(refund_amount, entity)
              @log << "#{entity.name} receives #{format_currency(refund_amount)} in share compensation from #{corporation.name}"
            end
          end

          # Handle IC token replacement
          ic.tokens << Token.new(ic, price: 0)
          ic_tokens = ic.tokens.reject(&:city)
          corporation_token = corporation.tokens.find { |token| IC_LINE_HEXES.include?(token&.hex&.id) }
          replace_ic_token(corporation, corporation_token, ic_tokens)

          # Transfer corporation's remaining cash to IC
          if corporation.cash.positive?
            treasury = format_currency(corporation.cash)
            @log << "#{ic.name} receives the #{corporation.name} treasury of #{treasury}"
            corporation.spend(corporation.cash, ic)
          end

          # Transfer corporation's trains to IC
          if corporation.trains.any?
            trains_transferred = transfer(:trains, corporation, ic).map(&:name)
            @log << "#{ic.name} receives #{trains_transferred.one? ? 'a train' : 'trains'} "\
                    "from #{corporation.name}: #{trains_transferred.join(', ')}"
          end

          post_ic_formation if @mergeable_candidates.empty?
        end

        def replace_ic_token(corporation, corporation_token, ic_tokens)
          city = corporation_token.city
          @log << "#{corporation.name}'s token in #{city.hex.name} (#{city.hex.tile.location_name}) "\
                  "is replaced with an #{ic.name} token"
          ic_replacement = ic_tokens.first
          corporation_token.remove!
          city.place_token(ic, ic_replacement, free: true, check_tokenable: false)
          ic_tokens.delete(ic_replacement)
        end

        def ic_reserve_tokens
          @slot_open = true
          count = ic.tokens(&:city).count - 1

          # Place tokens in the city until we have 2
          while count < 2
            # Add new token to the corporation
            ic.tokens << Token.new(ic, price: 0)
            ic_tokens = ic.tokens.reject(&:city)

            # Determine where to place the token
            hex = ic_line_token_location
            city = hex.tile.cities.first
            city.place_token(ic, ic_tokens.first, free: true, check_tokenable: false, cheater: !@slot_open)

            # Log the token placement
            @log << "#{ic.name} places a token in #{city.hex.name} (#{hex.tile.location_name})"

            count += 1
          end

          ic.tokens << Token.new(ic, price: 0) while ic.tokens.count < 7
        end

        def ic_line_token_location
          # Try to find an available token slot on the IC Line
          selected_hexes = find_available_ic_line_hexes

          # If no available hexes found, look for the first city without an IC token
          if selected_hexes.empty?
            selected_hexes = find_available_ic_line_hexes(cheater: true)
            @slot_open = false
          else
            @slot_open = true
          end

          # Return the northernmost available city
          selected_hexes.last
        end

        def find_available_ic_line_hexes(cheater: false)
          hexes.select do |hex|
            IC_LINE_HEXES.include?(hex.id) && hex.tile.cities.any? do |city|
              !city.tokened_by?(ic) && city.tokenable?(ic, free: true, cheater: cheater)
            end
          end
        end

        def post_ic_formation
          # IC gains station tokens and places additional tokens if fewer than two mergers occur
          ic_reserve_tokens

          train = @depot.upcoming[0]
          if ic.trains.empty? && ic.cash >= @depot.min_depot_price
            # IC buys a train immediately if it is trainless and has enough cash
            @log << "#{ic.name} is trainless"
            @log << "#{ic.name} buys a #{train.name} train for #{format_currency(train.price)} from the Depot"
            buy_train(ic, train, train.price)
            @phase.buying_train!(ic, train, train.owner)
          end

          # calculate IC's new share price - the average of merged corporations' share prices and $80
          price = if @merge_share_prices.one?
                    ic.share_price.price
                  else
                    @merge_share_prices.sum / @merge_share_prices.count
                  end
          ic_new_share_price = @stock_market.market.first.max_by { |p| p.price <= price ? p.price : 0 }
          @log << "#{ic.name}'s new share price is #{format_currency(ic_new_share_price.price)}"
          # removes old share price and sets new
          ic.share_price.corporations.delete(ic)
          stock_market.set_par(ic, ic_new_share_price)
          # IC enters receivership if there is no president (priority deal player operates)
          add_ic_receivership_ability
          if ic_in_receivership?
            @log << "#{ic.name} enters receivership (it has no president)"
            @log << "While in receivership, #{ic.name} will be operated by a random player"
            ic.owner = @players.min_by { rand }
          else
            add_ic_operating_ability
          end

          earliest_index = @merged_corps.empty? ? 99 : @merged_corps.map { |n| @round.entities.index(n) }.min
          current_corp_index = @round.entities.index(@ic_trigger_entity)
          # if no corps merged or none of the merged corps ran yet, IC runs next

          if current_corp_index < earliest_index # if the triggering corp operated before any merged corps,
            # IC will operate this round
            @log << if @merged_corps.empty?
                      'IC will operate for the first time in this operating round (no corporations merged)'
                    else
                      'IC will operate for the first time in this operating round '\
                        '(no merged corporations have operated in this round)'
                    end
            # find the corp with the next price below IC's
            index_corp = @round.entities.sort.find { |c| c.share_price.price < ic.share_price.price }
            index = @round.entities.find_index(index_corp)
            if index.nil? # if there is no such corp, add IC at the end of the line
              @round.entities << ic
              # if IC's price is higher than the trigger corp's, IC will operate next
            elsif ic.share_price.price > @ic_trigger_entity.share_price.price
              @round.entities.insert(current_corp_index + 1, ic)
            else
              # if IC's price is equal to or lower than the trigger corp's, IC will be placed in the proper place in order
              @round.entities.insert(index, ic)
            end
          else
            @log << 'IC will operate for the first time in the next operating round '\
                    '(a merged corporation has already operated)'

          end
          ic.floatable = true
          ic.floated = true
          ic.ipoed = true

          @merged_corps.each do |c|
            close_corporation(c)
            # moves the index back by one for each merged corp if the merged corp had already operated
            @round.entity_index -= 1 if c.operated?
          end

          @ic_formation_pending = false
          @log << '-- Event: Illinois Central Formation complete --'
        end

        def add_ic_operating_ability
          return if @ic_president == true

          ic.remove_ability(self.class::RECEIVERSHIP_ABILITY)
          ic.add_ability(self.class::OPERATING_ABILITY)
          @ic_president = true
        end

        def add_ic_receivership_ability
          ic.add_ability(self.class::RECEIVERSHIP_ABILITY)
        end

        def ic_in_receivership?
          ic.presidents_share.owner == ic
        end
      end
    end
  end
end
