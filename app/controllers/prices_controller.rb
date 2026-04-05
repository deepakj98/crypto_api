class PricesController < ApplicationController
  def index
    if params[:symbol].present?
      return redirect_to price_path(params[:symbol].downcase)
    end

    @prices = CryptoPrice.all
  end

  def show
    @symbol = params[:symbol].downcase

    @record = CryptoPrice.find_by(symbol: @symbol)
    @cached_price = Rails.cache.read(cache_key(@symbol))

    result = CryptoPriceFetcher.fetch(@symbol)

    live_price = result[:price]
    @error = result[:error]

    if live_price.present?
      @record ||= CryptoPrice.new(symbol: @symbol)
      @record.update!(
        price: live_price,
        last_fetched_at: Time.current
      )

      Rails.cache.write(cache_key(@symbol), live_price, expires_in: 5.minutes)

      @price = live_price
      @source = "api"

    elsif @cached_price.present?
      @price = @cached_price
      @source = "cache"

    elsif @record&.price.present?
      @price = @record.price
      @source = "db"

    else
      @price = nil
    end

    respond_to do |format|
      format.html { render :show }

      format.json do
        if @price
          render json: { symbol: @symbol, price: @price, source: @source }
        else
          render json: { error: "Price not available" }, status: :not_found
        end
      end
    end
  end

  private

  def cache_key(symbol)
    "price_#{symbol}"
  end
end
  