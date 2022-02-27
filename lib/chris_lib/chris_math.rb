require 'matrix'
require 'quaternion'
Quaternion.class_eval do
  # rounds each element of quaternion to n decimal places
  def round(n)
    q = self
    Quaternion.new(q[0].round(n), q[1].round(n), q[2].round(n), q[3].round(n))
  end

  # Creates identity quaternion
  def self.identity
    Quaternion.new(1.0, 0.0, 0.0, 0.0)
  end

  # Creates zero quaternion
  def self.zero
    Quaternion.new(0.0, 0.0, 0.0, 0.0)
  end
  
  # Creates quaternion using square brackets (for compatability with Matrix and Vector)
  # see https://stackoverflow.com/questions/69155796/how-to-define-a-class-method-when-using-class-eval
  def self.[](q0, q1, q2, q3)
    Quaternion.new(q0, q1, q2, q3)
  end
end

Integer.class_eval do
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
  # right pseudo-inverse for linearly independent rows
  def pinv
    full_rank = (rank == [row_count, column_count].min)
    raise ExceptionForMatrix::ErrNotRegular unless full_rank
    transpose * (self * transpose).inv
  end

  # for linearly independent rows
  def pinv_right
    full_rank = (rank == [row_count, column_count].min)
    raise ExceptionForMatrix::ErrNotRegular unless full_rank
    transpose * (self * transpose).inv
  end

  # for linearly independent columns
  def pinv_left
    (transpose * self).inv * transpose
  end
end

Array.class_eval do
  # converts radians to degrees
  # Also rounds to n_decimal places unless n_decimimals is nil
  def to_deg(n_decimals = nil)
    map { |e| e.to_deg(n_decimals) }   
  end

  # converts degrees to radians
  # Also rounds to n_decimal places unless n_decimimals is nil
  def to_rad(n_decimals = nil)
    map { |e| e.to_rad(n_decimals) }
  end

  # round each element
  def round(decimal_points = 0)
    map { |e| e.round(decimal_points) }
  end

  def eround(decimal_points = 0)
    map { |e| e.eround(decimal_points) }
  end
  
  # mean of array
  def mean
    raise 'Length must be greater than 0.' if length < 1
    sum.to_f / length
  end

  # unbiased sample variance of array
  def var
    raise 'Length must be greater than 1' if length < 2
    mu = mean
    map { |v| (v**2 - mu**2) }.sum.to_f / (length - 1)
  end

  # sample standard deviation
  def std
    return 0 if var < 0.0 # perhaps due to rounding errors
    Math.sqrt(var)
  end

  # standard error of sample mean
  def std_err
    std / Math.sqrt(size)
  end

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

  # deep dup, takes about 20 microseconds for scores arrays
  # https://www.thoughtco.com/making-deep-copies-in-ruby-2907749
  def deep_dup
    Marshal.load(Marshal.dump(self))
  end
end

Float.class_eval do
  # converts radians to degrees
  # Also rounds to n_decimal places unless n_decimimals is nil
  def to_deg(n_decimals = nil)
    include Math unless defined?(Math)
    degrees = self * 180.0 / PI
    return degrees if n_decimals.nil?
    degrees.round(n_decimals)    
  end

  # converts degrees to radians
  # Also rounds to n_decimal places unless n_decimimals is nil
  def to_rad(n_decimals = nil)
    include Math unless defined?(Math)
    radians = self * PI / 180.0
    return radians if n_decimals.nil?
    radians.round(n_decimals)
  end

  # rounds exponential notation to n decimal places
  def eround(decimal_points = 0)
    ("%.#{decimal_points}e" % self).to_f
  end

  def round_down(n=0)
    # n is decimal place to round down at
    int,dec=self.to_s.split('.')
    "#{int}.#{dec[0...n]}".to_f
  end

  def round1
    round(1)
  end

  def round2
    round(2)
  end

  def round3
    round(3)
  end

  def round4
    round(4)
  end
end

module ChrisMath
  
  include Math

  def gaussian_array(n = 1)
    (1..n).map do
      u1 = rand()
      u2 = rand()
      sqrt(-2*log(u1))*cos(2*PI*u2)
    end
  end
  
  def bi_gaussian_rand
    u1 = rand()
    u2 = rand()
    z0 = sqrt(-2*log(u1))*cos(2*PI*u2)
    z1 = sqrt(-2*log(u1))*sin(2*PI*u2)
    [z0,z1]
  end

  def gaussian_rand(mean,std)
    u1 = rand()
    u2 = rand()
    z0 = sqrt(-2*log(u1))*cos(2*PI*u2)
    z0*std + mean
  end
  
  
  def std(values)
    n = values.length
    raise 'n = #{n} but must be greater than 1' if n < 2
    m = mean(values)
    sum = values.inject { |s,v| s + (v**2 - m**2)}
    sqrt(sum.to_f/(n - 1))
  end
  

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
  
  def factorial(n)
    #from rosetta code
    (1..n).inject {|prod, i| prod * i}
  end
  
  def combinatorial(n, k)
    #from rosetta code
    (0...k).inject(1) do |m,i| (m * (n - i)) / (i + 1) end
  end
  
end
