require "openssl"
require "net/http"
require "net/https"
require "uri"
require "json"
#require "addressable/uri"

module CEX

  class API
    attr_accessor :api_key, :api_secret, :username, :nonce_v

    def initialize()
      self.username = ENV["CEX_UID"]
      self.api_key = ENV["CEX_KEY"]
      self.api_secret = ENV["CEX_SECRET"]
    end

    def api_call(method, param = {}, http_method = "get", priv = true, action = '', is_json = true)
      url = "https://cex.io/api/#{ method }/#{ action }"
      if priv
        self.nonce
        param.merge!(:key => self.api_key, :signature => self.signature.to_s, :nonce => self.nonce_v)
      end

      if http_method == "post"
        answer = self.post(url, param)
      elsif http_method == "get"
        answer = self.get(url)
      end

      # unfortunately, the API does not always respond with JSON, so we must only
      # parse as JSON if is_json is true.
      if is_json
        JSON.parse(answer)
      else
        answer
      end
    end

    def last_price(couple = "BTC/USD")
      # last_price/BTC/USD
      self.api_call("last_price", {}, "get", true, couple)
    end

    def fees(couple = "BTC/USD")
      self.api_call("get_myfee", {}, "post", true)["data"][couple.gsub("/", ":")]
    end

    def full_fees
      self.api_call("get_myfee", {}, "post", true)
    end

    def ticker(couple = 'BTC/USD')
      self.api_call('ticker', {}, false, couple)
    end

    def convert(couple = 'BTC/USD', amount = 1)
      self.api_call('convert', {:amnt => amount}, false, couple)
    end

    # Bid is sell orders and asks is for buy orders.
    def order_book(couple = 'BTC/USD')
      self.api_call('order_book', {}, "get", false, couple)
    end

    def trade_history(since = 1, couple = 'BTC/USD')
      self.api_call('trade_history', {:since => since.to_s}, false, couple)
    end

    def balance
      self.api_call('balance', {}, "post", true)
    end

    def open_orders(couple = 'BTC/USD')
      self.api_call('open_orders', {}, "post", true, couple)
    end

    def cancel_order(order_id)
      self.api_call('cancel_order', {:id => order_id.to_s}, "post", true, '',false)
    end

    def place_order(ptype = 'buy', amount = 1, price =1, couple = 'BTC/USD')
      self.api_call('place_order', {:type => ptype, :amount => amount.to_s, :price => price.to_s}, "post", true, couple)
    end

    def get_order(order_id, couple = 'BTC/USD')
      self.api_call('get_order', {:id => order_id}, "post", true)
    end

    def get_order_tx(order_id, couple = 'BTC/USD')
      self.api_call('get_order_tx', {:id => order_id}, "post", true)
    end

    def hashrate
      self.api_call('ghash.io', {}, true, 'hashrate')
    end

    def workers_hashrate
      self.api_call('ghash.io', {}, true, 'workers')
    end

    def nonce
      self.nonce_v = (Time.now.to_f * 1000000).to_i.to_s
    end

    def signature
      str = self.nonce_v + self.username + self.api_key
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), self.api_secret, str)
    end

    def post(url, param)
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      params = Addressable::URI.new
      params.query_values = param
      https.post(uri.path, params.query).body
    end

    def get(url)
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      params = Addressable::URI.new
      https.get(uri.path).body
    end
  end

end
