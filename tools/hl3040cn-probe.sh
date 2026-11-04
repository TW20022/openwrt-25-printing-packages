#!/bin/sh
# ============================================================
# Brother HL-3040CN 打印数据完整性探针 v5（无需真实打印机）
#
#   hl3040cn-selftest.sh 只回答"链路通不通"，本脚本回答"数据整不整"：
#   同一份文档连打 N 次，逐份统计 PJL 结构，判断是整页输出还是被截断。
#
#   判读依据（从 brhl3040cnfilter.bin 的字符串表确认）：
#     \033%-12345X                 UEL，通用语言退出
#     @PJL JOB NAME="..."          作业开始
#     @PJL ENTER LANGUAGE=XL2HB    每页一次
#     ) BROTHER XL2HB;             每页数据块开始
#     @PJL EOJ NAME="..."          作业收尾 —— 被截断时不会有
#   完整输出的结构是：
#     UEL + JOB + ... + ENTER LANGUAGE + )BROTHER + <二进制> + UEL + EOJ + UEL
#
#   用法： sh hl3040cn-probe.sh [次数，默认 3]
#
#   v3: backend 以 lp 身份运行，不能写 root 建的 0644 文件（sticky 位连删都删不掉）。
#       输出目录改为脚本自建并 chmod 777，路径由 DEVICE_URI 指定；写不了时
#       把 uid / 目录权限打进 CUPS 日志并返回非 0，不再"哑巴成功"
#   v4: 一致性判据从"整文件大小相同"改为"数据段指纹相同"。
#       PJL 头里有打印时间戳（@PJL PRINTLOG ITEM = 2,...），每次必然不同，
#       长度还会差 1 字节，用整文件大小比对会误报"存在时序差异"
#   v5: 设备的 busybox grep 没有 -b，v4 靠 grep -abo 取偏移的做法失效，
#       指纹退化成整文件、三个样本被判成三种。改为"从 EOF 往前取等长窗口"
#       做指纹：头部变长变短都不影响，尾部被截断则立刻不等
# ============================================================
PPD=/usr/share/ppd/hl3040cn.ppd
[ -f "$PPD" ] || PPD=/usr/share/cups/model/brother/hl3040cn.ppd
Q=HL_PROBE
B=/usr/lib/cups/backend/savefile
TXT=/tmp/probe.txt
N=${1:-3}
OUTDIR=/tmp/hl3040cn-out
JOB=$OUTDIR/job.prn

ok()   { printf '  [ OK ] %s\n' "$1"; }
bad()  { printf '  [FAIL] %s\n' "$1"; }
warn() { printf '  [ ?? ] %s\n' "$1"; }
info() { printf '  ---- %s\n' "$1"; }
hr()   { printf '\n===== %s =====\n' "$1"; }

# 统计某个字面量在二进制文件里出现的次数
cnt() { grep -a -o -- "$2" "$1" 2>/dev/null | wc -l | tr -d ' '; }

# 尾部 120 字节可读化
tailview() { tail -c 120 "$1" | tr -c '[:print:]\n' '.'; }

# 压缩数据段的指纹。
# 不能从文件头往后切：PJL 头里有打印时间戳（@PJL PRINTLOG ITEM = 2,...），
# 每次不同，而且字符串长度偶尔差 1 字节，一旦按固定偏移切就会整体错位。
# 改成"从文件末尾往前取同样多的字节"——EOF 对齐，头部怎么变都不影响，
# 数据被截断则会立刻体现在这段尾部上。
# 设备上的 busybox grep 没有 -b，所以也不能靠 grep 算偏移。
sig() {
  [ -n "$SIGLEN" ] || { md5sum "$1" 2>/dev/null | cut -d' ' -f1; return; }
  tail -c "$SIGLEN" "$1" 2>/dev/null | md5sum | cut -d' ' -f1
}

# 计算比对窗口：所有样本里最短的那份，再留 700 字节给 PJL 头
sig_window() {
  min=0
  for w in "$@"; do
    s=$(wc -c < "$w")
    if [ "$min" -eq 0 ] || [ "$s" -lt "$min" ]; then
      min=$s
    fi
  done
  if [ "$min" -gt 4096 ]; then
    SIGLEN=$((min - 700))
  else
    SIGLEN=$((min / 2))
  fi
  [ "$SIGLEN" -ge 256 ] || SIGLEN=""
}

# 分析一份落盘文件
analyse() {
  f=$1
  sz=$(wc -c < "$f")
  uel=$(cnt "$f" '%-12345X')
  lang=$(cnt "$f" '@PJL ENTER LANGUAGE=XL2HB')
  blk=$(cnt "$f" ') BROTHER XL2HB;')
  eoj=$(cnt "$f" '@PJL EOJ')

  printf '  %-28s %8s 字节  UEL=%s  页(ENTER)=%s  块=%s  EOJ=%s\n' \
         "$(basename "$f")" "$sz" "$uel" "$lang" "$blk" "$eoj"

  # 完整性判定：有 EOJ 才说明 filter 走完了收尾流程
  if [ "$eoj" -ge 1 ] && [ "$lang" -ge 1 ]; then
    if tail -c 200 "$f" | grep -aq '%-12345X'; then
      ok "结构完整（含 EOJ 且以 UEL 结束）"
    else
      warn "有 EOJ 但尾部没有 UEL，收尾可能不完整"
    fi
  elif [ "$lang" -ge 1 ]; then
    bad "有 XL2HB 数据段但没有 @PJL EOJ —— 数据在收尾前被掐断"
  else
    bad "没有 XL2HB 数据段"
  fi
  info "尾部: $(tailview "$f")"
}

hr "0. 准备"
# backend 不是 root 跑的（CUPS 以 lp 身份启动），所以输出目录必须显式放开写权限；
# 写失败时返回非 0 并把原因打到 CUPS 日志，避免"作业成功但没文件"。
cat > $B <<'EOS'
#!/bin/sh
[ $# -eq 0 ] && exit 0
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
chmod 755 $B
ok "假 backend: $B"
printf 'probe page\nline 2 1234567890\n' > $TXT
info "测试文档: $TXT ($(wc -c < $TXT) 字节)，连打 $N 次"
rm -rf $OUTDIR; mkdir -p $OUTDIR; chmod 777 $OUTDIR
info "输出目录: $OUTDIR (0777)，backend 以 lp 身份运行也能写"

/etc/init.d/cupsd start >/dev/null 2>&1
sleep 2
lpstat -r >/dev/null 2>&1 || { bad "cupsd 起不来"; exit 1; }

lpadmin -x $Q >/dev/null 2>&1
made=0
for i in 1 2 3; do
  lpadmin -p $Q -v savefile:$JOB -P "$PPD" -E 2>/dev/null && { made=1; break; }
  sleep 3
done
[ $made -eq 1 ] && ok "队列 $Q 就绪（设备 URI: savefile:$JOB）" || { bad "lpadmin 失败"; exit 1; }

job_wait() {   # job_wait <作业号>
  jw=0
  while [ $jw -lt 120 ]; do
    lpstat -W not-completed -o 2>/dev/null | awk '{print $1}' | grep -qx "$1" || return 0
    sleep 2; jw=$((jw+2))
  done
  return 1
}

hr "1. 连打 $N 次，逐份分析"
i=1
while [ $i -le $N ]; do
  rm -f $JOB
  jid=$(lp -d $Q $TXT 2>&1 | sed -n 's/.*request id is \([^ ]*\).*/\1/p')
  if [ -z "$jid" ]; then bad "第 $i 次提交失败"; break; fi
  job_wait "$jid" || warn "第 $i 次作业 120 秒未结束"
  sleep 1
  got=0
  if [ -f $JOB ] && [ -s $JOB ]; then
    cp $JOB "$OUTDIR/run$i.prn"
    got=1
  fi
  if [ $got -eq 1 ]; then
    analyse "$OUTDIR/run$i.prn"
  else
    bad "第 $i 次没有落盘文件（期望 $JOB）"
    if [ -f $OUTDIR/savefile-backend.log ]; then
      info "backend 日志末 3 行:"
      tail -3 $OUTDIR/savefile-backend.log | sed 's/^/      /'
    else
      info "没有 $OUTDIR/savefile-backend.log —— backend 可能压根没被调用"
    fi
    info "backend 在 CUPS 日志里的报错:"
    grep -a 'savefile' /var/log/cups/error_log 2>/dev/null | grep -aiE 'ERROR|not writable|Permission|failed' | tail -3 | sed 's/^/      /'
    info "目录权限: $(ls -ld /tmp $OUTDIR 2>&1 | tr '\n' ' ')"
    info "/tmp 剩余空间: $(df -h /tmp 2>/dev/null | awk 'NR==2{print $4" / 共 "$2}')"
  fi
  i=$((i+1))
done

hr "2. 一致性对比"
if ls $OUTDIR/run* >/dev/null 2>&1; then
  # 先看整文件大小
  szs=$(for f in $OUTDIR/run*; do wc -c < "$f"; done | sort -n | uniq | tr '\n' ' ')
  info "各次字节数（去重）: $szs"

  # 再比压缩数据段指纹 —— 这才是"输出是否确定性"的真正判据
  sig_window $OUTDIR/run*
  if [ -n "$SIGLEN" ]; then
    info "比对窗口: 各文件末尾 $SIGLEN 字节（EOF 对齐，跳过 PJL 头）"
  else
    info "样本太小，比对窗口退化为整文件"
  fi

  sigs=""
  printf '  %-10s %8s  %s\n' file bytes md5
  for f in $OUTDIR/run*; do
    printf '  %-10s %8s  %s\n' "$(basename "$f")" "$(wc -c < "$f")" "$(sig "$f")"
    sigs="$sigs $(sig "$f")"
  done
  nsig=$(printf '%s\n' $sigs | sort -u | wc -l | tr -d ' ')

  if [ "$nsig" -eq 1 ]; then
    ok "数据段完全一致 —— 输出确定性，无竞态、无丢字节"
    nsz=$(printf '%s\n' $szs | tr ' ' '\n' | grep -c .)
    if [ "$nsz" -gt 1 ]; then
      info "整文件大小有 $nsz 种（相差几字节），来自 PJL 头里的打印时间戳："
      grep -ah 'PRINTLOG ITEM = 2' $OUTDIR/run* 2>/dev/null | sed 's/^/      /'
      info "时间戳字符串长度会差 1 字节，属正常，不是数据丢失"
    fi
  else
    warn "数据段指纹有 $nsig 种 —— 同样的输入产出了不同的压缩数据，需查时序/丢字节"
    info "可能性：cupswrapper 短写（r2 已修）、box86 竞态、CUPS 送来的 raster 不一致"
    info "可对比两次的差异位置： tail -c $SIGLEN run1.prn > /tmp/a ; diff 或 cmp -l"
  fi
else
  bad "一份样本都没有，跳过一致性对比（先解决第 1 步的落盘问题）"
fi

hr "3. 收尾"
lpadmin -x $Q >/dev/null 2>&1 && ok "已删除队列 $Q"
info "样本保留在 $OUTDIR/ 供进一步分析"
info "如需手工复查某一页： grep -a -o '%-12345X' <文件> | wc -l"
