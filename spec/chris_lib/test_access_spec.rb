require 'spec_helper'
require 'pp'
describe AccessTestController, type: :controller do
  pending "should retun index" do
  	include TestAccess
  	expect(TestAccess.temp).to eq "adfa1"
  	get :index
  	response.should be_success
  end
	pending "not signed in" do
		include TestAccess
		actions=[:index,:edit,:update]
		TestAccess::ExampleGroupMethods.it_should_route_to('signin_path',actions)
	end
end