module TestAccess
	# A rspec macro to test access security for controllers, call <tt>it_should_route_to(path,actions)</tt>
  # where path is a string of the form <tt>url_path</tt> and actions is a hash of symbols
  # that represent actions to be protected. 
  # An example call is <tt>it_should_route_to('login_path',:edit,:update)</tt>.  The call is
  # made in a describe or context block with a preceding <tt>require TestAccess</tt>.
  #
	module ExampleMethods
	end
	module ExampleGroupMethods
	  def it_should_route_to(path,actions)
			actions.each do |a|
				it "should deny access to #{a}" do
	  			get a, id: 1
	  			response.should redirect_to send(path)
	  		end
			end
		end
  end
  def self.included(receiver)
    receiver.extend         ExampleGroupMethods
    receiver.send :include, ExampleMethods
  end
end