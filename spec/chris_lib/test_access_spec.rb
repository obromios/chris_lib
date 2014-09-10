require 'spec_helper'
describe AccessTestController, type: :controller do
  it "allows access to index" do
    get :index
    response.should be_success
  end
	it "block access to rest" do
    pending "need to ask for help"
	  include TestAccess
		actions=[:edit,:update]
	  it_should_route_to('signin_path',actions)
	end
end