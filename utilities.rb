class Utilities
	def median(array)
  		sorted = array.sort
  		len = sorted.length
		return (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
	end

        def is_float?(object)
            if (not object.include? "." or object.downcase.include? "e") #out of range check
                return false
            else
                return is_numeric?(object)
            end
        end

	def makeStats (arr)
		result=Hash.new
		result['sum']=arr.inject{ |s, el| s + el }.to_f
		result['avg']=result['sum']/arr.size
		result['median']=@@utils.median(arr)
		result['min']=arr.min
		result['max']=arr.max
		return result
	end

        def is_numeric?(object)
           	if object==nil
            	return false
            end
            true if Float(object) rescue false
        end

       	def stripper(str)
           if (str==nil)
               return ""
           end
           parts=str.split('&')
           s=""
           for param in parts do
               s=s+"->\t"+param+"\n"
           end
           return s
       	end

       	def printStrippedURL(url,fw)
			params=stripper(url[1])
            fw.puts "\n"+url[0]+" "
            if params!=""
                    fw.puts params
            else
                	fw.puts "----"
           	end
        end

        def makeDistrib_LaPr(adsDir)            # Calculate Latency and Price distribution
            countInstances("./","latency.out")        #latency
            system("awk \'{print $2\" \"$1}\' "+adsDir+"prices | sort -n | uniq -c | sort -n | tac > "+adsDir+"prices_cnt")
            system("awk \'{print $2\" \"$1}\' "+adsDir+"prices | sort -n | uniq > "+adsDir+"prices_uniq")
        end

	def printRow(row,fw)
		for key in row.keys
        	fw.puts key+" => "+row[key]
			if key=="url"
				printStrippedURL(row[key].split('?'),fw)
			end
     	end
        fw.puts "------------------------------------------------"
    end

	def countInstances(dir,att)
        system('sort -n '+dir+att+' | uniq > '+dir+att+"_uniq")
        system('sort -n '+dir+att+' | uniq -c | sort -n  |tac > '+dir+ att+"_cnt") #calculate distribution
	end	
end