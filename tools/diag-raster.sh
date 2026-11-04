#!/bin/sh
# ============================================================
# diag-raster.sh —— 只查一件事：这台机的 PS 为什么转不出 CUPS raster
#
# 用法:  sh diag-raster.sh 2>&1 | tee /tmp/diag.txt
#        （不用带参数，不建队列，不碰硬件，几秒出结果）
#
# 背景：hpcups / rastertobrlaser / rastertoqpdl 这三个过滤器吃的都是
# CUPS raster。OpenWrt 上这一步由 cups-filters 的 gstoraster 完成，
# gstoraster 内部又是调 gs 的 cups 设备。任何一环不灵，三个 GDI/主机型
# 驱动全哑，而 foo2zjs 不受影响（它自己调 gs 出 pbmraw）。
# ============================================================
set -u
D=/tmp/diag-raster
rm -rf "$D"; mkdir -p "$D" || exit 1

say() { printf '\n========== %s ==========\n' "$1"; }
kv()  { printf '  %-22s %s\n' "$1" "$2"; }
hdr() { head -c 4 "$1" 2>/dev/null | tr -d '\000'; }
bytes(){ wc -c < "$1" 2>/dev/null | tr -d ' '; }

printf '%%!PS-Adobe-3.0\n/Helvetica findfont 20 scalefont setfont\n72 700 moveto (raster diag) show\nshowpage\n' > "$D/t.ps"

say "0. 环境"
kv "日期"        "$(date)"
kv "gs 路径"     "$(command -v gs 2>/dev/null || echo 未安装)"
kv "gs 版本"     "$(gs --version 2>&1 | head -1)"
kv "cupsfilter"  "$(command -v cupsfilter 2>/dev/null || echo 缺)"
kv "cupsd"       "$(command -v cupsd 2>/dev/null || ls /usr/sbin/cupsd 2>/dev/null || echo 缺)"
echo "  ---- 过滤器目录 /usr/lib/cups/filter:"
ls -l /usr/lib/cups/filter 2>/dev/null | sed -n '2,25p' | sed 's/^/      /'
echo "  ---- /tmp 空间:"
df -h /tmp 2>/dev/null | sed 's/^/      /'
echo "  ---- 内存:"
free 2>/dev/null | sed -n '1,3p' | sed 's/^/      /'
echo "  ---- gs 里有没有 cups / pwgraster / pbmraw 设备:"
if gs -h 2>&1 | tr ' ' '\n' | grep -qxE 'cups|pwgraster|pbmraw'; then
  gs -h 2>&1 | tr ' ' '\n' | grep -xE 'cups|pwgraster|pbmraw|pdfwrite' | sort -u | sed 's/^/      /'
else
  echo "      (gs -h 没列出，往下看第 1 步的实测)"
fi

say "1. 绕开 cups-filters，直接让 gs 出 CUPS raster"
gs -q -dNOPAUSE -dBATCH -sDEVICE=cups -r600 -g1000x1400 \
   -dcupsBitsPerColor=1 -dcupsColorSpace=3 \
   -sOutputFile="$D/1.raster" "$D/t.ps" 2> "$D/1.err"
rc=$?
kv "退出码" "$rc"
kv "产物"   "$(bytes "$D/1.raster") 字节，头=$(hdr "$D/1.raster")"
if [ -s "$D/1.raster" ]; then
  echo "  => gs 的 cups 设备可用。cups-filters 那一层若是坏的，脚本的第 3 条退路能顶上。"
else
  echo "  => gs 自己也出不来。stderr:"
  sed -n '1,15p' "$D/1.err" | sed 's/^/      /'
  echo "  => 这就是三个 raster 驱动全哑的根因。修法见文末。"
fi

say "2. gstoraster 直调（cups-filters 那一层）"
PPD=''
for p in /usr/share/ppd/HP/hp-laserjet_1020.ppd /usr/share/cups/model/HP-LaserJet_1020.ppd \
         /usr/share/cups/model/samsung/ml2010.ppd; do
  [ -f "$p" ] && { PPD=$p; break; }
done
if [ -z "$PPD" ]; then
  g=$(find /usr/share/ppd /usr/share/cups/model -name 'hp-laserjet_1020.ppd*' 2>/dev/null | head -1)
  [ -n "$g" ] && { zcat "$g" > "$D/ppd.ppd" 2>/dev/null || cp "$g" "$D/ppd.ppd"; PPD=$D/ppd.ppd; }
fi
kv "用到的 PPD" "${PPD:-无}"
if [ -x /usr/lib/cups/filter/gstoraster ] && [ -n "$PPD" ]; then
  PPD="$PPD" CUPS_DATADIR=/usr/share/cups \
    /usr/lib/cups/filter/gstoraster 1 root selftest 1 "PageSize=A4" "$D/t.ps" \
    > "$D/2.raster" 2> "$D/2.err"
  rc=$?
  kv "退出码" "$rc"
  kv "产物"   "$(bytes "$D/2.raster") 字节，头=$(hdr "$D/2.raster")"
  echo "  ---- stderr 末尾 25 行:"
  tail -25 "$D/2.err" | sed 's/^/      /'
else
  echo "  缺 gstoraster 或 PPD，跳过"
fi

say "3. cupsfilter -m application/vnd.cups-raster"
if command -v cupsfilter >/dev/null 2>&1 && [ -n "$PPD" ]; then
  cupsfilter -p "$PPD" -i application/postscript -m application/vnd.cups-raster \
             -o PageSize=A4 "$D/t.ps" > "$D/3.raster" 2> "$D/3.err"
  rc=$?
  kv "退出码" "$rc"
  kv "产物"   "$(bytes "$D/3.raster") 字节，头=$(hdr "$D/3.raster")"
  echo "  ---- stderr 末尾 15 行:"
  tail -15 "$D/3.err" | sed 's/^/      /'
else
  echo "  缺 cupsfilter 或 PPD，跳过"
fi

say "4. 拿现成的 raster 喂编码器（有哪台机器就试哪台）"
RAS=''
for f in "$D/1.raster" "$D/2.raster" "$D/3.raster"; do
  [ -s "$f" ] && { RAS=$f; break; }
done
if [ -z "$RAS" ]; then
  echo "  三个来源都没出 raster，本步无从谈起（先解决第 1/2 步）"
else
  echo "  用 $RAS（$(bytes "$RAS") 字节）"
  run_dev() {   # run_dev <过滤器名> <PPD> <输出>
    if [ -x "/usr/lib/cups/filter/$1" ] && [ -n "$2" ] && [ -f "$2" ]; then
      PPD="$2" DEVICE_URI=usb://x CUPS_DATADIR=/usr/share/cups \
        "/usr/lib/cups/filter/$1" 1 root selftest 1 "PageSize=A4" "$RAS" > "$3" 2> "$3.err"
      printf '  %-18s rc=%s  %s 字节\n' "$1" "$?" "$(bytes "$3")"
      tr -d '\000' < "$3" 2>/dev/null | grep -a -oE '@PJL [A-Z ]+|JZJZ|ENTER LANGUAGE ?=? ?[A-Z]+' | head -4 | sed 's/^/      /'
    else
      printf '  %-18s 缺过滤器或 PPD，跳过\n' "$1"
    fi
  }
  P1=$(find /usr/share/ppd /usr/share/cups/model -name 'hp-laserjet_1020.ppd*' 2>/dev/null | head -1)
  [ -n "$P1" ] && { zcat "$P1" > "$D/p1.ppd" 2>/dev/null || cp "$P1" "$D/p1.ppd"; P1=$D/p1.ppd; }
  P2=$(find /usr/share/cups/model -name 'ml2010.ppd' 2>/dev/null | head -1)
  P3=$(find /usr/share/cups/model /usr/share/cups/ppd -name 'br2140.ppd' 2>/dev/null | head -1)
  run_dev hpcups          "$P1" "$D/h.zjs"
  run_dev rastertobrlaser "$P3" "$D/b.prn"
  run_dev rastertoqpdl    "$P2" "$D/s.spl"
fi

say "5. CUPS 侧的状态（全链路为什么会「已完成但没文件」）"
if command -v lpinfo >/dev/null 2>&1; then
  echo "  ---- lpinfo -v 里的 backend（注意：这里列的是「设备」，不是 backend 清单）:"
  lpinfo -v 2>/dev/null | sed -n '1,6p' | sed 's/^/      /'
  echo "      => 自建的 savefile backend 无参数调用不报设备，本来就不会出现在这里；"
  echo "         要判断它能不能用，看 error_log 里有没有 'Started backend .../savefile'。"
fi
command -v lpstat >/dev/null 2>&1 && { echo "  ---- 打印机状态:"; lpstat -p -d 2>&1 | sed -n '1,10p' | sed 's/^/      /'; }
command -v lpstat >/dev/null 2>&1 && { echo "  ---- 最近作业:"; lpstat -W all -o 2>&1 | sed -n '1,10p' | sed 's/^/      /'; }
echo "  ---- error_log 里与作业/后端有关的行:"
grep -aE '\[Job [0-9]+\]|backend|savefile|Unable to' /var/log/cups/error_log 2>/dev/null | tail -15 | sed 's/^/      /'

say "结论怎么看"
cat <<'EOS'
  第 1 步有产物  -> gs 没问题，脚本第 3 条退路能顶上，重跑 test-*.sh 即可。
  第 1 步没产物  -> gs 缺 cups 设备（OpenWrt 上的 gs 有时裁掉了），
                    三个 raster 驱动（hplip/brlaser/splix）在软件层就走不通。
                    修：opkg install ghostscript 后重跑；仍不行则需换用
                    gs 自带 cups 设备的构建，或改用 foo2zjs 那条链。
  第 4 步有 ZJS/PJL 输出 -> 编码器本身是好的，问题只在「PS 转 raster」这一层。
  第 2 步 rc=139 而数据完整 -> gstoraster 崩在退出清理（本机实测就是这样），
                    真正的判据是 probe-gstoraster.sh --cups 第 4 步（cupsd 里能不能打）。
  注意：CUPS raster 的同步字小端落盘是 3SaR，不是 RaS3 —— 只判 RaS3 会把好东西判死。
EOS
echo
echo "  本次中间文件在 $D，可整体删除。"
