# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18IL
      module Step
        class BuyTrain < Engine::Step::BuyTrain

          def actions(entity)
            return [] unless can_entity_buy_train?(entity)
            return ['sell_shares'] if entity == current_entity&.owner && can_ebuy_sell_shares?(current_entity)
            return [] if entity != current_entity
            return %w[sell_shares buy_train] if president_may_contribute?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)
            []
          end

          def description
            'Buy Trains'
          end

          def pass_description
            @acted ? 'Done (Trains)' : 'Skip (Trains)'
          end

          def pass!
            company = @game.train_subsidy
            company.close! if company.ability_uses.first < 4
            @last_share_sold_price = nil
            @last_share_issued_price = nil
            super
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(_train)
            'Scrap'
          end

          def process_buy_train(action)
            check_spend(action)
            buy_train_action(action)
            pass! if !can_buy_train?(action.entity) && pass_if_cannot_buy_train?(action.entity)
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

        end
      end
    end
  end
end