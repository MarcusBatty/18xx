# frozen_string_literal: true

require_relative '../../../step/concession_auction'

module Engine
  module Game
    module G18IL
      module Step
        class ConcessionAuction < Engine::Step::ConcessionAuction
          def setup
            @game.players.each(&:unpass!)
            @declined_players = []
            @bought_shares = []
            setup_auction

            if @game.ic_formation_triggered? && !@game.ic.ipo_shares.empty?
              prepare_ic_shares
            else
              @companies = filter_companies_by_type(:concession)
            end

            sort_companies!
          end

          def prepare_ic_shares
            ic_shares = assign_share_values(:share, @game.ic.share_price.price)
            ic_presidents_share = assign_share_values(:presidents_share, @game.ic.share_price.price * 2)

            @companies = filter_companies_by_type(:concession)

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

          def filter_companies_by_type(type)
            @game.companies.select { |c| c.meta[:type] == type }
          end

          def sort_companies!
            @companies = @companies.sort_by { |c| [c.meta[:type], c.sym] }
          end

          def up_to_nearest_five(num)
            return num if (num % 5).zero?

            up_to_nearest_five(num + 1)
          end

          def description
            if @auctioning
              'Bid on Selected Concession'
            else
              'Bid on Concession'
            end
          end

          def entities
            @round.entities.reject { |e| @declined_players.include?(e) }
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
            if @companies.empty? && entities.one?
              @declined_players << player
            else
              @round.next_entity_index!
            end
          end

          def process_pass(action)
            entity = action.entity

            if auctioning
              pass_auction(action.entity)
            else
              @log << "#{entity.name} declines to start auction and is removed from the round"
              entity.pass!
              @declined_players << entity
            end
          end

          def start_auction(bid)
            @auctioning = bid.company
            @log << "-- #{bid.entity.name} nominates #{@auctioning.name} for auction --"
            add_bid(bid)
            starter = bid.entity
            start_price = bid.price

            bids = @bids[@auctioning]

            entities.rotate(entities.find_index(starter)).each_with_index do |player, idx|
              next if player == starter
              next if max_bid(player, @auctioning) < start_price + min_increment

              bids << (Engine::Action::Bid.new(player,
                                               corporation: @auctioning,
                                               price: idx - entities.size))
            end
            # resolve auction immediately after starting if no other player can afford to bid
            resolve_bids if entities.reject { |e| e == starter }
                            .select { |e| max_bid(e, @auctioning) >= start_price + min_increment }.empty?
            post_auction if @companies.empty? && entities.one?
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
              bundle = ShareBundle.new(ic.shares.last)
              @game.share_pool.transfer_shares(bundle, player)
              if @game.ic_in_receivership?
                @bought_shares << company
                @game.companies.delete(company)
                @companies.delete(company)
                company.close!
              # if IC now has a president and president's cert still exists,
              # remove the president's cert proxy from the auction
              elsif (pres = @game.companies.find { |c| c == @game.company_by_id('ICP') })
                company.close!
                @companies << company
                @game.companies << @bought_shares.first
                @companies << @bought_shares.first
                @companies.delete(pres)
                @game.companies.delete(pres)
                pres.close!
                @companies = @companies.sort_by(&:sym)
                @companies = @companies.sort_by { |c| c.meta[:type] }
                @game.add_ic_operating_ability
              else
                company.close!
                @game.companies.delete(company)
                @companies.delete(company)
              end
            # exchange for president's share of IC
            when :presidents_share
              bundle = ShareBundle.new(ic.shares.first)
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
