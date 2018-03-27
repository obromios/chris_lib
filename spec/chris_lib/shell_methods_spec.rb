describe ShellMethods  do
	describe :time_hash do
		include ShellMethods
		it "should give right hash" do
			allow(Time).to receive(:now).and_return DateTime.new(2014,8,30,13,11)
			expect(time_hash).to eq '3082014-1311'
		end
	end
end

