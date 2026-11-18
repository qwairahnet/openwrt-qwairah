module("luci.controller.qwairah_telegram", package.seeall)
function index()
    entry({"admin", "services", "qwairah_telegram"}, cbi("qwairah_telegram"), _("Telegram Bot (QWAIRAH)"), 60).dependent = false
end
