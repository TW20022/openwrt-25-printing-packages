#!/bin/sh
# foo2zjs-fw-setup.sh —— HP LaserJet 1020（ZJS 裸机）固件下发安装器
#
# 背景：1020/1005/1018/P1005 这类"软固件"机型，冷启动后 USB 里只是引导程序，
#       固件在 RAM 里，断电即失效 —— 所以每插一次电都要重灌一次，必须靠 hotplug 自动化。
#       固件封装有两种，别搞混：
#         · hplip 的 .fw.gz —— gzip 压缩的裸 .dl，zcat 出来直接就是成品（arm2hpdl 喂它只会吐 0 字节）
#         · getweb 的 .img  —— HP 官方上传格式，内部有 "FW" 头，必须 arm2hpdl 剥头才是 .dl
#
# 用法：
#   sh foo2zjs-fw-setup.sh              # 只体检：找固件源、试转换、检查 usblp，不改任何东西
#   sh foo2zjs-fw-setup.sh --install    # 生成 .dl + 装 hotplug 规则
#   sh foo2zjs-fw-setup.sh --now        # 在 --install 基础上，立刻给当前插着的机器灌一次
#   sh foo2zjs-fw-setup.sh --hplip      # 不生成 .dl，改用 hplip 的 hp-firmware 灌（插件已装时最省事）
#   sh foo2zjs-fw-setup.sh --remove     # 移除 hotplug 规则
#   sh foo2zjs-fw-setup.sh --disable-hplip   # 停用 hplip 自带的 10-hp-printer（两者互斥，见第 3 步）
#   sh foo2zjs-fw-setup.sh --restore-hplip   # 恢复上一步停用的 hplip 规则
#   --force 放在 --install 后面可跳过冲突检查
#
# 判读：第 4 步"灌完 lp 节点还在不在"决定了 foo2zjs 这条路能不能用 ——
#       固件加载后设备会重新枚举，如果新身份下 usblp 不再绑定（没有 /dev/usb/lp*），
#       那么 CUPS 的 usb backend 也拿不到设备，foo2zjs 走不通，应改用 hplip 的 hp backend。

set -u
TAG=hp1020fw
VENDOR=03f0
PRODUCT=2b17
DL=/lib/firmware/hp/sihp1020.dl
FWGZ=/usr/share/hplip/data/firmware/hp_laserjet_1020.fw.gz
HOTPLUG=/etc/hotplug.d/usb/20-hp1020-fw
HOTPLUG_SRC=$0
MODE=check

ok()   { echo "  [ OK ] $*"; }
bad()  { echo "  [FAIL] $*"; }
warn() { echo "  [WARN] $*"; }
info() { echo "  ---- $*"; }
hr()   { echo; echo "===== $* ====="; }
sz()   { wc -c < "$1" 2>/dev/null | tr -d ' '; }
# 这台 OpenWrt 上没有 od，hexdump 优先，od 只作退路
head_hex() {
  if command -v hexdump >/dev/null 2>&1; then
    hexdump -C "$1" 2>/dev/null | head -1 | sed 's/^[0-9a-f]*  *//; s/  *|.*$//'
  else
    od -An -tx1 -N8 "$1" 2>/dev/null | tr -s ' ' | sed 's/^ //'
  fi
}
first_byte_hex() {
  if command -v hexdump >/dev/null 2>&1; then
    head -c 2 "$1" 2>/dev/null | hexdump -C | head -1 | awk '{print $2$3}'
  else
    head -c 2 "$1" 2>/dev/null | od -An -tx1 | tr -d ' \n'
  fi
}

for a in "$@"; do
  case "$a" in
    --install|--now|--hplip|--remove|--disable-hplip|--restore-hplip) MODE=${a#--} ;;
    --force) FORCE=1 ;;
    -h|--help) sed -n '3,26p' "$0"; exit 0 ;;
    *) MODE=check ;;
  esac
done
FORCE=${FORCE:-0}

[ "$(id -u)" = "0" ] || { echo "需要 root 运行"; exit 1; }

# ---------------------------------------------------------------- 0
hr "0. 环境"
info "内核 $(uname -r)"
if [ -d /sys/module/usblp ]; then
  ok "usblp 已加载 —— /dev/usb/lp* 可用，cat > lp0 那条通道成立"
else
  warn "usblp 未加载 —— 没有 /dev/usb/lp*，cat > lp0 那条通道完全不可用"
  info "装它：opkg update && opkg install kmod-usb-printer，然后 /etc/init.d/cupsd restart"
  info "libusb 通道（hp-firmware）不受影响，可以先走 --hplip 把固件灌进去"
fi
for c in arm2hpdl usb_printerid lsusb hp-firmware zcat hexdump; do
  p=$(command -v $c 2>/dev/null)
  if [ -n "$p" ]; then info "$(printf '%-14s' $c) $p"; else info "$(printf '%-14s' $c) 未安装"; fi
done
info "现有 /dev/usb/lp*：$(ls /dev/usb/lp* 2>/dev/null | tr '\n' ' ')"
info "现有固件：$DL $([ -s "$DL" ] && echo "($(sz "$DL") 字节)" || echo '(无)')"

# 当前插着的 1020（busnum:devnum）
find_1020() {
  for d in /sys/bus/usb/devices/*/; do
    [ -r "$d/idVendor" ] || continue
    [ "$(cat "$d/idVendor" 2>/dev/null)" = "$VENDOR" ] || continue
    [ "$(cat "$d/idProduct" 2>/dev/null)" = "$PRODUCT" ] || continue
    b=$(cat "$d/busnum" 2>/dev/null); n=$(cat "$d/devnum" 2>/dev/null)
    [ -n "$b" ] && [ -n "$n" ] && printf '%03d:%03d' "$b" "$n" && return 0
  done
  return 1
}
USBID=$(find_1020 2>/dev/null)
if [ -n "$USBID" ]; then
  ok "检测到 1020 在总线 $USBID（busnum:devnum，三位补零）"
else
  warn "当前没看到 03f0:2b17（没插 / 已断电 / 不是这台机型）"
  for d in /sys/bus/usb/devices/*/; do
    [ -r "$d/idVendor" ] || continue
    v=$(cat "$d/idVendor" 2>/dev/null); p=$(cat "$d/idProduct" 2>/dev/null)
    [ "$v" = "$VENDOR" ] || continue
    # 认一下机型，省得对着插错的机器反复灌固件（3217 是本 feed 实测踩过的）
    case "$p" in
      2b17) why="  <- LaserJet 1020/1020plus，正是本脚本的目标" ;;
      3217) why="  <- LaserJet 3050：PCL5 完整机型，自带固件，不需要也灌不进 .dl，本脚本对它无效" ;;
      4117) why="  <- LaserJet 1018：ZJS，但固件是 sihp1018.dl，型号常量不同" ;;
      3d17) why="  <- LaserJet P1005：ZJS，固件 sihpP1005.dl，型号常量不同" ;;
      3e17) why="  <- LaserJet P1006：ZJS，固件 sihpP1006.dl，型号常量不同" ;;
      *)    why="" ;;
    esac
    info "现场其它 HP 设备：${d%/}  $v:$p$why"
  done
  info "本脚本的型号常量是 $VENDOR:$PRODUCT（LaserJet 1020）；上面若没有 2b17，就别往下灌固件，灌错固件会让设备挂死"
fi

# 取 /dev/usb/lpN 对应设备的 vid:pid。
# 注意：/sys/class/usb/lp0/device 指向的是 interface 目录（1-1:1.0），idVendor 在它的父目录，
# 所以必须逐级往上找，不能只看 device/。
lp_vidpid() {
  b=${1##*/}
  for d in "/sys/class/usb/$b/device" "/sys/class/usb/$b/device/.." "/sys/class/usb/$b/device/../.."; do
    [ -r "$d/idVendor" ] || continue
    printf '%s:%s' "$(cat "$d/idVendor" 2>/dev/null)" "$(cat "$d/idProduct" 2>/dev/null)"
    return 0
  done
  return 1
}

# ---------------------------------------------------------------- 1
hr "1. 找固件源"
SRC=""
for c in "$DL" /usr/share/foo2zjs/firmware/sihp1020.dl /lib/firmware/sihp1020.dl "$FWGZ"; do
  [ -s "$c" ] || continue
  if [ "$c" = "$FWGZ" ]; then
    info "候选：$c（hplip 的 .fw.gz，$(sz "$c") 字节 —— gzip 压缩的裸 .dl，解压即成品，不需要 arm2hpdl）"
    [ -z "$SRC" ] && SRC=$c
  else
    ok "候选：$c（$(sz "$c") 字节，头 $(head_hex "$c")）"
    SRC=$c
    break
  fi
done
[ -n "$SRC" ] || bad "找不到任何固件源：需要 hp_laserjet_1020.fw.gz 或 sihp1020.dl"

# ---------------------------------------------------------------- 2
hr "2. 生成 sihp1020.dl"
MADE=""
if [ -s "$DL" ]; then
  ok "已是成品：$DL（$(sz "$DL") 字节）"; MADE=$DL
elif [ "$SRC" = "$FWGZ" ]; then
  mkdir -p "${DL%/*}" 2>/dev/null
  # 路线 A（首选）：hplip 的 .fw.gz 就是 gzip 压缩的裸 .dl，zcat 出来直接是成品。
  # 实测：把 .fw.gz 喂给 arm2hpdl（无论直接喂还是 zcat 后喂）都只吐 0 字节 ——
  #       arm2hpdl 只认 HP 官方的 .img（内部有 "FW" 头），不认 hplip 的封装。
  out=/tmp/.sihp1020.try
  zcat "$SRC" > "$out" 2>/dev/null
  n=$(sz "$out")
  if [ "${n:-0}" -gt 10240 ]; then
    cp "$out" "$DL" && MADE=$DL
    ok "直接解压成功（zcat，不经 arm2hpdl）：$n 字节，头 $(head_hex "$DL")"
  else
    info "不行：zcat 只出了 ${n:-0} 字节（不是纯 gzip 的 .dl？）"
  fi
  rm -f "$out"

  # 路线 B（退路）：万一这份 .fw.gz 其实是 .img 换了外壳，再让 arm2hpdl 试一遍
  if [ -z "$MADE" ] && command -v arm2hpdl >/dev/null 2>&1; then
    for how in "arm2hpdl $SRC" "zcat $SRC | arm2hpdl"; do
      out=/tmp/.sihp1020.try
      if [ "$how" = "zcat $SRC | arm2hpdl" ]; then
        zcat "$SRC" 2>/dev/null | arm2hpdl > "$out" 2>/dev/null
      else
        arm2hpdl "$SRC" > "$out" 2>/dev/null
      fi
      n=$(sz "$out")
      if [ "${n:-0}" -gt 10240 ]; then
        cp "$out" "$DL" && MADE=$DL
        ok "arm2hpdl 转换成功（$how）：$(sz "$DL") 字节，头 $(head_hex "$DL")"
        break
      else
        info "不行：$how 只出了 ${n:-0} 字节"
      fi
    done
    rm -f /tmp/.sihp1020.try
  fi

  if [ -z "$MADE" ]; then
    bad "zcat 直通与 arm2hpdl 都没出成品"
    info "zcat 失败 = 它不是纯 gzip 的 .dl；arm2hpdl 失败 = 它也不是 HP 官方 .img"
    info "改用 getweb 取原始 .img：getweb 1020，再 arm2hpdl sihp1020.img > $DL"
    info "或直接走 --hplip 模式，让 hp-firmware 自己解 .fw.gz（插件已装时最省事）"
  fi
else
  cp "$SRC" "$DL" 2>/dev/null && MADE=$DL && ok "已拷到 $DL"
fi

if [ -n "$MADE" ]; then
  # 成品校验：.dl 不该是 gzip，也不该是大段可打印文本（那是 hplip 的头没剥掉）
  first2=$(first_byte_hex "$MADE")
  if [ "$first2" = "1f8b" ]; then
    bad "$DL 仍是 gzip（头 1f8b）—— 打印机不认，绝不能灌"
    MADE=""          # 宁可灌不进去，也不能把 gzip 流喷给打印机引导程序
  else
    txt=$(head -c 256 "$MADE" | tr -d '\000' | tr -cd '[:print:]' | wc -c | tr -d ' ')
    if [ "${txt:-0}" -gt 200 ]; then
      warn "$DL 前 256 字节几乎全是可打印文本（$txt 字节）—— 疑似没剥掉 hplip 头，建议人工核一下"
    else
      ok "$DL 看起来是二进制固件（头 $(head_hex "$MADE")）"
    fi
  fi
fi

# ---------------------------------------------------------------- 3
hr "3. 与 hplip 自带 hotplug 的关系"
HPLUG=/etc/hotplug.d/usb/10-hp-printer
HCONFLICT=0

if [ "$MODE" = "disable-hplip" ] || [ "$MODE" = "restore-hplip" ]; then
  if [ ! -e "$HPLUG" ]; then
    info "$HPLUG 不存在（没装 hplip，或已被改名）"
  elif [ "$MODE" = "disable-hplip" ]; then
    if [ -x "$HPLUG" ]; then
      # 注意：hotplug.d 会执行目录下所有可执行文件，不看扩展名，所以只能用 chmod 去掉 x
      chmod a-x "$HPLUG" && ok "已停用 hplip 的 10-hp-printer（chmod a-x）"
      info "它原本还负责两件事，本脚本的规则已经代劳："
      info "  · 关 USB 自动挂起（autosuspend=-1）—— 1020 固件在 RAM 里，挂起容易掉"
      info "  · 输出日志到 syslog（tag 从 hp-hotplug 换成 hp1020fw）"
      info "opkg 升级 hplip 会把这个文件重装成 755，届时需要重跑一次本命令"
      info "现在可以装本脚本的规则了：sh $0 --install"
    else
      ok "已经是停用状态"
    fi
  else
    chmod 755 "$HPLUG" && ok "已恢复 hplip 的 10-hp-printer（chmod 755）"
    info "如果同时装着本脚本的规则，两个都会灌固件 —— 走 hplip 就该先 --remove"
  fi
  exit 0
fi

if [ -x "$HPLUG" ]; then
  HCONFLICT=1
  warn "发现可执行的 $HPLUG（hplip 包自带）"
  info "它监听 ACTION=bind，PRODUCT 匹配所有 3f0/*，命中后调 hp-config_usb_printer 灌固件"
  info "本脚本监听 ACTION=add，固件经 /dev/usb/lp* 写入 —— 两条通道（libusb vs usblp）互不相让"
  info "同一次插拔里两个都可能下发，固件流交错会让设备挂死，要拔插才能恢复"
  info "而且它的 PRODUCT 规则是 3f0/*（含 3050 等 fw-download=False 的机型），本脚本只认 2b17"
  info "=> 二选一：走 foo2zjs 就 sh $0 --disable-hplip；走 hplip 就不要装本脚本的规则"
elif [ -e "$HPLUG" ]; then
  ok "hplip 的 10-hp-printer 存在但不可执行，不抢固件下发"
else
  ok "没有 hplip 的 10-hp-printer（纯 foo2zjs 环境），无冲突"
fi

# ---------------------------------------------------------------- 4
hr "4. 装 hotplug 规则"
if [ "$MODE" = "remove" ]; then
  rm -f "$HOTPLUG" && ok "已删除 $HOTPLUG"
  hr "结果"; info "hotplug 已移除，之后需手动灌固件"; exit 0
fi

if [ "$MODE" = "check" ]; then
  info "体检模式，不写文件。要安装：sh $0 --install"
elif [ "$MODE" = "hplip" ]; then
  info "--hplip 模式只用 hp-firmware 下发，不装 hotplug 规则（避免与 hplip 自己的脚本抢固件）"
elif [ "$HCONFLICT" = "1" ] && [ "$FORCE" != "1" ]; then
  bad "拒绝安装：hplip 的 10-hp-printer 还在工作，两个脚本会抢着灌固件"
  info "走 foo2zjs 的话先停用它：sh $0 --disable-hplip"
  info "确实要让两者共存（不推荐）再加 --force"
  exit 1
else
  [ "$HCONFLICT" = "1" ] && warn "--force 已指定：两个 hotplug 会共存，出问题先看 syslog 里谁先灌的"
  mkdir -p "${HOTPLUG%/*}"
  cat > "$HOTPLUG" <<'EOS'
#!/bin/sh
# HP LaserJet 1020 冷启动自动下发固件（foo2zjs 路线）
# 由 foo2zjs-fw-setup.sh 安装；删除本文件即关闭自动下发
[ "$ACTION" = "add" ] || exit 0
case "$PRODUCT" in
  3f0/2b17/*|3f0/2b17) ;;
  *) exit 0 ;;
esac
FW=/lib/firmware/hp/sihp1020.dl
[ -s "$FW" ] || { logger -t hp1020fw "firmware missing: $FW"; exit 0; }

# usblp 建节点要几十毫秒；最多等 3 秒
i=0
while [ $i -lt 30 ]; do
  for lp in /dev/usb/lp*; do
    [ -c "$lp" ] || continue
    # device/ 是 interface 目录，idVendor 在父目录，逐级往上找
    vp=""
    for d in "/sys/class/usb/${lp##*/}/device" "/sys/class/usb/${lp##*/}/device/.." \
             "/sys/class/usb/${lp##*/}/device/../.."; do
      [ -r "$d/idVendor" ] || continue
      vp="$(cat "$d/idVendor" 2>/dev/null):$(cat "$d/idProduct" 2>/dev/null)"
      break
    done
    [ "$vp" = "03f0:2b17" ] || continue
    # 关 USB 自动挂起：1020 固件在内存里，挂起再唤醒容易掉固件（hplip 的脚本也做这件事）
    udev=$(basename "$(readlink -f "/sys/class/usb/${lp##*/}/device/.." 2>/dev/null)" 2>/dev/null)
    if [ -n "$udev" ] && [ -d "/sys/bus/usb/devices/$udev/power" ]; then
      echo -1 > "/sys/bus/usb/devices/$udev/power/autosuspend" 2>/dev/null
    fi
    # 已经加载过固件的设备能读出 IEEE-1284 ID，别重复灌
    if command -v usb_printerid >/dev/null 2>&1; then
      case "$(usb_printerid "$lp" 2>/dev/null)" in
        *MFG:*|*CMD:*) exit 0 ;;
      esac
    fi
    cat "$FW" > "$lp" 2>/dev/null && logger -t hp1020fw "firmware sent to $lp ($(wc -c < "$FW") bytes)"
    exit 0
  done
  sleep 0.1; i=$((i+1))
done
logger -t hp1020fw "no /dev/usb/lp* for 03f0:2b17 in 3s (装 kmod-usb-printer 了吗？)"
exit 0
EOS
  chmod 755 "$HOTPLUG"
  ok "已写入 $HOTPLUG"
fi

# ---------------------------------------------------------------- 5
hr "5. 灌一次并验证"
if [ "$MODE" = "hplip" ]; then
  if ! command -v hp-firmware >/dev/null 2>&1; then
    bad "没有 hp-firmware（hplip 未装）—— 这条路的前提是 hplip + 插件在位"
  elif [ -z "$USBID" ]; then
    warn "没检测到 1020，跳过"
  else
    st=$(grep -c 'installed = 1' /var/lib/hp/hplip.state 2>/dev/null)
    [ "${st:-0}" -ge 1 ] && ok "插件状态 installed=1（$USBID）" || warn "插件状态未标记 installed，hp-firmware 可能直接返回"
    info "执行：hp-firmware -y3 -s $USBID"
    hp-firmware -y3 -s "$USBID" 2>&1 | tail -8 | sed 's/^/      /'
    ok "已尝试下发（hp-firmware 只认三位补零的 busnum:devnum，$USBID 就是这个格式）"
  fi
elif [ "$MODE" = "now" ] || [ "$MODE" = "install" ]; then
  if [ -z "$MADE" ]; then
    bad "没有可用的 .dl，跳过灌入"
  elif [ -z "$(ls /dev/usb/lp* 2>/dev/null)" ]; then
    warn "没有 /dev/usb/lp* —— usblp 没绑定设备"
    info "要么没插 / 已断电，要么缺 kmod-usb-printer；装完再插一次即可由 hotplug 自动灌"
  else
    LPNODE=""
    for lp in /dev/usb/lp*; do
      [ -c "$lp" ] || continue
      [ "$(lp_vidpid "$lp")" = "$VENDOR:$PRODUCT" ] && LPNODE=$lp
    done
    if [ -z "$LPNODE" ]; then
      cnt=$(ls /dev/usb/lp* 2>/dev/null | wc -l | tr -d ' ')
      if [ "${cnt:-0}" = "1" ]; then
        LPNODE=$(ls /dev/usb/lp* 2>/dev/null)
        warn "拿不到 $(basename "$LPNODE") 的 vid:pid，但全场只有这一个 lp 节点，按它处理"
      fi
    fi
    if [ -z "$LPNODE" ]; then
      warn "lp 节点存在，但没有一个是 03f0:2b17"
    else
      info "灌 $LPNODE（$(sz "$MADE") 字节）"
      cat "$MADE" > "$LPNODE" 2>&1 && ok "已写入 $LPNODE"
      sleep 3
      NEWUSBID=$(find_1020 2>/dev/null)
      if [ -n "$USBID" ] && [ -n "$NEWUSBID" ] && [ "$USBID" != "$NEWUSBID" ]; then
        ok "设备已重新枚举：$USBID -> $NEWUSBID —— 固件生效的标志"
      elif [ -n "$NEWUSBID" ]; then
        info "设备号仍是 $NEWUSBID（不一定失败，部分固件不改变 devnum）"
      fi
      # 决定性判据：重新枚举后 usblp 还绑不绑
      if ls /dev/usb/lp* >/dev/null 2>&1; then
        ok "重新枚举后 /dev/usb/lp* 仍在 —— foo2zjs 这条路可用（CUPS usb backend 有设备节点）"
      else
        bad "重新枚举后 /dev/usb/lp* 消失了 —— 新身份下 usblp 不绑定"
        info "=> foo2zjs 走不通（它只能经 /dev/usb/lp0 发数据）"
        info "=> 改用 hplip 的 hp backend（libusb 直写），即 hpcups 那条链，重跑 test-hplip-1020.sh"
      fi
      if command -v usb_printerid >/dev/null 2>&1; then
        for lp in /dev/usb/lp*; do
          [ -c "$lp" ] || continue
          id=$(usb_printerid "$lp" 2>/dev/null)
          case "$id" in
            *MFG:*) ok "$lp 能读出 IEEE-1284 ID：$(echo "$id" | head -1)" ;;
            *)      info "$lp 读不出 ID（固件没进去时正常）" ;;
          esac
        done
      fi
    fi
  fi
fi

# ---------------------------------------------------------------- 6
hr "6. 这对打印意味着什么"
cat <<'EOS'
  灌固件 与 用哪个驱动打印 是两件独立的事，可以混搭：
    · 固件：hp-firmware（libusb 直写）或 cat *.dl > /dev/usb/lp0（经 usblp）
    · 打印：hpcups（hplip 链）或 foo2zjs（foomatic-rip + foo2zjs-wrapper）
  所以"打印走 foo2zjs、固件用 hp-firmware 灌"是完全合法的组合，插件已装时最省事。

  1020 的固件只在 RAM 里，断电即失效 —— hotplug 不是可选项，是必须项。
  /var 是 tmpfs，所以规则要放 /etc/hotplug.d/（overlay 持久），不要放 /tmp。

  灌完固件后确认 CUPS 看得到设备：
    lpinfo -v | grep -i 'usb://HP'
  建队列（foo2zjs）：
    lpadmin -p HP1020 -E -v "usb://HP/LaserJet%201020?serial=..." \
            -m /usr/share/cups/model/HP-LaserJet_1020.ppd.gz
    lp -d HP1020 /etc/hostname
EOS
