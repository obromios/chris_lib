# encoding: utf-8
require 'spec_helper'
describe ChrisMath  do
	describe :factorial do
		it{expect(5.factorial).to eq 120}
		it{expect(1.factorial).to eq 1}
		it{expect(0.factorial).to eq nil}
		it{expect((-5).factorial).to eq nil}
		it{expect{21.factorial}.to raise_error "Number too large"}
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
		let(:tol){(5*sigma/30)**2}
		it{expect(uniform.var).to be_within(tol).of(sigma**2)}
		it{expect{[1].var}.to raise_error "Length must be greater than 1"}
	end
end