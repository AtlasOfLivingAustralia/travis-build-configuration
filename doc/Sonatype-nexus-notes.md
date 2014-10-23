```BASH
# download and install JDK

# download and install sonatype nexus
wget -c http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz
sudo cp nexus-latest-bundle.tar.gz /usr/local
cd /usr/local
sudo tar -zxvf nexus-latest-bundle.tar.gz 
sudo ln -s nexus-2.9.1-02 nexus

# the sonatype nexus howto seems to be incorrect (resp. incomplete), you need a non-root user that can run nexus in /usr/local
chown -R nexususer:nexusgrp nexus-2.9.1-02
chown -R nexususer:nexusgrp sonatype-work

cd nexus/
./bin/nexus start #TODO: verify if this is correct, or if some chmod on /usr/local/nexus is REQUIRED

# PROBLEM:
# open port 8081
# install apache httpd and use apache running on port 80 to proxy to jetty/nexus running on port 8081
# use iptables to forward incoming HTTP (tcp) traffic to port 8081

# forward incoming traffic to port 80 to sonatype nexus port 8081
sudo iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j REDIRECT --to-ports 8081
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```
