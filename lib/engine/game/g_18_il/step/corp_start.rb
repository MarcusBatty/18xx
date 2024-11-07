# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18IL
      module Step
        module CorpStart
          
          def post_share_pass_step!
            return unless @round.corp_started

            corp = @round.corp_started
            case corp.total_shares
            when 10
              min = 3
              max = 6
              @log << "#{corp.name} must buy between #{min-1} and #{max-1} tokens"
            when 5
              min = 2
              max = 2
              @log << "#{corp.name} must buy 1 token"
            when 2
              min = 1
              max = 1
              @log << "#{corp.name} does not buy tokens"
            end
            
            price = 40
            @log << "Each token costs $40"
            @round.buy_tokens << {
              entity: corp,
              type: :start,
              first_price: 0,
              price: price,
              min: min,
              max: max,
            }
          end
        end
      end
    end
  end
end