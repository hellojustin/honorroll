require 'spec_helper'
require 'honorroll/cluster'
require 'honorroll/point'

describe HonorRoll::Cluster do

  describe 'when initialized' do

    describe 'with no parameters' do
      before do
        @cluster = HonorRoll::Cluster.new
      end

      it 'should have an empty array of points' do
        @cluster.points.must_equal []
      end
      it 'should have a size of 0' do
        @cluster.size.must_equal 0
      end
      it 'should have a nil centroid' do
        @cluster.centroid.must_be_nil
      end
      it 'should have a dimensionality of nil' do
        @cluster.dimensionality.must_be_nil
      end
    end

    describe 'with a centroid' do
      before do
        @centroid = HonorRoll::Point.new [0,1]
        @cluster  = HonorRoll::Cluster.new( centroid: @centroid )
      end

      it 'should have an empty array of points' do
        @cluster.points.must_equal []
      end
      it 'should have a size of 0' do
        @cluster.size.must_equal 0
      end
      it 'should have the same centroid that was passed to #new' do
        @cluster.centroid.must_equal @centroid
      end
      it 'should have a dimensionality of nil' do
        @cluster.dimensionality.must_be_nil
      end
    end

    describe 'with a points array' do
      before do
        @points  = [HonorRoll::Point.new([0,0]), HonorRoll::Point.new([0,1]),
                    HonorRoll::Point.new([1,0]), HonorRoll::Point.new([1,1])]
        @cluster = HonorRoll::Cluster.new( points: @points )
      end

      it 'should have the same array of points passed to #new' do
        @cluster.points.must_equal @points
      end
      it 'should have a size of 4' do
        @cluster.size.must_equal 4
      end
      it 'should have a nil centroid' do
        @cluster.centroid.must_be_nil
      end
      it 'should have a dimensionality of 2' do
        @cluster.dimensionality.must_equal 2
      end

      describe 'and asked to determine its centroid' do
        before do
          @centroid = @cluster.centroid_from_points!
        end

        it 'should return the centroid as a Point object' do
          @centroid.must_be_instance_of HonorRoll::Point
        end
        it 'should return the expected centroid' do
          @centroid.coords.must_equal [0.5, 0.5]
        end
        it 'should update the centroid property of the cluster' do
          @cluster.centroid.must_equal @centroid
        end
      end

      describe 'and asked to determine its dimensional ranges' do
        before do
          @ranges = @cluster.dimensional_ranges
        end

        it 'should return an array of ranges' do
          @ranges.each { |range| range.must_be_instance_of Range }
        end
        it '''should return ranges that cover all coordinates in their
              respective dimension''' do
          points = @cluster.points.map &:coords
          points.transpose.each_with_index do |coords, i|
            @ranges[i].min.must_equal coords.min
            @ranges[i].max.must_equal coords.max
          end
        end
      end
    end

  end

end
