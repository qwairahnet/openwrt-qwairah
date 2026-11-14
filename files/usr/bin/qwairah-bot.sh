#!/bin/sh
CONF="/etc/config/qwairah_bot"
[ ! -f "$CONF" ] && exit 0
. "$CONF"
[ -z "$TOKEN" ] || [ -z "$CHAT_ID" ] && exit 0

API="https://api.telegram.org/bot$TOKEN"
send_msg() {
    curl -s -X POST "$API/sendMessage" -d chat_id="$CHAT_ID" -d text="$1" >/dev/null
}

IP=$(uci get network.lan.ipaddr 2>/dev/null || echo "192.168.1.1")
send_msg "✅ تم تشغيل نظام QWAIRAH بنجاح | IP: $IP"

LAST_ID=0
while true; do
    UPDATES=$(curl -s "$API/getUpdates?offset=$((LAST_ID+1))&timeout=10")
    MSG_ID=$(echo "$UPDATES" | jq -r '.result[-1].update_id // empty')
    if [ -n "$MSG_ID" ]; then
        LAST_ID=$MSG_ID
        TEXT=$(echo "$UPDATES" | jq -r '.result[-1].message.text // empty')
        case "$TEXT" in
            "/status")
                UP=$(uptime)
                MEM=$(free -m | awk '/Mem:/ {print $3"/"$2"MB"}')
                CLIENTS=$(iw dev 2>/dev/null | grep Interface | awk '{print $2}' | xargs -I {} iw dev {} station dump 2>/dev/null | grep -c Station)
                send_msg "📊 حالة QWAIRAH:\n⏱ التشغيل: $UP\n🧠 الرام: $MEM\n📱 المتصلين: $CLIENTS"
                ;;
            "/reboot")
                send_msg "🔄 جاري إعادة تشغيل الجهاز عن بُعد..."
                reboot
                ;;
            "/clients")
                LIST=$(cat /tmp/dhcp.leases 2>/dev/null | awk '{print "📱 "$4" | IP: "$3" | MAC: "$2}')
                [ -z "$LIST" ] && LIST="لا يوجد أجهزة مسجلة حالياً"
                send_msg "📋 قائمة المتصلين:\n$LIST"
                ;;
        esac
    fi
    sleep 5
done
