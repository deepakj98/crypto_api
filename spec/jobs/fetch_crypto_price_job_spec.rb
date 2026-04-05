require 'rails_helper'

RSpec.describe FetchCryptoPriceJob, type: :job do
  let(:symbols) { %w[bitcoin ethereum] }

  before do
    Rails.cache.clear
  end

  describe "#perform" do
    context "when API succeeds" do
      it "updates prices and caches them" do
        allow(CryptoPriceFetcher).to receive(:fetch).with("bitcoin").and_return(60000)
        allow(CryptoPriceFetcher).to receive(:fetch).with("ethereum").and_return(3000)

        described_class.perform_now

        bitcoin = CryptoPrice.find_by(symbol: "bitcoin")
        ethereum = CryptoPrice.find_by(symbol: "ethereum")

        expect(bitcoin.price).to eq(60000)
        expect(ethereum.price).to eq(3000)

        expect(Rails.cache.read("price_bitcoin")).to eq(60000)
        expect(Rails.cache.read("price_ethereum")).to eq(3000)
      end
    end

    context "when API fails but cache exists" do
      it "uses cached value" do
        Rails.cache.write("price_bitcoin", 50000)

        allow(CryptoPriceFetcher).to receive(:fetch).and_raise(StandardError)

        described_class.perform_now

        # DB should NOT be overwritten
        expect(CryptoPrice.find_by(symbol: "bitcoin")).to be_nil
        expect(Rails.cache.read("price_bitcoin")).to eq(50000)
      end
    end

    context "when API fails and DB has old value" do
      it "keeps existing DB value" do
        CryptoPrice.create!(symbol: "bitcoin", price: 100)

        allow(CryptoPriceFetcher).to receive(:fetch).and_raise(StandardError)

        described_class.perform_now

        expect(CryptoPrice.find_by(symbol: "bitcoin").price).to eq(100)
      end
    end

    context "when API returns nil" do
      it "falls back without updating DB" do
        CryptoPrice.create!(symbol: "bitcoin", price: 200)

        allow(CryptoPriceFetcher).to receive(:fetch).and_return(nil)

        described_class.perform_now

        expect(CryptoPrice.find_by(symbol: "bitcoin").price).to eq(200)
      end
    end
  end
end
