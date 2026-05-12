#!/bin/bash

TIMEOUT=300  # ۵ دقیقه
LAST_ACTIVITY=$(date +%s)

echo "✅ Idle Monitor فعال شد. در صورت عدم فعالیت به مدت ۵ دقیقه، کداسپیس متوقف می‌شود."

# خواندن توکن از فایل (اگر وجود داشته باشد)
TOKEN_FILE="$HOME/.gh_token"
if [ -f "$TOKEN_FILE" ]; then
    GH_TOKEN=$(cat "$TOKEN_FILE")
    echo "🔑 توکن برای توقف خودکار یافت شد."
else
    echo "⚠️ هشدار: توکن یافت نشد. امکان توقف خودکار وجود ندارد."
    GH_TOKEN=""
fi

while true; do
  ACTIVE_CONN=$(netstat -tn 2>/dev/null | grep -E ':(443|8080).*ESTABLISHED' | wc -l)

  if [ "$ACTIVE_CONN" -gt 0 ]; then
    LAST_ACTIVITY=$(date +%s)
  else
    NOW=$(date +%s)
    IDLE_TIME=$((NOW - LAST_ACTIVITY))
    if [ "$IDLE_TIME" -ge "$TIMEOUT" ]; then
      echo "❌ هیچ فعالیتی برای ۵ دقیقه وجود نداشت. در حال توقف کداسپیس..."
      if [ -n "$GH_TOKEN" ]; then
        # استفاده از API گیت‌هاب برای توقف کداسپیس
        curl -L -X POST -H "Authorization: Bearer $GH_TOKEN" \
          -H "Accept: application/vnd.github+json" \
          https://api.github.com/user/codespaces/$CODESPACE_NAME/stop
        echo "✅ کداسپیس متوقف شد."
      else
        echo "⚠️ توکن در دسترس نیست. لطفاً به صورت دستی کداسپیس را متوقف کنید."
      fi
      break
    fi
  fi
  sleep 30
done
