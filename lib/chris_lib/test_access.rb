module TestAccess
	module ExampleMethods
	end
	module ExampleGroupMethods
	  def self.it_should_route_to(path,actions)
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