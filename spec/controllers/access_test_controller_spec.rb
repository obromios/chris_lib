require 'spec_helper'

describe AccessTestController do

  describe "block access when needed" do
    include TestAccess
    actions=[:edit,:update]
    it_should_route_to('access_test_index_path',actions)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end
