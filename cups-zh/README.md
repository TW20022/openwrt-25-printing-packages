# CUPS Web 界面中文本地化包（2.4.x）

把 `/usr/share/cups/templates/*.tmpl` 与 `/usr/share/cups/doc-root/index.html` 换成中文，
覆盖即生效，**不依赖浏览器语言、也不需要 `DefaultLanguage`**。

## 来源

- 主体译文：[tuutoo/CUPS-Chinese-Language-Patch](https://github.com/tuutoo/CUPS-Chinese-Language-Patch)（基于 CUPS 2.4.1，GPL-2.0，源自 TubroDog/CUPSChinesePatch）
- 参考：[yanzilisan183/CUPS_LanguagePackage_zh_CN](https://github.com/yanzilisan183/CUPS_LanguagePackage_zh_CN)（基于 2.3.1，额外含汉化帮助文档）

## 本包相对原始译文做的修补

上游 2.4.10 的 `templates/` 共 64 个 `.tmpl`，逐个比对占位符后发现原始译文只缺两处，
另有若干英文残留，均已修好：

| 文件 | 问题 | 处理 |
|---|---|---|
| `printer-added.tmpl` | 漏了 2.4 新增的「设置打印机选项」整个表单（`org.cups.sid` 缺失），加完打印机后没有下一步入口 | 补回表单并译名 |
| `jobs.tmpl` | 漏 `{job_hold_until=auth-info-required?}` 分支；状态词 `pending since / held since / completed at / aborted / Unknown / Withheld` 仍是英文 | 补分支 + 全部译出 |
| `printers.tmpl` `printer.tmpl` `class.tmpl` `classes.tmpl` | 状态 `Idle/Processing/Paused`、`SUMMARY="Printer List"` 未译 | 空闲 / 处理中 / 已暂停 |
| `command.tmpl` `error-op.tmpl` | `processing/stopped`、`Unknown operation` | 已译 |
| `header.tmpl` `doc-root/index.html` | 标题里写死 `CUPS 2.4.1` | 改为 `__CUPS_VERSION__`，安装时按实际版本替换 |
| 导航栏（两处：`header.tmpl` + 静态首页） | 首页写「类别」、内页写「类」，同一个链接两种叫法；「帮助」指向 `/help/`，本固件没打包帮助文档，点了必 404 | 统一为「集群」；删掉「帮助」一项 |
| 全部 class 相关模板（10 个） | 「添加类 / 删除类 / 修改类 / 暂停类 / 恢复类 / 管理类」术语不统一 | 统一为「集群」；`人类可读`、`类 Unix` 等普通用词不受影响 |
| 静态首页正文 | 三栏全是 `help/*.html` 链接，文档没打包 → 整片死链 | 换成「常用入口」（打印机列表 / 管理 / 任务）+「使用提示」（网络打印服务器说明、客户端 `ipp://` 添加地址） |

另外：`cups.css` 的类名在 2.4 系列中途由 `.header/.body` 改成了 `.cups-header/.cups-body`，
原始译文用的是旧类名，直接覆盖会让导航栏丢失样式。`install.sh` 会读本机 `cups.css`
自动判断并改写类名，所以 2.4.1 与 2.4.10 都能用。

## 用法

```sh
# 传到路由器后
tar xzf cups-zh-cn.tar.gz
cd cups-zh-cn
sh install.sh            # 安装
sh install.sh --restore  # 还原英文
```

安装脚本做的事：

1. **探测 DocumentRoot**：优先读 `cups-files.conf` 里未注释的 `DocumentRoot`，否则按 `cups.css` 的实际位置反推（OpenWrt 的 cups 把 doc-root 装到了 `/usr/share/doc/cups`，而 `/usr/share/cups/` 下根本没有 `doc-root`，`cups-files.conf` 里那行又是注释状态 —— 写死路径必然扑空）
2. 把现有英文模板备份到 `/usr/share/cups/templates/default.en/`，首页备份为 `index.html.en`
3. 读 `cups-config --version`（没有就从 `header.tmpl` 标题里抠）得到版本号
4. 按本机 `header.tmpl` 判断该用 `.header` 还是 `.cups-header` 类名
5. **只覆盖本机实际存在的模板**——上游已删除的旧模板不会被塞进去，不同小版本的清单差异自然打平；装完还会列出「本机有、包里没有」的模板（这些页面仍是英文）
6. 重启 `cupsd`

装完必须 **Ctrl+F5 强刷**，浏览器会缓存 tmpl 渲染结果。

## 已知限制

- 译文质量是机翻 + 人工整理，个别句子生硬；`help/` 在线帮助文档**没有**汉化（原始译文包也没做完，且体积大，路由器 Flash 不划算）。
- 用「覆盖」而不是 `templates/zh_CN/` 子目录：子目录依赖 CGI 进程的 `LANG`（由浏览器 `Accept-Language` 决定），与 `DefaultLanguage` 无关（上游 issue #5763），在部分浏览器下不生效。覆盖最稳，代价是英文界面同时失去——用 `--restore` 换回。
- 升级 CUPS 包会覆盖这些模板（`opkg upgrade` 后需重跑一次 `install.sh`）。

## 安全

模板只是静态 HTML + `{占位符}`，不含脚本逻辑，不改变 CUPS 的权限与策略；
`install.sh` 只写 `/usr/share/cups/templates/`、`/usr/share/cups/doc-root/index.html` 和备份目录。
