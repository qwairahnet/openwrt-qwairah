module("luci.controller.qwairah", package.seeall)

function index()
entry({"admin", "qwairah"}, alias("admin", "qwairah", "tools"), _("QWAIRAH Control"), 10).dependent = false
entry({"admin", "qwairah", "tools"}, template("qwairah/tools"), _("أدوات وبرمجة QWAIRAH"), 1).leaf = true
entry({"admin", "qwairah", "speedtest"}, call("action_speedtest"), nil).leaf = true
entry({"admin", "qwairah", "scan"}, call("action_scan"), nil).leaf = true
entry({"admin", "qwairah", "save_tg"}, call("action_save_tg"), nil).leaf = true
end

function action_speedtest()
local handle = io.popen("iperf3 -c speedtest.tele2.net -p 5201 -R -t 5 2>&1 || ping -c 4 8.8.8.8")
local result = handle:read("*a")
handle:close()
luci.http.prepare_content("application/json")
luci.http.write_json({ result = result })
end

function action_scan()
local handle = io.popen("iwinfo wlan0 scan 2>/dev/null || iw dev wlan0 scan 2>/dev/null")
local result = handle:read("*a")
handle:close()
luci.http.prepare_content("application/json")
luci.http.write_json({ scan = result })
end

function action_save_tg()
local token = luci.http.formvalue("token")
local chat_id = luci.http.formvalue("chat_id")
os.execute("uci set qwairah.telegram=telegram")
os.execute("uci set qwairah.telegram.token='" .. token .. "'")
os.execute("uci set qwairah.telegram.chat_id='" .. chat_id .. "'")
os.execute("uci commit qwairah")
os.execute("/usr/bin/qwairah-telegram.sh 'تم ربط بوت التليجرام بنجاح!'")
luci.http.prepare_content("application/json")
luci.http.write_json({ status = "success" })
end
