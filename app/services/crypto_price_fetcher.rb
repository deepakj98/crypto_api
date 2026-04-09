# app/services/crypto_price_fetcher.rb
class CryptoPriceFetcher
  include HTTParty
  base_uri "https://api.coingecko.com/api/v3"

  def self.fetch(symbol)
    response = get("/simple/price",
      query: {
        ids: symbol.downcase,
        vs_currencies: "usd"
      }
    )

    if response.success?
      price = response.parsed_response.dig(symbol.downcase, "usd")

      if price.nil?
        error = "Invalid coin id: #{symbol}"
        Rails.logger.warn(error)
        { price: nil, error: error }
      else
        { price: price, error: nil }
      end
    else
      error = "API error: #{response.code}"
      Rails.logger.error("#{error} - #{response.body}")
      { price: nil, error: error }
    end

  rescue StandardError => e
    error = "Fetch failed: #{e.message}"
    Rails.logger.error(error)
    { price: nil, error: error }
  end
end
