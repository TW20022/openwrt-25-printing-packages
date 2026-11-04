#!/bin/sh
# ============================================================
# HP LaserJet 1020 —— hplip(hpcups) 链路 离线验证
#
# 用法:  sh test-hplip-1020.sh             # 两段式链路（默认，几秒出结果）
#        sh test-hplip-1020.sh --full      # 再追加 cupsd 全链路（假 backend）
#        sh test-hplip-1020.sh --quick     # 只跑依赖 + 第一段
#
# 为什么不再用 cupsfilter 一步到位：
#   本机 CUPS 2.4 的 cupsfilter 解析 PPD 时报
#   "ppdFilterLoadPPD: Last filter could not get determined"，
#   它会停在 PS->PDF，根本走不到 hpcups（旧版脚本那串 FAIL 全源于此，
#   与打印机、与 012 补丁都无关）。现在按 cupsd 的真实调用方式拆两段：
#     段1  PS     -> CUPS raster   (cupsfilter -m ...，失败退回 gstoraster)
#     段2  raster -> hpcups -> ZJS (带 PPD/DEVICE_URI 环境直接调过滤器)
#
# 判据：ESC E + UEL(ESC%-12345X) + @PJL ENTER LANGUAGE=ZJS + JZJZ，
#       且体积随内容单调增长（空白 < 文字 < 噪点）。
# 无法离线验证：USB 枚举、固件握手、1020 对数据流的实际接受度。
# ============================================================
set -u

TAG=hplip1020
TMP=/tmp/$TAG
QNAME=zz_${TAG}_selftest
FULL=auto
FILTDIR=${FILTDIR:-/usr/lib/cups/filter}
DEVURI='usb://HP/LaserJet%201020'

# 容错：--full / -full / "-- full" / full 都认
for a in "$@"; do
  case "$a" in
    *full*)  FULL=yes ;;
    *quick*) FULL=no  ;;
  esac
done

ok()   { printf '  [ OK ] %s\n' "$1"; }
bad()  { printf '  [FAIL] %s\n' "$1"; }
warn() { printf '  [WARN] %s\n' "$1"; }
info() { printf '  ---- %s\n' "$1"; }
hr()   { printf '\n===== %s =====\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

N_OK=0; N_BAD=0; N_WARN=0
yes_() { N_OK=$((N_OK+1));   ok   "$1"; }
no_()  { N_BAD=$((N_BAD+1)); bad  "$1"; }
hm_()  { N_WARN=$((N_WARN+1)); warn "$1"; }

sz()  { wc -c < "$1" 2>/dev/null | tr -d ' '; }
# 二进制安全：先去掉 NUL 再匹配，避免 busybox grep 把文件当二进制跳过
has() { [ -s "$1" ] && tr -d '\000' < "$1" 2>/dev/null | grep -qF -- "$2"; }
first4() { head -c 4 "$1" 2>/dev/null | tr -d '\000'; }

UEL=$(printf '\033%%-12345X')      # ESC%-12345X
ESC_E=$(printf '\033E')            # 打印机复位

mkdir -p "$TMP" || exit 1
# 上一轮留下的 PDF/半截产物会冒充本轮结果，先清掉
rm -f "$TMP"/*.raster "$TMP"/*.zjs "$TMP"/*.prn "$TMP"/*.spl 2>/dev/null

hr "0. 依赖检查"
PPD=''
for p in /usr/share/ppd/HP/hp-laserjet_1020.ppd /usr/share/ppd/HP/hp-laserjet_1020.ppd.gz \
         /usr/share/cups/model/hp-laserjet_1020.ppd /usr/share/cups/model/hp-laserjet_1020.ppd.gz; do
  [ -f "$p" ] && { PPD=$p; break; }
done
[ -n "$PPD" ] || PPD=$(find /usr/share/ppd /usr/share/cups/model -iname 'hp-laserjet_1020.ppd*' 2>/dev/null | head -1)

[ -n "$PPD" ] && yes_ "PPD: $PPD" || no_ "找不到 hp-laserjet_1020.ppd*（缺 hplip-ppds）"

for f in gstoraster hpcups; do
  [ -x "$FILTDIR/$f" ] && yes_ "过滤器 $f 在位" || no_ "缺 $FILTDIR/$f"
done
have cupsfilter && yes_ "cupsfilter 可用" || no_ "缺 cupsfilter（opkg install cups-client）"
have gs && yes_ "ghostscript (gs) 在位" || no_ "缺 gs（gstoraster 依赖它）"

FW=/usr/share/hplip/data/firmware/hp_laserjet_1020.fw.gz
if [ -f "$FW" ] && gzip -t "$FW" 2>/dev/null; then
  yes_ "固件 $FW 完整（$(sz "$FW") 字节）"
else
  no_ "固件缺失或损坏（$FW）—— 没它 1020 冷启动后不会进打印模式"
fi

# 插件状态：hpcups 打印本身不需要插件，但 hp-firmware 需要
ST=''
for s in /var/lib/hp/hplip.state /root/.hplip/hplip.state /etc/hplip.state; do
  [ -f "$s" ] && { ST=$s; break; }
done
if [ -n "$ST" ] && grep -q 'installed *=' "$ST"; then
  if [ -L /var/lib/hp/hplip.state ]; then
    yes_ "插件状态 installed（$ST，已软链持久化）"
  else
    hm_ "插件状态在 $ST，但 /var/lib/hp 不是软链 —— 重启可能丢"
  fi
else
  hm_ "未见 hplip.state —— 不影响本脚本的编码器验证，但 hp-firmware 会被拒绝"
fi

hr "1. 生成测试页（空白 / 文字 / 噪点）"
mk_ps() {
  case "$2" in
    blank) printf '%%!PS-Adobe-3.0\nshowpage\n' > "$1" ;;
    text)  printf '%%!PS-Adobe-3.0\n/Helvetica findfont 20 scalefont setfont\n72 760 moveto (CUPS selftest 1234567890) show\n72 700 moveto (hplip hpcups ZJS chain) show\n0 0 moveto 400 0 lineto stroke\nshowpage\n' > "$1" ;;
    noise) printf '%%!PS-Adobe-3.0\n0 setlinewidth\n1 1 4000 { pop rand 500 mod 40 add rand 780 mod 40 add moveto rand 100 mod 8 add 0 rlineto stroke } for\nshowpage\n' > "$1" ;;
  esac
}
mk_ps "$TMP/blank.ps" blank
mk_ps "$TMP/text.ps"  text
mk_ps "$TMP/noise.ps" noise
info "三张页已生成：$(sz "$TMP/blank.ps") / $(sz "$TMP/text.ps") / $(sz "$TMP/noise.ps") 字节"

# 过滤器要读 PPD，.gz 先解开
RUNPPD=$TMP/1020.ppd
if [ -z "$PPD" ]; then
  info "没有 PPD，跳过解压"
elif [ "${PPD%.gz}" != "$PPD" ]; then
  zcat "$PPD" > "$RUNPPD" 2>/dev/null || cp "$PPD" "$RUNPPD"
else
  cp "$PPD" "$RUNPPD"
fi
[ -s "$RUNPPD" ] && info "PPD 已就绪：$RUNPPD" || no_ "PPD 不可用（解压失败或文件为空）"

# ---------- 两段式：PS -> raster -> 设备流 ----------
# 段1：PS -> CUPS raster
# CUPS raster 的同步字是 0x52615333：小端机上落盘就是 "3SaR"，大端机是 "RaS3"。
# 之前只判 "RaS*"，等于把 valid 的 raster 全判成失败（本机实测头就是 3SaR）。
is_raster() {
  [ -s "$1" ] || return 1
  case "$(first4 "$1")" in
    RaS3|3SaR) return 0 ;;
    *)         return 1 ;;
  esac
}

mk_raster() {   # mk_raster <in.ps> <out.raster>；成功则 RASTER_HOW 记录走的哪条路
  : > "$2"; : > "$2.err"
  RASTER_HOW=""; RASTER_RC=""
  # 退路 1：cupsfilter 停在 CUPS raster 这一层（= cupsd 里 pdftopdf + gstoraster 的等价物）
  cupsfilter -p "$RUNPPD" -i application/postscript -m application/vnd.cups-raster \
             -o PageSize=A4 "$1" > "$2" 2>> "$2.err"
  RASTER_RC=$?
  if is_raster "$2"; then RASTER_HOW="cupsfilter -m (rc=$RASTER_RC)"; return 0; fi
  # 退路 2：直接调 gstoraster。故意用管道（cupsd 给过滤器的也是管道）：
  # 本机 gstoraster 在「stdout 是普通文件」时退出清理会 SIGSEGV，管道下正常。
  if [ -x "$FILTDIR/gstoraster" ]; then
    # 子 shell 才拿得到 gstoraster 自己的退出码（`cmd | cat` 的 $? 是 cat 的）
    ( PPD="$RUNPPD" CUPS_DATADIR=/usr/share/cups \
      "$FILTDIR/gstoraster" 1 root selftest 1 "PageSize=A4" "$1" 2>> "$2.err"
      echo $? > "$2.rc" ) | cat > "$2"
    RASTER_RC=$(cat "$2.rc" 2>/dev/null)
    if is_raster "$2"; then RASTER_HOW="gstoraster|cat (rc=${RASTER_RC:-?})"; return 0; fi
  fi
  # 退路 3：绕开 cups-filters，自己调 gs 的 cups 设备（gstoraster 内部最终也是它）
  if have gs; then
    gs -q -dNOPAUSE -dBATCH -sDEVICE=cups -r600 -g4960x7016 \
       -dcupsBitsPerColor=1 -dcupsColorSpace=3 \
       -sOutputFile="$2" "$1" 2>> "$2.err"
    RASTER_RC=$?
    if is_raster "$2"; then RASTER_HOW="gs -sDEVICE=cups (rc=$RASTER_RC)"; return 0; fi
  fi
  RASTER_HOW=""
  return 1
}

# 段2：CUPS raster -> hpcups -> ZJS（参数顺序与 cupsd 调用过滤器时完全一致）
mk_dev() {      # mk_dev <in.raster> <out.dev>
  PPD="$RUNPPD" DEVICE_URI="$DEVURI" CUPS_DATADIR=/usr/share/cups \
    "$FILTDIR/hpcups" 1 root selftest 1 "PageSize=A4" "$1" > "$2" 2> "$2.err"
  return $?
}

hr "2. 段1：PS -> CUPS raster（gstoraster 那一步）"
RASTER_OK=0; RASTER_HOW=""
if mk_raster "$TMP/text.ps" "$TMP/text.raster"; then
  RASTER_OK=1
  yes_ "得到 CUPS raster：$(sz "$TMP/text.raster") 字节，包头 $(first4 "$TMP/text.raster")，来源 $RASTER_HOW"
  case "$RASTER_HOW" in
    *rc=139*)
      hm_ "gstoraster 退出码 139（SIGSEGV），但数据是完整的 —— 崩在退出清理，不在渲染"
      info "cupsd 只认过滤器退出码，这一条得用 probe-gstoraster.sh --cups 确认作业是否被判失败"
      ;;
  esac
else
  no_ "PS 转 CUPS raster 失败：cupsfilter -m、gstoraster、gs -sDEVICE=cups 三条路都没出 raster"
  info "gs 版本：$(gs --version 2>&1 | head -1)；/tmp 可用：$(df -k /tmp 2>/dev/null | tail -1 | awk '{print $4}') KB"
  info "stderr 末尾 20 行（gs 为什么退通常就写在这里）："
  tail -20 "$TMP/text.raster.err" 2>/dev/null | sed 's/^/      /'
  info "先跑一次 probe-gstoraster.sh 定位，再决定补 gs 还是改走 foo2zjs"
fi

hr "3. 段2：raster -> hpcups -> ZJS"
RUNOK=0
if [ "$RASTER_OK" -eq 1 ]; then
  if mk_dev "$TMP/text.raster" "$TMP/text.zjs" && [ -s "$TMP/text.zjs" ]; then
    RUNOK=1
    yes_ "hpcups 正常返回，产出 $(sz "$TMP/text.zjs") 字节"
    has "$TMP/text.zjs" "$ESC_E" && yes_ "含 ESC E（打印机复位）" || hm_ "未见 ESC E"
    has "$TMP/text.zjs" "$UEL" && yes_ "含 UEL（ESC%-12345X），进了 PJL 层" || no_ "缺 UEL，数据没有进入 PJL 层"
    if has "$TMP/text.zjs" '@PJL ENTER LANGUAGE=ZJS'; then
      yes_ "含 @PJL ENTER LANGUAGE=ZJS —— 切到 1020 认的 ZJS 语言"
    else
      no_ "缺 @PJL ENTER LANGUAGE=ZJS —— 不是 1020 要的语言，真机会无反应"
    fi
    if has "$TMP/text.zjs" 'JZJZ'; then
      yes_ "含 JZJZ 魔数 —— ZJS 数据块已开始编码"
    else
      no_ "缺 JZJZ —— 只有页头没有数据，真机会吐白纸"
    fi
    if grep -qi 'ImageProcessor' "$TMP/text.zjs.err" 2>/dev/null; then
      no_ "stderr 提到 ImageProcessor —— 012 补丁打坏了编码器"
    else
      yes_ "stderr 无 ImageProcessor 报错"
    fi
  else
    no_ "hpcups 没有产出数据"
    sed -n '1,8p' "$TMP/text.zjs.err" 2>/dev/null | sed 's/^/      /'
  fi
else
  info "段1 没出 raster，段2 跳不过去"
fi
rm -f "$TMP/text.raster"

hr "4. 内容相关性（编码器是否真的在编码，而不是只发页头）"
if [ "$RUNOK" -eq 1 ]; then
  chain_size() {   # chain_size <name> -> 打印设备流字节数
    if mk_raster "$TMP/$1.ps" "$TMP/$1.raster" && mk_dev "$TMP/$1.raster" "$TMP/$1.zjs"; then
      sz "$TMP/$1.zjs"
    else
      echo 0
    fi
    rm -f "$TMP/$1.raster"
  }
  B=$(chain_size blank); N=$(chain_size noise)
  info "空白页 ${B:-0} 字节 / 噪点页 ${N:-0} 字节"
  if [ "${B:-0}" -gt 0 ] && [ "${N:-0}" -gt "${B:-0}" ]; then
    if [ "$N" -ge $((B * 3)) ] || [ "$N" -ge 2000 ]; then
      yes_ "噪点页显著大于空白页 —— 差分编码在按内容工作"
    else
      hm_ "噪点页只比空白页大一点，编码器可能在偷懒（真机打印会偏白）"
    fi
  else
    hm_ "体积没有随内容增长，无法判断（先看第 3 步是否已经 FAIL）"
  fi
else
  info "段2 已失败，跳过"
fi

hr "5. 数据流抽样（人工复核用）"
if [ ! -s "$TMP/text.zjs" ]; then
  info "没有产出，跳过"
else
  info "text.zjs 前 64 字节："
  if have hexdump; then hexdump -C -n 64 "$TMP/text.zjs" | sed 's/^/      /'
  elif have od;   then od -A d -t x1z -N 64 "$TMP/text.zjs" | sed 's/^/      /'
  else info "      (无 hexdump/od)"; fi
  info "可读片段："
  tr -d '\000' < "$TMP/text.zjs" | tr -c '[:print:]\n' '\n' | grep -a . | head -6 | sed 's/^/      /'
fi

hr "6. cupsd 全链路（假 backend，可选）"
if [ "$FULL" = no ]; then
  info "已跳过（--quick）"
elif ! have lpadmin || ! have lp || [ ! -x /usr/sbin/cupsd ]; then
  hm_ "缺 cupsd/lpadmin/lp，跳过"
else
  running() { pidof cupsd >/dev/null 2>&1; }
  running || { /etc/init.d/cupsd start >/dev/null 2>&1; sleep 1; }
  if ! running; then
    hm_ "cupsd 没起来，跳过全链路"
  else
    # 假 backend：输出路径直接从 DEVICE_URI 取，保证脚本知道文件落在哪
    BK=$FILTDIR/../backend/savefile
    cat > "$BK" <<'EOS'
#!/bin/sh
# 假 backend：把 CUPS 送来的打印数据存成文件，不碰硬件
# cupsd 是以非 root 用户跑 backend 的（OpenWrt 上是 lp，桌面发行版是 cups），
# 所以输出目录必须对它可写，日志也写在输出文件旁边（写 /tmp 根会被 root 的 644 挡住）。
[ $# -eq 0 ] && exit 0                       # 无参数 = 设备发现调用
out="${DEVICE_URI#savefile:}"                # 队列的 URI 就是输出路径
[ -n "$out" ] || out="/tmp/savefile-$1.prn"
echo "$(date '+%F %T') uri=$DEVICE_URI user=$(id -un 2>/dev/null) args=$*" >> "$out.log" 2>/dev/null
f=""
for a in "$@"; do [ -f "$a" ] && f="$a"; done  # CUPS 2.x 把数据文件作为最后一个参数
if [ -n "$f" ]; then cat "$f" > "$out" 2>> "$out.log"; else cat > "$out" 2>> "$out.log"; fi
printf 'INFO: saved %s (%s bytes)\n' "$out" "$(wc -c < "$out")"
exit 0
EOS
    chmod 755 "$BK"
    # 让 cupsd 重扫 backend 目录（新建的可执行 backend 需要一次重扫才认得）
    pid=$(pidof cupsd 2>/dev/null | awk '{print $1}')
    [ -n "$pid" ] && kill -HUP "$pid" 2>/dev/null; sleep 1
    # 注意：lpinfo -v 列的是「设备」，本假 backend 无参数调用直接 exit（不报设备），
    # 所以它永远不会出现在 lpinfo -v 里 —— 这不代表 cupsd 用不了它。
    # 真正的判据是下面 lpstat -v 有没有记住 savefile: 这个 URI。

    OUT=$TMP/job.prn
    rm -f "$OUT" "$OUT.log"
    # 关键：cupsd 的 backend 是普通用户，$TMP 由 root 建成 755 时它写不进去，
    # error_log 会留下 "can't create ...: Permission denied"
    chmod 777 "$TMP" 2>/dev/null
    : > "$OUT.log" 2>/dev/null; chmod 666 "$OUT.log" 2>/dev/null
    info "cupsd 跑 backend 的用户：$(grep -E '^(User|Group)[[:space:]]' /etc/cups/cupsd.conf 2>/dev/null | tr '\n' ' ')"
    lpadmin -x "$QNAME" >/dev/null 2>&1
    if err=$(lpadmin -p "$QNAME" -E -v "savefile:$OUT" -P "$RUNPPD" 2>&1); then
      if lpstat -v "$QNAME" 2>/dev/null | grep -q savefile; then
        info "队列已建立：$(lpstat -v "$QNAME" 2>/dev/null | head -1)"
      else
        hm_ "队列建了但 device-uri 不是 savefile:（cupsd 可能没认这个 backend）"
      fi
      if err=$(lp -d "$QNAME" "$TMP/text.ps" 2>&1); then
        i=0
        while [ $i -lt 20 ]; do [ -s "$OUT" ] && break; sleep 1; i=$((i+1)); done
        if [ -s "$OUT" ]; then
          yes_ "全链路产出 $(sz "$OUT") 字节（cupsd -> gstoraster -> hpcups -> backend）"
          if has "$OUT" '@PJL ENTER LANGUAGE=ZJS' && has "$OUT" 'JZJZ'; then
            yes_ "全链路输出与离线结果一致：ZJS 语言 + JZJZ"
          else
            no_ "全链路输出缺 ZJS 标记，看 /var/log/cups/error_log"
          fi
        else
          no_ "全链路没产出（作业入了队但没落到 $OUT）"
          info "作业状态（pending/aborted 一眼看出 cupsd 有没有真跑过滤器）："
          lpstat -W all -o "$QNAME" 2>/dev/null | head -3 | sed 's/^/      /'
          info "backend 日志（空 = backend 没被调用；有 Permission denied 就是权限问题）："
          tail -5 "$OUT.log" 2>/dev/null | sed 's/^/      /'
          info "error_log：作业相关行"
          grep -aE '\[Job [0-9]+\]' /var/log/cups/error_log 2>/dev/null | tail -8 | sed 's/^/      /'
          info "error_log：过滤器/后端失败特征（出现 139 / SIGSEGV 就是 gstoraster 崩了）"
          grep -aE 'Filter failed|SIGSEGV|status 13[0-9]|exited with status|Permission denied|savefile|Unable to' /var/log/cups/error_log 2>/dev/null | tail -8 | sed 's/^/      /'
          fi
      else
        no_ "lp 提交失败：$err"
      fi
    else
      hm_ "建临时队列失败：$err"
    fi
    lpadmin -x "$QNAME" >/dev/null 2>&1
    info "假 backend 留在 $BK，不需要时 rm 掉即可"
  fi
fi

hr "结果"
printf '  OK=%d  WARN=%d  FAIL=%d\n' "$N_OK" "$N_WARN" "$N_BAD"
if [ "$N_BAD" -eq 0 ]; then
  cat <<'EOS'
  结论：hplip 链路在软件层是完整的。
  1020 到手后的顺序：
    hp-probe -b usb                  # 看得到 = 枚举正常
    hp-config_usb_printer 001:00X    # 下发固件（会重新枚举，devnum 变化）
    hp-probe -b usb                  # 设备号变了 = 固件生效
    hp-setup -i                      # 建队列，选 HP LaserJet 1020
    lp -d <队列> /etc/hostname       # 出纸即全线打通
EOS
else
  printf '  结论：链路有断点。上面每条 FAIL 都写了它对应真机上的什么现象。\n'
  printf '  常见补法：opkg install hplip-ppds cups-filters ghostscript cups-client\n'
fi
printf '  中间文件在 %s，可整体删除。\n' "$TMP"
