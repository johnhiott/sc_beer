<?php
/*
  Serve locations as json
*/

//TODO: changeable radius and limit

error_reporting(E_ALL);
ini_set('display_errors', 'on');

$lat = $_GET["lat"];
$lon = $_GET["lon"];


class Location{
    public $county = "";
    public $address  = "";
    public $license = "";
    public $name = "";
    public $lat = "";
    public $lon = "";
}

$HOST = 'localhost';
$PASSWORD = '';
$USERNAME = 'root';
$DATABASE = 'sundayfunday';

$locations = array();

try {
  $db = new PDO("mysql:host=$HOST;dbname=$DATABASE", $USERNAME, $PASSWORD);

  //Makes PDO throw exceptions for invalid SQL
  $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

} catch(Exception $ex){
    die($ex->getMessage());
}

$sql = "SELECT name, county, address, liscense, lat, lon,
        ( 3959 * acos( cos( radians(:lat) )
        * cos( radians( lat ) )
        * cos( radians( lon ) - radians(:lon) )
        + sin( radians(:lat) ) * sin( radians( lat ) ) ) )
        AS distance FROM Locations HAVING distance < 25 ORDER BY distance LIMIT 0 , 20";

$tagStmt = $db->prepare($sql);
$tagStmt->bindValue(":lat", $lat);
$tagStmt->bindValue(":lon", $lon);
$tagStmt->execute();

while($row = $tagStmt->fetch(PDO::FETCH_ASSOC)){
  $location = new Location();
  $location->name = $row['name'];
  $location->county = $row['county'];
  $location->address = $row['address'];
  $location->license = $row['liscense'];
  $location->lat = $row['lat'];
  $location->lon = $row['lon'];
  $locations[] = $location;
}

$results = json_encode($locations);

echo $results;
?>
