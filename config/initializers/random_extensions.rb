# there might be a better place to put this ...?

Kernel.class_eval do
  
  def rand_range(min, max) 
    return min + rand(max-min)
  end
  
end