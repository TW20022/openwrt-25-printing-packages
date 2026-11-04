#!/bin/sh
# ============================================================
# Brother HL-2140（brlaser 驱动）链路 离线验证
#
# 用法:  sh test-brlaser-hl2140.sh            # 两段式链路（默认）
#        sh test-brlaser-hl2140.sh --full     # 再追加 cupsd 全链路（假 backend）
#        sh test-brlaser-hl2140.sh --quick    # 只跑依赖 + 第一段
#
# 为什么选 HL-2140：brlaser v6 的 drv 里它 PCFileName 是 br2140.ppd，
# 1284DeviceID 为 "CMD:PJL,HBP"，600dpi、纯 HBPL/PCL 光栅，最典型也最常见。
#
# 为什么拆两段：本机 CUPS 2.4 的 cupsfilter 解析 PPD 时报
#   "ppdFilterLoadPPD: Last filter could not get determined"
# 于是停在 PS->PDF，走不到 rastertobrlaser（旧脚本的 FAIL 全是这个原因）。
# 现在按 cupsd 的真实调用方式拆：
#   段1  PS     -> CUPS raster        (cupsfilter -m ...，失败退回 gstoraster)
#   段2  raster -> rastertobrlaser    (带 PPD 环境直接调，与 cupsd 一致)
#
# 判据（来自 brlaser/src/job.cc）：@PJL JOB + "@PJL ENTER LANGUAGE = PCL"
#   + ESC E + @PJL EOJ，且体积随内容增长。
# 无法离线验证：USB 枚举、HL-2140 对 PCL 光栅压缩流的接受度。
# ============================================================
set -u

TAG=brlaser
MODEL_PPD=br2140.ppd
MODEL_NAME="Brother HL-2140 series"
TMP=/tmp/$TAG
QNAME=zz_${TAG}_selftest
FULL=auto
FILTDIR=${FILTDIR:-/usr/lib/cups/filter}
DEVURI='usb://Brother/HL-2140%20series'

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

ESC_E=$(printf '\033E')
mkdir -p "$TMP" || exit 1
# 上一轮留下的 PDF/半截产物会冒充本轮结果，先清掉
rm -f "$TMP"/*.raster "$TMP"/*.zjs "$TMP"/*.prn "$TMP"/*.spl 2>/dev/null
DRV=/usr/share/cups/drv/brlaser.drv
FILTER=$FILTDIR/rastertobrlaser

hr "0. 依赖检查"
[ -x "$FILTER" ] && yes_ "过滤器 rastertobrlaser 在位" \
  || no_ "缺 $FILTER（opkg install brlaser）"
[ -f "$DRV" ] && yes_ "drv 描述文件: $DRV" \
  || no_ "缺 $DRV —— brlaser 不装 PPD，只装 drv，缺它就没有任何机型可选"
[ -x "$FILTDIR/gstoraster" ] && yes_ "gstoraster 在位" \
  || no_ "缺 gstoraster（opkg install cups-filters）"
have gs && yes_ "ghostscript (gs) 在位" || no_ "缺 gs"
have cupsfilter && yes_ "cupsfilter 可用" || no_ "缺 cupsfilter（opkg install cups-client）"

hr "1. 取得 HL-2140 的 PPD"
PPD=''
for p in /usr/share/cups/model/$MODEL_PPD /usr/share/ppd/HP/$MODEL_PPD \
         /usr/share/cups/ppd/$MODEL_PPD; do
  [ -f "$p" ] && { PPD=$p; break; }
done
if [ -z "$PPD" ]; then
  PPD=$(find /usr/share/cups /usr/share/ppd -name "$MODEL_PPD" 2>/dev/null | head -1)
fi

if [ -n "$PPD" ]; then
  yes_ "已有现成 PPD: $PPD"
elif [ -f "$DRV" ] && have ppdc; then
  info "没有现成 PPD，用 ppdc 从 drv 展开（这是 brlaser 的正常形态）"
  rm -rf "$TMP/ppd"; mkdir -p "$TMP/ppd"
  ppdc -d "$TMP/ppd" "$DRV" >"$TMP/ppdc.log" 2>&1
  if [ -f "$TMP/ppd/$MODEL_PPD" ]; then
    PPD=$TMP/ppd/$MODEL_PPD
    yes_ "ppdc 已生成 $MODEL_PPD"
  else
    no_ "ppdc 没生成 $MODEL_PPD，日志："
    sed -n '1,8p' "$TMP/ppdc.log" | sed 's/^/      /'
    info "已生成的文件：$(ls "$TMP/ppd" 2>/dev/null | tr '\n' ' ')"
  fi
elif [ -f "$DRV" ]; then
  info "没有 ppdc，改走 lpadmin 临时队列生成 PPD（需要 cupsd）"
  running() { pidof cupsd >/dev/null 2>&1; }
  running || { /etc/init.d/cupsd start >/dev/null 2>&1; sleep 1; }
  if running && have lpadmin; then
    lpadmin -x "$QNAME" >/dev/null 2>&1
    if lpadmin -p "$QNAME" -E -v "file:/dev/null" -m "drv:///brlaser.drv/$MODEL_PPD" >/dev/null 2>&1 \
       && [ -f "/etc/cups/ppd/$QNAME.ppd" ]; then
      PPD=$TMP/from-queue.ppd
      cp "/etc/cups/ppd/$QNAME.ppd" "$PPD"
      yes_ "从临时队列取出 PPD: $PPD"
      lpadmin -x "$QNAME" >/dev/null 2>&1
    else
      no_ "lpadmin -m drv:///brlaser.drv/$MODEL_PPD 失败"
    fi
  else
    no_ "cupsd 不可用，无法生成 PPD"
  fi
else
  no_ "既没有 PPD 也没有 drv，无法继续"
fi

# 顺手核对 PPD 里的过滤器是否指向 rastertobrlaser
if [ -s "$PPD" ]; then
  line=$(grep -i 'cupsFilter' "$PPD" | head -2)
  info "PPD 的 cupsFilter: ${line:-（未声明）}"
  case "$line" in
    *rastertobrlaser*) yes_ "cupsFilter 指向 rastertobrlaser" ;;
    *) hm_ "cupsFilter 不是 rastertobrlaser，可能取错了 PPD" ;;
  esac
  grep -qi "$MODEL_NAME" "$PPD" && yes_ "PPD 型号匹配：$MODEL_NAME" \
    || hm_ "PPD 里没找到 \"$MODEL_NAME\"，确认机型是否取对"
fi

hr "2. 生成测试页（空白 / 文字 / 噪点）"
mk_ps() {
  case "$2" in
    blank) printf '%%!PS-Adobe-3.0\nshowpage\n' > "$1" ;;
    text)  printf '%%!PS-Adobe-3.0\n/Helvetica findfont 20 scalefont setfont\n72 760 moveto (CUPS selftest 1234567890) show\n72 700 moveto (brlaser HL-2140 chain) show\n0 0 moveto 400 0 lineto stroke\nshowpage\n' > "$1" ;;
    noise) printf '%%!PS-Adobe-3.0\n0 setlinewidth\n1 1 4000 { pop rand 500 mod 40 add rand 780 mod 40 add moveto rand 100 mod 8 add 0 rlineto stroke } for\nshowpage\n' > "$1" ;;
  esac
}
mk_ps "$TMP/blank.ps" blank
mk_ps "$TMP/text.ps"  text
mk_ps "$TMP/noise.ps" noise
info "三张页已生成：$(sz "$TMP/blank.ps") / $(sz "$TMP/text.ps") / $(sz "$TMP/noise.ps") 字节"

RUNPPD=$TMP/br2140.ppd
if [ -n "$PPD" ]; then
  case "$PPD" in
    *.gz) zcat "$PPD" > "$RUNPPD" 2>/dev/null ;;
    *)    cp "$PPD" "$RUNPPD" ;;
  esac
fi
[ -s "$RUNPPD" ] && info "PPD 已就绪：$RUNPPD" || no_ "PPD 不可用（解压失败或文件为空）"

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

hr "4. 段2：raster -> rastertobrlaser -> PJL + PCL 光栅"
RUNOK=0
if [ "$RASTER_OK" -eq 1 ]; then
  if mk_dev "$TMP/text.raster" "$TMP/text.prn" && [ -s "$TMP/text.prn" ]; then
    RUNOK=1
    yes_ "rastertobrlaser 正常返回，产出 $(sz "$TMP/text.prn") 字节"
    has "$TMP/text.prn" '@PJL JOB' && yes_ "含 @PJL JOB（作业头）" || no_ "缺 @PJL JOB（没进 PJL 层）"
    if has "$TMP/text.prn" '@PJL ENTER LANGUAGE = PCL'; then
      yes_ "含 @PJL ENTER LANGUAGE = PCL —— 进入 PCL 光栅模式"
    elif has "$TMP/text.prn" 'ENTER LANGUAGE'; then
      hm_ "有 ENTER LANGUAGE 但不是 PCL，看下面的实际内容"
      tr -d '\000' < "$TMP/text.prn" | grep -a 'ENTER LANGUAGE' | head -2 | sed 's/^/      /'
    else
      no_ "缺 @PJL ENTER LANGUAGE = PCL —— 真机不会进入打印模式"
    fi
    has "$TMP/text.prn" "$ESC_E" && yes_ "含 ESC E（打印机复位）" || hm_ "未见 ESC E"
    if has "$TMP/text.prn" '@PJL SET RESOLUTION = 600'; then
      yes_ "含 @PJL SET RESOLUTION = 600 —— 600dpi 参数已下发"
    else
      info "未见 RESOLUTION=600 行（1200HQ 模式下改写为 RAS1200MODE，属正常）"
    fi
    has "$TMP/text.prn" '@PJL EOJ' && yes_ "含 @PJL EOJ（整页收尾）" || no_ "缺 @PJL EOJ —— 数据被掐断"
    if grep -qiE 'error|cannot|failed|unsupported' "$TMP/text.prn.err" 2>/dev/null; then
      hm_ "stderr 有异常字样："
      grep -aiE 'error|cannot|failed|unsupported' "$TMP/text.prn.err" | head -5 | sed 's/^/      /'
    else
      yes_ "stderr 无错误"
    fi
  else
    no_ "rastertobrlaser 没有产出数据"
    sed -n '1,8p' "$TMP/text.prn.err" 2>/dev/null | sed 's/^/      /'
  fi
else
  info "段1 没出 raster，段2 跳不过去"
fi
rm -f "$TMP/text.raster"

hr "5. 内容相关性（光栅压缩是否真在压缩）"
if [ "$RUNOK" -eq 1 ]; then
  chain_size() {   # chain_size <name> -> 打印设备流字节数
    if mk_raster "$TMP/$1.ps" "$TMP/$1.raster" && mk_dev "$TMP/$1.raster" "$TMP/$1.prn"; then
      sz "$TMP/$1.prn"
    else
      echo 0
    fi
    rm -f "$TMP/$1.raster"
  }
  B=$(chain_size blank); N=$(chain_size noise)
  info "空白页 ${B:-0} 字节 / 噪点页 ${N:-0} 字节"
  if [ "${B:-0}" -gt 0 ] && [ "${N:-0}" -gt "${B:-0}" ]; then
    if [ "$N" -ge $((B * 2)) ] || [ "$N" -ge 3000 ]; then
      yes_ "噪点页显著更大 —— 有实际图像数据在里头"
    else
      hm_ "噪点页增幅偏小，可能被强压缩（brlaser 对纯色页压缩率极高，噪点页正常会大很多）"
    fi
  else
    hm_ "体积没随内容增长，值得复核"
  fi
else
  info "段2 已失败，跳过"
fi

hr "6. 数据流抽样（人工复核用）"
if [ ! -s "$TMP/text.prn" ]; then
  info "没有产出（第 4 步已 FAIL），跳过"
else
  info "text.prn 前 96 字节："
  if have hexdump; then hexdump -C -n 96 "$TMP/text.prn" | sed 's/^/      /'
  elif have od;   then od -A d -t x1z -N 96 "$TMP/text.prn" | sed 's/^/      /'
  else info "      (无 hexdump/od)"; fi
  info "PJL 行（brlaser 的作业头/页头/收尾都在这几行）："
  tr -d '\000' < "$TMP/text.prn" | grep -a '@PJL' | cut -c1-100 | head -12 | sed 's/^/      /'
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
          yes_ "全链路产出 $(sz "$OUT") 字节（cupsd -> gstoraster -> rastertobrlaser -> backend）"
          if has "$OUT" '@PJL ENTER LANGUAGE = PCL' && has "$OUT" '@PJL EOJ'; then
            yes_ "全链路输出完整：PCL 语言 + EOJ 收尾"
          else
            no_ "全链路输出不完整，看 /var/log/cups/error_log"
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
  结论：brlaser 链路在软件层是完整的。
  真机接入后的顺序：
    lpinfo -m | grep -i br2140                 # 确认 drv 里的机型可见
    lpadmin -p BR2140 -E -v usb://Brother/HL-2140%20series -m drv:///brlaser.drv/br2140.ppd
    lp -d BR2140 /etc/hostname
  要换机型：把上面的 br2140.ppd 换成目标机型的 PCFileName（以下取自 brlaser.drv）：
    HL-2030 series -> br2030.ppd        HL-2270DW series -> br2270dw.ppd
    DCP-7030       -> br7030.ppd        DCP-7065DN       -> br7065dn.ppd
    MFC-7360N      -> br7360n.ppd       MFC-7460DN       -> br7460dn.ppd
  完整清单：grep -E 'ModelName|PCFileName' /usr/share/cups/drv/brlaser.drv
EOS
else
  printf '  结论：链路有断点，按上面 FAIL 逐条修。\n'
  printf '  常见补法：opkg install brlaser cups-filters ghostscript cups-client cups-ppdc\n'
fi
printf '  中间文件在 %s，可整体删除。\n' "$TMP"
