# Point
# -----
#
# A class representing a point (or vector) in n-dimensional space.
#
class HonorRoll::Point

  # The coordinates of the point
  attr_accessor :coords
  # The cluster to which the point belongs
  attr_accessor :cluster

  # Generates an n-dimensional random point within the ranges provided for each
  # dimension.
  #
  # Params:
  #   dimension_ranges - An array of range objects, specifying the max/min
  #                      possible value for each dimension. The length of
  #                      this array determines the number of dimensions.
  #
  # Returns:
  #   A Point instance with random coordinates within the ranges specified for
  #   each dimension.
  #
  def self.random_point(dimension_ranges)
    HonorRoll::Point.new dimension_ranges.map { |r| rand(r.min.to_f..r.max.to_f) }
  end

  # Creates an instance of a Point class, initialized with the provided
  # coordinates. If no coordinates ar provided, the point is initialized in
  # 2-dimensional space at [0,0]
  #
  # Params:
  #   coords - an array of Float objects representing the coordinate of this
  #            point in each dimension.
  #
  # Returns:
  #   A Point instance.
  #
  def initialize(coords = [0.0,0.0])
    self.coords = coords;
  end

  # Determines the number of dimensions in which this Point is expressed, based
  # on the number of elements in the @coords array.
  #
  # Returns:
  #   A Fixnum representing the number of dimensions.
  #
  def dimensions
    self.coords.count
  end

  # Calculates the Euclidean Distance to another point.
  # (https://en.wikipedia.org/wiki/Euclidean_distance)
  #
  # Params:
  #   point - another Point object with the same number of dimensions, to which
  #           we will calculate a distance.
  #
  # Returns:
  #   The Euclidean distance, as a Float object.
  #
  def euclidean_distance_to(point)
    if self.dimensions != point.dimensions
      raise HonorRoll::IncompatibleDimensionsError
    end
    coord_pairs = self.coords.zip point.coords
    Math.sqrt coord_pairs.map{ |p| (p[0] - p[1])**2 }.reduce(:+)
  end

end


# IncompatibleDimensionsError
#
# An error class that describes a situation where execution cannot continude
# because two points are expressed in different dimensions.
#
# For example, a distance cannot be calculated between the points:
#   [ 1, 2, 2, 3 ] and [4, 2]
#
class HonorRoll::IncompatibleDimensionsError < ArgumentError
  def message
    '''
    The provided Point object has an incompatible number of dimensions,
    therefore a Euclidean distance cannot be calculated.
    '''
  end
end
