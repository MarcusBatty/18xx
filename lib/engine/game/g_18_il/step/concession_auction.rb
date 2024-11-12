# frozen_string_literal: true

require_relative '../../../step/concession_auction'

module Engine
  module Game
    module G18IL
      module Step
        class ConcessionAuction < Engine::Step::ConcessionAuction
          


          def setup
            @game.players.each(&:unpass!)
            setup_auction   
            #@companies = @game.companies
            @companies = @game.companies.select { |company| company.meta[:type] == :concession }
          end
         
          def description
            if @auctioning
              'Bid on Selected Concession'
            else
              'Bid on Concession'
            end
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
            @round.next_entity_index!
          end
          
          def buy_company(player, company, price)
            if (available = max_bid(player, company)) < price
              raise GameError, "#{player.name} has #{@game.format_currency(available)} available and cannot spend #{@game.format_currency(price)}"
            end
            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            #removes company from the auction
            @companies.delete(company)
            @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"
            #moves auction winner to the back of the line and starts again from the front of the line
            @game.players.insert((@round.entity_index - 1), @game.players.delete_at(@game.players.index(player)))
            @round.entity_index = @game.players.index(player)
          end
          
        end
      end
    end
  end
end