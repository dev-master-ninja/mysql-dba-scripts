<?php
/* 
 * Script: /usr/lib/tools/check.php
 */
error_reporting(0);

$user = "admin";
$password = "bad-password";
$server = "127.0.0.1";

if(!mysqli_connect($server, $user, $password)){
  echo "Kan geen verbinding maken!\n";
  exit(3);
} else {
  exit(0);
}