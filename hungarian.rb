# Implementation of the Hungarian algorithm for weighted matching
# Big thanks to http://www.hungarianalgorithm.com/ for step-by-step

class Hungarian
	attr_reader :solved, :assignments

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
		@zeroes = { :row => Array.new, :column => Array.new }
		subtract_row_minima
		subtract_column_minima
		@assignments = assign

		sanity = 0
		sanity_max = 7
		while !@assignments[ :row ].count.eql? @grid.count and sanity < sanity_max
			puts " - - - New Iteration - - - "
			sanity += 1
			marked = mark
			puts "Marked Rows and Columns: " + marked.inspect
			smallest_unmarked = smallest_un(marked)
			subtract_from_un(marked, smallest_unmarked)
			add_to_doubly(marked, smallest_unmarked)
			puts "Grid after subtract and add: \n" + @grid.inspect
			@assignments = assign
			puts "Assigned Pairs: " + @assignments.inspect
		end
		if sanity >= sanity_max
			puts "Error! Hungarian algorithm did not converge in " + sanity.inspect + " iterations."
			exit
		end
		@solved = true

		puts "Grid \n" + @grid.inspect
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

		def collect_zeroes(r,c)
			if @grid[r][c] == 0 and !assigned?(r,c,@zeroes)
				@zeroes[ :row ].push( r )
				@zeroes[ :column ].push( c )
			end
		end

		def subtract_row_minima
			@grid.each_with_index do |row, r_idx|
				min = @global_max
				row.each do |val|
					if val < min then min = val end
				end
				row.each_with_index do |val, v_idx|
					@grid[r_idx][v_idx] = val - min
					collect_zeroes(r_idx,v_idx)
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
					collect_zeroes(r_idx,v_idx)
				end
			end
		end

		def assign
			r_assignments = Array.new # rows
			c_assignments = Array.new # columns
			# @grid.each_with_index do |row, r_idx|
			# 	row.each_with_index do |val, v_idx|
			# 		if 0 === val
			# 			if !r_assignments.include? r_idx and !c_assignments.include? v_idx
			# 				r_assignments.push(r_idx)
			# 				c_assignments.push(v_idx)
			# 			end
			# 		end
			# 	end
			# end
			puts "Zeroes \n" + @zeroes.inspect
			(@zeroes[ :row ].count - 1).downto(0).each do |idx|
				r = @zeroes[ :row ][idx]
				c = @zeroes[ :column ][idx]
				puts "At Index " + idx.inspect + ", Grid r c = " + @grid[r][c].inspect
				if @grid[r][c] == 0 and !r_assignments.include? r and !c_assignments.include? c
					r_assignments.push(r)
					c_assignments.push(c)
				end
			end
			return { :row => r_assignments, :column => c_assignments }
		end

		def mark
			unassigned_or_duplicate_rows = Array.new
			capturing_columns = Array.new
			visit_rows = Array(0..@grid.count - 1)
			visit_rows.each_with_index do |u_row, u_row_idx| # visit all rows
				if @assignments[ :row ].include? u_row and u_row_idx < @grid.count # skip if they are assigned
					next
				end
				if !unassigned_or_duplicate_rows.include? u_row
					unassigned_or_duplicate_rows.push(u_row)
				end
				@grid[u_row].each_with_index do |val, v_idx|
					if 0 === val and !capturing_columns.include? v_idx
						capturing_columns.push(v_idx) # capturing cols get zeroes from un_rows
						@grid.each_with_index do |row, r_idx|
							if assigned?(r_idx,v_idx) and !unassigned_or_duplicate_rows.include? r_idx
								unassigned_or_duplicate_rows.push(r_idx)
								visit_rows.push(r_idx)
							end
						end
					end
				end
			end
			puts "---> unassigned_or_duplicate_rows: " + unassigned_or_duplicate_rows.inspect
			capturing_rows = Array (0..@grid.count - 1) # invert this next
			capturing_rows = capturing_rows - unassigned_or_duplicate_rows
			return { :row => capturing_rows, :column => capturing_columns }
		end

		def assigned?(r,c,rc = @assignments)
			if rc[ :row ].include? r and rc[ :column ].include? c
				if rc[ :row ].index(r) == rc[ :column ].index(c)
					return true
				end
			end
			return false
		end

		def smallest_un(marked)
			min = @global_max
			@grid.each_with_index do |row, r_idx|
				if marked[ :row ].include? r_idx
					next
				end
				row.each_with_index do |val, v_idx|
					if marked[ :column ].include? v_idx
						next
					end
					if val < min then min = val end
				end
			end
			return min
		end

		def subtract_from_un(marked, smallest_unmarked)
			@grid.each_with_index do |row, r_idx|
				if marked[ :row ].include? r_idx
					next
				end
				row.each_with_index do |val, v_idx|
					if marked[ :column ].include? v_idx
						next
					end
					@grid[r_idx][v_idx] = @grid[r_idx][v_idx] - smallest_unmarked
					collect_zeroes(r_idx,v_idx)
				end
			end
		end

		def add_to_doubly(marked, smallest_unmarked)
			@grid.each_with_index do |row, r_idx|
				if !marked[ :row ].include? r_idx
					next
				end
				row.each_with_index do |val, v_idx|
					if !marked[ :column ].include? v_idx
						next
					end
					@grid[r_idx][v_idx] = @grid[r_idx][v_idx] + smallest_unmarked
				end
			end
		end
end