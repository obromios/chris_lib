# encoding: utf-8
require 'spec_helper'
require 'pp'
include Math
require 'quaternion'

describe 'Quaternion extensions' do
	describe 'quaternion.round(n)' do
	  let!(:q) { Quaternion.new(1.003, -0.8345, 0.3456, 0.1345) }
	  it { expect(q.round(2)).to eq Quaternion.new(1.00, -0.83, 0.35, 0.13) }
	end

	describe 'Quaternion.identity' do
	  it { expect(Quaternion.identity).to eq Quaternion.new(1.0, 0.0, 0.0, 0.0) }
	end

	describe 'Quaternion.zero' do
	  it { expect(Quaternion.zero).to eq Quaternion.new(0.0, 0.0, 0.0, 0.0) }
	end

	describe 'Quaternion initialization with brackets' do
	  it { expect(Quaternion[1.0, 2.0, 3.0, 4.0]).to eq Quaternion.new(1.0, 2.0, 3.0, 4.0) }
	end
end

describe 'Float degree-radian conversions' do
  let!(:rad0) { PI / 6 }
  let!(:rad1) { 58.316 / 180.0 * PI }
  let!(:rad2) { 45 / 180.0 * PI }
  describe 'Float.to_deg(n)' do
    it { expect(rad0.to_deg).to be_within(1e-9).of  30.0 }
    it { expect(rad1.to_deg(2)).to eq 58.32 }
  end
  describe 'Float.to_rad(n)' do
    it { expect(30.0.to_rad).to be_within(1e-9).of rad0 }
    it { expect(30.0.to_rad(3)).to eq 0.524 }
  end

  describe 'Array degree-radian conversions' do
    describe 'Array.to_rad(n)' do
      let!(:ary) { [[rad0, rad1], [rad0, []]]  }
      it {expect(ary.to_deg.round(9)).to eq  [[30.0, 58.316], [30.0, []]] }
      it {expect(ary.to_deg(2)).to eq  [[30.0, 58.32], [30.0, []]] }
    end
    describe 'Array.to_rad(n)' do
      let!(:ary) { [[30.0, 45.0], [30.0, []]] }
      it { expect(ary.to_rad.round(9)).to eq [[rad0.round(9), rad2.round(9)], [rad0.round(9), []]] }
      it { expect(ary.to_rad.round(3)).to eq [[0.524, 0.785], [0.524, []]] }
    end
  end
end

describe 'Array.round(n)' do
  let!(:a) { [1.003, -0.8345, 0.3456, 0.1345] }
  it { expect(a.round(2)).to eq [1.00, -0.83, 0.35, 0.13] }
  it { expect(a.round).to eq [1, -1, 0, 0] }
  it { expect([1.1, [2.6, []]].round).to eq [1, [3, []]]}
end

describe 'Array.eround(n)' do
	let!(:a) { [1.2347e-8, 1.2344e-8, 0.35162e-4, 1.2347e-6] }
	it { expect(a.eround(3)).to eq [1.235e-8, 1.234e-8, 3.516e-5, 1.235e-6] }
	it { expect([1.235e-8, [0.35162e-4, []]].eround(3)).to eq [1.235e-8, [3.516e-5, []]]}
end

describe 'Pseudo Inverse' do
	describe 'pinv' do
		it 'is right inverse' do
			a_m = Matrix[[1.0, 2.0, 3.0], [7.0, 3.0, 5.0]]
			expect((a_m * a_m.pinv).round(8)).to eq Matrix.identity(2)
		end
	end
	describe 'pinv_right' do
		it 'is right inverse' do
			a_m = Matrix[[1.0, 2.0, 3.0], [7.0, 3.0, 5.0]]
			expect((a_m * a_m.pinv_right).round(8)).to eq Matrix.identity(2)
		end
	end
	describe 'pinv_left' do
		it 'is right inverse' do
			a_m = Matrix[[1.0, 2.0], [7.0, 3.0], [6.0, -3.0]]
			expect((a_m.pinv_left * a_m).round(8)).to eq Matrix.identity(2)
		end
	end
end
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
describe 'Float Extensions' do
	let(:a) { 1.0 / 3}
	let(:b) { 2.0 / 3}
  describe 'float.eround(n)' do
    it { expect(1.2347e-8.eround(3)).to eq 1.235e-8 }
    it { expect(1.2347e-8.eround(0)).to eq 1.0e-8 }
    it { expect(1.2347e-8.eround).to eq 1.0e-8 }
  end
	describe 'round_down' do
		it { expect(a.round_down).to eq 0.0  }
		it { expect(a.round_down(1)).to eq 0.3 }
		it {expect(a.round_down(4)).to eq 0.3333 }
		it { expect(b.round_down(1)).to eq 0.6 }
		it {expect(b.round_down(4)).to eq 0.6666 }
	end
	describe 'round4' do
		it {expect(a.round4).to eq 0.3333 }
		it {expect(b.round4).to eq 0.6667 }
	end
	describe 'round3' do
		it {expect(a.round3).to eq 0.333 }
		it {expect(b.round3).to eq 0.667 }
	end
	describe 'round2' do
		it {expect(a.round2).to eq 0.33 }
		it {expect(b.round2).to eq 0.67 }
	end
	describe 'round1' do
		it {expect(a.round1).to eq 0.3 }
		it {expect(b.round1).to eq 0.7 }
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
		it{ expect([].median).to be_nil }
		it{ expect([3].median).to eq 3 }
		it{ expect([3,4,5].median).to eq 4}
		it{ expect([2,4,5,6].median).to be_within(0.0001).of 4.5}
	end
	describe 'mean' do
		let(:uniform){(1..900).to_a.map!{rand()}}
		let(:mu){0.5}
		let(:sigma){0.2887}
		let(:tol){5*sigma/30}
		it{expect(uniform.mean).to be_within(tol).of(mu)}
		it{expect{[].mean}.to raise_error RuntimeError, "Length must be greater than 0."}
	end
	describe 'var' do
		let(:uniform){(1..900).to_a.map!{rand()}}
		let(:mu){0.5}
		let(:sigma){0.2887}
		let(:tol){(10*sigma**2/30)}
		it{expect(uniform.var).to be_within(tol).of(sigma**2)}
		it{expect{[1].var}.to raise_error "Length must be greater than 1"}
		it{ expect([1,2,3].var).to eq 1.0 }
	end
	describe 'Check agains R' do
		let(:ary) { [7.08195525827783, 10.831582068121444, 9.288611270369554, 9.054684238411918, 12.268532229606647] }
		it 'mean agrees with R' do
			expect(ary.mean.round(6)).to eq 9.705073
		end
		it 'var agrees with R' do
			expect(ary.var.round(6)).to eq 3.829385
		end
		it 'std agrees with R' do
			expect(ary.std.round(6)).to eq 1.956881
		end
		it 'std_err agrees with R' do
			# R used var(x)/length(x)
			expect(ary.std_err.round(7)). to eq 0.8751439
		end
	end
	describe 'deep_dup' do
		it 'makes a independent copy' do
			ary1 = [[[1,3], [1,4]], [3, 5]]
			ary2 = ary1.deep_dup
			ary2[0][0][1] = 5
			expect(ary1).not_to eq ary2
		end
	end
end