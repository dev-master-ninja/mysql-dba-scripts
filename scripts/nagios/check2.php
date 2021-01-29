<?php

error_reporting(0);

$user = "admin";
$password = "admin";
$server = "127.0.0.1";

$connect = mysqli_connect($server, $user, $password);
$sql = "select user from mysql.user where user = 'admin'";
$result = mysqli_query($connect, $sql);

$row = mysqli_fetch_array($result, MYSQL_ASSOC);

echo $row["user"];