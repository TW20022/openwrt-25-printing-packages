#!/bin/sh
# ============================================================
# Brother HL-3040CN 现场诊断 v2（只读，不改 CUPS 配置）
#   用途：排查"作业成功但没有落盘文件"
#   用法： sh hl3040cn-doctor.sh
#
#   v2: 修正 v1 的误判 —— v1 把 backend 的输出路径写死成
#       /tmp/savefile-99-root.prn，而新版 backend 按 DEVICE_URI 决定路径，
#       于是"明明写成功"也被报成"文件没生成"。
#       本版改为：解析 backend 自己打印的路径，并重点检查
#       "backend 以 lp 身份能否写 /tmp"，这才是上次真正失败的地方。
# ============================================================
hr() { printf '\n===== %s =====\n' "$1"; }
B=/usr/lib/cups/backend/savefile
OUTDIR=/tmp/hl3040cn-out

hr "1. 身份与关键目录权限"
echo "当前用户: $(id)"
echo "---- backend 是 CUPS 以哪个用户启动的（看 cups-files.conf）----"
grep -iE '^\s*(User|Group|SystemGroup)' /etc/cups/cups-files.conf 2>/dev/null || echo "(未配置，默认 lp)"
ls -ld /tmp /var/spool/cups /var/spool/cups/tmp 2>&1
echo "---- /tmp 是否对 other 可写（sticky 位 1777 才对）----"
perl -e 'my @s=stat("/tmp"); printf "/tmp mode=%04o\n", $s[2]&07777' 2>/dev/null || ls -ld /tmp

hr "2. 磁盘与内存"
df -h / 2>/dev/null
df -h /tmp 2>/dev/null
free -m 2>/dev/null

hr "3. /tmp 下已有的 savefile 产物（重点看属主）"
ls -l /tmp/savefile* $OUTDIR 2>/dev/null || echo "(一个都没有)"

hr "4. 以 lp 身份试写 /tmp（这才是 backend 的真实处境）"
if su lp -s /bin/sh -c 'echo lp-write-test > /tmp/.lp-wtest 2>/dev/null && echo OK || echo DENIED' 2>/dev/null; then :; else
  echo "（本机没有 su 或没有 lp 用户，改看下面 root 的结果）"
  echo root-write-test > /tmp/.lp-wtest 2>/dev/null && echo "root OK"
fi
if [ -f /tmp/.lp-wtest ]; then echo "写入成功: $(ls -l /tmp/.lp-wtest)"; else echo "写入失败"; fi
rm -f /tmp/.lp-wtest

hr "5. 以 lp 身份试写专用目录（selftest 用的就是这个）"
T=/tmp/hl3040cn-doctest
rm -rf $T; mkdir -p $T; chmod 777 $T
if su lp -s /bin/sh -c "echo t > $T/.wtest 2>/dev/null && echo OK || echo DENIED" 2>/dev/null; then :; else
  echo "（无 su，退回 root 测试）"; echo t > $T/.wtest && echo "root OK"
fi
[ -f $T/.wtest ] && echo "成功: $(ls -l $T/.wtest)" || echo "失败"
rm -rf $T

hr "6. 当前 backend 内容"
if [ -f $B ]; then cat $B; else echo "($B 不存在 —— 说明自检脚本还没跑过，或已被删)"; fi

hr "7. 手工调用 backend，看它自己报的落盘路径"
echo test | DEVICE_URI=savefile:$OUTDIR/manual.prn $B 99 root t 1 "" 2>&1
echo "rc=$?"
if [ -f $OUTDIR/manual.prn ]; then
  echo "确认生成: $(ls -l $OUTDIR/manual.prn)"
else
  echo "没有生成 $OUTDIR/manual.prn —— backend 脚本本身有问题"
fi

hr "8. backend 自己的日志"
[ -f $OUTDIR/savefile-backend.log ] && tail -5 $OUTDIR/savefile-backend.log || echo "(无)"

hr "9. cupsd 相关"
grep -iE '^\s*(TempDir|RequestRoot|StateDir|PreserveJobFiles)' /etc/cups/cupsd.conf 2>/dev/null
ps w 2>/dev/null | grep '[c]upsd' || ps 2>/dev/null | grep '[c]upsd'
echo "---- 最近作业里 backend 的报错行 ----"
grep -a 'backend/savefile\|savefile:' /var/log/cups/error_log 2>/dev/null | grep -aiE 'ERROR|Permission|writable|failed|exited' | tail -8

hr "10. 收尾"
rm -f $OUTDIR/manual.prn
echo "已清理本次测试文件"
echo "提示：如果第 4/5 步 lp 写不了，说明 backend 只能写 CUPS 自己的临时目录，"
echo "      需要把输出目录放到可写位置（或改 cups-files.conf 的 User）。"
