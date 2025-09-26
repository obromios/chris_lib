describe ShellMethods  do
	describe :time_hash do
		include ShellMethods
		it "should give right hash" do
			allow(Time).to receive(:now).and_return DateTime.new(2014,8,30,13,11)
			expect(time_hash).to eq '3082014-1311'
		end
	end

	describe '#osx_send_mail' do
		include ShellMethods
		it 'warns when subject is blank' do
			expect { osx_send_mail(' ') }.to output(/subject/).to_stderr
		end
	end

	describe '#r_runner' do
		include ShellMethods
		it 'warns when script is missing' do
			allow(File).to receive(:exist?).and_return(false)
			expect { r_runner('/missing/script.R', 'arg') }.to output(/does not exist/).to_stderr
		end
	end
end
