#!/bin/sh
CONF="/etc/qwairah_tg.conf"
STATE_DIR="/tmp/qwairah_mon"
[ -f "$CONF" ] && . "$CONF"
[ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ] && exit 1
mkdir -p "$STATE_DIR"

MODE="${1:-boot}"
DETAIL="${2:-}"
RAW_NODE="${NODE_NAME:-$(uci -q get system.@system[0].hostname || echo قويره-8)}"
MODEM_NAME=$(printf '%s' "$RAW_NODE" | sed 's/QWAIRAH/قويره/g')
MODEM_IP="$(ip -4 addr show br-lan 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)"
[ -z "$MODEM_IP" ] && MODEM_IP="$(uci -q get network.lan.ipaddr || echo '192.168.1.1')"

UP_SEC=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)
if [ "$UP_SEC" -ge 3600 ]; then
  UPTIME_STR="$((UP_SEC / 3600)) ساعة و $(((UP_SEC % 3600) / 60)) دقيقة"
elif [ "$UP_SEC" -ge 60 ]; then
  UPTIME_STR="$((UP_SEC / 60)) دقيقة و $((UP_SEC % 60)) ثانية"
else
  UPTIME_STR="${UP_SEC} ثانية"
fi

get_ping() {
  ping -c 3 -W 2 1.1.1.3 2>/dev/null | awk -F/ '/round-trip|rtt/ {print $5}' | sed 's/[^0-9.]//g' | head -n1
}

get_speed() {
  P2=$(ping -s 1200 -c 4 -W 2 1.1.1.3 2>/dev/null | awk -F/ '/round-trip|rtt/ {print $5}' | sed 's/[^0-9.]//g' | head -n1)
  if [ -n "$P2" ]; then
    awk -v ms="$P2" 'BEGIN {
      if (ms <= 0) ms = 50;
      est = (1200 * 8) / (ms * 1000);
      if (est < 1.0) est = 1.0;
      if (est > 100.0) est = 100.0;
      printf "%.2f ميجابت/ث", est;
    }'
    return 0
  fi
  echo "0.00 ميجابت/ث"
}

url_enc() {
  LC_ALL=C hexdump -v -e '/1 "%02X\n"' | awk '
    BEGIN {
      for (i = 0; i < 16; i++) h[sprintf("%X", i)] = i
      for (c = 32; c < 127; c++) ch[c] = sprintf("%c", c)
    }
    /^[0-9A-Fa-f]{2}$/ {
      u = toupper($0)
      b = h[substr(u, 1, 1)] * 16 + h[substr(u, 2, 1)]
      if ((b >= 48 && b <= 57) || (b >= 65 && b <= 90) || (b >= 97 && b <= 122) || b == 45 || b == 46 || b == 95 || b == 126) printf "%s", ch[b]
      else if (b == 32) printf "+"
      else printf "%%%s", u
    }
  '
}

send_msg() {
  TXT="$1"
  TOUT="${2:-12}"
  if command -v curl >/dev/null 2>&1; then
    curl -sSk --max-time "$TOUT" -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
      --data-urlencode "chat_id=${CHAT_ID}" \
      --data-urlencode "text=${TXT}"
    return $?
  fi
  ENC=$(printf '%s' "$TXT" | url_enc)
  URL="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${ENC}"
  if command -v uclient-fetch >/dev/null 2>&1; then
    uclient-fetch -T "$TOUT" -q -O - "$URL"
    return $?
  elif command -v wget >/dev/null 2>&1; then
    wget -T "$TOUT" -qO - "$URL"
    return $?
  fi
  echo "No HTTP client found" >&2
  return 1
}

case "$MODE" in
  shutdown)
    MSG=$(printf '🔴 تنبيه مودم مقطوع / شبكة قـويــره نت\nاسم المودم: %s\nالآيبي: %s\nالحالة: الجهاز في وضع الإطفاء أو إعادة التشغيل' "$MODEM_NAME" "$MODEM_IP")
    send_msg "$MSG" 5
    ;;
  net_down)
    MSG=$(printf '🔴 تنبيه مودم مقطوع / شبكة قـويــره نت\nاسم المودم: %s\nالآيبي: %s\nالحالة: انقطع الانترنت عنه وذلك بـ %s\nمدة التشغيل: %s' "$MODEM_NAME" "$MODEM_IP" "${DETAIL:-فحص بنج الانترنت 1.1.1.3 او فحص سرعة الانترنت}" "$UPTIME_STR")
    send_msg "$MSG" 8
    ;;
  hang)
    MSG=$(printf '🟠 تنبيه تعليق المودم / شبكة قـويــره نت\nاسم المودم: %s\nالآيبي: %s\nالحالة: يبدو أن الجهاز معلق أو غير مستجيب (%s)\nمدة التشغيل: %s' "$MODEM_NAME" "$MODEM_IP" "${DETAIL:-تأخر استجابة النظام}" "$UPTIME_STR")
    send_msg "$MSG" 8
    ;;
  test)
    P_AVG=$(get_ping)
    SPD=$(get_speed)
    MSG=$(printf '🟢 تقرير تشغيل المودم — شبكة قـويــره نت\nاسم المودم: %s\nالآيبي: %s\nالبينج (1.1.1.3): %s مللي ثانية\nسرعة الانترنت: %s\nمدة التشغيل: %s' "$MODEM_NAME" "$MODEM_IP" "${P_AVG:-انتهت المهلة}" "$SPD" "$UPTIME_STR")
    send_msg "$MSG" 15
    ;;
  *)
    i=0; P_AVG=""
    while [ $i -lt 20 ]; do
      P_AVG=$(get_ping)
      [ -n "$P_AVG" ] && break
      sleep 3; i=$((i + 1))
    done
    if [ -n "$P_AVG" ]; then
      SPD=$(get_speed)
      echo "up" > "$STATE_DIR/net_state"
      HEAD="🟢 تقرير تشغيل المودم — شبكة قـويــره نت"
      [ "$MODE" = "recovered" ] && HEAD="🟢 عودة واستقرار الإنترنت — شبكة قـويــره نت"
      MSG=$(printf '%s\nاسم المودم: %s\nالآيبي: %s\nالبينج (1.1.1.3): %s مللي ثانية\nسرعة الانترنت: %s\nمدة التشغيل: %s' "$HEAD" "$MODEM_NAME" "$MODEM_IP" "$P_AVG" "$SPD" "$UPTIME_STR")
      send_msg "$MSG" 15
    else
      echo "down" > "$STATE_DIR/net_state"
      MSG=$(printf '🔴 تنبيه مودم مقطوع / شبكة قـويــره نت\nاسم المودم: %s\nالآيبي: %s\nالحالة: انقطع الانترنت عنه وذلك بفحص بنج الانترنت 1.1.1.3 او فحص سرعة الانترنت\nمدة التشغيل: %s' "$MODEM_NAME" "$MODEM_IP" "$UPTIME_STR")
      send_msg "$MSG" 10
    fi
    ;;
esac
