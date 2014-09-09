# encoding: utf-8
require 'spec_helper'
describe ChrisMath  do
	describe "should calculate factorial correctly" do
		it{expect(5.factorial).to eq 120}
		it{expect(1.factorial).to eq 1}
		it{expect(0.factorial).to eq nil}
		it{expect((-5).factorial).to eq nil}
		it{expect{21.factorial}.to raise_error "Number too large"}
	end
end