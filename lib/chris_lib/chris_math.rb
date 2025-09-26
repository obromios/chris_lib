require 'matrix'
require 'quaternion'
Quaternion.class_eval do
  # @param n [Integer] number of decimal places to retain
  # @return [Quaternion] a new quaternion with each component rounded
  def round(n)
    q = self
    Quaternion.new(q[0].round(n), q[1].round(n), q[2].round(n), q[3].round(n))
  end

  # @return [Quaternion] the identity quaternion (1, 0, 0, 0)
  def self.identity
    Quaternion.new(1.0, 0.0, 0.0, 0.0)
  end

  # @return [Quaternion] the zero quaternion (0, 0, 0, 0)
  def self.zero
    Quaternion.new(0.0, 0.0, 0.0, 0.0)
  end
  
  # Creates quaternion using square brackets (for compatability with Matrix and Vector)
  # @see https://stackoverflow.com/questions/69155796/how-to-define-a-class-method-when-using-class-eval
  # @param q0 [Numeric]
  # @param q1 [Numeric]
  # @param q2 [Numeric]
  # @param q3 [Numeric]
  # @return [Quaternion]
  def self.[](q0, q1, q2, q3)
    Quaternion.new(q0, q1, q2, q3)
  end
end

Integer.class_eval do
  # @return [Integer] factorial of the number
  # @raise [RuntimeError] when the receiver is greater than 20 to avoid overflow
  def factorial
    n = self
    if n > 20
      raise 'Number too large'
    else
      (1..n).inject {|prod, i| prod * i}
    end
  end
end

Matrix.class_eval do
  # Right pseudo-inverse for linearly independent rows
  # @return [Matrix]
  # @raise [ExceptionForMatrix::ErrNotRegular] when the matrix is rank-deficient
  def pinv
    full_rank = (rank == [row_count, column_count].min)
    raise ExceptionForMatrix::ErrNotRegular unless full_rank
    transpose * (self * transpose).inv
  end

  # Alias for {#pinv} maintained for backwards compatibility
  # @return [Matrix]
  # @raise [ExceptionForMatrix::ErrNotRegular] when the matrix is rank-deficient
  def pinv_right
    full_rank = (rank == [row_count, column_count].min)
    raise ExceptionForMatrix::ErrNotRegular unless full_rank
    transpose * (self * transpose).inv
  end

  # Left pseudo-inverse for linearly independent columns
  # @return [Matrix]
  def pinv_left
    (transpose * self).inv * transpose
  end
end

Array.class_eval do
  # Converts radians to degrees for each element
  # @param n_decimals [Integer, nil] decimal places to round to, pass nil for no rounding
  # @return [Array<Float>] converted values
  def to_deg(n_decimals = nil)
    map { |e| e.to_deg(n_decimals) }   
  end

  # Converts degrees to radians for each element
  # @param n_decimals [Integer, nil] decimal places to round to, pass nil for no rounding
  # @return [Array<Float>] converted values
  def to_rad(n_decimals = nil)
    map { |e| e.to_rad(n_decimals) }
  end

  # Rounds each element in-place
  # @param decimal_points [Integer] decimal places to round to
  # @return [Array<Numeric>] rounded values
  def round(decimal_points = 0)
    map { |e| e.round(decimal_points) }
  end

  # Rounds elements using {Float#eround}
  # @param decimal_points [Integer]
  # @return [Array<Float>]
  def eround(decimal_points = 0)
    map { |e| e.eround(decimal_points) }
  end
  
  # Calculates the arithmetic mean of elements
  # @return [Numeric, Vector]
  # @raise [RuntimeError] when the array is empty
  def mean
    raise 'chris_lib - f - Length must be greater than 0.' if length < 1
    return sum.to_f / length unless all? { |e| e.class == Vector }
    ary = map { |v| v.to_a }.transpose.map { |a| a.mean }
    Vector.elements ary
  end

  # Computes the unbiased sample variance
  # @return [Float]
  # @raise [RuntimeError] when the array has fewer than two elements
  def var
    raise 'Length must be greater than 1' if length < 2
    mu = mean
    map { |v| (v**2 - mu**2) }.sum.to_f / (length - 1)
  end

  # Computes the sample standard deviation
  # @return [Float]
  def std
    return 0 if var < 0.0 # perhaps due to rounding errors
    Math.sqrt(var)
  end

  # Standard error of the sample mean
  # @return [Float]
  def std_err
    std / Math.sqrt(size)
  end

  # @return [Numeric] median value of the array
  def median
    return self[0] if length <= 1
    sorted = sort
    n = length
    if n.odd? # length is odd
      sorted[n/2]
    else
      (sorted[n/2] + sorted[n/2-1]).to_f/2
    end
  end

  # Deep duplicate the array
  # @return [Object] a deep copy of the array
  # @see https://www.thoughtco.com/making-deep-copies-in-ruby-2907749
  def deep_dup
    Marshal.load(Marshal.dump(self))
  end
end

Float.class_eval do
  # Converts radians to degrees
  # @param n_decimals [Integer, nil] decimal places to round to, pass nil for no rounding
  # @return [Float]
  def to_deg(n_decimals = nil)
    include Math unless defined?(Math)
    degrees = self * 180.0 / PI
    return degrees if n_decimals.nil?
    degrees.round(n_decimals)    
  end

  # Converts degrees to radians
  # @param n_decimals [Integer, nil] decimal places to round to, pass nil for no rounding
  # @return [Float]
  def to_rad(n_decimals = nil)
    include Math unless defined?(Math)
    radians = self * PI / 180.0
    return radians if n_decimals.nil?
    radians.round(n_decimals)
  end

  # Rounds a float represented in exponential notation
  # @param decimal_points [Integer]
  # @return [Float]
  def eround(decimal_points = 0)
    ("%.#{decimal_points}e" % self).to_f
  end

  # @param n [Integer] decimal place to round down to
  # @return [Float]
  def round_down(n=0)
    # n is decimal place to round down at
    int,dec=self.to_s.split('.')
    "#{int}.#{dec[0...n]}".to_f
  end

  # @return [Float]
  def round1
    round(1)
  end

  # @return [Float]
  def round2
    round(2)
  end

  # @return [Float]
  def round3
    round(3)
  end

  # @return [Float]
  def round4
    round(4)
  end
end

# Numerically focused helpers and distribution utilities.
module ChrisMath
  
  include Math

  # Generates normally distributed random numbers using Box-Muller
  # @param n [Integer] number of samples to generate
  # @return [Array<Float>] array of N(0,1) samples
  def gaussian_array(n = 1)
    (1..n).map do
      u1 = rand()
      u2 = rand()
      sqrt(-2*log(u1))*cos(2*PI*u2)
    end
  end
  
  # Generates a pair of independent standard normal deviates
  # @return [Array<Float>] two-element array [z0, z1]
  def bi_gaussian_rand
    u1 = rand()
    u2 = rand()
    z0 = sqrt(-2*log(u1))*cos(2*PI*u2)
    z1 = sqrt(-2*log(u1))*sin(2*PI*u2)
    [z0,z1]
  end

  # Generates a normally distributed random number with the provided mean and std
  # @param mean [Numeric]
  # @param std [Numeric]
  # @return [Float]
  def gaussian_rand(mean,std)
    u1 = rand()
    u2 = rand()
    z0 = sqrt(-2*log(u1))*cos(2*PI*u2)
    z0*std + mean
  end
  
  
  # Sample standard deviation for raw values
  # @param values [Array<Numeric>]
  # @return [Float]
  # @raise [RuntimeError] when fewer than two observations are provided
  def std(values)
    n = values.length
    raise 'n = #{n} but must be greater than 1' if n < 2
    m = mean(values)
    sum = values.inject { |s,v| s + (v**2 - m**2)}
    sqrt(sum.to_f/(n - 1))
  end
  

  # Cumulative probability of at least r successes in n Bernoulli trials
  # @param n [Integer]
  # @param r [Integer]
  # @param p [Float] probability of success per trial
  # @return [Float]
  # @raise [RuntimeError] when r is outside 0..n
  def combinatorial_distribution(n,r,p)
    # probability that r out n or greater hits with the 
    # probability of one hit is p.
    if r <= n && r >= 0
    sum = 0
    (r..n).each do |k|
      sum += combinatorial(n,k)*(p)**(k)*(1-p)**(n - k)
    end
    sum
    else
      raise 'Error, #{r} must be >= 0  and <= #{n}'
    end
  end
  
  # Factorial without overflow protection
  # @param n [Integer]
  # @return [Integer]
  def factorial(n)
    #from rosetta code
    (1..n).inject {|prod, i| prod * i}
  end
  
  # Binomial coefficient "n choose k"
  # @param n [Integer]
  # @param k [Integer]
  # @return [Integer]
  def combinatorial(n, k)
    #from rosetta code
    (0...k).inject(1) do |m,i| (m * (n - i)) / (i + 1) end
  end
  
end
