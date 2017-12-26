# Implementation of the Hungarian algorithm for weighted matching
# Big thanks to http://www.hungarianalgorithm.com/ for step-by-step

class Hungarian
	attr_reader :solved

	# grid must be a square array
	def initialize(grid, tie_breaker_grid, file_name)
		@solved = false

		if grid.nil?
			@grid = ingest_file(file_name)
		else
			@grid = grid
		end

		unless tie_breaker_grid.nil?
			@tie_breaker_grid = tie_breaker_grid
		end

		# make a clone for later
		copy = grid_clone

		# do the algorithm:
		@global_max = invert
		subtract_row_minima
		subtract_column_minima
		evaluate

		puts "Grid \n" + @grid.inspect
		# puts "Copy \n" + copy.inspect
	end

	protected

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

		def grid_clone # deep clone
			copy = Array.new
			@grid.each do |row|
				if row.count != @grid.count # sanity check
					puts "Error. Input data is not square"
					exit
				end
				temp_row = Array.new
				row.each do |val|
					temp_row.push(val.to_i)
				end
				copy.push(temp_row)
			end
			return copy
		end

		# invert the sign of the grid, then add max
		def invert
			max = 0
			@grid.each_with_index do |row, r_idx|
				row.each_with_index do |val, v_idx|
					if val.to_i > max then max = val.to_i end
					@grid[r_idx][v_idx] = -val.to_i
				end
			end
			@grid.each_with_index do |row, r_idx|
				row.each_with_index do |val, v_idx|
					@grid[r_idx][v_idx] = val + max
				end
			end
			return max
		end

		def subtract_row_minima
			@grid.each_with_index do |row, r_idx|
				min = @global_max
				row.each do |val|
					if val < min then min = val end
				end
				row.each_with_index do |val, v_idx|
					@grid[r_idx][v_idx] = val - min
				end
			end
		end

		def subtract_column_minima
			@grid[0].each_with_index do |val, v_idx|
				min = @global_max
				@grid.each do |row|
					if row[v_idx] < min then min = row[v_idx] end
				end
				@grid.each_with_index do |row, r_idx|
					@grid[r_idx][v_idx] = row[v_idx] - min
				end
			end
		end

		def evaluate
		end

		def break_ties
		end

end