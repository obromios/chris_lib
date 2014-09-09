Integer.class_eval do
	def factorial
		n=self
		if n > 39
			raise "Number too large"
		else
			(1..n).inject {|prod, i| prod * i}
		end
	end
end

module ChrisMath
	
	include Math
	
	def bi_gaussian_rand
		u1 = rand()
		u2 = rand()
		z0 = sqrt(-2*log(u1))*cos(2*PI*u2)
		z1 = sqrt(-2*log(u1))*sin(2*PI*u2)
		return [z0,z1]
	end

	def gaussian_rand(mean,std)
		u1 = rand()
		u2 = rand()
		z0 = sqrt(-2*log(u1))*cos(2*PI*u2)
		z0*std + mean
	end
	
	
	def std(values)
		n = values.count
		raise "n = #{n} but must be greater than 1" if n < 2 
		m = mean(values)
		sum = values.inject { |s,v| s + (v**2 - m**2)}
		sqrt(sum.to_f/(n -1))
	end
	

	def combinatorial_distribution(n,r,p)
		# probability that r out n or greater hits with the 
		# probability of one hit is p.
		if r <= n && r >= 0
		sum = 0
		(r..n).each do |k|
			sum += combinatorial(n,k)*(p)**(k)*(1-p)**(n -k)
		end
		sum
		else
			raise "Error, #{r} must be >= 0  and <= #{n}"
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
