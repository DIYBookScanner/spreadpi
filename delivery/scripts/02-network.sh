cat <<EOM >/etc/network/if-pre-up.d/iptables
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.up.rules
EOM

chmod +x /etc/network/if-pre-up.d/iptables

cat <<EOM >/etc/iptables.up.rules
*nat
:PREROUTING ACCEPT [1:60]
:INPUT ACCEPT [1:60]
:OUTPUT ACCEPT [3:300]
:POSTROUTING ACCEPT [3:300]
-A PREROUTING -i eth0 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 5000
COMMIT
*filter
:INPUT ACCEPT [290:21584]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [200:20552]
COMMIT
EOM
