require 'csv'
require 'pp'

###

src = "./source"
#colname = "change"

###

## change = CSV.read(f, headers: true)[colname]

def parser f
  # you need to parse them as contribs by date
  datapairs = []
  if File.exists? f
    CSV.foreach(f) do |row|
      if row.is_a? Array
        if row[2].to_f>0
          contrib = 1
        elsif row[2].to_f<=0
          contrib = -1
        end
        unless row[0].include? "Date"
          datapairs.push [row[0], contrib]
        end
      end
    end
  end
  # ==== data checked
  return datapairs
end#parser

def timeseries changes
 dates = []
 series = {}
 dailies = []
 changes[0].each do |i|
   # find the "date" entry and push contrib
   dates.push i[0]
 end
 dates.reverse!
 #pp dates
 #pp changes
 dates.each do |d|
  series[d] = []
  changes.each do |sa| #subarray - single coins contribs
    sa.each do |i| #elements in subarray
      if i.include? d
        series[d].push i[1]
      end
    end
   end
   dailies.push series[d].inject(0){|sum,x| sum + x }
 end
 # check crude ADL contribs sanity
 dailies.each do |crude|
   if crude.to_f > 30
     puts "BOGUS DATA WARNING  - crude ADL contribution returned value over 30 on an index of 30 constituents!"
   end
 end


 # export
 adls = adl dailies
 data = dates.zip adls
 export data
 # ==== the result
 return adls
end

def adl dailies
  adl_series = [0]
  adl = 0
  dailies.each do |i|
    i = i.to_f
    #puts "i #{i}, old adl #{adl}"
    adl = adl + i
    #puts "new adl #{adl}"
    adl_series.push adl
  end
  # ==== data checked
  return adl_series
end

def export data
  # pp data
  # need to add header maybe
  CSV.open( "./log/cci30_adl_#{Date.today}.csv", "w+") do |csv|
    data.each do |newline|
      csv << newline
    end
  end
end

def wrapper src
  changes = []
  adl_series = []
  Dir.glob("#{src}/*.csv").each do |f|
    name = File.basename(f, '.csv')
    changes.push parser f
  end
  timeseries changes
end

##################################

wrapper src
