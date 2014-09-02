#get lat, lon of the locations from Google's geocoding API

require 'mysql'
require 'net/http'
require 'json'
require 'pp'

begin

  API_KEY = ENV['GOOGLE_SIMPLE_API_WEB']

  con = ::Mysql.new 'localhost', 'root', '', 'sundayfunday'

  #keys for query
  ADDRESS = 1
  ID = 0
  ids = con.query("Select id, address FROM Locations WHERE Lat IS NULL")

  count = 0

  ids.each do |id|

    puts id[0]
    count = count + 1
    address = id[1]

    uri = URI('https://maps.googleapis.com/maps/api/geocode/json')
    params = { :address => address, :key => API_KEY }

    uri.query = URI.encode_www_form(params)
    results = Net::HTTP.get_response(uri)

    parsed = JSON.parse(results.body) # returns a hash
    if parsed["status"] == "OK"
      lat = parsed["results"][0]["geometry"]["location"]["lat"]
      lon = parsed["results"][0]["geometry"]["location"]["lng"]
      con.query( "UPDATE Locations SET lat=#{lat}, lon=#{lon} WHERE id = '#{id[0]}' " )
    end

    #sleep 1 if count % 3 == 0

  end

rescue Mysql::Error => e
  puts e.errno
  puts e.error
ensure
  con.close if con
end
