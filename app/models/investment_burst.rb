class InvestmentBurst < MoneyBurst

  store :data , accessors: [  ]

  def threshold_gain_buy
    return 0.3
  end

  def threshold_gain_sell
    return 0.35
  end

end
