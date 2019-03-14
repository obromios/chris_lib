Integer.class_eval do
  def factorial
    n = self
    if n > 20
      fail 'Number too large'
    else
      (1..n).inject {|prod, i| prod * i}
    end
  end
end
Array.class_eval do
  # mean of array
  def mean
    # s=c(7.08195525827783, 10.831582068121444, 9.288611270369554, 9.054684238411918, 12.268532229606647)
    # returns 9.705073
    fail 'Length must be greater than 0.' if length < 1
    sum = self.inject { |s, v| s + v }
    sum.to_f / length
  end

  # unbiased sample variance of array
  def var
    # s=c(7.08195525827783, 10.831582068121444, 9.288611270369554, 9.054684238411918, 12.268532229606647)
    # R returns 3.829385
    fail 'Length must be greater than 1' if length < 2 
    mu = self.mean
    total = self.inject(0) { |s,v| s + (v**2 - mu**2)}
    total.to_f/(length - 1)
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

  def histogram
    k = Hash.new(0)
    self.each { |x| k[x] += 1 }
    k
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
    fail 'n = #{n} but must be greater than 1' if n < 2
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
      fail 'Error, #{r} must be >= 0  and <= #{n}'
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
