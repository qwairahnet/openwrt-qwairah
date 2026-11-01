#!/bin/sh
TOKEN=$(uci -q get qwairah.telegram.token)
CHAT_ID=$(uci -q get qwairah.telegram.chat_id)
[ -z "$TOKEN" ] || [ -z "$CHAT_ID" ] && exit 0

EVENT="$1"
WAN_IP=$(ip addr show dev eth1 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
[ -z "$WAN_IP" ] && WAN_IP="غير متصل"
LAN_IP=$(uci -q get network.lan.ipaddr)
UPTIME=$(uptime | awk -F'uptime ' '{print $2}' | awk -F',' '{print $1}')
CLIENTS=$(cat /proc/net/arp | wc -l)

MSG="🚀 *QWAIRAH ISP - شبكة قويره نت*%0A"
MSG="${MSG}📌 *الحدث:* ${EVENT}%0A"
MSG="${MSG}📡 *آيبي LAN:* ${LAN_IP}%0A"
MSG="${MSG}🌐 *آيبي WAN:* ${WAN_IP}%0A"
MSG="${MSG}👥 *المتصلون:* ${CLIENTS} أجهزة%0A"
MSG="${MSG}⏱️ *مدة التشغيل:* ${UPTIME}"

curl -s -k "https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MSG}&parse_mode=Markdown" >/dev/null 2>&1
