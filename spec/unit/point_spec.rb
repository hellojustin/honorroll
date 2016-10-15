require 'spec_helper'
require 'honorroll/point'

describe HonorRoll::Point do

  describe 'when initialized' do

    describe 'with no parameters' do
      before do
        @point         = HonorRoll::Point.new
        @another_point = HonorRoll::Point.new [1, 1]
      end

      it 'should have a default coordinates equal to the origin in 2D space' do
        @point.coords.must_equal [0.0,0.0]
      end
      it 'should be able to tell us its dimensional space' do
        @point.dimensions.must_equal 2
      end
      it 'should be able to tell us its euclidean distance to another point' do
        @point.euclidean_distance_to(@another_point).must_equal 1.4142135623730951
      end
    end

    describe 'with a coords parameter' do
      before do
        @point           = HonorRoll::Point.new [3.4, 4.4, 7.1, 8.0]
        @another_point   = HonorRoll::Point.new [0.0, 1.2, 3.1, 4.7]
        @diff_dimensions = HonorRoll::Point.new [0.0, 1.2, 3.1]
      end

      it 'should have the coordinates passed to #new' do
        @point.coords.must_equal [3.4, 4.4, 7.1, 8.0]
      end
      it 'should be able to tell us its dimensional space' do
        @point.dimensions.must_equal 4
      end
      it 'should be able to tell us its euclidean distance to another point' do
        @point.euclidean_distance_to(@another_point).must_equal 6.977822009767804
      end
      it '''should raise an error if asked to calculate distance to a point in
            different dimensions''' do
        Proc.new {
            @point.euclidean_distance_to(@diff_dimensions)
        }.must_raise HonorRoll::IncompatibleDimensionsError
      end
    end

    describe 'as a random point' do
      before do
        @dimension_bounds = [0..1, 2..20, -5..0]
        @point            = HonorRoll::Point.random_point @dimension_bounds
      end

      it 'should have dimensionality equal to the count of dimensional bounds' do
        @point.dimensions.must_equal @dimension_bounds.count
      end
      it 'should have coordinates within the bounds for each dimension' do
        @dimension_bounds.each_with_index do |bound, i|
          bound.must_be :cover?, @point.coords[i]
        end
      end
    end

  end

end
