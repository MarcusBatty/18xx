# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18IL
      module Step
        class ExchangeChoiceCorp < Engine::Step::Base

          def actions(entity)
            return [] unless entity == current_entity

            ['choose']
          end

          def active_entities
            return [] unless @game.exchange_choice_corps

            @game.exchange_choice_corps
          end

          def description
            "Sell or Exchange President's Share"
          end

          def active?
            !active_entities.empty?
          end

          def choice_available?(entity)
            entity == @game.exchange_choice_corp
          end

          def can_sell?
            false
          end

          def ipo_type(_entity)
            nil
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

          def choices
            choices = []
            choices << ["Sell for #{@game.format_currency(@game.ic.share_price.price / 2)}"]
            choices << ["Exchange for #{@game.ic.name} share for #{@game.format_currency(@game.ic.share_price.price / 2)}"] if @game.ic.num_market_shares.positive?
            choices
          end

          def choice_name
            "Option Cube Decision"
          end

          def process_choose(action)
            corp = action.entity

            if action.choice == "Sell for #{@game.format_currency(@game.ic.share_price.price / 2)}"
              @game.option_sell(corp)
            else
              @game.option_exchange(corp)
            end

            @game.exchange_choice_corp = nil
            @game.exchange_choice_corps.delete_at(0)
          end

        end
      end
    end
  end
end