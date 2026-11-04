#!/bin/sh
# ============================================================
# Samsung ML-2010（splix 驱动）链路 离线验证
#
# 用法:  sh test-splix-ml2010.sh             # 两段式链路（默认）
#        sh test-splix-ml2010.sh --full      # 再追加 cupsd 全链路（假 backend）
#        sh test-splix-ml2010.sh --quick     # 只跑依赖 + 第一段
#
# 为什么选 ML-2010：splix 的 ppd 目录里 ml2010.ppd 是最经典的 SPL2（QPDL v2）
# 单色机型，600dpi、rastertoqpdl 单过滤器、结构最简单。它在 GDI/主机型打印机里
# 和 HP 1020 是同一类东西，拿来验证 splix 这条链最干净。
#
# 为什么拆两段：本机 CUPS 2.4 的 cupsfilter 解析 PPD 时报
#   "ppdFilterLoadPPD: Last filter could not get determined"
# 于是停在 PS->PDF，走不到 rastertoqpdl（旧脚本的 FAIL 全是这个原因）。
#   段1  PS     -> CUPS raster     (cupsfilter -m ...，失败退回 gstoraster)
#   段2  raster -> rastertoqpdl    (带 PPD 环境直接调，与 cupsd 一致)
#
# 判据（来自 ml2010.ppd 的 *PJL BeginPJL/EndPJL 与 qpdl.cpp 的记录格式）：
#   头 = ESC%-12345X        尾 = TAB + ESC%-12345X
#   中间 = QPDL 记录（0x0C 波段 / 0x13 页头…），体积随内容增长。
# 无法离线验证：USB 枚举、ML-2010 对 QPDL 压缩流的接受度。
# ============================================================
set -u

TAG=splixml2010
MODEL_PPD=ml2010.ppd
MODEL_NAME="Samsung ML-2010"
TMP=/tmp/$TAG
QNAME=zz_${TAG}_selftest
FULL=auto
FILTDIR=${FILTDIR:-/usr/lib/cups/filter}
DEVURI='usb://Samsung/ML-2010'

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
has() { [ -s "$1" ] && tr -d '\000' < "$1" 2>/dev/null | grep -qF -- "$2"; }
first4() { head -c 4 "$1" 2>/dev/null | tr -d '\000'; }

UEL=$(printf '\033%%-12345X')     # ESC%-12345X
TAB=$(printf '\011')

mkdir -p "$TMP" || exit 1
# 上一轮留下的 PDF/半截产物会冒充本轮结果，先清掉
rm -f "$TMP"/*.raster "$TMP"/*.zjs "$TMP"/*.prn "$TMP"/*.spl 2>/dev/null
FILTER=$FILTDIR/rastertoqpdl

hr "0. 依赖检查"
[ -x "$FILTER" ] && yes_ "过滤器 rastertoqpdl 在位" \
  || no_ "缺 $FILTER（opkg install splix）"
[ -x "$FILTDIR/gstoraster" ] && yes_ "gstoraster 在位" \
  || no_ "缺 gstoraster（opkg install cups-filters）"
have gs && yes_ "ghostscript (gs) 在位" || no_ "缺 gs"
have cupsfilter && yes_ "cupsfilter 可用" || no_ "缺 cupsfilter（opkg install cups-client）"
# splix 依赖 libjbigkit；缺库时 filter 会以 "can't load library" 退出
if [ -n "$(ls /usr/lib/libjbig*.so* 2>/dev/null)" ]; then
  yes_ "libjbigkit 在位"
else
  hm_ "未见 libjbig*，splix 可能起不来（opkg install libjbigkit）"
fi

hr "1. 取得 ML-2010 的 PPD"
PPD=$(find /usr/share/cups/model /usr/share/ppd -name "$MODEL_PPD" 2>/dev/null | head -1)
[ -n "$PPD" ] && yes_ "PPD: $PPD" || no_ "找不到 $MODEL_PPD —— splix 装了但 PPD 没进 model 目录？"

if [ -n "$PPD" ]; then
  case "$PPD" in
    *.gz) zcat "$PPD" > "$TMP/splix.ppd" 2>/dev/null ;;
    *)    cp "$PPD" "$TMP/splix.ppd" ;;
  esac
  PPD=$TMP/splix.ppd
  info "cupsFilter: $(grep -i 'cupsFilter' "$PPD" | head -1)"
  grep -qi "$MODEL_NAME" "$PPD" && yes_ "PPD 型号匹配：$MODEL_NAME" || hm_ "PPD 里没找到 $MODEL_NAME"
  # 这两行决定包头包尾，脚本按它校验，先打出来
  grep -i -E 'BeginPJL|EndPJL|QPDLVersion' "$PPD" | sed 's/^/      /'
  case "$(grep -i 'cupsFilter' "$PPD" | head -1)" in
    *rastertoqpdl*) yes_ "cupsFilter 指向 rastertoqpdl" ;;
    *pstoqpdl*)     hm_ "该 PPD 走 pstoqpdl（PS 直入），本脚本按 raster 链验证，可能不适用" ;;
    *)              hm_ "cupsFilter 不是 rastertoqpdl，核对机型" ;;
  esac
fi

hr "2. 生成测试页（空白 / 文字 / 噪点）"
mk_ps() {
  case "$2" in
    blank) printf '%%!PS-Adobe-3.0\nshowpage\n' > "$1" ;;
    text)  printf '%%!PS-Adobe-3.0\n/Helvetica findfont 20 scalefont setfont\n72 760 moveto (CUPS selftest 1234567890) show\n72 700 moveto (splix QPDL chain) show\n0 0 moveto 400 0 lineto stroke\nshowpage\n' > "$1" ;;
    noise) printf '%%!PS-Adobe-3.0\n0 setlinewidth\n1 1 4000 { pop rand 500 mod 40 add rand 780 mod 40 add moveto rand 100 mod 8 add 0 rlineto stroke } for\nshowpage\n' > "$1" ;;
  esac
}
mk_ps "$TMP/blank.ps" blank
mk_ps "$TMP/text.ps"  text
mk_ps "$TMP/noise.ps" noise
info "三张页已生成：$(sz "$TMP/blank.ps") / $(sz "$TMP/text.ps") / $(sz "$TMP/noise.ps") 字节"

RUNPPD=$TMP/splix.ppd
[ -s "$RUNPPD" ] && info "PPD 已就绪：$RUNPPD" || no_ "PPD 不可用"

# ---------- 两段式 ----------
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

mk_dev() {      # mk_dev <in.raster> <out.dev>
  PPD="$RUNPPD" DEVICE_URI="$DEVURI" CUPS_DATADIR=/usr/share/cups \
    "$FILTER" 1 root selftest 1 "PageSize=A4" "$1" > "$2" 2> "$2.err"
  return $?
}

hr "3. 段1：PS -> CUPS raster（gstoraster 那一步）"
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

hr "4. 段2：raster -> rastertoqpdl -> QPDL(SPL2)"
RUNOK=0
if [ "$RASTER_OK" -eq 1 ]; then
  if mk_dev "$TMP/text.raster" "$TMP/text.spl" && [ -s "$TMP/text.spl" ]; then
    RUNOK=1
    T=$(sz "$TMP/text.spl")
    yes_ "rastertoqpdl 正常返回，产出 $T 字节"

    # 包头：BeginPJL = ESC%-12345X
    if head -c 12 "$TMP/text.spl" | grep -qF "$UEL"; then
      yes_ "开头是 UEL（ESC%-12345X）—— 与 PPD 的 BeginPJL 一致"
    else
      no_ "开头不是 UEL —— 数据没按 PPD 的 BeginPJL 封装，真机不会认"
    fi
    # 包尾：EndPJL = TAB + ESC%-12345X
    if [ "${T:-0}" -ge 16 ] && tail -c 32 "$TMP/text.spl" | grep -qF "$UEL"; then
      yes_ "结尾含 UEL —— 与 PPD 的 EndPJL 一致（作业完整收尾）"
    else
      no_ "结尾没有 UEL —— 数据可能被截断"
    fi
    if grep -qiE 'error|cannot|failed|unsupported|abort' "$TMP/text.spl.err" 2>/dev/null; then
      hm_ "stderr 有异常字样："
      grep -aiE 'error|cannot|failed|unsupported|abort' "$TMP/text.spl.err" | head -5 | sed 's/^/      /'
    else
      yes_ "stderr 无错误"
    fi
  else
    no_ "rastertoqpdl 没有产出数据"
    sed -n '1,8p' "$TMP/text.spl.err" 2>/dev/null | sed 's/^/      /'
  fi
else
  info "段1 没出 raster，段2 跳不过去"
fi
rm -f "$TMP/text.raster"

hr "5. 内容相关性（QPDL 压缩是否真在压缩）"
if [ "$RUNOK" -eq 1 ]; then
  chain_size() {   # chain_size <name> -> 打印设备流字节数
    if mk_raster "$TMP/$1.ps" "$TMP/$1.raster" && mk_dev "$TMP/$1.raster" "$TMP/$1.spl"; then
      sz "$TMP/$1.spl"
    else
      echo 0
    fi
    rm -f "$TMP/$1.raster"
  }
  B=$(chain_size blank); N=$(chain_size noise)
  info "空白页 ${B:-0} 字节 / 噪点页 ${N:-0} 字节"
  if [ "${B:-0}" -gt 0 ] && [ "${N:-0}" -gt "${B:-0}" ]; then
    if [ "$N" -ge $((B * 2)) ] || [ "$N" -ge 3000 ]; then
      yes_ "噪点页显著更大 —— 有实际图像数据"
    else
      hm_ "噪点页增幅偏小，压缩率异常（也可能是页面被跳过）"
    fi
  else
    hm_ "体积没随内容增长，值得复核"
  fi
else
  info "段2 已失败，跳过"
fi

hr "6. 数据流抽样（人工复核用）"
if [ ! -s "$TMP/text.spl" ]; then
  info "没有产出（第 4 步已 FAIL），跳过"
else
  info "text.spl 前 64 字节（UEL 之后应紧接 QPDL 记录，首字节常见 0x0C/0x13）："
  if have hexdump; then hexdump -C -n 64 "$TMP/text.spl" | sed 's/^/      /'
  elif have od;   then od -A d -t x1z -N 64 "$TMP/text.spl" | sed 's/^/      /'
  else info "      (无 hexdump/od)"; fi
  info "结尾 16 字节（应看到 09 1b 25 2d 31 32 33 34 35 58，即 TAB+UEL）："
  if have hexdump; then tail -c 16 "$TMP/text.spl" | hexdump -C | sed 's/^/      /'
  elif have od;   then tail -c 16 "$TMP/text.spl" | od -A d -t x1z | sed 's/^/      /'
  else info "      (无 hexdump/od)"; fi
fi

hr "7. cupsd 全链路（假 backend，可选）"
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

    OUT=$TMP/job.spl
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
          yes_ "全链路产出 $(sz "$OUT") 字节（cupsd -> gstoraster -> rastertoqpdl -> backend）"
          if head -c 12 "$OUT" | grep -qF "$UEL" && tail -c 32 "$OUT" | grep -qF "$UEL"; then
            yes_ "全链路输出首尾都是 UEL，与离线结果一致"
          else
            no_ "全链路输出首尾 UEL 不匹配，看 /var/log/cups/error_log"
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
  结论：splix 链路在软件层是完整的。
  真机接入后的顺序（ML-2010 是 SPL2/QPDL v2 机型，插上即被识别，不需要固件）：
    lsusb | grep -i 04e8                        # 三星 vendor id 是 04e8
    lpinfo -v | grep usb                        # 看 usb://Samsung/ML-2010 之类
    lpadmin -p ML2010 -E -v usb://Samsung/ML-2010 -P /usr/share/cups/model/<...>/ml2010.ppd
    lp -d ML2010 /etc/hostname
  要换机型：把 ml2010.ppd 换成目标 PPD（splix 的 PPD 全平铺在 model 目录下）：
    ml2510.ppd  ML-2510        ml2571.ppd  ML-2571N     scx4200.ppd  SCX-4200
    ph3117.ppd  Xerox 3117     1100.ppd    Dell 1100     clp315.ppd   CLP-315(彩色)
  完整清单：find /usr/share/cups/model -name '*.ppd*' | grep -iE 'ml|scx|clp|ph3'
EOS
else
  printf '  结论：链路有断点，按上面 FAIL 逐条修。\n'
  printf '  常见补法：opkg install splix cups-filters ghostscript cups-client libjbigkit\n'
fi
printf '  中间文件在 %s，可整体删除。\n' "$TMP"
