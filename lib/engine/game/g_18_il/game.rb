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
                      :other_train_pass, :lincoln_triggered

        attr_reader :merged_corporation, :last_set_triggered, :ic_line_completed_hexes, :insolvent_corporations

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '$%s'
        NEXT_SR_PLAYER_ORDER = :first_to_pass
        BANK_CASH = 99_999
        CAPITALIZATION = :incremental
        CERT_LIMIT = { 2 => 24, 3 => 18, 4 => 15, 5 => 13, 6 => 11 }.freeze
        STARTING_CASH = { 2 => 900, 3 => 720, 4 => 560, 5 => 420, 6 => 360 }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'signal_end_game' => ['Signal End Game', 'Game Ends 3 ORs after purchase/export of first D train']
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

        GAME_END_CHECK = { final_phase: :one_more_full_or_set }.freeze
        SELL_AFTER = :p_any_operate
        SELL_MOVEMENT = :none

        SOLD_OUT_INCREASE = true
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true
        CLOSED_CORP_TRAINS_REMOVED = false
        CLOSED_CORP_TOKENS_REMOVED = false
        CLOSED_CORP_RESERVATIONS_REMOVED = false

        PORT_HEXES = %w[B1 D23 H1 I2].freeze
        MINE_HEXES = %w[C2 D9 D13 D17 E6 E14 F5 F13 F21 G22 H11].freeze
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
        CHICAGO_HEX = ['H3'].freeze
        PORT_MARKER_ICON = 'port'.freeze
        MINE_MARKER_ICON = 'mine'.freeze
        SPRINGFIELD_HEX = 'E12'.freeze
        CORPORATION_SIZES = { 2 => :small, 5 => :medium, 10 => :large }.freeze
        PORT_ICON = 'port'.freeze
        MINE_ICON = 'mine'.freeze
        IC_STARTING_PRICE = 80.freeze
        IC_LINE_HEXES = %w[H7 G10 F17 E22].freeze
        BOOM_HEXES = %w[E8 E12].freeze

        PORT_TILE_FOR_HEX = {
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
          desc_detail: 'IC only performs the "lay track", "place token", "run trains" and "buy trains" '\
                       'steps during its operating turns.'
        )
        TRAIN_BUY_ABILITY = Ability::Description.new(
          type: 'description',
          description: 'Modified train buy',
          desc_detail: 'IC can only buy trains from the bank and can only buy one train per round. '\
                       'IC is not required to own a train, but must buy a train if possible. '\
                       "IC's last train may not be bought by another corporation."
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
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            G18IL::Step::DiverseCargoChoice,
            G18IL::Step::MineCompanyChoice,
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
            G18IL::Step::SpecialIssueShares,
            G18IL::Step::CorporateIssueBuyShares,
            G18IL::Step::Track,
            G18IL::Step::ExtraStationChoice,
            G18IL::Step::Token,
            G18IL::Step::LincolnChoice,
            G18IL::Step::BorrowTrain,
            G18IL::Step::BuyTrainBeforeRunRoute,
            G18IL::Step::Route,
            G18IL::Step::Dividend,
            Engine::Step::SpecialBuyTrain,
            G18IL::Step::CorporateSellShares,
            G18IL::Step::BuyTrain,
            [G18IL::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def tile_lays(entity)
          return super unless engineering_mastery&.owner == entity

          tile_lays = [{ lay: true, upgrade: true, cost: 0, cannot_reuse_same_hex: true }]
          # Engineering Mastery gets first upgrade for $20 or second upgrade for $30
          tile_lays += [{ lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true }] unless @round.upgraded_track
          if @round.upgraded_track
            tile_lays += [{
              lay: true,
              upgrade: true,
              cost: 20,
              upgrade_cost: 30,
              cannot_reuse_same_hex: true,
            }]
          end
          tile_lays
        end

        def status_array(corp)
          str = []
          company = @companies.find { |c| !c.closed? && c.sym == corp.name }
          str << "Concession: #{company.owner.name}" if company&.owner&.player?
          str << "Option cubes: #{@option_cubes[corp]}" if (@option_cubes[corp]).positive?
          str << "Loan amount: #{format_currency(corp.loans.first.amount)}" unless corp.loans.empty?
          str.empty? ? nil : str
        end

        def init_round
          new_concession_round
        end

        # this is not actually true, but forces the corporate_buy_sell_shares view to be used
        def corporations_can_ipo?
          true
        end

        def next_sr_position(entity)
          player_order = if @round.current_entity&.player?
                           @round.pass_order
                         else
                           @players
                         end
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
          return if !ic_in_receivership? || !ic_formation_triggered?

          ic.owner = priority_deal_player
          @log << "#{ic.name} is in receivership and will be operated '\
          'by the player with priority deal (#{priority_deal_player.name})"
        end

        def initial_auction_companies
          companies
        end

        def company_status_str(company)
          return if @optional_rules&.include?(:intro_game)

          case company.meta[:type]
          when :private
            if company.meta[:class] == :A
              'Class A'
            else
              'Class B'
            end
          when :concession
            corp = @corporations.find { |c| c.name == company.sym }
            "A: #{corp.companies[0].name} B: #{corp.companies[1].name}"
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

        def setup_preround
          super

          # creates corp that places blocking tokens (phase colors) in STL
          blocking_logo = ['/logos/18_il/yellow_blocking.svg', '/logos/18_il/green_blocking.svg',
                           '/logos/18_il/brown_blocking.svg', '/logos/18_il/gray_blocking.svg']
          game_start_blocking_corp = Corporation.new(sym: 'GSB', name: 'game_start_blocking_corp', logo: blocking_logo[0],
                                                     simple_logo: blocking_logo[0], tokens: [0])
          game_start_blocking_corp.owner = @bank
          city = @hexes.find { |hex| hex.id == 'C18' }.tile.cities.first
          blocking_logo.each do |n|
            token = Token.new(game_start_blocking_corp, price: 0, logo: n.to_s, simple_logo: n.to_s, type: :blocking)
            city.place_token(game_start_blocking_corp, token, check_tokenable: false)
          end

          @port_corporations = []
          @mine_corporations = []

          if @optional_rules&.include?(:intro_game)
            @port_corporations = @corporations.min_by(4) { rand }
            @mine_corporations = @corporations - @port_corporations
            @port_tile_for_hex = PORT_TILE_FOR_HEX.min_by(1) { rand }
          else
            array_a = [*8..15]
            array_b = [*16..23]
            class_a = array_a.min_by(array_a.count) { rand }
            class_b = array_b.min_by(array_b.count) { rand }
            @log << '-- Auction Lot Formation --'
            8.times do |i|
              str = []
              entity = @corporations[i]
              c = companies[class_a[i]]
              c.owner = entity
              str << "#{c.name} and "
              entity.companies << c
              c = companies[class_b[i]]
              c.owner = entity
              str << "#{c.name} assigned to #{entity.name} concession"
              entity.companies << c

              @log << str.join
            end
          end
        end

        def setup
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

          @stl_nodes = STL_HEXES.map do |h|
            hex_by_id(h).tile.nodes.find { |n| n.offboard? && n.groups.include?('STL') }
          end

          return unless @optional_rules&.include?(:intro_game)

          # assigns port and mine markers to corporations
          assign_port_markers(port_corporations)
          assign_mine_markers(mine_corporations)

          # place random port tile on map and remove the other
          hex = @hexes.find { |h| h.id == PORT_TILE_HEXES.min_by { rand } }
          assign_port_tile(hex)
          remove_port_tiles
        end

        def assign_port_tile(hex)
          tile_name, rotation = PORT_TILE_FOR_HEX[hex.id]
          hex.lay(@tiles.find { |t| t.name == tile_name }.rotate!(rotation))
          @log << "Port tile is placed on #{hex.id}"
        end

        def remove_port_tiles
          @all_tiles.each { |tile| tile.hide if tile.color == :blue }
        end

        def assign_port_markers(_entity)
          port_log = []
          port_corporations.each do |c|
            assign_port_icon(c)
            port_log << c.name
            port_log << ', ' if port_log.count < 6
            port_log << 'and ' if port_log.count == 6
          end
          @log << "#{port_log.join} receive port markers"
        end

        def assign_mine_markers(_entity)
          mine_log = []
          mine_corporations.each do |c|
            assign_mine_icon(c)
            mine_log << c.name
            mine_log << ', ' if mine_log.count < 6
            mine_log << 'and ' if mine_log.count == 6
          end
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

        def emr_active?
          @emr_active
        end

        def company_sellable(company); end

        def port_corporations
          @port_corporations.each { |c| corporation_by_id(c) }
        end

        def mine_corporations
          @mine_corporations.each { |c| corporation_by_id(c) }
        end

        # allows blue tile lays at any time
        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          return true if tile.name == 'SPH' || tile.name == 'POM'

          super
        end

        # allows blue-on-blue tile lays
        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if PORT_TILE_HEXES.include?(from.hex.id) && (from.color == :blue && to.color == :blue)

          if BOOM_HEXES.include?(from.hex.id) && @round.current_operator == central_illinois_boom.owner && phase.name == 'D'
            return true if from.hex.id == 'E8' && to.name == 'P4'
            return true if from.hex.id == 'E12' && to.name == 'S4'
          end
          super
        end

        def eligible_tokens?(corporation)
          corporation.tokens.find { |t| t.used && !STL_TOKEN_HEXES.include?(t.hex.id) }
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
            hexes.select { |hex| hex.tile.cities.find { |c| c.tokened_by?(corporation) && !STL_TOKEN_HEXES.include?(hex.id) } }
          else
            hexes.select do |hex|
              hex.tile.cities.any? && hex.tile.cities.select { |c| c.reservations.any? }.empty? &&
              !STL_TOKEN_HEXES.include?(hex.id) && !CHICAGO_HEX.include?(hex.id)
            end
          end
        end

        def ic_owns_train
          return if @ic_owns_train

          @ic_owns_train = true
          ic.remove_ability(self.class::FORCED_WITHHOLD_ABILITY)
          ic.remove_ability(self.class::IMMOBILE_SHARE_PRICE_ABILITY)
          ic.remove_ability(self.class::BORROW_TRAIN_ABILITY)
        end

        def ic_needs_train
          return if @ic_needs_train

          @ic_needs_train = true
          ic.add_ability(self.class::FORCED_WITHHOLD_ABILITY)
          ic.add_ability(self.class::IMMOBILE_SHARE_PRICE_ABILITY)
          ic.add_ability(self.class::BORROW_TRAIN_ABILITY)
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
          tile = action.hex.tile
          icons = action.hex.tile.icons
          corp = action.entity.corporation

          return if @ic_line_completed_hexes.include?(hex)

          connection_count = ic_line_connections(hex)

          return unless connection_count.positive?

          if tile.color == 'yellow'
            @log << "#{corp.name} receives a #{format_currency(20)} subsidy for IC Line improvement"
            @bank.spend(20, corp)
          end

          return unless connection_count == 2

          @ic_line_completed_hexes << hex
          icons.each do |icon|
            next unless icon.sticky

            icons.delete(icon)
            @option_cubes[corp] += 1
            @log << "#{corp.name} receives an option cube"
          end

          @log << "IC Line hexes completed: #{@ic_line_completed_hexes.size} of 10"

          return unless ic_line_completed?

          @log << 'IC Line is complete'
          @log << "The Illinois Central Railroad will form at the end of #{action.entity.name}'s turn"
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
          new_shares.each { |share| add_new_share(share) }
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
          corporation.spend(total_cost, @bank) unless total_cost.zero?
          if corporation == station_subsidy.owner
            @log << "#{corporation.name} uses #{station_subsidy.name} and buys"\
                    " #{count} #{count == 1 ? 'token' : 'tokens'} for #{format_currency(total_cost)}"
            token_ability = corporation.all_abilities.find { |a| a.type == :token }
            count.times { token_ability.use! }
            station_subsidy.close! unless token_ability.count.positive?
          else
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
          if num_shares > corp.shares_of(corp).size
            raise GameError, 'Corporation cannot raise enough money to convert - please undo'
          end

          bundle = ShareBundle.new(corp.shares_of(corp).take(num_shares))
          bundle.share_price = corp.share_price.price / 2.0
          @emr_active = true
          old_price = corp.share_price.price
          sell_shares_and_change_price(bundle)
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
          if corporation == share_premium.owner && @round.steps.find do |step|
                                                     step.is_a?(G18IL::Step::SpecialIssueShares)
                                                   end&.active?
            all_bundles.each do |b|
              b.share_price = corporation.share_price.price * 2.0
            end
          end
          all_bundles.concat(partial_bundles_for_presidents_share(corporation, bundle, percent)) if shares.last.president

          all_bundles.sort_by(&:percent)
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil, movement: nil)
          corporation = bundle.corporation
          movement = :down_share if emr_active?
          movement = :left_share if @sp_used
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
          @emr_active = nil
        end

        def emergency_issuable_cash(corporation)
          return 0 if corporation.trains.any?

          emergency_issuable_bundles(corporation).max_by(&:num_shares)&.price || 0
        end

        def emergency_issuable_bundles(entity)
          return [] unless entity.cash < @depot.min_depot_price
          return [] unless entity.corporation?
          return [] if entity.num_ipo_shares.zero?

          @emr_active = true
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
          if @depot.upcoming.first.name == '2'
            depot.export_all!('2')
            phase.next!
            nc.trains.shift
            @log << '-- Event: Rogers (1+1) train rusts --'
          else
            depot.export!
          end
        end

        def or_set_finished
          # no one owns IC if in receivership
          ic.owner = nil if ic_in_receivership?

          # convert unstarted corporations at the appropriate time.
          if %w[4 4+2P 5 6 D].include?(@phase.name)
            @corporations.reject { |c| c.floated? || @closed_corporations.include?(c) }.each do |c|
              convert(c) if c.total_shares == 2
              break if @phase.name == '4'

              convert(c) if c.total_shares == 5
            end
          end

          return unless phase.name == 'D'

          @log << '-- Event: Removing unopened corporations and placing blocking tokens --'
          # remove unopened corporations and decrement cert limit
          remove_unparred_corporations!
          @log << "-- Certificate limit adjusted to #{@cert_limit} --"

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
            if mine_corporation?(corporation) && port_corporation?(corporation)
              train.distance = [{ 'nodes' => %w[town halt], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => train_num, 'visit' => train_num }]
              next
            end
            train.distance = if mine_corporation?(corporation)
                               [{ 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[halt], 'pay' => 0, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => train_num, 'visit' => train_num }]
                             elsif port_corporation?(corporation)
                               [{ 'nodes' => %w[halt], 'pay' => 99, 'visit' => 99 },
                                { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => train_num, 'visit' => train_num }]
                             else
                               [{ 'nodes' => %w[town halt], 'pay' => 0, 'visit' => 99 },
                                { 'nodes' => %w[city offboard], 'pay' => train_num, 'visit' => train_num }]
                             end
          end
        end

        def routes_subsidy(routes)
          routes.sum(&:subsidy)
        end

        def subsidy_for(route, _stops)
          return 0 unless route.corporation == us_mail_line.owner

          (route.visited_stops & regular_stops).count * 10
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += ew_ns_bonus(stops)[:revenue] + p_bonus(route, stops)

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
          STL_TOKEN_HEXES.any? { |h| hex_by_id(h).tile.cities.any? { |c| c.tokened_by?(entity) } }
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

        def check_distance(route, visits)
          # checks STL for permit token
          check_stl(visits)

          # disallows 3P trains from running to red areas
          check_three_p(route, visits)

          # disallows Rogers train from running outside of Springfield/Jacksonville
          check_rogers(route, visits)

          super
        end

        def try_take_loan(entity, price)
          return if !price.positive? || price <= entity.cash

          @game.take_loan(entity) while entity.cash < price
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
            old_loan = corporation.loans.first.amount
            corporation.loans.shift
            corporation.loans << Loan.new(corporation, loan + old_loan)
          else
            @log << "-- #{corporation.name} is now insolvent --"
            @log << "#{corporation.name} takes a loan of #{format_currency(loan)}"
            corporation.loans << Loan.new(corporation, loan)
            @insolvent_corporations << corporation
          end
        end

        def payoff_loan(corporation, payoff_amount: nil)
          loan_balance = corporation.loans.first.amount
          payoff_amount = corporation.cash if !payoff_amount || payoff_amount > corporation.cash
          payoff_amount = [payoff_amount, loan_balance].min
          corporation.loans.shift
          corporation.loans << Loan.new(corporation, loan_balance - payoff_amount)
          corporation.cash -= payoff_amount
          if payoff_amount == loan_balance
            @log << "#{corporation.name} pays off their loan of #{format_currency(loan_balance)}"
            @log << "-- #{corporation.name} is now solvent --"
            @insolvent_corporations.delete(corporation)
          else
            @log << "#{corporation.name} decreases their loan amount by #{format_currency(payoff_amount)} "\
                    "(#{format_currency(corporation.loans.first.amount)} remaining)"
          end
        end

        def event_signal_end_game!
          # Play one more OR, then Pullman Strike and blocking token events occur, then play one final set (CR, SR, 3 ORs)
          @final_operating_rounds = 3
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
          @log << "Blocking #{@blocking_log.count == 1 ? 'token' : 'tokens'} placed on #{@blocking_log.join(', ')}"
          @log << 'Concessions removed from the game'
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

          if action.entity == central_illinois_boom
            tile = action.hex.tile
            case tile.name
            when 'P4'
              tiles.delete_if { |t| t.name == 'S4' }
            when 'S4'
              tiles.delete_if { |t| t.name == 'P4' }
            end
          end

          if action.entity == goodrich_transit_line || action.entity == steamboat
            corp.assign!(PORT_ICON)
            log << "#{corp.name} receives a port marker"
          end
          return if !action.entity == frink_walker_co && !action.entity == chicago_virden_coal_company

          corp.assign!(MINE_ICON)
          log << "#{corp.name} receives a mine marker"
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless @round.steps.find { |step| step.is_a?(G18IL::Step::BaseBuySellParShares) }.active?

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        #--------------------------------IC Formation-------------------------------------------------------#

        def ic
          @ic_corporation ||= corporation_by_id('IC')
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
          ic.remove_ability(self.class::FORMATION_ABILITY)

          bundle = ShareBundle.new(ic.shares.last(5))
          @share_pool.transfer_shares(bundle, @share_pool)

          stock_market.set_par(ic, @stock_market.par_prices.find do |p|
            p.price == IC_STARTING_PRICE
          end)
          @bank.spend(IC_STARTING_PRICE * 10, ic)
          @merge_share_prices = [ic.share_price.price] # adds IC's share price to array to be averaged later
          @log << "#{ic.name} is started at #{format_currency(IC_STARTING_PRICE)} and '\
          'receives #{format_currency(IC_STARTING_PRICE * 10)} from the bank"

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
          @log << "#{corp.name} pays #{format_currency(cost)} and exchanges option cube '\
          'for a 10% share of #{ic.name}"
          @option_cubes[corp] -= 1
        end

        def option_sell(corp)
          refund = ic.share_price.price / 2
          @bank.spend(refund, corp)
          @log << if ic.num_market_shares.positive?
                    "#{corp.name} sells option cube for #{format_currency(refund)}"
                  else
                    "#{corp.name} sells option cube for #{format_currency(refund)} '\
                    '(#{ic.name} has no market shares to exchange)"
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
            ic_line_corporations << corp if !corp.nil? && !corp == ic
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

          # Shares other than president's share are refunded- non-president-owned shares at full price,
          # president-owned shares at half price.
          refund = corporation.share_price.price
          @merge_share_prices << refund # adds merging corp's share price to array to be averaged later
          @total_refund = 0.0

          # Check if corporation has enough cash to compensate shareholders. If not, all of its money is returned to the bank.
          (@players + @corporations).each do |entity|
            entity.shares_of(corporation).dup.each do |share|
              next unless share

              next if corporation == entity || share.president

              modifier = 1.0 if corporation.owner != entity
              modifier = 0.5 if corporation.owner == entity # President's shares would be compensated at half value.
              @total_refund += (refund * modifier)
            end
          end

          (@players + @corporations).each do |entity|
            entity.shares_of(corporation).dup.each do |share|
              next unless share

              # president is given option of exchange corp's president's share for share of IC or the corp's current value
              @exchange_choice_player = entity if share.president
            end
          end
        end

        def presidency_exchange(player)
          bundle = ShareBundle.new(ic.shares_of(ic).last)
          @share_pool.transfer_shares(bundle, player)
          @log << "#{player.name} exchanges the president's share of #{@merged_corporation.name} for a 10% share of #{ic.name}"
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
          # Player's shares are compensated from the corporation if it has enough money;
          # otherwise, they are compensated from the bank.
          (@players + @corporations).each do |entity|
            refund_amount = 0.0
            entity.shares_of(corporation).dup.each do |share|
              next unless share

              # Refund 10% share
              refund_amount += refund if corporation != entity && !share.president
            end
            next unless refund_amount.positive?

            if corporation.cash.zero?
              if corporation.owner != entity
                @bank.spend(refund_amount, entity)
                @log << "#{entity.name} receives #{format_currency(refund_amount)} in share compensation from bank"
              end
            else
              refund_amount /= 2 if corporation.owner == entity
              refund_amount = refund_amount.ceil
              corporation.spend(refund_amount, entity)
              @log << "#{entity.name} receives #{format_currency(refund_amount)} in share compensation from #{corporation.name}"
            end
          end

          ic.tokens << Engine::Token.new(ic, price: 0)
          ic_tokens = ic.tokens.reject(&:city)
          corporation_token = corporation.tokens.find { |t| t.hex == hex_by_id('H7') } ||
                              corporation.tokens.find { |t| t.hex == hex_by_id('G10') } ||
                              corporation.tokens.find { |t| t.hex == hex_by_id('F17') } ||
                              corporation.tokens.find { |t| t.hex == hex_by_id('E22') }
          replace_ic_token(corporation, corporation_token, ic_tokens)

          # If the corporation has any money, it is transferred to IC
          if corporation.cash.positive?
            treasury = format_currency(corporation.cash)
            @log << "#{ic.name} receives the #{corporation.name} treasury of #{treasury}"
            corporation.spend(corporation.cash, ic)
          end

          # If the corporation has any trains, they are transferred to IC
          if corporation.trains.any?
            trains_transfered = transfer(:trains, corporation, ic).map(&:name)
            @log << "#{ic.name} receives #{trains_transfered.one? ? 'a train' : 'trains'} '\
            'from #{corporation.name}: #{trains_transfered.join(', ')}"
          end

          # close_corporation(corporation)
          post_ic_formation if @mergeable_candidates.empty?
        end

        def replace_ic_token(corporation, corporation_token, ic_tokens)
          city = corporation_token.city
          @log << "#{corporation.name}'s token in #{city.hex.name} (#{city.hex.tile.location_name}) '\
          'is replaced with an #{ic.name} token"
          ic_replacement = ic_tokens.first
          corporation_token.remove!
          city.place_token(ic, ic_replacement, free: true, check_tokenable: false)
          ic_tokens.delete(ic_replacement)
        end

        def ic_reserve_tokens
          @slot_open = true
          count = ic.tokens(&:city).count - 1
          while count < 2
            ic.tokens << Engine::Token.new(ic, price: 0)
            ic_tokens = ic.tokens.reject(&:city)
            hex = ic_line_token_location
            city = hex.tile.cities.first
            if @slot_open == true
              city.place_token(ic, ic_tokens.first, free: true, check_tokenable: false)
            else
              city.place_token(ic, ic_tokens.first, free: true, check_tokenable: false, cheater: true)
            end
            @log << "#{ic.name} places a token in #{city.hex.name} (#{hex.tile.location_name})"
            count += 1
          end
          # IC gets additional tokens
          ic.tokens << Engine::Token.new(ic, price: 0) while ic.tokens.count < 7
        end

        def ic_line_token_location
          # looks for empty token slots along IC Line
          selected_hexes = hexes.select do |hex|
            IC_LINE_HEXES.include?(hex.id) && hex.tile.cities.any? do |city|
              !city.tokened_by?(ic) && city.tokenable?(ic, free: true)
            end
          end
          @slot_open = true
          if selected_hexes.empty?
            # if none are available, it finds the first city not tokened by IC
            selected_hexes = hexes.select do |hex|
              IC_LINE_HEXES.include?(hex.id) && hex.tile.cities.any? do |city|
                !city.tokened_by?(ic) && city.tokenable?(ic, free: true, tokens: ic.tokens_by_type, cheater: true)
              end
            end
            @slot_open = false
          end
          selected_hexes.last # selects the northernmost city with extra slot if needed
        end

        def post_ic_formation
          # IC gains station tokens and places additional tokens if fewer than two mergers occur
          ic_reserve_tokens

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
            @log << "#{ic.name} will be operated by the player with priority deal (#{priority_deal_player.name})"
            ic.owner = priority_deal_player
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
            index = @round.entities.find_index { |c| c.share_price.price < ic.share_price.price }
            if index.nil? # if there is no such corp, add IC at the end of the line
              @round.entities << ic
              # if IC's price is higher than the trigger corp's, IC will operate next
            elsif ic.share_price.price > @ic_trigger_entity.share_price.price
              @round.entities.insert(current_corp_index + 1, ic)
            else
              # if IC's price is lower than the trigger corp's, IC will be placed in the proper place in order
              @round.entities.insert(index, ic)
            end
          else
            @log << 'IC will operate for the first time in the next operating round'
          end

          @log << '-- Event: Illinois Central Formation complete --'

          ic.floatable = true
          ic.floated = true
          ic.ipoed = true
          @merged_corps.each { |c| close_corporation(c) }
          @ic_formation_pending = false
        end

        def add_ic_operating_ability
          return if @ic_president == true

          ic.remove_ability(self.class::RECEIVERSHIP_ABILITY)
          ic.add_ability(self.class::OPERATING_ABILITY)
          @ic_president = true unless ic_in_receivership?
        end

        def add_ic_receivership_ability
          ic.add_ability(self.class::RECEIVERSHIP_ABILITY)
        end

        def ic_in_receivership?
          ic.presidents_share.owner == ic
        end

        #-------------------------------------------------------------------------------------------#

        def extra_station
          @extra_station = @companies.find { |c| c&.name == 'Extra Station' }
        end

        def goodrich_transit_line
          @goodrich_transit_line = @companies.find { |c| c&.name == 'Goodrich Transit Line' }
        end

        def rush_delivery
          @rush_delivery = @companies.find { |c| c&.name == 'Rush Delivery' }
        end

        def station_subsidy
          @station_subsidy = @companies.find { |c| c&.name == 'Station Subsidy' }
        end

        def share_premium
          @share_premium = @companies.find { |c| c&.name == 'Share Premium' }
        end

        def steamboat
          @steamboat = @companies.find { |c| c&.name == 'Steamboat' }
        end

        def train_subsidy
          @train_subsidy = @companies.find { |c| c&.name == 'Train Subsidy' }
        end

        def us_mail_line
          @us_mail_line = @companies.find { |c| c&.name == 'U.S. Mail Line' }
        end

        def advanced_track
          @advanced_track = @companies.find { |c| c&.name == 'Advanced Track' }
        end

        def central_illinois_boom
          @central_illinois_boom = @companies.find { |c| c&.name == 'Central Illinois Boom' }
        end

        def chicago_virden_coal_company
          @chicago_virden_coal_company = @companies.find { |c| c&.name == 'Chicago-Virden Coal Company' }
        end

        def diverse_cargo
          @diverse_cargo = @companies.find { |c| c&.name == 'Diverse Cargo' }
        end

        def engineering_mastery
          @engineering_mastery = @companies.find { |c| c&.name == 'Engineering Mastery' }
        end

        def frink_walker_co
          @frink_walker_co = @companies.find { |c| c&.name == 'Frink, Walker, & Co.' }
        end

        def illinois_steel_bridge_company
          @illinois_steel_bridge_company = @companies.find { |c| c&.name == 'Illinois Steel Bridge Company' }
        end

        def lincoln_funeral_car
          @lincoln_funeral_car = @companies.find { |c| c&.name == 'Lincoln Funeral Car' }
        end
      end
    end
  end
end
