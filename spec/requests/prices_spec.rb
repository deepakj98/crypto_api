require 'rails_helper'

RSpec.describe "Prices", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/prices/show"
      expect(response).to have_http_status(:success)
    end
  end

end
