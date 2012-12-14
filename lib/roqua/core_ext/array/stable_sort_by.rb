class Array
  # Method for stably sorting elements in an array on multiple attributes.
  #
  # * Pass the method a block with two arrays containing the attributes for which the
  #   elements should be subsequently sorted. The first attribute is applied last.
  #   If for some attribute the sort order should be reversed, the parameters x and y can
  #   be exchanged between the arrays.
  #
  # ==== Example
  #   my_array.stable_sort_by{|x, y| [
  #                            x.attribute1,
  #                            y.attribute2,
  #                            y.attribute3,
  #                            y.attribute4
  #                          ] <=> [
  #                            y.attribute1,
  #                            x.attribute2,
  #                            x.attribute3,
  #                            x.attribute4
  #                          ]}
  #
  def stable_sort_by
    sort do |x, y|
      if not x
        -1
      elsif not y
        1
      else
        if block_given?
          yield x, y
        else
          x <=> y
        end
      end
    end
  end
end