require 'spec_helper'
require 'pp'
describe "temp tests" do
  include TestAccess
  it{expect(temp).to eq 'temp here'}
end
describe AccessTestController, type: :controller do
  it "allows access to index" do
    get :index
    response.should be_success
  end
	it "block access to rest" do
	  include TestAccess
		actions=[:edit,:update]
	  it_should_route_to('signin_path',actions)
	end
end