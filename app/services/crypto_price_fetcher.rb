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
        Rails.logger.warn("Invalid coin id: #{symbol}")
      end

      price
    else
      Rails.logger.error("API error: #{response.code} - #{response.body}")
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Fetch failed: #{e.message}")
    nil
  end
end
