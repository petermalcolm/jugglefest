require './hungarian.rb'

class JuggleFest

	def initialize()
		if ARGV.length < 1
		  puts "Too few arguments - provide a file"
		  exit
		end
		if "H" === ARGV[0]
			if ARGV.length < 2
			  puts "Too few arguments - provide a hungarian grid file"
			  exit
			end
			hungarian = Hungarian.new(nil,nil,ARGV[1])
			puts "Hungarian algorithm solved it? " + hungarian.solved.inspect
			puts "Here are the assignments: " + hungarian.assignments.inspect
			exit
		end
		@circuits = Hash.new
		@jugglers = Hash.new
		ingest_file(ARGV[0])
		puts "Circuits: \n" + @circuits.inspect
		puts "Jugglers: \n" + @jugglers.inspect
		dot_product = calculate_dot_product
		puts "Dot Product: \n" + dot_product.inspect
	end

	def ingest_file(file_name)
		begin
			File.open(file_name).each do |line|
				parse_line(line)
			end
		rescue Exception => msg
			# display the system generated error message
			puts msg  
		end		
	end

	def parse_line(line)
		line = line.split
		if line.empty? or ( line[0] != 'C' and line[0] != 'J' )
			return
		end
		if 'C' === line[0]
			temp = Hash.new
			for idx in 2..(line.count - 1)
				pair = line[idx].split(':')
				temp[pair[0]] = pair[1]
			end
			@circuits[line[1]] = temp
		elsif 'J' === line[0]
			temp = Hash.new
			for idx in 2..(line.count - 1)
				if line[idx].include? ":"
					pair = line[idx].split(':')
					temp[pair[0]] = pair[1]
				else # must be preferences
					temp['prefs'] = line[idx].split(',')
				end
			end
			@jugglers[line[1]] = temp
		end
	end

	def calculate_dot_product
		dot_product = Array.new
		@jugglers.each do |juggler|
			dp_row = Array.new
			@circuits.each do |circuit_name,circuit_val|
				dp = 0
				# puts circuit.inspect
				# exit
				# dp_row.push( circuit.inject(0) do { |dp,circuit_val| 
				# 	dp + circuit_val.to_i *  juggler[].to_i
				# } )
				circuit_val.each do |key,val| 
					puts "\nkey: " + key.inspect
					puts "\nval: " + val.inspect
					dp += val.to_i * juggler[1][key].to_i 
				end
				dp_row.push( dp )
			end
			dot_product.push( dp_row )
		end
		return dot_product
	end

end

JuggleFest.new