nums = []
1000.times { |i| nums << (i+1)**(i+1) }
puts nums.sum.to_s.slice(-10..-1)