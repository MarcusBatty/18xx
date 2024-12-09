# frozen_string_literal: true

require_relative '../../../step/concession_auction'

module Engine
  module Game
    module G18IL
      module Step
        class ConcessionAuction < Engine::Step::ConcessionAuction
          def setup
            @game.players.each(&:unpass!)
            @passed_players = []
            setup_auction
            if @game.ic_formation_triggered?
              ic_shares = @game.companies.dup.select { |c| c.meta[:type] == :share }
              ic_shares = ic_shares.each { |c| c.value = up_to_nearest_5(@game.ic.share_price.price) }
              ic_presidents_share = @game.companies.dup.select { |c| c.meta[:type] == :presidents_share }
              ic_presidents_share = ic_presidents_share.each { |c| c.value = up_to_nearest_5(@game.ic.share_price.price * 2) }
              @companies = @game.companies.dup.select do |company|
                company.meta[:type] == :concession
              end + ic_presidents_share + ic_shares
            else
              @companies = @game.companies.dup.select { |c| c.meta[:type] == :concession }
            end
            @companies = @companies.sort_by { |c| c.meta[:type] }
          end

          def up_to_nearest_5(n)
            return n if (n % 5).zero?

            rounded = n.round(-1)
            rounded > n ? rounded : rounded + 5
          end

          def description
            if @auctioning
              'Bid on Selected Concession'
            else
              'Bid on Concession'
            end
          end

          def actions(entity)
            return [] if finished?

            correct = false

            active_auction do |_company, bids|
              correct = bids.min_by(&:price).entity == entity
            end

            correct || entity == current_entity ? ACTIONS : []
          end

          def resolve_bids
            return unless @bids[@auctioning].one?

            bid = @bids[@auctioning].first
            @auctioning = nil
            price = bid.price
            company = bid.company
            player = bid.entity
            @bids.delete(company)
            buy_company(player, company, price)
            if @companies.empty? && @game.players.one?
              @game.players.delete(player)
              @passed_players << player
              @passed_players.each { |p| @game.players << p }
            else
              @round.next_entity_index!
            end
          end

          def process_pass(action)
            entity = action.entity

            if auctioning
              pass_auction(action.entity)
            else
              @log << "#{entity.name} passes bidding"
              entity.pass!
              @passed_players << entity
              @game.players.delete(entity)
              @passed_players.each { |p| @game.players << p } if @game.players.empty?
            end
          end

          def start_auction(bid)
            super
            resolve_bids if @game.players.one?
            post_auction if @companies.empty? && @game.players.one?
          end

          def buy_company(player, company, price)
            if (available = max_bid(player, company)) < price
              raise GameError,
                    "#{player.name} has #{@game.format_currency(available)} available '\
                    'and cannot spend #{@game.format_currency(price)}"
            end

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            # removes company from the auction
            @companies.delete(company)
            @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"

            ic = @game.ic
            # exchange for ordinary share of IC
            case company.meta[:type]
            when :share
              bundle = ShareBundle.new(ic.shares_of(ic).last)
              @game.share_pool.transfer_shares(bundle, player)
              if @game.ic_in_receivership?
                @game.companies.delete(company)
                company.close!
              # if IC now has a president, remove the president's cert proxy from the auction
              else
                company.close!
                @companies << company
                @companies = @companies.sort_by { |c| c.meta[:type] }
                pres = @companies.find { |c| c == @game.company_by_id('ICP') }
                @companies.delete(pres)
                @game.companies.delete(pres)
                pres.close!
                @game.add_ic_operating_ability
              end
            # exchange for president's share of IC
            when :presidents_share
              bundle = ShareBundle.new(ic.shares_of(ic).first)
              @game.share_pool.transfer_shares(bundle, player)
              @game.companies.delete(company)
              company.close!
              @game.add_ic_operating_ability
            end

            # moves auction winner to the back of the line and starts again from the front of the line.
            @game.players.insert((@game.players.size - 1), @game.players.delete_at(@game.players.index(player)))
            @round.entity_index = @game.players.index(player)
          end
        end
      end
    end
  end
end
