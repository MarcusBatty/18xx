# frozen_string_literal: true

require_relative '../../../step/passable_auction'

module Engine
  module Game
    module G18IL
      module Step
        class SelectionAuction < Engine::Step::SelectionAuction
          def setup
            @game.players.each(&:unpass!)
            @bought_shares = []
            setup_auction
            company_setup
          end

          def company_setup
            @companies = @game.companies.select { |c| c.meta[:type] == :concession }.sort_by { |c| [c.meta[:share_count], c.sym] }
            @companies.each { |c| change_private_description(c) }
            prepare_ic_shares if @game.ic_formation_triggered? && !@game.ic.ipo_shares.empty?
          end

          def change_private_description(company)
            company.desc = "Can start #{company.sym} as a #{company.meta[:share_count]}-share corporation "\
                           'in the next Stock Round.'
          end

          def prepare_ic_shares
            ic_shares = assign_share_values(:share, @game.ic.share_price.price)
            ic_presidents_share = assign_share_values(:presidents_share, @game.ic.share_price.price * 2)
            shares_to_add = @game.ic.num_ipo_shares.dup

            if @game.ic_in_receivership?
              @companies += ic_presidents_share
              shares_to_add -= 2
            end

            @companies += ic_shares.take(shares_to_add)
          end

          def assign_share_values(type, value)
            @game.companies.select { |c| c.meta[:type] == type }.each { |c| c.value = up_to_nearest_five(value) }
          end

          def up_to_nearest_five(num)
            return num if (num % 5).zero?

            up_to_nearest_five(num + 1)
          end

          def may_bid?
            true
          end

          def actions(entity)
            return [] if entities.all?(&:passed?)

            entity == current_entity ? ACTIONS : []
          end

          def help
            str = []
            return str if @auctioning && @auctioning.meta[:type] != :concession

            if !@game.optional_rules.include?(:intro_game) &&
              @companies.any? do |c|
                c.meta[:type] == :concession &&
                @game.corporations.find { |corp| corp.name == c.sym }.companies.any?
              end
              str << [
                "The private companies attached to each concession are shown at the bottom of the concession's card. ",
                'Select the Entities tab to view their descriptions.',
              ]
            end

            unless @auctioning
              str << '—' unless str.empty?
              str << 'Start an auction or decline:'
            end
            str
          end

          def description
            return 'Bid on Selected Concession' if @auctioning&.meta&.[](:type) == :concession
            return 'Bid on Selected Share' if @auctioning

            @companies&.any? { |c| c.meta&.[](:type) != :concession } ? 'Bid on Concession or Share' : 'Bid on Concession'
          end

          def pass_description
            return 'Decline' unless @auctioning

            if @auctioning.meta[:type] == :concession
              "Pass (on #{@auctioning.id})"
            else
              "Pass (on #{@auctioning.name})"
            end
          end

          def process_pass(action)
            entity = action.entity

            if auctioning
              pass_auction(entity)
              resolve_bids
            else
              @log << "#{entity.name} declines to start an auction"
              @active_bidders.delete(entity)
              entity.pass!
            end
            next_entity!
          end

          def next_entity!
            @round.next_entity_index!
          end

          def post_win_bid(player, company)
            @round.goto_entity!(@auction_triggerer)
            entities.each(&:unpass!)
            @auction_triggerer = current_entity

            ic = @game.ic
            # exchange for ordinary share of IC
            case company.meta[:type]
            when :share
              bundle = ShareBundle.new(ic.shares.last)
              @game.share_pool.transfer_shares(bundle, player)
              # if IC now has a president and president's cert still exists,
              # remove the president's cert proxy from the auction
              if !@game.ic_in_receivership? && (pres = @game.companies.find { |c| c == @game.company_by_id('ICP') })
                company.close!
                @companies << company
                if @bought_shares.empty?
                  @companies.select! { |c| c.meta[:type] == :concession }
                  prepare_ic_shares unless @game.ic.ipo_shares.empty?
                else
                  @game.companies << @bought_shares.first
                  @companies << @bought_shares.first
                end
                @companies.delete(pres)
                @game.companies.delete(pres)
                pres.close!
                @companies = @companies.sort_by { |c| [c.meta[:type], c.meta[:share_count], c.sym] }
                @game.add_ic_operating_ability
              else
                @bought_shares << company
                @game.companies.delete(company)
                @companies.delete(company)
                company.close!
              end
            # exchange for president's share of IC
            when :presidents_share
              bundle = ShareBundle.new(ic.shares.first)
              @game.share_pool.transfer_shares(bundle, player)
              @game.companies.delete(company)
              company.close!
              @game.add_ic_operating_ability
            end
          end
        end
      end
    end
  end
end
