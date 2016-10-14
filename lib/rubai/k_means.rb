# KMeans
#
# A class from which instances of the K-Means clustering method can be created
# and run. K-Means clustering is a method of identifying clusters of points in
# n-dimensional space. A fantastic explanation of the K-Means algorithm can be
# found at https://www.youtube.com/watch?v=_aWzGGNrcic.
#
class KMeans

  # An array of Cluster objects (see lib/rubai/cluster.rb) representing the
  # clusters that K-Means will identify.
  attr_accessor :clusters
  # An array of Point objects (see lib/rubai/points.rb) representing the dataset
  # on which we will run k-means.
  attr_accessor :points

  # Creates an instance of the KMeans class, optionally but likely initialized
  # with a params hash containing the dataset.
  #
  # Params:
  #   :points - an array of arrays, where the inner arrays are the n-dimensional
  #             coordinates of each point in the dataset
  #
  # Returns:
  #   An instance of KMeans
  #
  def initialize(params = {})
    @points = if params[:points]
      params[:points].map { |p| Point.new p }
    else
      []
    end
  end

  # Runs the k-means algorithm on the dataset specified at initialization.
  # Defaults to idenifying two clusters, starting with random centroids, but
  # a different number of clusters and starting centroids can be passed
  # optionally. The number-of-clusters param is ignored if starting centroids
  # are provided.
  #
  # Params:
  #   number_of_clusters - (optional, defaults to 2) The number of cluster that
  #                        the algorithm should identify. Ignored if
  #                        initial_centroids is also passed.
  #   initial_centroids  - An array of smaller arrays where the smaller arrays
  #                        specify the n-dimensional initial coordinates of the
  #                        centroids of the clusters. If not passed, the
  #                        clusters will be initialized with random centroids.
  #                        When passed, the number of clusters is determined by
  #                        the length of this array.
  #
  # Returns:
  #   The array of cluster objects, now populated with Points based on the
  #   results of the algorithm.
  #
  def identify_clusters(number_of_clusters = 2, initial_centroids = nil)
    @clusters = if initial_centroids
      initial_centroids.map { |ic| Cluster.new(centroid: Point.new(ic)) }
    else
      clusters_with_random_centroids points, number_of_clusters
    end
    assign_points_to_clusters! @points, @clusters
    @clusters
  end

private

  # Performs one iteration of the k-means algorithm, and then calls itself if
  # any points have changed cluster membership. Points are assigned to clusters
  # using the euclidan distance method, but at some point in the future, it will
  # be possible to provide other measures of distance.
  #
  # TODO: Optionally allow custom distance functions.
  #
  # Params:
  #   points - the full dataset of n-dimensional points (array of Point objects)
  #   clusters - the array of Cluster objects
  #
  # Returns:
  #   Nil
  #
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
  #
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
  #
  def centroid(points)
    Point.new points.transpose.map{ |d| d.reduce(:+) / d.count.to_f }
  end

end
