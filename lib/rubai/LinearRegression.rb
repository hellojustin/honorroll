class LinearRegression

  attr_accessor :training_inputs
  attr_accessor :training_outputs

  def initialize(training_set)
    @training_inputs    = training_set[:inputs]
    @training_outputs   = training_set[:outputs]
    @learning_rate      = 1
    @converge_threshold = 0.001
  end

  def predict
  end

  def train
  end

  def descend(theta_vector, training_inputs, training_outputs)
    theta_vector.map.with_index do |t, i|
      t - @learning_rate * partial_derivative(training_inputs, training_inputs[i], training_outputs)
    end
    
  end

  def partial_derivative(x_vector, x_j, y)
    (1/x_vector.size) * x_vector.inject do |sum, x|
      sum + (hypothesize(x) - y) * x_j
    end
  end

  def hypothesize(theta_vector, feature_vector)
    feature_vector.unshift 1 # adds the 'zero feaure', so that theta0 remains itself
    terms = theta_vector.zip feature_vector

    # TODO: this is a transpose operation. theta_vector is matrix, feature_vector is vector.
    terms.inject theta0 do |sum, term|
      sum + term[0] * term[1]
    end
  end

end
