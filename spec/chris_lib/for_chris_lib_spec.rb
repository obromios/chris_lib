require 'spec_helper'

RSpec.describe ForChrisLib do
  include ForChrisLib
  include ChrisMath

  let(:test_a) { [1,1,1,1,1,1,-1,-1,-1,-1,0,0,0,2,2,2,2,2,4,4] }

  describe '#outcome' do
    it 'returns probability mass for unique smallest value' do
      expect(outcome([2, 1, 4])).to eq([0, 1, 0])
    end

    it 'splits probability between tied minima' do
      expect(outcome([2, 1, 1])).to eq([0, 0.5, 0.5])
    end

    it 'handles all equal values' do
      expect(outcome([1, 1, 1])).to eq([1.0 / 3, 1.0 / 3, 1.0 / 3])
    end

    it 'handles negative winners' do
      expect(outcome([-1, 1, 1])).to eq([1, 0, 0])
    end
  end

  describe 'padding and unpadding sub-arrays' do
    describe '#pad_sub_arrays!' do
      it 'extends sub-arrays to the same length' do
        ary = [[1,2,3], [1,2], [], [1], [5, 6, 7]].pad_sub_arrays!
        expect(ary.all? { |a| a.length == 3 }).to be true
      end
    end

    describe '#unpad_sub_arrays!' do
      it 'restores padded arrays to original length' do
        original = [[1,2,3], [1,2], [], [1], [5, 6, 7]]
        copy = original.deep_dup.pad_sub_arrays!.unpad_sub_arrays!
        expect(copy).to eq(original)
      end
    end
  end

  describe ForChrisLib::ChiSquaredStdErr do
    let(:n_games) { 4000 }
    let(:mus) { [0, 10, 20] }
    let(:std) { [1, 4, 9] }
    let(:scores) do
      (0..2).map do |i|
        gaussian_array(n_games).map { |e| e * std[i] + mus[i] }
      end
    end
    let(:means) { scores.map(&:mean) }
    let(:std_errs) { scores.map(&:std_err) }

    context 'when the confidence level is invalid' do
      it 'raises ForChrisLibError' do
        expect do
          described_class.new(means, std_errs, mus, confidence_level: 0.0)
        end.to raise_error(ForChrisLibError)
      end
    end

    context 'when the null hypothesis holds' do
      before do
        allow(ForChrisLib::PChiSquared).to receive(:new).and_return(double(call: 0.9))
      end

      it 'passes at the requested confidence level' do
        result = described_class.new(means, std_errs, mus).call
        expect(result.pass?).to be true
        expect(result.p).to be > 0.05
        expect(result.chi2).to be > 0
      end
    end

    context 'when the null hypothesis is false' do
      let(:mus_false) { [0, 10.6, 20] }

      before do
        allow(ForChrisLib::PChiSquared).to receive(:new).and_return(double(call: 0.01))
      end

      it 'flags the failure' do
        result = described_class.new(means, std_errs, mus_false).call
        expect(result.pass?).to be false
      end
    end
  end

  describe ForChrisLib::PChiSquared do
    it 'approximates chi-squared survival probabilities' do
      calculator = described_class.new
      expect(calculator.call(1, 1.642).round(2)).to eq(0.20)
      expect(calculator.call(2, 4.605).round(2)).to eq(0.10)
      expect(calculator.call(12, 3.074).round(3)).to eq(0.995)
    end

    it 'delegates probability calculation to injected calculator' do
      calculator = ->(_dof, _nu) { 0.42 }
      expect(described_class.new(calculator: calculator).call(2, 3)).to eq(0.42)
    end
  end

  describe 'ChiSquared survival function' do
    let(:chi) { ForChrisLib::PChiSquared.new }

    it { expect(chi.call(1, 1.642).round(2)).to eq(0.20) }
    it { expect(chi.call(2, 4.605).round(2)).to eq(0.10) }
    it { expect(chi.call(34, 48.602).round(2)).to eq(0.05) }
    it { expect(chi.call(6, 8.56).round(2)).to eq(0.20) }
    it { expect(chi.call(12, 3.074).round(3)).to eq(0.995) }
  end

  describe ForChrisLib::Framed do
    let(:frame) { described_class.new(%w[id score], [[1, 5], [2, 3]]) }

    it 'accepts matching header and rows' do
      expect(frame.header).to eq(%w[id score])
      expect(frame.rows[1]).to eq([2, 3])
    end

    it 'requires array headers' do
      expect do
        described_class.new('string', [[1]])
      end.to raise_error('header must be an array')
    end

    it 'requires array rows' do
      expect do
        described_class.new(%w[a b], 1)
      end.to raise_error('rows must be an array')
    end

    it 'validates row sizes' do
      expect do
        described_class.new(%w[id score], [[1, 5], [2, 3, 1]])
      end.to raise_error('row 1 size not equal to header size')
    end
  end

  describe '#fvu' do
    it 'computes fraction of variance unexplained' do
      y_hat = [1, 2, 3]
      y = [1, 3, 5]
      expect(fvu(y_hat_a: y_hat, y_a: y).round(3)).to eq(0.625)
    end
  end

  describe '#bias_estimate_by_min' do
    class StubStore
      attr_reader :histogram, :min, :max

      def initialize(bins, min:, max:)
        @histogram = [bins]
        @min = min
        @max = max
      end
    end

    class StubWinLoss
      def win_loss_graph(_results, pdf:)
        pdf
      end

      def win_loss_stats(_graph)
        [50.0, nil]
      end
    end

    class StubMinimizer
      attr_accessor :expected
      attr_reader :x_minimum

      def initialize(min, max, fn)
        @min = min
        @max = max
        @fn = fn
        @x_minimum = -3.7
      end

      def iterate
        @fn.call((@min + @max) / 2.0)
      end
    end

    it 'returns the minimizer offset when dependencies are provided' do
      store = StubStore.new([10, 5, 1], min: -1.0, max: 1.0)
      result = bias_estimate_by_min(
        store,
        win_loss_calculator: StubWinLoss.new,
        minimizer_class: StubMinimizer
      )
      expect(result).to eq(3.7)
    end

    it 'raises when WinLoss dependency is missing' do
      store = StubStore.new([1, 2, 3], min: -1.0, max: 1.0)
      expect do
        bias_estimate_by_min(store, minimizer_class: StubMinimizer)
      end.to raise_error(ForChrisLibError)
    end
  end

  describe '#pdf_from_hist' do
    it 'converts histogram counts into probability mass' do
      expect(pdf_from_hist([1, 1, 2], min: -1)).to eq({ -1 => 0.25, 0 => 0.25, 1 => 0.5 })
    end
  end

  describe '#summed_bins_histogram' do
    let(:points) { [[-0.9999, +1], [-0.2, +1], [1.1, -1], [1.9, +1], [1.8, -1],[3.9999, +1]] }

    it 'bins points by x coordinate' do
      result = summed_bins_histogram(points, 5).transpose
      expect(result[0].map { |v| v.round(3) }).to eq([-0.5, 0.5, 1.5, 2.5, 3.5])
      expect(result[1]).to eq([2, 0, -1, 0, 1])
      expect(result[2]).to eq([2, 0, 3, 0, 1])
    end
  end

  describe '#inc_m2_var' do
    it 'matches batch variance' do
      data = [1, 2, 3]
      acc = [0, 0, 0]
      data.each { |value| acc = inc_m2_var(value, acc) }
      expect(acc[0]).to eq(data.mean)
      expect((acc[1] / (data.size - 1))).to eq(data.var)
      expect(acc[2]).to eq(data.size)
    end
  end

  describe '#acf' do
    it 'computes autocorrelation at lag' do
      data = [1, 2, 1, 2, 1, 2]
      expect(acf(data, 2).round(3)).to eq(0.833)
    end

    it 'validates lag size' do
      expect { acf([1, 2], 5) }.to raise_error('Lag is too large, n = 2, lag = 5')
    end
  end

  describe 'Weighted statistics' do
    let(:bins) { [1, 2, 3] }

    it 'computes weighted mean' do
      expect(weighted_mean(bins)).to eq(8.0 / 6)
    end

    it 'computes weighted standard deviation' do
      mu = weighted_mean(bins)
      expect(weighted_sd(bins, mu).round(4)).to eq(0.8165)
    end

    it 'computes weighted skewness' do
      mu = weighted_mean(bins)
      expect(weighted_skewness(bins, mu).round(4)).to eq(-0.4763)
    end
  end

  describe '#pdf_from_bins/#cdf_from_bins' do
    let(:bins) { [1, 2, 3] }

    it 'produces pdf and cdf' do
      pdf = pdf_from_bins(bins)
      cdf = cdf_from_bins(bins)
      expect(pdf.keys).to eq([0, 1, 2])
      expect(pdf.values.map { |v| v.round(2) }).to eq([0.17, 0.33, 0.5])
      expect(cdf.values.map { |v| v.round(2) }).to eq([0.17, 0.5, 1.0])
    end
  end

  describe '#normal_pdf' do
    it 'evaluates standard normal density' do
      expect(normal_pdf(0).round(4)).to eq(0.3989)
    end
  end

  describe '#normal_cdf' do
    it 'approximates standard normal CDF' do
      expect(normal_cdf(0)).to eq(0.5)
    end
  end

  describe '#simpson' do
    it 'integrates a parabola exactly with sufficient intervals' do
      expect(simpson(:parabola, -2, 3, 100, a: 3).round(2)).to eq(62.5)
    end

    it 'requires an even number of intervals' do
      expect { simpson(:parabola, 0, 1, 3) }.to raise_error('n must be even (received n=3)')
    end
  end

  describe '#inverse_transform_rand' do
    it 'returns boundary values for out-of-range samples' do
      allow(self).to receive(:rand).and_return(-1)
      cdf = [[0, 0], [1, 0.4], [2, 1.0]]
      expect(inverse_transform_rand(cdf)).to eq(0)
    end
  end

  describe '#arbitrary_cdf_a' do
    it 'returns sampled CDF pairs' do
      result = arbitrary_cdf_a(:normal_pdf, { mu: 0, sigma: 1 }, n_samples: 3)
      expect(result.length).to eq(3)
      expect(result.first.length).to eq(2)
    end
  end

  describe '#delimit' do
    it 'adds thousands separators' do
      expect(delimit(1234567)).to eq('1,234,567')
    end
  end

  describe 'String#string_between_markers' do
    it 'extracts substring between markers' do
      expect('foo [bar] baz'.string_between_markers('[', ']')).to eq('bar')
    end
  end

  describe 'Integer#sigmoid and Float#sigmoid' do
    it 'maps numbers to sign buckets' do
      expect(5.sigmoid).to eq(1)
      expect((-3.2).sigmoid).to eq(-1)
      expect(0.0.sigmoid).to eq(0)
    end
  end

  describe 'Array extensions' do
    let(:values) { [3, 4, 5, 5, 2, 1] }

    describe '#bin_shift' do
      it 'preserves sum for positive shift' do
        expect(values.bin_shift(2.1).sum).to be_within(0.0001).of(values.sum)
      end

      it 'adjusts bins for negative shift' do
        result = values.bin_shift(-2)
        expect(result).to eq([12, 5, 2, 1, 0, 0])
      end
    end

    describe '#bin_int_shift' do
      it 'wraps integer shifts right and left' do
        expect(values.bin_int_shift(2)).to eq([0, 0, 3, 4, 5, 8])
        expect(values.bin_int_shift(-2)).to eq([12, 5, 2, 1, 0, 0])
      end
    end

    describe '#pdf/#cdf' do
      it 'computes discrete distributions' do
        pdf = test_a.pdf
        cdf = test_a.cdf
        expect(pdf.keys).to eq([-1, 0, 1, 2, 4])
        expect(pdf.values).to eq([0.2, 0.15, 0.3, 0.25, 0.1])
        expect(cdf.values.map { |v| v.round(2) }).to eq([0.2, 0.35, 0.65, 0.9, 1.0])
      end
    end
  end

  describe 'Hash extensions' do
    it 'builds a CDF from a PDF hash' do
      pdf = test_a.pdf
      expect(pdf.cdf_from_pdf.values.map { |v| v.round(2) }).to eq([0.2, 0.35, 0.65, 0.9, 1.0])
    end

    it 'builds gender histograms in score ranges' do
      counts = { '-1.2' => 3, '0.0' => 5, '40.3' => 2 }
      expect(counts.male_ga_hist[-1]).to eq(3)
      expect(counts.female_male_ga_hist[40]).to eq(2)
    end
  end
end
