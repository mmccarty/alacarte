require 'spec_helper'

describe LoginController do
  describe "GET #login" do
    it "responds successfully with an HTTP 200 status code" do
      get :login
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end
end
