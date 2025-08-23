# frozen_string_literal: true

require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18IL2
      module Step
        class SelectionAuction < Engine::Step::SelectionAuction
          def setup
            @game.players.each(&:unpass!)
            @bought_shares = []
            setup_auction
            company_setup

            while !@auctioning && @companies.any? && current_entity&.player? && current_entity.cash < starting_bid(min_company)
              @log << "#{current_entity.name} declines to start an auction (insufficient cash)"
              current_entity.pass!
              break if entities.all?(&:passed?)

              @round.next_entity_index!
            end
          end

          def min_company
            return nil if @companies.nil? || @companies.empty?

            # concessions always start at $10 minimum
            min_value_company = @companies.min_by(&:value)
            min_value = [min_value_company.value, 10].min

            @companies.find { |c| c.value == min_value } || min_value_company
          end

          def company_setup
            if big_lots_first_turn?
              @companies = @game.big_lot_proxies
            else
              concessions = @game.companies.select { |c| c.meta[:type] == :concession }
              @companies = concessions.sort_by { |c| [c.meta[:share_count], c.sym] }
              @companies.each { |c| change_private_description(c) }
              prepare_ic_shares if @game.ic_formation_triggered? && !@game.ic.ipo_shares.empty?
            end
          end

def change_private_description(company)
  corp = @game.corporations.find { |c| c.name == company.sym }
  share_count = company&.meta&.[](:share_count) || corp&.total_shares || 10

  base = "Can start #{company.sym} as a #{share_count}-share corporation."
  holdings = nil

  if corp && (corp.cash.positive? || corp.trains.any?)
    cash_part = corp.cash.positive? ? @game.format_currency(corp.cash) : nil

    if corp.trains.any?
      items = corp.trains.map { |t| t.name.match?(/^\d$/) ? "#{t.name}-" : t.name }
      if items.size == 1
        name = items.first
        trains_part = name.end_with?('-') ? "#{name}train" : "#{name} train"
      else
        list = cash_part ? items.join(', ') : @game.list_with_and(items)
        trains_part = "#{list} train"
      end
    end

    parts = [cash_part, trains_part].compact
    holdings = "\nCorporation holdings: #{parts.join(' and ')}" unless parts.empty?
  end

  company.desc = "#{base}#{holdings}"
end





          def prepare_ic_shares
            ic_shares = assign_share_values(:share, @game.ic.share_price.price)
            ic_presidents_share = assign_share_values(:presidents_share, @game.ic.share_price.price * 2)
            shares_to_add = @game.ic.num_ipo_shares.dup

            if @game.ic_in_receivership?
              @companies += ic_presidents_share
              shares_to_add -= 2
            end

            @companies += ic_shares.take(shares_to_add)
          end

          def assign_share_values(type, value)
            @game.companies.select { |c| c.meta[:type] == type }.each { |c| c.value = up_to_nearest_five(value) }
          end

          def up_to_nearest_five(num)
            return num if (num % 5).zero?

            up_to_nearest_five(num + 1)
          end

          def starting_bid(company)
            return 10 if !company || company&.meta&.[](:type) == :concession

            company.min_bid
          end

          def may_bid?
            true
          end

          def actions(entity)
            return [] if entities.all?(&:passed?)
            return [] if @companies.empty?
            return %w[bid] if big_lots_first_turn? && !@auctioning

            entity == current_entity ? ACTIONS : []
          end

          def big_lots_first_turn?
            @game.big_lots_variant? && @game.turn == 1
          end

          def help
            str = []
            return str if @auctioning && @auctioning.meta[:type] != :concession

            if big_lots_first_turn? && !@auctioning
              str << 'Choose one Big Lot to start an auction. The winner receives all four concessions in that lot; '\
                     'the other player receives the remaining lot for free.'
              return str
            end

            if !@game.intro_game? &&
              @companies.any? do |c|
                c.meta[:type] == :concession &&
                @game.corporations.find { |corp| corp.name == c.sym }.companies.any?
              end
              str << [
                "The private companies attached to each concession are shown at the bottom of the concession's card. ",
                'Select the Entities tab to view their descriptions.',
              ]
            end

            unless @auctioning
              str << '—' unless str.empty?
              str << 'Start an auction or decline:'
            end
            str
          end

          def description
            return (@auctioning ? 'Bid on Selected Big Lot' : 'Bid on Big Lot') if big_lots_first_turn?
            return 'Bid on Selected Concession' if @auctioning&.meta&.[](:type) == :concession
            return 'Bid on Selected Share' if @auctioning

            @companies&.any? { |c| c.meta&.[](:type) == :share } ? 'Bid on Concession or Share' : 'Bid on Concession'
          end

          def pass_description
            return 'Decline' unless @auctioning

            if @auctioning.meta[:type] == :concession
              "Pass (on #{@auctioning.id})"
            else
              "Pass (on #{@auctioning.name})"
            end
          end

def process_pass(action, reason = nil)
  entity = action.entity

  if auctioning
    pass_auction(entity)
    resolve_bids
  else
    msg = "#{entity.name} declines to start an auction"
    msg += " (#{reason})" if reason
    @log << msg
    entity.pass!
    return pass! if entities.all?(&:passed?) || @companies.empty?
    next_entity!
  end

  return pass! if @companies.none?
end

def next_entity!
  @round.next_entity_index!
  entity = entities[entity_index]
  entity.pass! if @auctioning && entity && max_bid(entity, @auctioning) < min_bid(@auctioning)

  while !@auctioning && @companies.any? && entity&.player? && !entity.passed? &&
        entity.cash < starting_bid(min_company)
    return process_pass(Engine::Action::Pass.new(entity), 'insufficient cash')
  end

  next_entity! if entity&.passed?
end


          def add_bid(bid)
            company = bid_target(bid)
            entity = bid.entity
            price  = bid.price
            min    = min_bid(company)
            raise GameError, "No minimum bid available for #{company.name}" unless min

            raise GameError, "Minimum bid is #{@game.format_currency(min)} for #{company.name}" if price < min
            if must_bid_increment_multiple? && ((price - min) % @game.class::MIN_BID_INCREMENT).nonzero?
              raise GameError, "Must increase bid by a multiple of #{@game.class::MIN_BID_INCREMENT}"
            end
            if price > max_bid(entity, company)
              raise GameError, "Cannot afford bid. Maximum possible bid is #{max_bid(entity, company)}"
            end

            bids = (@bids[company] ||= [])
            bids.reject! { |b| b.entity == entity }
            bids << bid

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"

            return unless @auctioning

            min = min_bid(@auctioning)
            passing = @active_bidders.reject { |p| p == entity || max_bid(p, @auctioning) >= min }
            passing.each do |p|
              @game.log << "#{p.name} cannot bid #{@game.format_currency(min)} and is out of the auction for #{@auctioning.name}"
              remove_from_auction(p)
            end
          end

          def win_bid(winner, company)
            if company.meta[:type] == :big_lot
              player = winner.entity
              price  = winner.price
              @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"
              player.spend(price, @game.bank) if price.positive?
            else
              super
            end
          end

          def resolve_bids
            super
            return pass! if @companies.none?

            entities.each(&:unpass!)
            @round.goto_entity!(@auction_triggerer)
            next_entity!
          end


          def resolve_big_lot!(winner_player, lot_idx)
            other_player = (@game.players - [winner_player]).first
            lot_won  = @game.big_lots[lot_idx]
            lot_free = @game.big_lots[1 - lot_idx]

            [[lot_won, winner_player], [lot_free, other_player]].each do |lot, player|
              lot.each do |corp|
                company = @game.company_by_id(corp.name)
                assign_company(company, player)
                change_private_description(company)
              end
            end

            @log << "#{winner_player.name} wins Big Lot #{lot_idx + 1} and receives #{@game.list_with_and(lot_won.map(&:name))}"
            @log << "#{other_player.name} wins Big Lot #{2 - lot_idx} and receives #{@game.list_with_and(lot_free.map(&:name))}"

            @game.big_lot_proxies.each do |c|
              c.close!
              @game.companies.delete(c)
            end

            @game.big_lot_proxies.clear
            pass!
          end

          def post_win_bid(winner, company)
            resolve_big_lot!(winner.entity, company.meta[:lot_index]) if company.meta[:type] == :big_lot

            player = winner.entity
            ic = @game.ic

            # exchange for ordinary share of IC
            case company.meta[:type]
            when :share
              bundle = ShareBundle.new(ic.shares.last)
              @game.share_pool.transfer_shares(bundle, player)
              # if IC now has a president and president's cert still exists,
              # remove the president's cert proxy from the auction
              if !@game.ic_in_receivership? && (pres = @game.companies.find { |c| c == @game.company_by_id('ICP') })
                company.close!
                @companies << company
                if @bought_shares.empty?
                  @companies.select! { |c| c.meta[:type] == :concession }
                  prepare_ic_shares unless @game.ic.ipo_shares.empty?
                else
                  @game.companies << @bought_shares.first
                  @companies << @bought_shares.first
                end
                @companies.delete(pres)
                @game.companies.delete(pres)
                pres.close!
                @companies = @companies.sort_by { |c| [c.meta[:type], c.meta[:share_count], c.sym] }
                @game.add_ic_operating_ability
              else
                @bought_shares << company
                @game.companies.delete(company)
                @companies.delete(company)
                company.close!
              end
            # exchange for president's share of IC
            when :presidents_share
              bundle = ShareBundle.new(ic.shares.first)
              @game.share_pool.transfer_shares(bundle, player)
              @game.companies.delete(company)
              company.close!
              @game.add_ic_operating_ability
            end
          end
        end
      end
    end
  end
end
