#!/bin/sh
# CUPS Web 界面中文本地化 —— 安装 / 还原脚本
#
#   sh install.sh            安装（覆盖模板，英文原件备份到 templates/default.en/）
#   sh install.sh --restore  还原英文界面
#
# 适配：CUPS 2.4.x；样式类名（.header / .cups-header）按本机模板自动判定，
#       DocumentRoot 按 cups-files.conf 与实际 cups.css 位置自动探测。
# 原理：/usr/share/cups/templates/*.tmpl 是 CGI 直接读取的页面模板，
#       覆盖即生效，与浏览器语言、DefaultLanguage 无关。

set -e

TPL=/usr/share/cups/templates
SRC=$(cd "$(dirname "$0")" && pwd)
BAK=$TPL/default.en

if [ ! -d "$TPL" ]; then
  echo "错误：$TPL 不存在。CUPS 没装，或者打包时裁掉了 templates 目录。"
  echo "      先确认：ls /usr/share/cups/templates | wc -l"
  exit 1
fi

# ---------- 探测 DocumentRoot ----------
# OpenWrt 的 cups 常把 doc-root 装到别处（如 /usr/share/doc/cups），
# cups-files.conf 里那行又是注释状态，只能靠实际文件定位。
DOC=''
if [ -f /etc/cups/cups-files.conf ]; then
  DOC=$(sed -n 's/^[[:space:]]*DocumentRoot[[:space:]]\{1,\}\([^[:space:]]*\).*/\1/p' /etc/cups/cups-files.conf | tail -1)
fi
if [ -z "$DOC" ]; then
  for d in /usr/share/cups/doc-root /usr/share/doc/cups /usr/share/cups/doc; do
    if [ -f "$d/cups.css" ] || [ -f "$d/index.html" ]; then DOC=$d; break; fi
  done
fi
if [ -z "$DOC" ]; then
  DOC=$(dirname "$(find /usr/share /var/lib -maxdepth 4 -name cups.css 2>/dev/null | head -1)")
fi
[ -n "$DOC" ] && [ "$DOC" != "." ] || DOC=/usr/share/cups/doc-root

# ---------- 还原 ----------
if [ "$1" = "--restore" ]; then
  [ -d "$BAK" ] || { echo "错误：找不到备份 $BAK"; exit 1; }
  for f in "$BAK"/*.tmpl; do
    [ -f "$f" ] && cp -f "$f" "$TPL"/
  done
  [ -f "$DOC/index.html.en" ] && cp -f "$DOC/index.html.en" "$DOC/index.html"
  chmod 644 "$TPL"/*.tmpl 2>/dev/null || true
  /etc/init.d/cupsd restart >/dev/null 2>&1 || true
  echo "已还原为英文界面，请 Ctrl+F5 强刷浏览器。"
  exit 0
fi

echo "模板目录：$TPL"
echo "文档根目录：$DOC"

# ---------- 1. 备份英文原件 ----------
if [ ! -d "$BAK" ]; then
  mkdir -p "$BAK"
  for f in "$TPL"/*.tmpl; do
    [ -f "$f" ] && cp -f "$f" "$BAK"/
  done
  echo "[1/5] 英文模板已备份 -> $BAK"
else
  echo "[1/5] 备份已存在，跳过（$BAK）"
fi
if [ -f "$DOC/index.html" ] && [ ! -f "$DOC/index.html.en" ]; then
  cp -f "$DOC/index.html" "$DOC/index.html.en"
  echo "      首页已备份 -> $DOC/index.html.en"
fi

# ---------- 2. CUPS 版本号 ----------
VER=$(cups-config --version 2>/dev/null | tr -d ' \r\n')
if [ -z "$VER" ] && [ -f "$BAK/header.tmpl" ]; then
  VER=$(sed -n 's|.*CUPS \([0-9][0-9.]*\)</title>.*|\1|p' "$BAK/header.tmpl" | head -1)
fi
[ -z "$VER" ] && VER="2.4.x"
echo "[2/5] CUPS 版本：$VER"

# ---------- 3. 样式类名适配 ----------
# 以本机模板为准（比 cups.css 可靠：不同打包可能裁掉 doc-root）
if [ -f "$BAK/header.tmpl" ] && grep -q 'cups-header' "$BAK/header.tmpl" 2>/dev/null; then
  CLSFIX='s|class="header"|class="cups-header"|g; s|class="body"|class="cups-body"|g'
  echo "[3/5] 本机模板用 .cups-header 结构，已启用类名适配"
elif [ -f "$DOC/cups.css" ] && grep -q 'cups-header' "$DOC/cups.css" 2>/dev/null; then
  CLSFIX='s|class="header"|class="cups-header"|g; s|class="body"|class="cups-body"|g'
  echo "[3/5] 样式表用 .cups-header 结构，已启用类名适配"
else
  CLSFIX=''
  echo "[3/5] 本机为 .header 结构，无需适配"
fi

emit() { # $1=源文件 $2=目标文件
  if [ -n "$CLSFIX" ]; then
    sed -e "s|__CUPS_VERSION__|$VER|g" -e "$CLSFIX" "$1" > "$2"
  else
    sed -e "s|__CUPS_VERSION__|$VER|g" "$1" > "$2"
  fi
}

# ---------- 4. 安装模板 ----------
# 只装本机确实存在的模板：避免把上游已删除的旧页面塞进去，
# 也让 2.4.x 各小版本都能对上。
n=0
skip=0
for f in "$SRC"/templates/*.tmpl; do
  b=$(basename "$f")
  if [ ! -f "$BAK/$b" ]; then
    skip=$((skip + 1))
    continue
  fi
  emit "$f" "$TPL/$b"
  chmod 644 "$TPL/$b"
  n=$((n + 1))
done
echo "[4/5] 已安装 $n 个中文模板（跳过本机不存在的 $skip 个）"

# 本机有、包里没有的模板：这些页面仍是英文，列出来便于后续补译
left=''
for f in "$BAK"/*.tmpl; do
  [ -f "$f" ] || continue
  b=$(basename "$f")
  [ -f "$SRC/templates/$b" ] || left="$left $b"
done
[ -n "$left" ] && echo "      仍为英文（本机独有模板）:$left"

# ---------- 5. 安装首页 ----------
if [ ! -d "$DOC" ]; then
  mkdir -p "$DOC" && echo "[5/5] 文档根目录不存在，已创建 $DOC"
fi
if [ -f "$SRC/doc-root/index.html" ]; then
  emit "$SRC/doc-root/index.html" "$DOC/index.html"
  chmod 644 "$DOC/index.html"
  echo "[5/5] 首页已写入 $DOC/index.html"
else
  echo "[5/5] 包内没有首页，跳过"
fi
[ -f "$DOC/cups.css" ] || echo "      注意：$DOC/cups.css 不存在，页面会是裸 HTML（无样式）"

/etc/init.d/cupsd restart >/dev/null 2>&1 \
  && echo "      cupsd 已重启" \
  || echo "      没找到 /etc/init.d/cupsd，请手动重启 CUPS 服务"

echo
echo "打开 http://<路由器IP>:631/ 查看，务必 Ctrl+F5 强刷（浏览器会缓存模板）。"
echo "还原英文：sh $0 --restore"
