class MoneyBurst < ApplicationRecord

  store :data , accessors: [ :current_order_id ]

  has_many :transactions
  has_many :logs

  state_machine :initial => :idle do

    event :set_idle do
      transition any => :idle
    end

    event :buy_order do
      transition :idle => :is_buying
    end

    event :bought do
      transition :is_buying => :idle
    end

    event :sell_order do
      transition :idle => :is_selling
    end

    event :sold do
      transition :is_selling => :idle
    end

    event :experiencing_issue_during_order do
      transition any => :issue_order
    end

  end

  scope :by_state, -> state { where(state: state) }
  scope :by_type, -> type { where(type: type) }

  def self.calc_bitcoin(usd_amount, fee, cur_price)
    #puts "calc bitcoin #{usd_amount} #{fee} #{cur_price}"
    return ((usd_amount * (1.0 - (fee / 100.0))) / cur_price).round(8)
  end

  def is_worth_ordering?(order_book, fees)

    last_tx = transactions.last

    if last_tx.trans_type == "sell"
      bids = order_book["bids"].sort_by { |o| o[0] }.reverse

      if bids.count < 3
        return false, 0, 0, 0
      end

      cur_price = ((bids[1][0] + bids[2][0]) / 2.0).round(4)

      return false, 0, 0, 0 if cur_price <= 0 # probably a problem?

      # means we now have USD
      amount = last_tx.final_obtained_amount-0.025
      amount_bitcoin_to_buy = self.class.calc_bitcoin(amount, fees["buy"].to_f, cur_price)

      diff_price = cur_price - last_tx.price
      percentage_gain = diff_price/last_tx.price

      # TODO: adjust percentage gain!
      return percentage_gain <= -0.004, amount_bitcoin_to_buy, cur_price, percentage_gain
    elsif last_tx.trans_type == "buy"

      asks = order_book["asks"].sort_by { |o| o[0] }

      if asks.count < 3
        return false, 0, 0, 0
      end

      cur_price = ((asks[1][0] + asks[2][0]) / 2.0).round(4)

      return false, 0, 0, 0 if cur_price <= 0 # probably a problem?

      fee_ratio = (1.0 - (fees["sell"].to_f / 100.0))
      amount_usd_to_buy = last_tx.final_obtained_amount * cur_price * fee_ratio
      amount_bitcoin_to_sell = last_tx.final_obtained_amount

      #last_amt = last_tx.final_obtained_amount * last_tx.price
      #diff_usd = amount_usd_to_buy - last_amt
      #percentage_gain = diff_usd / last_amt

      diff_price = cur_price - last_tx.price
      percentage_gain = diff_price/last_tx.price

      # TODO: adjust percentage gain!
      return percentage_gain >= 0.004, amount_bitcoin_to_sell, cur_price, percentage_gain
    end

    return false, 0, 0, 0

  end

  def init_buy_order(p_order_id)
    buy_order!
    touch # change updated_at
    self.current_order_id = p_order_id
    save
  end

  def init_sell_order(p_order_id)
    sell_order!
    touch # change updated_at
    self.current_order_id = p_order_id
    save
  end

  def last_is_sell?
    return transactions.last.trans_type == "sell" rescue false
  end

  def last_is_buy?
    return transactions.last.trans_type == "buy" rescue false
  end

end
