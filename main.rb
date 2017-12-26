
class JuggleFest

	def initialize()
		if ARGV.length < 1
		  puts "Too few arguments"
		  exit
		end
		ingest_file(ARGV[0])
	end

	def ingest_file(file_name)
		begin
			File.open(file_name).each do |line|
				puts line
			end
		rescue Exception => msg
			# display the system generated error message
			puts msg  
		end		
	end


end

JuggleFest.new