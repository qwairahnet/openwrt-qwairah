m = Map("qwairah_bot", "إعدادات بوت التليجرام - شبكة قويره نت", "أدخل توكن البوت والآي دي لتلقي الإشعارات الفورية.")
s = m:section(TypedSection, "settings", "بيانات البوت")
s.anonymous = true
t = s:option(Value, "token", "Telegram Bot Token")
t.rmempty = true
c = s:option(Value, "chat_id", "Telegram Chat ID")
c.rmempty = true
return m
