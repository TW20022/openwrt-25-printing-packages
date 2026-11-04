#!/bin/sh
# ============================================================
# HP LaserJet 1020 —— foo2zjs 链路 离线验证
#
# 用法:  sh test-foo2zjs-1020.sh             # 编码器直连（默认，几秒）
#        sh test-foo2zjs-1020.sh --full      # 再追加 cupsd 全链路（假 backend）
#        sh test-foo2zjs-1020.sh --quick     # 只跑依赖 + 编码器
#
# 链路：PS -> foomatic-rip -> foo2zjs-wrapper -> foo2zjs -> ZJS
# 判据：输出含 @PJL JOB + JZJZ + @PJL EOJ，且体积随内容增长。
#       foo2zjs **不发** @PJL ENTER LANGUAGE=ZJS（这是它与 hpcups 的显著区别）。
#
# 关于第 2 步为什么不走 cupsfilter：
#   本机 CUPS 2.4 的 cupsfilter 解析 PPD 时报
#   "ppdFilterLoadPPD: Last filter could not get determined"，会停在 PS->PDF，
#   根本走不到 foomatic-rip（旧脚本那串 FAIL 全是这个原因）。
#   所以这里直接调 foo2zjs-wrapper —— 它和 foomatic-rip 传给它的东西完全一样
#   （PS 在 stdin/文件里，参数来自 PPD 的 FoomaticRIPCommandLine）。
#   真正的 cupsd 串联由第 6 步验证。
#
# 无法离线验证：USB 枚举、sihp1020.dl 的固件握手、1020 对数据流的接受度。
# ============================================================
set -u

TAG=foo2zjs1020
TMP=/tmp/$TAG
QNAME=zz_${TAG}_selftest
FULL=auto
FILTDIR=${FILTDIR:-/usr/lib/cups/filter}
DEVURI='usb://HP/LaserJet%201020'

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

UEL=$(printf '\033%%-12345X')

mkdir -p "$TMP" || exit 1
# 上一轮留下的 PDF/半截产物会冒充本轮结果，先清掉
rm -f "$TMP"/*.raster "$TMP"/*.zjs "$TMP"/*.prn "$TMP"/*.spl 2>/dev/null

hr "0. 依赖检查"
PPD=''
for p in /usr/share/cups/model/HP-LaserJet_1020.ppd.gz /usr/share/cups/model/HP-LaserJet_1020.ppd \
         /usr/share/ppd/HP/HP-LaserJet_1020.ppd.gz; do
  [ -f "$p" ] && { PPD=$p; break; }
done
[ -n "$PPD" ] || PPD=$(find /usr/share/cups/model /usr/share/ppd -name 'HP-LaserJet_1020.ppd*' 2>/dev/null | head -1)
[ -n "$PPD" ] && yes_ "PPD: $PPD" || no_ "找不到 foo2zjs 的 HP-LaserJet_1020.ppd*（缺 foo2zjs）"

FRIP=''
[ -x "$FILTDIR/foomatic-rip" ] && FRIP=$FILTDIR/foomatic-rip
[ -z "$FRIP" ] && [ -x /usr/bin/foomatic-rip ] && FRIP=/usr/bin/foomatic-rip
[ -n "$FRIP" ] && yes_ "foomatic-rip: $FRIP" || no_ "缺 foomatic-rip（opkg install cups-filters）"

WRAP=/usr/bin/foo2zjs-wrapper
[ -x "$WRAP" ] && yes_ "foo2zjs-wrapper 在位" || no_ "缺 $WRAP（opkg install foo2zjs）"
[ -x /usr/bin/foo2zjs ] && yes_ "foo2zjs 编码器在位" || no_ "缺 /usr/bin/foo2zjs"
have gs && yes_ "ghostscript (gs) 在位" || no_ "缺 gs（wrapper 内部要靠它把 PS 转位图）"

# foomatic-rip 是 perl 脚本时，没有 perl 就整条链断
if [ -n "$FRIP" ]; then
  first=$(head -c 40 "$FRIP" 2>/dev/null | tr -d '\000')
  case "$first" in
    *perl*)
      if have perl; then yes_ "foomatic-rip 是 perl 脚本，perl 在位"
      else no_ "foomatic-rip 需要 perl，但系统没有 —— 链会在第一步断"; fi ;;
    *) info "foomatic-rip 不是 perl 脚本（或已被编译），跳过 perl 检查" ;;
  esac
fi

# 固件：foo2zjs 不走 hp-plugin，而是自己把 .dl 写进 /dev/usb/lp0
DL=''
for d in /lib/firmware/hp/sihp1020.dl /usr/share/foo2zjs/firmware/sihp1020.dl \
         /usr/share/foo2zjs/sihp1020.dl /root/sihp1020.dl; do
  [ -f "$d" ] && { DL=$d; break; }
done
if [ -n "$DL" ]; then
  yes_ "固件 sihp1020.dl: $DL（$(sz "$DL") 字节）"
else
  hm_ "没有 sihp1020.dl —— 编码链路能通，但 1020 冷启动后不会进打印模式"
  info "取得办法（三选一）："
  info "  1) zcat /usr/share/hplip/data/firmware/hp_laserjet_1020.fw.gz > /lib/firmware/hp/sihp1020.dl"
  info "  2) 从 foo2zjs 的 getweb 或固件包取 sihp1020.dl（1020/1020plus 通用）"
  info "  3) 确认 /dev/usb/lp0 存在后 cat sihp1020.dl > /dev/usb/lp0 手动灌一次"
fi

hr "1. 生成测试页（空白 / 文字 / 噪点）"
mk_ps() {
  case "$2" in
    blank) printf '%%!PS-Adobe-3.0\nshowpage\n' > "$1" ;;
    text)  printf '%%!PS-Adobe-3.0\n/Helvetica findfont 20 scalefont setfont\n72 760 moveto (CUPS selftest 1234567890) show\n72 700 moveto (foo2zjs ZJS chain) show\n0 0 moveto 400 0 lineto stroke\nshowpage\n' > "$1" ;;
    noise) printf '%%!PS-Adobe-3.0\n0 setlinewidth\n1 1 4000 { pop rand 500 mod 40 add rand 780 mod 40 add moveto rand 100 mod 8 add 0 rlineto stroke } for\nshowpage\n' > "$1" ;;
  esac
}
mk_ps "$TMP/blank.ps" blank
mk_ps "$TMP/text.ps"  text
mk_ps "$TMP/noise.ps" noise
info "三张页已生成：$(sz "$TMP/blank.ps") / $(sz "$TMP/text.ps") / $(sz "$TMP/noise.ps") 字节"

RUNPPD=$TMP/f2z.ppd
if [ -n "$PPD" ]; then
  case "$PPD" in
    *.gz) zcat "$PPD" > "$RUNPPD" 2>/dev/null ;;
    *)    cp "$PPD" "$RUNPPD" ;;
  esac
fi
[ -s "$RUNPPD" ] && info "PPD 已就绪：$RUNPPD" || no_ "PPD 不可用（解压失败或文件为空）"

# 编码器直连：参数用 1020 这一档的典型组合（-z1 = ZJS for LJ 1020）
ZW_ARGS="-z1 -P -L0"
encode() {   # encode <in.ps> <out.zjs>
  "$WRAP" $ZW_ARGS "$1" > "$2" 2> "$2.err"
  return $?
}

hr "2. 编码器直连：PS -> gs -> foo2zjs -> ZJS"
RUNOK=0
if [ -x "$WRAP" ]; then
  if encode "$TMP/text.ps" "$TMP/text.zjs" && [ -s "$TMP/text.zjs" ]; then
    RUNOK=1
    yes_ "foo2zjs-wrapper 正常返回，产出 $(sz "$TMP/text.zjs") 字节（参数 $ZW_ARGS）"
    has "$TMP/text.zjs" '@PJL JOB' && yes_ "含 @PJL JOB（foo2zjs 的作业头）" || no_ "缺 @PJL JOB"
    if has "$TMP/text.zjs" 'JZJZ'; then
      yes_ "含 JZJZ 魔数（ZJS 数据块已开始编码）"
    else
      no_ "缺 JZJZ —— 只有页头没有数据，真机会吐白纸"
    fi
    if has "$TMP/text.zjs" '@PJL EOJ'; then
      yes_ "含 @PJL EOJ（作业收尾，说明整页写完）"
    else
      no_ "缺 @PJL EOJ —— 数据可能在收尾前被掐断"
    fi
    has "$TMP/text.zjs" "$UEL" && yes_ "含 UEL（ESC%-12345X）" || hm_ "未见 UEL（部分 foo2zjs 版本只在头尾各发一次，可继续看第 3 步）"
    if has "$TMP/text.zjs" 'ENTER LANGUAGE'; then
      info "注意：输出里有 ENTER LANGUAGE，说明这不是 foo2zjs 而是别的编码器；核对 PPD 是否选错"
    else
      yes_ "没有 ENTER LANGUAGE —— 符合 foo2zjs 的特征（它直接进 ZJS）"
    fi
    if grep -qiE 'error|cannot|failed' "$TMP/text.zjs.err" 2>/dev/null; then
      hm_ "stderr 有提示字样（多为无关的 locale/terminfo 报警）："
      grep -aiE 'error|cannot|failed' "$TMP/text.zjs.err" | head -5 | sed 's/^/      /'
    else
      yes_ "stderr 无错误"
    fi
  else
    no_ "编码器没产出数据，看 stderr："
    sed -n '1,8p' "$TMP/text.zjs.err" 2>/dev/null | sed 's/^/      /'
  fi
else
  info "没有 $WRAP，跳过"
fi

hr "3. 定位用：单独验 foomatic-rip 这一层（不计入结论）"
if [ -n "$FRIP" ] && [ -s "$RUNPPD" ]; then
  PPD="$RUNPPD" DEVICE_URI="$DEVURI" \
    "$FRIP" -p "$RUNPPD" 1 root selftest 1 "PageSize=A4" "$TMP/text.ps" \
    > "$TMP/rip.out" 2> "$TMP/rip.err"
  rrc=$?
  if [ "$rrc" -eq 0 ] && has "$TMP/rip.out" 'JZJZ'; then
    yes_ "foomatic-rip 这一层也通（产出 $(sz "$TMP/rip.out") 字节，含 JZJZ）"
  else
    hm_ "foomatic-rip 单独调用没出 ZJS（退出码 $rrc）—— 只作定位参考"
    info "cupsd 里它由 cupsd 自己拼参数，与手工调用不完全等价；以第 6 步为准"
    sed -n '1,4p' "$TMP/rip.err" 2>/dev/null | sed 's/^/      /'
  fi
else
  info "缺 foomatic-rip 或 PPD，跳过"
fi

hr "4. 内容相关性（编码器是否真的在编码）"
if [ "$RUNOK" -eq 1 ]; then
  encode "$TMP/blank.ps" "$TMP/blank.zjs"
  encode "$TMP/noise.ps" "$TMP/noise.zjs"
  B=$(sz "$TMP/blank.zjs"); N=$(sz "$TMP/noise.zjs")
  info "空白页 ${B:-0} 字节 / 噪点页 ${N:-0} 字节"
  if [ "${B:-0}" -gt 0 ] && [ "${N:-0}" -gt "${B:-0}" ]; then
    if [ "$N" -ge 2000 ] && [ "$N" -gt $((B * 3)) ]; then
      yes_ "体积随内容单调增长 —— 编码器在按像素工作"
    else
      hm_ "噪点页增幅偏小，编码器可能只发了页头（真机会偏白）"
    fi
  else
    hm_ "体积没有随内容增长，编码器可能只发了页头"
  fi
else
  info "编码器已失败，跳过"
fi

hr "5. 数据流抽样（人工复核用）"
if [ ! -s "$TMP/text.zjs" ]; then
  info "没有产出（第 2 步已 FAIL），跳过"
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
          yes_ "全链路产出 $(sz "$OUT") 字节（cupsd -> foomatic-rip -> foo2zjs -> backend）"
          if has "$OUT" 'JZJZ' && has "$OUT" '@PJL EOJ'; then
            yes_ "全链路输出完整：JZJZ 数据 + EOJ 收尾"
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
  结论：foo2zjs 链路在软件层是完整的。
  1020 到手后的顺序：
    cat /lib/firmware/hp/sihp1020.dl > /dev/usb/lp0     # 每次冷启动都要，或交给 hotplug 脚本
    lpinfo -v | grep usb                                 # 应看到 usb://HP/LaserJet%201020
    lpadmin -p LJ1020 -E -v usb://HP/LaserJet%201020 -P <foo2zjs 的 1020 PPD>
    lp -d LJ1020 /etc/hostname
  与 hplip 的差别：不吃 HP 插件、不需要 hplip.state，但固件要自己灌。
EOS
else
  printf '  结论：链路有断点，按上面 FAIL 逐条修。\n'
  printf '  常见补法：opkg install foo2zjs cups-filters ghostscript cups-client perl\n'
fi
printf '  中间文件在 %s，可整体删除。\n' "$TMP"
