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


end

JuggleFest.new