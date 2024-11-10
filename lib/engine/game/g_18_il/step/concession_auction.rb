# frozen_string_literal: true

require_relative '../../../step/concession_auction'

module Engine
  module Game
    module G18IL
      module Step
        class ConcessionAuction < Engine::Step::ConcessionAuction
          
          MIN_BID = 0

          def setup
            setup_auction    
            if @game.turn == 1
              @companies = @game.initial_auction_companies
            else
              @companies = @game.companies
            end
          end

          def start_auction(bid)
            @auctioning = bid.company
            @log << "#{bid.entity.name} nominates the #{@auctioning.sym} concession for auction"
            add_bid(bid)
            starter = bid.entity
            start_price = bid.price
    
            bids = @bids[@auctioning]
    
            entities.rotate(entities.find_index(starter)).each_with_index do |player, idx|
              next if player == starter
              next if max_bid(player, @auctioning) <= start_price
    
              bids << (Engine::Action::Bid.new(player,
                                               corporation: @auctioning,
                                               price: idx - entities.size))
            end
          end

          def description
            if @auctioning
              'Bid on Selected Concession'
            else
              'Bid on Concession'
            end
          end

          def pass_auction(entity)
            @log << "#{entity.name} passes on #{auctioning.sym}"
            remove_from_auction(entity)
          end

          def add_bid(bid)
            company = bid_target(bid)
            entity = bid.entity
            price = bid.price
            min = min_bid(company)
            raise GameError, "Minimum bid is #{@game.format_currency(min)} for #{company.name}" if price < min
            if must_bid_increment_multiple? && ((price - min) % @game.class::MIN_BID_INCREMENT).nonzero?
              raise GameError, "Must increase bid by a multiple of #{@game.class::MIN_BID_INCREMENT}"
            end
            if price > max_bid(entity, company)
              raise GameError, "Cannot afford bid. Maximum possible bid is #{max_bid(entity, company)}"
            end
    
            bids = @bids[company]
            bids.reject! { |b| b.entity == entity }
            bids << bid
    
            @log << "#{bid.entity.name} bids #{@game.format_currency(bid.price)} for #{bid.company.sym}"
          end

          def buy_company(player, company, price)
            if (available = max_bid(player, company)) < price
              raise GameError, "#{player.name} has #{@game.format_currency(available)} "\
                               'available and cannot spend '\
                               "#{@game.format_currency(price)}"
            end
            company.owner = player
            player.companies << company
            @companies.delete(company)
            player.spend(price, @game.bank) if price.positive?
            @log << "#{player.name} wins the #{company.sym} concession "\
                    "with a bid of #{@game.format_currency(price)}"
          end

          def min_bid(company)
            return unless company

            high_bid = highest_bid(company)
            high_bid ? high_bid.price + min_increment : MIN_BID
          end
        end
      end
    end
  end
end