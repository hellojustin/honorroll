require 'spec_helper'
require 'honorroll/polynomial_regression'

describe HonorRoll::PolynomialRegression do

  describe 'when initialized' do

    describe 'with no parameters' do
      before do
        @pr = HonorRoll::PolynomialRegression.new
      end

      it 'should have a default learning rate' do
        @pr.learning_rate.must_equal 1.0e-20
      end
      it 'should have a default convergence threshold' do
        @pr.convergence_threshold.must_equal 1.0e-4
      end
      it 'should have a default polynomial degree' do
        @pr.polynomial_degree.must_equal 1
      end
      it 'should have a default log flag' do
        @pr.log.must_equal false
      end
    end

    describe 'with parameters' do
      before do
        @params = {
          learning_rate:         0.0001,
          convergence_threshold: 0.0001,
          polynomial_degree:     2,
          log_to_standard_out:   true
        }
        @pr = HonorRoll::PolynomialRegression.new @params
      end

      it 'should use the provided learning rate' do
        @pr.learning_rate.must_equal @params[:learning_rate]
      end
      it 'should use the provided convergence threshold' do
        @pr.convergence_threshold.must_equal @params[:convergence_threshold]
      end
      it 'should use the provided polynomial degree' do
        @pr.polynomial_degree.must_equal @params[:polynomial_degree]
      end
      it 'should use the provided log flag' do
        @pr.log.must_equal @params[:log_to_standard_out]
      end
    end

  end

  describe 'a univariate linear regression' do

    describe 'when trained on an almost linear dataset' do
      before do
        params = {
          learning_rate:         0.1,
          convergence_threshold: 1.0e-9
        }
        @pr       = HonorRoll::PolynomialRegression.new params
        @features = [[1], [2], [3], [4], [5]]
        @outputs  = [1.9, 4.1, 6.0, 7.8, 10.1]
        @pr.train @features, @outputs
      end

      it 'should keep track of how many iterations it took to converge' do
        @pr.iterations.must_be_kind_of Fixnum
      end
      it 'should predict training set values with relative accuracy' do
        @pr.predict( [1] ).must_be_within_epsilon 1.9, 0.05
        @pr.predict( [2] ).must_be_within_epsilon 4.1, 0.05
        @pr.predict( [3] ).must_be_within_epsilon 6.0, 0.05
        @pr.predict( [4] ).must_be_within_epsilon 7.8, 0.05
        @pr.predict( [5] ).must_be_within_epsilon 10.1, 0.05
      end
      it 'should predict new values' do
        @pr.predict( [6] ).must_be_kind_of Float
      end
    end

    describe 'when trained with a learning rate that is too high' do
      before do
        params = {
          learning_rate:         600,
          convergence_threshold: 1.0e-9
        }
        @pr       = HonorRoll::PolynomialRegression.new params
        @features = [[1], [2], [3], [4], [5]]
        @outputs  = [1.9, 4.1, 6.0, 7.8, 10.1]
      end

      it 'should raise a MeanSquaredErrorDivergenceError' do
        Proc.new {
            @pr.train(@features, @outputs)
        }.must_raise HonorRoll::MeanSquaredErrorDivergenceError
      end
    end
  end

  describe 'a multivariate linear regression' do
    before do
      params = {
        learning_rate:         0.04,
        convergence_threshold: 1.0e-5
      }
      @pr       = HonorRoll::PolynomialRegression.new params
      @features = [[1, 2], [2, 4], [3, 5], [4, 7.5], [5, 9]]
      @outputs  = [0.95, 2.025, 6.0, 7.8, 10.05]
      @pr.train @features, @outputs
    end

    it 'should keep track of how many iterations it took to converge' do
      @pr.iterations.must_be_kind_of Fixnum
    end
    it 'should predict training set values with relative accuracy' do
      @pr.predict( [1, 2] ).must_be_within_epsilon 0.95, 0.75
      @pr.predict( [2, 4] ).must_be_within_epsilon 2.025, 0.5
      @pr.predict( [3, 5] ).must_be_within_epsilon 6.0, 0.5
      @pr.predict( [4, 7.5] ).must_be_within_epsilon 7.8, 0.5
      @pr.predict( [5, 9] ).must_be_within_epsilon 10.05, 0.5
    end
    it 'should predict new values' do
      @pr.predict( [9, 18] ).must_be_within_epsilon 18, 0.5
    end
  end

  describe 'a univariate polynomial regression' do
    before do
      params = {
        learning_rate:         0.001,
        convergence_threshold: 1.0e-5,
        polynomial_degree:     2
      }
      @pr       = HonorRoll::PolynomialRegression.new params
      @features = [[1], [2], [3], [4], [5]]
      @outputs  = [0.95, 2.025, 6.0, 7.8, 10.05]
      @pr.train @features, @outputs
    end

    it 'should keep track of how many iterations it took to converge' do
      @pr.iterations.must_be_kind_of Fixnum
    end
    it 'should predict training set values with relative accuracy' do
      @pr.predict( [1] ).must_be_within_epsilon 0.95, 0.4
      @pr.predict( [2] ).must_be_within_epsilon 2.025, 0.4
      @pr.predict( [3] ).must_be_within_epsilon 6.0, 0.4
      @pr.predict( [4] ).must_be_within_epsilon 7.8, 0.4
      @pr.predict( [5] ).must_be_within_epsilon 10.05, 0.4
    end
    it 'should predict new values' do
      @pr.predict( [9] ).must_be_within_epsilon 34, 0.4
    end
  end

  describe 'a multivariate polynomial regression' do
    before do
      params = {
        learning_rate:         0.00001,
        convergence_threshold: 1.0e-4,
        polynomial_degree:     3
      }
      @pr       = HonorRoll::PolynomialRegression.new params
      @features = [[1, 2], [2, 4], [3, 5], [4, 7.5], [5, 9]]
      @outputs  = [0.95, 2.025, 6.0, 7.8, 10.05]
      @pr.train @features, @outputs
    end
    it 'should keep track of how many iterations it took to converge' do
      @pr.iterations.must_be_kind_of Fixnum
    end
    it 'should predict training set values with relative accuracy' do
      @pr.predict( [1, 2] ).must_be_within_epsilon 0.95, 0.5
      @pr.predict( [2, 4] ).must_be_within_epsilon 2.025, 0.5
      @pr.predict( [3, 5] ).must_be_within_epsilon 6.0, 0.5
      @pr.predict( [4, 7.5] ).must_be_within_epsilon 7.8, 0.5
      @pr.predict( [5, 9] ).must_be_within_epsilon 10.05, 0.5
    end
    it 'should predict new values' do
      @pr.predict( [9, 18] ).must_be_within_epsilon 1, 0.5
    end
  end

end
