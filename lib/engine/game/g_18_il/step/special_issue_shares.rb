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
            return actions if @game.last_set_triggered
            return actions unless entity.corporation?
            return actions unless entity == current_entity
    
            actions << 'sell_shares' unless issuable_shares(entity).empty?
            actions << 'pass' if blocks? && !actions.empty?
    
            actions
          end

          def visible_corporations
            [current_entity]
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
            @game.sp_used = current_entity
            old = action.bundle.corporation.share_price.price
            @game.sell_shares_and_change_price(action.bundle)
            new = action.bundle.corporation.share_price.price
            @log << "#{action.bundle.corporation.name}'s share price moves left horizontally from $#{old} to $#{new}"
            @game.share_premium.close!
            pass!
          end

          def ability(entity, share: nil)
            return unless entity&.company?
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