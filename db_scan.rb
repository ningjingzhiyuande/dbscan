####################################################
# shiguodong, June 2011
# References:
#   1. see also wikipedia entry (this implementation is similar to
#      their pseudo code): http://en.wikipedia.org/wiki/DBSCAN
####################################################
module DbScan
	def self.included(base)
		base.extend(ClassMethods)
	end
	module ClassMethods
		def dbscan(points, epsilon=0.05, min_pts=2)
			@points,@epsilon,@min_pts = points,epsilon,min_pts
			init_point
			_dbscan
		end
		def init_point
			return @points if (!@points.is_a? Array) or (@points.size<2)
			@new_points = []
			@points.each_with_index{|point,i|@new_points.push(Point.new(point))}
		end

		def _dbscan
			clusters = {}     
			clusters[-1] = []
			current_cluster = -1
			for point in @new_points
				if not point.visited
					point.visited = true
					neighbours = immediate_neighbours(point)
					if neighbours.size >= @min_pts
						current_cluster += 1
						point.cluster = current_cluster                
						cluster = [point,]
						cluster.push(add_connected(neighbours,current_cluster))
						clusters[current_cluster] = cluster.flatten
					else
						clusters[-1].push(point)
					end
				end
			end 
			return as_list(clusters)
		end

		def as_list(clusters)
			hash = {}
			clusters.each do |key,value|
				 hash[key]=value.flatten.map(&:items) if !value.flatten.empty?
			end
			hash
		end
		def immediate_neighbours(point)
			neighbours = []
			@new_points.each do |p|
				next	if p.items == point.items
				d = distance(point.items,p.items)
				neighbours.push(p) if d < @epsilon
			end
			return neighbours
		end
		def distance(p1,p2)
			raise "Error" if p1.size != p2.size
			sum = 0
			(0...p1.size).each{|i| sum+=(p1[i]-p2[i])**2}
			Math.sqrt(sum)
		end
		def add_connected(neighbours,current_cluster)
			cluster_points = []
			neighbours.each do  |point|
				if not point.visited
					point.visited = true 
					new_points = immediate_neighbours(point)
					new_points.each do |p|
						if  not (neighbours.include? p)
							neighbours.push(p) 
						end
					end  if new_points.size >= @min_pts 
				end

				if !point.cluster
					cluster_points.push(point)
					point.cluster = current_cluster
				end
			end
			return cluster_points
		end

	end
end

class Point
	attr_accessor :items,:cluster,:visited
	def initialize(point)
		self.items = point
		self.cluster = nil
		self.visited = false
	end
end
