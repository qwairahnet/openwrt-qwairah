#!/bin/sh
CONF="/etc/qwairah_tg.conf"
STATE_DIR="/tmp/qwairah_mon"
mkdir -p "$STATE_DIR"

sleep 20

while true; do
  [ -f "$CONF" ] && . "$CONF"
  if [ -n "$BOT_TOKEN" ] && [ -n "$CHAT_ID" ]; then
    if ! ip link show br-lan >/dev/null 2>&1; then
      /usr/bin/qwairah-tg-notify.sh hang "واجهة br-lan غير متاحة"
      sleep 30
      continue
    fi

    PING_OK=0
    if ping -c 3 -W 2 1.1.1.3 >/dev/null 2>&1; then
      PING_OK=1
    fi

    PREV_STATE=$(cat "$STATE_DIR/net_state" 2>/dev/null || echo "unknown")

    if [ "$PING_OK" -eq 1 ]; then
      echo "0" > "$STATE_DIR/fail_count"
      if [ "$PREV_STATE" = "down" ]; then
        /usr/bin/qwairah-tg-notify.sh recovered
      fi
      echo "up" > "$STATE_DIR/net_state"
    else
      FC=$(cat "$STATE_DIR/fail_count" 2>/dev/null || echo 0)
      FC=$((FC + 1))
      echo "$FC" > "$STATE_DIR/fail_count"
      if [ "$FC" -ge 2 ] && [ "$PREV_STATE" != "down" ]; then
        /usr/bin/qwairah-tg-notify.sh net_down "فحص بنج الانترنت 1.1.1.3"
        echo "down" > "$STATE_DIR/net_state"
      fi
    fi
  fi
  sleep 30
done
