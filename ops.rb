require 'digest/sha1'
require 'utilities'
require 'core'

#IP_Port--UserIP--URL--UserAgent--Host--Timestamp--ResponseCode--ContentLength--DeliveredData--Duration--HitOrMiss

class Operations
	@@func=Core.new

	def load(filename)
		puts "> Creating Directories..."
		Dir.mkdir @@dataDir unless File.exists?(@@dataDir)
        Dir.mkdir @@adsDir unless File.exists?(@@adsDir)
		puts "> Loading Trace..."
		@totalNumofRows=@@func.loadTrace(filename)
		puts "\t"+@totalNumofRows.to_s+" requests have been loaded successfully!"
	end

    def separate()
        for key in @totalNumofRows[0].keys() do
            @@func.separateField(key,@@dataDir)
   		end
	end

	def clearAll()
        system('rm -rf '+@@dataDir)
        system('rm -rf '+@@adsDir)
		system('rm -f *.out')
	end

  	def stripURL()      
		puts "> Stripping parameters, detecting and classifying Third-Party content..."
		adsTypes=nil
		fi,fa,fl,fp,fn,fd1,fb,fm,fz,fd2=Utilities.openFiles
		for r in @totalNumofRows do
			@@func.parseRequest(r,fa,fl,fi,fp,fn,fd1,fb,fz,fd2,fb)
		end
		trace=@@func.getTrace
		parseResults(trace)
	end

	def parseResults(trace)
		puts "> Calculating Statistics about detected ads..."
		totalNumofRows=trace.rows.size		
		paramsStats,sizeStats,sums=@trace.analyzeTotalAds()
		#LATENCY
	#	lat=@@func.getLatency
	#	avgL=lat.inject{ |sum, el| sum + el }.to_f / lat.size
	#	Utilities.makeDistrib_LaPr(@@adsDir)

		#DETECTED ADS
	#	totalAds,adsTypes,filterTypes,adBeacon=@@func.getAdResults

		#PRICES
        numericPrices=Array.new
        for p in prices do
            if Utilities.is_float?(p)
                numericPrices.push(p)
            end
        end
		pricesStats=makeStats(numericPrices)
        Utilities.countInstances(@@adsDir,@@beaconT)

		#PRINTING RESULTS		
		puts "Printing Results...\nTRACE STATS\n------------"
		puts "Traffic from  mobile devices: "+trace.mobDev.to_s+"/"+totalNumofRows.to_s
		puts "3rd Party content detected:\n"
#		filterTypes.each { |key,value| print key+" => "+value.to_s+" "}
		puts "\nSize of the unnecessary 3rd Party content (i.e. Adverising+Analytics+Social)\nTotal: "+sizeStats['sum'].to_s+" Bytes - Average: "+sizeStats['avg'].to_s+" Bytes"
		puts "Total Ads-related requests found: "+sums['numOfAds'].to_s+"/"+totalNumofRows.to_s
		puts "Ad-related traffic using mobile devices: "+sums['numOfadMobile'].to_s+"/"+sums['numOfAds'].to_s
		puts "Number of parameters:\nmax => "+paramsStats['max'.to_s+" min=>"+paramsStats['min'].to_s+" avg=>"+paramsStats['avg'].to_s+" median=>"+paramsStats['median'].to_s
        puts "Price tags found: "+prices.length.to_s
        puts numericPrices.size.to_s+"/"+prices.size.to_s+" are actually numeric values"
        puts "Average price "+pricesStats['avg'].to_s

		puts "Beacons found: "+sums['numOfBeacons'].to_s+"\nAds-related beacons: "+sums['numOfAdBeacons'].to_s+"/"+sums['numOfBeacons'].to_s
        puts "Impressions detected "+sums['numOfImps'].to_s
        puts "Average latency "+avgL.to_s

		puts "PER USER STATS"
		puts "TODO"
	#	puts adsTypes
	
		#PLOTING CDFs
		puts "Creating CDFs..."
		puts "TODO... Devices, Prices, NumOfParameters,popular ad-related hosts,3rdParty Size"
		@@func.close
	end

	def findStrInRows(str,printable)
		count=0
		found=Array.new
		puts "Locating String..."
		rows=@@func.getRows
		for r in rows do
			for val in r.values do
				if val.include? str
					count+=1
					if(printable)
						url=r['url'].split('?')
						Utilities.printRow(r,STDOUT)
					end
					found.push(r)					
					break
				end
			end
		end 
		if(printable)
			puts count.to_s+" Results were found!"
		end
		return found
	end
end
