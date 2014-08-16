cat <<EOM >/boot/config.txt
core_freq=500
sdram_freq=600
over_voltage=6
arm_freq=1000
EOM

cat <<EOM >/etc/rc.local
#!/bin/sh
echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
exit 0
EOM
