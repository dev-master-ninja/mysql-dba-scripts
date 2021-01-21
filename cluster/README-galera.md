# Install Galera Cluster Manager

Information: https://galeracluster.com/

## Step by Step installation guide (platform independent)

### Disabling SELinux for mysqld
If SELinux (Security-Enhanced Linux) is enabled on the servers, it may block `mysqld` from performing required operations. You must either disable SELinux for `mysqld` or configure it to allow `mysqld` to run external programs and open listen sockets on unprivileged ports—that is, operations that an unprivileged user may do.
To disable SELinux for `mysqld`, execute the following from the command-line: 
```
# semanage permissive -a mysqld_t
```