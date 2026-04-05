require 'rails_helper'

RSpec.describe FetchCryptoPriceJob, type: :job do
  let(:symbol) { "bitcoin" }
  let(:cache_key) { "price_#{symbol}" }

  before do
    Rails.cache.clear
  end

  describe "#perform" do
    context "when API succeeds" do
      it "updates DB and writes to cache" do
        allow(CryptoPriceFetcher).to receive(:fetch).and_return({ price: nil, error: nil })

        allow(CryptoPriceFetcher).to receive(:fetch).with("bitcoin")
          .and_return({ price: 60000, error: nil })

        described_class.perform_now

        record = CryptoPrice.find_by(symbol: "bitcoin")

        record.reload
        expect(record.price.to_f).to eq(60000.0)
        expect(Rails.cache.read("price_bitcoin")).to eq(60000)
      end
    end

    context "when API fails but cache exists" do
      it "keeps cached value and does not overwrite DB" do
        Rails.cache.write(cache_key, 50000)

        CryptoPrice.delete_all

        allow(CryptoPriceFetcher).to receive(:fetch).and_return({ price: nil, error: "API failed" })

        described_class.perform_now

        record = CryptoPrice.find_by(symbol: symbol)

        expect(record).not_to be_nil
        expect(record.price).to be_nil   # DB not updated

        expect(Rails.cache.read(cache_key)).to eq(50000)
      end
    end

    context "when API fails but DB has value" do
      it "keeps existing DB price" do
        CryptoPrice.create!(symbol: symbol, price: 45000)

        allow(CryptoPriceFetcher).to receive(:fetch).with(symbol).and_return({ price: nil, error: "API failed" })

        described_class.perform_now

        record = CryptoPrice.find_by(symbol: symbol)

        expect(record.price).to eq(45000)
      end
    end

    context "when no data exists anywhere" do
      it "creates record but no price" do
        allow(CryptoPriceFetcher).to receive(:fetch).and_return({ price: nil, error: "" })

        described_class.perform_now

        record = CryptoPrice.find_by(symbol: symbol)

        expect(record).not_to be_nil
        expect(record.price).to be_nil
      end
    end
  end
end
