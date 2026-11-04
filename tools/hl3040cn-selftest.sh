#!/bin/sh
# ============================================================
# Brother HL-3040CN 打印链路自检 v8（无需真实打印机）
#   用法:  sh hl3040cn-selftest.sh
#   全程不需要插打印机，所有输出落在 /tmp
#   查"链路通不通"用本脚本；查"数据整不整"用 hl3040cn-probe.sh
#   v3: 轮询等待作业完成，完成后才评估与清理
#   v4: 用 lpstat -W not-completed -o 判断作业是否还在跑（lpstat -o 只接受打印机名）
#   v5: 第 1.5 步不再依赖 timeout 命令（设备 busybox 无此命令，会误报退出码 127），
#       改用纯 shell 看门狗；127 明确提示为"命令缺失"而非 filter 故障
#   v6: 判定从"含 XL2HB"升级为"含 XL2HB + @PJL EOJ 收尾"，能识别数据被截断；
#       日志摘要增加 cupswrapper 的每页/累计字节数行
#   v7: 假 backend 写失败不再 exit 0（旧版会让 CUPS 报"exited with no errors"），
#       改为非 0 + 记 savefile-backend.log；无文件时自动打印 df 与 backend 日志
#   v8: backend 由 CUPS 以 lp 身份启动，不是 root。输出目录改由脚本自建并 chmod 777，
#       输出路径由 DEVICE_URI 明确给出；先做可写性探测，失败时把 uid / 目录权限
#       打进 CUPS 日志并返回非 0（v7 仍会因 root 建的 0644 文件而 EACCES）
# ============================================================
PPD=/usr/share/ppd/hl3040cn.ppd
[ -f "$PPD" ] || PPD=/usr/share/cups/model/brother/hl3040cn.ppd
[ -f "$PPD" ] || PPD=$(ls /usr/share/cups/model/brother/hl3040cn.ppd.gz 2>/dev/null)
QNAME=HL3040CN_SELFTEST
TXT=/tmp/selftest.txt
PRN=/tmp/selftest.prn
ERR=/tmp/selftest.err

ok()   { printf '  [ OK ] %s\n' "$1"; }
bad()  { printf '  [FAIL] %s\n' "$1"; }
info() { printf '  ---- %s\n' "$1"; }
hr()   { printf '\n===== %s =====\n' "$1"; }

# 兼容 busybox：优先 strings/hexdump，退回 grep -a
have() { command -v "$1" >/dev/null 2>&1; }

hr "0. 环境检查"
[ -x /usr/sbin/cupsd ] && ok "cupsd 已安装" || bad "缺 cups（opkg install cups）"
for c in lpadmin lpstat lp cupsfilter; do
  p=$(command -v $c 2>/dev/null)
  [ -n "$p" ] && ok "$c -> $p" || bad "缺命令 $c（opkg install cups-client）"
done
[ -x /usr/lib/cups/filter/brhl3040cncupswrapper ] && ok "cupswrapper 过滤器在位" \
  || bad "缺 /usr/lib/cups/filter/brhl3040cncupswrapper（装 brhl3040cncupswrapper）"
[ -x /opt/brother/Printers/hl3040cn/brhl3040cnfilter ] && ok "filter wrapper 在位" \
  || bad "缺 /opt/brother/Printers/hl3040cn/brhl3040cnfilter（装 brhl3040cnfilter）"
[ -x /usr/bin/box86 ] && ok "box86 在位" || bad "缺 /usr/bin/box86（装 box86）"
# 在位不等于能跑：实测一次，顺带暴露 RUNPATH / libc 版本问题
# 注意 box86 -v 会先把 "sh: lscpu: not found" 打到 stdout，必须过滤掉这行
if [ -x /usr/bin/box86 ]; then
  bv=$(/usr/bin/box86 -v 2>&1 | tr -d '\000' | grep -i 'box86' | head -1)
  if [ -n "$bv" ]; then
    ok "box86 可执行：$bv"
  else
    bad "box86 -v 没有版本输出，可能缺库或 RUNPATH 坏了"
  fi
fi
for f in universal texttopdf pdftoraster rastertopwg; do
  [ -x /usr/lib/cups/filter/$f ] && ok "过滤器 $f" || bad "缺过滤器 $f（装 cups-filters）"
done
[ -n "$(ls /usr/lib/libpoppler.so* 2>/dev/null)" ] && ok "libpoppler 在位" || bad "缺 libpoppler（装 poppler）"
have gs && ok "ghostscript (gs) 在位" || bad "缺 gs（装 ghostscript）"
[ -f "$PPD" ] && ok "PPD -> $PPD" || bad "找不到 hl3040cn.ppd"

hr "1. 只跑过滤器链（不启 cupsd、不用打印机）"
printf 'CUPS self test page\nline 2 1234567890\n' > $TXT
info "输入: $TXT ($(wc -c < $TXT) 字节)"
cupsfilter -p "$PPD" -i text/plain $TXT > $PRN 2> $ERR
rc=$?
info "cupsfilter 退出码 $rc"
if [ $rc -ne 0 ]; then
  bad "过滤器链失败，错误如下："
  sed -n '1,20p' $ERR
else
  sz=$(wc -c < $PRN)
  info "输出: $PRN ($sz 字节)"
  if [ "$sz" -gt 1024 ]; then ok "输出非空且规模合理"; else bad "输出太小，可能中途失败"; fi

  # 在整个文件里找 XL2HB（v1 只看前 2KB，太短会漏）
  hit=0
  if have strings; then
    strings $PRN | grep -q 'XL2HB' && hit=1
  else
    grep -a 'XL2HB' $PRN >/dev/null 2>&1 && hit=1
  fi
  if [ $hit -eq 1 ]; then
    ok "命中 Brother XL2HB 语言标记 —— 数据是打印机原生格式"
  else
    # cupsfilter 的已知局限：universal 找不到"最后一个过滤器"时会在 PDF 阶段提前收工
    if head -c 64 $PRN | grep -qa '%PDF'; then
      info "输出是 PDF（cupsfilter 在 PDF 阶段提前收工，未走到 PPD 的 cupsFilter 链）"
      info "这是 cupsfilter 的已知局限，不代表链路故障 —— 以第 2 步 cupsd 全链路为准"
    else
      bad "整份输出没找到 XL2HB 且不是 PDF，需检查"
    fi
  fi

  # PJL 头检查（放开到前 4KB）
  if head -c 4096 $PRN | tr -d '\000' | grep -qa 'PJL'; then
    ok "PJL 头存在"
  else
    info "前 4KB 未见 PJL（看下面的可读内容判断实际格式）"
  fi

  info "输出的可读内容（前 12 行，能看出这是什么格式）："
  if have strings; then
    strings $PRN | head -12 | sed 's/^/      /'
  else
    head -c 4096 $PRN | tr -d '\000-\010\013-\037\177-\377' | head -12 | sed 's/^/      /'
  fi
  info "前 64 字节十六进制："
  if have hexdump; then
    hexdump -C $PRN | head -4 | sed 's/^/      /'
  elif have od; then
    od -A d -t x1z $PRN | head -4 | sed 's/^/      /'
  else
    info "      (设备上没有 hexdump/od，跳过)"
  fi
  info "filter 的 stderr（应有 NOTICE: Launching ... 行）："
  grep -aE 'NOTICE|ERROR|INFO' $ERR | head -10 | sed 's/^/      /'
fi

hr "1.5 直连 filter 快测（box86 + i386 filter，5 秒，不依赖 CUPS）"
# 手工构造 cupswrapper 的两个参数文件（格式取自源码 write_paper_inf / write_br_config）
printf 'paper type:\twidth\theight\nA4:\t4961\t7016\n' > /tmp/brpaper.inf
{
  printf '[HL3040CN]\nPageSize=A4\nBRMonoColor=Auto\nInputSlot=AutoSelect\n'
  printf 'BRResolution=Normal\nBRReverse=OFF\nBRColorMatching=Normal\nBRGray=OFF\n'
  printf 'BREnhanceBlkPrt=OFF\nBRImproveOutput=OFF\nSaturation=0\nBrightness=0\n'
  printf 'Contrast=0\nRedKey=0\nGreenKey=0\nBlueKey=0\nMediaType=Plain\n'
  printf 'Copies=1\nCollate=OFF\nTonerSaveMode=OFF\n'
} > /tmp/brparam.rc

# 16x16 的 PPM（P6），像素全灰
{ printf 'P6\n16 16\n255\n'; i=0; while [ $i -lt 256 ]; do printf '\200\200\200'; i=$((i+1)); done; } > /tmp/t.ppm
info "测试图: /tmp/t.ppm ($(wc -c < /tmp/t.ppm) 字节)"

FILTER=/opt/brother/Printers/hl3040cn/brhl3040cnfilter

# v5: 设备上通常没有 coreutils 的 timeout（busybox 精简版没编它），
#     直接调用会得到 127 且什么都没跑 —— 用纯 shell 看门狗替代。
run_to() {   # run_to <stdin> <超时秒> <stdout> <stderr> <命令...>
  rt_in=$1; rt_tmo=$2; rt_out=$3; rt_err=$4; shift 4
  "$@" < "$rt_in" > "$rt_out" 2> "$rt_err" &
  rt_pid=$!
  rt_n=0
  while kill -0 "$rt_pid" 2>/dev/null; do
    if [ "$rt_n" -ge "$rt_tmo" ]; then
      kill -9 "$rt_pid" 2>/dev/null
      wait "$rt_pid" 2>/dev/null
      return 124
    fi
    sleep 1
    rt_n=$((rt_n+1))
  done
  wait "$rt_pid"
  return $?
}

if [ -x "$FILTER" ]; then
  start=$(date +%s)
  run_to /tmp/t.ppm 90 /tmp/direct.prn /tmp/direct.err \
      "$FILTER" -pi /tmp/brpaper.inf -rc /tmp/brparam.rc
  drc=$?
  end=$(date +%s)
  info "退出码 $drc，耗时 $((end-start)) 秒，输出 $(wc -c < /tmp/direct.prn) 字节"
  if [ $drc -eq 124 ]; then
    info "已超过 90 秒，看门狗强制结束 —— 不是链路故障，但说明这条路径很慢"
  elif [ $drc -eq 127 ]; then
    info "退出码 127 = 命令/解释器找不到（如 box86 缺失或 wrapper 里的路径不对），不是 filter 本身的逻辑错误"
  fi
  # v6: 只看 XL2HB 不足以说明数据完整 —— 收尾标记 @PJL EOJ 才是。
  #     filter 的完整输出形如：
  #       UEL + @PJL JOB + @PJL ENTER LANGUAGE=XL2HB + <二进制> + UEL + @PJL EOJ + UEL
  eoj=$(grep -a -o '@PJL EOJ' /tmp/direct.prn 2>/dev/null | wc -l)
  if grep -aq 'XL2HB' /tmp/direct.prn && [ "$eoj" -ge 1 ] && ! grep -aq 'Reading pixels failed' /tmp/direct.err; then
    ok "直连成功：box86 → i386 filter 链路完好，含 XL2HB 数据段与 @PJL EOJ 收尾"
  elif grep -aq 'XL2HB' /tmp/direct.prn && [ "$eoj" -eq 0 ]; then
    bad "有 XL2HB 数据段但缺 @PJL EOJ —— 数据在收尾前被掐断，不是完整一页"
    info "filter 的 stderr："
    head -12 /tmp/direct.err | sed 's/^/      /'
  elif grep -aq 'XL2HB' /tmp/direct.prn; then
    bad "只出了 PJL 头（XL2HB），但像素处理失败 —— 看下面的 stderr"
    info "filter 的 stderr："
    head -12 /tmp/direct.err | sed 's/^/      /'
  else
    bad "直连失败：filter 没产出 XL2HB"
    info "filter 的 stderr："
    head -12 /tmp/direct.err | sed 's/^/      /'
  fi
  info "filter stderr 摘要："
  grep -aE 'INFO|ERROR|Box86|box86' /tmp/direct.err | head -6 | sed 's/^/      /'
else
  bad "找不到 $FILTER"
fi

hr "2. 全链路：cupsd + 假 backend（把打印数据存成文件）"
BACKEND=/usr/lib/cups/backend/savefile
OUTDIR=/tmp/hl3040cn-out
# v8: backend 不是以 root 跑的（CUPS 用 lp 身份启动它），所以
#     ① 不能往 /tmp 下 root 建的 0644 文件里写（sticky 位下连删都删不掉）
#     ② 目录必须显式放开写权限
#     改成：输出目录由本脚本建并 chmod 777，输出路径由 DEVICE_URI 明确指定，
#     写不了时把 uid / 目录权限打到 CUPS 日志里并返回非 0，不再"哑巴成功"。
rm -rf $OUTDIR; mkdir -p $OUTDIR; chmod 777 $OUTDIR
cat > $BACKEND <<'EOS'
#!/bin/sh
# 假 backend：把 CUPS 送来的打印数据原样存盘，不连打印机
[ $# -eq 0 ] && exit 0          # 设备发现调用，直接返回
[ "$1" = "-" ] && exit 0

out="${DEVICE_URI#savefile:}"
case "$out" in /*) ;; *) out="" ;; esac
[ -n "$out" ] || out="/tmp/savefile-$1-$2.prn"
dir=`dirname "$out"`

mkdir -p "$dir" 2>/dev/null
if ! ( : > "$dir/.wtest.$$" ) 2>/dev/null; then
  echo "ERROR: savefile: dir not writable: $dir (uid=`id -u` user=`id -un`) /tmp=`ls -ld /tmp 2>&1 | cut -d' ' -f1,3,4`" >&2
  exit 1
fi
rm -f "$dir/.wtest.$$"

cat > "$out"
rc=$?
if [ $rc -eq 0 ]; then
  bytes=`wc -c < "$out"`
  echo "`date '+%F %T'` job=$1 user=$2 uid=`id -u` ok bytes=$bytes -> $out" >> "$dir/savefile-backend.log"
  echo "INFO: savefile: saved $bytes bytes to $out"
  exit 0
fi
echo "`date '+%F %T'` job=$1 user=$2 uid=`id -u` FAILED rc=$rc -> $out" >> "$dir/savefile-backend.log" 2>/dev/null
echo "ERROR: savefile: write to $out failed (rc=$rc)"
exit 1
EOS
chmod 755 $BACKEND
info "假 backend 已就位: $BACKEND"
info "输出目录: $OUTDIR (0777)，backend 以 lp 身份运行也能写"

/etc/init.d/cupsd enable >/dev/null 2>&1
/etc/init.d/cupsd start >/dev/null 2>&1
sleep 2
cupsctl --debug-logging >/dev/null 2>&1
# v2 修复：cupsctl 会触发 cupsd 重启，必须等它稳定，否则 lpadmin 会报 Bad file descriptor
sleep 4
lpstat -r >/dev/null 2>&1 && ok "cupsd 正在运行" || bad "cupsd 未启动"

lpadmin -x $QNAME >/dev/null 2>&1
made=0
for i in 1 2 3; do
  if lpadmin -p $QNAME -v savefile:$OUTDIR/job.prn -P "$PPD" -E 2>/tmp/lpadmin.err; then
    made=1; break
  fi
  info "lpadmin 第 $i 次失败，3 秒后重试..."
  sleep 3
done
if [ $made -eq 1 ]; then
  ok "已建队列 $QNAME（设备 URI: savefile:$OUTDIR/job.prn）"
else
  bad "lpadmin 三次都失败："
  sed -n '1,10p' /tmp/lpadmin.err
  info "手动兜底： CUPS_SERVER=/var/run/cups/cups.sock lpadmin -p $QNAME -v savefile:$OUTDIR/job.prn -P $PPD -E"
fi
lpstat -p $QNAME 2>&1 | sed 's/^/      /'

rm -f $OUTDIR/job*.prn
jid=$(lp -d $QNAME $TXT 2>&1 | sed -n 's/.*request id is \([^ ]*\).*/\1/p')
[ -n "$jid" ] && ok "作业已提交: $jid" || bad "lp 提交失败"
jnum=$(printf '%s' "$jid" | sed -n 's/.*-\([0-9]*\)$/\1/p')

# v4: A4 raster 原始数据约 104MB，经 box86 模拟压缩需要几十秒到几分钟。
# 正确判断"作业是否还在跑"：lpstat -o 只接受打印机名，不接受作业号！
# 必须用 -W not-completed 列出所有未完成作业，再按第一列（作业号）匹配。
job_running() {
  lpstat -W not-completed -o 2>/dev/null | awk '{print $1}' | grep -qx "$jid"
}

found=0
start=$(date +%s)
n=0
last_report=0
while [ $n -lt 300 ]; do   # 最长 300 x 2s = 10 分钟
  if ! job_running; then
    for f in $OUTDIR/job*.prn; do
      [ -f "$f" ] && found=1
    done
    break
  fi
  sleep 2
  n=$((n+1))
  now=$(date +%s)
  if [ $((now-start-last_report)) -ge 10 ]; then
    last_report=$((now-start))
    cur=0
    for f in $OUTDIR/job*.prn; do [ -f "$f" ] && cur=$(wc -c < "$f"); done
    info "处理中... 已等待 $((now-start)) 秒，落盘 $((${cur:-0}/1024)) KB"
  fi
done
waited=$(( $(date +%s) - start ))
if job_running; then
  bad "等待 ${waited} 秒作业仍未结束（可能确实很慢，或已卡死）"
  info "作业可能仍在跑，本脚本不会删除队列（见第 3 步）"
fi
if [ $found -eq 1 ]; then
  info "等待了约 ${waited} 秒"
  for f in $OUTDIR/job*.prn; do
    [ -f "$f" ] || continue
    info "落盘文件: $f ($(wc -c < $f) 字节)"
    lang=$(grep -a -o '@PJL ENTER LANGUAGE=XL2HB' "$f" 2>/dev/null | wc -l)
    eoj=$(grep -a -o '@PJL EOJ' "$f" 2>/dev/null | wc -l)
    info "结构: 页(ENTER)=$lang  EOJ=$eoj"
    if grep -aq 'XL2HB' "$f" && [ "$eoj" -ge 1 ]; then
      ok "该文件含 XL2HB 且以 @PJL EOJ 收尾 —— 全链路打通且数据完整"
    elif grep -aq 'XL2HB' "$f"; then
      bad "含 XL2HB 但缺 @PJL EOJ —— cupswrapper 没把整页数据喂完（数据被截断）"
      info "对比：同一份文档在正常机器上约 78 KB（A4 600dpi 单页）"
      info "如果只有十几 KB，且日志里 'page N done' 的字节数明显小于 104 MB，就是喂数据环节丢了内容"
    else
      bad "该文件含 XL2HB 失败（当前 $(wc -c < "$f") 字节）"
      info "文件头部可读内容："
      head -c 4096 "$f" | tr -d '\000' | head -8 | sed 's/^/      /'
    fi
  done
else
  bad "作业结束但没有生成落盘文件"
  info "backend 自己的日志（$OUTDIR/savefile-backend.log）:"
  if [ -f $OUTDIR/savefile-backend.log ]; then
    tail -5 $OUTDIR/savefile-backend.log | sed 's/^/      /'
  else
    info "      (空 —— backend 要么没被调用，要么在写日志前就退出了)"
  fi
  info "backend 在 CUPS 日志里的报错（这里会带 uid 和目录权限）:"
  grep -a 'savefile' /var/log/cups/error_log 2>/dev/null | grep -aiE 'ERROR|not writable|Permission|failed' | tail -5 | sed 's/^/      /'
  info "输出目录与 /tmp 的权限（backend 以 lp 身份跑，必须对 other 可写）:"
  ls -ld /tmp $OUTDIR 2>&1 | sed 's/^/      /'
  df -h /tmp 2>/dev/null | sed 's/^/      /'
  info "手工以 lp 身份验证一次（关键：不是 root 能写就行）:"
  info "      su lp -s /bin/sh -c 'echo hi > $OUTDIR/manual.prn' ; ls -l $OUTDIR/manual.prn"
fi

info "作业状态："
lpstat -W all -o 2>&1 | sed 's/^/      /'
info "error_log 中本次作业（Job $jnum）的相关行："
if [ -n "$jnum" ]; then
  grep -a "\[Job $jnum\]" /var/log/cups/error_log 2>/dev/null | tail -60 | sed 's/^/      /'
else
  grep -aE 'Job|brhl|box86|filter' /var/log/cups/error_log 2>/dev/null | tail -40 | sed 's/^/      /'
fi
info "日志中的 ERROR / Launchning / 数据量行（不受窗口截断影响）："
grep -aE 'ERROR|Launchning|ready to print|done, .*bytes|total .*bytes|Reading pixels' /var/log/cups/error_log 2>/dev/null | tail -20 | sed 's/^/      /'

hr "3. 收尾"
if job_running; then
  info "作业仍在处理，为避免杀掉正在跑的 filter，本次不删除队列"
  info "看完结果后可手动清理： lpadmin -x $QNAME"
else
  lpadmin -x $QNAME >/dev/null 2>&1 && ok "已删除测试队列 $QNAME"
fi
info "假 backend 保留在 $BACKEND，下次可直接复用；不需要可 rm"
info "本次落盘样本留在 $OUTDIR（0777，backend 以 lp 身份写入）"
info "如要关调试日志： cupsctl --no-debug-logging"
cat <<'EON'

判读：
  第 1 步输出 PDF 属正常（cupsfilter 局限），以第 1.5 / 2 步为准
  第 1.5 步含 XL2HB -> box86 + i386 filter 链路本身没问题
  第 2 步含 XL2HB   -> cupsd 调度 / 过滤器链 / 后端也全部打通
  插真机时把 device-uri 换成 usb://Brother/HL-3040CN%20series 即可
  可忽略的日志噪音：
    sh: lscpu: not found            box86 探测 CPU 型号，找不到就按默认值跑，不影响结果
    Option BRReverse/Copies not found  PPD 未定义该组选项时 cupswrapper 打日志，属正常
    ColorManager service unknown    设备没装 colord，颜色管理降级为 Off，正常
EON
