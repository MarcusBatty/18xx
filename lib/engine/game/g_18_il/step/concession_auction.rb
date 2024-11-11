# frozen_string_literal: true

require_relative '../../../step/concession_auction'

module Engine
  module Game
    module G18IL
      module Step
        class ConcessionAuction < Engine::Step::ConcessionAuction
          
          def description
            if @auctioning
              'Bid on Selected Concession'
            else
              'Bid on Concession'
            end
          end

          def setup
            @game.players.each(&:unpass!)
            setup_auction   
            #@companies = @game.companies
            @companies = @game.companies.select { |company| company.meta[:type] == :concession }
          end
          
        end
      end
    end
  end
end