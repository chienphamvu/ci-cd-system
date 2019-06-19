<?php
function OpenCon()
{
    $dbhost = "192.168.1.2";
    $dbuser = "root";
    $dbpass = "root";
    $db = "mysql";
    $conn = new mysqli($dbhost, $dbuser, $dbpass,$db) or die("Connect failed: %s\n". $conn -> error);

    return $conn;
}
 
function CloseCon($conn)
{
    $conn -> close();
}

?>