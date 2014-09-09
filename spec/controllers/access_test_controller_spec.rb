require 'spec_helper'

describe AccessTestController do

  it "not signed in" do
    include TestAccess
    actions=[:index,:edit,:update]
    it_should_route_to('signin_path')
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "returns http success" do
      get 'update'
      response.should be_success
    end
  end

end
