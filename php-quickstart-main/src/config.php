<?php
// Basic connection settings
$databaseHost = "192.168.9.31";
$databaseUsername = "root";
$databasePassword = "";
$databaseName = 'rolodex';

// Connect to the database
$mysqli = mysqli_connect($databaseHost, $databaseUsername, $databasePassword, $databaseName); 
?>
