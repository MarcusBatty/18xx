# frozen_string_literal: true

require_relative 'corporate_issue_buy_shares'

module Engine
  module Game
    module G18IL
      module Step
        class SpecialIssueShares < CorporateIssueBuyShares

          ACTIONS = %w[sell_shares].freeze

          def description
            "Use #{@game.share_premium&.name} ability"
          end

          def actions(entity)
            actions = []
            return actions unless entity.corporation?
            return actions unless entity == current_entity
    
            actions << 'sell_shares' unless issuable_shares(entity).empty?
            actions << 'pass' if blocks? && !actions.empty?
    
            actions
          end

          def active_entities
            return [] unless @game.share_premium&.owner == @round.current_operator
              [@game.share_premium&.owner].compact
            end

          def pass_description
            'Skip (Special Issue)'
          end

          def help
            return [] unless active?

            [
              'Issue in this step to use Share Premium to issue share at double the current share price',
            ]
          end

          def sell_shares_description
            'test'
          end

          def issuable_shares(entity)
            # Done via Sell Shares
            @game.issuable_shares(entity)
          end

          def process_sell_shares(action)
            company = action.entity
            corporation = @round.current_operator
            ability = ability(company, share: @game.issuable_shares(corporation))
            @game.sp_used = true
            @game.sell_shares_and_change_price(action.bundle)
            old = action.bundle.corporation.share_price.price
            @game.stock_market.move_left(action.bundle.corporation) 
            new = action.bundle.corporation.share_price.price
            @log << "#{action.bundle.corporation.name}'s share price moves left horizontally from $#{old} to $#{new}"

            pass!
          end

          # def process_buy_train(action)
          #   company = action.entity
          #   corporation = @round.current_operator
          #   ability = ability(company, train: action.train)
          #   from_depot = action.train.from_depot?
          #   buy_train_action(action, corporation)

          #   @round.bought_trains << corporation if from_depot && @round.respond_to?(:bought_trains)

          #   closes_company = ability.count && (ability.count - 1).zero? && ability.closed_when_used_up

          #   ability.use! if action.price < action.train.price &&
          #     ability.discounted_price(action.train, action.train.price) == action.price
          #   if closes_company && !action.entity.closed?
          #     @game.company_closing_after_using_ability(company)
          #     company.close!
          #   end

          #   pass! unless can_buy_train?(corporation)
          # end

          def ability_timing
            %w[%current_step% owning_corp_or_turn owning_player_or_turn]
          end

          def ability(entity, share: nil)
            return unless entity&.company?
            @log << "hello"
            @game.abilities(entity, :description, time: ability_timing) do |ability|
              return ability if !share
            end

            nil
          end

        end
      end
    end
  end
end