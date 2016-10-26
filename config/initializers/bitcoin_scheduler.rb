scheduler = Rufus::Scheduler.new

Dotenv.load(".env") # why not loading sometimes?!
api = CEX::API.new()

prod_mode = true

def pretty_log(s)
  File.open("#{Rails.root.to_s}/log/scheduler.txt", "a+"){|f| f << "#{Time.now} - #{s}\n" }
end

def init_log()
  File.open("#{Rails.root.to_s}/log/scheduler.txt", "w"){|f| f << "#{Time.now} - Starting scheduler\n" }
end

unless defined?(Rails::Console) #Rails.env == "production"
  init_log
	general_infos = GeneralInfo.last

	scheduler.every '2s' do

    pretty_log("--- Begin loop ---")

	  GeneralInfo.get_fees(api)
    general_infos.reload

    order_book = api.order_book

	  MoneyBurst.by_state("idle").each do |mb|

	    if mb.transactions.empty?
	      next
	    end

	    ActiveRecord::Base.transaction do

	      begin
          worth_ordering, amount_to_buy_or_sell, cur_price, gain = mb.is_worth_ordering?(order_book, general_infos.fees)

          pretty_log("Worth ordering? #{worth_ordering}, amount #{amount_to_buy_or_sell}, price #{cur_price}, gain #{gain}")

          if worth_ordering && mb.last_is_sell?
            pretty_log("worth ordering and is sell")

            if prod_mode
              pretty_log("!!!!!!!! BUYING before place order")

              balance_before = api.balance["USD"]["available"].to_f
              pretty_log("balance before #{balance_before}")

              res = api.place_order('buy', amount_to_buy_or_sell, cur_price)
              pretty_log("after place order")

              balance_after = api.balance["USD"]["available"].to_f # should be less
              pretty_log("balance after #{balance_after}")

              real_amount = balance_before - balance_after

              last_amount_was = mb.transactions.last.final_obtained_amount
              mb.remaining_after_buying = last_amount_was - real_amount
              mb.save
              pretty_log("last amount was #{last_amount_was}")
              pretty_log("real amount #{real_amount}")
              pretty_log("remaining_after buying #{mb.remaining_after_buying}")

              if res["error"].present?
                raise res.to_s
              end

              # placed the order
              mb.init_buy_order(res["id"])
              pretty_log("init buy order")
            end

          elsif worth_ordering && mb.last_is_buy?
            pretty_log("worth ordering and is buy")
            last_tx = mb.transactions.last

            if prod_mode
              pretty_log("before place order sell")
              res = api.place_order('sell', amount_to_buy_or_sell, cur_price)
              pretty_log("after place order sell")

              if res["error"].present?
                raise res.to_s
              end

              # placed the order
              mb.init_sell_order(res["id"])
              pretty_log("init sell order")
            end
          end
        rescue => e
          #mb.experiencing_issue_during_order!
          mb.logs.create(msg: "PROBLEM in main loop " + e.to_s)
          pretty_log("problem in main loop #{e.to_s}")
	      end

      end

	  end

    if prod_mode
      MoneyBurst.by_state("is_buying").each do |mb|
        ActiveRecord::Base.transaction do
          pretty_log("check is buying loop")

          begin
            res = api.get_order(mb.current_order_id)
            pretty_log("res = #{res}")

            if res["status"] == "d" # done
              pretty_log("ORDER DONE")
              tx = mb.transactions.create(trans_type: "buy", amount: res["amount"].to_f, price: res["price"].to_f,
                        final_obtained_amount: res["a:BTC:cds"].to_f)
              mb.bought!
            end

          rescue => e
            mb.experiencing_issue_during_order!
            mb.logs.create(msg: "problem in is_buying " + e.to_s)
            pretty_log("problem in is buying #{e.to_s}")
          end

        end

      end
    end

    if prod_mode
      MoneyBurst.by_state("is_selling").each do |mb|
        ActiveRecord::Base.transaction do
          pretty_log("check is selling loop")

          begin

            res = api.get_order(mb.current_order_id)
            pretty_log("res = #{res}")

            if res["status"] == "d" # done
              pretty_log("ORDER DONE")
              tx = mb.transactions.create(trans_type: "sell", amount: res["amount"].to_f, price: res["price"].to_f,
                        final_obtained_amount: res["a:USD:cds"].to_f) # + mb.remaining_after_buying
              mb.sold!
              mb.remaining_after_buying = 0
              mb.save
            end

          rescue => e
            mb.experiencing_issue_during_order!
            mb.logs.create(msg: "problem in is_selling" + e.to_s)
            pretty_log("problem in is selling #{e.to_s}")
          end

        end
      end
    end
	end
end

