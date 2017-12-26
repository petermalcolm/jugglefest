# Implementation of the Hungarian algorithm for weighted matching

class Hungarian

	# grid must be a square array
	def initialize(grid, tie_breaker_grid, file_name)
		if grid.nil?
			@grid = ingest_file(file_name)
		else
			@grid = grid
		end

		unless tie_breaker_grid.nil?
			@tie_breaker_grid = tie_breaker_grid
		end

	end

	def ingest_file(file_name)
		grid = Array.new
		begin
			File.open(file_name).each do |line|
				grid.push(line.split)
			end
		rescue Exception => msg
			# display the system generated error message
			puts msg  
		end	
		return grid	
	end



end