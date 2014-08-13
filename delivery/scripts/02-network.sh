cat <<EOM >/etc/network/if-pre-up.d/iptables
/sbin/iptables-restore < /etc/iptables.up.rules
EOM

chmod +x /etc/network/if-pre-up.d/iptables

cat <<EOM >/etc/iptables.up.rules
-A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 5000
EOM
