RSpec.describe CryptoPriceFetcher do
  it "returns nil on exception" do
    allow(described_class).to receive(:get).and_raise(StandardError)

    expect(described_class.fetch("bitcoin")).to be_nil
  end
end
