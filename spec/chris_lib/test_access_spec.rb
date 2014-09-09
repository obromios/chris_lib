require 'spec_helper'
require 'pp'
describe AccessTestController, type: :controller do
  it "should retun index" do
  	get :index
  end
	it "not signed in" do
		include TestAccess
		actions=[:index,:edit,:update]
		it_should_route_to('signin_path')
	end
end