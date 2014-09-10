require 'spec_helper'
require 'pp'
describe "temp tests" do
  include TestAccess
  it{expect(temp).to eq 'temp here'}
end
describe AccessTestController, type: :controller do
	pending "not signed in" do
		include TestAccess
		actions=[:index,:edit,:update]
	  it_should_route_to('signin_path',actions)
	end
end