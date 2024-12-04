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
            if @game.ic_formation_triggered?
              ic_shares = @game.companies.dup.select { |c| c.meta[:type] == :share}.each { |c| c.value = up_to_nearest_5(@game.ic.share_price.price) }
              ic_presidents_share = @game.companies.dup.select { |c| c.meta[:type] == :presidents_share}.each { |c| c.value = up_to_nearest_5(@game.ic.share_price.price * 2) }
              @companies = @game.companies.dup.select { |company| company.meta[:type] == :concession } + ic_presidents_share + ic_shares
            else
              @companies = @game.companies.dup.select { |c| c.meta[:type] == :concession }
            end
            @companies = @companies.sort_by {|c| c.meta[:type]}
          end
         
          def up_to_nearest_5(n)
            return n if n % 5 == 0
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

            ic = @game.ic
            #exchange for ordinary share of IC
            if company.meta[:type] == :share
              corporation = @game.corporation_by_id(company.sym)
              bundle = ShareBundle.new(ic.shares_of(ic).last)
              @game.share_pool.transfer_shares(bundle, player)
              if @game.ic_in_receivership?
                @game.companies.delete(company)
                company.close!
              #if IC now has a president, remove the president's cert proxy from the auction
              else
                company.close!
                @companies << company
                @companies = @companies.sort_by {|c| c.meta[:type]}
                pres = @companies.find {|c| c == @game.company_by_id('ICP')}
                @companies.delete(pres)
                @game.companies.delete(pres)
                pres.close!
                @game.add_ic_operating_ability
              end
            #exchange for president's share of IC
            elsif company.meta[:type] == :presidents_share
              corporation = @game.corporation_by_id(company.sym)
              bundle = ShareBundle.new(ic.shares_of(ic).first)
              @game.share_pool.transfer_shares(bundle, player)
              @game.companies.delete(company)
              company.close!
              @game.add_ic_operating_ability
            end

            #moves auction winner to the back of the line and starts again from the front of the line
            @game.players.insert((@round.entity_index - 1), @game.players.delete_at(@game.players.index(player)))
            @round.entity_index = @game.players.index(player)
          end
          
        end
      end
    end
  end
end