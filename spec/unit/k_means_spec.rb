require 'spec_helper'
require 'honorroll/k_means'
require 'honorroll/point'

describe HonorRoll::KMeans do

  describe 'when initialized' do

    describe 'with no parameters' do
      before do
        @kmeans = HonorRoll::KMeans.new
      end

      it 'should have an empty array of points' do
        @kmeans.points.must_equal []
      end
      it 'should have nil clusters' do
        @kmeans.clusters.must_be_nil
      end
    end

    describe 'with a set of points' do
      before do
        @points = [ [0.1, 0.1], [0.1, 0.15], [0.15, 0.1], [0.15, 0.15],
                    [0.5, 0.5], [0.5, 0.55], [0.55, 0.5], [0.55, 0.55],
                    [0.9, 0.9], [0.9, 0.95], [0.95, 0.9], [0.95, 0.95] ]
        @kmeans = HonorRoll::KMeans.new(points: @points)
      end

      it 'should have an array of Point objects based on coords past to #new' do
        @kmeans.points.each_with_index do |p, i|
          p.must_be_instance_of HonorRoll::Point
          p.coords.must_equal @points[i]
        end
      end
      it 'should have nil clusters' do
        @kmeans.clusters.must_be_nil
      end
    end

  end

  describe 'when asked to identify clusters, starting w/ specific centroids' do
    before do
      @points = [ [0.1, 0.1], [0.1, 0.15], [0.15, 0.1], [0.15, 0.15],
                  [0.5, 0.5], [0.5, 0.55], [0.55, 0.5], [0.55, 0.55],
                  [0.9, 0.9], [0.9, 0.95], [0.95, 0.9], [0.95, 0.95] ]
      @kmeans = HonorRoll::KMeans.new(points: @points)
      @kmeans.identify_clusters 3, [[0.0, 0.0], [0.4, 0.45], [0.85, 0.85]]
    end

    it 'should have three clusters' do
      @kmeans.clusters.count.must_equal 3
    end
    it 'should capture the first four points in one of the clusters' do
      points = @points[0..3]
      @kmeans.clusters.any? do |c|
        c.points.map{ |p| p.coords } == points
      end.must_equal true
    end
    it 'should capture the second four points in one of the clusters' do
      points = @points[4..7]
      @kmeans.clusters.any? do |c|
        c.points.map{ |p| p.coords } == points
      end.must_equal true
    end
    it 'should capture the third four points in one of the clusters' do
      points = @points[8..11]
      @kmeans.clusters.any? do |c|
        c.points.map{ |p| p.coords } == points
      end.must_equal true
    end
  end

  describe 'when asked to indentify clusters, starting w/ random centroids' do
    before do
      @points = [ [0.1, 0.1], [0.1, 0.15], [0.15, 0.1], [0.15, 0.15],
                  [0.5, 0.5], [0.5, 0.55], [0.55, 0.5], [0.55, 0.55],
                  [0.9, 0.9], [0.9, 0.95], [0.95, 0.9], [0.95, 0.95] ]
      @kmeans = HonorRoll::KMeans.new(points: @points)
      @kmeans.identify_clusters 4
    end

    it 'should have four clusters' do
      @kmeans.clusters.count.must_equal 4
    end
  end

end
