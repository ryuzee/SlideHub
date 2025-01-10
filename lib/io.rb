# module SlideHub
  class IO
    def head(num_of_lines)
      lazy.first(num_of_lines)
    end

    def tail(num_of_lines)
      reverse_each.lazy.first(num_of_lines).reverse
    end
  end
# end
