# Cluster
# -------
#
# A class representing a Cluster. A Cluster is a group of Point objects.
#
class HonorRoll::Cluster

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
    self.centroid = HonorRoll::Point.new avg_coord
  end

  # Adds the specified Point object to this cluster, removing it from any other
  # clusters first. In the future we may make it possible for a point to belong
  # to more than one Cluster, or for a point to have a fuzzy relationship with
  # clusters.
  #
  # Params:
  #   point - the Point object that should be added to this cluster.
  #
  # Returns:
  #   This Cluster instance.
  #
  def add_point(point)
    point.cluster.remove_point point if point.cluster
    self.points << point
    point.cluster = self
  end

  # Removes the specified Point object from this cluster. Note that if two
  # points with the same coordinates are members of the cluster, only the one
  # with the same memory address will be removed. (Removal is done by instance
  # equality - which is based on the memory address - not coordinate equality.)
  #
  # Params:
  #   point - the Point object that should be removed from this cluster.
  #
  # Returns:
  #   nil
  #
  def remove_point(point)
    self.points.delete point
    point.cluster = nil
  end

  # Determines whether the specified point is a member of this cluster. Like
  # \#remove_point, this is done by instance equality (memory address), not
  # coordinate equality.
  #
  # Params:
  #   point - the Point object whose membership we wish to test.
  #
  # Returns
  #   True if the point is a member of the cluster, False otherwise.
  #
  def include?(point)
    self.points.include? point
  end

end
