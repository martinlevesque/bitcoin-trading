namespace :cex do
  task create_investment_burst: :environment do

    raise "invalid, missing USD_AMOUNT" unless ENV["USD_AMOUNT"].present?
    usd_amount = ENV["USD_AMOUNT"].to_f

    create_money_burst("InvestmentBurst", usd_amount)

  end

  task create_trading_burst: :environment do

    raise "invalid, missing USD_AMOUNT" unless ENV["USD_AMOUNT"].present?
    usd_amount = ENV["USD_AMOUNT"].to_f

    create_money_burst("TradingBurst", usd_amount)

  end

  def create_money_burst(type, usd_amount)

    raise "to fix"

    ActiveRecord::Base.transaction do
      api = CEX::API.new()

      GeneralInfo.get_fees(api)
      general_infos = GeneralInfo.last

      mb = type.constantize.create(init_amount: usd_amount.to_f, state: "idle")

      p = api.last_price

      cur_price = p["lprice"].to_f

      bitcoins_to_buy = MoneyBurst.calc_bitcoin(usd_amount, general_infos.fees["buy"].to_f, cur_price)

      res = api.place_order('buy', bitcoins_to_buy, cur_price)

      if res["error"].present?
        raise res.to_s
      end

      # placed the order
      mb.init_buy_order(res["id"])
    end
  end

end
