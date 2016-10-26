class TradingBurst < MoneyBurst

  store :data , accessors: [  ]

  def threshold_gain_buy
    return 0.01
  end

  def threshold_gain_sell
    return 0.015
  end

end
