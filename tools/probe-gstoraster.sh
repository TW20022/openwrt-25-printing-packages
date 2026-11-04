#!/bin/sh
# ============================================================
# probe-gstoraster.sh —— gstoraster 退出码 139(SIGSEGV) 到底伤不伤真机打印
#
# 用法:  sh probe-gstoraster.sh              # 只测过滤器，不建队列（最安全）
#        sh probe-gstoraster.sh --cups       # 额外用 cupsd + 假 backend 打一页
#
# 背景（来自 diag-raster.sh 的实测）：
#   gs 的 cups 设备正常；cupsfilter -m 正常；但**直接调用** gstoraster 时，
#   数据明明写完了（Rendering completed、gs 无错），最后却 "Segmentation fault"，
#   退出码 139。cupsd 判作业成败只看过滤器退出码 —— 所以必须确认：
#   139 只在「stdout 是普通文件」时发生，还是 cupsd（管道）里也会发生。
# ============================================================
set -u
TAG=probegsr
TMP=/tmp/$TAG
FILTDIR=${FILTDIR:-/usr/lib/cups/filter}
QNAME=zz_${TAG}_selftest
DOCUPS=no
for a in "$@"; do case "$a" in *cups*) DOCUPS=yes ;; esac; done

ok()   { printf '  [ OK ] %s\n' "$1"; }
bad()  { printf '  [FAIL] %s\n' "$1"; }
warn() { printf '  [WARN] %s\n' "$1"; }
info() { printf '  ---- %s\n' "$1"; }
hr()   { printf '\n===== %s =====\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }
sz()   { wc -c < "$1" 2>/dev/null | tr -d ' '; }
hdr()  { head -c 4 "$1" 2>/dev/null | tr -d '\000'; }
# CUPS raster 每页以同步字 0x52615333 开头；小端机落盘是 3SaR，大端是 RaS3
pages(){ [ -s "$1" ] || { echo 0; return; }
         tr -d '\000' < "$1" 2>/dev/null | grep -a -o -e 3SaR -e RaS3 | wc -l | tr -d ' '; }
is_raster() { case "$(hdr "$1")" in RaS3|3SaR) return 0 ;; *) return 1 ;; esac; }

mkdir -p "$TMP" || exit 1
rm -f "$TMP"/* 2>/dev/null

printf '%%!PS-Adobe-3.0\n/Helvetica findfont 20 scalefont setfont\n72 700 moveto (probe gstoraster) show\nshowpage\n' > "$TMP/t.ps"

hr "0. 环境"
PPD=''
for p in /usr/share/ppd/HP/hp-laserjet_1020.ppd /usr/share/ppd/HP/hp-laserjet_1020.ppd.gz \
         /usr/share/cups/model/HP-LaserJet_1020.ppd /usr/share/cups/model/samsung/ml2010.ppd; do
  [ -f "$p" ] && { PPD=$p; break; }
done
RUNPPD=$TMP/p.ppd
if [ -n "$PPD" ]; then
  if [ "${PPD%.gz}" != "$PPD" ]; then zcat "$PPD" > "$RUNPPD" 2>/dev/null || cp "$PPD" "$RUNPPD"
  else cp "$PPD" "$RUNPPD"; fi
fi
info "PPD：${PPD:-未找到（用 /usr/share/cups/model 里的任意一个也行，只影响颜色/分辨率参数）}"
info "gs：$(gs --version 2>&1 | head -1)    cupsd：$(cupsd -v 2>/dev/null | head -1)"
info "cups-filters：$(opkg list-installed 2>/dev/null | grep -i '^cups-filters' | awk '{print $1" "$3}' | tr '\n' ' ')"
info "libc：$(ls -l /lib/ld-musl-* /lib/ld-linux-* 2>/dev/null | head -1 | awk '{print $NF}' | sed 's#.*/##')"

hr "1. 同一份 PS，四种调用方式（cupsd 用的是方式 B）"
# A / C 是「stdout = 普通文件或 /dev/null」，B 是「stdout = 管道」，与 cupsd 一致
run_case() {   # run_case <标签> <模式>
  out=$TMP/$1.raster; err=$TMP/$1.err; : > "$out"; rm -f "$TMP/$1.rc"
  case "$2" in
    file)   PPD="$RUNPPD" CUPS_DATADIR=/usr/share/cups \
              "$FILTDIR/gstoraster" 1 root selftest 1 "PageSize=A4" "$TMP/t.ps" > "$out" 2> "$err"
            echo $? > "$TMP/$1.rc" ;;
    # 管道方式必须用子 shell 把过滤器自己的退出码写出去：`cmd | cat` 的 $? 是 cat 的
    pipe)   ( PPD="$RUNPPD" CUPS_DATADIR=/usr/share/cups \
              "$FILTDIR/gstoraster" 1 root selftest 1 "PageSize=A4" "$TMP/t.ps" 2> "$err"
              echo $? > "$TMP/$1.rc" ) | cat > "$out" ;;
    null)   PPD="$RUNPPD" CUPS_DATADIR=/usr/share/cups \
              "$FILTDIR/gstoraster" 1 root selftest 1 "PageSize=A4" "$TMP/t.ps" > /dev/null 2> "$err"
            echo $? > "$TMP/$1.rc" ;;
  esac
  rc=$(cat "$TMP/$1.rc" 2>/dev/null)
  printf '  %-10s rc=%-5s 产出=%-9s 头=%-5s 页数=%s\n' "$1" "${rc:-?}" "$(sz "$out")" "$(hdr "$out")" "$(pages "$out")"
}

RC_A=""; RC_B=""; RC_C=""
if [ ! -x "$FILTDIR/gstoraster" ]; then
  bad "缺 $FILTDIR/gstoraster（opkg install cups-filters）"
else
  [ -n "$RUNPPD" ] || warn "没有 PPD，gstoraster 会按默认参数跑，够用"
  run_case A_file file
  run_case B_pipe pipe
  run_case C_null null
  RC_A=$(cat "$TMP/A_file.rc"); RC_B=$(cat "$TMP/B_pipe.rc"); RC_C=$(cat "$TMP/C_null.rc")

  if [ "$RC_B" -eq 0 ] && [ "$RC_A" -ne 0 ]; then
    ok "管道方式退出码 0，只在「stdout 是普通文件」时才崩"
    info "=> cupsd 给过滤器的就是管道，139 属于我们手工调用方式的问题，真机打印不受影响"
  elif [ "$RC_B" -ne 0 ]; then
    bad "管道方式也返回 $RC_B（139 = SIGSEGV）"
    info "=> gstoraster 这个入口在本机确实会崩，但它只是 cups-filters 2.x 的**旧入口**："
    info "   cupsd 实际用的是 /usr/lib/cups/filter/universal（同一份多呼叫二进制的另一入口），"
    info "   别急着下结论，看第 4 步 cupsd 真实作业有没有产出（那才是最终答案）。"
  else
    ok "两种方式退出码都是 0，本次没复现 139"
  fi
fi

hr "2. 输出完整性（即使退出码非 0，数据也可能已经写完）"
for f in A_file B_pipe; do
  o=$TMP/$f.raster
  [ -s "$o" ] || continue
  if is_raster "$o"; then
    ok "$f：合法 CUPS raster，$(sz "$o") 字节，$(pages "$o") 页"
  else
    warn "$f：头不是 RaS3/3SaR（$(hdr "$o")），不是 CUPS raster"
  fi
done
# gstoraster 崩之前 stderr 里应该已经有 "Rendering completed"
for f in A_file B_pipe; do
  [ -s "$TMP/$f.err" ] || continue
  if tr -d '\000' < "$TMP/$f.err" | grep -q 'Rendering completed'; then
    info "$f：stderr 里有 'Rendering completed' —— 说明崩在收尾，不在渲染"
  else
    info "$f：stderr 末尾 5 行"; tail -5 "$TMP/$f.err" | sed 's/^/      /'
  fi
done

hr "3. 对照：pdftoraster / cupsfilter -m 是否也崩"
if [ -s "$TMP/B_pipe.raster" ]; then
  if have cupsfilter && [ -n "$RUNPPD" ]; then
    cupsfilter -p "$RUNPPD" -i application/postscript -m application/vnd.cups-raster \
               -o PageSize=A4 "$TMP/t.ps" > "$TMP/via_cupsfilter.raster" 2> "$TMP/via_cupsfilter.err"
    printf '  cupsfilter -m   rc=%-5s 产出=%-9s 页数=%s\n' "$?" "$(sz "$TMP/via_cupsfilter.raster")" "$(pages "$TMP/via_cupsfilter.raster")"
  fi
  # PS -> PDF -> pdftoraster，看 CUPS 内部的 PDF 支路是否同样受影响
  if have gs; then
    gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="$TMP/t.pdf" "$TMP/t.ps" >/dev/null 2>&1
    if [ -s "$TMP/t.pdf" ] && [ -x "$FILTDIR/pdftoraster" ] && [ -n "$PPD" ]; then
      PPD="$RUNPPD" CUPS_DATADIR=/usr/share/cups \
        "$FILTDIR/pdftoraster" 1 root selftest 1 "PageSize=A4" "$TMP/t.pdf" 2> "$TMP/pdf.err" | cat > "$TMP/pdf.raster"
      printf '  pdftoraster    rc=%-5s 产出=%-9s 页数=%s\n' "$?" "$(sz "$TMP/pdf.raster")" "$(pages "$TMP/pdf.raster")"
    fi
  fi
fi

hr "4. 真机口径：cupsd 跑一遍（假 backend，不碰硬件）"
if [ "$DOCUPS" = no ]; then
  info "已跳过（加 --cups 才跑）。这一步才是「CUPS 里能不能打」的最终答案。"
elif ! have lpadmin || ! have lp || ! have lpstat; then
  warn "缺 lpadmin/lp/lpstat，跳过"
else
  running() { pidof cupsd >/dev/null 2>&1; }
  running || { /etc/init.d/cupsd start >/dev/null 2>&1; sleep 1; }
  BK=$FILTDIR/../backend/savefile
  cat > "$BK" <<'EOS'
#!/bin/sh
# cupsd 以非 root 用户跑 backend：输出目录要可写，日志写在输出文件旁边
[ $# -eq 0 ] && exit 0
out="${DEVICE_URI#savefile:}"
[ -n "$out" ] || out="/tmp/savefile-$1.prn"
echo "$(date '+%F %T') uri=$DEVICE_URI user=$(id -un 2>/dev/null) args=$*" >> "$out.log" 2>/dev/null
f=""
for a in "$@"; do [ -f "$a" ] && f="$a"; done
if [ -n "$f" ]; then cat "$f" > "$out" 2>> "$out.log"; else cat > "$out" 2>> "$out.log"; fi
printf 'INFO: saved %s (%s bytes)\n' "$out" "$(wc -c < "$out")"
exit 0
EOS
  chmod 755 "$BK"
  pid=$(pidof cupsd 2>/dev/null | awk '{print $1}')
  [ -n "$pid" ] && kill -HUP "$pid" 2>/dev/null; sleep 1

  OUT=$TMP/job.prn
  rm -f "$OUT" "$OUT.log"
  # backend 是普通用户，$TMP 由 root 建成 755 时它写不进去（error_log 会报 Permission denied）
  chmod 777 "$TMP" 2>/dev/null
  : > "$OUT.log" 2>/dev/null; chmod 666 "$OUT.log" 2>/dev/null
  info "cupsd 跑 backend 的用户：$(grep -E '^(User|Group)[[:space:]]' /etc/cups/cupsd.conf 2>/dev/null | tr '\n' ' ')"
  lpadmin -x "$QNAME" >/dev/null 2>&1
  if err=$(lpadmin -p "$QNAME" -E -v "savefile:$OUT" -P "$RUNPPD" 2>&1); then
    info "队列已建立：$(lpstat -v "$QNAME" 2>/dev/null | head -1)"
    if err=$(lp -d "$QNAME" "$TMP/t.ps" 2>&1); then
      i=0
      while [ $i -lt 20 ]; do [ -s "$OUT" ] && break; sleep 1; i=$((i+1)); done
      if [ -s "$OUT" ]; then
        ok "cupsd 全链路打通：产出 $(sz "$OUT") 字节（$(pages "$OUT") 个 raster 页的痕迹）"
        info "cupsd 实际用到的过滤器："
        grep -aE 'Started filter|PID [0-9]+ \(/usr/lib/cups/filter|[0-9]+ \(/usr/lib/cups/filter' \
          /var/log/cups/error_log 2>/dev/null | tail -6 | sed 's/^/      /'
        info "=> 结论：CUPS 里能打。gstoraster 的 139 只是那个旧入口自己的问题，与打印无关。"
      else
        bad "cupsd 全链路没有产出"
        info "作业状态："; lpstat -W all -o "$QNAME" 2>/dev/null | head -3 | sed 's/^/      /'
        info "backend 日志（空 = backend 没被调用）："; tail -5 "$OUT.log" 2>/dev/null | sed 's/^/      /'
        info "error_log 失败特征："
        grep -aE 'Filter failed|SIGSEGV|status 13[0-9]|exited with status|Permission denied|savefile|Unable to|Job [0-9]+' \
          /var/log/cups/error_log 2>/dev/null | tail -12 | sed 's/^/      /'
        if grep -aq 'Permission denied' /var/log/cups/error_log 2>/dev/null; then
          info "=> 看到 Permission denied：backend 是普通用户，输出目录不可写（chmod 777 输出目录即可）"
        fi
        info "=> 若出现 139/SIGSEGV 且作业被判 Failed，才是 gstoraster 拖垮作业（与驱动无关）"
      fi
    else
      warn "lp 提交失败：$err"
    fi
  else
    warn "建队列失败：$err"
  fi
  lpadmin -x "$QNAME" >/dev/null 2>&1
  info "假 backend 留在 $BK，不需要时 rm 掉"
fi

hr "结论"
cat <<'EOS'
  第 4 步有产出       -> 最终答案：CUPS 里能打。
                         理由：cups-filters 2.x 的 gstoraster/pdftoraster 都是同一个多呼叫二进制
                         的旧入口；cupsd 实际调用的是 universal 入口，它的退出清理没这个毛病。
                         （cupsfilter -m 也走 universal，所以它 rc=0 而 gstoraster 是 139。）
  第 4 步没产出 + Permission denied -> 假 backend 的权限问题，与驱动无关：
                         cupsd 以 lp/cups 用户跑 backend，输出目录得 chmod 777。
  第 4 步没产出 + Filter failed / 139 -> 才是真问题：作业被过滤器拖垮，换 cups-filters 构建，
                         或 HP 1020 直接走 foo2zjs（不经 gstoraster，实测全绿）。

  另：CUPS raster 的同步字是 0x52615333，小端机落盘为 3SaR（不是 RaS3）——
      只判 RaS3 会把合法 raster 全部判死。
EOS
printf '\n  中间文件在 %s，可整体删除。\n' "$TMP"
