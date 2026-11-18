module("luci.controller.qwairah", package.seeall)

function index()
    entry({"admin", "qwairah"}, firstchild(), _("QWAIRAH"), 5).dependent = false
    entry({"admin", "qwairah", "quick"}, template("qwairah/quick"), _("البرمجة السريعة (WDS/Mesh/VLAN)"), 1)
    entry({"admin", "qwairah", "scan"}, template("qwairah/scan"), _("فحص القنوات والإشارة الأقوى"), 2)
    entry({"admin", "qwairah", "tools"}, template("qwairah/tools"), _("أدوات الشبكة (Ping & Speed)"), 3)
    entry({"admin", "qwairah", "telegram"}, cbi("qwairah_telegram"), _("إشعارات التيلجرام"), 4)
    entry({"admin", "qwairah", "action"}, call("action_handler"), nil).leaf = true
end

function action_handler()
    local http = require "luci.http"
    local sys = require "luci.sys"
    local act = http.formvalue("act")

    if act == "quick_apply" then
        local mode = http.formvalue("mode")
        local band = http.formvalue("band")
        local ssid = http.formvalue("ssid") or "QWAIRAH"
        local vlan_id = http.formvalue("vlan_id")
        local ipaddr = http.formvalue("ipaddr") or "192.168.1.1"

        sys.call("uci set network.lan.ipaddr='" .. ipaddr .. "'")
        if mode == "ap_wds" then
            sys.call("uci set wireless.default_" .. band .. ".mode='ap'")
            sys.call("uci set wireless.default_" .. band .. ".wds='1'")
            sys.call("uci set wireless.default_" .. band .. ".ssid='" .. ssid .. "'")
        elseif mode == "sta_wds" then
            sys.call("uci set wireless.default_" .. band .. ".mode='sta'")
            sys.call("uci set wireless.default_" .. band .. ".wds='1'")
            sys.call("uci set wireless.default_" .. band .. ".ssid='" .. ssid .. "'")
        elseif mode == "mesh" then
            sys.call("uci set wireless.default_" .. band .. ".mode='mesh'")
            sys.call("uci set wireless.default_" .. band .. ".mesh_id='" .. ssid .. "'")
        end

        if vlan_id and vlan_id ~= "" then
            sys.call("uci set network.vlan" .. vlan_id .. "=interface")
            sys.call("uci set network.vlan" .. vlan_id .. ".proto='none'")
            sys.call("uci set network.vlan" .. vlan_id .. ".device='br-lan." .. vlan_id .. "'")
        end
        sys.call("uci commit && /etc/init.d/network reload && wifi &")
        http.write("تم تطبيق البرمجة السريعة بنجاح! الآيبي الحالي: " .. ipaddr)
    elseif act == "scan" then
        local dev = http.formvalue("dev") or "radio0"
        local res = sys.exec("iwinfo " .. dev .. " scan | awk '/Cell|ESSID|Channel|Signal/ {print $0}'")
        http.write(res)
    elseif act == "ping" then
        local host = http.formvalue("host") or "1.1.1.1"
        local res = sys.exec("ping -c 4 " .. host)
        http.write(res)
    elseif act == "speed" then
        local res = sys.exec("curl -o /dev/null -s -w 'سرعة التحميل: %{speed_download} بايت/ثانية | زمن الاستجابة: %{time_total} ثانية\n' http://speedtest.tele2.net/1MB.zip")
        http.write(res)
    end
end
