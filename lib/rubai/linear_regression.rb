require 'matrix'

class LinearRegression

  def initialize(params = {})
    @learning_rate      = params[:learning_rate] || 1
    @converge_threshold = params[:convergence_threshold] || 0.001
  end

  def predict(features)
    if defined? @thetas
      features = features.clone.unshift 1
      hypothesize @thetas, features
    end
  end

  # Runs the training process to fit a line to a particular set of feactures and
  # outputs. One datapoint includes one or more features and exactly one output.
  #
  # This example data...
  #
  # |-------------|------------|------------|---------|
  # | Feature 1   | Feature 2  | Feature 3  | Output  |
  # |-------------|------------|------------|---------|
  # | 2104        | 5          | 1          | 460     |
  # | 1416        | 3          | 2          | 232     |  <-- one datapoint
  # | 1534        | 3          | 2          | 315     |
  # | 852         | 2          | 1          | 178     |  <-- another datapoint
  # | ...         | ...        | ...        | ...     |
  # |-------------|------------|------------|---------|
  #
  # ...would be passed as two paramters:
  #
  # features:
  # [ [2104, 5, 1], [1416, 3, 2], [1534, 3, 2], [852, 2, 1], ... ]
  #
  # outputs:
  # [ 460, 232, 315, 178 ]
  #
  def train(original_features, outputs)
    features    = add_zero_feature scale_features(original_features)
    thetas      = Array.new features.first.size, 0
    outputs     = scale_values outputs
    @iterations = 0
    @thetas     = batch_descend thetas, features, outputs
    @iterations
  end

  def scale_features(features)
    t_features = features.transpose.map do |feature_values|
      scale_values feature_values
    end
    t_features.transpose
  end

  def scale_values(values)
    avg = values.reduce(:+) / values.count
    max = values.max
    values.map { |v| (v - avg) / max.to_f }
  end

  def add_zero_feature(features)
    features.map { |f| f.clone.unshift 1 }
  end

  def batch_descend(thetas, features, outputs)
    @iterations += 1
    new_thetas = thetas.map.with_index do |theta, i|
      theta - @learning_rate * partial_derivative(thetas, features, outputs, i)
    end
    puts new_thetas.to_s
    if continue? new_thetas, thetas
      batch_descend new_thetas, features, outputs
    else
      new_thetas
    end
  end

  def continue? (new_thetas, old_thetas)
    changes = new_thetas.zip(old_thetas).map{ |c| c.reduce(:-)}.map(&:abs)
    avg_change = changes.reduce(:+) / changes.size.to_f
    puts avg_change
    avg_change > @converge_threshold
  end

  # Calculates the partial derivative for
  # thetas      = the thetas vector
  # feature_set = the array of all feature vectors (2-d)
  # outputs     = the output vector
  # theta_index = the index of the theta that we're trying to calculate
  def partial_derivative(thetas, features_set, outputs, theta_index)
    terms = features_set.map.with_index do |features, i|
      (hypothesize(thetas, features) - outputs[i]) * features[theta_index]
    end
    terms.reduce(:+).to_f / features_set.size.to_f
  end

  def mean_squared_error(thetas, features_set, outputs)
    terms = features_set.map do |features|
      (hypothesize(thetas, features) - outputs[i])**2
    end
    terms.reduce(:+).to_f / (2 * features_set.size.to_f)
  end

  # Runs the multivariate hypothesis function for one data point
  # thetas   = the thetas vector
  # features = the feature vector for one data point
  #
  # Multivariate hypothesis equation:
  #  t0*f0 + t1*f1 + t2*f2 ...
  #
  def hypothesize(thetas, features)
    terms = thetas.zip features
    terms.map{ |t| t.reduce :* }.reduce :+
  end

end
