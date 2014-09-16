describe ShellMethods  do
	describe :time_hash do
		include ShellMethods
		it "should give right hash" do
			Time.stub(:now).and_return DateTime.new(2014,8,30,13,11)
			time_hash.should eq '3082014-1311'
		end
	end
end

