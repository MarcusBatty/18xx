# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18IL
      module Step
        module CorpConvert
          
          def post_convert_pass_step!
            return unless @round.converted

              corp = @round.converted
              case corp.total_shares
              when 10
                min = 3
                max = 3
                @log << "#{corp.name} must buy 3 tokens"
              when 5
                min = 1
                max = 1
                @log << "#{corp.name} must buy 1 token"
              end
 
            price = 40
            @log << "Each token costs $40"
            @round.buy_tokens << {
              entity: corp,
              type: :convert,
              first_price: price,
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