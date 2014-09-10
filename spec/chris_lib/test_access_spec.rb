require 'spec_helper'
describe AccessTestController, type: :controller do
  def self.allow_index
    it "allows access to index" do
      get :index
      response.should be_success
    end
  end
  allow_index
	it "block access to rest" do
    binding.pry
	  include TestAccess
		actions=[:edit,:update]
	  it_should_route_to('signin_path',actions)
	end
end