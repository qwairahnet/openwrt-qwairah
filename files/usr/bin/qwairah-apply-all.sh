#!/bin/sh
DEFAULT_BOT_TOKEN="7905762136:AAF1BeNXsjLnvOcxdv7e9PHK_CRoy06qBVE"
DEFAULT_CHAT_ID="1017548476"
DEFAULT_NODE_NAME="${QW_NODE_NAME:-$(uci -q get system.@system[0].hostname || echo قويره)}"

mkdir -p /www/luci-static/bootstrap/css /www/luci-static/resources/view/qwairah /usr/share/rpcd/acl.d /tmp/qwairah_mon

if [ ! -f /etc/qwairah_tg.conf ]; then
cat << EOF > /etc/qwairah_tg.conf
BOT_TOKEN="${DEFAULT_BOT_TOKEN}"
CHAT_ID="${DEFAULT_CHAT_ID}"
NODE_NAME="${DEFAULT_NODE_NAME}"
EOF
else
  . /etc/qwairah_tg.conf
  [ -z "$BOT_TOKEN" ] && BOT_TOKEN="$DEFAULT_BOT_TOKEN"
  [ -z "$CHAT_ID" ] && CHAT_ID="$DEFAULT_CHAT_ID"
  [ -z "$NODE_NAME" ] && NODE_NAME="$DEFAULT_NODE_NAME"
cat << EOF > /etc/qwairah_tg.conf
BOT_TOKEN="${BOT_TOKEN}"
CHAT_ID="${CHAT_ID}"
NODE_NAME="${NODE_NAME}"
EOF
fi
chmod 600 /etc/qwairah_tg.conf

cat << 'EOF' > /www/luci-static/resources/qwairah_custom.css
:root{--qw-bg:#031412;--qw-card:#072420;--qw-dark:#021a16;--qw-g1:#047857;--qw-g2:#10b981;--qw-y1:#eab308;--qw-y2:#fef08a;--qw-txt:#f8fafc}
body,html{background:radial-gradient(circle at top right,#064e3b 0%,var(--qw-bg) 65%)!important;color:var(--qw-txt)!important;overflow-x:hidden!important}
header,.navbar,.topbar,.main>header{background:linear-gradient(90deg,#022c22,#065f46,#022c22)!important;border-bottom:2px solid var(--qw-y1)!important}
.brand::before{content:"";display:inline-block;width:24px;height:24px;background:url("/luci-static/resources/qwairah_logo.jpg") center/cover no-repeat;border-radius:50%;border:1.5px solid var(--qw-y2);margin-right:7px;vertical-align:middle}
.brand{color:var(--qw-y2)!important;font-weight:900!important}

#topmenu,#topmenu>li,#topmenu>li>a,.nav,.nav>li,.nav>li>a,.sidebar,.sidebar ul,.sidebar li,.sidebar a,.menu,.menu ul,.menu li,.menu a,aside,aside ul,aside li,aside a{
  background-color:#022c22!important;
  color:#ffffff!important;
  font-weight:700!important;
}
#topmenu>li>a:hover,#topmenu>li.open>a,#topmenu>li.active>a,.nav>li.active>a,.nav>li.open>a,.sidebar li.active>a,.sidebar li.open>a{
  background:linear-gradient(90deg,var(--qw-y2),var(--qw-y1))!important;
  color:#022c22!important;
}

#topmenu>li.open>.dropdown-menu,#topmenu>li.dropdown:hover>.dropdown-menu,
#topmenu>li.open>ul,#topmenu>li.active>ul,
.nav>li.open>ul,.nav>li.active>ul,.nav>li>.dropdown-menu,
.sidebar .open>ul,.sidebar .active>ul,.sidebar ul.open,ul.dropdown-menu.show{
  display:block!important;
  visibility:visible!important;
  opacity:1!important;
  position:static!important;
  float:none!important;
  background:#072420!important;
  border:1px solid var(--qw-y1)!important;
  border-radius:6px!important;
  margin:4px 0 8px 6px!important;
  padding:4px 0!important;
  height:auto!important;
  max-height:none!important;
}
#topmenu .dropdown-menu>li>a,#topmenu ul>li>a,.nav ul>li>a,.sidebar ul>li>a,aside ul>li>a{
  color:var(--qw-y2)!important;
  background:#072420!important;
  font-weight:700!important;
  padding:8px 12px!important;
  display:block!important;
}
#topmenu .dropdown-menu>li>a:hover,#topmenu ul>li>a:hover,.nav ul>li>a:hover,.sidebar ul>li>a:hover,aside ul>li>a:hover{
  background:var(--qw-g1)!important;
  color:#ffffff!important;
}

.main>.container,.cbi-map,.cbi-section,.panel,.table-overview,.cbi-value,.cbi-modal,.cbi-modal>div,.modal,.modal-content,.modal-header,.modal-body,.modal-footer,.cbi-tabmenu,.cbi-tabmenu>li,.nav-tabs,.nav-tabs>li,table,thead,tbody,tr,th,td,.table,.tr,.th,.td,.cbi-page-actions,.cbi-map-actions,div.cbi-page-actions>*{
  background:var(--qw-card)!important;
  color:var(--qw-txt)!important;
  border-color:rgba(234,179,8,.45)!important;
}
.cbi-value-field,.cbi-value-description,.cbi-section-descr,.cbi-map-descr{
  background:transparent!important;
  color:#f1f5f9!important;
}
input[type="text"],input[type="password"],input[type="number"],select,textarea,.cbi-input-text,.cbi-input-select,.cbi-dropdown,.cbi-dropdown>ul,.cbi-dropdown>ul>li{
  background:var(--qw-dark)!important;
  color:#ffffff!important;
  border:1px solid rgba(234,179,8,.65)!important;
}
h1,h2,h3,legend,.cbi-section-table-descr,label,.cbi-value-title{
  color:var(--qw-y2)!important;
  font-weight:700!important;
}
.btn,button,.cbi-button,input[type="submit"],input[type="button"]{
  background:linear-gradient(135deg,var(--qw-g2),var(--qw-g1))!important;
  border:1px solid var(--qw-y1)!important;
  color:#ffffff!important;
  font-weight:800!important;
  border-radius:6px!important;
}
.btn:hover,button:hover,.cbi-button:hover{
  background:linear-gradient(135deg,var(--qw-y2),var(--qw-y1))!important;
  color:#022c22!important;
}
pre,#qw-scan-out,#qw-tools-out,#qw-tg-out,#qw-ram-box,#qw-ports-box,#qw-overview-ports-pre{
  background:var(--qw-dark)!important;
  color:var(--qw-y2)!important;
  border:1px solid var(--qw-y1)!important;
  border-radius:6px!important;
  padding:10px!important;
  min-height:80px;
  white-space:pre-wrap;
}
footer,.footer{text-align:center;padding:12px;border-top:2px solid var(--qw-y1);background:#022c22!important}
footer a,.footer a,a[href*="github.com/openwrt"],a[href*="luci"],.luci-credits{display:none!important}
footer::after,.footer::after{content:"QWAIRAH NET SYSTEM";display:block;color:var(--qw-y2);font-weight:800}

@media (max-width:768px){
  body{padding-left:0!important}
  header{flex-wrap:wrap!important}
  #topmenu{width:100%!important;float:none!important;display:flex!important;flex-direction:column!important;gap:4px!important;margin:6px 0!important}
  #topmenu>li{float:none!important;width:100%!important}
  .main,#maincontent,.container,.container-fluid{width:100%!important;max-width:100%!important;margin-left:0!important;padding-left:8px!important;padding-right:8px!important}
}
EOF
cp -f /www/luci-static/resources/qwairah_custom.css /www/luci-static/bootstrap/css/qwairah_custom.css

cat << 'EOF' > /usr/share/luci/menu.d/luci-app-qwairah.json
{
  "admin/qwairah": {"title": "QWAIRAH", "order": 15, "action": {"type": "firstchild"}},
  "admin/qwairah/quicksetup": {"title": "Quick Setup", "order": 1, "action": {"type": "view", "path": "qwairah/quicksetup"}},
  "admin/qwairah/tools": {"title": "Ping & Speed", "order": 2, "action": {"type": "view", "path": "qwairah/tools"}},
  "admin/qwairah/telegram": {"title": "Telegram Bot", "order": 3, "action": {"type": "view", "path": "qwairah/telegram"}}
}
EOF

cat << 'EOF' > /usr/share/rpcd/acl.d/luci-app-qwairah.json
{
  "luci-app-qwairah": {
    "description": "QWAIRAH permissions",
    "read": {
      "file": {
        "/etc/qwairah_tg.conf": ["read"],
        "/proc/meminfo": ["read"],
        "/sys/class/net": ["list", "read"],
        "/sys/class/net/*": ["list", "read"],
        "/sys/class/net/*/operstate": ["read"],
        "/sys/class/net/*/speed": ["read"],
        "/sys/class/net/*/duplex": ["read"]
      },
      "uci": ["system", "luci", "network", "wireless"]
    },
    "write": {
      "file": {
        "/etc/qwairah_tg.conf": ["write"]
      },
      "exec": {
        "/bin/sh": ["exec"],
        "/bin/ping": ["exec"],
        "/usr/bin/curl": ["exec"],
        "/usr/bin/qwairah-tg-notify.sh": ["exec"],
        "/usr/bin/qwairah-tg-watch.sh": ["exec"],
        "/etc/init.d/qwairah-tg": ["exec"]
      },
      "uci": ["system", "luci", "network", "wireless"]
    }
  }
}
EOF

cat << 'EOF' > /www/luci-static/resources/view/qwairah/quicksetup.js
'use strict';
'require view';'require form';'require uci';'require fs';

function portLabel(n){
  if(n==='lan1')return 'LAN 1';
  if(n==='lan2')return 'LAN 2';
  if(n==='lan3')return 'LAN 3';
  if(n==='lan4')return 'LAN 4';
  if(n==='eth0')return 'LAN / Port 1 (eth0)';
  if(n==='eth1')return 'WAN / Port 2 (eth1)';
  if(n==='wan')return 'WAN (wan)';
  if(n==='br-lan')return 'Bridge LAN (br-lan)';
  return n;
}

function cableDesc(s,st){
  var n=parseInt(s,10);
  if(st==='down'||isNaN(n)||n<=0){
    return (st==='up')?'مرتبط (سرعة غير محددة — احتمال عطل كابل/منفذ)':'غير مرتبط / مفصول (بدون كابل)';
  }
  if(n>=1000)return 'كابل 1 جيجابت/ث ('+n+' Mbps) — سليم';
  if(n>=100)return 'كابل 100 ميجابت/ث ('+n+' Mbps) — تنبيه: أقل من 1 جيجا (تحقق من الكابل إذا كان يدعم 1G)';
  return 'كابل 10 ميجابت/ث ('+n+' Mbps) — تحذير: سرعة ضعيفة / احتمال عطل كابل أو منفذ';
}

return view.extend({
  load:function(){
    return Promise.all([
      uci.load('system'),
      fs.read('/proc/meminfo').catch(function(){return '';}),
      fs.list('/sys/class/net').catch(function(){return [];})
    ]);
  },
  render:function(d){
    var m=d[1]||'',t=0,a=0,f=0;
    m.split(/\r?\n/).forEach(function(l){var x;if((x=l.match(/^MemTotal:\s+(\d+)\s+kB/)))t=+x[1];if((x=l.match(/^MemAvailable:\s+(\d+)\s+kB/)))a=+x[1];if((x=l.match(/^MemFree:\s+(\d+)\s+kB/)))f=+x[1];});
    var ramPre=E('pre',{id:'qw-ram-box',style:'direction:rtl;text-align:right;unicode-bidi:plaintext;'},'الإجمالي: '+(t/1024).toFixed(2)+' MiB | المستخدم: '+Math.max(0,(t-a)/1024).toFixed(2)+' MiB ('+(t?(((t-a)/t)*100).toFixed(1):'0.0')+'%) | المتاح: '+(a/1024).toFixed(2)+' MiB (Free: '+(f/1024).toFixed(2)+' MiB)');
    var portPre=E('pre',{id:'qw-ports-box',style:'direction:rtl;text-align:right;unicode-bidi:plaintext;'},'جاري فحص منافذ LAN والكوابل...');

    var map=new form.Map('system',_('QWAIRAH Quick Setup'));
    var sec=map.section(form.TypedSection,'system',_('Node Settings'));sec.anonymous=true;sec.addremove=false;
    sec.option(form.Value,'hostname',_('Hostname')).datatype='hostname';
    sec.option(form.Value,'notes',_('Node Note')).optional=true;
    sec.option(form.Value,'zonename',_('Timezone')).placeholder='Asia/Aden';
    sec.option(form.Value,'timezone',_('TZ String')).placeholder='<+03>-3';

    var present={};
    (d[2]||[]).forEach(function(it){if(it&&it.name)present[it.name]=true;});
    var fixed=['lan1','lan2','lan3','lan4','eth0','eth1','wan','br-lan'];
    var extra=Object.keys(present).filter(function(k){
      return fixed.indexOf(k)===-1 && /^(lan\d+|eth\d+|wan\d*)$/.test(k);
    }).sort();
    var portsList=fixed.concat(extra);

    return map.render().then(function(el){
      el.appendChild(E('div',{class:'cbi-section',style:'direction:rtl;text-align:right;'},[E('h3',{},'Ports & Cable Speed'),portPre]));
      el.appendChild(E('div',{class:'cbi-section',style:'direction:rtl;text-align:right;'},[E('h3',{},'RAM Status'),ramPre]));
      Promise.all(portsList.map(function(n){
        if(!present[n]){
          return Promise.resolve('⚪ '+portLabel(n)+' ['+n+']: غير متوفر في هذا الجهاز');
        }
        return Promise.all([
          fs.read('/sys/class/net/'+n+'/operstate').catch(function(){return 'unknown';}),
          fs.read('/sys/class/net/'+n+'/speed').catch(function(){return '';}),
          fs.read('/sys/class/net/'+n+'/duplex').catch(function(){return '';})
        ]).then(function(v){
          var st=(v[0]||'unknown').trim();
          var sp=(v[1]||'').trim();
          var dp=(v[2]||'').trim();
          var ic=(st==='up')?'🟢':'🔴';
          var dupTxt=(dp&&st==='up')?' | Duplex: '+dp:'';
          return ic+' '+portLabel(n)+' ['+n+']: الحالة = '+st+' | الكابل = '+cableDesc(sp,st)+dupTxt;
        });
      })).then(function(lines){portPre.textContent=lines.join('\n');});
      return el;
    });
  }
});
EOF

cat << 'EOF' > /www/luci-static/resources/view/qwairah/tools.js
'use strict';
'require view';'require fs';'require ui';
return view.extend({
  render:function(){
    var inp=E('input',{id:'qw-host',type:'text',value:'1.1.1.3',placeholder:'1.1.1.3 or 192.168.5.1'});
    var out=E('pre',{id:'qw-tools-out'},_('اختر Ping أو Local Speed.'));
    var pBtn=E('button',{class:'btn cbi-button-apply',click:function(){
      var h=(inp.value||'1.1.1.3').trim().replace(/[^a-zA-Z0-9.-]/g,'')||'1.1.1.3';
      out.textContent='جاري البينج إلى '+h+'...';
      return fs.exec('/bin/ping',['-c','4','-W','2',h]).then(function(r){out.textContent=((r.stdout||'')+(r.stderr||'')).trim()||'تم.';}).catch(function(e){ui.addNotification(null,E('p',e.message));});
    }},_('Ping (4x)'));
    var sBtn=E('button',{class:'btn cbi-button-action',style:'margin-left:8px;',click:function(){
      out.textContent='جاري قياس السرعة المحلية...';
      var t0=performance.now();
      return fetch('/luci-static/resources/ui.js?t='+Date.now(),{cache:'no-store'}).then(function(r){return r.blob();}).then(function(b){
        var sec=Math.max((performance.now()-t0)/1000,0.001);
        out.textContent='الحجم: '+(b.size/(1024*1024)).toFixed(3)+' MB\nالزمن: '+sec.toFixed(3)+' s\nالسرعة: '+(b.size/(1024*1024)/sec).toFixed(2)+' MB/s';
      });
    }},_('Local Speed'));
    return E('div',{class:'cbi-map'},[E('h2',{},_('QWAIRAH Ping & Speed')),E('div',{class:'cbi-section'},[E('div',{class:'cbi-value'},[E('label',{class:'cbi-value-title'},_('Target Host')),E('div',{class:'cbi-value-field'},inp)]),E('p',{},[pBtn,sBtn]),out])]);
  },
  handleSaveApply:null,handleSave:null,handleReset:null
});
EOF

cat << 'EOF' > /www/luci-static/resources/view/qwairah/telegram.js
'use strict';
'require view';'require fs';'require ui';

function parseConf(t){
  var c={BOT_TOKEN:'7905762136:AAF1BeNXsjLnvOcxdv7e9PHK_CRoy06qBVE',CHAT_ID:'1017548476',NODE_NAME:'قويره'};
  (t||'').split(/\r?\n/).forEach(function(l){
    var m=l.match(/^\s*([A-Z0-9_]+)\s*=\s*"?(.*?)"?\s*$/);
    if(m)c[m[1]]=m[2];
  });
  return c;
}

function buildConf(tokInp, chatInp, nodeInp){
  var tok=(tokInp.value||'').trim();
  var cid=(chatInp.value||'').trim();
  var nod=(nodeInp.value||'').trim()||'قويره';
  return 'BOT_TOKEN="'+tok+'"\nCHAT_ID="'+cid+'"\nNODE_NAME="'+nod+'"\n';
}

function runNotifyTest(out){
  return fs.exec('/usr/bin/qwairah-tg-notify.sh',['test']).catch(function(){
    return fs.exec('/bin/sh',['/usr/bin/qwairah-tg-notify.sh','test']);
  }).then(function(r){
    var res=(((r&&r.stdout)||'')+((r&&r.stderr)||'')).trim();
    if(res.indexOf('"ok":true')!==-1){
      out.textContent='تم إرسال التقرير إلى البوت بنجاح.';
      ui.addNotification(null,E('p','تم إرسال التقرير إلى البوت بنجاح.'),'info');
    } else {
      out.textContent=res||(r&&r.code===0?'تم إرسال التقرير إلى البوت.':'تعذر الإرسال (رمز الخروج: '+(r?r.code:'?')+')');
    }
  });
}

return view.extend({
  load:function(){
    return fs.read('/etc/qwairah_tg.conf').catch(function(){
      return 'BOT_TOKEN="7905762136:AAF1BeNXsjLnvOcxdv7e9PHK_CRoy06qBVE"\nCHAT_ID="1017548476"\nNODE_NAME="قويره"\n';
    });
  },
  render:function(txt){
    var c=parseConf(txt);
    var tokInp=E('input',{
      id:'qw-tg-token',
      type:'text',
      dir:'ltr',
      value:c.BOT_TOKEN||'',
      placeholder:'7905762136:AAF1BeNXsjLnvOcxdv7e9PHK_CRoy06qBVE',
      style:'width:100%;box-sizing:border-box;font-family:monospace;direction:ltr;text-align:left;unicode-bidi:bidi-override;'
    });
    var chatInp=E('input',{
      id:'qw-tg-chatid',
      type:'text',
      dir:'ltr',
      value:c.CHAT_ID||'',
      placeholder:'1017548476',
      style:'width:100%;box-sizing:border-box;font-family:monospace;direction:ltr;text-align:left;'
    });
    var nodeInp=E('input',{
      id:'qw-tg-node',
      type:'text',
      dir:'rtl',
      value:c.NODE_NAME||'قويره',
      placeholder:'قويره',
      style:'width:100%;box-sizing:border-box;direction:rtl;text-align:right;'
    });

    var out=E('pre',{id:'qw-tg-out',dir:'rtl',style:'direction:rtl;text-align:right;unicode-bidi:plaintext;'},'يمكنك تعديل التوكن أو الآي دي أو اسم المودم ثم الضغط على حفظ المعلومات أو إرسال التقرير.');

    var saveB=E('button',{class:'btn cbi-button-save',click:function(){
      var content=buildConf(tokInp,chatInp,nodeInp);
      return fs.write('/etc/qwairah_tg.conf',content).then(function(){
        out.textContent='تم حفظ المعلومات بنجاح.';
        ui.addNotification(null,E('p','تم حفظ المعلومات بنجاح.'),'info');
      }).catch(function(e){
        out.textContent='تعذر الحفظ: '+(e&&e.message?e.message:String(e));
      });
    }},'حفظ المعلومات');

    var testB=E('button',{class:'btn cbi-button-apply',style:'margin-right:8px;',click:function(){
      var tok=(tokInp.value||'').trim();
      var cid=(chatInp.value||'').trim();
      if(!tok||!cid){
        out.textContent='يرجى إدخال توكن بوت التيليجرام وآي دي التيليجرام أولاً.';
        return;
      }
      var content=buildConf(tokInp,chatInp,nodeInp);
      out.textContent='جاري حفظ المعلومات وإرسال التقرير إلى البوت...';
      return fs.write('/etc/qwairah_tg.conf',content).then(function(){
        return runNotifyTest(out);
      }).catch(function(e){
        out.textContent='تعذر الإرسال: '+(e&&e.message?e.message:String(e));
      });
    }},'ارسال الئ البوت التقرير');

    return E('div',{class:'cbi-map',dir:'rtl',style:'direction:rtl;text-align:right;'},[
      E('h2',{style:'direction:rtl;text-align:right;'},'إعدادات بوت التيليجرام'),
      E('div',{class:'cbi-section',style:'direction:rtl;text-align:right;'},[
        E('div',{class:'cbi-value'},[
          E('label',{class:'cbi-value-title',for:'qw-tg-token',style:'direction:rtl;text-align:right;'},'توكن بوت التيليجرام'),
          E('div',{class:'cbi-value-field',style:'direction:ltr;text-align:left;'},tokInp)
        ]),
        E('div',{class:'cbi-value'},[
          E('label',{class:'cbi-value-title',for:'qw-tg-chatid',style:'direction:rtl;text-align:right;'},'آي دي التيليجرام'),
          E('div',{class:'cbi-value-field',style:'direction:ltr;text-align:left;'},chatInp)
        ]),
        E('div',{class:'cbi-value'},[
          E('label',{class:'cbi-value-title',for:'qw-tg-node',style:'direction:rtl;text-align:right;'},'اسم المودم'),
          E('div',{class:'cbi-value-field',style:'direction:rtl;text-align:right;'},nodeInp)
        ]),
        E('p',{style:'margin-top:12px;direction:rtl;text-align:right;'},[saveB,testB]),
        out
      ])
    ]);
  },
  handleSaveApply:null,handleSave:null,handleReset:null
});
EOF

cat << 'EOF' > /www/luci-static/resources/qwairah_menu_toggle.js
(function(){
  if (!document.getElementById("qw-injected-css")) {
    var lk = document.createElement("link");
    lk.id = "qw-injected-css";
    lk.rel = "stylesheet";
    lk.href = "/luci-static/resources/qwairah_custom.css?v=" + Date.now();
    (document.head || document.documentElement).appendChild(lk);
  }

  function fixWhiteSurfaces(){
    document.querySelectorAll("*").forEach(function(el){
      if (el === document.body || el === document.documentElement) return;
      var r = el.getBoundingClientRect();
      if (r.width <= 0 || r.height <= 0) return;
      var cs = getComputedStyle(el);
      var bg = cs.backgroundColor;
      var isWhite = (bg === "rgb(255, 255, 255)" || bg === "rgba(255, 255, 255, 1)");
      var inNav = !!el.closest("aside, nav, .sidebar, .menu, .nav, #topmenu, .drawer, .offcanvas");
      if (isWhite && (inNav || r.width < window.innerWidth * 0.9)) {
        el.style.setProperty("background-color", inNav ? "#022c22" : "#072420", "important");
        var fg = cs.color;
        if (fg === "rgb(255, 255, 255)" || fg === "rgba(255, 255, 255, 1)" || fg === "rgb(254, 240, 138)") {
          el.style.setProperty("color", inNav ? "#ffffff" : "#fef08a", "important");
        }
      }
    });
  }

  document.addEventListener("click", function(e){
    setTimeout(fixWhiteSurfaces, 40);
    setTimeout(fixWhiteSurfaces, 180);
    var a = e.target.closest("a");
    if (!a) return;
    var li = a.parentElement;
    if (!li) return;
    var sub = li.querySelector(":scope > ul, :scope > .dropdown-menu, :scope > .nav, :scope > .submenu");
    if (!sub) return;

    var href = (a.getAttribute("href") || "").trim();
    if (href === "#" || href === "" || href.indexOf("javascript:") === 0) {
      e.preventDefault();
    }
    var currentlyOpen = li.classList.contains("open") || sub.style.display === "block";
    if (currentlyOpen) {
      sub.style.setProperty("display", "none", "important");
      li.classList.remove("open");
    } else {
      sub.style.setProperty("display", "block", "important");
      sub.style.setProperty("visibility", "visible", "important");
      sub.style.setProperty("opacity", "1", "important");
      sub.style.setProperty("background-color", "#072420", "important");
      li.classList.add("open");
    }
  }, true);

  window.addEventListener("load", function(){ setTimeout(fixWhiteSurfaces, 200); });
  setInterval(fixWhiteSurfaces, 1500);
})();
EOF

cat << 'EOF' > /usr/bin/qwairah-tg-notify.sh
#!/bin/sh
CONF="/etc/qwairah_tg.conf"
STATE_DIR="/tmp/qwairah_mon"
[ -f "$CONF" ] && . "$CONF"
[ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ] && exit 1
mkdir -p "$STATE_DIR"

MODE="${1:-boot}"
DETAIL="${2:-}"
RAW_NODE="${NODE_NAME:-$(uci -q get system.@system[0].hostname || echo قويره)}"
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

get_net_cards() {
  CARDS=""
  for d in /sys/class/net/*; do
    [ -e "$d" ] || continue
    iface=$(basename "$d")
    [ "$iface" = "lo" ] && continue
    st=$(cat "$d/operstate" 2>/dev/null || echo "unknown")
    case "$iface" in
      wlan*|ra*|apcli*|ath*) ic="📶"; role="واي فاي" ;;
      br-*) ic="🌉"; role="جسر شبكة" ;;
      eth*|lan*|wan*) ic="🔌"; role="منفذ شبكة" ;;
      *) ic="🖧"; role="واجهة" ;;
    esac
    item="${ic} ${iface} (${role}: ${st})"
    if [ -z "$CARDS" ]; then
      CARDS="$item"
    else
      CARDS="${CARDS}، ${item}"
    fi
  done
  [ -z "$CARDS" ] && CARDS="⚠️ غير متاح"
  printf '%s' "$CARDS"
}

describe_cable() {
  st="$1"
  spd="$2"
  if [ "$st" = "up" ] && [ -n "$spd" ] && [ "$spd" -gt 0 ] 2>/dev/null; then
    if [ "$spd" -ge 1000 ]; then
      printf 'كابل 1 جيجابت/ث (%s Mbps - سليم)' "$spd"
    elif [ "$spd" -ge 100 ]; then
      printf 'كابل 100 ميجابت/ث (%s Mbps - تحقق من الكابل)' "$spd"
    else
      printf 'كابل 10 ميجابت/ث (%s Mbps - تحذير عطل/كابل ضعيف)' "$spd"
    fi
  elif [ "$st" = "up" ]; then
    printf 'مرتبط (سرعة غير محددة - احتمال عطل)'
  else
    printf 'غير مرتبط / مفصول'
  fi
}

get_ports_info() {
  OUT=""
  FOUND_LINK=0
  for p in lan1 lan2 lan3 lan4 eth0 eth1 wan br-lan; do
    [ -d "/sys/class/net/$p" ] || continue
    st=$(cat "/sys/class/net/$p/operstate" 2>/dev/null || echo "down")
    spd=$(cat "/sys/class/net/$p/speed" 2>/dev/null || echo "")
    cdesc=$(describe_cable "$st" "$spd")
    if [ "$st" = "up" ]; then
      FOUND_LINK=1
      line="🟢 منفذ ${p}: مرتبط | ${cdesc}"
    else
      line="🔴 منفذ ${p}: غير مرتبط / مفصول | ${cdesc}"
    fi
    if [ -z "$OUT" ]; then
      OUT="$line"
    else
      OUT="${OUT}\n${line}"
    fi
  done
  [ -z "$OUT" ] && OUT="⚠️ لا توجد منافذ سلكية معرفة"
  if [ "$FOUND_LINK" -eq 1 ]; then
    OUT="${OUT}\n🔗 حالة الارتباط بالمنافذ: يوجد ارتباط نشط"
  else
    OUT="${OUT}\n🔌 حالة الارتباط بالمنافذ: لا يوجد أجهزة مرتبطة بالمنافذ"
  fi
  printf '%b' "$OUT"
}

lookup_host_by_mac() {
  TMAC=$(printf '%s' "$1" | tr 'A-F' 'a-f')
  HNAME=""
  if [ -f /tmp/dhcp.leases ]; then
    HNAME=$(awk -v m="$TMAC" 'tolower($2)==m && $4!="*" && $4!="" {print $4; exit}' /tmp/dhcp.leases 2>/dev/null)
  fi
  if [ -z "$HNAME" ] && [ -f /proc/net/arp ]; then
    TIP=$(awk -v m="$TMAC" 'tolower($4)==m {print $1; exit}' /proc/net/arp 2>/dev/null)
    if [ -n "$TIP" ] && [ -f /tmp/dhcp.leases ]; then
      HNAME=$(awk -v ip="$TIP" '$3==ip && $4!="*" && $4!="" {print $4; exit}' /tmp/dhcp.leases 2>/dev/null)
    fi
  fi
  [ -z "$HNAME" ] && HNAME="غير معروف"
  printf '%s' "$HNAME"
}

lookup_ip_by_mac() {
  TMAC=$(printf '%s' "$1" | tr 'A-F' 'a-f')
  TIP=""
  if [ -f /proc/net/arp ]; then
    TIP=$(awk -v m="$TMAC" 'tolower($4)==m {print $1; exit}' /proc/net/arp 2>/dev/null)
  fi
  [ -z "$TIP" ] && TIP="غير محدد"
  printf '%s' "$TIP"
}

get_wifi_clients() {
  if command -v iw >/dev/null 2>&1; then
    for w in $(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}'); do
      iw dev "$w" station dump 2>/dev/null | awk -v iface="$w" '
        /^Station / {
          mac=tolower($2); sig=""; rx=""; tx="";
        }
        /signal:/ {
          if ($3 == "dBm") sig=$2 " dBm";
          else if ($4 == "dBm") sig=$3 " dBm";
          else sig=$2;
        }
        /rx bitrate:/ {
          rx=$3 " " $4;
        }
        /tx bitrate:/ {
          tx=$3 " " $4;
        }
        /^$/ || (mac!="" && /tx bitrate:/) {
          if (mac!="" && (sig!="" || rx!="" || tx!="")) {
            printf "%s|%s|%s|%s|%s\n", iface, mac, sig, rx, tx;
            mac=""; sig=""; rx=""; tx="";
          }
        }
      ' | sort -u | while IFS='|' read -r w_if w_mac w_sig w_rx w_tx; do
        [ -z "$w_mac" ] && continue
        h_name=$(lookup_host_by_mac "$w_mac")
        ip_addr=$(lookup_ip_by_mac "$w_mac")
        printf '👤 الاسم: %s | 📶 الكرت: %s | 🔖 الماك: %s | 🌐 الآيبي: %s | 📡 الإشارة: %s | ⬇️ الاستقبال: %s | ⬆️ الإرسال: %s\n' \
          "$h_name" "$w_if" "$w_mac" "$ip_addr" "${w_sig:-غير متاح}" "${w_rx:-غير متاح}" "${w_tx:-غير متاح}"
      done
    done
  elif command -v iwinfo >/dev/null 2>&1; then
    for w in $(iwinfo 2>/dev/null | awk '/ESSID:/{print $1}'); do
      iwinfo "$w" assoclist 2>/dev/null | awk -v iface="$w" '
        /^[0-9A-Fa-f:]{17}/ {
          mac=tolower($1); sig=$2 " dBm";
          printf "👤 الاسم: غير معروف | 📶 الكرت: %s | 🔖 الماك: %s | 📡 الإشارة: %s\n", iface, mac, sig;
        }
      '
    done
  fi
}

url_enc() {
  if command -v hexdump >/dev/null 2>&1; then
    LC_ALL=C hexdump -v -e '/1 "%02X\n"'
  else
    LC_ALL=C od -An -tx1 | tr -s ' ' '\n' | grep -E '^[0-9a-fA-F]{2}$'
  fi | awk '
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
  TOUT="${2:-15}"
  if command -v curl >/dev/null 2>&1; then
    curl -sSk --max-time "$TOUT" -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
      --data-urlencode "chat_id=${CHAT_ID}" \
      --data-urlencode "text=${TXT}"
    return $?
  fi
  ENC=$(printf '%s' "$TXT" | url_enc)
  URL="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${ENC}"
  if command -v uclient-fetch >/dev/null 2>&1; then
    uclient-fetch --no-check-certificate -T "$TOUT" -q -O - "$URL" 2>&1
    return $?
  elif command -v wget >/dev/null 2>&1; then
    wget --no-check-certificate -T "$TOUT" -qO - "$URL" 2>&1
    return $?
  fi
  echo "No HTTP client found" >&2
  return 1
}

build_full_report() {
  HEAD_TITLE="$1"
  P_VAL="$2"
  S_VAL="$3"
  NET_CARDS=$(get_net_cards)
  PORTS_BLK=$(get_ports_info)
  WIFI_BLK=$(get_wifi_clients)
  [ -z "$WIFI_BLK" ] && WIFI_BLK="🚫 لا يوجد مستخدمون مرتبطون على كروت الواي فاي حالياً"

  printf '%s\n📡 اسم المودم: %s\n🌐 الآيبي: %s\n📶 البينج (1.1.1.3): %s مللي ثانية\n⚡ سرعة الانترنت: %s\n⏱️ مدة التشغيل: %s\n\n🧩 كروت الشبكة:\n%s\n\n🔌 المنافذ وحالة الارتباط:\n%s\n\n👥 المستخدمون المرتبطون بالواي فاي:\n%s' \
    "$HEAD_TITLE" "$MODEM_NAME" "$MODEM_IP" "$P_VAL" "$S_VAL" "$UPTIME_STR" "$NET_CARDS" "$PORTS_BLK" "$WIFI_BLK"
}

case "$MODE" in
  shutdown)
    MSG=$(printf '🔴 تنبيه مودم مقطوع / شبكة قـويــره نت\n📡 اسم المودم: %s\n🌐 الآيبي: %s\n⚙️ الحالة: الجهاز في وضع الإطفاء أو إعادة التشغيل' "$MODEM_NAME" "$MODEM_IP")
    send_msg "$MSG" 6
    ;;
  net_down)
    MSG=$(printf '🔴 تنبيه مودم مقطوع / شبكة قـويــره نت\n📡 اسم المودم: %s\n🌐 الآيبي: %s\n⚠️ الحالة: انقطع الانترنت عنه وذلك بـ %s\n⏱️ مدة التشغيل: %s' "$MODEM_NAME" "$MODEM_IP" "${DETAIL:-فحص بنج الانترنت 1.1.1.3 او فحص سرعة الانترنت}" "$UPTIME_STR")
    send_msg "$MSG" 8
    ;;
  test)
    P_AVG=$(get_ping)
    SPD=$(get_speed)
    MSG=$(build_full_report "🟢 تقرير تشغيل المودم — شبكة قـويــره نت" "${P_AVG:-انتهت المهلة}" "$SPD")
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
      MSG=$(build_full_report "$HEAD" "$P_AVG" "$SPD")
      send_msg "$MSG" 15
    else
      echo "down" > "$STATE_DIR/net_state"
      MSG=$(printf '🔴 تنبيه مودم مقطوع / شبكة قـويــره نت\n📡 اسم المودم: %s\n🌐 الآيبي: %s\n⚠️ الحالة: انقطع الانترنت عنه وذلك بفحص بنج الانترنت 1.1.1.3 او فحص سرعة الانترنت\n⏱️ مدة التشغيل: %s' "$MODEM_NAME" "$MODEM_IP" "$UPTIME_STR")
      send_msg "$MSG" 10
    fi
    ;;
esac
EOF

cat << 'EOF' > /usr/bin/qwairah-tg-watch.sh
#!/bin/sh
CONF="/etc/qwairah_tg.conf"
STATE_DIR="/tmp/qwairah_mon"
PID_FILE="$STATE_DIR/watch.pid"
STATE_FILE="$STATE_DIR/net_state"
FAIL_FILE="$STATE_DIR/fail_cnt"
mkdir -p "$STATE_DIR"

if [ -f "$PID_FILE" ]; then
  OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
  if [ -n "$OLD_PID" ] && [ "$OLD_PID" != "$$" ] && [ -d "/proc/$OLD_PID" ]; then
    exit 0
  fi
fi
echo "$$" > "$PID_FILE"
[ ! -f "$STATE_FILE" ] && echo "up" > "$STATE_FILE"
echo "0" > "$FAIL_FILE"

while true; do
  sleep 30
  [ -f "$CONF" ] && . "$CONF"
  [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ] && continue

  if ping -c 2 -W 2 1.1.1.3 >/dev/null 2>&1; then
    echo "0" > "$FAIL_FILE"
    CUR_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "up")
    if [ "$CUR_STATE" = "down" ]; then
      echo "up" > "$STATE_FILE"
      /usr/bin/qwairah-tg-notify.sh recovered >/dev/null 2>&1
    fi
  else
    FAILS=$(cat "$FAIL_FILE" 2>/dev/null || echo 0)
    case "$FAILS" in ''|*[!0-9]*) FAILS=0 ;; esac
    FAILS=$((FAILS + 1))
    echo "$FAILS" > "$FAIL_FILE"
    CUR_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "up")
    if [ "$FAILS" -ge 3 ] && [ "$CUR_STATE" != "down" ]; then
      echo "down" > "$STATE_FILE"
      /usr/bin/qwairah-tg-notify.sh net_down "فحص بنج الانترنت 1.1.1.3 (3 محاولات متتالية)" >/dev/null 2>&1
    fi
  fi
done
EOF

chmod +x /usr/bin/qwairah-tg-notify.sh /usr/bin/qwairah-tg-watch.sh

cat << 'EOF' > /etc/init.d/qwairah-tg
#!/bin/sh /etc/rc.common
START=99
STOP=10

start() {
  (
    sleep 25
    /usr/bin/qwairah-tg-notify.sh boot
    /usr/bin/qwairah-tg-watch.sh
  ) >/dev/null 2>&1 &
}

stop() {
  if [ -f /tmp/qwairah_mon/watch.pid ]; then
    WPID=$(cat /tmp/qwairah_mon/watch.pid 2>/dev/null)
    [ -n "$WPID" ] && kill "$WPID" 2>/dev/null || true
    rm -f /tmp/qwairah_mon/watch.pid
  fi
  /usr/bin/qwairah-tg-notify.sh shutdown >/dev/null 2>&1
}
EOF

chmod +x /etc/init.d/qwairah-tg
/etc/init.d/qwairah-tg enable
/etc/init.d/qwairah-tg start

for hdr in /www/luci-static/bootstrap/header.htm /usr/lib/lua/luci/view/themes/bootstrap/header.htm /usr/share/ucode/luci/template/themes/bootstrap/header.ut; do
  if [ -f "$hdr" ] && ! grep -q "qwairah_custom.css" "$hdr"; then
    sed -i 's|</head>|<link rel="stylesheet" href="/luci-static/bootstrap/css/qwairah_custom.css" /></head>|g' "$hdr"
  fi
done

for ftr in /www/luci-static/bootstrap/footer.htm /usr/lib/lua/luci/view/themes/bootstrap/footer.htm /usr/share/ucode/luci/template/themes/bootstrap/footer.ut; do
  if [ -f "$ftr" ] && ! grep -q "qwairah_menu_toggle.js" "$ftr"; then
    sed -i 's|</body>|<script src="/luci-static/resources/qwairah_menu_toggle.js"></script></body>|g' "$ftr"
  fi
done

/etc/init.d/rpcd restart
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache /var/luci-* 2>/dev/null || true
/etc/init.d/uhttpd restart
