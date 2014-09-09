require 'spec_helper'
require 'pp'
describe AccessTestController, type: :controller do
  it "should retun index" do
  	include TestAccess
  	expect(temp).to "adfa1"
  	get :index
  	response.should be_success
  end
	it "not signed in" do
		include TestAccess
		actions=[:index,:edit,:update]
		it_should_route_to('signin_path')
	end
end