# PolynomialRegression
#
# A class from which instances of the PolynomialRegression algorithm can be
# instantiated. Polynomial Regression is a supervised machine learninging
# technique that attempts to fit a line or curve function (hence polynomial) to
# a dataset where the input values (aka features), and output values are known.
# Once fitted, the line function can be used to predict the outputs values for
# new input values.
#
# Currently, this implementation uses the gradient-decent method of fitting a
# curve to the dataset. In the future, we will add the option to use the normal
# equation method.
#
# TODO: Add option to use the normal equation method.
#
class PolynomialRegression

  # The learning_rate (sometimes called alpha), which influences the step size
  # in our gradient-decent method. If too large for the provided dataset,
  # gradient-decent may never reach convergence.
  attr_accessor :learning_rate

  # The convergence threshold is the mean_squared_error at which we decide to
  # stop optimizing the fit of the line. This too must likely be adjusted based
  # on the dataset.
  attr_accessor :convergence_threshold

  # The polynomial detree influences the shape of the line/curve that we're
  # going to fit. A 1-degree (or first-degree) polynomial uses the formula
  # 'Bx + C', which represents a straight but possibly slanted line. A
  # 2-degree (or second-degree) polynomial uses the formula 'Ax^2 + Bx + C',
  # which represents a u-shaped line. (Note these examples assume a
  # 1-dimensional feature set.) The polynomial degree must be a whole number
  # greater that 0.
  attr_accessor :polynomial_degree

  # A flag to determine whether log statements should be written to standard
  # out.
  attr_accessor :log

  # A counter that keeps track of the number of iterations of the algorithm that
  # have been run.
  attr_accessor :iterations

  # An array of theta values - the coefficients for each term in the polynomial
  # formula. These are what the algorithm tries to learn during training, and
  # are then used to make predictions for new inputs.
  attr_accessor :thetas

  # The array of theta values from the previous iteration of the algorithm. We
  # keep these around so that we can determine if the error is increasing or
  # decreasing.
  attr_accessor :old_thetas

  # Creates an instance of PolynomialRegression. If no parameters are passed,
  # defaults are used, but given the nature of Polynomial Regression, you'll
  # probably have to use non-default values that work for your dataset.
  #
  # Params (passed as a hash):
  #   :learning_rate - the learning rate that should be used for
  #                    gradient-decent. Defaults to 1.0e-20. (small and slow)
  #   :convergence_threshold - the error threshold at which we stop the
  #                    gradient-decent iterations because we have a "good
  #                    enough" fit. Defaults to 1.0e-4.
  #   :polynomial_degree - a Fixnum specifying the shape of the line (or the
  #                    number of terms in the line's formula). Defaults to 1.
  #   :log           - set to true for log output. Defaults to false.
  #
  def initialize(params = {})
    @learning_rate         = params[:learning_rate]         || 1.0e-20
    @convergence_threshold = params[:convergence_threshold] || 1.0e-4
    @polynomial_degree     = params[:polynomial_degree]     || 1
    @log                   = params[:log_to_standard_out]   || false
  end

  # Predicts the output value for a given set of features (inputs), once the
  # instance is trained.
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

  # Augments the provided features to reflect the specified polynomial degree.
  # For example if for the feature "age", and polynomial degree 2, this function
  # would produce the array [(age), (age)^2]. For a third-degree polynomial, it
  # produces [(age), (age)^2, (age)^3], and so.
  #
  # Params:
  #   features - The full feature set as an array of arrays.
  #
  # Returns:
  #   The augmented feature set with the additional x^2, x^3, etc terms.
  #
  def polynomialize_features(features)
    features.collect do |feature|
      (1..@polynomial_degree).collect do |n|
        feature.map{ |f| f**n }
      end.flatten
    end
  end

  # Adds a the x^0 feature, which is the variable used to multiply the theta
  # value that represents the y-intercept in our curve or line equation.
  #
  # Params:
  #   features - The full feature set as an array of arrays.
  #
  # Returns:
  #     The augmented feature set with the additional x^0 term.
  #
  def add_zero_feature(features)
    features.map { |f| f.clone.unshift 1 }
  end

  # Runs one iteration of the batch-decend algorithm.
  #
  # Params:
  #   thetas   - the list of coefficients in our line formula that we're trying
  #              to optimize.
  #   features - an array of arrays, where each inner array contains the input
  #              values for one record in the training set.
  #   outputs  - an array of Floats, each of which is the output value of one
  #              record in the training set.
  # Returns:
  #   The updated array of thetas.
  #
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

  # Determines whether we should continue running the batch-decend algorithm, by
  # calculating wether the mean_squared_error of our newes thetas is decreasing
  # and/or has crossed the convergence_threshold.
  #
  # Params:
  #   new_thetas - the array of theta values from the most recent iteration of
  #                batch-decend.
  #   old_thetas - the array of theta valuse from the previous iteration of
  #                batch-decend.
  #   features   - an array of arrays where each inner array contains the input
  #                values for one record in the training set.
  #   outputs    - an array of Floats, where each element is the output value of
  #              one record in the training set.
  #
  # Returns:
  #   True, if the thetas are converging, but the mean_squared_error has not yet
  #   crossed the convergence threshold. False, if the mean_squared_error HAS
  #   crossed the convergence threshold. Raises an error if the thetas are
  #   diverging.
  #
  def continue? (new_thetas, old_thetas, features, outputs)
    old_thetas_mse = mean_squared_error(old_thetas, features, outputs)
    new_thetas_mse = mean_squared_error(new_thetas, features, outputs)
    change = old_thetas_mse - new_thetas_mse
    raise MeanSquaredErrorDivergenceError if change < 0
    change.abs > @convergence_threshold
  end

  # Calculates the partial derivative of the cost function. This essentially
  # tells us how much to adjust each theta in our current iteration of the
  # algorithm.
  #
  # Params:
  #   thetas       - the list of coefficients in our line formula that we're
  #                  trying to optimize.
  #   features_set - the full array of arrays containing the records and
  #                  features of our training set.
  #   outputs      - the array of outputs for each record in our training set.
  #   theta_index  - the index of the theta whose adjustment we're calculating.
  #
  # Returns:
  #   The Float value by which we must adjust the theta at theta_index in the
  #   current iteration of gradient-decent.
  #
  def partial_derivative(thetas, features_set, outputs, theta_index)
    terms = features_set.map.with_index do |features, i|
      (hypothesize(thetas, features) - outputs[i]) * features[theta_index]
    end
    terms.reduce(:+).to_f / features_set.size.to_f
  end

  # Calculates a number that represent how well our line/curve fits the dataset,
  # given the provided thetas.
  #
  # Params:
  #   thetas       - the list of coefficients in our line formula that we're
  #                  trying to optimize.
  #   features_set - the full array of arrays containing the records and
  #                  features of our training set.
  #   outputs      - the array of outputs for each record in our training set.
  #
  # Returns:
  #   A Float value representing the amount of error between our line and the
  #   points in our dataset.
  #
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

# MeanSquaredErrorDivergenceError
#
# A RuntimeError that describes a situation where the thetas in our calculation
# are diverging (based on mean_squared_error). This is an error, because
# diverging thetas mean that the algorithm will run forever.
#
class MeanSquaredErrorDivergenceError < RuntimeError
  def message
    """
    The Mean Squared Error is increasing, which means your thetas are diverging.
    Try using a smaller learning_rate (alpha).
    """
  end
end
