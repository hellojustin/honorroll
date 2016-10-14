class PolynomialRegression

  attr_accessor :learning_rate
  attr_accessor :convergence_threshold
  attr_accessor :polynomial_degree
  attr_accessor :log
  attr_accessor :iterations
  attr_accessor :thetas
  attr_accessor :old_thetas

  def initialize(params = {})
    @learning_rate         = params[:learning_rate]         || 1.0e-20
    @convergence_threshold = params[:convergence_threshold] || 1.0e-4
    @polynomial_degree     = params[:polynomial_degree]     || 1
    @log                   = params[:log_to_standard_out]   || false
  end

  def predict(features)
    if defined? @thetas
      features = polynomialize_features([features]).flatten.clone.unshift 1
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
    features    = add_zero_feature polynomialize_features(original_features)
    @iterations = 0
    @old_thetas = Array.new features.first.size, 0
    @thetas     = batch_descend @old_thetas, features, outputs
    while continue? @thetas, @old_thetas, features, outputs
      @old_thetas = @thetas
      @thetas = batch_descend @thetas, features, outputs
    end
    @iterations
  end

private

  def polynomialize_features(features)
    features.collect do |feature|
      (1..@polynomial_degree).collect do |n|
        feature.map{ |f| f**n }
      end.flatten
    end
  end

  def add_zero_feature(features)
    features.map { |f| f.clone.unshift 1 }
  end

  def batch_descend(thetas, features, outputs)
    if @log
      puts "Iteration ##{@iterations}:"
      puts "Features: #{features}"
      puts "Outputs: #{outputs}"
      puts "Thetas: #{thetas}"
      puts ""
    end
    @iterations += 1
    @thetas = thetas.map.with_index do |theta, i|
      theta - @learning_rate * partial_derivative(thetas, features, outputs, i)
    end
  end

  def continue? (new_thetas, old_thetas, features, outputs)
    old_thetas_mse = mean_squared_error(old_thetas, features, outputs)
    new_thetas_mse = mean_squared_error(new_thetas, features, outputs)
    change = old_thetas_mse - new_thetas_mse
    raise MeanSquaredErrorDivergenceError if change < 0
    change.abs > @convergence_threshold
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
    terms = features_set.map.with_index do |features, i|
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

class MeanSquaredErrorDivergenceError < RuntimeError
  def message
    """
    The Mean Squared Error is increasing, which means your thetas are diverging.
    Try using a smaller learning_rate (alpha).
    """
  end
end
