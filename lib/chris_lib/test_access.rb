module TestAccess
	# An RSpec helper that verifies protected controller actions redirect to a login path.
  #
  # Include the module and call {.it_should_route_to} with the protected actions:
  #
  #   it_should_route_to('login_path', [:edit, :update])
  #
  # Optionally provide a `flash_message` expectation.
	# @!visibility private
	module ExampleMethods
	end

	# @!visibility private
	module ExampleGroupMethods
	  # Define a set of expectations that each action redirects to the provided path.
	  # @param path [String] helper method name that resolves to the desired redirect URL
	  # @param actions [Array<Symbol>]
	  # @param flash_message [String, nil] text to match in `flash[:error]`
	  def it_should_route_to(path,actions,flash_message=nil)
			actions.each do |a|
				it "should deny access to #{a}" do
          if Rails::VERSION::MAJOR >= 5
            get a.to_sym, params: { id: 1}
          else
            get a.to_sym,  id: 1
          end
	  			expect(response).to redirect_to send(path)
	  		end
	  		if flash_message.present?
	  			it "should have correct flash message for #{a}" do
	  				if Rails::VERSION::MAJOR >= 5
              get a.to_sym, params: { id: 1}
            else
              get a.to_sym,  id: 1
            end
	  				expect(flash[:error]).to include flash_message
	  			end
	  		end
			end
		end
  end
  # @!visibility private
  def self.included(receiver)
    receiver.extend         ExampleGroupMethods
    receiver.send :include, ExampleMethods
  end
end
