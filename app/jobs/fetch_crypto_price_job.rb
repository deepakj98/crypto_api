class FetchCryptoPriceJob < ApplicationJob
  queue_as :default

  DEFAULT_SYMBOLS = %w[bitcoin ethereum]

  def perform
    symbols = fetch_symbols

    symbols.each do |symbol|
      record = CryptoPrice.find_or_create_by!(symbol: symbol)

      result = CryptoPriceFetcher.fetch(symbol)
      price = result[:price]

      if price.present?
        record.update!(
          price: price,
          last_fetched_at: Time.current
        )

        Rails.cache.write("price_#{symbol}", price, expires_in: 5.minutes)
      else
        fallback(record)
      end
    end
  end

  private

  def fetch_symbols
    # If DB empty → seed defaults
    if CryptoPrice.count.zero?
      DEFAULT_SYMBOLS
    else
      CryptoPrice.pluck(:symbol)
    end
  end

  def fallback(record)
    cached = Rails.cache.read("price_#{record.symbol}")

    if cached
      Rails.logger.info("Fallback cache for #{record.symbol}")
    elsif record.price.present?
      Rails.logger.info("Fallback DB for #{record.symbol}")
    else
      Rails.logger.warn("No data for #{record.symbol}")
    end
  end
end
