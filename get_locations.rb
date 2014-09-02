#Get locations from South Carolina's tax website

require 'mysql'
require  'csv'
require 'open-uri'

#Fields we need
COUNTY = 0
ADDRESS = 6
NAME = 4
LISCENSE = 2
ID = 3

STORE_KEY = '7 DAY BEER/WINE OFF PREMISES CONSUMPTION'
RESTAURANT_KEY = 'LOCAL OPTION PERMIT'

begin

  puts "downloading database..."
  csv_file = open('http://167.7.210.151/ABLwebRPT/ABL_database.csv?956191B1-A6E9-D58D-7EEE-0DA9730A296A=1408978481930',
    "Referer" => "http://www.sctax.org/ABLwebRPT/ABL.swf",
    "Host" => "www.sctax.org")

  puts 'Done.'

  con = ::Mysql.new 'localhost', 'root', '', 'sundayfunday'

  con.autocommit false

  pst = con.prepare("CREATE TABLE IF NOT EXISTS Locations ( id INT, name VARCHAR(250),
    address VARCHAR(250), lat VARCHAR(50), lon VARCHAR(50), county VARCHAR(250),
    liscense VARCHAR(250), last_updated timestamp default current_timestamp on update current_timestamp, PRIMARY KEY (id) )
    ENGINE=InnoDB")
  pst.execute

  puts 'inserting into db...'
  count = 0
  CSV.foreach(csv_file, :col_sep => ",", :quote_char => "\x00") do |row|

    if row[LISCENSE] == RESTAURANT_KEY || row[LISCENSE] == STORE_KEY
      row[ADDRESS] ? address = con.escape_string( row[ADDRESS].gsub(/;/, ',') ) : address = ""
      row[LISCENSE] ? liscense = con.escape_string( row[LISCENSE] ) : liscense = ""
      row[NAME] ? name = con.escape_string( row[NAME] ) : name = ""
      row[COUNTY] ? county_name = con.escape_string( row[COUNTY] ) : county_name = ""
      id = con.escape_string( row[ID] )

      #ignore the insert if it exisit
      query = "INSERT IGNORE INTO Locations(id, county, address, name, liscense)
              VALUES('#{id}', '#{county_name}', '#{address}', '#{name}', '#{liscense}')"

      pst = con.prepare(query)
      pst.execute

    end
  end

  con.commit

  puts 'Done.'

rescue Mysql::Error => e
  puts e.errno
  puts e.error
ensure
  con.close if con
end
