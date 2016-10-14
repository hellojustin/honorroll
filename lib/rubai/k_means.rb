class KMeans

  attr_accessor :clusters
  attr_accessor :points

  def initialize(params = {})
    @points = if params[:points]
      params[:points].map { |p| Point.new p }
    else
      []
    end
  end

  def identify_clusters(number_of_clusters = 2, initial_centroids = nil)
    @clusters = if initial_centroids
      initial_centroids.map { |ic| Cluster.new(centroid: Point.new(ic)) }
    else
      clusters_with_random_centroids points, number_of_clusters
    end
    assign_points_to_clusters! @points, @clusters
    @clusters
  end

#private

  # Determines the nearest centroid to each point, and assigns the point to that
  # centroid's cluster. If one or more point change from one cluster to another,
  # the method recurs. This method mutates members of the @clusters and @points
  # attributes.
  #
  # Params:
  #   points - the full dataset of n-dimensional points (an array of arrays)
  #   clusters - the array of Cluster objects
  #
  # Returns:
  #   Nil
  def assign_points_to_clusters!(points, clusters)
    cluster_changes = 0
    points.each do |p|
      nearest = @clusters.min_by { |c| p.euclidean_distance_to c.centroid }
      cluster_changes += 1 unless nearest == p.cluster
      nearest.add_point p
    end
    clusters.each { |c| c.centroid_from_points! }
    assign_points_to_clusters!(points, clusters) if cluster_changes > 0
  end

  # Generates an array of random points that can be used as initial centroid
  # values for each cluster. Note that a point is also an array, so this returns
  # an array of arrays
  #
  # Params:
  #   points - the full dataset (used to find max/min in each dimension)
  #   number_of_centroids - the desired number of centroids
  #
  # Returns:
  #   An array of randomly-generated n-dimensional points, of length
  #   number_of_centroids
  #
  def clusters_with_random_centroids(points, number_of_clusters)
    point_coords = points.map &:coords
    dimension_ranges = point_coords.transpose.map { |p| p.min..p.max }
    (0...number_of_clusters).map do
      Cluster.new(centroid: Point.random_point(dimension_ranges))
    end
  end

  # Determines the centroid for each of a set of clusters.
  #
  # Params:
  #   clusters - an associative array where the key is a cluster number, and the
  #              value is an array of n-dimensional points belonging to that
  #              cluster.
  #
  # Returns:
  #   An array of n-dimensional array, each of which is the centroid of the
  #   cluster corresponding to its index in the array.
  def centroids(clusters)
    clusters.values.map { |cluster_points| centroid cluster_points }
  end

  # Finds the centroid - or average point - of a set of n-dimensional points.
  #
  # Params:
  #   points - An array of n-dimensional points (array of arrays).
  #
  # Returns:
  #   An n-dimensional array representing the centroid of the set of points.
  def centroid(points)
    Point.new points.transpose.map{ |d| d.reduce(:+) / d.count.to_f }
  end

end
