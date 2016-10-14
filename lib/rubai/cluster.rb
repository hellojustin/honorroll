# Cluster
#
# A class representing a Cluster. A Cluster is a group of Point objects.
#
class Cluster

  # An array of Point objects belonging to the cluster
  attr_accessor :points
  # A Point object representing the centroid of the cluster
  attr_accessor :centroid

  # Creates an instance of a Cluster class, initialized with defaults or the
  # provided points and/or centroid.
  #
  # Params:
  #   :points   - An array of Point objects that will become the members of the
  #               cluster.
  #   :centroid - A Point object representing the centroid of the cluster.
  #
  # Returns:
  #   A Cluster instance.
  #
  def initialize(params = {})
    self.points   = params[:points]   || []
    self.centroid = params[:centroid] || nil
  end

  # Returns the number of points in the cluster.
  #
  # Returns:
  #   A Fixnum equal to the number of points in the cluster.
  #
  def size
    self.points.count
  end

  # Calculates the number of dimensions for the points in the cluster. All
  # points in the cluster should have the same number of dimensions.
  #
  # Returns:
  #   A Fixnum equal to the number of coordinates that the first point in the
  #   cluster.
  #
  def dimensionality
    return nil if self.points.count == 0
    self.points.first.dimensions
  end

  # Calculates a range for each dimension such that it covers all coordinates in
  # that dimension for all points in the cluster.
  #
  # Returns:
  #   An Array of Range objects, sucn that each range_i covers point.coords_i,
  #   for all points.
  #
  def dimensional_ranges
    points = self.points.map &:coords
    points.transpose.map { |d| d.min.to_f..d.max.to_f }
  end

  # Determines the centroid of the cluster (and updates the Cluster's @centroid
  # property), based on the points of the cluster.
  #
  # Returns:
  #   A Point object whose coordinates are the average of all points in the
  #   cluster.
  #
  def centroid_from_points!
    return self.centroid if self.size == 0
    points = self.points.map &:coords
    avg_coord = points.transpose.map { |d| d.reduce(:+) / d.count.to_f }
    self.centroid = Point.new avg_coord
  end

  def add_point(point)
    point.cluster.remove_point point if point.cluster
    self.points << point
    point.cluster = self
  end

  def remove_point(point)
    self.points.delete point
    point.cluster = nil
  end

  def include?(point)
    self.points.include? point
  end

end
