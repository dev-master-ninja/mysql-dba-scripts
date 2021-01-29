# Configuring a Nagios Check


Custom checks for Nagios are quite easy to set up.
When a functional Nagios environment is installed, a new check can be easily deployed. 

## On the Client Server
On the target server create a (`bash`) script which returns an exit code in the range `0` to `3`. Where `0` is the equivalent of `Okay` and `3` being `Critical`:

```
0. Okay
1. Warning
2. Error
3. Critical
```

Every executable on Linux exits with a specific exit-status. 
In a `bash`-script this status code can be queried with `$?`: 

```bash
find . -name 'does-not-exist'
echo $?
```

This probably will result in an exit code of 1.

If the Nagios NRPE client is installed on the target system, the shell script can be created in the `/usr/lib/nagios/plugins` directory. 

In this example we use the `mysql_check` script, which contains the following source: 

```bash
#!/bin/bash
## Check Script:
/usr/bin/php /usr/lib/tools/check.php
EXIT=$?
exit $EXIT
```
This script executes a little `PHP` script to login to the local `mysql-server`: 

```php
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
```
In the Nagios config file, we need to specify the existence of the shell script: 

```bash
vi /etc/nagios/npre.cfg

command[mysql_check]=/usr/lib/nagios/plugins/mysql_check
```
Save the file and restart the Nagios NRPE client (On Ubuntu):
```bash
systemctl restart nagios-nrpe-server
```

## On the Main Nagios Server
We need to tell Nagios it has a specifc command to execute. This needs to be configured for your Nagios version. So the implementation can be different on the various platforms. 

In the general Commands File (`/usr/local/nagios/etc/objects/commands.cfg`):
```bash
define command{
   command_name     mysql_check
   command_line     $USER1$/check_npre -H $HOSTADDRESS -c mysql_check
}

where $USER1$ depends on the system config!!
```

In the config file for the monitored server: 
```bash
define service {
      use                     generic-service
      host_name               server-b.dba-training.online
      service_description     MySQL Check
      check_command           mysql_check
}
````

Verify the service works:
```bash
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
```

And restart the server: 
```bash
systemctl restart nagios
```