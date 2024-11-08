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
              @companies = @game.initial_auction_companies.dup 
            else
              @companies = @game.companies
            end
          end

          def description
            if @auctioning
              'Bid on Selected Concession'
            else
              'Bid on Concession'
            end
          end

          def buy_company(player, company, price)
            if (available = max_bid(player, company)) < price
              raise GameError, "#{player.name} has #{@game.format_currency(available)} "\
                               'available and cannot spend '\
                               "#{@game.format_currency(price)}"
            end
            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            @log << "#{player.name} wins the auction for #{company.name} "\
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