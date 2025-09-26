require 'ostruct'

ForChrisLibError = Class.new(StandardError) unless defined?(ForChrisLibError)

# Aggregated analytical helpers formerly housed in golf_lab.
module ForChrisLib
  include ChrisLib
  include Math

  # Compute probabilities of winning given an array of scores.
  # @param results [Array<Numeric>]
  # @return [Array<Float>] probability mass for each input
  def outcome(results)
    s_min = results.min
    flags = results.map { |value| value == s_min ? 1 : 0 }
    total = flags.sum.nonzero? || 1
    flags.map { |value| value.to_f / total }
  end

  # Evaluate a chi-squared goodness-of-fit test from summary statistics.
  class ChiSquaredStdErr
    # @param means [Array<Numeric>]
    # @param std_errs [Array<Numeric>] standard errors of the means
    # @param mus [Array<Numeric>] hypothesised means
    # @param confidence_level [Float]
    def initialize(means, std_errs, mus, confidence_level: 0.95)
      @means = means
      @std_errs = std_errs
      @mus = mus
      @confidence_level = confidence_level
      check_confidence_level
      @threshold = 1 - confidence_level
    end

    # @return [OpenStruct] containing :pass?, :p, and :chi2
    def call
      chi2 = means.zip(mus, std_errs).map { |m, mu, se| (m.to_f - mu)**2 / se**2 }.sum
      p_value = PChiSquared.new.call(means.size, chi2)
      OpenStruct.new(pass?: p_value > threshold, p: p_value, chi2: chi2)
    end

    private

    attr_reader :means, :std_errs, :mus, :threshold, :confidence_level

    def check_confidence_level
      return if confidence_level.positive? && confidence_level < 1

      msg = "Confidence level is #{confidence_level} must be between 0 and 1"
      raise ForChrisLibError, msg
    end
  end

  # Wrapper around chi-squared tail probability helpers.
  class PChiSquared
    # @param calculator [#call] dependency used to evaluate the tail probability
    def initialize(calculator: nil)
      @calculator = calculator
    end

    # @param dof [Integer] degrees of freedom
    # @param nu [Numeric] chi-squared statistic
    # @return [Float] upper-tail probability
    def call(dof, nu)
      if calculator
        return calculator.call(dof, nu)
      end

      # Use the complemented incomplete gamma to evaluate the survival function.
      s = dof.to_f / 2.0
      x = nu.to_f / 2.0
      regularized_gamma_q(s, x)
    end

    private

    attr_reader :calculator

    def regularized_gamma_q(s, x)
      # Borrowed from Numerical Recipes, see https://numerical.recipes
      if x < s + 1.0
        1.0 - regularized_gamma_p_series(s, x)
      else
        regularized_gamma_q_continued_fraction(s, x)
      end
    end

    def regularized_gamma_p_series(s, x)
      return 0.0 if x <= 0.0

      gln = Math.lgamma(s).first
      sum = 1.0 / s
      term = sum
      n = 1
      loop do
        term *= x / (s + n)
        sum += term
        break if term.abs < sum.abs * 1e-12
        n += 1
        break if n > 10_000
      end
      Math.exp(-x + s * Math.log(x) - gln) * sum
    end

    def regularized_gamma_q_continued_fraction(s, x)
      gln = Math.lgamma(s).first
      b = x + 1.0 - s
      c = 1.0 / 1e-30
      d = 1.0 / b
      h = d
      n = 1
      loop do
        an = -n * (n - s)
        b += 2.0
        d = an * d + b
        d = 1e-30 if d.abs < 1e-30
        c = b + an / c
        c = 1e-30 if c.abs < 1e-30
        d = 1.0 / d
        delta = d * c
        h *= delta
        break if (delta - 1.0).abs < 1e-12
        n += 1
        break if n > 10_000
      end
      Math.exp(-x + s * Math.log(x) - gln) * h
    end
  end

  # Lightweight helper that keeps table data and headers together.
  class Framed
    attr_reader :hsh

    # @param header [Array<String>]
    # @param rows [Array<Array>]
    def initialize(header, rows)
      raise 'header must be an array' unless header.is_a?(Array)
      raise 'rows must be an array' unless rows.is_a?(Array)

      @hsh = { header: header, rows: rows }

      rows.each_with_index do |row, index|
        next if row.size == header.size

        raise "row #{index} size not equal to header size"
      end
    end

    # @return [Array<String>]
    def header
      hsh[:header]
    end

    # @return [Array<Array>]
    def rows
      hsh[:rows]
    end
  end

  # @return [String] sentinel used in legacy tests
  def test
    'here'
  end

  # Fraction of variance unexplained given predictions and observations.
  # @param y_hat_a [Array<Numeric>]
  # @param y_a [Array<Numeric>]
  # @return [Float]
  def fvu(y_hat_a:, y_a:)
    raise 'TGM - y_hat_a must be greater than 1' if y_hat_a.size < 2
    raise 'TGM - y_hat_a.size != y_a.size' unless y_hat_a.size == y_a.size

    ss_err = y_hat_a.zip(y_a).sum { |yh, y| (y - yh)**2 }.to_f
    y_mu = y_a.mean
    ss_tot = y_a.sum { |y| (y - y_mu)**2 }.to_f
    ss_err / ss_tot
  end

  # Estimate bias in a histogram by minimising win/loss difference between players.
  # @param store [#histogram, #min, #max]
  # @param win_loss_calculator [#win_loss_graph,#win_loss_stats]
  # @param minimizer_class [Class]
  # @return [Float]
  def bias_estimate_by_min(store, win_loss_calculator: nil, minimizer_class: nil)
    win_loss = win_loss_calculator || default_win_loss_calculator

    fn = lambda do |x|
      bins = store.histogram[0].bin_shift(x)
      pdf = pdf_from_hist(bins, min: store.min)
      wl_graph = win_loss.win_loss_graph(nil, pdf: pdf)
      outcome = win_loss.win_loss_stats(wl_graph)[0]
      (outcome - 50.0)**2
    end

    minimizer = (minimizer_class || default_minimizer_class).new(store.min, store.max, fn)
    minimizer.expected = 0.0 if minimizer.respond_to?(:expected=)
    minimizer.iterate
    -minimizer.x_minimum
  end

  # Convert integer bin counts into a probability mass function.
  # @param bins [Array<Integer>]
  # @param min [Integer]
  # @return [Hash{Integer=>Float}]
  def pdf_from_hist(bins, min: 0)
    total = bins.sum.nonzero? || 1
    bins.map.with_index { |b, i| [i + min, b.to_f / total] }.to_h
  end

  # Sum y values into equi-width x bins.
  # @param x_y [Array<Array(Float, Float)>]
  # @param n_bins [Integer]
  # @return [Array<Array<Float, Numeric, Integer>>]
  def summed_bins_histogram(x_y, n_bins)
    x_a = x_y.transpose[0]
    y_a = x_y.transpose[1]
    min = x_a.min
    max = x_a.max
    bin_sums = Array.new(n_bins, 0)
    bins = Array.new(n_bins, 0)
    delta = (max - min).to_f / n_bins

    x_a.each_with_index do |x, i|
      j = [((x - min).to_f / delta), n_bins - 1].min
      bin_sums[j] += y_a[i]
      bins[j] += 1
    end

    bin_sums.each_with_index.map do |bin_sum, i|
      [min + delta / 2 + i * delta, bin_sum, bins[i]]
    end
  end

  # Incremental mean and second central moment accumulator.
  # @param x [Numeric]
  # @param accumulator [Array<Numeric>] [mean, m2, n]
  # @return [Array<Numeric>]
  def inc_m2_var(x, accumulator)
    mean, m2, n = accumulator
    n += 1
    delta = x - mean
    mean += delta.to_f / n
    delta2 = x - mean
    m2 += delta * delta2
    [mean, m2, n]
  end

  # Autocorrelation at a specific lag.
  # @param x_a [Array<Numeric>]
  # @param lag [Integer]
  # @return [Float]
  def acf(x_a, lag)
    n = x_a.size
    raise "Lag is too large, n = #{n}, lag = #{lag}" if n < lag + 1

    mu = x_a.mean
    total = 0
    x_a[0..-(lag + 1)].each_with_index do |x, i|
      total += (x - mu) * (x_a[i + lag] - mu)
    end
    total.to_f / (n - lag) / x_a.var
  end

  # Weighted mean based on histogram bins.
  # @param bins [Array<Numeric>]
  # @param min [Numeric]
  # @param delta [Numeric]
  # @return [Float, nil]
  def weighted_mean(bins, min = 0, delta = 1)
    return nil if bins.sum.zero?

    sum = bins.each_with_index.sum do |w, i|
      (min * delta + i * delta) * w
    end
    sum.to_f / bins.sum
  end

  # Weighted sample standard deviation.
  # @param bins [Array<Numeric>]
  # @param mu [Numeric]
  # @param min [Numeric]
  # @param delta [Numeric]
  # @return [Float, nil]
  def weighted_sd(bins, mu, min = 0, delta = 1)
    return nil if bins.sum < 2

    sum = bins.each_with_index.sum do |w, i|
      v = min * delta + i * delta
      (v - mu)**2 * w
    end
    sqrt(sum / (bins.sum - 1))
  end

  # Weighted skewness using the third central moment.
  # @param bins [Array<Numeric>]
  # @param mu [Numeric]
  # @param min [Numeric]
  # @param delta [Numeric]
  # @return [Float, nil]
  def weighted_skewness(bins, mu, min = 0, delta = 1)
    n = bins.sum
    return nil if n < 2

    third_moment = weighted_m_3(bins, mu, min, delta)
    sd = weighted_sd(bins, mu, min, delta)
    third_moment / sd**3
  end

  # Weighted third central moment.
  # @return [Float, nil]
  def weighted_m_3(bins, mu, min = 0, delta = 1)
    n = bins.sum
    return if n < 1

    sum = bins.each_with_index.sum do |w, i|
      v = min * delta + i * delta
      (v - mu)**3 * w
    end
    sum / n
  end

  # Weighted fourth central moment.
  # @return [Float, nil]
  def weighted_m_4(bins, mu, min = 0, delta = 1)
    n = bins.sum
    return if n < 1

    sum = bins.each_with_index.sum do |w, i|
      v = min * delta + i * delta
      (v - mu)**4 * w
    end
    sum / n
  end

  # Probability mass function derived from histogram bins.
  # @return [Hash{Numeric=>Float}]
  def pdf_from_bins(bins, min = 0, delta = 1)
    total = bins.sum.nonzero? || 1
    bins.each_with_index.map { |bin, i| [min * delta + i * delta, bin.to_f / total] }.to_h
  end

  # Cumulative distribution function derived from histogram bins.
  # @return [Hash{Numeric=>Float}]
  def cdf_from_bins(bins, min = 0, delta = 1)
    pdf_from_bins(bins, min, delta).cdf_from_pdf
  end

  # Standard normal (or shifted) probability density function.
  # @param x [Numeric]
  # @param options [Hash] :mu and :sigma keys
  # @return [Float]
  def normal_pdf(x, options = {})
    params = { mu: 0, sigma: 1 }.merge(options)
    mu = params[:mu]
    sigma = params[:sigma]
    E**(-(x - mu)**2 / 2 / sigma**2) / sqrt(2 * PI) / sigma
  end

  # Standard normal cumulative distribution function.
  # @param x [Numeric]
  # @return [Float]
  def normal_cdf(x)
    0.5 * (1 + erf(x / sqrt(2)))
  end

  # Skew-normal probability density function using alpha parameterisation.
  # @param x [Numeric]
  # @param options [Hash]
  # @return [Float]
  def skew_normal_pdf(x, options = { alpha: 0 })
    params = { alpha: 0 }.merge(options)
    alpha = params[:alpha]
    2 * normal_pdf(x) * normal_cdf(alpha * x)
  end

  # Placeholder skew-normal sampler backed by numerical integration.
  # @return [Float]
  def skew_normal_rand(_x, options = { alpha: 0 })
    cdf_calc(rand, :normal_pdf, { mu: 2, sigma: 4 }, n_pts: 100, sigma: 4, mu: 2)
  end

  # Evaluate quadratic polynomial with configurable coefficients.
  # @param x [Numeric]
  # @param options [Hash]
  # @return [Numeric]
  def parabola(x, options = {})
    params = { a: 2, b: 3, c: 4 }.merge(options)
    a = params[:a]
    b = params[:b]
    c = params[:c]
    a * x**2 + b * x + c
  end

  # Simpson's rule numerical integration for functions referenced by symbol.
  # @param func [Symbol]
  # @param a [Numeric]
  # @param b [Numeric]
  # @param n [Integer] even number of intervals
  # @param options [Hash]
  # @return [Float]
  def simpson(func, a, b, n, options = {})
    raise "n must be even (received n=#{n})" unless n.even?

    h = (b - a).to_f / n
    s = send(func, a, options) + send(func, b, options)
    (1..n).step(2) { |i| s += 4 * send(func, a + i * h, options) }
    (2..n - 1).step(2) { |i| s += 2 * send(func, a + i * h, options) }
    s * h / 3
  end

  # Generate random samples from the skew-normal distribution using inverse transform.
  # @param n [Integer]
  # @param alpha [Numeric]
  # @return [Array<Float>]
  def skew_normal_rand_a(n, alpha)
    cdf_a = arbitrary_cdf_a(:skew_normal_pdf, { alpha: alpha })
    (1..n).map { inverse_transform_rand(cdf_a) }
  end

  # Inverse transform sampling based on a discretised CDF array.
  # @param cdf_a [Array<Array(Float, Float)>]
  # @return [Float]
  def inverse_transform_rand(cdf_a)
    p_a = cdf_a.map { |pair| pair[1] }
    x_a = cdf_a.map { |pair| pair[0] }
    p_min = p_a.first
    p_max = p_a.last
    p_rand = rand
    return p_min if p_rand <= p_min
    return p_max if p_rand >= p_max

    i = p_a.find_index { |p| p > p_rand }
    interpolate(p_rand, p_a[i - 1], p_a[i], x_a[i - 1], x_a[i])
  end

  # Linear interpolation between two points.
  # @return [Float]
  def interpolate(x, x_L, x_U, y_L, y_U)
    m = (y_U - y_L) / (x_U - x_L)
    (x - x_L) * m + y_L
  end

  # Sample a cumulative distribution function for plotting.
  # @param func [Symbol]
  # @param options [Hash]
  # @param n_samples [Integer]
  # @return [Array<Array<Float, Float>>]
  def arbitrary_cdf_a(func, options, n_samples: 100)
    width = 8.0
    h = width / (n_samples - 1)
    x_a = (1..n_samples).map { |i| -width / 2 + (i - 1) * h }
    x_a.map do |x|
      [x, cdf_calc(x, func, options)]
    end
  end

  # Discretised skew-normal cumulative distribution function.
  # @return [Array<Array<Float, Float>>]
  def skew_normal_cdf_a(options, n_samples: 100)
    width = 8.0
    h = width / (n_samples - 1)
    x_a = (1..n_samples).map { |i| -width / 2 + (i - 1) * h }
    x_a.map do |x|
      [x, cdf_calc(x, :skew_normal_pdf, options)]
    end
  end

  # Numerical integration helper for CDFs.
  # @param x [Numeric]
  # @param func [Symbol]
  # @param options [Hash]
  # @param mu [Numeric]
  # @param sigma [Numeric]
  # @param n_pts [Integer]
  # @return [Float]
  def cdf_calc(x, func, options, mu: 0, sigma: 1, n_pts: 100)
    raise "n_pts must be even (received n_pts=#{n_pts})" unless n_pts.even?

    a = x - mu < -3 * sigma ? x - 2 * sigma + mu : -5 * sigma + mu
    simpson(func, a, x, n_pts, options)
  end

  # Format a number with thousands delimiters.
  # @param number [Numeric, String]
  # @param delimiter [String]
  # @param separator [String]
  # @return [String]
  def delimit(number, delimiter = ',', separator = '.')
    parts = number.to_s.split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
    parts.join separator
  end

  # @return [String] hostname truncated to ten characters
  def computer_name_short
    `hostname`[0..9]
  end

  private

  # @return [Object] default WinLoss calculator or raises a helpful error
  def default_win_loss_calculator
    return WinLoss.new if defined?(WinLoss)

    raise ForChrisLibError, 'WinLoss dependency is not available. Provide win_loss_calculator:'
  end

  # @return [Class] default minimizer or raises when dependency missing
  def default_minimizer_class
    require 'minimization'
    Minimization::Brent
  rescue LoadError
    raise ForChrisLibError, 'minimization gem is required to estimate bias or supply minimizer_class'
  end
end

String.class_eval do
  # Extract substring located between two marker strings.
  # @param marker1 [String]
  # @param marker2 [String]
  # @return [String, nil]
  def string_between_markers(marker1, marker2)
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

Integer.class_eval do
  # Coerce integer to float then apply {Float#sigmoid}.
  # @return [Integer]
  def sigmoid
    to_f.sigmoid
  end
end

Float.class_eval do
  # Sign-based sigmoid returning -1, 0, or 1.
  # @return [Integer]
  def sigmoid
    if self > 0
      1
    elsif self < 0
      -1
    else
      0
    end
  end
end

Array.class_eval do
  # Pad nested arrays with nil so all sub-arrays share a length.
  # @return [Array<Array>]
  def pad_sub_arrays!
    max_len = map(&:length).max
    map do |a|
      len = a.length
      if len == max_len
        a
      else
        a.fill(nil, len...max_len)
      end
    end
  end

  # Remove nil padding created by {#pad_sub_arrays!}.
  # @return [Array<Array>]
  def unpad_sub_arrays!
    map(&:compact)
  end

  # Histogram of rounded integers derived from the array values.
  # @return [Hash{Integer=>Integer}]
  def histogram_int
    hsh = Hash.new(0)
    each { |x| hsh[x.round] += 1 }
    hsh.sort_by { |k, _| k }.to_h
  end

  # Shift histogram bins by a fractional amount using linear interpolation.
  # @param x [Float]
  # @return [Array<Float>]
  def bin_shift(x)
    i_max = length - 1
    return self if x.zero?

    if x.positive?
      j = x.floor
      dx = x - j
      b = bin_int_shift(j)
      delta = b.map { |e| e * dx }
      delta[-1] = 0.0
      b_1 = b.zip(delta).map { |e_b, e_d| e_b - e_d }
      b_2 = (1..i_max).map { |i| b_1[i] + delta[i - 1] }
      b_2.insert(0, b_1[0])
    else
      j = x.ceil
      dx = (x - j).abs
      b = bin_int_shift(j)
      delta = b.map { |e| e * dx }
      delta[0] = 0.0
      b_1 = b.zip(delta).map { |e_b, e_d| e_b - e_d }
      b_2 = (0..(i_max - 1)).map { |i| b_1[i] + delta[i + 1] }
      b_2.insert(i_max, b_1[i_max])
    end
  end

  # Shift histogram bins by an integer amount.
  # @param j [Integer]
  # @return [Array<Numeric>]
  def bin_int_shift(j)
    i_max = length - 1
    if j.zero?
      self
    elsif j.positive?
      a_s = self
      (1..[j, i_max].min).each do
        a_s = a_s.bin_int_shift_right(i_max)
      end
      a_s
    else
      a_s = self
      (1..[-j, i_max].min).each do
        a_s = a_s.bin_int_shift_left(i_max)
      end
      a_s
    end
  end

  # Helper used by {#bin_int_shift} for leftward shifts.
  # @return [Array<Numeric>]
  def bin_int_shift_left(i_max)
    each_with_index.map do |_, i|
      if i == i_max
        0
      elsif i.positive?
        self[i + 1]
      else
        self[0] + self[1]
      end
    end
  end

  # Helper used by {#bin_int_shift} for rightward shifts.
  # @return [Array<Numeric>]
  def bin_int_shift_right(i_max)
    each_with_index.map do |_, i|
      if i.zero?
        0
      elsif i < i_max
        self[i - 1]
      else
        self[i - 1] + self[i]
      end
    end
  end

  # Apply {Float#sigmoid} element-wise.
  # @return [Array<Integer>]
  def sigmoid
    map do |v|
      if v > 0
        1
      elsif v < 0
        -1
      else
        0
      end
    end
  end

  # Linear interpolation over sorted [x, y] pairs.
  # @param x [Numeric]
  # @return [Numeric]
  def interpolate(x)
    x_a = transpose[0]
    x_min = x_a[0]
    x_max = x_a[-1]
    return self[0][1] if x <= x_min
    return self[-1][1] if x >= x_max

    i = x_a.find_index { |v| v >= x }
    return self[i][1] if x == self[i][0]

    m = (self[i][1] - self[i - 1][1]).to_f / (self[i][0] - self[i - 1][0])
    (x - self[i - 1][0]) * m + self[i - 1][1]
  end

  # Approximate tensor dimension based on nested arrays.
  # @return [Integer]
  def dimension
    return 0 unless is_a?(Array)

    result = 1
    each do |sub_a|
      next unless sub_a.is_a?(Array)

      dim = sub_a.dimension
      result = dim + 1 if dim + 1 > result
    end
    result
  end

  # Sum values across 1D, 2D, or 3D arrays.
  # @return [Numeric]
  def total
    unless [1, 2, 3].include?(dimension)
      raise "not implemented for #{dimension} dimensions"
    end

    return sum if dimension == 1
    return sum.sum if dimension == 2

    sum.sum.sum
  end

  # Discrete probability density function derived from sample counts.
  # @return [Hash{Numeric=>Float}]
  def pdf
    tally.map { |k, v| [k, v.to_f / count] }.sort_by { |k, _| k }.to_h
  end

  # Discrete cumulative distribution function derived from {#pdf}.
  # @return [Hash{Numeric=>Float}]
  def cdf
    pdf_temp = pdf
    pdf_temp.keys.each_with_index.map { |k, i| [k, pdf_temp.values[0..i].sum] }.to_h
  end
end

Hash.class_eval do
  # Build a cumulative distribution function from ordered PDF values.
  # @return [Hash{Object=>Float}]
  def cdf_from_pdf
    keys.each_with_index.map { |k, i| [k, values[0..i].sum] }.to_h
  end

  # Normalise Handicap histogram into ordered hash for male golfers.
  # @return [Hash{Integer=>Integer}]
  def male_ga_hist
    hist = Hash.new(0)
    (-5..37).each do |h|
      each { |k, v| hist[h] += v if k.to_i == h }
    end
    hist
  end

  # Normalise Handicap histogram into ordered hash for female golfers.
  # @return [Hash{Integer=>Integer}]
  def female_male_ga_hist
    hist = Hash.new(0)
    (-5..46).each do |h|
      each { |k, v| hist[h] += v if k.to_i == h }
    end
    hist
  end
end
