```BASH
# download and install JDK (sonatype nexus is a java app running in java jetty webcontainer)

# download and install sonatype nexus
wget -c http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz
sudo cp nexus-latest-bundle.tar.gz /usr/local
cd /usr/local
sudo tar -zxvf nexus-latest-bundle.tar.gz 
sudo ln -s nexus-2.9.1-02 nexus

# the sonatype nexus howto seems to be incorrect (resp. incomplete), you need a non-root user that can run nexus in /usr/local
sudo adduser --home /usr/local/nexus --disabled-login --disabled-password nexus
chown -R nexus:nexus nexus
chown -R nexus:nexus sonatype-work

# WARNING: make sure the directory sonatype-work is on a partitions with enough free space for your maven repository!

# verify if we are up and running (for now in manual mode)
sudo su nexus
cd nexus/
./bin/nexus start
./bin/nexus status
./bin/nexus stop

# make sonatype nexus start automatically on the system startup, this is distro specific, here is what i did for ubuntu:
hor22n@ala-wonder:~$ cat /etc/*rel*     
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=14.04
DISTRIB_CODENAME=trusty
DISTRIB_DESCRIPTION="Ubuntu 14.04.1 LTS"
NAME="Ubuntu"
VERSION="14.04.1 LTS, Trusty Tahr"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 14.04.1 LTS"
VERSION_ID="14.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"

# copy the nexus script or create a symbolic link to /etc/init.d/nexus
ln -s /usr/local/nexus/bin/nexus /etc/init.d/nexus

# set the NEXUS_HOME="/usr/local/nexus" and RUN_AS_USER=nexus in /etc/init.d/nexus

# run update-rc.d:
sudo update-rc.d nexus defaults

# from now on nexus should automatically start on the system startup

# sonatype nexus runs by default in jetty container and listens on (unprivileged) port 8081, normally you want to make your
# maven repo accessible over port 80, you can either install apache to listen on port 80 and proxy to jetty/sonatype nexus on
# port 8081, or simply forward incoming connection to port 80 to port 8081. to do this on ubuntu i added the port forwarding
# to /etc/rc.local:
hor22n@ala-wonder:~$ sudo cat /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

/sbin/iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j REDIRECT --to-ports 8081
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

exit 0

# on this ubuntu box /etc/rc.local gets executed by /etc/init.d/rc.local script, so after you restart the machine,
# sonata nexus (served by jetty) should be now accessible through port 8081, and default HTTP port 80.

```
