# encoding: utf-8
require 'spec_helper'
require 'pp'
describe "ChrisMath Module" do
	include ChrisMath
	describe "combinatorial" do
		it{expect(combinatorial(50,49)).to eq 50}
		it{expect(combinatorial(31,31)).to eq 1}
		it{expect(combinatorial(8,4)).to eq 70}
	end
	describe "gaussian_rand" do
	describe "should have the right mean" do
			let(:mu){1}
			let(:sigma){2}
			let(:gaussian){(1..900).to_a.map!{gaussian_rand(mu,sigma)}}
			let(:tol){5.0*sigma/30}
			it{expect(gaussian.mean).to be_within(tol).of(mu)}
		end
	end
end
describe "Integer Extensions"  do
	describe :factorial do
		it{expect(5.factorial).to eq 120}
		it{expect(1.factorial).to eq 1}
		it{expect(0.factorial).to eq nil}
		it{expect((-5).factorial).to eq nil}
		it{expect{21.factorial}.to raise_error "Number too large"}
	end
end
describe "Array Extensions" do
	describe 'median' do
		it{ [].median.should be_nil }
		it{ [3].median.should eq 3 }
		it{ [3,4,5].median.should eq 4}
		it{ [2,4,5,6].median.should be_within(0.0001).of 4.5}
	end
	describe :mean do
		let(:uniform){(1..900).to_a.map!{rand()}}
		let(:mu){0.5}
		let(:sigma){0.2887}
		let(:tol){5*sigma/30}
		it{expect(uniform.mean).to be_within(tol).of(mu)}
		it{expect{[1].mean}.to raise_error "Length must be greater than 1"}
	end
	describe :var do
		let(:uniform){(1..900).to_a.map!{rand()}}
		let(:mu){0.5}
		let(:sigma){0.2887}
		let(:tol){(10*sigma**2/30)}
		it{expect(uniform.var).to be_within(tol).of(sigma**2)}
		it{expect{[1].var}.to raise_error "Length must be greater than 1"}
		it{ expect([1,2,3].var).to eq 1.0 }
	end
end