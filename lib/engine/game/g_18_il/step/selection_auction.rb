# frozen_string_literal: true

require_relative '../../../step/selection_auction'

module Engine
  module Game
    module G18IL
      module Step
        class SelectionAuction < Engine::Step::SelectionAuction
          def setup
            @game.players.each(&:unpass!)
            #@declined_players = []
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

          def help
            str = []
            return str if @auctioning&.meta&.[](:type) != :concession

            if !@game.optional_rules.include?(:intro_game) &&
              @companies.any? do |c|
                c.meta[:type] == :concession && @game.corporations.find do |corp|
                  corp.name == c.sym
                end.companies.any?
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
            if @auctioning
              'Bid on Selected Concession'
            else
              'Bid on Concession'
            end
          end

          def pass_description
            return 'Decline' unless @auctioning

            if @auctioning.meta[:type] == :concession
              "Pass (on #{@auctioning.id})"
            else
              "Pass (on #{@auctioning.name})"
            end
          end

          def buy_company(player, company, price)
            if (available = max_bid(player, company)) < price
              raise GameError,
                    "#{player.name} has #{@game.format_currency(available)} available '\
                    'and cannot spend #{@game.format_currency(price)}"
            end

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank) if price.positive?
            # removes company from the auction
            @companies.delete(company)
            @log << "#{player.name} wins the auction for #{company.name} with a bid of #{@game.format_currency(price)}"

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
