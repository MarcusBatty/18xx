# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18IL
      module Step
        class ExchangeChoicePlayer < Engine::Step::Base

          def actions(entity)
            return [] unless entity == current_entity

            ['choose']
          end

          def active_entities
            return [] unless @game.exchange_choice_player

            [@game.exchange_choice_player]
          end

          def description
            "Sell or Exchange President's Share"
          end

          def active?
            !active_entities.empty?
          end

          def choice_available?(entity)
            entity == @game.exchange_choice_player
          end

          def choices
            ["Sell for #{@game.format_currency(@game.merged_corporation.share_price.price)}", "Exchange for 10% share of #{@game.ic.name}"]
          end

          def choice_name
            "President's Share Decision"
          end

          def process_choose(action)
            player = action.entity

            if action.choice == "Exchange for 10% share of #{@game.ic.name}"
              @game.presidency_exchange(player)
            else
              @game.presidency_sell(player)
            end

            @game.exchange_choice_player = nil
            @game.merge_corporation_part_two
          end

        end
      end
    end
  end
end