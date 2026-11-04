# 支持的打印机型号清单

> 型号数据提取自本仓库编译产物（aarch64_generic）ipk 内的驱动定义文件，非手工整理。  
> |  |  |  
> | --- | --- |  
> 设备上装好对应包后，用 `lpinfo -m | grep -i 型号` 即可在线查询。
>
> **提取方式按驱动栈而异**：hplip / foo2zjs / splix 来自 ipk 内附带的 PPD 与 `.drv` 文件；  
> gutenprint 自 5.3 起不再预置 PPD，型号在 CUPS 查询时由驱动插件  
> `/usr/lib/cups/driver/gutenprint.5.3` 依 XML 定义动态生成，因此这里解析的是  
> ipk 内 `/usr/share/gutenprint/5.3/xml/printers/*.xml`（8 个家族定义文件），  
> |  |  |  
> | --- | --- |  
> 条目数与设备上 `lpinfo -m | grep -c gutenprint` 的行数一致。

## 总览

| 驱动包              | 型号数      | 覆盖品牌                                                                                                             | 技术路线                                                             |
| ---------------- | -------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| gutenprint 5.3.5 | 3608     | HP、Brother、Kyocera、Ricoh、Sharp、Xerox、Samsung、Epson、Canon、Lexmark、DNP、HiTi、Mitsubishi、Kodak、Sony、Datamax-O'Neil 等 | 通用驱动套件（PCL / ESC-P2 / Canon / 热升华 / DPL），CUPS 驱动插件按 XML 动态生成 PPD |
| hplip            | 1296     | HP / Apollo                                                                                                      | hpcups 原生驱动（喷墨 + 激光）                                             |
| foo2zjs          | 101      | HP、Oki、Samsung、KONICA、Xerox、Minolta、Fuji Xerox、Ricoh、Kyocera、Epson、Dell 等                                        | GDI/ZJS 主机开源替代（9 个 foo2* 家族）                                     |
| splix            | 86       | Samsung、Xerox、Dell、Toshiba、Lexmark                                                                               | Samsung QPDL 类 GDI 打印机                                           |
| brlaser          | 29       | Brother                                                                                                          | 单色激光，drv 动态生成 PPD                                                |
| brhl3040cn       | 1        | Brother HL-3040CN / HL-3070CW                                                                                    | 彩色 LED，闭源 i386 filter + box86 转译                                 |
| **合计**           | **5121** | —                                                                                                                | 存在型号重叠（同一机型多栈支持），实际可选条目以此为准                                      |

---

## gutenprint 5.3.5（通用驱动套件） — 3608 个型号

Gutenprint 是覆盖面最广的开源打印驱动套件，按打印机语言分成 8 个家族（每个家族对应一个 PPD 生成后端），  
下表按家族列出全部型号。要点：

- **PPD 是动态生成的**：`/usr/lib/cups/driver/gutenprint.5.3` 在 CUPS 枚举时按 XML 定义即时生成 PPD，  
  所以 ipk 里看不到 `.ppd` 文件；也正因如此，CUPS 网页的「选择型号」页面在装了本包后会明显变慢（首次枚举需生成上千份 PPD）。
- **命令行添加队列**时，下表「驱动名」即 gutenprint URI 中的型号段：  
  `lpadmin -p 队列名 -E -v <设备URI> -m "gutenprint.5.3://<驱动名>/expert"`。  
  |  |  |  
  | --- | --- |  
  实际 URI 用 `lpinfo -m | grep gutenprint.5.3` 核对。本 feed 编译时用了 `--disable-simplified-cups-ppds`，  
  每个型号只输出 `/expert` 一条（否则还会多出 `/simple` 简化版，即界面上带 `Simplified` 后缀的那份）。
- **EXPERIMENTAL 标记**（共 1341 个，其中 Canon 喷墨 1097 个）表示上游未取得充分实机验证，  
  能装上但不保证所有分辨率/纸张组合可用，接入前建议先用测试页验证。
- **与 hplip 的关系**：HP 机型优先用 hplip（hpcups 为 HP 官方调校）；Gutenprint 的 PCL 家族适合  
  hplip 未收录的老机型与 OEM 贴牌机（Apollo、Apple、Brother、Kyocera、Ricoh、Sharp 等）。

### PCL 系列 — 1607 个型号（其中 171 个标注 EXPERIMENTAL）

通用 PCL5/PCL6 激光与喷墨：HP LaserJet 兼容机、Brother、Kyocera、Ricoh、Sharp、Xerox、Samsung、Lexmark 激光等

| 型号                           | 驱动名                 | 备注 |
| ---------------------------- | ------------------- | -- |
| Apollo P-2100                | `pcl-apollo-p2100`  |    |
| Apollo P-2150                | `pcl-apollo-p2150`  |    |
| Apollo P-2200                | `pcl-apollo-p2200`  |    |
| Apollo P-2250                | `pcl-apollo-p2250`  |    |
| Apollo P-2500                | `pcl-apollo-p2500`  |    |
| Apollo P-2550                | `pcl-apollo-p2550`  |    |
| Apollo P-2600                | `pcl-apollo-p2600`  |    |
| Apollo P-2650                | `pcl-apollo-p2650`  |    |
| Apple Color StyleWriter 4100 | `pcl-apple-4100`    |    |
| Apple Color StyleWriter 4500 | `pcl-apple-4500`    |    |
| Apple Color StyleWriter 6500 | `pcl-apple-6500`    |    |
| Apple LaserWriter Select 360 | `pcl-apple-lw360`   |    |
| Brother DCP-1200             | `brother-dcp-1200`  |    |
| Brother DCP-8045D            | `brother-dcp-8045d` |    |
| Brother HL-1040              | `brother-hl-1040`   |    |
| Brother HL-1050              | `brother-hl-1050`   |    |
| Brother HL-1060              | `brother-hl-1060`   |    |
| Brother HL-1070              | `brother-hl-1070`   |    |
| Brother HL-10h               | `brother-hl-10h`    |    |
| Brother HL-10V               | `brother-hl-10v`    |    |
| Brother HL-1240              | `brother-hl-1240`   |    |
| Brother HL-1250              | `brother-hl-1250`   |    |
| Brother HL-1260              | `brother-hl-1260`   |    |
| Brother HL-1270N             | `brother-hl-1270n`  |    |
| Brother HL-1440    | `brother-hl-1440`    |              |
| Brother HL-1450    | `brother-hl-1450`    |              |
| Brother HL-1470N   | `brother-hl-1470n`   |              |
| Brother HL-1650    | `brother-hl-1650`    |              |
| Brother HL-1660e   | `brother-hl-1660e`   |              |
| Brother HL-1670N   | `brother-hl-1670n`   |              |
| Brother HL-1850    | `brother-hl-1850`    |              |
| Brother HL-1870N   | `brother-hl-1870n`   |              |
| Brother HL-2060    | `brother-hl-2060`    |              |
| Brother HL-2250DN  | `brother-hl-2250dn`  |              |
| Brother HL-2400CeN | `brother-hl-2400cen` | EXPERIMENTAL |
| Brother HL-2460    | `brother-hl-2460`    |              |
| Brother HL-2460N   | `brother-hl-2460n`   |              |
| Brother HL-2600CN  | `brother-hl-2600cn`  | EXPERIMENTAL |
| Brother HL-3400CN  | `brother-hl-3400cn`  | EXPERIMENTAL |
| Brother HL-3450CN  | `brother-hl-3450cn`  | EXPERIMENTAL |
| Brother HL-4040CN  | `brother-hl-4040cn`  |              |
| Brother HL-4Ve     | `brother-hl-4ve`     |              |
| Brother HL-5030    | `brother-hl-5030`    |              |
| Brother HL-5040    | `brother-hl-5040`    |              |
| Brother HL-5050    | `brother-hl-5050`    |              |
| Brother HL-5070N   | `brother-hl-5070n`   |              |
| Brother HL-5140    | `brother-hl-5140`    |              |
| Brother HL-5150D   | `brother-hl-5150d`   |              |
| Brother HL-5170DN        | `brother-hl-5170dn`       |              |
| Brother HL-5340D         | `brother-hl-5340d`        |              |
| Brother HL-630           | `brother-hl-630`          |              |
| Brother HL-660           | `brother-hl-660`          |              |
| Brother HL-7050          | `brother-hl-7050`         |              |
| Brother HL-7050N         | `brother-hl-7050n`        |              |
| Brother HL-760           | `brother-hl-760`          |              |
| Brother HL-960           | `brother-hl-960`          |              |
| Brother MFC-6550MC       | `brother-mfc-6550mc`      |              |
| Brother MFC-8300         | `brother-mfc-8300`        |              |
| Brother MFC-9500         | `brother-mfc-9500`        |              |
| Brother MFC-9600         | `brother-mfc-9600`        |              |
| Canon GP 335             | `canon-gp_335`            |              |
| Canon imageRunner 330s   | `canon-ir_330s`           |              |
| Canon imageRunner C2550  | `canon-imagerunner_c2550` |              |
| Canon imageRunner C2570  | `canon-ir_c2570`          | EXPERIMENTAL |
| Canon imageRunner C2570i | `canon-ir_c2570i`         | EXPERIMENTAL |
| Canon imageRunner C2570N | `canon-ir_c2570N`         | EXPERIMENTAL |
| Canon imageRunner C2620N | `canon-ir_c2620N`         | EXPERIMENTAL |
| Canon imageRunner C3100  | `canon-ir_c3100`          | EXPERIMENTAL |
| Canon imageRunner C3170  | `canon-ir_c3170`          | EXPERIMENTAL |
| Canon imageRunner C3170i | `canon-ir_c3170i`         | EXPERIMENTAL |
| Canon imageRunner C3200  | `canon-ir_c3200`          | EXPERIMENTAL |
| Canon imageRunner C5030  | `canon-ir_c5030`          | EXPERIMENTAL |
| Canon imageRunner C5058  | `canon-imagerunner_c5058`  |              |
| Canon imageRunner C5068  | `canon-imagerunner_c5068`  |              |
| Canon imageRunner C5180  | `canon-ir_c5180`           | EXPERIMENTAL |
| Canon imageRunner C5185  | `canon-imagerunner_c5185`  |              |
| Canon imageRunner C5185i | `canon-imagerunner_c5185i` |              |
| Canon imageRunner C5800  | `canon-ir_c5800`           | EXPERIMENTAL |
| Canon imageRunner C5870U | `canon-ir_c5870U`          | EXPERIMENTAL |
| Canon imageRunner C6800  | `canon-ir_c6800`           | EXPERIMENTAL |
| Canon imageRunner C6870U | `canon-ir_c6870u`          | EXPERIMENTAL |
| Canon LBP-1000           | `canon-lbp-1000`           |              |
| Canon LBP-1260           | `canon-lbp-1260`           |              |
| Canon LBP-1760           | `canon-lbp-1760`           |              |
| Canon LBP-3360           | `canon-lbp-3360`           |              |
| Canon LBP-430            | `canon-lbp-430`            |              |
| Canon LBP-4sx            | `canon-lbp-4sx`            |              |
| Canon LBP-5360           | `canon-lbp-5360`           |              |
| Canon LBP-5390           | `canon-lbp-5390`           |              |
| Citizen ProJet II        | `citizen-projet_ii`        |              |
| Datamax-ONeil H8308p     | `datamax_oneil_H8308p`     |              |
| Datamax-ONeil p1115      | `datamax_oneil_p1115`      |              |
| Datamax-ONeil p1115s     | `datamax_oneil_p1115s`     |              |
| Datamax-ONeil p1120n     | `datamax_oneil_p1120n`     |              |
| Datamax-ONeil p1125      | `datamax_oneil_p1125`      |              |
| Datamax-ONeil p1725      | `datamax_oneil_p1725`      |              |
| Datamax-ONeil w1110    | `datamax_oneil_w1110` |              |
| DEC 1800               | `dec-1800`            |              |
| DEC LN17               | `dec-ln17`            |              |
| Dell 3000cn            | `dell-3000cn`         |              |
| Dell 3100cn            | `dell-3100cn`         |              |
| Epson ActionLaser 1100 | `epson-actl_1100`     |              |
| Epson ActionLaser II   | `epson-actl_ii`       |              |
| Epson AL-C2000         | `epson-acl_c2000`     |              |
| Epson AL-C2000 PS3     | `epson-acl_c2000ps`   |              |
| Epson AL-C8500         | `epson-acl_c8500`     |              |
| Epson AL-C8500PS       | `epson-acl_c8500ps`   |              |
| Epson AL-C8600         | `epson-acl_c8600`     | EXPERIMENTAL |
| Epson AL-C8600 PS3     | `epson-acl_c8600ps`   | EXPERIMENTAL |
| Epson EPL-5200         | `epson-epl-5200`      |              |
| Epson EPL-5200+        | `epson-epl-5200plus`  |              |
| Epson EPL-5700         | `epson-epl-5700`      |              |
| Epson EPL-5700PS       | `epson-epl-5700ps`    |              |
| Epson EPL-5800         | `epson-epl-5800`      |              |
| Epson EPL-5800PS       | `epson-epl-5800ps`    |              |
| Epson EPL-5900         | `epson-epl-5900`      |              |
| Epson EPL-5900 PS3     | `epson-epl-5900ps`    |              |
| Epson EPL-6100         | `epson-epl-6100`      |              |
| Epson EPL-6100 PS3     | `epson-epl-6100ps`    |              |
| Epson EPL-7100         | `epson-epl-7100`      |              |
| Epson EPL-N2050                      | `epson-epl-n2050`       |    |
| Epson EPL-N2050+                     | `epson-epl-n2050plus`   |    |
| Epson EPL-N2050PS                    | `epson-epl-n2050ps`     |    |
| Epson EPL-N2050PS+                   | `epson-epl-n2050psplus` |    |
| Epson EPL-N2120                      | `epson-epl-n2120`       |    |
| Epson EPL-N2500                      | `epson-epl-n2500`       |    |
| Epson EPL-N2500 PS3                  | `epson-epl-n2500ps`     |    |
| Epson EPL-N2750                      | `epson-epl-n2750`       |    |
| Epson EPL-N2750PS                    | `epson-epl-n2750ps`     |    |
| Fujitsu PrintPartner 10V             | `fujitsu-pp_10v`        |    |
| Fujitsu PrintPartner 16DV            | `fujitsu-pp_16dv`       |    |
| Fujitsu PrintPartner 20W             | `fujitsu-pp_20w`        |    |
| Fujitsu PrintPartner 8000            | `fujitsu-pp_8000`       |    |
| Generic PCL 4 LF Printer             | `pcl-g_4_l`             |    |
| Generic PCL 4 Printer                | `pcl-g_4`               |    |
| Generic PCL 4 Printer wide margin    | `pcl-g_4_a4`            |    |
| Generic PCL 5 LF Printer             | `pcl-g_5_l`             |    |
| Generic PCL 5 Printer                | `pcl-g_5`               |    |
| Generic PCL 5 Printer wide margin    | `pcl-g_5_a4`            |    |
| Generic PCL 5c LF Printer            | `pcl-g_5c_l`            |    |
| Generic PCL 5c Printer               | `pcl-g_5c`              |    |
| Generic PCL 5e LF Printer            | `pcl-g_5e_l`            |    |
| Generic PCL 5e Printer               | `pcl-g_5e`              |    |
| Generic PCL 6 LF Printer wide margin | `pcl-g_6_lf_a4`         |    |
| Generic PCL 6 Printer wide margin      | `pcl-g_6_a4`         |              |
| Generic PCL 6 Tabl Printer wide margin | `pcl-g_6_tabloid_a4` |              |
| Generic PCL 6/PCL XL LF Printer        | `pcl-g_6_l`          |              |
| Generic PCL 6/PCL XL Printer           | `pcl-g_6`            |              |
| Generic PCL Color Laser                | `pcl-g_c`            | EXPERIMENTAL |
| Generic PCL Color Laser LF Printer     | `pcl-g_c_l`          | EXPERIMENTAL |
| Generic PCL Color LF wide margin       | `pcl-g_c_lf_a4`      | EXPERIMENTAL |
| Generic PCL Color Tabl wide margin     | `pcl-g_c_tabloid_a4` | EXPERIMENTAL |
| Generic PCL Color wide margin          | `pcl-g_c_a4`         | EXPERIMENTAL |
| Gestetner 10512                        | `gestetner-10512`    |              |
| Gestetner 2212                         | `gestetner-2212`     |              |
| Gestetner 2712                         | `gestetner-2712`     |              |
| Gestetner 3212                         | `gestetner-3212`     |              |
| Gestetner 3502                         | `gestetner-3502`     |              |
| Gestetner 3532/4235g                   | `gestetner-4235g`    |              |
| Gestetner 4502                         | `gestetner-4502`     |              |
| Gestetner 4532/4245g                   | `gestetner-4245g`    |              |
| Gestetner 6002                         | `gestetner-6002`     |              |
| Gestetner 7502                         | `gestetner-7502`     |              |
| Gestetner 9002                         | `gestetner-9002`     |              |
| Gestetner CS555                        | `gestetner-cs555`    |              |
| Gestetner DSc1020                      | `gestetner-dsc1020`  |              |
| Gestetner DSc1025                      | `gestetner-dsc1025`  |              |
| Gestetner DSc1030                      | `gestetner-dsc1030`  |              |

| Gestetner DSc1045 | `gestetner-dsc1045` |  |
| Gestetner DSc1060 | `gestetner-dsc1060` |  |
| Gestetner DSc1120 | `gestetner-dsc1120` |  |
| Gestetner DSc1220 | `gestetner-dsc1220` |  |
| Gestetner DSc1225 | `gestetner-dsc1225` |  |
| Gestetner DSc1230 | `gestetner-dsc1230` |  |
| Gestetner DSc1245 | `gestetner-dsc1245` |  |
| Gestetner DSc1260 | `gestetner-dsc1260` |  |
| Gestetner DSc424 | `gestetner-dsc424` |  |
| Gestetner DSc428 | `gestetner-dsc428` |  |
| Gestetner DSc432 | `gestetner-dsc432` |  |
| Gestetner DSc435 | `gestetner-dsc435` |  |
| Gestetner DSc445 | `gestetner-dsc445` |  |
| Gestetner DSc460 | `gestetner-dsc460` |  |
| Gestetner DSm415 | `gestetner-dsm415` |  |
| Gestetner DSm615 | `gestetner-dsm615` |  |
| Gestetner DSm616 | `gestetner-dsm616` |  |
| Gestetner DSm618 | `gestetner-dsm618` |  |
| Gestetner DSm618d | `gestetner-dsm618d` |  |
| Gestetner DSm620 | `gestetner-dsm620` |  |
| Gestetner DSm620d | `gestetner-dsm620d` |  |
| Gestetner DSm622 | `gestetner-dsm622` |  |
| Gestetner DSm627 | `gestetner-dsm627` |  |
| Gestetner DSm635/635G | `gestetner-dsm635g` |  |
| Gestetner DSm645/645G | `gestetner-ds645g` |  |
| Gestetner DSm651 | `gestetner-dsm651` |  |
| Gestetner DSm660 | `gestetner-dsm660` |  |
| Gestetner DSm675 | `gestetner-dsm675` |  |
| Gestetner DSm725 | `gestetner-dsm725` |  |
| Gestetner DSm730 | `gestetner-dsm730` |  |
| Gestetner DSm735/735G | `gestetner-dsm735g` |  |
| Gestetner DSm745/745G | `gestetner-dsm745g` |  |
| Gestetner MP 161/DSm416 | `gestetner-dsm416` |  |
| Gestetner MP 2510/DSm725e | `gestetner-dsm725e` |  |
| Gestetner MP 2550 | `gestetner-mp_2550` |  |
| Gestetner MP 2550B | `gestetner-mp_2550b` |  |
| Gestetner MP 3010/DSm730e | `gestetner-dsm730e` |  |
| Gestetner MP 3350 | `gestetner-mp_3350` |  |
| Gestetner MP 3350B | `gestetner-mp_3350b` |  |
| Gestetner MP 4000 | `gestetner-mp_4000` |  |
| Gestetner MP 4000B | `gestetner-mp_4000b` |  |
| Gestetner MP 5000 | `gestetner-mp_5000` |  |
| Gestetner MP 5000B | `gestetner-mp_5000b` |  |
| Gestetner MP C2003 | `gestetner-mp_c2003` |  |
| Gestetner MP C2004 | `gestetner-mp_c2004` |  |
| Gestetner MP C2011 | `gestetner-mp_c2011` |  |
| Gestetner MP C2050 | `gestetner-mp_c2050` |  |
| Gestetner MP C2051 | `gestetner-mp_c2051` |  |
| Gestetner MP C2503 | `gestetner-mp_c2503` |  |
| Gestetner MP C2504 | `gestetner-mp_c2504` |  |
| Gestetner MP C2550 | `gestetner-mp_c2550` |  |
| Gestetner MP C2551 | `gestetner-mp_c2551` |  |
| Gestetner MP C2800 | `gestetner-mp_c2800` |  |
| Gestetner MP C300 | `gestetner-mp_c300` |  |
| Gestetner MP C3001 | `gestetner-mp_c3001` |  |
| Gestetner MP C3002 | `gestetner-mp_c3002` |  |
| Gestetner MP C3003 | `gestetner-mp_c3003` |  |
| Gestetner MP C3004 | `gestetner-mp_c3004` |  |
| Gestetner MP C300SR | `gestetner-mp_c300sr` |  |
| Gestetner MP C3300 | `gestetner-mp_c3300` |  |
| Gestetner MP C3501 | `gestetner-mp_c3501` |  |
| Gestetner MP C3502 | `gestetner-mp_c3502` |  |
| Gestetner MP C3503 | `gestetner-mp_c3503` |  |
| Gestetner MP C3504 | `gestetner-mp_c3504` |  |
| Gestetner MP C400 | `gestetner-mp_c400` |  |
| Gestetner MP C4000 | `gestetner-mp_c4000` |  |
| Gestetner MP C400SR | `gestetner-mp_c400sr` |  |
| Gestetner MP C4501 | `gestetner-mp_c4501` |  |
| Gestetner MP C4501A | `gestetner-mp_c4501a` |  |
| Gestetner MP C4502 | `gestetner-mp_c4502` |  |
| Gestetner MP C4502A | `gestetner-mp_c4502a` |  |
| Gestetner MP C4503 | `gestetner-mp_c4503` |  |
| Gestetner MP C4504 | `gestetner-mp_c4504` |  |
| Gestetner MP C5000 | `gestetner-mp_c5000` |  |
| Gestetner MP C5501 | `gestetner-mp_c5501` |  |
| Gestetner MP C5501A | `gestetner-mp_c5501a` |  |
| Gestetner MP C5502 | `gestetner-mp_c5502` |  |
| Gestetner MP C5502A | `gestetner-mp_c5502a` |  |
| Gestetner MP C5503 | `gestetner-mp_c5503` |  |
| Gestetner MP C6000 | `gestetner-mp_c6000` |  |
| Gestetner MP C6003 | `gestetner-mp_c6003` |  |
| Gestetner MP C6004 | `gestetner-mp_c6004` |  |
| Gestetner MP C6501 | `gestetner-mp_c6501` |  |
| Gestetner MP C6502 | `gestetner-mp_c6502` |  |
| Gestetner MP C6503 | `gestetner-mp_c6503` |  |
| Gestetner MP C7500 | `gestetner-mp_c7500` |  |
| Gestetner MP C7501 | `gestetner-mp_c7501` |  |
| Gestetner MP C8002 | `gestetner-mp_c8002` |  |
| Gestetner MP C8003 | `gestetner-mp_c8003` |  |
| Gestetner MP1100/DSm7110 | `gestetner-dsm7110` |  |
| Gestetner MP1350/DSm7135 | `gestetner-dsm7135` |  |
| Gestetner MP1600/DSm716 | `gestetner-dsm716` |  |
| Gestetner MP2000/DSm721d | `gestetner-dsm721d` |  |
| Gestetner MP2500/DSm625 | `gestetner-dsm625` |  |
| Gestetner MP3500/DSm735e | `gestetner-dsm735e` |  |
| Gestetner MP4500/DSm745e | `gestetner-dsm745e` |  |
| Gestetner MP5500/DSm755 | `gestetner-dsm755` |  |
| Gestetner MP6500/DSm765 | `gestetner-dsm765` |  |
| Gestetner MP7500/DSm775 | `gestetner-dsm775` |  |
| Gestetner MP9000/DSm790 | `gestetner-dsm790` |  |
| Gestetner MPC1500/GS106 | `gestetner-mpc1500_gs106` |  |
| Gestetner MPC2500/DSc525 | `gestetner-mpc2500_dsc525` |  |
| Gestetner MPC3000/DSc530 | `gestetner-mpc3000_dsc530` |  |
| Gestetner MPC3500/DSc535 | `gestetner-mpc3500_dsc535` |  |
| Gestetner MPC4500/DSc545 | `gestetner-mpc4500_dsc545` |  |
| Gestetner Pro C5200S | `gestetner-pro_c5200s` |  |
| Gestetner Pro C5210S | `gestetner-pro_c5210s` |  |
| HP Business Inkjet 2200 | `hp-bij_2200` |  |
| HP Business Inkjet 2230 | `hp-bij_2230` |  |
| HP Business Inkjet 2250 | `hp-bij_2250` |  |
| HP Business Inkjet 2250TN | `hp-bij_2250tn` |  |
| HP Business Inkjet 2280 | `hp-bij_2280` |  |
| HP Color Inkjet Printer CP1160 | `hp-cij_cp1160` |  |
| HP Color Inkjet Printer CP1700 | `hp-cij_cp1700` |  |
| HP Color LaserJet 2500 | `hp-clj_2500` | EXPERIMENTAL |
| HP Color LaserJet 3000 | `hp-clj_3000` | EXPERIMENTAL |
| HP Color LaserJet 3000dn | `hp-clj_3000dn` | EXPERIMENTAL |
| HP Color LaserJet 3000dtn | `hp-clj_3000dtn` | EXPERIMENTAL |
| HP Color LaserJet 3000n | `hp-clj_3000n` | EXPERIMENTAL |
| HP Color LaserJet 3700 | `hp-clj_3700` | EXPERIMENTAL |
| HP Color LaserJet 3700n | `hp-clj_3700n` | EXPERIMENTAL |
| HP Color LaserJet 3800 | `hp-clj_3800` | EXPERIMENTAL |
| HP Color LaserJet 3800dn | `hp-clj_3800dn` | EXPERIMENTAL |
| HP Color LaserJet 3800dtn | `hp-clj_3800dtn` | EXPERIMENTAL |
| HP Color LaserJet 3800n | `hp-clj_3800n` | EXPERIMENTAL |
| HP Color LaserJet 4500 | `hp-clj_4500` | EXPERIMENTAL |
| HP Color LaserJet 4550 | `hp-clj_4550` | EXPERIMENTAL |
| HP Color LaserJet 4600 | `hp-clj_4600` | EXPERIMENTAL |
| HP Color LaserJet 4610 | `hp-clj_4610` | EXPERIMENTAL |
| HP Color LaserJet 4650 | `hp-clj_4650` | EXPERIMENTAL |
| HP Color LaserJet 4700 | `hp-clj_4700` | EXPERIMENTAL |
| HP Color LaserJet 4700dn | `hp-clj_4700dn` | EXPERIMENTAL |
| HP Color LaserJet 4700dtn | `hp-clj_4700dtn` | EXPERIMENTAL |
| HP Color LaserJet 4700n | `hp-clj_4700n` | EXPERIMENTAL |
| HP Color LaserJet 4700ph+ | `hp-clj_4700phplus` | EXPERIMENTAL |
| HP Color LaserJet 5 | `hp-clj_5` | EXPERIMENTAL |
| HP Color LaserJet 5000 | `hp-clj_5000` | EXPERIMENTAL |
| HP Color LaserJet 5500 | `hp-clj_5500` | EXPERIMENTAL |
| HP Color LaserJet 5500dn | `hp-clj_5500dn` | EXPERIMENTAL |
| HP Color LaserJet 5500dtn | `hp-clj_5500dtn` | EXPERIMENTAL |
| HP Color LaserJet 5500hdn | `hp-clj_5500hdn` | EXPERIMENTAL |
| HP Color LaserJet 5500n | `hp-clj_5500n` | EXPERIMENTAL |
| HP Color LaserJet 5m | `hp-clj_5m` | EXPERIMENTAL |
| HP Color LaserJet 8500 | `hp-clj_8500` | EXPERIMENTAL |
| HP Color LaserJet 8500dn | `hp-clj_8500dn` | EXPERIMENTAL |
| HP Color LaserJet 8500n | `hp-clj_8500n` | EXPERIMENTAL |
| HP Color LaserJet 8550 | `hp-clj_8550` | EXPERIMENTAL |
| HP Color LaserJet 8550DN | `hp-clj_8550dn` | EXPERIMENTAL |
| HP Color LaserJet 8550GN | `hp-clj_8550gn` | EXPERIMENTAL |
| HP Color LaserJet 8550MN | `hp-clj_8550mn` | EXPERIMENTAL |
| HP Color LaserJet 9500 | `hp-clj_9500` | EXPERIMENTAL |
| HP Color LaserJet 9500gp | `hp-clj_9500gp` | EXPERIMENTAL |
| HP Color LaserJet 9500hdn | `hp-clj_9500hdn` | EXPERIMENTAL |
| HP Color LaserJet 9500n | `hp-clj_9500n` | EXPERIMENTAL |
| HP Color LaserJet CM1312 | `hp-clj_cm1312` | EXPERIMENTAL |
| HP Color LaserJet CM1312nfi | `hp-clj_9500nfi` | EXPERIMENTAL |
| HP Color LaserJet CM1411fn | `hp-clj_cm1411fn` | EXPERIMENTAL |
| HP Color LaserJet CM1412fn | `hp-clj_cm1412fn` | EXPERIMENTAL |
| HP Color LaserJet CM1413fn | `hp-clj_cm1413fn` | EXPERIMENTAL |
| HP Color LaserJet CM1415fn | `hp-clj_cm1415fn` | EXPERIMENTAL |
| HP Color LaserJet CM1415fnw | `hp-clj_cm1415fn2` | EXPERIMENTAL |
| HP Color LaserJet CM1416fnw | `hp-clj_cm1416fn2` | EXPERIMENTAL |
| HP Color LaserJet CM1417fnw | `hp-clj_cm1417fn2` | EXPERIMENTAL |
| HP Color LaserJet CM1418fnw | `hp-clj_cm1418fn2` | EXPERIMENTAL |
| HP Color LaserJet CM2320 MFP | `hp-clj_cm2320` | EXPERIMENTAL |
| HP Color LaserJet CM2320FXI MFP | `hp-clj_cm2320fxi` | EXPERIMENTAL |
| HP Color LaserJet CM2320N MFP | `hp-clj_cm2320n` | EXPERIMENTAL |
| HP Color LaserJet CM2320NF MFP | `hp-clj_cm2320nf` | EXPERIMENTAL |
| HP Color LaserJet CM3530 MFP | `hp-clj_cm3530_mfp` | EXPERIMENTAL |
| HP Color LaserJet CM4540 MFP | `hp-clj_cm4540_mfp` | EXPERIMENTAL |
| HP Color LaserJet CM4730 MFP | `hp-clj_cm4730_mfp` | EXPERIMENTAL |
| HP Color LaserJet CM6030 MFP | `hp-clj_cm6030_mfp` | EXPERIMENTAL |
| HP Color LaserJet CM6040 MFP | `hp-clj_cm6040_mfp` | EXPERIMENTAL |
| HP Color LaserJet CM6040f MFP | `hp-clj_cm6040f_mfp` | EXPERIMENTAL |
| HP Color LaserJet CM6049f MFP | `hp-clj_cm6049f_mfp` | EXPERIMENTAL |
| HP Color LaserJet CP1514n | `hp-clj_cp1514n` | EXPERIMENTAL |
| HP Color LaserJet CP1515n | `hp-clj_cp1515n` | EXPERIMENTAL |
| HP Color LaserJet CP1518ni | `hp-clj_cp1518ni` | EXPERIMENTAL |
| HP Color LaserJet CP2025 | `hp-clj_cp2025` | EXPERIMENTAL |
| HP Color LaserJet CP2025dn | `hp-clj_cp2025dn` | EXPERIMENTAL |
| HP Color LaserJet CP2025n | `hp-clj_cp2025n` | EXPERIMENTAL |
| HP Color LaserJet CP2025x | `hp-clj_cp2025x` | EXPERIMENTAL |
| HP Color LaserJet CP3505 | `hp-clj_cp3505` | EXPERIMENTAL |
| HP Color LaserJet CP3505dn | `hp-clj_cp3505dn` | EXPERIMENTAL |
| HP Color LaserJet CP3505n | `hp-clj_cp3505n` | EXPERIMENTAL |
| HP Color LaserJet CP3505x | `hp-clj_cp3505x` | EXPERIMENTAL |
| HP Color LaserJet CP3525 | `hp-clj_cp3525` | EXPERIMENTAL |
| HP Color LaserJet CP3525dn | `hp-clj_cp3525dn` | EXPERIMENTAL |
| HP Color LaserJet CP3525n | `hp-clj_cp3525n` | EXPERIMENTAL |
| HP Color LaserJet CP3525x | `hp-clj_cp3525x` | EXPERIMENTAL |
| HP Color LaserJet CP4005 | `hp-clj_cp4005` | EXPERIMENTAL |
| HP Color LaserJet CP4005dn | `hp-clj_cp4005dn` | EXPERIMENTAL |

| HP Color LaserJet CP4005n | `hp-clj_cp4005n` | EXPERIMENTAL |
| HP Color LaserJet CP4020 | `hp-clj_cp4020` | EXPERIMENTAL |
| HP Color LaserJet CP4500 | `hp-clj_cp4500` | EXPERIMENTAL |
| HP Color LaserJet CP4520 | `hp-clj_cp4520` | EXPERIMENTAL |
| HP Color LaserJet CP4540 MFP | `hp-clj_cp4540` | EXPERIMENTAL |
| HP Color LaserJet CP5225 | `hp-clj_cp5225` | EXPERIMENTAL |
| HP Color LaserJet CP5225dn | `hp-clj_cp5225dn` | EXPERIMENTAL |
| HP Color LaserJet CP5225n | `hp-clj_cp5225n` | EXPERIMENTAL |
| HP Color LaserJet CP5520 | `hp-clj_cp5520` | EXPERIMENTAL |
| HP Color LaserJet CP6015de | `hp-clj_cp6015de` | EXPERIMENTAL |
| HP Color LaserJet CP6015dn | `hp-clj_cp6015dn` | EXPERIMENTAL |
| HP Color LaserJet CP6015n | `hp-clj_cp6015n` | EXPERIMENTAL |
| HP Color LaserJet CP6015x | `hp-clj_cp6015x` | EXPERIMENTAL |
| HP Color LaserJet CP6015xh | `hp-clj_cp6015xh` | EXPERIMENTAL |
| HP DesignJet 230 | `pcl-desnj-230` |  |
| HP DesignJet 2500CP | `pcl-desnj-2500` |  |
| HP DesignJet 250C | `pcl-desnj-250` |  |
| HP DesignJet 3500CP | `pcl-desnj-3500` |  |
| HP DesignJet 430 | `pcl-desnj-430` |  |
| HP DesignJet 450C | `pcl-desnj-450` |  |
| HP DesignJet 455CA | `pcl-desnj-455` |  |
| HP DesignJet 488CA | `pcl-desnj-488` |  |
| HP DesignJet 700 | `pcl-desnj-700` |  |
| HP DesignJet 750C | `pcl-750` |  |
| HP DesignJet 750C Plus | `hp-desnj_750c_plus` |  |
| HP DesignJet ColorPro CAD | `hp-desnj_cp_cad` |  |
| HP DeskJet 1100C | `pcl-1100` |  |
| HP DeskJet 1120C | `pcl-1120` |  |
| HP DeskJet 1125C | `hp-dj_1125c` |  |
| HP DeskJet 1200C | `pcl-1200` |  |
| HP DeskJet 1220C | `pcl-1220` |  |
| HP DeskJet 1600C | `pcl-1600` |  |
| HP DeskJet 1600CM | `hp-dj_1600cm` |  |
| HP DeskJet 2000 | `pcl-2000` |  |
| HP DeskJet 2500 | `pcl-2500` |  |
| HP DeskJet 2500CM | `hp-2500cm` |  |
| HP DeskJet 340C | `pcl-340` |  |
| HP DeskJet 3810 | `hp-dj_3810` |  |
| HP DeskJet 3816 | `hp-dj_3816` |  |
| HP DeskJet 3820 | `hp-dj_3820` |  |
| HP DeskJet 3822 | `hp-dj_3822` |  |
| HP DeskJet 400 | `pcl-400` |  |
| HP DeskJet 420C | `hp-dj_420c` |  |
| HP DeskJet 450 | `hp-dj_450` |  |
| HP DeskJet 500 | `pcl-500` |  |
| HP DeskJet 500C | `pcl-501` |  |
| HP DeskJet 505J Plus | `hp-dj_505j_plus` |  |
| HP DeskJet 510 | `hp-dj_510` |  |
| HP DeskJet 520 | `pcl-520` |  |
| HP DeskJet 540C | `pcl-540` |  |
| HP DeskJet 550C | `pcl-550` |  |
| HP DeskJet 5550 | `hp-dj_5550` |  |
| HP DeskJet 5551 | `hp-dj_5551` |  |
| HP DeskJet 560C | `pcl-560` |  |
| HP DeskJet 600 | `pcl-600` |  |
| HP DeskJet 600C | `pcl-601` |  |
| HP DeskJet 610C | `hp-dj_610c` |  |
| HP DeskJet 610CL | `hp-dj_610cl` |  |
| HP DeskJet 6122 | `hp-dj_6122` |  |
| HP DeskJet 6127 | `hp-dj_6127` |  |
| HP DeskJet 612C | `hp-dj_612c` |  |
| HP DeskJet 640C | `hp-dj_640c` |  |
| HP DeskJet 648C | `hp-dj_648c` |  |
| HP DeskJet 660C | `hp-dj_660c` |  |
| HP DeskJet 670C | `hp-dj_670c` |  |
| HP DeskJet 670TV | `hp-dj_670tv` |  |
| HP DeskJet 672C | `hp-dj_672c` |  |
| HP DeskJet 680C | `hp-dj_680c` |  |
| HP DeskJet 682C | `hp-dj_682c` |  |
| HP DeskJet 690C | `pcl-690` |  |
| HP DeskJet 692C | `hp-dj_692c` |  |
| HP DeskJet 693C | `hp-dj_693c` |  |
| HP DeskJet 694C | `hp-dj_694c` |  |
| HP DeskJet 695C | `hp-dj_695c` |  |
| HP DeskJet 697C | `hp-dj_697c` |  |
| HP DeskJet 810C | `pcl-810` |  |
| HP DeskJet 812C | `pcl-812` |  |
| HP DeskJet 815C | `hp-dj_815c` |  |
| HP DeskJet 816C | `hp-dj_816c` |  |
| HP DeskJet 825C | `hp-dj_825c` |  |
| HP DeskJet 830C | `hp-dj_830c` |  |
| HP DeskJet 832C | `hp-dj_832c` |  |
| HP DeskJet 840C | `pcl-840` |  |
| HP DeskJet 841C | `hp-dj_841c` |  |
| HP DeskJet 842C | `pcl-842` |  |
| HP DeskJet 843C | `hp-dj_843c` |  |
| HP DeskJet 845C | `pcl-845` |  |
| HP DeskJet 850C | `pcl-850` |  |
| HP DeskJet 855C | `pcl-855` |  |
| HP DeskJet 870C | `pcl-870` |  |
| HP DeskJet 880C | `hp-dj_880c` |  |
| HP DeskJet 882C | `hp-dj_882c` |  |
| HP DeskJet 890C | `pcl-890` |  |
| HP DeskJet 895C | `pcl-895` |  |
| HP DeskJet 916C | `pcl-900` |  |
| HP DeskJet 920C | `hp-dj_920c` |  |
| HP DeskJet 9300 | `hp-dj_9300` |  |
| HP DeskJet 930C | `hp-dj_930c` |  |
| HP DeskJet 932C | `hp-dj_932c` |  |
| HP DeskJet 933C | `hp-dj_933c` |  |
| HP DeskJet 934C | `hp-dj_934c` |  |
| HP DeskJet 935C | `hp-dj_935c` |  |
| HP DeskJet 940C | `hp-dj_940c` |  |
| HP DeskJet 948C | `hp-dj_948c` |  |
| HP DeskJet 950C | `hp-dj_950c` |  |
| HP DeskJet 952C | `hp-dj_952c` |  |
| HP DeskJet 955C | `hp-dj_955c` |  |
| HP DeskJet 957C | `hp-dj_957c` |  |
| HP DeskJet 959C | `hp-dj_959c` |  |
| HP DeskJet 960C | `hp-dj_960c` |  |
| HP DeskJet 970C | `hp-dj_970c` |  |
| HP DeskJet 975C | `hp-dj_975c` |  |
| HP DeskJet 980C | `hp-dj_980c` |  |
| HP DeskJet 990C | `hp-dj_990c` |  |
| HP DeskJet 995C | `hp-dj_995c` |  |
| HP e-printer e20 | `hp-e-printer_e20` |  |
| HP LaserJet 1010 | `hp-lj_1010` |  |
| HP LaserJet 1012 | `hp-lj_1012` |  |
| HP LaserJet 1015 | `hp-lj_1015` |  |
| HP LaserJet 1022 | `hp-lj_1022` |  |
| HP LaserJet 1100 | `hp-lj_1100` |  |
| HP LaserJet 1100A | `hp-lj_1100a` |  |
| HP LaserJet 1150 | `hp-lj_1150` |  |
| HP LaserJet 1160 | `hp-lj_1160` |  |
| HP LaserJet 1200 | `hp-lj_1200` |  |
| HP LaserJet 1220 | `hp-lj_1220` |  |
| HP LaserJet 1300 | `hp-lj_1300` |  |
| HP LaserJet 1320 | `hp-lj_1320` |  |
| HP LaserJet 2 | `pcl-2` |  |
| HP LaserJet 2100 | `hp-lj_2100` |  |
| HP LaserJet 2100M | `hp-lj_2100m` |  |
| HP LaserJet 2200 | `hp-lj_2200` |  |
| HP LaserJet 2300 | `hp-lj_2300` |  |
| HP LaserJet 2410 | `hp-lj_2410` |  |
| HP LaserJet 2420 | `hp-lj_2420` |  |
| HP LaserJet 2430 | `hp-lj_2430` |  |
| HP LaserJet 2D | `hp-lj_2d` |  |
| HP LaserJet 2P | `pcl-2p` |  |
| HP LaserJet 2P Plus | `hp-lj_2p_plus` |  |
| HP LaserJet 3 | `pcl-3` |  |
| HP LaserJet 3015 | `hp-lj_3015` |  |
| HP LaserJet 3020 | `hp-lj_3020` |  |
| HP LaserJet 3030 | `hp-lj_3030` |  |
| HP LaserJet 3050 | `hp-lj_3050` |  |
| HP LaserJet 3052 | `hp-lj_3052` |  |
| HP LaserJet 3055 | `hp-lj_3055` |  |
| HP LaserJet 3200 | `hp-lj_3200` |  |
| HP LaserJet 3200m | `hp-lj_3200m` |  |
| HP LaserJet 3200se | `hp-lj_3200se` |  |
| HP LaserJet 3300 MFP | `hp-lj_3300_mfp` |  |
| HP LaserJet 3310 MFP | `hp-lj_3310_mfp` |  |
| HP LaserJet 3320 MFP | `hp-lj_3320_mfp` |  |
| HP LaserJet 3320N MFP | `hp-lj_3320n_mfp` |  |
| HP LaserJet 3330 MFP | `hp-lj_3330_mfp` |  |
| HP LaserJet 3380 | `hp-lj_3380` |  |
| HP LaserJet 3390 | `hp-lj_3390` |  |
| HP LaserJet 3392 | `hp-lj_3392` |  |
| HP LaserJet 3D | `hp-lj_3d` |  |
| HP LaserJet 3P w/ PCL5 | `hp-lj_3p_w_pcl5` |  |
| HP LaserJet 3P w/PS | `hp-lj_3p_w_ps` |  |
| HP LaserJet 4 | `pcl-4` |  |
| HP LaserJet 4 Plus | `hp-lj_4_plus` |  |
| HP LaserJet 4000 | `hp-lj_4000` |  |
| HP LaserJet 4050 | `hp-lj_4050` |  |
| HP LaserJet 4100 | `hp-lj_4100` |  |
| HP LaserJet 4200 | `hp-lj_4200` |  |
| HP LaserJet 4240 | `hp-lj_4240` |  |
| HP LaserJet 4250 | `hp-lj_4250` |  |
| HP LaserJet 4300 | `hp-lj_4300` |  |
| HP LaserJet 4345 mfp | `hp-lj_4345_mfp` |  |
| HP LaserJet 4350 | `hp-lj_4350` |  |
| HP LaserJet 4L | `pcl-4l` |  |
| HP LaserJet 4M | `hp-lj_4m` |  |
| HP LaserJet 4ML | `hp-lj_4ml` |  |
| HP LaserJet 4P | `hp-lj_4p` |  |
| HP LaserJet 4Si | `pcl-4si` |  |
| HP LaserJet 4V | `pcl-4v` |  |
| HP LaserJet 5 | `pcl-5` |  |
| HP LaserJet 5000 | `hp-lj_5000` |  |
| HP LaserJet 5100 | `hp-lj_5100` |  |
| HP LaserJet 5200 | `hp-lj_5200` |  |
| HP LaserJet 5200L | `hp-lj_5200l` |  |
| HP LaserJet 5L | `hp-lj_5l` |  |
| HP LaserJet 5M | `hp-lj_5m` |  |
| HP LaserJet 5MP | `hp-lj_5mp` |  |
| HP LaserJet 5N | `hp-lj_5n` |  |
| HP LaserJet 5P | `hp-lj_5p` |  |
| HP LaserJet 5Si | `pcl-5si` |  |
| HP LaserJet 6 | `pcl-6` |  |
| HP LaserJet 6L | `hp-lj_6l` |  |
| HP LaserJet 6MP | `hp-lj_6mp` |  |
| HP LaserJet 6P | `hp-lj_6p` |  |
| HP LaserJet 8000 | `hp-lj_8000` |  |
| HP LaserJet 8100 | `hp-lj_8100` |  |
| HP LaserJet 8150 | `hp-lj_8150` |  |
| HP LaserJet 9000 | `hp-lj_9000` |  |
| HP LaserJet 9040 | `hp-lj_9040` |  |
| HP LaserJet 9040 MFP | `hp-lj_9040_mfp` |  |
| HP LaserJet 9050 | `hp-lj_9050` |  |
| HP LaserJet 9050 MFP | `hp-lj_9050_mfp` |  |
| HP LaserJet M3027 MFP | `hp-lj_m3027_mfp` |  |
| HP LaserJet M3035 MFP | `hp-lj_m3035_mfp` |  |
| HP LaserJet M4345 MFP | `hp-lj_m4345_mfp` |  |
| HP LaserJet M5025 MFP | `hp-lj_m5025_mfp` |  |
| HP LaserJet M5035 MFP | `hp-lj_m5035_mfp` |  |
| HP LaserJet P2010 | `hp-lj_p2010` |  |
| HP LaserJet P2015 | `hp-lj_p2015` |  |
| HP LaserJet P3004 | `hp-lj_p3004` |  |
| HP LaserJet P3005 | `hp-lj_p3005` |  |
| HP Mopier 240 | `hp-mopier_240` |  |
| HP Mopier 320 | `hp-mopier_320` |  |
| HP OfficeJet | `hp-oj` |  |
| HP OfficeJet 300 | `hp-oj_300` |  |
| HP OfficeJet 330 | `hp-oj_330` |  |
| HP OfficeJet 350 | `hp-oj_350` |  |
| HP OfficeJet 500 | `hp-oj_500` |  |
| HP OfficeJet 5105 | `hp-oj_5105` |  |
| HP OfficeJet 5110 | `hp-oj_5110` |  |
| HP OfficeJet 5110xi | `hp-oj_5110xi` |  |
| HP OfficeJet 520 | `hp-oj_520` |  |
| HP OfficeJet 570 | `hp-oj_570` |  |
| HP OfficeJet 580 | `hp-oj_580` |  |
| HP OfficeJet 590 | `hp-oj_590` |  |
| HP OfficeJet 600 | `hp-oj_600` |  |
| HP OfficeJet 610 | `hp-oj_610` |  |
| HP OfficeJet 6105 | `hp-oj_6105` |  |
| HP OfficeJet 6110 | `hp-oj_6110` |  |
| HP OfficeJet 625 | `hp-oj_625` |  |
| HP OfficeJet 630 | `hp-oj_630` |  |
| HP OfficeJet 635 | `hp-oj_635` |  |
| HP OfficeJet 700 | `hp-oj_700` |  |
| HP OfficeJet 710 | `hp-oj_710` |  |
| HP OfficeJet 7110 | `hp-oj_7110` |  |
| HP OfficeJet 7130 | `hp-oj_7130` |  |
| HP OfficeJet 7140 | `hp-oj_7140` |  |
| HP OfficeJet 720 | `hp-oj_720` |  |
| HP OfficeJet 725 | `hp-oj_725` |  |
| HP OfficeJet D125 | `hp-oj_d125` |  |
| HP OfficeJet D135 | `hp-oj_d135` |  |
| HP OfficeJet D145 | `hp-oj_d145` |  |
| HP OfficeJet D155 | `hp-oj_d155` |  |
| HP OfficeJet G55 | `hp-oj_g55` |  |
| HP OfficeJet G85 | `hp-oj_g85` |  |
| HP OfficeJet G95 | `hp-oj_g95` |  |
| HP OfficeJet K60 | `hp-oj_k60` |  |
| HP OfficeJet K60xi | `hp-oj_k60xi` |  |
| HP OfficeJet K80 | `hp-oj_k80` |  |
| HP OfficeJet K80xi | `hp-oj_k80xi` |  |
| HP OfficeJet LX | `hp-oj_lx` |  |
| HP OfficeJet Pro 1150C | `hp-oj_pro_1150c` |  |
| HP OfficeJet Pro 1170C | `hp-oj_pro_1170c` |  |
| HP OfficeJet Pro 1175C | `hp-oj_pro_1175c` |  |
| HP OfficeJet R40 | `hp-oj_r40` |  |
| HP OfficeJet R45 | `hp-oj_r45` |  |
| HP OfficeJet R60 | `hp-oj_r60` |  |
| HP OfficeJet R65 | `hp-oj_r65` |  |
| HP OfficeJet R80 | `hp-oj_r80` |  |
| HP OfficeJet T45 | `hp-oj_t45` |  |
| HP OfficeJet T65 | `hp-oj_t65` |  |
| HP OfficeJet V40 | `hp-oj_v40` |  |
| HP OfficeJet V40xi | `hp-oj_v40xi` |  |
| HP PhotoSmart 7150 | `hp-psc_7150` |  |
| HP PhotoSmart 7345 | `hp-psc_7345` |  |
| HP PhotoSmart 7350 | `hp-psc_7350` |  |

| HP PhotoSmart 7550 | `hp-psc_7550` |  |
| HP PhotoSmart P100 | `hp-psc_p100` |  |
| HP PhotoSmart P1000 | `pcl-P1000` |  |
| HP PhotoSmart P1100 | `pcl-P1100` |  |
| HP PhotoSmart P1115 | `hp-psc_p1115` |  |
| HP PhotoSmart P1215 | `hp-psc_p1215` |  |
| HP PhotoSmart P1218 | `hp-psc_p1218` |  |
| HP PhotoSmart P130 | `hp-psc_p130` |  |
| HP PhotoSmart P1315 | `hp-psc_p1315` |  |
| HP PhotoSmart P230 | `hp-psc_p230` |  |
| HP PSC 2110 | `hp-psc_2110` |  |
| HP PSC 2150 | `hp-psc_2150` |  |
| HP PSC 2210 | `hp-psc_2210` |  |
| HP PSC 370 | `hp-psc_370` |  |
| HP PSC 380 | `hp-psc_380` |  |
| HP PSC 500 | `hp-psc_500` |  |
| HP PSC 750 | `hp-psc_750` |  |
| HP PSC 950 | `hp-psc_950` |  |
| HP PSC 950xi | `hp-psc_950xi` |  |
| IBM 4019 | `ibm-4019` |  |
| IBM 4029 030 LaserPrinter 10 | `ibm-4029_030_lp_10` |  |
| IBM 4312 | `ibm-4312` |  |
| IBM Infoprint 12 | `ibm-infoprint_12` |  |
| IBM Page Printer 3112 | `ibm-pp_3112` |  |
| Infotec 4353 MF | `infotec-4353_mf` |  |
| Infotec 4452 MF | `infotec-4452_mf` |  |
| Infotec 4651 MF | `infotec-4651_mf` |  |
| Infotec IS 2015 | `infotec-is_2015` |  |
| Infotec IS 2018 | `infotec-is_2018` |  |
| Infotec IS 2018D | `infotec-is_2018d` |  |
| Infotec IS 2060 | `infotec-is_2060` |  |
| Infotec IS 2075 | `infotec-is_2075` |  |
| Infotec IS 2122 | `infotec-is_2122` |  |
| Infotec IS 2127 | `infotec-is_2127` |  |
| Infotec IS 2132 | `infotec-is_2132` |  |
| Infotec IS 2135 | `infotec-is_2135` |  |
| Infotec IS 2145 | `infotec-is_2145` |  |
| Infotec IS 2151 | `infotec-is_2151` |  |
| Infotec IS 2160 | `infotec-is_2160` |  |
| Infotec IS 2175 | `infotec-is_2175` |  |
| Infotec IS 2215 | `infotec-is_2215` |  |
| Infotec IS 2216 | `infotec-is_2216` |  |
| Infotec IS 2220 | `infotec-is_2220` |  |
| Infotec IS 2220D | `infotec-is_2220d` |  |
| Infotec IS 2225 | `infotec-is_2225` |  |
| Infotec IS 2230 | `infotec-is_2230` |  |
| Infotec IS 2235 | `infotec-is_2235` |  |
| Infotec IS 2245 | `infotec-is_2245` |  |
| Infotec IS 2255 | `infotec-is_2255` |  |
| Infotec IS 2265 | `infotec-is_2265` |  |
| Infotec IS 2275 | `infotec-is_2275` |  |
| Infotec IS 2316 | `infotec-is_2316` |  |
| Infotec IS 2320 | `infotec-is_2320` |  |
| Infotec IS 2325 | `infotec-is_2325` |  |
| Infotec IS 2416 | `infotec-is_2416` |  |
| Infotec IS 2425 | `infotec-is_2425` |  |
| Infotec IS 2430 | `infotec-is_2430` |  |
| Infotec IS 2435 | `infotec-is_2435` |  |
| Infotec IS 2445 | `infotec-is_2445` |  |
| Infotec IS 3090 | `infotec-is_3090` |  |
| Infotec IS 3110 | `infotec-is_3110` |  |
| Infotec IS 3135 | `infotec-is_3135` |  |
| Infotec IS2022 | `infotec-is2022` |  |
| Infotec IS2027 | `infotec-is2027` |  |
| Infotec IS2032 | `infotec-is2032` |  |
| Infotec IS2035 | `infotec-is2035` |  |
| Infotec IS2045 | `infotec-is2045` |  |
| Infotec IS2090 | `infotec-is2090` |  |
| Infotec IS2105 | `infotec-is2105` |  |
| Infotec ISC 1024c | `infotec-isc_1024c` |  |
| Infotec ISC 1032c | `infotec-isc_1032c` |  |
| Infotec ISC 2428 | `infotec-isc_2428` |  |
| Infotec ISC 2525 | `infotec-isc_2525` |  |
| Infotec ISC 2835 | `infotec-isc_2835` |  |
| Infotec ISC 3030 | `infotec-isc_3030` |  |
| Infotec ISC 3535 | `infotec-isc_3535` |  |
| Infotec ISC 3545 | `infotec-isc_3545` |  |
| Infotec ISC 4045 | `infotec-isc_4045` |  |
| Infotec ISC 4560 | `infotec-isc_4560` |  |
| Infotec ISC 5560 | `infotec-isc_5560` |  |
| Infotec ISC 615G | `infotec-isc_615g` |  |
| Infotec MP 2550 | `infotec-mp_2550` |  |
| Infotec MP 2550B | `infotec-mp_2550b` |  |
| Infotec MP 3350 | `infotec-mp_3350` |  |
| Infotec MP 3350B | `infotec-mp_3350b` |  |
| Infotec MP 4000 | `infotec-mp_4000` |  |
| Infotec MP 4000B | `infotec-mp_4000b` |  |
| Infotec MP 5000 | `infotec-mp_5000` |  |
| Infotec MP 5000B | `infotec-mp_5000b` |  |
| Infotec MP C2003 | `infotec-mp_c2003` |  |
| Infotec MP C2003Z | `infotec-mp_c2003z` |  |
| Infotec MP C2004 | `infotec-mp_c2004` |  |
| Infotec MP C2011 | `infotec-mp_c2011` |  |
| Infotec MP C2050 | `infotec-mp_c2050` |  |
| Infotec MP C2051 | `infotec-mp_c2051` |  |
| Infotec MP C2503 | `infotec-mp_c2503` |  |
| Infotec MP C2503Z | `infotec-mp_c2503z` |  |
| Infotec MP C2504 | `infotec-mp_c2504` |  |
| Infotec MP C2550 | `infotec-mp_c2550` |  |
| Infotec MP C2551 | `infotec-mp_c2551` |  |
| Infotec MP C2800 | `infotec-mp_c2800` |  |
| Infotec MP C300 | `infotec-mp_c300` |  |
| Infotec MP C3001 | `infotec-mp_c3001` |  |
| Infotec MP C3002 | `infotec-mp_c3002` |  |
| Infotec MP C3003 | `infotec-mp_c3003` |  |
| Infotec MP C3004 | `infotec-mp_c3004` |  |
| Infotec MP C300SR | `infotec-mp_c300sr` |  |
| Infotec MP C3300 | `infotec-mp_c3300` |  |
| Infotec MP C3501 | `infotec-mp_c3501` |  |
| Infotec MP C3502 | `infotec-mp_c3502` |  |
| Infotec MP C3503 | `infotec-mp_c3503` |  |
| Infotec MP C3504 | `infotec-mp_c3504` |  |
| Infotec MP C400 | `infotec-mp_c400` |  |
| Infotec MP C4000 | `infotec-mp_c4000` |  |
| Infotec MP C400SR | `infotec-mp_c400sr` |  |
| Infotec MP C4501 | `infotec-mp_c4501` |  |
| Infotec MP C4501A | `infotec-mp_c4501a` |  |
| Infotec MP C4502 | `infotec-mp_c4502` |  |
| Infotec MP C4502A | `infotec-mp_c4502a` |  |
| Infotec MP C4503 | `infotec-mp_c4503` |  |
| Infotec MP C4504 | `infotec-mp_c4504` |  |
| Infotec MP C5000 | `infotec-mp_c5000` |  |
| Infotec MP C5501 | `infotec-mp_c5501` |  |
| Infotec MP C5501A | `infotec-mp_c5501a` |  |
| Infotec MP C5502 | `infotec-mp_c5502` |  |
| Infotec MP C5502A | `infotec-mp_c5502a` |  |
| Infotec MP C5503 | `infotec-mp_c5503` |  |
| Infotec MP C5504 | `infotec-mp_c5504` |  |
| Infotec MP C6000 | `infotec-mp_c6000` |  |
| Infotec MP C6003 | `infotec-mp_c6003` |  |
| Infotec MP C6004 | `infotec-mp_c6004` |  |
| Infotec MP C6501 | `infotec-mp_c6501` |  |
| Infotec MP C6502 | `infotec-mp_c6502` |  |
| Infotec MP C6503 | `infotec-mp_c6503` |  |
| Infotec MP C7500 | `infotec-mp_c7500` |  |
| Infotec MP C7501 | `infotec-mp_c7501` |  |
| Infotec MP C8002 | `infotec-mp_c8002` |  |
| Infotec MP C8003 | `infotec-mp_c8003` |  |
| Infotec Pro C5100S | `infotec-pro_c5100s` |  |
| Infotec Pro C5110S | `infotec-pro_c5110s` |  |
| Infotec Pro C5200S | `infotec-pro_c5200s` |  |
| Infotec Pro C5210S | `infotec-pro_c5210s` |  |
| Infotec Pro C7100 | `infotec-pro_c7100` |  |
| Infotec Pro C7100S | `infotec-pro_c7100s` |  |
| Infotec Pro C7110 | `infotec-pro_c7110` |  |
| Infotec Pro C7110S | `infotec-pro_c7110s` |  |
| Kyocera Ci-1100 | `kyocera-ci-1100` |  |
| Kyocera CS-1815 | `kyocera-cs-1815` |  |
| Kyocera CS-250ci | `kyocera-cs-250ci` |  |
| Kyocera CS-2525E | `kyocera-cs-2525e` |  |
| Kyocera CS-300ci | `kyocera-cs-300ci` |  |
| Kyocera CS-3050ci | `kyocera-cs-3050ci` |  |
| Kyocera CS-3225E | `kyocera-cs-3225e` |  |
| Kyocera CS-3232E | `kyocera-cs-3232e` |  |
| Kyocera CS-3550ci | `kyocera-cs-3550ci` |  |
| Kyocera CS-400ci | `kyocera-cs-400ci` |  |
| Kyocera CS-4035E | `kyocera-cs-4035e` |  |
| Kyocera CS-500ci | `kyocera-cs-500ci` |  |
| Kyocera F-1010 | `kyocera-f-1010` |  |
| Kyocera FS-1000 | `kyocera-fs-1000` |  |
| Kyocera FS-1000+ | `kyocera-fs-1000plus` |  |
| Kyocera FS-1010 | `kyocera-fs-1010` |  |
| Kyocera FS-1018MFP | `kyocera-fs-1018mfp` |  |
| Kyocera FS-1020D | `kyocera-fs-1020d` |  |
| Kyocera FS-1030D | `kyocera-fs-1030d` |  |
| Kyocera FS-1050 | `kyocera-fs-1050` |  |
| Kyocera FS-1118MFP | `kyocera-fs-1118mfp` |  |
| Kyocera FS-1135MFP | `kyocera-fs-1135mfp` |  |
| Kyocera FS-1200 | `kyocera-fs-1200` |  |
| Kyocera FS-1600 | `kyocera-fs-1600` |  |
| Kyocera FS-1600+ | `kyocera-fs-1600plus` |  |
| Kyocera FS-1700 | `kyocera-fs-1700` |  |
| Kyocera FS-1700+ | `kyocera-fs-1700plus` |  |
| Kyocera FS-1714M | `kyocera-fs-1714m` |  |
| Kyocera FS-1750 | `kyocera-fs-1750` |  |
| Kyocera FS-1800 | `kyocera-fs-1800` |  |
| Kyocera FS-1800+ | `kyocera-fs-1800plus` |  |
| Kyocera FS-1900 | `kyocera-fs-1900` |  |
| Kyocera FS-1920 | `kyocera-fs-1920` |  |
| Kyocera FS-2000D | `kyocera-fs-2000d` |  |
| Kyocera FS-3500 | `kyocera-fs-3500` |  |
| Kyocera FS-3600 | `kyocera-fs-3600` |  |
| Kyocera FS-3600+ | `kyocera-fs-3600plus` |  |
| Kyocera FS-3700 | `kyocera-fs-3700` |  |
| Kyocera FS-3700+ | `kyocera-fs-3700plus` |  |
| Kyocera FS-3718M | `kyocera-fs-3718m` |  |
| Kyocera FS-3750 | `kyocera-fs-3750` |  |
| Kyocera FS-3800 | `kyocera-fs-3800` |  |
| Kyocera FS-3820N | `kyocera-fs-3820n` |  |
| Kyocera FS-3830N | `kyocera-fs-3830n` |  |
| Kyocera FS-3900DN | `kyocera-fs-3900dn` |  |
| Kyocera FS-4000DN | `kyocera-fs-4000dn` |  |
| Kyocera FS-5800C | `kyocera-fs-5800c` | EXPERIMENTAL |
| Kyocera FS-5900C | `kyocera-fs-5900c` | EXPERIMENTAL |
| Kyocera FS-600 | `kyocera-fs-600` |  |
| Kyocera FS-600 - KPDL-2 | `kyocera-fs-600_kpdl-2` |  |
| Kyocera FS-6020 | `kyocera-fs-6020` |  |
| Kyocera FS-6026 | `kyocera-fs-6026` |  |
| Kyocera FS-6300 | `kyocera-fs-6300` |  |
| Kyocera FS-6500 | `kyocera-fs-6500` |  |
| Kyocera FS-6500+ | `kyocera-fs-6500plus` |  |
| Kyocera FS-6700 | `kyocera-fs-6700` |  |
| Kyocera FS-6750 | `kyocera-fs-6750` |  |
| Kyocera FS-680 | `kyocera-fs-680` |  |
| Kyocera FS-6900 | `kyocera-fs-6900` |  |
| Kyocera FS-6950DN | `kyocera-fs-6950dn` |  |
| Kyocera FS-7000 | `kyocera-fs-7000` |  |
| Kyocera FS-7000+ | `kyocera-fs-7000plus` |  |
| Kyocera FS-7028M | `kyocera-fs-7028m` |  |
| Kyocera FS-800 | `kyocera-fs-800` |  |
| Kyocera FS-8000C | `kyocera-fs-8000c` | EXPERIMENTAL |
| Kyocera FS-9000 | `kyocera-fs-9000` |  |
| Kyocera FS-9100DN | `kyocera-fs-9100dn` |  |
| Kyocera FS-9130DN | `kyocera-fs-9130dn` |  |
| Kyocera FS-920 | `kyocera-fs-920` |  |
| Kyocera FS-9500DN | `kyocera-fs-9500dn` |  |
| Kyocera FS-9530DN | `kyocera-fs-9530dn` |  |
| Kyocera FS-C5015N | `kyocera-fs-c5015n` | EXPERIMENTAL |
| Kyocera FS-C5016N | `kyocera-fs-c5016n` | EXPERIMENTAL |
| Kyocera FS-C5020N | `kyocera-fs-c5020n` | EXPERIMENTAL |
| Kyocera FS-C5025N | `kyocera-fs-c5025n` | EXPERIMENTAL |
| Kyocera FS-C5030N | `kyocera-fs-c5030n` | EXPERIMENTAL |
| Kyocera FS-C5100DN | `kyocera-fs-c5100dn` | EXPERIMENTAL |
| Kyocera FS-C5200DN | `kyocera-fs-c5200dn` | EXPERIMENTAL |
| Kyocera FS-C5300DN | `kyocera-fs-c5300dn` | EXPERIMENTAL |
| Kyocera FS-C5350DN | `kyocera-fs-c5350dn` | EXPERIMENTAL |
| Kyocera FS-C5400DN | `kyocera-fs-c5400dn` | EXPERIMENTAL |
| Kyocera FS-C8008N | `kyocera-fs-c8008n` | EXPERIMENTAL |
| Kyocera FS-C8100DN | `kyocera-fs-c8100dn` | EXPERIMENTAL |
| Kyocera FS-C8100DN+ | `kyocera-fs-c8100dnplus` | EXPERIMENTAL |
| Kyocera KM-1510 | `kyocera-km-1510` |  |
| Kyocera KM-1530 | `kyocera-km-1530` |  |
| Kyocera KM-1810 | `kyocera-km-1810` |  |
| Kyocera KM-1815 | `kyocera-km-1815` |  |
| Kyocera KM-1820 | `kyocera-km-1820` |  |
| Kyocera KM-2030 | `kyocera-km-2030` |  |
| Kyocera KM-2530 | `kyocera-km-2530` |  |
| Kyocera KM-3050 | `kyocera-km-3050` |  |
| Kyocera KM-3530 | `kyocera-km-3530` |  |
| Kyocera KM-4050 | `kyocera-km-4050` |  |

| Kyocera KM-4230 | `kyocera-km-4230` |  |
| Kyocera KM-4230/5230 | `kyocera-km-4230_5230` |  |
| Kyocera KM-4530 | `kyocera-km-4530` |  |
| Kyocera KM-5050 | `kyocera-km-5050` |  |
| Kyocera KM-5230 | `kyocera-km-5230` |  |
| Kyocera KM-5530 | `kyocera-km-5530` |  |
| Kyocera KM-6030 | `kyocera-km-6030` |  |
| Kyocera KM-6230 | `kyocera-km-6230` |  |
| Kyocera KM-8030 | `kyocera-km-8030` |  |
| Kyocera KM-C2520 | `kyocera-km-c2520` | EXPERIMENTAL |
| Kyocera KM-C2525E | `kyocera-km-c2525e` | EXPERIMENTAL |
| Kyocera KM-C2630 | `kyocera-km-c2630` | EXPERIMENTAL |
| Kyocera KM-C3225 | `kyocera-km-c3225` | EXPERIMENTAL |
| Kyocera KM-C3225E | `kyocera-km-c3225e` | EXPERIMENTAL |
| Kyocera KM-C3232 | `kyocera-km-c3232` | EXPERIMENTAL |
| Kyocera KM-C3232E | `kyocera-km-c3232e` | EXPERIMENTAL |
| Kyocera KM-C4035E | `kyocera-km-c4035e` | EXPERIMENTAL |
| Kyocera KM-C830 | `kyocera-km-c830` | EXPERIMENTAL |
| Kyocera KM-C850 | `kyocera-km-c850` | EXPERIMENTAL |
| Kyocera TASKalfa 250ci | `kyocera-km-taskalfa-250ci` | EXPERIMENTAL |
| Kyocera TASKalfa 300ci | `kyocera-km-taskalfa-300ci` | EXPERIMENTAL |
| Kyocera TASKalfa 400ci | `kyocera-km-taskalfa-400ci` | EXPERIMENTAL |
| Kyocera TASKalfa 500ci | `kyocera-km-taskalfa-500ci` | EXPERIMENTAL |
| Lanier 5622 | `lanier-5622` |  |
| Lanier 5627 | `lanier-5627` |  |
| Lanier 5632 | `lanier-5632` |  |
| Lanier 5635 | `lanier-5635` |  |
| Lanier 5645 | `lanier-5645` |  |
| Lanier LC155 | `lanier-lc155` |  |
| Lanier LD 130C | `lanier-ld_130c` |  |
| Lanier LD 130CSR | `lanier-ld_130csr` |  |
| Lanier LD 140C | `lanier-ld_140c` |  |
| Lanier LD 140CSR | `lanier-ld_140csr` |  |
| Lanier LD 620C | `lanier-ld_620c` |  |
| Lanier LD 625C | `lanier-ld_625c` |  |
| Lanier LD0105 | `lanier-ld0105` |  |
| Lanier LD015 | `lanier-ld015` |  |
| Lanier LD035 | `lanier-ld035` |  |
| Lanier LD045 | `lanier-ld045` |  |
| Lanier LD060 | `lanier-ld060` |  |
| Lanier LD075 | `lanier-ld075` |  |
| Lanier LD090 | `lanier-ld090` |  |
| Lanier LD115 | `lanier-ld115` |  |
| Lanier LD116 | `lanier-ld116` |  |
| Lanier LD118 | `lanier-ld118` |  |
| Lanier LD118d | `lanier-ld118d` |  |
| Lanier LD120 | `lanier-ld120` |  |
| Lanier LD120d | `lanier-ld120d` |  |
| Lanier LD122 | `lanier-ld122` |  |
| Lanier LD124c | `lanier-ld124c` |  |
| Lanier LD127 | `lanier-ld127` |  |
| Lanier LD132 | `lanier-ld132` |  |
| Lanier LD132c | `lanier-ld132c` |  |
| Lanier LD135 | `lanier-ld135` |  |
| Lanier LD145 | `lanier-ld145` |  |
| Lanier LD151 | `lanier-ld151` |  |
| Lanier LD160 | `lanier-ld160` |  |
| Lanier LD160c | `lanier-ld160c` |  |
| Lanier LD175 | `lanier-ld175` |  |
| Lanier LD225 | `lanier-ld225` |  |
| Lanier LD230 | `lanier-ld230` |  |
| Lanier LD235 | `lanier-ld235` |  |
| Lanier LD245 | `lanier-ld245` |  |
| Lanier LD328c | `lanier-ld328c` |  |
| Lanier LD335c | `lanier-ld335c` |  |
| Lanier LD345c | `lanier-ld345c` |  |
| Lanier MP 1100/LD1100 | `lanier-ld1100` |  |
| Lanier MP 1350/LD1135 | `lanier-ld1135` |  |
| Lanier MP 1600/LD316 | `lanier-ld316` |  |
| Lanier MP 161/LD016 | `lanier-ld016` |  |
| Lanier MP 2000/LD320d | `lanier-ld320d` |  |
| Lanier MP 2510/LD325 | `lanier-ld325` |  |
| Lanier MP 2550/LD425 | `lanier-ld425` |  |
| Lanier MP 2550B/LD425B | `lanier-ld425b` |  |
| Lanier MP 3010/LD330 | `lanier-ld330` |  |
| Lanier MP 3350/LD433 | `lanier-ld433` |  |
| Lanier MP 3350B/LD433B | `lanier-ld433b` |  |
| Lanier MP 3500/LD335 | `lanier-ld335` |  |
| Lanier MP 4000/LD040 | `lanier-ld040` |  |
| Lanier MP 4000B/LD040B | `lanier-ld040b` |  |
| Lanier MP 4500/LD345 | `lanier-ld345` |  |
| Lanier MP 5000/LD050 | `lanier-ld050` |  |
| Lanier MP 5000B/LD050B | `lanier-ld050b` |  |
| Lanier MP 5500/LD255 | `lanier-ld255` |  |
| Lanier MP 6500/LD265 | `lanier-ld265` |  |
| Lanier MP 7500/LD275 | `lanier-ld275` |  |
| Lanier MP 9000/LD190 | `lanier-ld190` |  |
| Lanier MP C1500/LD215c | `lanier-mp_c1500` |  |
| Lanier MP C2003 | `lanier-mp_c2003` |  |
| Lanier MP C2004 | `lanier-mp_c2004` |  |
| Lanier MP C2050/LD520C | `lanier-mp_c2050_ld520c` |  |
| Lanier MP C2500/LD425c | `lanier-mp_c2500_ld425c` |  |
| Lanier MP C2503 | `lanier-mp_c2503` |  |
| Lanier MP C2504 | `lanier-mp_c2504` |  |
| Lanier MP C2550/LD525C | `lanier-mp_c2550_ld525c` |  |
| Lanier MP C2800/LD528C | `lanier-mp_c2800_ld528c` |  |
| Lanier MP C300 | `lanier-mp_c300` |  |
| Lanier MP C3000/LD430c | `lanier-mp_c3000_ld430c` |  |
| Lanier MP C3001/LD630C | `lanier-mp_c3001_ld630c` |  |
| Lanier MP C3002 | `lanier-mp_c3002` |  |
| Lanier MP C3003 | `lanier-mp_c3003` |  |
| Lanier MP C3004 | `lanier-mp_c3004` |  |
| Lanier MP C300SR | `lanier-mp_c300sr` |  |
| Lanier MP C3300/LD533C | `lanier-mp_c3300_ld533c` |  |
| Lanier MP C3500/LD435c | `lanier-mp_c3500_ld435c` |  |
| Lanier MP C3501/LD635C | `lanier-mp_c3501_ld635c` |  |
| Lanier MP C3502 | `lanier-mp_c3502` |  |
| Lanier MP C3503 | `lanier-mp_c3503` |  |
| Lanier MP C3504 | `lanier-mp_c3504` |  |
| Lanier MP C400 | `lanier-mp_c400` |  |
| Lanier MP C4000/LD540C | `lanier-mp_c4000_ld540c` |  |
| Lanier MP C400SR | `lanier-mp_c400sr` |  |
| Lanier MP C4500/LD445c | `lanier-mp_c4500_ld445c` |  |
| Lanier MP C4501/LD645C | `lanier-mp_c4501_ld645c` |  |
| Lanier MP C4501A/LD645CA | `lanier-mp_c4501a` |  |
| Lanier MP C4502 | `lanier-mp_c4502` |  |
| Lanier MP C4502A | `lanier-mp_c4502a` |  |
| Lanier MP C4503 | `lanier-mp_c4503` |  |
| Lanier MP C4504 | `lanier-mp_c4504` |  |
| Lanier MP C5000/LD550C | `lanier-mp_c5000_ld550c` |  |
| Lanier MP C5501/LD655C | `lanier-mp_c5501_ld655c` |  |
| Lanier MP C5501A/LD655CA | `lanier-mp_c5501a` |  |
| Lanier MP C5502 | `lanier-mp_c5502` |  |
| Lanier MP C5502A | `lanier-mp_c5502a` |  |
| Lanier MP C5503 | `lanier-mp_c5503` |  |
| Lanier MP C6000/LD260c | `lanier-mp_c6000_ld260c` |  |
| Lanier MP C6003 | `lanier-mp_c6003` |  |
| Lanier MP C6004 | `lanier-mp_c6004` |  |
| Lanier MP C6501/LD365C | `lanier-mp_c6501_ld365c` |  |
| Lanier MP C6502 | `lanier-mp_c6502` |  |
| Lanier MP C6503 | `lanier-mp_c6503` |  |
| Lanier MP C7500/LD275c | `lanier-mp_c7500_ld275c` |  |
| Lanier MP C7501/LD375C | `lanier-mp_c7501_ld375c` |  |
| Lanier MP C8002 | `lanier-mp_c8002` |  |
| Lanier MP C8003 | `lanier-mp_c8003` |  |
| Lanier MP2500/LD125 | `lanier-ld125` |  |
| Lanier Pro C5100S | `lanier-pro_c5100s` |  |
| Lanier Pro C5110S | `lanier-pro_c5110s` |  |
| Lanier Pro C5200S | `lanier-pro_c5200s` |  |
| Lanier Pro C5210S | `lanier-pro_c5210s` |  |
| Lanier Pro C7100 | `lanier-pro_c7100` |  |
| Lanier Pro C7100S | `lanier-pro_c7100s` |  |
| Lanier Pro C7110 | `lanier-pro_c7110` |  |
| Lanier Pro C7110S | `lanier-pro_c7110s` |  |
| Lanier SG3110DN | `lanier-sg3110dn` |  |
| Lanier SG3110DNw | `lanier-sg3110dnw` |  |
| Lanier SG3110SFNw | `lanier-sg3110sfnw` |  |
| Lexmark 4076 | `lexmark-4076` |  |
| Lexmark Optra E | `lexmark-optra_e` |  |
| Lexmark Optra E+ | `lexmark-optra_eplus` |  |
| Lexmark Optra E220 | `lexmark-optra_e220` |  |
| Lexmark Optra E321 | `lexmark-optra_e321` |  |
| Lexmark Optra E323 | `lexmark-optra_e323` |  |
| Lexmark Valuewriter 300 | `lexmark-vw_300` |  |
| Minolta PagePro 1100 | `minolta-pp_1100` |  |
| Minolta PagePro 6 | `minolta-pp_6` |  |
| Minolta PagePro 6e | `minolta-pp_6e` |  |
| Minolta PagePro 6ex | `minolta-pp_6ex` |  |
| Minolta PagePro 8 | `minolta-pp_8` |  |
| Minolta PagePro 8L | `minolta-pp_8l` |  |
| NEC SuperScript 1260 | `nec-ssc_1260` |  |
| NEC SuperScript 1400 | `nec-ssc_1400` |  |
| NEC SuperScript 1800 | `nec-ssc_1800` |  |
| NEC SuperScript 660i | `nec-ssc_660i` |  |
| NEC SuperScript 860 | `nec-ssc_860` |  |
| NEC SuperScript 870 | `nec-ssc_870` |  |
| NRG 10515/10518/10512 | `nrg-10512` |  |
| NRG 2205/2238/2212 | `nrg-2212` |  |
| NRG 2705/2738/2712 | `nrg-2712` |  |
| NRG 3205/3238/3212 | `nrg-3212` |  |
| NRG 3525/3508/3502 | `nrg-3502` |  |
| NRG 3545/3518/3532 | `nrg-3532` |  |
| NRG 4525/4508/4502 | `nrg-4502` |  |
| NRG 4545/4518/4532 | `nrg-4532` |  |
| NRG 6002/6005/6008 | `nrg-6008` |  |
| NRG 7502/7505/7508 | `nrg-7508` |  |
| NRG 9005/9008/9002 | `nrg-9002` |  |
| NRG CS555 | `nrg-cs555` |  |
| NRG DSc424 | `nrg-dsc424` |  |
| NRG DSc428 | `nrg-dsc428` |  |
| NRG DSc432 | `nrg-dsc432` |  |
| NRG DSc435 | `nrg-dsc435` |  |
| NRG DSc445 | `nrg-dsc445` |  |
| NRG DSc460 | `nrg-dsc460` |  |
| NRG DSm415 | `nrg-dsm415` |  |
| NRG DSm615 | `nrg-dsm615` |  |
| NRG DSm616 | `nrg-dsm616` |  |
| NRG DSm618 | `nrg-dsm618` |  |
| NRG DSm618d | `nrg-dsm618d` |  |
| NRG DSm620 | `nrg-dsm620` |  |
| NRG DSm620d | `nrg-dsm620d` |  |
| NRG DSm622 | `nrg-dsm622` |  |
| NRG DSm627 | `nrg-dsm627` |  |
| NRG DSm632 | `nrg-dsm632` |  |
| NRG DSm635 | `nrg-dsm635` |  |
| NRG DSm645 | `nrg-dsm645` |  |
| NRG DSm651 | `nrg-dsm651` |  |
| NRG DSm660 | `nrg-dsm660` |  |
| NRG DSm675 | `nrg-dsm675` |  |
| NRG DSm725 | `nrg-dsm725` |  |
| NRG DSm730 | `nrg-dsm730` |  |
| NRG DSm735 | `nrg-dsm735` |  |
| NRG DSm745 | `nrg-dsm745` |  |
| NRG MP 1100 | `nrg-mp_1100` |  |
| NRG MP 1350 | `nrg-mp_1350` |  |
| NRG MP 1600 | `nrg-mp_1600` |  |
| NRG MP 161 | `nrg-mp_161` |  |
| NRG MP 2000 | `nrg-mp_2000` |  |
| NRG MP 2500 | `nrg-mp_2500` |  |
| NRG MP 2510 | `nrg-mp_2510` |  |
| NRG MP 2550 | `nrg-mp_2550` |  |
| NRG MP 2550B | `nrg-mp_2550b` |  |
| NRG MP 3010 | `nrg-mp_3010` |  |
| NRG MP 3350 | `nrg-mp_3350` |  |
| NRG MP 3350B | `nrg-mp_3350b` |  |
| NRG MP 3500 | `nrg-mp_3500` |  |
| NRG MP 4000 | `nrg-mp_4000` |  |
| NRG MP 4000B | `nrg-mp_4000b` |  |
| NRG MP 4500 | `nrg-mp_4500` |  |
| NRG MP 5000 | `nrg-mp_5000` |  |
| NRG MP 5000B | `nrg-mp_5000b` |  |
| NRG MP 5500 | `nrg-mp_5500` |  |
| NRG MP 6500 | `nrg-mp_6500` |  |
| NRG MP 7500 | `nrg-mp_7500` |  |
| NRG MP 9000 | `nrg-mp_9000` |  |
| NRG MP C1500sp | `nrg-mp_c1500sp` |  |
| NRG MP C2003 | `nrg-mp_c2003` |  |
| NRG MP C2003Z | `nrg-mp_c2003z` |  |
| NRG MP C2004 | `nrg-mp_c2004` |  |
| NRG MP C2011 | `nrg-mp_c2011` |  |
| NRG MP C2050 | `nrg-mp_c2050` |  |
| NRG MP C2051 | `nrg-mp_c2051` |  |
| NRG MP C2500 | `nrg-mp_c2500` |  |
| NRG MP C2503 | `nrg-mp_c2503` |  |
| NRG MP C2503Z | `nrg-mp_c2503z` |  |
| NRG MP C2504 | `nrg-mp_c2504` |  |
| NRG MP C2550 | `nrg-mp_c2550` |  |
| NRG MP C2551 | `nrg-mp_c2551` |  |
| NRG MP C2800 | `nrg-mp_c2800` |  |
| NRG MP C300 | `nrg-mp_c300` |  |

| NRG MP C3000 | `nrg-mp_c3000` |  |
| NRG MP C3001 | `nrg-mp_c3001` |  |
| NRG MP C3002 | `nrg-mp_c3002` |  |
| NRG MP C3003 | `nrg-mp_c3003` |  |
| NRG MP C3004 | `nrg-mp_c3004` |  |
| NRG MP C300SR | `nrg-mp_c300sr` |  |
| NRG MP C3300 | `nrg-mp_c3300` |  |
| NRG MP C3500 | `nrg-mp_c3500` |  |
| NRG MP C3501 | `nrg-mp_c3501` |  |
| NRG MP C3502 | `nrg-mp_c3502` |  |
| NRG MP C3503 | `nrg-mp_c3503` |  |
| NRG MP C3504 | `nrg-mp_c3504` |  |
| NRG MP C400 | `nrg-mp_c400` |  |
| NRG MP C4000 | `nrg-mp_c4000` |  |
| NRG MP C400SR | `nrg-mp_c400sr` |  |
| NRG MP C4500 | `nrg-mp_c4500` |  |
| NRG MP C4501 | `nrg-mp_c4501` |  |
| NRG MP C4501A | `nrg-mp_c4501a` |  |
| NRG MP C4502 | `nrg-mp_c4502` |  |
| NRG MP C4502A | `nrg-mp_c4502a` |  |
| NRG MP C4503 | `nrg-mp_c4503` |  |
| NRG MP C4504 | `nrg-mp_c4504` |  |
| NRG MP C5000 | `nrg-mp_c5000` |  |
| NRG MP C5501 | `nrg-mp_c5501` |  |
| NRG MP C5501A | `nrg-mp_c5501a` |  |
| NRG MP C5502 | `nrg-mp_c5502` |  |
| NRG MP C5502A | `nrg-mp_c5502a` |  |
| NRG MP C5503 | `nrg-mp_c5503` |  |
| NRG MP C5504 | `nrg-mp_c5504` |  |
| NRG MP C6000 | `nrg-mp_c6000` |  |
| NRG MP C6003 | `nrg-mp_c6003` |  |
| NRG MP C6004 | `nrg-mp_c6004` |  |
| NRG MP C6501 | `nrg-mp_c6501` |  |
| NRG MP C6502 | `nrg-mp_c6502` |  |
| NRG MP C6503 | `nrg-mp_c6503` |  |
| NRG MP C7500 | `nrg-mp_c7500` |  |
| NRG MP C7501 | `nrg-mp_c7501` |  |
| NRG MP C8002 | `nrg-mp_c8002` |  |
| NRG MP C8003 | `nrg-mp_c8003` |  |
| NRG Pro C5100S | `nrg-pro_c5100s` |  |
| NRG Pro C5110S | `nrg-pro_c5110s` |  |
| NRG Pro C5200S | `nrg-pro_c5200s` |  |
| NRG Pro C5210S | `nrg-pro_c5210s` |  |
| NRG Pro C7100 | `nrg-pro_c7100` |  |
| NRG Pro C7100S | `nrg-pro_c7100s` |  |
| NRG Pro C7110 | `nrg-pro_c7110` |  |
| NRG Pro C7110S | `nrg-pro_c7110s` |  |
| NRG SG3110DN | `nrg-sg3110dn` |  |
| NRG SG3110DNw | `nrg-sg3110dnw` |  |
| NRG SG3110SFNw | `nrg-sg3110sfnw` |  |
| Oki B401d | `oki-b401d` |  |
| Oki B430 | `oki-b430` |  |
| Oki B4350 | `oki-b4350` |  |
| Oki C5300 | `oki-c5300` | EXPERIMENTAL |
| Oki C5400 | `oki-c5400` | EXPERIMENTAL |
| Oki C7300 | `oki-c7300` | EXPERIMENTAL |
| Oki C8800 | `oki-c8800` |  |
| Oki C9200 | `oki-c9200` | EXPERIMENTAL |
| Oki C9400 | `oki-c9400` | EXPERIMENTAL |
| Oki Okipage 10e | `okidata-okp_10e` |  |
| Oki Okipage 10ex | `okidata-okp_10ex` |  |
| Oki Okipage 14ex | `okidata-okp_14ex` |  |
| Oki Okipage 6e | `okidata-okp_6e` |  |
| Oki Okipage 6ex | `okidata-okp_6ex` |  |
| Oki Okipage 8p | `okidata-okp_8p` |  |
| Oki OL400 | `okidata-ol400` |  |
| Oki OL400e | `okidata-ol400e` |  |
| Oki OL400ex | `okidata-ol400ex` |  |
| Oki OL410e | `okidata-ol410e` |  |
| Oki OL600e | `okidata-ol600e` |  |
| Oki OL610e/S | `okidata-ol610e_s` |  |
| Oki OL800 | `okidata-ol800` |  |
| Oki OL810ex | `okidata-ol810ex` |  |
| Oki Super 6e | `okidata-super_6e` |  |
| Olivetti JP350S | `olivetti-jp350s` |  |
| Olivetti PG 306 | `olivetti-pg_306` |  |
| Panasonic DP-180 | `panasonic-dp-180` |  |
| Panasonic DP-C265 | `panasonic-dp-c265` |  |
| Panasonic DP-C305 | `panasonic-dp-c305` |  |
| Panasonic DP-C322 | `panasonic-dp-c322` |  |
| Panasonic DP-C405 | `panasonic-dp-c405` |  |
| Panasonic KX-P4410 | `panasonic-kx-p4410` |  |
| Panasonic KX-P4450 | `panasonic-kx-p4450` |  |
| Panasonic KX-P6150 | `panasonic-kx-p6150` |  |
| Panasonic KX-P6500 | `panasonic-kx-p6500` |  |
| PCPI 1030 | `pcpi-1030` |  |
| Raven LP-410 | `raven-lp-410` |  |
| Ricoh Aficio 1022 | `ricoh-afc_1022` |  |
| Ricoh Aficio 1027 | `ricoh-afc_1027` |  |
| Ricoh Aficio 1032 | `ricoh-afc_1032` |  |
| Ricoh Aficio 1035 | `ricoh-afc_1035` |  |
| Ricoh Aficio 1045 | `ricoh-afc_1045` |  |
| Ricoh Aficio 1060 | `ricoh-afc_1060` |  |
| Ricoh Aficio 1075 | `ricoh-afc_1075` |  |
| Ricoh Aficio 1515 | `ricoh-afc_1515` |  |
| Ricoh Aficio 2015 | `ricoh-afc_2015` |  |
| Ricoh Aficio 2016 | `ricoh-afc_2016` |  |
| Ricoh Aficio 2018 | `ricoh-afc_2018` |  |
| Ricoh Aficio 2018D | `ricoh-afc_2018d` |  |
| Ricoh Aficio 2020 | `ricoh-afc_2020` |  |
| Ricoh Aficio 2020D | `ricoh-afc_2020d` |  |
| Ricoh Aficio 2022 | `ricoh-afc_2022` |  |
| Ricoh Aficio 2027 | `ricoh-afc_2027` |  |
| Ricoh Aficio 2032 | `ricoh-afc_2032` |  |
| Ricoh Aficio 2035 | `ricoh-afc_2035` |  |
| Ricoh Aficio 2035e | `ricoh-afc_2035e` |  |
| Ricoh Aficio 2045 | `ricoh-afc_2045` |  |
| Ricoh Aficio 2045e | `ricoh-afc_2045e` |  |
| Ricoh Aficio 2051 | `ricoh-afc_2051` |  |
| Ricoh Aficio 2060 | `ricoh-afc_2060` |  |
| Ricoh Aficio 2075 | `ricoh-afc_2075` |  |
| Ricoh Aficio 2090 | `ricoh-afc_2090` |  |
| Ricoh Aficio 2105 | `ricoh-afc_2105` |  |
| Ricoh Aficio 220 | `ricoh-afc_220` |  |
| Ricoh Aficio 3025 | `ricoh-afc_3025` |  |
| Ricoh Aficio 3030 | `ricoh-afc_3030` |  |
| Ricoh Aficio 3035 | `ricoh-afc_3035` |  |
| Ricoh Aficio 3045 | `ricoh-afc_3045` |  |
| Ricoh Aficio 3224C | `ricoh-afc_3224c` |  |
| Ricoh Aficio 3228C | `ricoh-afc_3228c` |  |
| Ricoh Aficio 3232C | `ricoh-afc_3232c` |  |
| Ricoh Aficio 3235C | `ricoh-afc_3235c` |  |
| Ricoh Aficio 3245C | `ricoh-afc_3245c` |  |
| Ricoh Aficio 3260C | `ricoh-afc_3260c` |  |
| Ricoh Aficio 401 | `ricoh-afc_401` |  |
| Ricoh Aficio 700 | `ricoh-afc_700` |  |
| Ricoh Aficio Color 5560 | `ricoh-afc_color_5560` |  |
| Ricoh Aficio MP 1100 | `ricoh-afc_mp_1100` |  |
| Ricoh Aficio MP 1350 | `ricoh-afc_mp_1350` |  |
| Ricoh Aficio MP 1600 | `ricoh-afc_mp_1600` |  |
| Ricoh Aficio MP 161 | `ricoh-afc_mp_161` |  |
| Ricoh Aficio MP 2000 | `ricoh-afc_mp_2000` |  |
| Ricoh Aficio MP 2500 | `ricoh-afc_mp_2500` |  |
| Ricoh Aficio MP 2510 | `ricoh-afc_mp_2510` |  |
| Ricoh Aficio MP 2550 | `ricoh-afc_mp_2550` |  |
| Ricoh Aficio MP 2550B | `ricoh-afc_mp_2550b` |  |
| Ricoh Aficio MP 3010 | `ricoh-afc_mp_3010` |  |
| Ricoh Aficio MP 3350 | `ricoh-afc_mp_3350` |  |
| Ricoh Aficio MP 3350B | `ricoh-afc_mp_3350b` |  |
| Ricoh Aficio MP 3500 | `ricoh-afc_mp_3500` |  |
| Ricoh Aficio MP 4000 | `ricoh-afc_mp_4000` |  |
| Ricoh Aficio MP 4000B | `ricoh-afc_mp_4000b` |  |
| Ricoh Aficio MP 4500 | `ricoh-afc_mp_4500` |  |
| Ricoh Aficio MP 5000 | `ricoh-afc_mp_5000` |  |
| Ricoh Aficio MP 5000B | `ricoh-afc_mp_5000b` |  |
| Ricoh Aficio MP 5500 | `ricoh-afc_mp_5500` |  |
| Ricoh Aficio MP 6500 | `ricoh-afc_mp_6500` |  |
| Ricoh Aficio MP 7500 | `ricoh-afc_mp_7500` |  |
| Ricoh Aficio MP 9000 | `ricoh-afc_mp_9000` |  |
| Ricoh Aficio MP C2050 | `ricoh-afc_mp_c2050` |  |
| Ricoh Aficio MP C2051 | `ricoh-afc_mp_c2051` |  |
| Ricoh Aficio MP C2500 | `ricoh-afc_mp_c2500` |  |
| Ricoh Aficio MP C2550 | `ricoh-afc_mp_c2550` |  |
| Ricoh Aficio MP C2551 | `ricoh-afc_mp_c2551` |  |
| Ricoh Aficio MP C2800 | `ricoh-afc_mp_c2800` |  |
| Ricoh Aficio MP C300 | `ricoh-afc_mp_c300` |  |
| Ricoh Aficio MP C3000 | `ricoh-afc_mp_c3000` |  |
| Ricoh Aficio MP C3001 | `ricoh-afc_mp_c3001` |  |
| Ricoh Aficio MP C3002 | `ricoh-afc_mp_c3002` |  |
| Ricoh Aficio MP C300SR | `ricoh-afc_mp_c300sr` |  |
| Ricoh Aficio MP C3300 | `ricoh-afc_mp_c3300` |  |
| Ricoh Aficio MP C3500 | `ricoh-afc_mp_c3500` |  |
| Ricoh Aficio MP C3501 | `ricoh-afc_mp_c3501` |  |
| Ricoh Aficio MP C3502 | `ricoh-afc_mp_c3502` |  |
| Ricoh Aficio MP C400 | `ricoh-afc_mp_c400` |  |
| Ricoh Aficio MP C4000 | `ricoh-afc_mp_c4000` |  |
| Ricoh Aficio MP C400SR | `ricoh-afc_mp_c400sr` |  |
| Ricoh Aficio MP C4500 | `ricoh-afc_mp_c4500` |  |
| Ricoh Aficio MP C4501 | `ricoh-afc_mp_c4501` |  |
| Ricoh Aficio MP C4501A | `ricoh-afc_mp_c4501a` |  |
| Ricoh Aficio MP C4502 | `ricoh-afc_mp_c4502` |  |
| Ricoh Aficio MP C4502A | `ricoh-afc_mp_c4502a` |  |
| Ricoh Aficio MP C5000 | `ricoh-afc_mp_c5000` |  |
| Ricoh Aficio MP C5501 | `ricoh-afc_mp_c5501` |  |
| Ricoh Aficio MP C5501A | `ricoh-afc_mp_c5501a` |  |
| Ricoh Aficio MP C5502 | `ricoh-afc_mp_c5502` |  |
| Ricoh Aficio MP C5502A | `ricoh-afc_mp_c5502a` |  |
| Ricoh Aficio MP C6000 | `ricoh-afc_mp_c6000` |  |
| Ricoh Aficio MP C6501 | `ricoh-afc_mp_c6501` |  |
| Ricoh Aficio MP C7500 | `ricoh-afc_mp_c7500` |  |
| Ricoh Aficio MP C7501 | `ricoh-afc_mp_c7501` |  |
| Ricoh Aficio SG 3110DN | `ricoh-afc_sg_3110dn` |  |
| Ricoh GX 3050N | `ricoh-gx_3050n` |  |
| Ricoh GX 3050SFN | `ricoh-gx_3050sfn` |  |
| Ricoh GX 5050N | `ricoh-gx_5050n` |  |
| Ricoh GX E3350N | `ricoh-gx_e3350n` |  |
| Ricoh GX E5550N | `ricoh-gx_e5550n` |  |
| Ricoh MP C1500/615C | `ricoh-mp_c1500_615c` |  |
| Ricoh MP C2003 | `ricoh-mp_c2003` |  |
| Ricoh MP C2003Z | `ricoh-mp_c2003z` |  |
| Ricoh MP C2004 | `ricoh-mp_c2004` |  |
| Ricoh MP C2011 | `ricoh-mp_c2011` |  |
| Ricoh MP C2094J | `ricoh-mp_c2094j` |  |
| Ricoh MP C2503 | `ricoh-mp_c2503` |  |
| Ricoh MP C2503Z | `ricoh-mp_c2503z` |  |
| Ricoh MP C2504 | `ricoh-mp_c2504` |  |
| Ricoh MP C2594J | `ricoh-mp_c2594j` |  |
| Ricoh MP C3003 | `ricoh-mp_c3003` |  |
| Ricoh MP C3004 | `ricoh-mp_c3004` |  |
| Ricoh MP C3503 | `ricoh-mp_c3503` |  |
| Ricoh MP C3504 | `ricoh-mp_c3504` |  |
| Ricoh MP C4503 | `ricoh-mp_c4503` |  |
| Ricoh MP C4504 | `ricoh-mp_c4504` |  |
| Ricoh MP C5503 | `ricoh-mp_c5503` |  |
| Ricoh MP C5504 | `ricoh-mp_c5504` |  |
| Ricoh MP C6003 | `ricoh-mp_c6003` |  |
| Ricoh MP C6004 | `ricoh-mp_c6004` |  |
| Ricoh MP C6502 | `ricoh-mp_c6502` |  |
| Ricoh MP C6503 | `ricoh-mp_c6503` |  |
| Ricoh MP C8002 | `ricoh-mp_c8002` |  |
| Ricoh MP C8003 | `ricoh-mp_c8003` |  |
| Ricoh Pro C5100S | `ricoh-pro_c5100s` |  |
| Ricoh Pro C5110S | `ricoh-pro_c5110s` |  |
| Ricoh Pro C5200S | `ricoh-pro_c5200s` |  |
| Ricoh Pro C5210S | `ricoh-pro_c5210s` |  |
| Ricoh Pro C7100 | `ricoh-pro_c7100` |  |
| Ricoh Pro C7100S | `ricoh-pro_c7100s` |  |
| Ricoh Pro C7110 | `ricoh-pro_c7110` |  |
| Ricoh Pro C7110S | `ricoh-pro_c7110s` |  |
| Ricoh SG3120BSFNw | `ricoh-sg3120bsfnw` |  |
| Samsung CLP-620 | `samsung-clp-620` |  |
| Samsung CLP-660N | `samsung-clp-660n` |  |
| Samsung CLP-660ND | `samsung-clp-660nd` |  |
| Samsung ML-1250 | `samsung-ml-1250` |  |
| Samsung ML-1450 | `samsung-ml-1450` |  |
| Samsung ML-1450PS | `samsung-ml-1450ps` |  |
| Samsung ML-1650 | `samsung-ml-1650` |  |
| Samsung ML-1651N | `samsung-ml-1651n` |  |
| Samsung ML-1750 | `samsung-ml-1750` |  |
| Samsung ML-2150 | `samsung-ml-2150` |  |
| Samsung ML-2150PS | `samsung-ml-2150ps` |  |
| Samsung ML-2151N | `samsung-ml-2151n` |  |
| Samsung ML-2151NPS | `samsung-ml-2151nps` |  |
| Samsung ML-2152W | `samsung-ml-2152w` |  |
| Samsung ML-2152WPS | `samsung-ml-2152wps` |  |
| Samsung ML-2250 | `samsung-ml-2250` |  |
| Samsung ML-2550 | `samsung-ml-2550` |  |
| Samsung ML-2551N | `samsung-ml-2551n` |  |
| Samsung ML-2552W | `samsung-ml-2552w` |  |
| Samsung ML-4600 | `samsung-ml-4600` |  |

| Samsung ML-5000a | `samsung-ml-5000a` |  |
| Samsung ML-6000 | `samsung-ml-6000` |  |
| Samsung ML-6100 | `samsung-ml-6100` |  |
| Samsung ML-7000 | `samsung-ml-7000` |  |
| Samsung ML-7000N | `samsung-ml-7000n` |  |
| Samsung ML-7000P | `samsung-ml-7000p` |  |
| Samsung ML-7050 | `samsung-ml-7050` |  |
| Samsung ML-7300 | `samsung-ml-7300` |  |
| Samsung ML-7300N | `samsung-ml-7300n` |  |
| Samsung ML-85 | `samsung-ml-85` |  |
| Samsung ProXpress SL-M3820ND | `samsung-sl-m3820nd` |  |
| Samsung QL-5100A | `samsung-ql-5100a` |  |
| Samsung QL-6050 | `samsung-ql-6050` |  |
| Savin 2522 | `savin-2522` |  |
| Savin 2527 | `savin-2527` |  |
| Savin 2532 | `savin-2532` |  |
| Savin 2535/2235 | `savin-2235` |  |
| Savin 2545/2245 | `savin-2245` |  |
| Savin 2560 | `savin-2560` |  |
| Savin 2575 | `savin-2575` |  |
| Savin 3515 | `savin-3515` |  |
| Savin 40105 | `savin-40105` |  |
| Savin 4015 | `savin-4015` |  |
| Savin 4018 | `savin-4018` |  |
| Savin 4018d | `savin-4018d` |  |
| Savin 4022 | `savin-4022` |  |
| Savin 4027 | `savin-4027` |  |
| Savin 4035/4135g | `savin-4135g` |  |
| Savin 4035e/4135eG | `savin-4135eg` |  |
| Savin 4045/4145g | `savin-4145g` |  |
| Savin 4045e/4145eG | `savin-4145eg` |  |
| Savin 4051 | `savin-4051` |  |
| Savin 4060 | `savin-4060` |  |
| Savin 4075 | `savin-4075` |  |
| Savin 4090 | `savin-4090` |  |
| Savin 7025 | `savin-7025` |  |
| Savin 8016 | `savin-8016` |  |
| Savin 8020 | `savin-8020` |  |
| Savin 8020d | `savin-8020d` |  |
| Savin 8025 | `savin-8025` |  |
| Savin 8025e | `savin-8025e` |  |
| Savin 8030 | `savin-8030` |  |
| Savin 8030e | `savin-8030e` |  |
| Savin 8035/8035g | `savin-8035g` |  |
| Savin 8035e | `savin-8035e` |  |
| Savin 8045/8045g | `savin-8045g` |  |
| Savin 8045e | `savin-8045e` |  |
| Savin 8055 | `savin-8055` |  |
| Savin 8065 | `savin-8065` |  |
| Savin 8075 | `savin-8075` |  |
| Savin 8090 | `savin-8090` |  |
| Savin 8110 | `savin-8110` |  |
| Savin 8135 | `savin-8135` |  |
| Savin 816 | `savin-816` |  |
| Savin 9016 | `savin-9016` |  |
| Savin 9021d | `savin-9021d` |  |
| Savin 9025 | `savin-9025` |  |
| Savin 9025b | `savin-9025b` |  |
| Savin 9033 | `savin-9033` |  |
| Savin 9033b | `savin-9033b` |  |
| Savin 9040 | `savin-9040` |  |
| Savin 9040b | `savin-9040b` |  |
| Savin 9050 | `savin-9050` |  |
| Savin 9050b | `savin-9050b` |  |
| Savin C 230 | `savin-c_230` |  |
| Savin C 230SR | `savin-c_230sr` |  |
| Savin C 240 | `savin-c_240` |  |
| Savin C 240SR | `savin-c_240sr` |  |
| Savin C2410 | `savin-c2410` |  |
| Savin C2525 | `savin-c2525` |  |
| Savin C2824 | `savin-c2824` |  |
| Savin C2828 | `savin-c2828` |  |
| Savin C3030 | `savin-c3030` |  |
| Savin C3210e | `savin-c3210e` |  |
| Savin C3333 | `savin-c3333` |  |
| Savin C3528 | `savin-c3528` |  |
| Savin C3535 | `savin-c3535` |  |
| Savin C4040 | `savin-c4040` |  |
| Savin C4535 | `savin-c4535` |  |
| Savin C4540 | `savin-c4540` |  |
| Savin C5050 | `savin-c5050` |  |
| Savin C6045 | `savin-c6045` |  |
| Savin C6055 | `savin-c6055` |  |
| Savin C7570 | `savin-c7570` |  |
| Savin C9020 | `savin-c9020` |  |
| Savin C9025 | `savin-c9025` |  |
| Savin C9065 | `savin-c9065` |  |
| Savin C9075 | `savin-c9075` |  |
| Savin C9120 | `savin-c9120` |  |
| Savin C9125 | `savin-c9125` |  |
| Savin C9130 | `savin-c9130` |  |
| Savin C9135 | `savin-c9135` |  |
| Savin C9145 | `savin-c9145` |  |
| Savin C9145A | `savin-c9145a` |  |
| Savin C9155 | `savin-c9155` |  |
| Savin C9155A | `savin-c9155a` |  |
| Savin MP C2003 | `savin-mp_c2003` |  |
| Savin MP C2004 | `savin-mp_c2004` |  |
| Savin MP C2503 | `savin-mp_c2503` |  |
| Savin MP C2504 | `savin-mp_c2504` |  |
| Savin MP C3002 | `savin-mp_c3002` |  |
| Savin MP C3003 | `savin-mp_c3003` |  |
| Savin MP C3004 | `savin-mp_c3004` |  |
| Savin MP C3502 | `savin-mp_c3502` |  |
| Savin MP C3503 | `savin-mp_c3503` |  |
| Savin MP C3504 | `savin-mp_c3504` |  |
| Savin MP C4502 | `savin-mp_c4502` |  |
| Savin MP C4502A | `savin-mp_c4502a` |  |
| Savin MP C4503 | `savin-mp_c4503` |  |
| Savin MP C4504 | `savin-mp_c4504` |  |
| Savin MP C5502 | `savin-mp_c5502` |  |
| Savin MP C5502A | `savin-mp_c5502a` |  |
| Savin MP C5503 | `savin-mp_c5503` |  |
| Savin MP C6003 | `savin-mp_c6003` |  |
| Savin MP C6004 | `savin-mp_c6004` |  |
| Savin MP C6502 | `savin-mp_c6502` |  |
| Savin MP C6503 | `savin-mp_c6503` |  |
| Savin MP C8002 | `savin-mp_c8002` |  |
| Savin MP C8003 | `savin-mp_c8003` |  |
| Savin Pro C5100S | `savin-pro_c5100s` |  |
| Savin Pro C5110S | `savin-pro_c5110s` |  |
| Savin Pro C5200S | `savin-pro_c5200s` |  |
| Savin Pro C5210S | `savin-pro_c5210s` |  |
| Savin Pro C7100 | `savin-pro_c7100` |  |
| Savin Pro C7100S | `savin-pro_c7100s` |  |
| Savin Pro C7110 | `savin-pro_c7110` |  |
| Savin Pro C7110S | `savin-pro_c7110s` |  |
| Savin SDC555 | `savin-sdc555` |  |
| Savin SG3110DN | `savin-sg3110dn` |  |
| Savin SGC 1506 | `savin-sgc_1506` |  |
| Seiko SpeedJET 200 | `seiko-sj_200` |  |
| Sharp AR-161 | `sharp-ar-161` |  |
| Sharp AR-BC260 | `sharp-ar-bc260` | EXPERIMENTAL |
| Sharp AR-BC320 | `sharp-ar-bc320` | EXPERIMENTAL |
| Sharp AR-C170FP | `sharp-ar-c170fp` |  |
| Sharp AR-C170M | `sharp-ar-c170m` | EXPERIMENTAL |
| Sharp AR-C172FP | `sharp-ar-c172fp` |  |
| Sharp AR-C172M | `sharp-ar-c172m` | EXPERIMENTAL |
| Sharp AR-C260 | `sharp-ar-c260` | EXPERIMENTAL |
| Sharp AR-C260F | `sharp-ar-c260F` | EXPERIMENTAL |
| Sharp AR-C260FP | `sharp-ar-c260fp` |  |
| Sharp AR-C260M | `sharp-ar-c260m` | EXPERIMENTAL |
| Sharp AR-C260P | `sharp-ar-c260p` | EXPERIMENTAL |
| Sharp AR-C260S | `sharp-ar-c260S` | EXPERIMENTAL |
| Sharp AR-C261F | `sharp-ar-c261f` | EXPERIMENTAL |
| Sharp AR-C261FP | `sharp-ar-c261fp` |  |
| Sharp AR-C261M | `sharp-ar-c261m` | EXPERIMENTAL |
| Sharp AR-C261S | `sharp-ar-c261s` | EXPERIMENTAL |
| Sharp AR-C262FP | `sharp-ar-c262fp` |  |
| Sharp AR-C262M | `sharp-ar-c262m` | EXPERIMENTAL |
| Sharp AR-C262S | `sharp-ar-c262s` | EXPERIMENTAL |
| Sharp AR-M257 | `sharp-ar-m257` |  |
| Sharp MX-2300FG | `sharp-mx-2300fg` |  |
| Sharp MX-2300G | `sharp-mx-2300g` |  |
| Sharp MX-2300N | `sharp-mx-2300n` |  |
| Sharp MX-2600N | `sharp-mx-2600n` |  |
| Sharp MX-2700FG | `sharp-mx-2700fg` |  |
| Sharp MX-2700G | `sharp-mx-2700g` |  |
| Sharp MX-2700N | `sharp-mx-2700n` |  |
| Sharp MX-3500FN | `sharp-mx-3500fn` |  |
| Sharp MX-3500N | `sharp-mx-3500n` |  |
| Sharp MX-3501FN | `sharp-mx-3501fn` |  |
| Sharp MX-3501N | `sharp-mx-3501n` |  |
| Sharp MX-4500FN | `sharp-mx-4500fn` |  |
| Sharp MX-4500N | `sharp-mx-4500n` |  |
| Sharp MX-4501FN | `sharp-mx-4501fn` |  |
| Sharp MX-4501N | `sharp-mx-4501n` |  |
| Sony IJP-V100 | `sony-ijp-v100` |  |
| Star LaserPrinter 8 | `star-lp_8` |  |
| Star LS-04 | `star-ls-04` |  |
| Tally MT908 | `tally-mt908` |  |
| Tektronix Phaser 750DP | `tektronix-phaser_750dp` |  |
| Tektronix Phaser 750DX | `tektronix-phaser_750dx` |  |
| Tektronix Phaser 750N | `tektronix-phaser_750n` |  |
| Tektronix Phaser 750P | `tektronix-phaser_750p` |  |
| Toshiba e-Studio 220cp | `toshiba-e-studio_220cp` |  |
| Toshiba e-Studio 2830c | `toshiba-e-studio_2830c` |  |
| Toshiba e-Studio 3530c | `toshiba-e-studio_3530c` |  |
| Toshiba e-Studio 4500c | `toshiba-e-studio_4500c` |  |
| Toshiba e-Studio 4520c | `toshiba-e-studio_4520c` |  |
| Toshiba e-Studio 5500c | `toshiba-e-studio_5500c` |  |
| Xerox Able 1406 | `xerox-able_1406` |  |
| Xerox Document Centre 400 | `xerox-dc_400` |  |
| Xerox DocuPrint 4508 | `xerox-dp_4508` |  |
| Xerox DocuPrint C20 | `xerox-dp_c20` | EXPERIMENTAL |
| Xerox DocuPrint N4512 | `xerox-dp_n4512` |  |
| Xerox DocuPrint N4512PS | `xerox-dp_n4512ps` |  |
| Xerox DocuPrint P12 | `xerox-dp_p12` |  |
| Xerox DocuPrint P1202 | `xerox-dp_p1202` |  |
| Xerox DocuPrint P8e | `xerox-dp_p8e` |  |
| Xerox Phaser 2135 | `xerox-phaser_2135` |  |
| Xerox Phaser 3160N | `xerox-phaser_3160n` | EXPERIMENTAL |
| Xerox Phaser 4400B | `xerox-phaser_4400b` |  |
| Xerox Phaser 4400DT | `xerox-phaser_4400dt` |  |
| Xerox Phaser 4400DX | `xerox-phaser_4400dx` |  |
| Xerox Phaser 4400N | `xerox-phaser_4400n` |  |
| Xerox Phaser 4500B | `xerox-phaser_4500b` |  |
| Xerox Phaser 4500DT | `xerox-phaser_4500dt` |  |
| Xerox Phaser 4500DX | `xerox-phaser_4500dx` |  |
| Xerox Phaser 4500N | `xerox-phaser_4500n` |  |
| Xerox Phaser 4510B | `xerox-phaser_4510b` |  |
| Xerox Phaser 4510DT | `xerox-phaser_4510dt` |  |
| Xerox Phaser 4510DX | `xerox-phaser_4510dx` |  |
| Xerox Phaser 4510N | `xerox-phaser_4510n` |  |
| Xerox Phaser 5500B | `xerox-phaser_5500b` |  |
| Xerox Phaser 5500DN | `xerox-phaser_5500dn` |  |
| Xerox Phaser 5500DT | `xerox-phaser_5500dt` |  |
| Xerox Phaser 5500DX | `xerox-phaser_5500dx` |  |
| Xerox Phaser 5500N | `xerox-phaser_5500n` |  |
| Xerox Phaser 6130N | `xerox-phaser_6130n` |  |
| Xerox Phaser 6180DN | `xerox-phaser_6180dn` |  |
| Xerox Phaser 6180MFP-D | `xerox-phaser_6180mfp-d` |  |
| Xerox Phaser 6200B | `xerox-phaser_6200b` |  |
| Xerox Phaser 6200DP | `xerox-phaser_6200dp` |  |
| Xerox Phaser 6200DX | `xerox-phaser_6200dx` |  |
| Xerox Phaser 6200N | `xerox-phaser_6200n` |  |
| Xerox Phaser 6250B | `xerox-phaser_6250b` |  |
| Xerox Phaser 6250DP | `xerox-phaser_6250dp` |  |
| Xerox Phaser 6250DT | `xerox-phaser_6250dt` |  |
| Xerox Phaser 6250DX | `xerox-phaser_6250dx` |  |
| Xerox Phaser 6250N | `xerox-phaser_6250n` |  |
| Xerox Phaser 6300DN | `xerox-phaser_6300dn` |  |
| Xerox Phaser 6300N | `xerox-phaser_6300n` |  |
| Xerox Phaser 6350DP | `xerox-phaser_6350dp` |  |
| Xerox Phaser 6350DT | `xerox-phaser_6350dt` |  |
| Xerox Phaser 6350DX | `xerox-phaser_6350dx` |  |
| Xerox Phaser 6360DN | `xerox-phaser_6360dn` |  |
| Xerox Phaser 6360DX | `xerox-phaser_6360dx` |  |
| Xerox Phaser 7300B | `xerox-phaser_7300b` |  |
| Xerox Phaser 7300DN | `xerox-phaser_7300dn` |  |
| Xerox Phaser 7300DT | `xerox-phaser_7300dt` |  |
| Xerox Phaser 7300DX | `xerox-phaser_7300dx` |  |
| Xerox Phaser 7300N | `xerox-phaser_7300n` |  |
| Xerox Phaser 7400DN | `xerox-phaser_7400dn` |  |
| Xerox Phaser 7400DT | `xerox-phaser_7400dt` |  |
| Xerox Phaser 7400DX | `xerox-phaser_7400dx` |  |
| Xerox Phaser 7400DXF | `xerox-phaser_7400dxf` |  |
| Xerox Phaser 7400N | `xerox-phaser_7400n` |  |
| Xerox Phaser 7700DN | `xerox-phaser_7700dn` |  |
| Xerox Phaser 7700DX | `xerox-phaser_7700dx` |  |
| Xerox Phaser 7700GX | `xerox-phaser_7700gx` |  |
| Xerox Phaser 7750B | `xerox-phaser_7750b` |  |
| Xerox Phaser 7750DN | `xerox-phaser_7750dn` |  |
| Xerox Phaser 7750DXF | `xerox-phaser_7750dxf` |  |
| Xerox Phaser 7750GX | `xerox-phaser_7750gx` |  |
| Xerox Phaser 7760DN | `xerox-phaser_7760dn` |  |
| Xerox Phaser 7760DX | `xerox-phaser_7760dx` |  |
| Xerox Phaser 7760GX | `xerox-phaser_7760gx` |  |
| Xerox Phaser 8400B | `xerox-phaser_8400b` |  |
| Xerox Phaser 8400BD | `xerox-phaser_8400bd` |  |
| Xerox Phaser 8400DP | `xerox-phaser_8400dp` |  |
| Xerox Phaser 8400DX | `xerox-phaser_8400dx` |  |
| Xerox Phaser 8400N | `xerox-phaser_8400n` |  |
| Xerox Phaser 8500DN | `xerox-phaser_8500dn` |  |
| Xerox Phaser 8500N | `xerox-phaser_8500n` |  |
| Xerox Phaser 8550DP | `xerox-phaser_8550dp` |  |
| Xerox Phaser 8550DT | `xerox-phaser_8550dt` |  |
| Xerox Phaser 8550DX | `xerox-phaser_8550dx` |  |
| Xerox Phaser 8560DN | `xerox-phaser_8560dn` |  |
| Xerox Phaser 8860 | `xerox-phaser_8860` | EXPERIMENTAL |
| Xerox WorkCentre 7345 | `xerox-workcentre_7345` | EXPERIMENTAL |
| Xerox WorkCentre C2424 | `xerox-workcentre_c2424` | EXPERIMENTAL |
| Xerox WorkCentre M118 | `xerox-wc_m118` |  |

### Epson ESC/P2 喷墨 — 595 个型号（其中 39 个标注 EXPERIMENTAL）

Epson 全线喷墨（Stylus/Artisan/WorkForce/XP 等），部分 Fujifilm 机型

| 型号 | 驱动名 | 备注 |
|---|---|---|
| Epson Artisan 1430 | `escp2-artisan1430` |  |
| Epson Artisan 50 | `escp2-artisan50` |  |
| Epson Artisan 700 | `escp2-artisan700` |  |
| Epson Artisan 710 | `escp2-artisan710` |  |
| Epson Artisan 800 | `escp2-artisan800` |  |
| Epson Artisan 810 | `escp2-artisan810` |  |
| Epson Artisan 835 | `escp2-artisan835` |  |
| Epson B-300 | `escp2-b300` |  |
| Epson B-308 | `escp2-b308` |  |
| Epson B-310 | `escp2-b310` |  |
| Epson B-310N | `escp2-b310n` |  |
| Epson B-500DN | `escp2-b500dn` |  |
| Epson B-508DN | `escp2-b508dn` |  |
| Epson B-510DN | `escp2-b510dn` |  |
| Epson CL 700 | `escp2-cl700` |  |
| Epson CL 750 | `escp2-cl750` |  |
| Epson CL 760 | `escp2-cl760` |  |
| Epson E 100 | `escp2-e100` |  |
| Epson E 150 | `escp2-e150` |  |
| Epson E 200 | `escp2-e200` |  |
| Epson E 300 | `escp2-e300` |  |
| Epson E 500 | `escp2-e500` |  |
| Epson E 520 | `escp2-e520` |  |
| Epson E 700 | `escp2-e700` |  |
| Epson E 720 | `escp2-e720` |  |
| Epson EM 900C | `escp2-em900c` |  |
| Epson EM 930C | `escp2-em930c` |  |
| Epson EP 302 | `escp2-ep302` |  |
| Epson EP 702A | `escp2-ep702a` |  |
| Epson EP 801A | `escp2-ep801a` |  |
| Epson EP 901A | `escp2-ep901a` |  |
| Epson EP 901F | `escp2-ep901f` |  |
| Epson Expression ET-2550 EcoTank | `escp2-et2550` |  |
| Epson Expression ET-2600 EcoTank | `escp2-et2600` |  |
| Epson Expression ET-2650 EcoTank | `escp2-et2650` |  |
| Epson Expression ET-2700 EcoTank | `escp2-et2700` |  |
| Epson Expression ET-2750 EcoTank | `escp2-et2750` |  |
| Epson Expression ET-2750 EcoTank Business Edition | `escp2-et2750be` |  |
| Epson Expression Home XP-240 | `escp2-xp240` |  |
| Epson Expression Home XP-245 | `escp2-xp245` |  |
| Epson Expression Home XP-340 | `escp2-xp340` |  |
| Epson Expression Home XP-344 | `escp2-xp344` |  |
| Epson Expression Home XP-440 | `escp2-xp440` |  |
| Epson Expression Home XP-442 | `escp2-xp442` |  |
| Epson Expression Home XP-820 | `escp2-xp820` |  |
| Epson Expression Photo XP-8500 | `escp2-xp8500` |  |
| Epson Expression Photo XP-860 | `escp2-xp860` |  |
| Epson Expression Photo XP-960 | `escp2-xp960` |  |
| Epson L120 | `escp2-l120` |  |
| Epson L130 | `escp2-l130` |  |
| Epson L1300 | `escp2-l1300` |  |
| Epson L1800 | `escp2-l1800` |  |
| Epson L210 | `escp2-l210` |  |
| Epson L310 | `escp2-l310` |  |
| Epson MC 10000 | `escp2-mc10000` |  |
| Epson MC 2000 | `escp2-mc2000` |  |
| Epson MC 5000 | `escp2-mc5000` |  |
| Epson MC 7000 | `escp2-mc7000` |  |
| Epson MC 9000 | `escp2-mc9000` |  |
| Epson ME 300 | `escp2-me300` |  |
| Epson ME 320 | `escp2-me320` |  |
| Epson ME Office 1100 | `escp2-meof1100` |  |
| Epson ME Office 360 | `escp2-meof360` |  |
| Epson ME Office 600F | `escp2-meof600f` |  |
| Epson ME Office 620F | `escp2-meof620f` |  |
| Epson ME Office 70 | `escp2-meof70` |  |
| Epson ME Office 700FW | `escp2-meof700fw` |  |
| Epson ME Office 80W | `escp2-meof80w` |  |
| Epson ME Office 82WD | `escp2-meof82wd` |  |
| Epson ME Office 85ND | `escp2-meof85nd` |  |
| Epson ME Office 900WD | `escp2-meof900wd` |  |
| Epson ME Office 940FW | `escp2-meof940fw` |  |
| Epson ME Office 960FWD | `escp2-meof960fwd` |  |
| Epson MJ 5100C | `escp2-mj5100c` |  |
| Epson MJ 6000C | `escp2-mj6000c` |  |
| Epson MJ 8000C | `escp2-mj8000c` |  |
| Epson MJ 930C | `escp2-mj930c` |  |
| Epson Offirio PX B300 | `escp2-pxb300` |  |
| Epson Offirio PX B500 | `escp2-pxb500` |  |
| Epson PictureMate | `escp2-picmate` |  |
| Epson PictureMate 100 | `escp2-picmate100` |  |
| Epson PictureMate 200 | `escp2-picmate200` |  |
| Epson PictureMate 2005 | `escp2-picmate2005` |  |
| Epson PictureMate 210 | `escp2-picmate210` |  |
| Epson PictureMate 215 | `escp2-picmate215` |  |
| Epson PictureMate 240 | `escp2-picmate240` |  |
| Epson PictureMate 250 | `escp2-picmate250` |  |
| Epson PictureMate 260 | `escp2-picmate260` |  |
| Epson PictureMate 270 | `escp2-picmate270` |  |
| Epson PictureMate 280 | `escp2-picmate280` |  |
| Epson PictureMate 290 | `escp2-picmate290` |  |
| Epson PictureMate 500 | `escp2-picmate500` |  |
| Epson PictureMate Dash | `escp2-picmatedash` |  |
| Epson PictureMate Deluxe | `escp2-picmated` |  |
| Epson PictureMate Flash | `escp2-picmateflash` |  |
| Epson PictureMate Pal | `escp2-picmatepal` |  |
| Epson PictureMate Snap | `escp2-picmatesnap` |  |
| Epson PM 10000 | `escp2-pm10000` |  |
| Epson PM 2000C | `escp2-pm2000c` |  |
| Epson PM 2200C | `escp2-pm2200c` |  |
| Epson PM 3000C | `escp2-pm3000c` |  |
| Epson PM 3300C | `escp2-pm3300c` |  |
| Epson PM 3500C | `escp2-pm3500c` |  |
| Epson PM 3700C | `escp2-pm3700c` |  |
| Epson PM 4000PX | `escp2-pm4000px` |  |
| Epson PM 5000C | `escp2-pm5000c` |  |
| Epson PM 670C | `escp2-pm670c` |  |
| Epson PM 7000C | `escp2-pm7000c` |  |
| Epson PM 700C | `escp2-pm700c` |  |
| Epson PM 730C | `escp2-pm730c` |  |
| Epson PM 740C | `escp2-pm740c` |  |
| Epson PM 750C | `escp2-pm750c` |  |
| Epson PM 760C | `escp2-pm760c` |  |
| Epson PM 770C | `escp2-pm770c` |  |
| Epson PM 780C | `escp2-pm780c` |  |
| Epson PM 790PT | `escp2-pm790pt` |  |
| Epson PM 800C | `escp2-pm800c` |  |
| Epson PM 850PT | `escp2-pm850pt` |  |
| Epson PM 870C | `escp2-pm870c` |  |
| Epson PM 880C | `escp2-pm880c` |  |
| Epson PM 9000C | `escp2-pm9000c` |  |
| Epson PM 930C | `escp2-pm930c` |  |
| Epson PM 940C | `escp2-pm940c` |  |
| Epson PM 950C | `escp2-pm950c` |  |
| Epson PM 970C | `escp2-pm970c` |  |
| Epson PM 980C | `escp2-pm980c` |  |
| Epson PM A650 | `escp2-pma650` |  |
| Epson PM A750 | `escp2-pma750` |  |
| Epson PM A820 | `escp2-pma820` |  |
| Epson PM A890 | `escp2-pma890` |  |
| Epson PM A900 | `escp2-pma900` |  |
| Epson PM A940 | `escp2-pma940` |  |
| Epson PM A950 | `escp2-pma950` |  |
| Epson PM D1000 | `escp2-pmd1000` |  |
| Epson PM D600 | `escp2-pmd600` |  |
| Epson PM D750 | `escp2-pmd750` |  |
| Epson PM D770 | `escp2-pmd770` |  |
| Epson PM D800 | `escp2-pmd800` |  |
| Epson PM D870 | `escp2-pmd870` |  |
| Epson PM G4500 | `escp2-pmg4500` |  |
| Epson PM G700 | `escp2-pmg700` |  |
| Epson PM G720 | `escp2-pmg720` |  |
| Epson PM G730 | `escp2-pmg730` |  |
| Epson PM G800 | `escp2-pmg800` |  |
| Epson PM G820 | `escp2-pmg820` |  |
| Epson PM G850 | `escp2-pmg850` |  |
| Epson PM T960 | `escp2-pmt960` |  |
| Epson PX 1001 | `escp2-px1001` |  |
| Epson PX 101 | `escp2-px101` |  |
| Epson PX 1200 | `escp2-px1200` | EXPERIMENTAL |
| Epson PX 1600F | `escp2-px1600f` | EXPERIMENTAL |
| Epson PX 1700F | `escp2-px1700f` | EXPERIMENTAL |
| Epson PX 201 | `escp2-px201` |  |
| Epson PX 203 | `escp2-px203` |  |
| Epson PX 204 | `escp2-px204` |  |
| Epson PX 401A | `escp2-px401a` |  |
| Epson PX 503A | `escp2-px503a` |  |
| Epson PX 504A | `escp2-px504a` |  |
| Epson PX 5500 | `escp2-px5500` |  |
| Epson PX 601F | `escp2-px601f` |  |
| Epson PX 603F | `escp2-px603f` |  |
| Epson PX 7000 | `escp2-px7000` |  |
| Epson PX 7V | `escp2-px7v` |  |
| Epson PX 9000 | `escp2-px9000` |  |
| Epson PX A650 | `escp2-pxa650` |  |
| Epson PX G5000 | `escp2-pxg5000` |  |
| Epson PX G5300 | `escp2-pxg5300` |  |
| Epson PX G5600 | `escp2-pxg5600` |  |
| Epson PX G900 | `escp2-pxg900` |  |
| Epson PX G920 | `escp2-pxg920` |  |
| Epson PX V500 | `escp2-pxv500` |  |
| Epson PX V600 | `escp2-pxv600` |  |
| Epson PX V630 | `escp2-pxv630` |  |
| Epson PX V780 | `escp2-pxv780` |  |
| Epson SC-P10000 Series | `escp2-p10000-s` | EXPERIMENTAL |
| Epson SC-P20000 Series | `escp2-p20000-s` | EXPERIMENTAL |
| Epson SC-P400 Series | `escp2-p400-s` | EXPERIMENTAL |
| Epson SC-P5000 Series | `escp2-p5000-s` | EXPERIMENTAL |
| Epson SC-P600 Series | `escp2-p600-s` | EXPERIMENTAL |
| Epson SC-P6000 Series | `escp2-p6000-s` | EXPERIMENTAL |
| Epson SC-P7000 Series | `escp2-p7000-s` | EXPERIMENTAL |
| Epson SC-P800 Series | `escp2-p800-s` | EXPERIMENTAL |
| Epson SC-P8000 Series | `escp2-p8000-s` | EXPERIMENTAL |
| Epson SC-P9000 Series | `escp2-p9000-s` | EXPERIMENTAL |
| Epson Stylus C110 | `escp2-c110` |  |
| Epson Stylus C120 | `escp2-c120` |  |
| Epson Stylus C20 | `escp2-c20` |  |
| Epson Stylus C20SX | `escp2-c20sx` |  |
| Epson Stylus C20UX | `escp2-c20ux` |  |
| Epson Stylus C40 | `escp2-c40` |  |
| Epson Stylus C40SX | `escp2-c40sx` |  |
| Epson Stylus C40UX | `escp2-c40ux` |  |
| Epson Stylus C41 | `escp2-c41` |  |
| Epson Stylus C41SX | `escp2-c41sx` |  |
| Epson Stylus C41UX | `escp2-c41ux` |  |
| Epson Stylus C42 | `escp2-c42` |  |
| Epson Stylus C42SX | `escp2-c42sx` |  |
| Epson Stylus C42UX | `escp2-c42ux` |  |
| Epson Stylus C43 | `escp2-c43` |  |
| Epson Stylus C43SX | `escp2-c43sx` |  |
| Epson Stylus C43UX | `escp2-c43ux` |  |
| Epson Stylus C44 | `escp2-c44` |  |
| Epson Stylus C44SX | `escp2-c44sx` |  |
| Epson Stylus C44UX | `escp2-c44ux` |  |
| Epson Stylus C45 | `escp2-c45` |  |
| Epson Stylus C46 | `escp2-c46` |  |
| Epson Stylus C48 | `escp2-c48` |  |
| Epson Stylus C50 | `escp2-c50` |  |
| Epson Stylus C60 | `escp2-c60` |  |
| Epson Stylus C61 | `escp2-c61` |  |
| Epson Stylus C62 | `escp2-c62` |  |
| Epson Stylus C63 | `escp2-c63` |  |
| Epson Stylus C64 | `escp2-c64` |  |
| Epson Stylus C65 | `escp2-c65` |  |
| Epson Stylus C66 | `escp2-c66` |  |
| Epson Stylus C68 | `escp2-c68` |  |
| Epson Stylus C70 | `escp2-c70` |  |
| Epson Stylus C79 | `escp2-c79` |  |
| Epson Stylus C80 | `escp2-c80` |  |
| Epson Stylus C82 | `escp2-c82` |  |
| Epson Stylus C83 | `escp2-c83` |  |
| Epson Stylus C84 | `escp2-c84` |  |
| Epson Stylus C85 | `escp2-c85` |  |
| Epson Stylus C86 | `escp2-c86` |  |
| Epson Stylus C87 | `escp2-c87` |  |
| Epson Stylus C88 | `escp2-c88` |  |
| Epson Stylus C92 | `escp2-c92` |  |
| Epson Stylus Color | `escp2` |  |
| Epson Stylus Color 1160 | `escp2-1160` |  |
| Epson Stylus Color 1500 | `escp2-1500` |  |
| Epson Stylus Color 1520 | `escp2-1520` |  |
| Epson Stylus Color 3000 | `escp2-3000` |  |
| Epson Stylus Color 400 | `escp2-400` |  |
| Epson Stylus Color 440 | `escp2-440` |  |
| Epson Stylus Color 460 | `escp2-460` |  |
| Epson Stylus Color 480 | `escp2-480` |  |
| Epson Stylus Color 500 | `escp2-500` |  |
| Epson Stylus Color 580 | `escp2-580` |  |
| Epson Stylus Color 600 | `escp2-600` |  |
| Epson Stylus Color 640 | `escp2-640` |  |
| Epson Stylus Color 660 | `escp2-660` |  |
| Epson Stylus Color 670 | `escp2-670` |  |
| Epson Stylus Color 680 | `escp2-680` |  |
| Epson Stylus Color 740 | `escp2-740` |  |
| Epson Stylus Color 760 | `escp2-760` |  |
| Epson Stylus Color 777 | `escp2-777` |  |
| Epson Stylus Color 8 3 | `escp2-83` |  |
| Epson Stylus Color 800 | `escp2-800` |  |
| Epson Stylus Color 850 | `escp2-850` |  |
| Epson Stylus Color 860 | `escp2-860` |  |
| Epson Stylus Color 880 | `escp2-880` |  |
| Epson Stylus Color 900 | `escp2-900` |  |
| Epson Stylus Color 980 | `escp2-980` |  |
| Epson Stylus Color I | `escp2-i` |  |
| Epson Stylus Color II | `escp2-ii` |  |
| Epson Stylus Color IIs | `escp2-iis` |  |
| Epson Stylus Color PRO | `escp2-pro` |  |
| Epson Stylus CX1500 | `escp2-cx1500` |  |
| Epson Stylus CX3100 | `escp2-cx3100` |  |
| Epson Stylus CX3200 | `escp2-cx3200` |  |
| Epson Stylus CX3500 | `escp2-cx3500` |  |
| Epson Stylus CX3600 | `escp2-cx3600` |  |
| Epson Stylus CX3650 | `escp2-cx3650` |  |
| Epson Stylus CX3700 | `escp2-cx3700` |  |
| Epson Stylus CX3800 | `escp2-cx3800` |  |
| Epson Stylus CX3805 | `escp2-cx3805` |  |
| Epson Stylus CX3810 | `escp2-cx3810` |  |
| Epson Stylus CX3900 | `escp2-cx3900` |  |
| Epson Stylus CX4100 | `escp2-cx4100` |  |
| Epson Stylus CX4200 | `escp2-cx4200` |  |
| Epson Stylus CX4400 | `escp2-cx4400` |  |
| Epson Stylus CX4500 | `escp2-cx4500` |  |
| Epson Stylus CX4600 | `escp2-cx4600` |  |
| Epson Stylus CX4700 | `escp2-cx4700` |  |
| Epson Stylus CX4800 | `escp2-cx4800` |  |
| Epson Stylus CX4900 | `escp2-cx4900` |  |
| Epson Stylus CX5000 | `escp2-cx5000` |  |
| Epson Stylus CX5000F | `escp2-cx5000f` |  |
| Epson Stylus CX5100 | `escp2-cx5100` |  |
| Epson Stylus CX5200 | `escp2-cx5200` |  |
| Epson Stylus CX5300 | `escp2-cx5300` |  |
| Epson Stylus CX5400 | `escp2-cx5400` |  |
| Epson Stylus CX5500 | `escp2-cx5500` |  |
| Epson Stylus CX5600 | `escp2-cx5600` |  |
| Epson Stylus CX5700 | `escp2-cx5700` |  |
| Epson Stylus CX5800 | `escp2-cx5800` |  |
| Epson Stylus CX6000 | `escp2-cx6000` |  |
| Epson Stylus CX6300 | `escp2-cx6300` |  |
| Epson Stylus CX6400 | `escp2-cx6400` |  |
| Epson Stylus CX6500 | `escp2-cx6500` |  |
| Epson Stylus CX6600 | `escp2-cx6600` |  |
| Epson Stylus CX7000F | `escp2-cx7000f` |  |
| Epson Stylus CX7300 | `escp2-cx7300` |  |
| Epson Stylus CX7400 | `escp2-cx7400` |  |
| Epson Stylus CX7700 | `escp2-cx7700` |  |
| Epson Stylus CX7800 | `escp2-cx7800` |  |
| Epson Stylus CX8300 | `escp2-cx8300` |  |
| Epson Stylus CX8400 | `escp2-cx8400` |  |
| Epson Stylus CX9300F | `escp2-cx9300f` |  |
| Epson Stylus CX9400 | `escp2-cx9400` |  |
| Epson Stylus CX9400F | `escp2-cx9400f` |  |
| Epson Stylus CX9475F | `escp2-cx9475f` |  |
| Epson Stylus D120 | `escp2-d120` |  |
| Epson Stylus D68 | `escp2-d68` |  |
| Epson Stylus D78 | `escp2-d78` |  |
| Epson Stylus D88 | `escp2-d88` |  |
| Epson Stylus D92 | `escp2-d92` |  |
| Epson Stylus DX3800 | `escp2-dx3800` |  |
| Epson Stylus DX3850 | `escp2-dx3850` |  |
| Epson Stylus DX4000 | `escp2-dx4000` |  |
| Epson Stylus DX4050 | `escp2-dx4050` |  |
| Epson Stylus DX4200 | `escp2-dx4200` |  |
| Epson Stylus DX4250 | `escp2-dx4250` |  |
| Epson Stylus DX4400 | `escp2-dx4400` |  |
| Epson Stylus DX4450 | `escp2-dx4450` |  |
| Epson Stylus DX4800 | `escp2-dx4800` |  |
| Epson Stylus DX4850 | `escp2-dx4850` |  |
| Epson Stylus DX7000F | `escp2-dx7000f` |  |
| Epson Stylus DX7400 | `escp2-dx7400` |  |
| Epson Stylus DX7450 | `escp2-dx7450` |  |
| Epson Stylus DX8400 | `escp2-dx8400` |  |
| Epson Stylus DX8450 | `escp2-dx8450` |  |
| Epson Stylus DX9400F | `escp2-dx9400f` |  |
| Epson Stylus NX100 | `escp2-nx100` |  |
| Epson Stylus NX105 | `escp2-nx105` |  |
| Epson Stylus NX115 | `escp2-nx115` |  |
| Epson Stylus NX200 | `escp2-nx200` |  |
| Epson Stylus NX215 | `escp2-nx215` |  |
| Epson Stylus NX300 | `escp2-nx300` |  |
| Epson Stylus NX400 | `escp2-nx400` |  |
| Epson Stylus NX415 | `escp2-nx415` |  |
| Epson Stylus NX420 | `escp2-nx420` |  |
| Epson Stylus NX515 | `escp2-nx515` |  |
| Epson Stylus NX530 | `escp2-nx530` |  |
| Epson Stylus NX625 | `escp2-nx625` |  |
| Epson Stylus NX630 | `escp2-nx630` |  |
| Epson Stylus NX635 | `escp2-nx635` |  |
| Epson Stylus NX645 | `escp2-nx645` |  |
| Epson Stylus Office B1100 | `escp2-of-b1100` |  |
| Epson Stylus Office B30 | `escp2-of-b30` |  |
| Epson Stylus Office B33 | `escp2-of-b33` |  |
| Epson Stylus Office B40W | `escp2-of-b40w` |  |
| Epson Stylus Office B42WD | `escp2-of-b42wd` |  |
| Epson Stylus Office BX300F | `escp2-of-bx300f` |  |
| Epson Stylus Office BX305F | `escp2-of-bx305f` |  |
| Epson Stylus Office BX525WD | `escp2-of-bx525wd` |  |
| Epson Stylus Office BX535WD | `escp2-of-bx535wd` |  |
| Epson Stylus Office BX600FW | `escp2-of-bx600fw` |  |
| Epson Stylus Office BX625FWD | `escp2-of-bx625fwd` |  |
| Epson Stylus Office BX630FW | `escp2-of-bx630fw` |  |
| Epson Stylus Office BX635FWD | `escp2-of-bx635fwd` |  |
| Epson Stylus Office SX600FW | `escp2-of-sx600fw` |  |
| Epson Stylus Office SX620FW | `escp2-of-sx620fw` |  |
| Epson Stylus Office T1100 | `escp2-of-t1100` |  |
| Epson Stylus Office T1110 | `escp2-of-t1110` |  |
| Epson Stylus Office T30 | `escp2-of-t30` |  |
| Epson Stylus Office T33 | `escp2-of-t33` |  |
| Epson Stylus Office T40W | `escp2-of-t40w` |  |
| Epson Stylus Office TX300F | `escp2-of-tx300f` |  |
| Epson Stylus Office TX600FW | `escp2-of-tx600fw` |  |
| Epson Stylus Office TX620FWD | `escp2-of-tx620fwd` |  |
| Epson Stylus Photo | `escp2-photo` |  |
| Epson Stylus Photo 1200 | `escp2-1200` |  |
| Epson Stylus Photo 1270 | `escp2-1270` |  |
| Epson Stylus Photo 1280 | `escp2-1280` |  |
| Epson Stylus Photo 1290 | `escp2-1290` |  |
| Epson Stylus Photo 1290s | `escp2-1290s` |  |
| Epson Stylus Photo 1400 | `escp2-1400` |  |
| Epson Stylus Photo 1410 | `escp2-1410` |  |
| Epson Stylus Photo 2000P | `escp2-2000` |  |
| Epson Stylus Photo 2100 | `escp2-2100` |  |
| Epson Stylus Photo 2200 | `escp2-2200` |  |
| Epson Stylus Photo 700 | `escp2-700` |  |
| Epson Stylus Photo 720 | `escp2-720` |  |
| Epson Stylus Photo 750 | `escp2-750` |  |
| Epson Stylus Photo 780 | `escp2-780` |  |
| Epson Stylus Photo 785 | `escp2-785` |  |
| Epson Stylus Photo 790 | `escp2-790` |  |
| Epson Stylus Photo 810 | `escp2-810` |  |
| Epson Stylus Photo 820 | `escp2-820` |  |
| Epson Stylus Photo 825 | `escp2-825` |  |
| Epson Stylus Photo 830 | `escp2-830` |  |
| Epson Stylus Photo 830U | `escp2-830u` |  |
| Epson Stylus Photo 870 | `escp2-870` |  |
| Epson Stylus Photo 875 | `escp2-875` |  |
| Epson Stylus Photo 890 | `escp2-890` |  |
| Epson Stylus Photo 895 | `escp2-895` |  |
| Epson Stylus Photo 900 | `escp2-ph900` |  |
| Epson Stylus Photo 915 | `escp2-915` |  |
| Epson Stylus Photo 925 | `escp2-925` |  |
| Epson Stylus Photo 935 | `escp2-935` |  |
| Epson Stylus Photo 950 | `escp2-950` |  |
| Epson Stylus Photo 960 | `escp2-960` |  |
| Epson Stylus Photo EX | `escp2-ex` |  |
| Epson Stylus Photo EX3 | `escp2-ex3` |  |
| Epson Stylus Photo P50 | `escp2-p50` |  |
| Epson Stylus Photo PX650 | `escp2-px650` |  |
| Epson Stylus Photo PX700W | `escp2-px700fw` |  |
| Epson Stylus Photo PX710W | `escp2-px710fw` |  |
| Epson Stylus Photo PX800FW | `escp2-px800fw` |  |
| Epson Stylus Photo PX810FW | `escp2-px810fw` |  |
| Epson Stylus Photo R1800 | `escp2-r1800` |  |
| Epson Stylus Photo R1900 | `escp2-r1900` |  |
| Epson Stylus Photo R200 | `escp2-r200` |  |
| Epson Stylus Photo R2000 | `escp2-r2000` |  |
| Epson Stylus Photo R210 | `escp2-r210` |  |
| Epson Stylus Photo R220 | `escp2-r220` |  |
| Epson Stylus Photo R230 | `escp2-r230` |  |
| Epson Stylus Photo R240 | `escp2-r240` |  |
| Epson Stylus Photo R2400 | `escp2-r2400` |  |
| Epson Stylus Photo R245 | `escp2-r245` |  |
| Epson Stylus Photo R260 | `escp2-r260` |  |
| Epson Stylus Photo R265 | `escp2-r265` |  |
| Epson Stylus Photo R270 | `escp2-r270` |  |
| Epson Stylus Photo R280 | `escp2-r280` |  |
| Epson Stylus Photo R285 | `escp2-r285` |  |
| Epson Stylus Photo R2880 | `escp2-r2880` |  |
| Epson Stylus Photo R290 | `escp2-r290` |  |
| Epson Stylus Photo R300 | `escp2-r300` |  |
| Epson Stylus Photo R3000 | `escp2-r3000` |  |
| Epson Stylus Photo R310 | `escp2-r310` |  |
| Epson Stylus Photo R320 | `escp2-r320` |  |
| Epson Stylus Photo R340 | `escp2-r340` |  |
| Epson Stylus Photo R350 | `escp2-r350` |  |
| Epson Stylus Photo R360 | `escp2-r360` |  |
| Epson Stylus Photo R380 | `escp2-r380` |  |
| Epson Stylus Photo R390 | `escp2-r390` |  |
| Epson Stylus Photo R800 | `escp2-r800` |  |
| Epson Stylus Photo RX400 | `escp2-rx400` |  |
| Epson Stylus Photo RX420 | `escp2-rx420` |  |
| Epson Stylus Photo RX425 | `escp2-rx425` |  |
| Epson Stylus Photo RX430 | `escp2-rx430` |  |
| Epson Stylus Photo RX500 | `escp2-rx500` |  |
| Epson Stylus Photo RX510 | `escp2-rx510` |  |
| Epson Stylus Photo RX560 | `escp2-rx560` |  |
| Epson Stylus Photo RX580 | `escp2-rx580` |  |
| Epson Stylus Photo RX585 | `escp2-rx585` |  |
| Epson Stylus Photo RX590 | `escp2-rx590` |  |
| Epson Stylus Photo RX595 | `escp2-rx595` |  |
| Epson Stylus Photo RX600 | `escp2-rx600` |  |
| Epson Stylus Photo RX610 | `escp2-rx610` |  |
| Epson Stylus Photo RX620 | `escp2-rx620` |  |
| Epson Stylus Photo RX630 | `escp2-rx630` |  |
| Epson Stylus Photo RX640 | `escp2-rx640` |  |
| Epson Stylus Photo RX650 | `escp2-rx650` |  |
| Epson Stylus Photo RX680 | `escp2-rx680` |  |
| Epson Stylus Photo RX685 | `escp2-rx685` |  |
| Epson Stylus Photo RX690 | `escp2-rx690` |  |
| Epson Stylus Photo RX700 | `escp2-rx700` |  |
| Epson Stylus Photo TX700W | `escp2-tx700w` |  |
| Epson Stylus Photo TX710W | `escp2-tx710w` |  |
| Epson Stylus Photo TX800FW | `escp2-tx800w` |  |
| Epson Stylus Photo TX810FW | `escp2-tx810fw` |  |
| Epson Stylus Pro 10000 | `escp2-10000` |  |
| Epson Stylus Pro 11800 | `escp2-11800` |  |
| Epson Stylus Pro 11800/11880 Back Compatible | `escp2-11600` |  |
| Epson Stylus Pro 11880 | `escp2-11880` |  |
| Epson Stylus Pro 3800 | `escp2-3800` |  |
| Epson Stylus Pro 3880 | `escp2-3880` |  |
| Epson Stylus Pro 3885 | `escp2-3885` |  |
| Epson Stylus Pro 4000 | `escp2-4000` |  |
| Epson Stylus Pro 4800 | `escp2-4800` |  |
| Epson Stylus Pro 4800/4880 Back Compatible | `escp2-4600` |  |
| Epson Stylus Pro 4880 | `escp2-4880` |  |
| Epson Stylus Pro 4900 | `escp2-4900` |  |
| Epson Stylus Pro 5000 | `escp2-5000` |  |
| Epson Stylus Pro 5500 | `escp2-5500` |  |
| Epson Stylus Pro 7000 | `escp2-7000` |  |
| Epson Stylus Pro 7500 | `escp2-7500` |  |
| Epson Stylus Pro 7600 | `escp2-7600` |  |
| Epson Stylus Pro 7700 | `escp2-7700` |  |
| Epson Stylus Pro 7800 | `escp2-7800` |  |
| Epson Stylus Pro 7880 | `escp2-7880` |  |
| Epson Stylus Pro 7890 | `escp2-7890` |  |
| Epson Stylus Pro 7900 | `escp2-7900` |  |
| Epson Stylus Pro 9000 | `escp2-9000` |  |
| Epson Stylus Pro 9500 | `escp2-9500` |  |
| Epson Stylus Pro 9600 | `escp2-9600` |  |
| Epson Stylus Pro 9700 | `escp2-9700` |  |
| Epson Stylus Pro 9800 | `escp2-9800` |  |
| Epson Stylus Pro 9880 | `escp2-9880` |  |
| Epson Stylus Pro 9890 | `escp2-9890` |  |
| Epson Stylus Pro 9900 | `escp2-9900` |  |
| Epson Stylus Pro XL | `escp2-pro-xl` |  |
| Epson Stylus S20 | `escp2-s20` |  |
| Epson Stylus S21 | `escp2-s21` |  |
| Epson Stylus S50 | `escp2-s50` |  |
| Epson Stylus Scan 2000 | `escp2-scan2000` |  |
| Epson Stylus Scan 2500 | `escp2-scan2500` |  |
| Epson Stylus SX100 | `escp2-sx100` |  |
| Epson Stylus SX105 | `escp2-sx105` |  |
| Epson Stylus SX110 | `escp2-sx110` |  |
| Epson Stylus SX115 | `escp2-sx115` |  |
| Epson Stylus SX200 | `escp2-sx200` |  |
| Epson Stylus SX205 | `escp2-sx205` |  |
| Epson Stylus SX210 | `escp2-sx210` |  |
| Epson Stylus SX215 | `escp2-sx215` |  |
| Epson Stylus SX400 | `escp2-sx400` |  |
| Epson Stylus SX405 | `escp2-sx405` |  |
| Epson Stylus SX410 | `escp2-sx410` |  |
| Epson Stylus SX415 | `escp2-sx415` |  |
| Epson Stylus SX420 | `escp2-sx420` |  |
| Epson Stylus SX445W | `escp2-sx445w` |  |
| Epson Stylus SX510W | `escp2-sx510w` |  |
| Epson Stylus SX515 | `escp2-sx515` |  |
| Epson Stylus SX525 | `escp2-sx525` |  |
| Epson Stylus SX535FW | `escp2-sx535FW` |  |
| Epson Stylus SX600FW | `escp2-sx600fw` |  |
| Epson Stylus SX610FW | `escp2-sx610fw` |  |
| Epson Stylus SX615 | `escp2-sx615` |  |
| Epson Stylus SX630 | `escp2-sx630` |  |
| Epson Stylus SX635 | `escp2-sx635` |  |
| Epson Stylus SX645 | `escp2-sx645` |  |
| Epson Stylus SX650 | `escp2-sx650` |  |
| Epson Stylus T13 | `escp2-t13` |  |
| Epson Stylus T20 | `escp2-t20` |  |
| Epson Stylus T21 | `escp2-t21` |  |
| Epson Stylus T22 | `escp2-t22` |  |
| Epson Stylus T22E | `escp2-t22e` |  |
| Epson Stylus T26 | `escp2-t26` |  |
| Epson Stylus T30 | `escp2-t30` |  |
| Epson Stylus T40W | `escp2-t40w` |  |
| Epson Stylus T42WD | `escp2-t42wd` |  |
| Epson Stylus T50 | `escp2-t50` |  |
| Epson Stylus T59 | `escp2-t59` |  |
| Epson Stylus T60 | `escp2-t60` |  |
| Epson Stylus TX100 | `escp2-tx100` |  |
| Epson Stylus TX101 | `escp2-tx101` |  |
| Epson Stylus TX102 | `escp2-tx102` |  |
| Epson Stylus TX103 | `escp2-tx103` |  |
| Epson Stylus TX104 | `escp2-tx104` |  |
| Epson Stylus TX105 | `escp2-tx105` |  |
| Epson Stylus TX106 | `escp2-tx106` |  |
| Epson Stylus TX109 | `escp2-tx109` |  |
| Epson Stylus TX110 | `escp2-tx110` |  |
| Epson Stylus TX125 | `escp2-tx125` |  |
| Epson Stylus TX200 | `escp2-tx200` |  |
| Epson Stylus TX210 | `escp2-tx210` |  |
| Epson Stylus TX300F | `escp2-tx300f` |  |
| Epson Stylus TX400 | `escp2-tx400` |  |
| Epson Stylus TX410 | `escp2-tx410` |  |
| Epson Stylus TX420 | `escp2-tx420` |  |
| Epson Stylus TX510FN | `escp2-tx510fn` |  |
| Epson Stylus TX550W | `escp2-tx550w` |  |
| Epson Stylus TX560WD | `escp2-tx560wd` |  |
| Epson Stylus TX610FW | `escp2-tx610fw` |  |
| Epson Stylus TX615 | `escp2-tx615` |  |
| Epson Stylus TX630 | `escp2-tx630` |  |
| Epson Stylus TX635 | `escp2-tx635` |  |
| Epson Stylus TX645 | `escp2-tx645` |  |
| Epson Stylus TX650 | `escp2-tx650` |  |
| Epson Stylus TX659 | `escp2-tx659` |  |
| Epson Stylus XP100 | `escp2-xp100` | EXPERIMENTAL |
| Epson SureColor P10000 | `escp2-p10000` | EXPERIMENTAL |
| Epson SureColor P20000 | `escp2-p20000` | EXPERIMENTAL |
| Epson SureColor P400 | `escp2-p400` | EXPERIMENTAL |
| Epson SureColor P5000 Commercial Edition | `escp2-p5000ce` | EXPERIMENTAL |
| Epson SureColor P5000 Standard Edition | `escp2-p5000se` | EXPERIMENTAL |
| Epson SureColor P600 | `escp2-p600` | EXPERIMENTAL |
| Epson SureColor P6000 | `escp2-p6000` | EXPERIMENTAL |
| Epson SureColor P7000 | `escp2-p7000` | EXPERIMENTAL |
| Epson SureColor P7000 Commercial Edition | `escp2-p7000c` | EXPERIMENTAL |
| Epson SureColor P800 | `escp2-p800` | EXPERIMENTAL |
| Epson SureColor P8000 | `escp2-p8000` | EXPERIMENTAL |
| Epson SureColor P9000 | `escp2-p9000` | EXPERIMENTAL |
| Epson SureColor P9000 Commercial Edition | `escp2-p9000c` | EXPERIMENTAL |
| Epson SureLab D700 | `escp2-sl-d700` | EXPERIMENTAL |
| Epson WF-7010 Series | `escp2-wf7010` | EXPERIMENTAL |
| Epson WF-7011 Series | `escp2-wf7011` | EXPERIMENTAL |
| Epson WF-7015 Series | `escp2-wf7015` | EXPERIMENTAL |
| Epson WF-7018 Series | `escp2-wf7018` | EXPERIMENTAL |
| Epson WF-7510 Series | `escp2-wf7510` | EXPERIMENTAL |
| Epson WF-7511 Series | `escp2-wf7511` | EXPERIMENTAL |
| Epson WF-7515 Series | `escp2-wf7515` | EXPERIMENTAL |
| Epson WF-7520 Series | `escp2-wf7520` | EXPERIMENTAL |
| Epson WF-7521 Series | `escp2-wf7521` | EXPERIMENTAL |
| Epson WF-7525 Series | `escp2-wf7525` | EXPERIMENTAL |
| Epson WorkForce 1100 | `escp2-wf1100` |  |
| Epson WorkForce 30 | `escp2-wf30` |  |
| Epson WorkForce 310 | `escp2-wf310` |  |
| Epson WorkForce 315 | `escp2-wf315` |  |
| Epson WorkForce 40 | `escp2-wf40` |  |
| Epson WorkForce 500 | `escp2-wf500` |  |
| Epson WorkForce 545 | `escp2-wf545` |  |
| Epson WorkForce 60 | `escp2-wf60` |  |
| Epson WorkForce 600 | `escp2-wf600` |  |
| Epson WorkForce 610 | `escp2-wf610` |  |
| Epson WorkForce 615 | `escp2-wf615` |  |
| Epson WorkForce 625 | `escp2-wf625` |  |
| Epson WorkForce 630 | `escp2-wf630` |  |
| Epson WorkForce 633 | `escp2-wf633` |  |
| Epson WorkForce 635 | `escp2-wf636` |  |
| Epson WorkForce 645 | `escp2-wf645` |  |
| Epson XP-15000 Series | `escp2-xp15000` |  |
| Fujifilm DX100 | `escp2-fujifilm-dx100` | EXPERIMENTAL |

### Canon 喷墨 — 1189 个型号（其中 1097 个标注 EXPERIMENTAL）

Canon BJ/BJC/S/i/MP/MX/PIXMA 等；绝大多数在 Gutenprint 中标注为实验性

| 型号 | 驱动名 | 备注 |
|---|---|---|
| Canon BJ-30 | `bjc-30` |  |
| Canon BJC-1000 | `bjc-1000` |  |
| Canon BJC-2000 | `bjc-2000` |  |
| Canon BJC-2010 | `bjc-2010` |  |
| Canon BJC-210 | `bjc-210` |  |
| Canon BJC-2100 | `bjc-2100` |  |
| Canon BJC-2110 | `bjc-2110` |  |
| Canon BJC-240 | `bjc-240` |  |
| Canon BJC-250 | `bjc-250` |  |
| Canon BJC-3000 | `bjc-3000` |  |
| Canon BJC-4000 | `bjc-4000` |  |
| Canon BJC-4300 | `bjc-4300` |  |
| Canon BJC-4400 | `bjc-4400` |  |
| Canon BJC-4550 | `bjc-4550` |  |
| Canon BJC-50 | `bjc-50` |  |
| Canon BJC-5100 | `bjc-5100` |  |
| Canon BJC-55 | `bjc-55` |  |
| Canon BJC-5500 | `bjc-5500` |  |
| Canon BJC-5500J | `bjc-5500j` |  |
| Canon BJC-6000 | `bjc-6000` |  |
| Canon BJC-6100 | `bjc-6100` |  |
| Canon BJC-6200 | `bjc-6200` |  |
| Canon BJC-6500 | `bjc-6500` |  |
| Canon BJC-7000 | `bjc-7000` |  |
| Canon BJC-7100 | `bjc-7100` |  |
| Canon BJC-80 | `bjc-80` |  |
| Canon BJC-8200 | `bjc-8200` |  |
| Canon BJC-85 | `bjc-85` |  |
| Canon BJC-8500 | `bjc-8500` |  |
| Canon E3100 series | `bjc-E3100-series` | EXPERIMENTAL |
| Canon E400 series | `bjc-E400-series` | EXPERIMENTAL |
| Canon E410 series | `bjc-E410-series` | EXPERIMENTAL |
| Canon E460 series | `bjc-E460-series` | EXPERIMENTAL |
| Canon E470 series | `bjc-E470-series` | EXPERIMENTAL |
| Canon E480 series | `bjc-E480-series` | EXPERIMENTAL |
| Canon E500 series | `bjc-E500-series` | EXPERIMENTAL |
| Canon E510 series | `bjc-E510-series` | EXPERIMENTAL |
| Canon E560 series | `bjc-E560-series` | EXPERIMENTAL |
| Canon E600 series | `bjc-E600-series` | EXPERIMENTAL |
| Canon E610 series | `bjc-E610-series` | EXPERIMENTAL |
| Canon G1000 series | `bjc-G1000-series` | EXPERIMENTAL |
| Canon G2000 series | `bjc-G2000-series` | EXPERIMENTAL |
| Canon G3000 series | `bjc-G3000-series` | EXPERIMENTAL |
| Canon G4000 series | `bjc-G4000-series` | EXPERIMENTAL |
| Canon i450 | `bjc-i450` | EXPERIMENTAL |
| Canon i450X | `bjc-i450X` | EXPERIMENTAL |
| Canon i455 | `bjc-i455` | EXPERIMENTAL |
| Canon i455X | `bjc-i455X` | EXPERIMENTAL |
| Canon i470D | `bjc-i470D` | EXPERIMENTAL |
| Canon i475D | `bjc-i475D` | EXPERIMENTAL |
| Canon i550 | `bjc-i550` | EXPERIMENTAL |
| Canon i550X | `bjc-i550X` | EXPERIMENTAL |
| Canon i560 | `bjc-i560` | EXPERIMENTAL |
| Canon i560X | `bjc-i560X` | EXPERIMENTAL |
| Canon i6100 | `bjc-i6100` |  |
| Canon i6500 | `bjc-i6500` |  |
| Canon i70 | `bjc-i70` |  |
| Canon i80 | `bjc-i80` |  |
| Canon i850 | `bjc-i850` | EXPERIMENTAL |
| Canon i850old | `bjc-i850old` |  |
| Canon i860 | `bjc-i860` | EXPERIMENTAL |
| Canon i860old | `bjc-i860old` |  |
| Canon i865 | `bjc-i865` | EXPERIMENTAL |
| Canon i865old | `bjc-i865old` |  |
| Canon i900D | `bjc-i900D` | EXPERIMENTAL |
| Canon i905D | `bjc-i905D` | EXPERIMENTAL |
| Canon i9100 | `bjc-i9100` |  |
| Canon i950 | `bjc-i950` | EXPERIMENTAL |
| Canon i960 | `bjc-i960` | EXPERIMENTAL |
| Canon i965 | `bjc-i965` | EXPERIMENTAL |
| Canon i990 | `bjc-i990` | EXPERIMENTAL |
| Canon i9900 | `bjc-i9900` | EXPERIMENTAL |
| Canon i9950 | `bjc-i9950` | EXPERIMENTAL |
| Canon iB4000 series | `bjc-iB4000-series` | EXPERIMENTAL |
| Canon iB4100 series | `bjc-iB4100-series` | EXPERIMENTAL |
| Canon iP110 series | `bjc-iP110-series` | EXPERIMENTAL |
| Canon iP2000 series | `bjc-iP2000-series` | EXPERIMENTAL |
| Canon iP2700 series | `bjc-iP2700-series` | EXPERIMENTAL |
| Canon iP2800 series | `bjc-iP2800-series` | EXPERIMENTAL |
| Canon iP3300 series | `bjc-iP3300-series` | EXPERIMENTAL |
| Canon iP3500 series | `bjc-iP3500-series` | EXPERIMENTAL |
| Canon iP3600 series | `bjc-iP3600-series` | EXPERIMENTAL |
| Canon iP4200 series | `bjc-iP4200-series` | EXPERIMENTAL |
| Canon iP4300 series | `bjc-iP4300-series` | EXPERIMENTAL |
| Canon iP4500 series | `bjc-iP4500-series` | EXPERIMENTAL |
| Canon iP4600 series | `bjc-iP4600-series` | EXPERIMENTAL |
| Canon iP4700 series | `bjc-iP4700-series` | EXPERIMENTAL |
| Canon iP4800 series | `bjc-iP4800-series` | EXPERIMENTAL |
| Canon iP4900 series | `bjc-iP4900-series` | EXPERIMENTAL |
| Canon iP5200R series | `bjc-iP5200R-series` | EXPERIMENTAL |
| Canon iP6600D series | `bjc-iP6600D-series` | EXPERIMENTAL |
| Canon iP6700D series | `bjc-iP6700-series` | EXPERIMENTAL |
| Canon iP7200 series | `bjc-iP7200-series` | EXPERIMENTAL |
| Canon iP8700 series | `bjc-iP8700-series` | EXPERIMENTAL |
| Canon iP90 series | `bjc-iP90-series` |  |
| Canon iX5000 series | `bjc-iX5000-series` | EXPERIMENTAL |
| Canon iX6500 series | `bjc-iX6500-series` | EXPERIMENTAL |
| Canon iX6700 series | `bjc-iX6700-series` | EXPERIMENTAL |
| Canon iX6800 series | `bjc-iX6800-series` | EXPERIMENTAL |
| Canon iX7000 series | `bjc-iX7000-series` | EXPERIMENTAL |
| Canon MAXIFY iB4010 | `bjc-MAXIFY-iB4010` | EXPERIMENTAL |
| Canon MAXIFY iB4020 | `bjc-MAXIFY-iB4020` | EXPERIMENTAL |
| Canon MAXIFY iB4030 | `bjc-MAXIFY-iB4030` | EXPERIMENTAL |
| Canon MAXIFY iB4040 | `bjc-MAXIFY-iB4040` | EXPERIMENTAL |
| Canon MAXIFY iB4050 | `bjc-MAXIFY-iB4050` | EXPERIMENTAL |
| Canon MAXIFY iB4060 | `bjc-MAXIFY-iB4060` | EXPERIMENTAL |
| Canon MAXIFY iB4070 | `bjc-MAXIFY-iB4070` | EXPERIMENTAL |
| Canon MAXIFY iB4080 | `bjc-MAXIFY-iB4080` | EXPERIMENTAL |
| Canon MAXIFY iB4090 | `bjc-MAXIFY-iB4090` | EXPERIMENTAL |
| Canon MAXIFY iB4110 | `bjc-MAXIFY-iB4110` | EXPERIMENTAL |
| Canon MAXIFY iB4120 | `bjc-MAXIFY-iB4120` | EXPERIMENTAL |
| Canon MAXIFY iB4130 | `bjc-MAXIFY-iB4130` | EXPERIMENTAL |
| Canon MAXIFY iB4140 | `bjc-MAXIFY-iB4140` | EXPERIMENTAL |
| Canon MAXIFY iB4150 | `bjc-MAXIFY-iB4150` | EXPERIMENTAL |
| Canon MAXIFY iB4170 | `bjc-MAXIFY-iB4170` | EXPERIMENTAL |
| Canon MAXIFY iB4180 | `bjc-MAXIFY-iB4180` | EXPERIMENTAL |
| Canon MAXIFY iB4190 | `bjc-MAXIFY-iB4190` | EXPERIMENTAL |
| Canon MAXIFY MB2010 | `bjc-MAXIFY-MB2010` | EXPERIMENTAL |
| Canon MAXIFY MB2020 | `bjc-MAXIFY-MB2020` | EXPERIMENTAL |
| Canon MAXIFY MB2030 | `bjc-MAXIFY-MB2030` | EXPERIMENTAL |
| Canon MAXIFY MB2040 | `bjc-MAXIFY-MB2040` | EXPERIMENTAL |
| Canon MAXIFY MB2050 | `bjc-MAXIFY-MB2050` | EXPERIMENTAL |
| Canon MAXIFY MB2060 | `bjc-MAXIFY-MB2060` | EXPERIMENTAL |
| Canon MAXIFY MB2110 | `bjc-MAXIFY-MB2110` | EXPERIMENTAL |
| Canon MAXIFY MB2120 | `bjc-MAXIFY-MB2120` | EXPERIMENTAL |
| Canon MAXIFY MB2130 | `bjc-MAXIFY-MB2130` | EXPERIMENTAL |
| Canon MAXIFY MB2140 | `bjc-MAXIFY-MB2140` | EXPERIMENTAL |
| Canon MAXIFY MB2150 | `bjc-MAXIFY-MB2150` | EXPERIMENTAL |
| Canon MAXIFY MB2160 | `bjc-MAXIFY-MB2160` | EXPERIMENTAL |
| Canon MAXIFY MB2320 | `bjc-MAXIFY-MB2320` | EXPERIMENTAL |
| Canon MAXIFY MB2330 | `bjc-MAXIFY-MB2330` | EXPERIMENTAL |
| Canon MAXIFY MB2340 | `bjc-MAXIFY-MB2340` | EXPERIMENTAL |
| Canon MAXIFY MB2350 | `bjc-MAXIFY-MB2350` | EXPERIMENTAL |
| Canon MAXIFY MB2360 | `bjc-MAXIFY-MB2360` | EXPERIMENTAL |
| Canon MAXIFY MB2390 | `bjc-MAXIFY-MB2390` | EXPERIMENTAL |
| Canon MAXIFY MB2710 | `bjc-MAXIFY-MB2710` | EXPERIMENTAL |
| Canon MAXIFY MB2720 | `bjc-MAXIFY-MB2720` | EXPERIMENTAL |
| Canon MAXIFY MB2730 | `bjc-MAXIFY-MB2730` | EXPERIMENTAL |
| Canon MAXIFY MB2740 | `bjc-MAXIFY-MB2740` | EXPERIMENTAL |
| Canon MAXIFY MB2750 | `bjc-MAXIFY-MB2750` | EXPERIMENTAL |
| Canon MAXIFY MB2760 | `bjc-MAXIFY-MB2760` | EXPERIMENTAL |
| Canon MAXIFY MB2790 | `bjc-MAXIFY-MB2790` | EXPERIMENTAL |
| Canon MAXIFY MB5020 | `bjc-MAXIFY-MB5020` | EXPERIMENTAL |
| Canon MAXIFY MB5030 | `bjc-MAXIFY-MB5030` | EXPERIMENTAL |
| Canon MAXIFY MB5040 | `bjc-MAXIFY-MB5040` | EXPERIMENTAL |
| Canon MAXIFY MB5050 | `bjc-MAXIFY-MB5050` | EXPERIMENTAL |
| Canon MAXIFY MB5060 | `bjc-MAXIFY-MB5060` | EXPERIMENTAL |
| Canon MAXIFY MB5070 | `bjc-MAXIFY-MB5070` | EXPERIMENTAL |
| Canon MAXIFY MB5080 | `bjc-MAXIFY-MB5080` | EXPERIMENTAL |
| Canon MAXIFY MB5090 | `bjc-MAXIFY-MB5090` | EXPERIMENTAL |
| Canon MAXIFY MB5110 | `bjc-MAXIFY-MB5110` | EXPERIMENTAL |
| Canon MAXIFY MB5120 | `bjc-MAXIFY-MB5120` | EXPERIMENTAL |
| Canon MAXIFY MB5130 | `bjc-MAXIFY-MB5130` | EXPERIMENTAL |
| Canon MAXIFY MB5140 | `bjc-MAXIFY-MB5140` | EXPERIMENTAL |
| Canon MAXIFY MB5150 | `bjc-MAXIFY-MB5150` | EXPERIMENTAL |
| Canon MAXIFY MB5160 | `bjc-MAXIFY-MB5160` | EXPERIMENTAL |
| Canon MAXIFY MB5170 | `bjc-MAXIFY-MB5170` | EXPERIMENTAL |
| Canon MAXIFY MB5180 | `bjc-MAXIFY-MB5180` | EXPERIMENTAL |
| Canon MAXIFY MB5190 | `bjc-MAXIFY-MB5190` | EXPERIMENTAL |
| Canon MAXIFY MB5310 | `bjc-MAXIFY-MB5310` | EXPERIMENTAL |
| Canon MAXIFY MB5320 | `bjc-MAXIFY-MB5320` | EXPERIMENTAL |
| Canon MAXIFY MB5330 | `bjc-MAXIFY-MB5330` | EXPERIMENTAL |
| Canon MAXIFY MB5340 | `bjc-MAXIFY-MB5340` | EXPERIMENTAL |
| Canon MAXIFY MB5350 | `bjc-MAXIFY-MB5350` | EXPERIMENTAL |
| Canon MAXIFY MB5360 | `bjc-MAXIFY-MB5360` | EXPERIMENTAL |
| Canon MAXIFY MB5370 | `bjc-MAXIFY-MB5370` | EXPERIMENTAL |
| Canon MAXIFY MB5390 | `bjc-MAXIFY-MB5390` | EXPERIMENTAL |
| Canon MAXIFY MB5410 | `bjc-MAXIFY-MB5410` | EXPERIMENTAL |
| Canon MAXIFY MB5420 | `bjc-MAXIFY-MB5420` | EXPERIMENTAL |
| Canon MAXIFY MB5430 | `bjc-MAXIFY-MB5430` | EXPERIMENTAL |
| Canon MAXIFY MB5440 | `bjc-MAXIFY-MB5440` | EXPERIMENTAL |
| Canon MAXIFY MB5450 | `bjc-MAXIFY-MB5450` | EXPERIMENTAL |
| Canon MAXIFY MB5460 | `bjc-MAXIFY-MB5460` | EXPERIMENTAL |
| Canon MAXIFY MB5470 | `bjc-MAXIFY-MB5470` | EXPERIMENTAL |
| Canon MAXIFY MB5480 | `bjc-MAXIFY-MB5480` | EXPERIMENTAL |
| Canon MAXIFY MB5490 | `bjc-MAXIFY-MB5490` | EXPERIMENTAL |
| Canon MB2000 series | `bjc-MB2000-series` | EXPERIMENTAL |
| Canon MB2100 series | `bjc-MB2100-series` | EXPERIMENTAL |
| Canon MB2300 series | `bjc-MB2300-series` | EXPERIMENTAL |
| Canon MB2700 series | `bjc-MB2700-series` | EXPERIMENTAL |
| Canon MB5000 series | `bjc-MB5000-series` | EXPERIMENTAL |
| Canon MB5100 series | `bjc-MB5100-series` | EXPERIMENTAL |
| Canon MB5300 series | `bjc-MB5300-series` | EXPERIMENTAL |
| Canon MB5400 series | `bjc-MB5400-series` | EXPERIMENTAL |
| Canon MG2100 series | `bjc-MG2100-series` | EXPERIMENTAL |
| Canon MG2200 series | `bjc-MG2200-series` | EXPERIMENTAL |
| Canon MG2400 series | `bjc-MG2400-series` | EXPERIMENTAL |
| Canon MG2500 series | `bjc-MG2500-series` | EXPERIMENTAL |
| Canon MG2900 series | `bjc-MG2900-series` | EXPERIMENTAL |
| Canon MG3000 series | `bjc-MG3000-series` | EXPERIMENTAL |
| Canon MG3100 series | `bjc-MG3100-series` | EXPERIMENTAL |
| Canon MG3200 series | `bjc-MG3200-series` | EXPERIMENTAL |
| Canon MG3500 series | `bjc-MG3500-series` | EXPERIMENTAL |
| Canon MG3600 series | `bjc-MG3600-series` | EXPERIMENTAL |
| Canon MG4100 series | `bjc-MG4100-series` | EXPERIMENTAL |
| Canon MG4200 series | `bjc-MG4200-series` | EXPERIMENTAL |
| Canon MG5100 series | `bjc-MG5100-series` | EXPERIMENTAL |
| Canon MG5200 series | `bjc-MG5200-series` | EXPERIMENTAL |
| Canon MG5300 series | `bjc-MG5300-series` | EXPERIMENTAL |
| Canon MG5400 series | `bjc-MG5400-series` | EXPERIMENTAL |
| Canon MG5500 series | `bjc-MG5500-series` | EXPERIMENTAL |
| Canon MG5600 series | `bjc-MG5600-series` | EXPERIMENTAL |
| Canon MG5700 series | `bjc-MG5700-series` | EXPERIMENTAL |
| Canon MG6100 series | `bjc-MG6100-series` | EXPERIMENTAL |
| Canon MG6200 series | `bjc-MG6200-series` | EXPERIMENTAL |
| Canon MG6300 series | `bjc-MG6300-series` | EXPERIMENTAL |
| Canon MG6400 series | `bjc-MG6400-series` | EXPERIMENTAL |
| Canon MG6500 series | `bjc-MG6500-series` | EXPERIMENTAL |
| Canon MG6600 series | `bjc-MG6600-series` | EXPERIMENTAL |
| Canon MG6700 series | `bjc-MG6700-series` | EXPERIMENTAL |
| Canon MG6800 series | `bjc-MG6800-series` | EXPERIMENTAL |
| Canon MG6900 series | `bjc-MG6900-series` | EXPERIMENTAL |
| Canon MG7100 series | `bjc-MG7100-series` | EXPERIMENTAL |
| Canon MG7500 series | `bjc-MG7500-series` | EXPERIMENTAL |
| Canon MG7700 series | `bjc-MG7700-series` | EXPERIMENTAL |
| Canon MG8100 series | `bjc-MG8100-series` | EXPERIMENTAL |
| Canon MG8200 series | `bjc-MG8200-series` | EXPERIMENTAL |
| Canon Mommy Photo MG5670 | `bjc-Mommy-Photo-MG5670` | EXPERIMENTAL |
| Canon Mommy Photo MG5790 | `bjc-Mommy-Photo-MG5790` | EXPERIMENTAL |
| Canon Mommy Photo MG6670 | `bjc-Mommy-Photo-MG6670` | EXPERIMENTAL |
| Canon Mommy Photo MG7570 | `bjc-Mommy-Photo-MG7570` | EXPERIMENTAL |
| Canon MP140 series | `bjc-MP140-series` | EXPERIMENTAL |
| Canon MP150 series | `bjc-MP150-series` | EXPERIMENTAL |
| Canon MP160 series | `bjc-MP160-series` | EXPERIMENTAL |
| Canon MP170 series | `bjc-MP170-series` | EXPERIMENTAL |
| Canon MP180 series | `bjc-MP180-series` | EXPERIMENTAL |
| Canon MP190 series | `bjc-MP190-series` | EXPERIMENTAL |
| Canon MP210 series | `bjc-MP210-series` | EXPERIMENTAL |
| Canon MP220 series | `bjc-MP220-series` | EXPERIMENTAL |
| Canon MP230 series | `bjc-MP230-series` |  |
| Canon MP240 series | `bjc-MP240-series` | EXPERIMENTAL |
| Canon MP250 series | `bjc-MP250-series` | EXPERIMENTAL |
| Canon MP260 series | `bjc-MP260-series` | EXPERIMENTAL |
| Canon MP270 series | `bjc-MP270-series` | EXPERIMENTAL |
| Canon MP280 series | `bjc-MP280-series` | EXPERIMENTAL |
| Canon MP360 series | `bjc-MP360-series` | EXPERIMENTAL |
| Canon MP370 series | `bjc-MP370-series` | EXPERIMENTAL |
| Canon MP390 series | `bjc-MP390-series` | EXPERIMENTAL |
| Canon MP450 series | `bjc-MP450-series` | EXPERIMENTAL |
| Canon MP460 series | `bjc-MP460-series` | EXPERIMENTAL |
| Canon MP470 series | `bjc-MP470-series` | EXPERIMENTAL |
| Canon MP480 series | `bjc-MP480-series` | EXPERIMENTAL |
| Canon MP490 series | `bjc-MP490-series` | EXPERIMENTAL |
| Canon MP500 series | `bjc-MP500-series` | EXPERIMENTAL |
| Canon MP510 series | `bjc-MP510-series` | EXPERIMENTAL |
| Canon MP520 series | `bjc-MP520-series` | EXPERIMENTAL |
| Canon MP530 series | `bjc-MP530-series` | EXPERIMENTAL |
| Canon MP540 series | `bjc-MP540-series` | EXPERIMENTAL |
| Canon MP550 series | `bjc-MP550-series` | EXPERIMENTAL |
| Canon MP560 series | `bjc-MP560-series` | EXPERIMENTAL |
| Canon MP600 series | `bjc-MP600-series` | EXPERIMENTAL |
| Canon MP610 series | `bjc-MP610-series` | EXPERIMENTAL |
| Canon MP620 series | `bjc-MP620-series` | EXPERIMENTAL |
| Canon MP630 series | `bjc-MP630-series` | EXPERIMENTAL |
| Canon MP640 series | `bjc-MP640-series` | EXPERIMENTAL |
| Canon MP700 series | `bjc-MP700-series` | EXPERIMENTAL |
| Canon MP710 series | `bjc-MP710-series` | EXPERIMENTAL |
| Canon MP730 series | `bjc-MP730-series` | EXPERIMENTAL |
| Canon MP740 series | `bjc-MP740-series` | EXPERIMENTAL |
| Canon MP750 series | `bjc-MP750-series` | EXPERIMENTAL |
| Canon MP760 series | `bjc-MULTIPASS-MP760-series` | EXPERIMENTAL |
| Canon MP770 series | `bjc-MULTIPASS-MP770-series` | EXPERIMENTAL |
| Canon MP780 series | `bjc-MP780-series` | EXPERIMENTAL |
| Canon MP790 series | `bjc-MP790-series` | EXPERIMENTAL |
| Canon MP800 series | `bjc-MP800-series` | EXPERIMENTAL |
| Canon MP810 series | `bjc-MP810-series` | EXPERIMENTAL |
| Canon MP830 series | `bjc-MP830-series` | EXPERIMENTAL |
| Canon MP900 series | `bjc-MP900-series` | EXPERIMENTAL |
| Canon MP950 series | `bjc-MP950-series` | EXPERIMENTAL |
| Canon MP960 series | `bjc-MP960-series` | EXPERIMENTAL |
| Canon MP970 series | `bjc-MP970-series` | EXPERIMENTAL |
| Canon MP980 series | `bjc-MP980-series` | EXPERIMENTAL |
| Canon MP990 series | `bjc-MP990-series` | EXPERIMENTAL |
| Canon MultiPASS MP360 | `bjc-MULTIPASS-MP360` | EXPERIMENTAL |
| Canon MultiPASS MP370 | `bjc-MULTIPASS-MP370` | EXPERIMENTAL |
| Canon MultiPASS MP390 | `bjc-MULTIPASS-MP390` | EXPERIMENTAL |
| Canon MultiPASS MP700 | `bjc-MULTIPASS-MP700` | EXPERIMENTAL |
| Canon MultiPASS MP730 | `bjc-MULTIPASS-MP730` | EXPERIMENTAL |
| Canon MX300 series | `bjc-MX300-series` | EXPERIMENTAL |
| Canon MX310 series | `bjc-MX310-series` | EXPERIMENTAL |
| Canon MX320 series | `bjc-MX320-series` | EXPERIMENTAL |
| Canon MX330 series | `bjc-MX330-series` | EXPERIMENTAL |
| Canon MX340 series | `bjc-MX340-series` | EXPERIMENTAL |
| Canon MX350 series | `bjc-MX350-series` | EXPERIMENTAL |
| Canon MX360 series | `bjc-MX360-series` | EXPERIMENTAL |
| Canon MX370 series | `bjc-MX370-series` | EXPERIMENTAL |
| Canon MX390 series | `bjc-MX390-series` | EXPERIMENTAL |
| Canon MX410 series | `bjc-MX410-series` | EXPERIMENTAL |
| Canon MX420 series | `bjc-MX420-series` | EXPERIMENTAL |
| Canon MX430 series | `bjc-MX430-series` | EXPERIMENTAL |
| Canon MX450 series | `bjc-MX450-series` | EXPERIMENTAL |
| Canon MX470 series | `bjc-MX470-series` | EXPERIMENTAL |
| Canon MX490 series | `bjc-MX490-series` | EXPERIMENTAL |
| Canon MX510 series | `bjc-MX510-series` | EXPERIMENTAL |
| Canon MX520 series | `bjc-MX520-series` | EXPERIMENTAL |
| Canon MX530 series | `bjc-MX530-series` | EXPERIMENTAL |
| Canon MX700 series | `bjc-MX700-series` | EXPERIMENTAL |
| Canon MX710 series | `bjc-MX710-series` | EXPERIMENTAL |
| Canon MX720 series | `bjc-MX720-series` | EXPERIMENTAL |
| Canon MX7600 series | `bjc-MX7600-series` | EXPERIMENTAL |
| Canon MX850 series | `bjc-MX850-series` | EXPERIMENTAL |
| Canon MX860 series | `bjc-MX860-series` | EXPERIMENTAL |
| Canon MX870 series | `bjc-MX870-series` | EXPERIMENTAL |
| Canon MX880 series | `bjc-MX880-series` | EXPERIMENTAL |
| Canon MX890 series | `bjc-MX890-series` | EXPERIMENTAL |
| Canon MX920 series | `bjc-MX920-series` | EXPERIMENTAL |
| Canon PIXMA E3170 | `bjc-PIXMA-E3170` | EXPERIMENTAL |
| Canon PIXMA E3190 | `bjc-PIXMA-E3190` | EXPERIMENTAL |
| Canon PIXMA E3195 | `bjc-PIXMA-E3195` | EXPERIMENTAL |
| Canon PIXMA E400 | `bjc-PIXMA-E400` | EXPERIMENTAL |
| Canon PIXMA E401 | `bjc-PIXMA-E401` | EXPERIMENTAL |
| Canon PIXMA E404 | `bjc-PIXMA-E404` | EXPERIMENTAL |
| Canon PIXMA E408 | `bjc-PIXMA-E408` | EXPERIMENTAL |
| Canon PIXMA E409 | `bjc-PIXMA-E409` | EXPERIMENTAL |
| Canon PIXMA E410 | `bjc-PIXMA-E410` | EXPERIMENTAL |
| Canon PIXMA E414 | `bjc-PIXMA-E414` | EXPERIMENTAL |
| Canon PIXMA E417 | `bjc-PIXMA-E417` | EXPERIMENTAL |
| Canon PIXMA E418 | `bjc-PIXMA-E418` | EXPERIMENTAL |
| Canon PIXMA E460 | `bjc-PIXMA-E460` | EXPERIMENTAL |
| Canon PIXMA E461 | `bjc-PIXMA-E461` | EXPERIMENTAL |
| Canon PIXMA E464 | `bjc-PIXMA-E464` | EXPERIMENTAL |
| Canon PIXMA E468 | `bjc-PIXMA-E468` | EXPERIMENTAL |
| Canon PIXMA E470 | `bjc-PIXMA-E470` | EXPERIMENTAL |
| Canon PIXMA E471 | `bjc-PIXMA-E471` | EXPERIMENTAL |
| Canon PIXMA E474 | `bjc-PIXMA-E474` | EXPERIMENTAL |
| Canon PIXMA E477 | `bjc-PIXMA-E477` | EXPERIMENTAL |
| Canon PIXMA E478 | `bjc-PIXMA-E478` | EXPERIMENTAL |
| Canon PIXMA E480 | `bjc-PIXMA-E480` | EXPERIMENTAL |
| Canon PIXMA E481 | `bjc-PIXMA-E481` | EXPERIMENTAL |
| Canon PIXMA E484 | `bjc-PIXMA-E484` | EXPERIMENTAL |
| Canon PIXMA E488 | `bjc-PIXMA-E488` | EXPERIMENTAL |
| Canon PIXMA E489 | `bjc-PIXMA-E489` | EXPERIMENTAL |
| Canon PIXMA E500 | `bjc-MULTIPASS-E500` | EXPERIMENTAL |
| Canon PIXMA E510 | `bjc-PIXMA-E510` | EXPERIMENTAL |
| Canon PIXMA E514 | `bjc-PIXMA-E514` | EXPERIMENTAL |
| Canon PIXMA E518 | `bjc-PIXMA-E518` | EXPERIMENTAL |
| Canon PIXMA E560 | `bjc-PIXMA-E560` | EXPERIMENTAL |
| Canon PIXMA E568 | `bjc-PIXMA-E568` | EXPERIMENTAL |
| Canon PIXMA E569 | `bjc-PIXMA-E569` | EXPERIMENTAL |
| Canon PIXMA E600 | `bjc-MULTIPASS-E600` | EXPERIMENTAL |
| Canon PIXMA E608 | `bjc-PIXMA-E608` | EXPERIMENTAL |
| Canon PIXMA E610 | `bjc-PIXMA-E610` | EXPERIMENTAL |
| Canon PIXMA E618 | `bjc-PIXMA-E618` | EXPERIMENTAL |
| Canon PIXMA G1000 | `bjc-PIXMA-G1000` | EXPERIMENTAL |
| Canon PIXMA G1100 | `bjc-PIXMA-G1100` | EXPERIMENTAL |
| Canon PIXMA G1200 | `bjc-PIXMA-G1200` | EXPERIMENTAL |
| Canon PIXMA G1400 | `bjc-PIXMA-G1400` | EXPERIMENTAL |
| Canon PIXMA G1500 | `bjc-PIXMA-G1500` | EXPERIMENTAL |
| Canon PIXMA G1800 | `bjc-PIXMA-G1800` | EXPERIMENTAL |
| Canon PIXMA G1900 | `bjc-PIXMA-G1900` | EXPERIMENTAL |
| Canon PIXMA G1910 | `bjc-PIXMA-G1910` | EXPERIMENTAL |
| Canon PIXMA G2000 | `bjc-PIXMA-G2000` | EXPERIMENTAL |
| Canon PIXMA G2002 | `bjc-PIXMA-G2002` | EXPERIMENTAL |
| Canon PIXMA G2100 | `bjc-PIXMA-G2100` | EXPERIMENTAL |
| Canon PIXMA G2200 | `bjc-PIXMA-G2200` | EXPERIMENTAL |
| Canon PIXMA G2400 | `bjc-PIXMA-G2400` | EXPERIMENTAL |
| Canon PIXMA G2500 | `bjc-PIXMA-G2500` | EXPERIMENTAL |
| Canon PIXMA G2600 | `bjc-PIXMA-G2600` | EXPERIMENTAL |
| Canon PIXMA G2800 | `bjc-PIXMA-G2800` | EXPERIMENTAL |
| Canon PIXMA G2900 | `bjc-PIXMA-G2900` | EXPERIMENTAL |
| Canon PIXMA G2910 | `bjc-PIXMA-G2910` | EXPERIMENTAL |
| Canon PIXMA G2915 | `bjc-PIXMA-G2915` | EXPERIMENTAL |
| Canon PIXMA G3000 | `bjc-PIXMA-G3000` | EXPERIMENTAL |
| Canon PIXMA G3010 | `bjc-PIXMA-G3010` | EXPERIMENTAL |
| Canon PIXMA G3100 | `bjc-PIXMA-G3100` | EXPERIMENTAL |
| Canon PIXMA G3200 | `bjc-PIXMA-G3200` | EXPERIMENTAL |
| Canon PIXMA G3400 | `bjc-PIXMA-G3400` | EXPERIMENTAL |
| Canon PIXMA G3500 | `bjc-PIXMA-G3500` | EXPERIMENTAL |
| Canon PIXMA G3600 | `bjc-PIXMA-G3600` | EXPERIMENTAL |
| Canon PIXMA G3800 | `bjc-PIXMA-G3800` | EXPERIMENTAL |
| Canon PIXMA G3900 | `bjc-PIXMA-G3900` | EXPERIMENTAL |
| Canon PIXMA G3910 | `bjc-PIXMA-G3910` | EXPERIMENTAL |
| Canon PIXMA G3915 | `bjc-PIXMA-G3915` | EXPERIMENTAL |
| Canon PIXMA G4000 | `bjc-PIXMA-G4000` | EXPERIMENTAL |
| Canon PIXMA G4010 | `bjc-PIXMA-G4010` | EXPERIMENTAL |
| Canon PIXMA G4100 | `bjc-PIXMA-G4100` | EXPERIMENTAL |
| Canon PIXMA G4200 | `bjc-PIXMA-G4200` | EXPERIMENTAL |
| Canon PIXMA G4400 | `bjc-PIXMA-G4400` | EXPERIMENTAL |
| Canon PIXMA G4500 | `bjc-PIXMA-G4500` | EXPERIMENTAL |
| Canon PIXMA G4600 | `bjc-PIXMA-G4600` | EXPERIMENTAL |
| Canon PIXMA G4800 | `bjc-PIXMA-G4800` | EXPERIMENTAL |
| Canon PIXMA G4900 | `bjc-PIXMA-G4900` | EXPERIMENTAL |
| Canon PIXMA G4902 | `bjc-PIXMA-G4902` | EXPERIMENTAL |
| Canon PIXMA G4910 | `bjc-PIXMA-G4910` | EXPERIMENTAL |
| Canon PIXMA G4911 | `bjc-PIXMA-G4911` | EXPERIMENTAL |
| Canon PIXMA iP110 | `bjc-PIXMA-iP110` | EXPERIMENTAL |
| Canon PIXMA iP2000 | `bjc-PIXMA-iP2000` | EXPERIMENTAL |
| Canon PIXMA iP2700 | `bjc-PIXMA-iP2700` | EXPERIMENTAL |
| Canon PIXMA iP2701 | `bjc-PIXMA-iP2701` | EXPERIMENTAL |
| Canon PIXMA iP2702 | `bjc-PIXMA-iP2702` | EXPERIMENTAL |
| Canon PIXMA iP2740 | `bjc-PIXMA-iP2740` | EXPERIMENTAL |
| Canon PIXMA iP2760 | `bjc-PIXMA-iP2760` | EXPERIMENTAL |
| Canon PIXMA iP2770 | `bjc-PIXMA-iP2770` | EXPERIMENTAL |
| Canon PIXMA iP2772 | `bjc-PIXMA-iP2772` | EXPERIMENTAL |
| Canon PIXMA iP2780 | `bjc-PIXMA-iP2780` | EXPERIMENTAL |
| Canon PIXMA iP2788 | `bjc-PIXMA-iP2788` | EXPERIMENTAL |
| Canon PIXMA iP2810 | `bjc-PIXMA-iP2810` | EXPERIMENTAL |
| Canon PIXMA iP2820 | `bjc-PIXMA-iP2820` | EXPERIMENTAL |
| Canon PIXMA iP2840 | `bjc-PIXMA-iP2840` | EXPERIMENTAL |
| Canon PIXMA iP2850 | `bjc-PIXMA-iP2850` | EXPERIMENTAL |
| Canon PIXMA iP2870 | `bjc-PIXMA-iP2870` | EXPERIMENTAL |
| Canon PIXMA iP2872 | `bjc-PIXMA-iP2872` | EXPERIMENTAL |
| Canon PIXMA iP2880 | `bjc-PIXMA-iP2880` | EXPERIMENTAL |
| Canon PIXMA iP2890 | `bjc-PIXMA-iP2890` | EXPERIMENTAL |
| Canon PIXMA iP2899 | `bjc-PIXMA-iP2899` | EXPERIMENTAL |
| Canon PIXMA iP3000 | `bjc-PIXMA-iP3000` | EXPERIMENTAL |
| Canon PIXMA iP3100 | `bjc-PIXMA-iP3100` | EXPERIMENTAL |
| Canon PIXMA iP3300 | `bjc-PIXMA-iP3300` | EXPERIMENTAL |
| Canon PIXMA iP3500 | `bjc-PIXMA-iP3500` | EXPERIMENTAL |
| Canon PIXMA iP3600 | `bjc-PIXMA-iP3600` | EXPERIMENTAL |
| Canon PIXMA iP3680 | `bjc-PIXMA-iP3680` | EXPERIMENTAL |
| Canon PIXMA iP4000 | `bjc-iP4000` |  |
| Canon PIXMA iP4000R | `bjc-PIXMA-iP4000R` |  |
| Canon PIXMA iP4100 | `bjc-PIXMA-iP4100` | EXPERIMENTAL |
| Canon PIXMA iP4100R | `bjc-PIXMA-iP4100R` | EXPERIMENTAL |
| Canon PIXMA iP4200 | `bjc-PIXMA-iP4200` | EXPERIMENTAL |
| Canon PIXMA iP4300 | `bjc-PIXMA-iP4300` | EXPERIMENTAL |
| Canon PIXMA iP4500 | `bjc-PIXMA-iP4500` | EXPERIMENTAL |
| Canon PIXMA iP4600 | `bjc-PIXMA-iP4600` | EXPERIMENTAL |
| Canon PIXMA iP4680 | `bjc-PIXMA-iP4680` | EXPERIMENTAL |
| Canon PIXMA iP4700 | `bjc-PIXMA-iP4700` | EXPERIMENTAL |
| Canon PIXMA iP4760 | `bjc-PIXMA-iP4760` | EXPERIMENTAL |
| Canon PIXMA iP4800 | `bjc-PIXMA-iP4800` | EXPERIMENTAL |
| Canon PIXMA iP4810 | `bjc-PIXMA-iP4810` | EXPERIMENTAL |
| Canon PIXMA iP4820 | `bjc-PIXMA-iP4820` | EXPERIMENTAL |
| Canon PIXMA iP4840 | `bjc-PIXMA-iP4840` | EXPERIMENTAL |
| Canon PIXMA iP4850 | `bjc-PIXMA-iP4850` | EXPERIMENTAL |
| Canon PIXMA iP4870 | `bjc-PIXMA-iP4870` | EXPERIMENTAL |
| Canon PIXMA iP4880 | `bjc-PIXMA-iP4880` | EXPERIMENTAL |
| Canon PIXMA iP4900 | `bjc-PIXMA-iP4900` | EXPERIMENTAL |
| Canon PIXMA iP4910 | `bjc-PIXMA-iP4910` | EXPERIMENTAL |
| Canon PIXMA iP4920 | `bjc-PIXMA-iP4920` | EXPERIMENTAL |
| Canon PIXMA iP4940 | `bjc-PIXMA-iP4940` | EXPERIMENTAL |
| Canon PIXMA iP4950 | `bjc-PIXMA-iP4950` | EXPERIMENTAL |
| Canon PIXMA iP4970 | `bjc-PIXMA-iP4970` | EXPERIMENTAL |
| Canon PIXMA iP4980 | `bjc-PIXMA-iP4980` | EXPERIMENTAL |
| Canon PIXMA iP5000 | `bjc-PIXMA-iP5000` | EXPERIMENTAL |
| Canon PIXMA iP5200 | `bjc-PIXMA-iP5200` | EXPERIMENTAL |
| Canon PIXMA iP5200R | `bjc-PIXMA-iP5200R` | EXPERIMENTAL |
| Canon PIXMA iP5300 | `bjc-PIXMA-iP5300` | EXPERIMENTAL |
| Canon PIXMA iP6000D | `bjc-PIXMA-iP6000D` | EXPERIMENTAL |
| Canon PIXMA iP6100D | `bjc-PIXMA-iP6100D` | EXPERIMENTAL |
| Canon PIXMA iP6210D | `bjc-PIXMA-iP6210D` | EXPERIMENTAL |
| Canon PIXMA iP6220D | `bjc-PIXMA-iP6220D` | EXPERIMENTAL |
| Canon PIXMA iP6310D | `bjc-PIXMA-iP6310D` | EXPERIMENTAL |
| Canon PIXMA iP6320D | `bjc-PIXMA-iP6320D` | EXPERIMENTAL |
| Canon PIXMA iP6600D | `bjc-PIXMA-iP6600D` | EXPERIMENTAL |
| Canon PIXMA iP6700D | `bjc-PIXMA-iP6700` | EXPERIMENTAL |
| Canon PIXMA iP7100 | `bjc-PIXMA-iP7100` | EXPERIMENTAL |
| Canon PIXMA iP7210 | `bjc-PIXMA-iP7210` | EXPERIMENTAL |
| Canon PIXMA iP7220 | `bjc-PIXMA-iP7220` | EXPERIMENTAL |
| Canon PIXMA iP7240 | `bjc-PIXMA-iP7240` | EXPERIMENTAL |
| Canon PIXMA iP7250 | `bjc-PIXMA-iP7250` | EXPERIMENTAL |
| Canon PIXMA iP7260 | `bjc-PIXMA-iP7260` | EXPERIMENTAL |
| Canon PIXMA iP7270 | `bjc-PIXMA-iP7270` | EXPERIMENTAL |
| Canon PIXMA iP7280 | `bjc-PIXMA-iP7280` | EXPERIMENTAL |

| Canon PIXMA iP7500 | `bjc-PIXMA-iP7500` | EXPERIMENTAL |
| Canon PIXMA iP7810 | `bjc-PIXMA-iP8710` | EXPERIMENTAL |
| Canon PIXMA iP8100 | `bjc-PIXMA-iP8100` | EXPERIMENTAL |
| Canon PIXMA iP8500 | `bjc-PIXMA-iP8500` | EXPERIMENTAL |
| Canon PIXMA iP8600 | `bjc-PIXMA-iP8600` | EXPERIMENTAL |
| Canon PIXMA iP8720 | `bjc-PIXMA-iP8720` | EXPERIMENTAL |
| Canon PIXMA iP8740 | `bjc-PIXMA-iP8740` | EXPERIMENTAL |
| Canon PIXMA iP8750 | `bjc-PIXMA-iP8750` | EXPERIMENTAL |
| Canon PIXMA iP8760 | `bjc-PIXMA-iP8760` | EXPERIMENTAL |
| Canon PIXMA iP8770 | `bjc-PIXMA-iP8770` | EXPERIMENTAL |
| Canon PIXMA iP8780 | `bjc-PIXMA-iP8780` | EXPERIMENTAL |
| Canon PIXMA iP90 | `bjc-PIXMA-iP90` |  |
| Canon PIXMA iP90v | `bjc-PIXMA-iP90v` |  |
| Canon PIXMA iP9910 | `bjc-PIXMA-iP9910` | EXPERIMENTAL |
| Canon PIXMA iX4000 | `bjc-PIXMA-iX4000` | EXPERIMENTAL |
| Canon PIXMA iX5000 | `bjc-PIXMA-iX5000` | EXPERIMENTAL |
| Canon PIXMA iX6500 | `bjc-PIXMA-iX6500` | EXPERIMENTAL |
| Canon PIXMA iX6510 | `bjc-PIXMA-iX6510` | EXPERIMENTAL |
| Canon PIXMA iX6520 | `bjc-PIXMA-iX6520` | EXPERIMENTAL |
| Canon PIXMA iX6540 | `bjc-PIXMA-iX6540` | EXPERIMENTAL |
| Canon PIXMA iX6550 | `bjc-PIXMA-iX6550` | EXPERIMENTAL |
| Canon PIXMA iX6560 | `bjc-PIXMA-iX6560` | EXPERIMENTAL |
| Canon PIXMA iX6580 | `bjc-PIXMA-iX6580` | EXPERIMENTAL |
| Canon PIXMA iX6770 | `bjc-PIXMA-iX6770` | EXPERIMENTAL |
| Canon PIXMA iX6780 | `bjc-PIXMA-iX6780` | EXPERIMENTAL |
| Canon PIXMA iX6810 | `bjc-PIXMA-iX6810` | EXPERIMENTAL |
| Canon PIXMA iX6820 | `bjc-PIXMA-iX6820` | EXPERIMENTAL |
| Canon PIXMA iX6840 | `bjc-PIXMA-iX6840` | EXPERIMENTAL |
| Canon PIXMA iX6850 | `bjc-PIXMA-iX6850` | EXPERIMENTAL |
| Canon PIXMA iX6860 | `bjc-PIXMA-iX6860` | EXPERIMENTAL |
| Canon PIXMA iX6870 | `bjc-PIXMA-iX6870` | EXPERIMENTAL |
| Canon PIXMA iX6880 | `bjc-PIXMA-iX6880` | EXPERIMENTAL |
| Canon PIXMA iX7000 | `bjc-PIXMA-iX7000` | EXPERIMENTAL |
| Canon PIXMA MG2100 | `bjc-PIXMA-MG2100` | EXPERIMENTAL |
| Canon PIXMA MG2110 | `bjc-PIXMA-MG2110` | EXPERIMENTAL |
| Canon PIXMA MG2120 | `bjc-PIXMA-MG2120` | EXPERIMENTAL |
| Canon PIXMA MG2140 | `bjc-PIXMA-MG2140` | EXPERIMENTAL |
| Canon PIXMA MG2150 | `bjc-PIXMA-MG2150` | EXPERIMENTAL |
| Canon PIXMA MG2160 | `bjc-PIXMA-MG2160` | EXPERIMENTAL |
| Canon PIXMA MG2170 | `bjc-PIXMA-MG2170` | EXPERIMENTAL |
| Canon PIXMA MG2180 | `bjc-PIXMA-MG2180` | EXPERIMENTAL |
| Canon PIXMA MG2210 | `bjc-PIXMA-MG2210` | EXPERIMENTAL |
| Canon PIXMA MG2220 | `bjc-PIXMA-MG2220` | EXPERIMENTAL |
| Canon PIXMA MG2240 | `bjc-PIXMA-MG2240` | EXPERIMENTAL |
| Canon PIXMA MG2250 | `bjc-PIXMA-MG2250` | EXPERIMENTAL |
| Canon PIXMA MG2260 | `bjc-PIXMA-MG2260` | EXPERIMENTAL |
| Canon PIXMA MG2270 | `bjc-PIXMA-MG2270` | EXPERIMENTAL |
| Canon PIXMA MG2280 | `bjc-PIXMA-MG2280` | EXPERIMENTAL |
| Canon PIXMA MG2400 | `bjc-PIXMA-MG2400` | EXPERIMENTAL |
| Canon PIXMA MG2410 | `bjc-PIXMA-MG2410` | EXPERIMENTAL |
| Canon PIXMA MG2420 | `bjc-PIXMA-MG2420` | EXPERIMENTAL |
| Canon PIXMA MG2440 | `bjc-PIXMA-MG2440` | EXPERIMENTAL |
| Canon PIXMA MG2450 | `bjc-PIXMA-MG2450` | EXPERIMENTAL |
| Canon PIXMA MG2460 | `bjc-PIXMA-MG2460` | EXPERIMENTAL |
| Canon PIXMA MG2470 | `bjc-PIXMA-MG2470` | EXPERIMENTAL |
| Canon PIXMA MG2490 | `bjc-PIXMA-MG2490` | EXPERIMENTAL |
| Canon PIXMA MG2510 | `bjc-PIXMA-MG2510` | EXPERIMENTAL |
| Canon PIXMA MG2520 | `bjc-PIXMA-MG2520` | EXPERIMENTAL |
| Canon PIXMA MG2522 | `bjc-PIXMA-MG2522` | EXPERIMENTAL |
| Canon PIXMA MG2525 | `bjc-PIXMA-MG2525` | EXPERIMENTAL |
| Canon PIXMA MG2540 | `bjc-PIXMA-MG2540` | EXPERIMENTAL |
| Canon PIXMA MG2540S | `bjc-PIXMA-MG2540S` | EXPERIMENTAL |
| Canon PIXMA MG2545S | `bjc-PIXMA-MG2545S` | EXPERIMENTAL |
| Canon PIXMA MG2550 | `bjc-PIXMA-MG2550` | EXPERIMENTAL |
| Canon PIXMA MG2550S | `bjc-PIXMA-MG2550S` | EXPERIMENTAL |
| Canon PIXMA MG2555S | `bjc-PIXMA-MG2555S` | EXPERIMENTAL |
| Canon PIXMA MG2560 | `bjc-PIXMA-MG2560` | EXPERIMENTAL |
| Canon PIXMA MG2570 | `bjc-PIXMA-MG2570` | EXPERIMENTAL |
| Canon PIXMA MG2570S | `bjc-PIXMA-MG2570S` | EXPERIMENTAL |
| Canon PIXMA MG2580 | `bjc-PIXMA-MG2580` | EXPERIMENTAL |
| Canon PIXMA MG2580S | `bjc-PIXMA-MG2580S` | EXPERIMENTAL |
| Canon PIXMA MG2590 | `bjc-PIXMA-MG2590` | EXPERIMENTAL |
| Canon PIXMA MG2910 | `bjc-PIXMA-MG2910` | EXPERIMENTAL |
| Canon PIXMA MG2920 | `bjc-PIXMA-MG2920` | EXPERIMENTAL |
| Canon PIXMA MG2922 | `bjc-PIXMA-MG2922` | EXPERIMENTAL |
| Canon PIXMA MG2924 | `bjc-PIXMA-MG2924` | EXPERIMENTAL |
| Canon PIXMA MG2940 | `bjc-PIXMA-MG2940` | EXPERIMENTAL |
| Canon PIXMA MG2950 | `bjc-PIXMA-MG2950` | EXPERIMENTAL |
| Canon PIXMA MG2960 | `bjc-PIXMA-MG2960` | EXPERIMENTAL |
| Canon PIXMA MG2970 | `bjc-PIXMA-MG2970` | EXPERIMENTAL |
| Canon PIXMA MG2980 | `bjc-PIXMA-MG2980` | EXPERIMENTAL |
| Canon PIXMA MG2990 | `bjc-PIXMA-MG2990` | EXPERIMENTAL |
| Canon PIXMA MG3010 | `bjc-PIXMA-MG3010` | EXPERIMENTAL |
| Canon PIXMA MG3020 | `bjc-PIXMA-MG3020` | EXPERIMENTAL |
| Canon PIXMA MG3022 | `bjc-PIXMA-MG3022` | EXPERIMENTAL |
| Canon PIXMA MG3030 | `bjc-PIXMA-MG3030` | EXPERIMENTAL |
| Canon PIXMA MG3040 | `bjc-PIXMA-MG3040` | EXPERIMENTAL |
| Canon PIXMA MG3050 | `bjc-PIXMA-MG3050` | EXPERIMENTAL |
| Canon PIXMA MG3051 | `bjc-PIXMA-MG3051` | EXPERIMENTAL |
| Canon PIXMA MG3052 | `bjc-PIXMA-MG3052` | EXPERIMENTAL |
| Canon PIXMA MG3053 | `bjc-PIXMA-MG3053` | EXPERIMENTAL |
| Canon PIXMA MG3060 | `bjc-PIXMA-MG3060` | EXPERIMENTAL |
| Canon PIXMA MG3070 | `bjc-PIXMA-MG3070` | EXPERIMENTAL |
| Canon PIXMA MG3077 | `bjc-PIXMA-MG3077` | EXPERIMENTAL |
| Canon PIXMA MG3080 | `bjc-PIXMA-MG3080` | EXPERIMENTAL |
| Canon PIXMA MG3090 | `bjc-PIXMA-MG3090` | EXPERIMENTAL |
| Canon PIXMA MG3100 | `bjc-PIXMA-MG3100` | EXPERIMENTAL |
| Canon PIXMA MG3110 | `bjc-PIXMA-MG3110` | EXPERIMENTAL |
| Canon PIXMA MG3120 | `bjc-PIXMA-MG3120` | EXPERIMENTAL |
| Canon PIXMA MG3122 | `bjc-PIXMA-MG3122` | EXPERIMENTAL |
| Canon PIXMA MG3140 | `bjc-PIXMA-MG3140` | EXPERIMENTAL |
| Canon PIXMA MG3150 | `bjc-PIXMA-MG3150` | EXPERIMENTAL |
| Canon PIXMA MG3160 | `bjc-PIXMA-MG3160` | EXPERIMENTAL |
| Canon PIXMA MG3170 | `bjc-PIXMA-MG3170` | EXPERIMENTAL |
| Canon PIXMA MG3180 | `bjc-PIXMA-MG3180` | EXPERIMENTAL |
| Canon PIXMA MG3210 | `bjc-PIXMA-MG3210` | EXPERIMENTAL |
| Canon PIXMA MG3220 | `bjc-PIXMA-MG3220` | EXPERIMENTAL |
| Canon PIXMA MG3222 | `bjc-PIXMA-MG3222` | EXPERIMENTAL |
| Canon PIXMA MG3240 | `bjc-PIXMA-MG3240` | EXPERIMENTAL |
| Canon PIXMA MG3250 | `bjc-PIXMA-MG3250` | EXPERIMENTAL |
| Canon PIXMA MG3260 | `bjc-PIXMA-MG3260` | EXPERIMENTAL |
| Canon PIXMA MG3270 | `bjc-PIXMA-MG3270` | EXPERIMENTAL |
| Canon PIXMA MG3510 | `bjc-PIXMA-MG3510` | EXPERIMENTAL |
| Canon PIXMA MG3520 | `bjc-PIXMA-MG3520` | EXPERIMENTAL |
| Canon PIXMA MG3522 | `bjc-PIXMA-MG3522` | EXPERIMENTAL |
| Canon PIXMA MG3540 | `bjc-PIXMA-MG3540` | EXPERIMENTAL |
| Canon PIXMA MG3550 | `bjc-PIXMA-MG3550` | EXPERIMENTAL |
| Canon PIXMA MG3560 | `bjc-PIXMA-MG3560` | EXPERIMENTAL |
| Canon PIXMA MG3570 | `bjc-PIXMA-MG3570` | EXPERIMENTAL |
| Canon PIXMA MG3580 | `bjc-PIXMA-MG3580` | EXPERIMENTAL |
| Canon PIXMA MG3610 | `bjc-PIXMA-MG3610` | EXPERIMENTAL |
| Canon PIXMA MG3620 | `bjc-PIXMA-MG3620` | EXPERIMENTAL |
| Canon PIXMA MG3640 | `bjc-PIXMA-MG3640` | EXPERIMENTAL |
| Canon PIXMA MG3650 | `bjc-PIXMA-MG3650` | EXPERIMENTAL |
| Canon PIXMA MG3670 | `bjc-PIXMA-MG3670` | EXPERIMENTAL |
| Canon PIXMA MG3680 | `bjc-PIXMA-MG3680` | EXPERIMENTAL |
| Canon PIXMA MG4100 | `bjc-PIXMA-MG4100` | EXPERIMENTAL |
| Canon PIXMA MG4110 | `bjc-PIXMA-MG4110` | EXPERIMENTAL |
| Canon PIXMA MG4120 | `bjc-PIXMA-MG4120` | EXPERIMENTAL |
| Canon PIXMA MG4140 | `bjc-PIXMA-MG4140` | EXPERIMENTAL |
| Canon PIXMA MG4150 | `bjc-PIXMA-MG4150` | EXPERIMENTAL |
| Canon PIXMA MG4160 | `bjc-PIXMA-MG4160` | EXPERIMENTAL |
| Canon PIXMA MG4170 | `bjc-PIXMA-MG4170` | EXPERIMENTAL |
| Canon PIXMA MG4180 | `bjc-PIXMA-MG4180` | EXPERIMENTAL |
| Canon PIXMA MG4210 | `bjc-PIXMA-MG4210` | EXPERIMENTAL |
| Canon PIXMA MG4220 | `bjc-PIXMA-MG4220` | EXPERIMENTAL |
| Canon PIXMA MG4240 | `bjc-PIXMA-MG4240` | EXPERIMENTAL |
| Canon PIXMA MG4250 | `bjc-PIXMA-MG4250` | EXPERIMENTAL |
| Canon PIXMA MG4260 | `bjc-PIXMA-MG4260` | EXPERIMENTAL |
| Canon PIXMA MG4270 | `bjc-PIXMA-MG4270` | EXPERIMENTAL |
| Canon PIXMA MG4280 | `bjc-PIXMA-MG4280` | EXPERIMENTAL |
| Canon PIXMA MG5100 | `bjc-PIXMA-MG5100` | EXPERIMENTAL |
| Canon PIXMA MG5120 | `bjc-PIXMA-MG5120` | EXPERIMENTAL |
| Canon PIXMA MG5140 | `bjc-PIXMA-MG5140` | EXPERIMENTAL |
| Canon PIXMA MG5150 | `bjc-PIXMA-MG5150` | EXPERIMENTAL |
| Canon PIXMA MG5170 | `bjc-PIXMA-MG5170` | EXPERIMENTAL |
| Canon PIXMA MG5180 | `bjc-PIXMA-MG5180` | EXPERIMENTAL |
| Canon PIXMA MG5200 | `bjc-PIXMA-MG5200` | EXPERIMENTAL |
| Canon PIXMA MG5210 | `bjc-PIXMA-MG5210` | EXPERIMENTAL |
| Canon PIXMA MG5220 | `bjc-PIXMA-MG5220` | EXPERIMENTAL |
| Canon PIXMA MG5240 | `bjc-PIXMA-MG5240` | EXPERIMENTAL |
| Canon PIXMA MG5250 | `bjc-PIXMA-MG5250` | EXPERIMENTAL |
| Canon PIXMA MG5270 | `bjc-PIXMA-MG5270` | EXPERIMENTAL |
| Canon PIXMA MG5280 | `bjc-PIXMA-MG5280` | EXPERIMENTAL |
| Canon PIXMA MG5300 | `bjc-PIXMA-MG5300` | EXPERIMENTAL |
| Canon PIXMA MG5310 | `bjc-PIXMA-MG5310` | EXPERIMENTAL |
| Canon PIXMA MG5320 | `bjc-PIXMA-MG5320` | EXPERIMENTAL |
| Canon PIXMA MG5340 | `bjc-PIXMA-MG5340` | EXPERIMENTAL |
| Canon PIXMA MG5350 | `bjc-PIXMA-MG5350` | EXPERIMENTAL |
| Canon PIXMA MG5370 | `bjc-PIXMA-MG5370` | EXPERIMENTAL |
| Canon PIXMA MG5380 | `bjc-PIXMA-MG5380` | EXPERIMENTAL |
| Canon PIXMA MG5410 | `bjc-PIXMA-MG5410` | EXPERIMENTAL |
| Canon PIXMA MG5420 | `bjc-PIXMA-MG5420` | EXPERIMENTAL |
| Canon PIXMA MG5422 | `bjc-PIXMA-MG5422` | EXPERIMENTAL |
| Canon PIXMA MG5440 | `bjc-PIXMA-MG5440` | EXPERIMENTAL |
| Canon PIXMA MG5450 | `bjc-PIXMA-MG5450` | EXPERIMENTAL |
| Canon PIXMA MG5460 | `bjc-PIXMA-MG5460` | EXPERIMENTAL |
| Canon PIXMA MG5470 | `bjc-PIXMA-MG5470` | EXPERIMENTAL |
| Canon PIXMA MG5480 | `bjc-PIXMA-MG5480` | EXPERIMENTAL |
| Canon PIXMA MG5510 | `bjc-PIXMA-MG5510` | EXPERIMENTAL |
| Canon PIXMA MG5520 | `bjc-PIXMA-MG5520` | EXPERIMENTAL |
| Canon PIXMA MG5522 | `bjc-PIXMA-MG5522` | EXPERIMENTAL |
| Canon PIXMA MG5540 | `bjc-PIXMA-MG5540` | EXPERIMENTAL |
| Canon PIXMA MG5550 | `bjc-PIXMA-MG5550` | EXPERIMENTAL |
| Canon PIXMA MG5560 | `bjc-PIXMA-MG5560` | EXPERIMENTAL |
| Canon PIXMA MG5570 | `bjc-PIXMA-MG5570` | EXPERIMENTAL |
| Canon PIXMA MG5580 | `bjc-PIXMA-MG5580` | EXPERIMENTAL |
| Canon PIXMA MG5610 | `bjc-PIXMA-MG5610` | EXPERIMENTAL |
| Canon PIXMA MG5620 | `bjc-PIXMA-MG5620` | EXPERIMENTAL |
| Canon PIXMA MG5622 | `bjc-PIXMA-MG5622` | EXPERIMENTAL |
| Canon PIXMA MG5640 | `bjc-PIXMA-MG5640` | EXPERIMENTAL |
| Canon PIXMA MG5650 | `bjc-PIXMA-MG5650` | EXPERIMENTAL |
| Canon PIXMA MG5660 | `bjc-PIXMA-MG5660` | EXPERIMENTAL |
| Canon PIXMA MG5670 | `bjc-PIXMA-MG5670` | EXPERIMENTAL |
| Canon PIXMA MG5680 | `bjc-PIXMA-MG5680` | EXPERIMENTAL |
| Canon PIXMA MG5710 | `bjc-PIXMA-MG5710` | EXPERIMENTAL |
| Canon PIXMA MG5720 | `bjc-PIXMA-MG5720` | EXPERIMENTAL |
| Canon PIXMA MG5721 | `bjc-PIXMA-MG5721` | EXPERIMENTAL |
| Canon PIXMA MG5722 | `bjc-PIXMA-MG5722` | EXPERIMENTAL |
| Canon PIXMA MG5740 | `bjc-PIXMA-MG5740` | EXPERIMENTAL |
| Canon PIXMA MG5750 | `bjc-PIXMA-MG5750` | EXPERIMENTAL |
| Canon PIXMA MG5751 | `bjc-PIXMA-MG5751` | EXPERIMENTAL |
| Canon PIXMA MG5752 | `bjc-PIXMA-MG5752` | EXPERIMENTAL |
| Canon PIXMA MG5753 | `bjc-PIXMA-MG5753` | EXPERIMENTAL |
| Canon PIXMA MG5770 | `bjc-PIXMA-MG5770` | EXPERIMENTAL |
| Canon PIXMA MG5780 | `bjc-PIXMA-MG5780` | EXPERIMENTAL |
| Canon PIXMA MG5790 | `bjc-PIXMA-MG5790` | EXPERIMENTAL |
| Canon PIXMA MG5795 | `bjc-PIXMA-MG5795` | EXPERIMENTAL |
| Canon PIXMA MG6100 | `bjc-PIXMA-MG6100` | EXPERIMENTAL |
| Canon PIXMA MG6110 | `bjc-PIXMA-MG6110` | EXPERIMENTAL |
| Canon PIXMA MG6120 | `bjc-PIXMA-MG6120` | EXPERIMENTAL |
| Canon PIXMA MG6140 | `bjc-PIXMA-MG6140` | EXPERIMENTAL |
| Canon PIXMA MG6150 | `bjc-PIXMA-MG6150` | EXPERIMENTAL |
| Canon PIXMA MG6170 | `bjc-PIXMA-MG6170` | EXPERIMENTAL |
| Canon PIXMA MG6180 | `bjc-PIXMA-MG6180` | EXPERIMENTAL |
| Canon PIXMA MG6200 | `bjc-PIXMA-MG6200` | EXPERIMENTAL |
| Canon PIXMA MG6210 | `bjc-PIXMA-MG6210` | EXPERIMENTAL |
| Canon PIXMA MG6220 | `bjc-PIXMA-MG6220` | EXPERIMENTAL |
| Canon PIXMA MG6240 | `bjc-PIXMA-MG6240` | EXPERIMENTAL |
| Canon PIXMA MG6250 | `bjc-PIXMA-MG6250` | EXPERIMENTAL |
| Canon PIXMA MG6270 | `bjc-PIXMA-MG6270` | EXPERIMENTAL |
| Canon PIXMA MG6280 | `bjc-PIXMA-MG6280` | EXPERIMENTAL |
| Canon PIXMA MG6310 | `bjc-PIXMA-MG6310` | EXPERIMENTAL |
| Canon PIXMA MG6320 | `bjc-PIXMA-MG6320` | EXPERIMENTAL |
| Canon PIXMA MG6340 | `bjc-PIXMA-MG6340` | EXPERIMENTAL |
| Canon PIXMA MG6350 | `bjc-PIXMA-MG6350` | EXPERIMENTAL |
| Canon PIXMA MG6360 | `bjc-PIXMA-MG6360` | EXPERIMENTAL |
| Canon PIXMA MG6370 | `bjc-PIXMA-MG6370` | EXPERIMENTAL |
| Canon PIXMA MG6380 | `bjc-PIXMA-MG6380` | EXPERIMENTAL |
| Canon PIXMA MG6400 | `bjc-PIXMA-MG6400` | EXPERIMENTAL |
| Canon PIXMA MG6410 | `bjc-PIXMA-MG6410` | EXPERIMENTAL |
| Canon PIXMA MG6420 | `bjc-PIXMA-MG6420` | EXPERIMENTAL |
| Canon PIXMA MG6440 | `bjc-PIXMA-MG6440` | EXPERIMENTAL |
| Canon PIXMA MG6450 | `bjc-PIXMA-MG6450` | EXPERIMENTAL |
| Canon PIXMA MG6470 | `bjc-PIXMA-MG6470` | EXPERIMENTAL |
| Canon PIXMA MG6610 | `bjc-PIXMA-MG6610` | EXPERIMENTAL |
| Canon PIXMA MG6620 | `bjc-PIXMA-MG6620` | EXPERIMENTAL |
| Canon PIXMA MG6622 | `bjc-PIXMA-MG6622` | EXPERIMENTAL |
| Canon PIXMA MG6640 | `bjc-PIXMA-MG6640` | EXPERIMENTAL |
| Canon PIXMA MG6650 | `bjc-PIXMA-MG6650` | EXPERIMENTAL |
| Canon PIXMA MG6660 | `bjc-PIXMA-MG6660` | EXPERIMENTAL |
| Canon PIXMA MG6670 | `bjc-PIXMA-MG6670` | EXPERIMENTAL |
| Canon PIXMA MG6680 | `bjc-PIXMA-MG6680` | EXPERIMENTAL |
| Canon PIXMA MG6810 | `bjc-PIXMA-MG6810` | EXPERIMENTAL |
| Canon PIXMA MG6820 | `bjc-PIXMA-MG6820` | EXPERIMENTAL |
| Canon PIXMA MG6821 | `bjc-PIXMA-MG6821` | EXPERIMENTAL |
| Canon PIXMA MG6822 | `bjc-PIXMA-MG6822` | EXPERIMENTAL |
| Canon PIXMA MG6840 | `bjc-PIXMA-MG6840` | EXPERIMENTAL |
| Canon PIXMA MG6850 | `bjc-PIXMA-MG6850` | EXPERIMENTAL |
| Canon PIXMA MG6851 | `bjc-PIXMA-MG6851` | EXPERIMENTAL |
| Canon PIXMA MG6852 | `bjc-PIXMA-MG6852` | EXPERIMENTAL |
| Canon PIXMA MG6853 | `bjc-PIXMA-MG6853` | EXPERIMENTAL |
| Canon PIXMA MG6870 | `bjc-PIXMA-MG6870` | EXPERIMENTAL |
| Canon PIXMA MG6880 | `bjc-PIXMA-MG6880` | EXPERIMENTAL |
| Canon PIXMA MG7110 | `bjc-PIXMA-MG7110` | EXPERIMENTAL |
| Canon PIXMA MG7120 | `bjc-PIXMA-MG7120` | EXPERIMENTAL |
| Canon PIXMA MG7140 | `bjc-PIXMA-MG7140` | EXPERIMENTAL |
| Canon PIXMA MG7150 | `bjc-PIXMA-MG7150` | EXPERIMENTAL |
| Canon PIXMA MG7170 | `bjc-PIXMA-MG7170` | EXPERIMENTAL |
| Canon PIXMA MG7180 | `bjc-PIXMA-MG7180` | EXPERIMENTAL |
| Canon PIXMA MG7510 | `bjc-PIXMA-MG7510` | EXPERIMENTAL |
| Canon PIXMA MG7520 | `bjc-PIXMA-MG7520` | EXPERIMENTAL |
| Canon PIXMA MG7540 | `bjc-PIXMA-MG7540` | EXPERIMENTAL |
| Canon PIXMA MG7550 | `bjc-PIXMA-MG7550` | EXPERIMENTAL |
| Canon PIXMA MG7560 | `bjc-PIXMA-MG7560` | EXPERIMENTAL |
| Canon PIXMA MG7570 | `bjc-PIXMA-MG7570` | EXPERIMENTAL |
| Canon PIXMA MG7580 | `bjc-PIXMA-MG7580` | EXPERIMENTAL |
| Canon PIXMA MG7710 | `bjc-PIXMA-MG7710` | EXPERIMENTAL |
| Canon PIXMA MG7720 | `bjc-PIXMA-MG7720` | EXPERIMENTAL |
| Canon PIXMA MG7740 | `bjc-PIXMA-MG7740` | EXPERIMENTAL |
| Canon PIXMA MG7750 | `bjc-PIXMA-MG7750` | EXPERIMENTAL |
| Canon PIXMA MG7751 | `bjc-PIXMA-MG7751` | EXPERIMENTAL |
| Canon PIXMA MG7752 | `bjc-PIXMA-MG7752` | EXPERIMENTAL |
| Canon PIXMA MG7753 | `bjc-PIXMA-MG7753` | EXPERIMENTAL |
| Canon PIXMA MG7770 | `bjc-PIXMA-MG7770` | EXPERIMENTAL |
| Canon PIXMA MG7780 | `bjc-PIXMA-MG7780` | EXPERIMENTAL |
| Canon PIXMA MG7790 | `bjc-PIXMA-MG7790` | EXPERIMENTAL |
| Canon PIXMA MG8100 | `bjc-PIXMA-MG8100` | EXPERIMENTAL |
| Canon PIXMA MG8120 | `bjc-PIXMA-MG8120` | EXPERIMENTAL |
| Canon PIXMA MG8120B | `bjc-PIXMA-MG8120B` | EXPERIMENTAL |
| Canon PIXMA MG8140 | `bjc-PIXMA-MG8140` | EXPERIMENTAL |
| Canon PIXMA MG8150 | `bjc-PIXMA-MG8150` | EXPERIMENTAL |
| Canon PIXMA MG8170 | `bjc-PIXMA-MG8170` | EXPERIMENTAL |
| Canon PIXMA MG8180 | `bjc-PIXMA-MG8180` | EXPERIMENTAL |
| Canon PIXMA MG8200 | `bjc-PIXMA-MG8200` | EXPERIMENTAL |
| Canon PIXMA MG8220 | `bjc-PIXMA-MG8220` | EXPERIMENTAL |
| Canon PIXMA MG8240 | `bjc-PIXMA-MG8240` | EXPERIMENTAL |
| Canon PIXMA MG8250 | `bjc-PIXMA-MG8250` | EXPERIMENTAL |
| Canon PIXMA MG8270 | `bjc-PIXMA-MG8270` | EXPERIMENTAL |
| Canon PIXMA MG8280 | `bjc-PIXMA-MG8280` | EXPERIMENTAL |
| Canon PIXMA mini220 | `bjc-PIXMA-mini220` |  |
| Canon PIXMA mini320 | `bjc-PIXMA-mini320` |  |
| Canon PIXMA mini360 | `bjc-PIXMA-mini360` |  |
| Canon PIXMA MP140 | `bjc-MULTIPASS-MP140` | EXPERIMENTAL |
| Canon PIXMA MP145 | `bjc-PIXMA-MP145` | EXPERIMENTAL |
| Canon PIXMA MP150 | `bjc-MULTIPASS-MP150` | EXPERIMENTAL |
| Canon PIXMA MP160 | `bjc-MULTIPASS-MP160` | EXPERIMENTAL |
| Canon PIXMA MP170 | `bjc-MULTIPASS-MP170` | EXPERIMENTAL |
| Canon PIXMA MP180 | `bjc-MULTIPASS-MP180` | EXPERIMENTAL |
| Canon PIXMA MP190 | `bjc-MULTIPASS-MP190` | EXPERIMENTAL |
| Canon PIXMA MP198 | `bjc-PIXMA-MP198` | EXPERIMENTAL |
| Canon PIXMA MP210 | `bjc-MULTIPASS-MP210` | EXPERIMENTAL |
| Canon PIXMA MP218 | `bjc-PIXMA-MP218` | EXPERIMENTAL |
| Canon PIXMA MP220 | `bjc-MULTIPASS-MP220` | EXPERIMENTAL |
| Canon PIXMA MP228 | `bjc-PIXMA-MP228` | EXPERIMENTAL |
| Canon PIXMA MP230 | `bjc-MULTIPASS-MP230` |  |
| Canon PIXMA MP236 | `bjc-PIXMA-MP236` |  |
| Canon PIXMA MP237 | `bjc-PIXMA-MP237` |  |
| Canon PIXMA MP240 | `bjc-MULTIPASS-MP240` | EXPERIMENTAL |
| Canon PIXMA MP245 | `bjc-PIXMA-MP245` | EXPERIMENTAL |
| Canon PIXMA MP250 | `bjc-MULTIPASS-MP250` | EXPERIMENTAL |
| Canon PIXMA MP252 | `bjc-PIXMA-MP252` | EXPERIMENTAL |
| Canon PIXMA MP258 | `bjc-PIXMA-MP258` | EXPERIMENTAL |
| Canon PIXMA MP259 | `bjc-PIXMA-MP259` | EXPERIMENTAL |
| Canon PIXMA MP260 | `bjc-MULTIPASS-MP260` | EXPERIMENTAL |
| Canon PIXMA MP268 | `bjc-PIXMA-MP268` | EXPERIMENTAL |
| Canon PIXMA MP270 | `bjc-MULTIPASS-MP270` | EXPERIMENTAL |
| Canon PIXMA MP272 | `bjc-PIXMA-MP272` | EXPERIMENTAL |
| Canon PIXMA MP276 | `bjc-PIXMA-MP276` | EXPERIMENTAL |
| Canon PIXMA MP280 | `bjc-MULTIPASS-MP280` | EXPERIMENTAL |
| Canon PIXMA MP282 | `bjc-PIXMA-MP282` | EXPERIMENTAL |
| Canon PIXMA MP287 | `bjc-PIXMA-MP287` | EXPERIMENTAL |
| Canon PIXMA MP288 | `bjc-PIXMA-MP288` | EXPERIMENTAL |
| Canon PIXMA MP360 | `bjc-PIXMA-MP360` | EXPERIMENTAL |
| Canon PIXMA MP370 | `bjc-PIXMA-MP370` | EXPERIMENTAL |
| Canon PIXMA MP375R | `bjc-MULTIPASS-MP375R` | EXPERIMENTAL |
| Canon PIXMA MP390 | `bjc-PIXMA-MP390` | EXPERIMENTAL |
| Canon PIXMA MP450 | `bjc-MULTIPASS-MP450` | EXPERIMENTAL |
| Canon PIXMA MP460 | `bjc-MULTIPASS-MP460` | EXPERIMENTAL |
| Canon PIXMA MP470 | `bjc-MULTIPASS-MP470` | EXPERIMENTAL |
| Canon PIXMA MP476 | `bjc-PIXMA-MP476` | EXPERIMENTAL |
| Canon PIXMA MP480 | `bjc-MULTIPASS-MP480` | EXPERIMENTAL |
| Canon PIXMA MP486 | `bjc-PIXMA-MP486` | EXPERIMENTAL |
| Canon PIXMA MP490 | `bjc-MULTIPASS-MP490` | EXPERIMENTAL |
| Canon PIXMA MP492 | `bjc-PIXMA-MP492` | EXPERIMENTAL |
| Canon PIXMA MP493 | `bjc-MULTIPASS-MP493` | EXPERIMENTAL |
| Canon PIXMA MP495 | `bjc-MULTIPASS-MP495` | EXPERIMENTAL |
| Canon PIXMA MP496 | `bjc-PIXMA-MP496` | EXPERIMENTAL |
| Canon PIXMA MP497 | `bjc-PIXMA-MP497` | EXPERIMENTAL |
| Canon PIXMA MP498 | `bjc-PIXMA-MP498` | EXPERIMENTAL |
| Canon PIXMA MP499 | `bjc-PIXMA-MP499` | EXPERIMENTAL |
| Canon PIXMA MP500 | `bjc-MULTIPASS-MP500` | EXPERIMENTAL |
| Canon PIXMA MP510 | `bjc-MULTIPASS-MP510` | EXPERIMENTAL |
| Canon PIXMA MP520 | `bjc-MULTIPASS-MP520` | EXPERIMENTAL |
| Canon PIXMA MP530 | `bjc-MULTIPASS-MP530` | EXPERIMENTAL |
| Canon PIXMA MP540 | `bjc-MULTIPASS-MP540` | EXPERIMENTAL |
| Canon PIXMA MP545 | `bjc-PIXMA-MP545` | EXPERIMENTAL |
| Canon PIXMA MP550 | `bjc-MULTIPASS-MP550` | EXPERIMENTAL |
| Canon PIXMA MP558 | `bjc-PIXMA-MP558` | EXPERIMENTAL |
| Canon PIXMA MP560 | `bjc-MULTIPASS-MP560` | EXPERIMENTAL |
| Canon PIXMA MP568 | `bjc-PIXMA-MP568` | EXPERIMENTAL |
| Canon PIXMA MP600 | `bjc-MULTIPASS-MP600` | EXPERIMENTAL |
| Canon PIXMA MP600R | `bjc-MULTIPASS-MP600R` | EXPERIMENTAL |
| Canon PIXMA MP610 | `bjc-MULTIPASS-MP610` | EXPERIMENTAL |
| Canon PIXMA MP620 | `bjc-MULTIPASS-MP620` | EXPERIMENTAL |
| Canon PIXMA MP620B | `bjc-PIXMA-MP620B` | EXPERIMENTAL |
| Canon PIXMA MP628 | `bjc-PIXMA-MP628` | EXPERIMENTAL |
| Canon PIXMA MP630 | `bjc-MULTIPASS-MP630` | EXPERIMENTAL |
| Canon PIXMA MP638 | `bjc-PIXMA-MP638` | EXPERIMENTAL |
| Canon PIXMA MP640 | `bjc-MULTIPASS-MP640` | EXPERIMENTAL |
| Canon PIXMA MP640R | `bjc-PIXMA-MP640R` | EXPERIMENTAL |
| Canon PIXMA MP648 | `bjc-PIXMA-MP648` | EXPERIMENTAL |
| Canon PIXMA MP700 | `bjc-PIXMA-MP700` | EXPERIMENTAL |
| Canon PIXMA MP710 | `bjc-MULTIPASS-MP710` | EXPERIMENTAL |
| Canon PIXMA MP730 | `bjc-PIXMA-MP730` | EXPERIMENTAL |
| Canon PIXMA MP740 | `bjc-MULTIPASS-MP740` | EXPERIMENTAL |
| Canon PIXMA MP750 | `bjc-MULTIPASS-MP750` | EXPERIMENTAL |
| Canon PIXMA MP760 | `bjc-MULTIPASS-MP760` | EXPERIMENTAL |
| Canon PIXMA MP770 | `bjc-MULTIPASS-MP770` | EXPERIMENTAL |
| Canon PIXMA MP780 | `bjc-MULTIPASS-MP780` | EXPERIMENTAL |
| Canon PIXMA MP790 | `bjc-MULTIPASS-MP790` | EXPERIMENTAL |
| Canon PIXMA MP800 | `bjc-MULTIPASS-MP800` | EXPERIMENTAL |
| Canon PIXMA MP800R | `bjc-MULTIPASS-MP800R` | EXPERIMENTAL |
| Canon PIXMA MP810 | `bjc-MULTIPASS-MP810` | EXPERIMENTAL |
| Canon PIXMA MP830 | `bjc-MULTIPASS-MP830` | EXPERIMENTAL |
| Canon PIXMA MP900 | `bjc-MULTIPASS-MP900` | EXPERIMENTAL |
| Canon PIXMA MP950 | `bjc-MULTIPASS-MP950` | EXPERIMENTAL |
| Canon PIXMA MP960 | `bjc-MULTIPASS-MP960` | EXPERIMENTAL |
| Canon PIXMA MP970 | `bjc-MULTIPASS-MP970` | EXPERIMENTAL |
| Canon PIXMA MP980 | `bjc-MULTIPASS-MP980` | EXPERIMENTAL |
| Canon PIXMA MP988 | `bjc-PIXMA-MP988` | EXPERIMENTAL |
| Canon PIXMA MP990 | `bjc-MULTIPASS-MP990` | EXPERIMENTAL |
| Canon PIXMA MP996 | `bjc-PIXMA-MP996` | EXPERIMENTAL |
| Canon PIXMA MX300 | `bjc-MULTIPASS-MX300` | EXPERIMENTAL |
| Canon PIXMA MX308 | `bjc-PIXMA-MX308` | EXPERIMENTAL |
| Canon PIXMA MX310 | `bjc-MULTIPASS-MX310` | EXPERIMENTAL |
| Canon PIXMA MX318 | `bjc-PIXMA-MX318` | EXPERIMENTAL |
| Canon PIXMA MX320 | `bjc-MULTIPASS-MX320` | EXPERIMENTAL |
| Canon PIXMA MX328 | `bjc-PIXMA-MX328` | EXPERIMENTAL |
| Canon PIXMA MX330 | `bjc-MULTIPASS-MX330` | EXPERIMENTAL |
| Canon PIXMA MX338 | `bjc-PIXMA-MX338` | EXPERIMENTAL |
| Canon PIXMA MX340 | `bjc-MULTIPASS-MX340` | EXPERIMENTAL |
| Canon PIXMA MX347 | `bjc-PIXMA-MX347` | EXPERIMENTAL |
| Canon PIXMA MX348 | `bjc-PIXMA-MX348` | EXPERIMENTAL |
| Canon PIXMA MX350 | `bjc-MULTIPASS-MX350` | EXPERIMENTAL |
| Canon PIXMA MX357 | `bjc-PIXMA-MX357` | EXPERIMENTAL |
| Canon PIXMA MX358 | `bjc-PIXMA-MX358` | EXPERIMENTAL |
| Canon PIXMA MX360 | `bjc-MULTIPASS-MX360` | EXPERIMENTAL |
| Canon PIXMA MX366 | `bjc-PIXMA-MX366` | EXPERIMENTAL |
| Canon PIXMA MX368 | `bjc-PIXMA-MX368` | EXPERIMENTAL |
| Canon PIXMA MX370 | `bjc-MULTIPASS-MX370` | EXPERIMENTAL |
| Canon PIXMA MX371 | `bjc-PIXMA-MX371` | EXPERIMENTAL |
| Canon PIXMA MX372 | `bjc-PIXMA-MX372` | EXPERIMENTAL |
| Canon PIXMA MX374 | `bjc-PIXMA-MX374` | EXPERIMENTAL |
| Canon PIXMA MX375 | `bjc-PIXMA-MX375` | EXPERIMENTAL |
| Canon PIXMA MX376 | `bjc-PIXMA-MX376` | EXPERIMENTAL |
| Canon PIXMA MX377 | `bjc-PIXMA-MX377` | EXPERIMENTAL |
| Canon PIXMA MX378 | `bjc-PIXMA-MX378` | EXPERIMENTAL |
| Canon PIXMA MX391 | `bjc-PIXMA-MX391` | EXPERIMENTAL |
| Canon PIXMA MX392 | `bjc-PIXMA-MX392` | EXPERIMENTAL |
| Canon PIXMA MX394 | `bjc-PIXMA-MX394` | EXPERIMENTAL |
| Canon PIXMA MX395 | `bjc-PIXMA-MX395` | EXPERIMENTAL |
| Canon PIXMA MX396 | `bjc-PIXMA-MX396` | EXPERIMENTAL |
| Canon PIXMA MX397 | `bjc-PIXMA-MX397` | EXPERIMENTAL |
| Canon PIXMA MX398 | `bjc-PIXMA-MX398` | EXPERIMENTAL |
| Canon PIXMA MX410 | `bjc-MULTIPASS-MX410` | EXPERIMENTAL |
| Canon PIXMA MX416 | `bjc-PIXMA-MX416` | EXPERIMENTAL |
| Canon PIXMA MX418 | `bjc-PIXMA-MX418` | EXPERIMENTAL |
| Canon PIXMA MX420 | `bjc-MULTIPASS-MX420` | EXPERIMENTAL |
| Canon PIXMA MX426 | `bjc-PIXMA-MX426` | EXPERIMENTAL |
| Canon PIXMA MX428 | `bjc-PIXMA-MX428` | EXPERIMENTAL |
| Canon PIXMA MX430 | `bjc-MULTIPASS-MX430` | EXPERIMENTAL |
| Canon PIXMA MX431 | `bjc-PIXMA-MX431` | EXPERIMENTAL |
| Canon PIXMA MX432 | `bjc-PIXMA-MX432` | EXPERIMENTAL |
| Canon PIXMA MX434 | `bjc-PIXMA-MX434` | EXPERIMENTAL |
| Canon PIXMA MX435 | `bjc-PIXMA-MX435` | EXPERIMENTAL |
| Canon PIXMA MX436 | `bjc-PIXMA-MX436` | EXPERIMENTAL |
| Canon PIXMA MX437 | `bjc-PIXMA-MX437` | EXPERIMENTAL |
| Canon PIXMA MX438 | `bjc-PIXMA-MX438` | EXPERIMENTAL |
| Canon PIXMA MX439 | `bjc-PIXMA-MX439` | EXPERIMENTAL |
| Canon PIXMA MX451 | `bjc-PIXMA-MX451` | EXPERIMENTAL |
| Canon PIXMA MX452 | `bjc-PIXMA-MX452` | EXPERIMENTAL |
| Canon PIXMA MX454 | `bjc-PIXMA-MX454` | EXPERIMENTAL |
| Canon PIXMA MX455 | `bjc-PIXMA-MX455` | EXPERIMENTAL |
| Canon PIXMA MX456 | `bjc-PIXMA-MX456` | EXPERIMENTAL |
| Canon PIXMA MX457 | `bjc-PIXMA-MX457` | EXPERIMENTAL |
| Canon PIXMA MX458 | `bjc-PIXMA-MX458` | EXPERIMENTAL |
| Canon PIXMA MX459 | `bjc-PIXMA-MX459` | EXPERIMENTAL |
| Canon PIXMA MX471 | `bjc-PIXMA-MX471` | EXPERIMENTAL |
| Canon PIXMA MX472 | `bjc-PIXMA-MX472` | EXPERIMENTAL |
| Canon PIXMA MX474 | `bjc-PIXMA-MX474` | EXPERIMENTAL |
| Canon PIXMA MX475 | `bjc-PIXMA-MX475` | EXPERIMENTAL |
| Canon PIXMA MX476 | `bjc-PIXMA-MX476` | EXPERIMENTAL |
| Canon PIXMA MX477 | `bjc-PIXMA-MX477` | EXPERIMENTAL |
| Canon PIXMA MX478 | `bjc-PIXMA-MX478` | EXPERIMENTAL |
| Canon PIXMA MX479 | `bjc-PIXMA-MX479` | EXPERIMENTAL |
| Canon PIXMA MX490 | `bjc-PIXMA-MX490` | EXPERIMENTAL |
| Canon PIXMA MX492 | `bjc-PIXMA-MX492` | EXPERIMENTAL |
| Canon PIXMA MX494 | `bjc-PIXMA-MX494` | EXPERIMENTAL |
| Canon PIXMA MX495 | `bjc-PIXMA-MX495` | EXPERIMENTAL |
| Canon PIXMA MX496 | `bjc-PIXMA-MX496` | EXPERIMENTAL |
| Canon PIXMA MX497 | `bjc-PIXMA-MX497` | EXPERIMENTAL |
| Canon PIXMA MX498 | `bjc-PIXMA-MX498` | EXPERIMENTAL |
| Canon PIXMA MX499 | `bjc-PIXMA-MX499` | EXPERIMENTAL |
| Canon PIXMA MX510 | `bjc-MULTIPASS-MX510` | EXPERIMENTAL |
| Canon PIXMA MX511 | `bjc-PIXMA-MX511` | EXPERIMENTAL |
| Canon PIXMA MX512 | `bjc-PIXMA-MX512` | EXPERIMENTAL |
| Canon PIXMA MX514 | `bjc-PIXMA-MX514` | EXPERIMENTAL |
| Canon PIXMA MX515 | `bjc-PIXMA-MX515` | EXPERIMENTAL |
| Canon PIXMA MX516 | `bjc-PIXMA-MX516` | EXPERIMENTAL |
| Canon PIXMA MX517 | `bjc-PIXMA-MX517` | EXPERIMENTAL |
| Canon PIXMA MX518 | `bjc-PIXMA-MX518` | EXPERIMENTAL |
| Canon PIXMA MX521 | `bjc-PIXMA-MX521` | EXPERIMENTAL |
| Canon PIXMA MX522 | `bjc-PIXMA-MX522` | EXPERIMENTAL |
| Canon PIXMA MX524 | `bjc-PIXMA-MX524` | EXPERIMENTAL |
| Canon PIXMA MX525 | `bjc-PIXMA-MX525` | EXPERIMENTAL |
| Canon PIXMA MX526 | `bjc-PIXMA-MX526` | EXPERIMENTAL |
| Canon PIXMA MX527 | `bjc-PIXMA-MX527` | EXPERIMENTAL |
| Canon PIXMA MX528 | `bjc-PIXMA-MX528` | EXPERIMENTAL |
| Canon PIXMA MX531 | `bjc-PIXMA-MX531` | EXPERIMENTAL |
| Canon PIXMA MX532 | `bjc-PIXMA-MX532` | EXPERIMENTAL |
| Canon PIXMA MX534 | `bjc-PIXMA-MX534` | EXPERIMENTAL |
| Canon PIXMA MX535 | `bjc-PIXMA-MX535` | EXPERIMENTAL |
| Canon PIXMA MX536 | `bjc-PIXMA-MX536` | EXPERIMENTAL |
| Canon PIXMA MX537 | `bjc-PIXMA-MX537` | EXPERIMENTAL |
| Canon PIXMA MX538 | `bjc-PIXMA-MX538` | EXPERIMENTAL |
| Canon PIXMA MX700 | `bjc-MULTIPASS-MX700` | EXPERIMENTAL |
| Canon PIXMA MX710 | `bjc-MULTIPASS-MX710` | EXPERIMENTAL |
| Canon PIXMA MX711 | `bjc-PIXMA-MX711` | EXPERIMENTAL |
| Canon PIXMA MX712 | `bjc-PIXMA-MX712` | EXPERIMENTAL |
| Canon PIXMA MX714 | `bjc-PIXMA-MX714` | EXPERIMENTAL |
| Canon PIXMA MX715 | `bjc-PIXMA-MX715` | EXPERIMENTAL |
| Canon PIXMA MX721 | `bjc-PIXMA-MX721` | EXPERIMENTAL |
| Canon PIXMA MX722 | `bjc-PIXMA-MX722` | EXPERIMENTAL |
| Canon PIXMA MX725 | `bjc-PIXMA-MX725` | EXPERIMENTAL |
| Canon PIXMA MX726 | `bjc-PIXMA-MX726` | EXPERIMENTAL |
| Canon PIXMA MX727 | `bjc-PIXMA-MX727` | EXPERIMENTAL |
| Canon PIXMA MX728 | `bjc-PIXMA-MX728` | EXPERIMENTAL |
| Canon PIXMA MX7600 | `bjc-MULTIPASS-MX7600` | EXPERIMENTAL |
| Canon PIXMA MX850 | `bjc-MULTIPASS-MX850` | EXPERIMENTAL |
| Canon PIXMA MX860 | `bjc-MULTIPASS-MX860` | EXPERIMENTAL |
| Canon PIXMA MX868 | `bjc-PIXMA-MX868` | EXPERIMENTAL |
| Canon PIXMA MX870 | `bjc-MULTIPASS-MX870` | EXPERIMENTAL |
| Canon PIXMA MX876 | `bjc-PIXMA-MX876` | EXPERIMENTAL |
| Canon PIXMA MX880 | `bjc-MULTIPASS-MX880` | EXPERIMENTAL |
| Canon PIXMA MX882 | `bjc-PIXMA-MX882` | EXPERIMENTAL |
| Canon PIXMA MX884 | `bjc-PIXMA-MX884` | EXPERIMENTAL |
| Canon PIXMA MX885 | `bjc-PIXMA-MX885` | EXPERIMENTAL |
| Canon PIXMA MX886 | `bjc-PIXMA-MX886` | EXPERIMENTAL |
| Canon PIXMA MX888 | `bjc-PIXMA-MX888` | EXPERIMENTAL |
| Canon PIXMA MX890 | `bjc-MULTIPASS-MX890` | EXPERIMENTAL |
| Canon PIXMA MX892 | `bjc-PIXMA-MX892` | EXPERIMENTAL |
| Canon PIXMA MX894 | `bjc-PIXMA-MX894` | EXPERIMENTAL |
| Canon PIXMA MX895 | `bjc-PIXMA-MX895` | EXPERIMENTAL |
| Canon PIXMA MX897 | `bjc-PIXMA-MX897` | EXPERIMENTAL |
| Canon PIXMA MX898 | `bjc-PIXMA-MX898` | EXPERIMENTAL |
| Canon PIXMA MX922 | `bjc-PIXMA-MX922` | EXPERIMENTAL |
| Canon PIXMA MX924 | `bjc-PIXMA-MX924` | EXPERIMENTAL |
| Canon PIXMA MX925 | `bjc-PIXMA-MX925` | EXPERIMENTAL |
| Canon PIXMA MX926 | `bjc-PIXMA-MX926` | EXPERIMENTAL |
| Canon PIXMA MX927 | `bjc-PIXMA-MX927` | EXPERIMENTAL |
| Canon PIXMA MX928 | `bjc-PIXMA-MX928` | EXPERIMENTAL |
| Canon PIXMA P200 | `bjc-PIXMA-P200` | EXPERIMENTAL |
| Canon PIXMA Pro9000 | `bjc-PIXMA-Pro9000` | EXPERIMENTAL |
| Canon PIXMA Pro9000mk2 | `bjc-PIXMA-Pro9000mk2` | EXPERIMENTAL |
| Canon PIXMA Pro9500 | `bjc-PIXMA-Pro9500` | EXPERIMENTAL |
| Canon PIXMA Pro9500mk2 | `bjc-PIXMA-Pro9500mk2` | EXPERIMENTAL |
| Canon PIXMA TS3110 | `bjc-PIXMA-TS3110` | EXPERIMENTAL |
| Canon PIXMA TS3120 | `bjc-PIXMA-TS3120` | EXPERIMENTAL |
| Canon PIXMA TS3130 | `bjc-PIXMA-TS3130` | EXPERIMENTAL |
| Canon PIXMA TS3130S | `bjc-PIXMA-TS3130S` | EXPERIMENTAL |
| Canon PIXMA TS3140 | `bjc-PIXMA-TS3140` | EXPERIMENTAL |
| Canon PIXMA TS3150 | `bjc-PIXMA-TS3150` | EXPERIMENTAL |
| Canon PIXMA TS3160 | `bjc-PIXMA-TS3160` | EXPERIMENTAL |
| Canon PIXMA TS3170 | `bjc-PIXMA-TS3170` | EXPERIMENTAL |
| Canon PIXMA TS3190 | `bjc-PIXMA-TS3190` | EXPERIMENTAL |
| Canon PIXMA TS3195 | `bjc-PIXMA-TS3195` | EXPERIMENTAL |
| Canon PIXMA TS5010 | `bjc-PIXMA-TS5010` | EXPERIMENTAL |
| Canon PIXMA TS5020 | `bjc-PIXMA-TS5020` | EXPERIMENTAL |
| Canon PIXMA TS5030 | `bjc-PIXMA-TS5030` | EXPERIMENTAL |
| Canon PIXMA TS5030S | `bjc-PIXMA-TS5030S` | EXPERIMENTAL |
| Canon PIXMA TS5040 | `bjc-PIXMA-TS5040` | EXPERIMENTAL |
| Canon PIXMA TS5050 | `bjc-PIXMA-TS5050` | EXPERIMENTAL |
| Canon PIXMA TS5051 | `bjc-PIXMA-TS5051` | EXPERIMENTAL |
| Canon PIXMA TS5053 | `bjc-PIXMA-TS5053` | EXPERIMENTAL |
| Canon PIXMA TS5055 | `bjc-PIXMA-TS5055` | EXPERIMENTAL |
| Canon PIXMA TS5060 | `bjc-PIXMA-TS5060` | EXPERIMENTAL |
| Canon PIXMA TS5070 | `bjc-PIXMA-TS5070` | EXPERIMENTAL |
| Canon PIXMA TS5080 | `bjc-PIXMA-TS5080` | EXPERIMENTAL |
| Canon PIXMA TS5090 | `bjc-PIXMA-TS5090` | EXPERIMENTAL |
| Canon PIXMA TS6010 | `bjc-PIXMA-TS6010` | EXPERIMENTAL |
| Canon PIXMA TS6020 | `bjc-PIXMA-TS6020` | EXPERIMENTAL |
| Canon PIXMA TS6030 | `bjc-PIXMA-TS6030` | EXPERIMENTAL |
| Canon PIXMA TS6040 | `bjc-PIXMA-TS6040` | EXPERIMENTAL |
| Canon PIXMA TS6050 | `bjc-PIXMA-TS6050` | EXPERIMENTAL |
| Canon PIXMA TS6051 | `bjc-PIXMA-TS6051` | EXPERIMENTAL |
| Canon PIXMA TS6052 | `bjc-PIXMA-TS6052` | EXPERIMENTAL |
| Canon PIXMA TS6060 | `bjc-PIXMA-TS6060` | EXPERIMENTAL |
| Canon PIXMA TS6070 | `bjc-PIXMA-TS6070` | EXPERIMENTAL |
| Canon PIXMA TS6080 | `bjc-PIXMA-TS6080` | EXPERIMENTAL |
| Canon PIXMA TS8010 | `bjc-PIXMA-TS8010` | EXPERIMENTAL |
| Canon PIXMA TS8020 | `bjc-PIXMA-TS8020` | EXPERIMENTAL |
| Canon PIXMA TS8030 | `bjc-PIXMA-TS8030` | EXPERIMENTAL |
| Canon PIXMA TS8040 | `bjc-PIXMA-TS8040` | EXPERIMENTAL |
| Canon PIXMA TS8050 | `bjc-PIXMA-TS8050` | EXPERIMENTAL |
| Canon PIXMA TS8051 | `bjc-PIXMA-TS8051` | EXPERIMENTAL |
| Canon PIXMA TS8052 | `bjc-PIXMA-TS8052` | EXPERIMENTAL |
| Canon PIXMA TS8053 | `bjc-PIXMA-TS8053` | EXPERIMENTAL |
| Canon PIXMA TS8060 | `bjc-PIXMA-TS8060` | EXPERIMENTAL |
| Canon PIXMA TS8070 | `bjc-PIXMA-TS8070` | EXPERIMENTAL |
| Canon PIXMA TS8080 | `bjc-PIXMA-TS8080` | EXPERIMENTAL |
| Canon PIXMA TS8090 | `bjc-PIXMA-TS8090` | EXPERIMENTAL |
| Canon PIXMA TS9010 | `bjc-PIXMA-TS9010` | EXPERIMENTAL |
| Canon PIXMA TS9020 | `bjc-PIXMA-TS9020` | EXPERIMENTAL |
| Canon PIXMA TS9030 | `bjc-PIXMA-TS9030` | EXPERIMENTAL |
| Canon PIXMA TS9040 | `bjc-PIXMA-TS9040` | EXPERIMENTAL |
| Canon PIXMA TS9050 | `bjc-PIXMA-TS9050` | EXPERIMENTAL |
| Canon PIXMA TS9055 | `bjc-PIXMA-TS9055` | EXPERIMENTAL |
| Canon PIXMA TS9060 | `bjc-PIXMA-TS9060` | EXPERIMENTAL |
| Canon PIXMA TS9080 | `bjc-PIXMA-TS9080` | EXPERIMENTAL |
| Canon PIXUS 450i | `bjc-450i` |  |
| Canon PIXUS 455i | `bjc-455i` |  |
| Canon PIXUS 470PD | `bjc-470PD` |  |
| Canon PIXUS 475PD | `bjc-475PD` |  |
| Canon PIXUS 50i | `bjc-50i` |  |
| Canon PIXUS 550i | `bjc-550i` |  |
| Canon PIXUS 560i | `bjc-560i` |  |
| Canon PIXUS 6100i | `bjc-6100i` |  |
| Canon PIXUS 6500i | `bjc-6500i` |  |
| Canon PIXUS 80i | `bjc-80i` |  |
| Canon PIXUS 850i | `bjc-850i` |  |
| Canon PIXUS 860i | `bjc-860i` |  |
| Canon PIXUS 865R | `bjc-865R` |  |
| Canon PIXUS 900PD | `bjc-900PD` |  |
| Canon PIXUS 9100i | `bjc-9100i` |  |
| Canon PIXUS 950i | `bjc-950i` |  |
| Canon PIXUS 960i | `bjc-960i` |  |
| Canon PIXUS 9900i | `bjc-9900i` |  |
| Canon PIXUS 990i | `bjc-990i` |  |
| Canon PIXUS iP110 | `bjc-PIXUS-iP110` | EXPERIMENTAL |
| Canon PIXUS iP2000 | `bjc-PIXUS-iP2000` | EXPERIMENTAL |
| Canon PIXUS iP2700 | `bjc-PIXUS-iP2700` | EXPERIMENTAL |
| Canon PIXUS iP3100 | `bjc-PIXUS-iP3100` | EXPERIMENTAL |
| Canon PIXUS iP3300 | `bjc-PIXUS-iP3300` | EXPERIMENTAL |
| Canon PIXUS iP3500 | `bjc-PIXUS-iP3500` | EXPERIMENTAL |
| Canon PIXUS iP3600 | `bjc-PIXUS-iP3600` | EXPERIMENTAL |
| Canon PIXUS iP4100 | `bjc-PIXUS-iP4100` | EXPERIMENTAL |
| Canon PIXUS iP4100R | `bjc-PIXUS-iP4100R` | EXPERIMENTAL |
| Canon PIXUS iP4200 | `bjc-PIXUS-iP4200` | EXPERIMENTAL |
| Canon PIXUS iP4300 | `bjc-PIXUS-iP4300` | EXPERIMENTAL |
| Canon PIXUS iP4500 | `bjc-PIXUS-iP4500` | EXPERIMENTAL |
| Canon PIXUS iP4600 | `bjc-PIXUS-iP4600` | EXPERIMENTAL |
| Canon PIXUS iP4700 | `bjc-PIXUS-iP4700` | EXPERIMENTAL |
| Canon PIXUS iP4830 | `bjc-PIXUS-iP4830` | EXPERIMENTAL |
| Canon PIXUS iP4930 | `bjc-PIXUS-iP4930` | EXPERIMENTAL |
| Canon PIXUS iP5200R | `bjc-PIXUS-iP5200R` | EXPERIMENTAL |
| Canon PIXUS iP6100D | `bjc-PIXUS-iP6100D` | EXPERIMENTAL |
| Canon PIXUS iP6600D | `bjc-PIXUS-iP6600D` | EXPERIMENTAL |
| Canon PIXUS iP6700D | `bjc-PIXUS-iP6700` | EXPERIMENTAL |
| Canon PIXUS iP7100 | `bjc-PIXUS-iP7100` | EXPERIMENTAL |
| Canon PIXUS iP7230 | `bjc-PIXUS-iP7230` | EXPERIMENTAL |
| Canon PIXUS iP7500 | `bjc-PIXUS-iP7500` | EXPERIMENTAL |
| Canon PIXUS iP8100 | `bjc-PIXUS-iP8100` | EXPERIMENTAL |
| Canon PIXUS iP8600 | `bjc-PIXUS-iP8600` | EXPERIMENTAL |
| Canon PIXUS iP8730 | `bjc-PIXUS-iP8730` | EXPERIMENTAL |
| Canon PIXUS iP90 | `bjc-PIXUS-iP90` |  |
| Canon PIXUS iP90v | `bjc-PIXUS-iP90v` |  |
| Canon PIXUS iP9910 | `bjc-PIXUS-iP9910` | EXPERIMENTAL |
| Canon PIXUS iX5000 | `bjc-PIXUS-iX5000` | EXPERIMENTAL |
| Canon PIXUS iX6530 | `bjc-PIXUS-iX6530` | EXPERIMENTAL |
| Canon PIXUS iX6830 | `bjc-PIXUS-iX6830` | EXPERIMENTAL |
| Canon PIXUS iX7000 | `bjc-PIXUS-iX7000` | EXPERIMENTAL |
| Canon PIXUS MG2130 | `bjc-PIXUS-MG2130` | EXPERIMENTAL |
| Canon PIXUS MG3130 | `bjc-PIXUS-MG3130` | EXPERIMENTAL |
| Canon PIXUS MG3230 | `bjc-PIXUS-MG3230` | EXPERIMENTAL |
| Canon PIXUS MG3530 | `bjc-PIXUS-MG3530` | EXPERIMENTAL |
| Canon PIXUS MG3630 | `bjc-PIXUS-MG3630` | EXPERIMENTAL |
| Canon PIXUS MG4130 | `bjc-PIXUS-MG4130` | EXPERIMENTAL |
| Canon PIXUS MG4230 | `bjc-PIXUS-MG4230` | EXPERIMENTAL |
| Canon PIXUS MG5130 | `bjc-PIXUS-MG5130` | EXPERIMENTAL |
| Canon PIXUS MG5230 | `bjc-PIXUS-MG5230` | EXPERIMENTAL |
| Canon PIXUS MG5330 | `bjc-PIXUS-MG5330` | EXPERIMENTAL |
| Canon PIXUS MG5430 | `bjc-PIXUS-MG5430` | EXPERIMENTAL |
| Canon PIXUS MG5530 | `bjc-PIXUS-MG5530` | EXPERIMENTAL |
| Canon PIXUS MG5630 | `bjc-PIXUS-MG5630` | EXPERIMENTAL |
| Canon PIXUS MG5730 | `bjc-PIXUS-MG5730` | EXPERIMENTAL |
| Canon PIXUS MG6130 | `bjc-PIXUS-MG6130` | EXPERIMENTAL |
| Canon PIXUS MG6230 | `bjc-PIXUS-MG6230` | EXPERIMENTAL |
| Canon PIXUS MG6330 | `bjc-PIXUS-MG6330` | EXPERIMENTAL |
| Canon PIXUS MG6530 | `bjc-PIXUS-MG6530` | EXPERIMENTAL |
| Canon PIXUS MG6730 | `bjc-PIXUS-MG6730` | EXPERIMENTAL |
| Canon PIXUS MG6930 | `bjc-PIXUS-MG6930` | EXPERIMENTAL |
| Canon PIXUS MG7130 | `bjc-PIXUS-MG7130` | EXPERIMENTAL |
| Canon PIXUS MG7530 | `bjc-PIXUS-MG7530` | EXPERIMENTAL |
| Canon PIXUS MG7530F | `bjc-PIXUS-MG7530F` | EXPERIMENTAL |
| Canon PIXUS MG7730 | `bjc-PIXUS-MG7730` | EXPERIMENTAL |
| Canon PIXUS MG7730F | `bjc-PIXUS-MG7730F` | EXPERIMENTAL |
| Canon PIXUS MG8130 | `bjc-PIXUS-MG8130` | EXPERIMENTAL |
| Canon PIXUS MG8230 | `bjc-PIXUS-MG8230` | EXPERIMENTAL |
| Canon PIXUS mini220 | `bjc-PIXUS-mini220` |  |
| Canon PIXUS mini360 | `bjc-PIXUS-mini360` |  |
| Canon PIXUS MP170 | `bjc-PIXUS-MP170` | EXPERIMENTAL |
| Canon PIXUS MP270 | `bjc-PIXUS-MP270` | EXPERIMENTAL |
| Canon PIXUS MP280 | `bjc-PIXUS-MP280` | EXPERIMENTAL |
| Canon PIXUS MP360 | `bjc-PIXUS-MP360` | EXPERIMENTAL |
| Canon PIXUS MP370 | `bjc-PIXUS-MP370` | EXPERIMENTAL |
| Canon PIXUS MP375R | `bjc-PIXUS-MP375R` | EXPERIMENTAL |
| Canon PIXUS MP390 | `bjc-PIXUS-MP390` | EXPERIMENTAL |
| Canon PIXUS MP450 | `bjc-PIXUS-MP450` | EXPERIMENTAL |
| Canon PIXUS MP460 | `bjc-PIXUS-MP460` | EXPERIMENTAL |
| Canon PIXUS MP470 | `bjc-PIXUS-MP470` | EXPERIMENTAL |
| Canon PIXUS MP480 | `bjc-PIXUS-MP480` | EXPERIMENTAL |
| Canon PIXUS MP490 | `bjc-PIXUS-MP490` | EXPERIMENTAL |
| Canon PIXUS MP493 | `bjc-PIXUS-MP493` | EXPERIMENTAL |
| Canon PIXUS MP500 | `bjc-PIXUS-MP500` | EXPERIMENTAL |
| Canon PIXUS MP510 | `bjc-PIXUS-MP510` | EXPERIMENTAL |
| Canon PIXUS MP520 | `bjc-PIXUS-MP520` | EXPERIMENTAL |
| Canon PIXUS MP540 | `bjc-PIXUS-MP540` | EXPERIMENTAL |
| Canon PIXUS MP55 | `bjc-PIXUS-MP55` | EXPERIMENTAL |
| Canon PIXUS MP550 | `bjc-PIXUS-MP550` | EXPERIMENTAL |
| Canon PIXUS MP560 | `bjc-PIXUS-MP560` | EXPERIMENTAL |
| Canon PIXUS MP600 | `bjc-PIXUS-MP600` | EXPERIMENTAL |
| Canon PIXUS MP610 | `bjc-PIXUS-MP610` | EXPERIMENTAL |
| Canon PIXUS MP620 | `bjc-PIXUS-MP620` | EXPERIMENTAL |
| Canon PIXUS MP630 | `bjc-PIXUS-MP630` | EXPERIMENTAL |
| Canon PIXUS MP640 | `bjc-PIXUS-MP640` | EXPERIMENTAL |
| Canon PIXUS MP700 | `bjc-PIXUS-MP700` | EXPERIMENTAL |
| Canon PIXUS MP710 | `bjc-PIXUS-MP710` | EXPERIMENTAL |
| Canon PIXUS MP730 | `bjc-PIXUS-MP730` | EXPERIMENTAL |
| Canon PIXUS MP740 | `bjc-PIXUS-MP740` | EXPERIMENTAL |
| Canon PIXUS MP770 | `bjc-PIXUS-MP770` | EXPERIMENTAL |
| Canon PIXUS MP790 | `bjc-PIXUS-MP790` | EXPERIMENTAL |
| Canon PIXUS MP800 | `bjc-PIXUS-MP800` | EXPERIMENTAL |
| Canon PIXUS MP810 | `bjc-PIXUS-MP810` | EXPERIMENTAL |
| Canon PIXUS MP830 | `bjc-PIXUS-MP830` | EXPERIMENTAL |
| Canon PIXUS MP900 | `bjc-PIXUS-MP900` | EXPERIMENTAL |
| Canon PIXUS MP950 | `bjc-PIXUS-MP950` | EXPERIMENTAL |
| Canon PIXUS MP960 | `bjc-PIXUS-MP960` | EXPERIMENTAL |
| Canon PIXUS MP970 | `bjc-PIXUS-MP970` | EXPERIMENTAL |
| Canon PIXUS MP980 | `bjc-PIXUS-MP980` | EXPERIMENTAL |
| Canon PIXUS MP990 | `bjc-PIXUS-MP990` | EXPERIMENTAL |
| Canon PIXUS MX350 | `bjc-PIXUS-MX350` | EXPERIMENTAL |
| Canon PIXUS MX420 | `bjc-PIXUS-MX420` | EXPERIMENTAL |
| Canon PIXUS MX513 | `bjc-PIXUS-MX513` | EXPERIMENTAL |
| Canon PIXUS MX523 | `bjc-PIXUS-MX523` | EXPERIMENTAL |
| Canon PIXUS MX7600 | `bjc-PIXUS-MX7600` | EXPERIMENTAL |
| Canon PIXUS MX850 | `bjc-PIXUS-MX850` | EXPERIMENTAL |
| Canon PIXUS MX860 | `bjc-PIXUS-MX860` | EXPERIMENTAL |
| Canon PIXUS MX870 | `bjc-PIXUS-MX870` | EXPERIMENTAL |
| Canon PIXUS MX883 | `bjc-PIXUS-MX883` | EXPERIMENTAL |
| Canon PIXUS MX893 | `bjc-PIXUS-MX893` | EXPERIMENTAL |
| Canon PIXUS MX923 | `bjc-PIXUS-MX923` | EXPERIMENTAL |
| Canon PIXUS Pro9000 | `bjc-PIXUS-Pro9000` | EXPERIMENTAL |
| Canon PIXUS Pro9000mk2 | `bjc-PIXUS-Pro9000mk2` | EXPERIMENTAL |
| Canon PIXUS Pro9500 | `bjc-PIXUS-Pro9500` | EXPERIMENTAL |
| Canon PIXUS Pro9500mk2 | `bjc-PIXUS-Pro9500mk2` | EXPERIMENTAL |
| Canon Pro9000 Mk.II series | `bjc-Pro9000mk2-series` | EXPERIMENTAL |
| Canon Pro9000 series | `bjc-Pro9000-series` | EXPERIMENTAL |
| Canon Pro9500 Mk.II series | `bjc-Pro9500mk2-series` | EXPERIMENTAL |
| Canon Pro9500 series | `bjc-Pro9500-series` | EXPERIMENTAL |
| Canon S100 | `bjc-s100` |  |
| Canon S200 | `bjc-s200` |  |
| Canon S300 | `bjc-s300` |  |
| Canon S330 | `bjc-s330` |  |
| Canon S400 | `bjc-s400` |  |
| Canon S450 | `bjc-s450` |  |
| Canon S4500 | `bjc-s4500` |  |
| Canon S500 | `bjc-s500` |  |
| Canon S520 | `bjc-s520` |  |
| Canon S530D | `bjc-s530D` |  |
| Canon S600 | `bjc-s600` |  |
| Canon S630 | `bjc-s630` |  |
| Canon S750 | `bjc-s750` |  |
| Canon S800 | `bjc-s800` |  |
| Canon S820 | `bjc-s820` |  |
| Canon S830D | `bjc-s830` |  |
| Canon S900 | `bjc-s900` |  |
| Canon S9000 | `bjc-s9000` |  |
| Canon SELPHY DS700 | `bjc-SELPHY-DS700` |  |
| Canon SELPHY DS810 | `bjc-SELPHY-DS810` |  |
| Canon SmartBase MP360 | `bjc-SmartBase-MP360` | EXPERIMENTAL |
| Canon SmartBase MP360S | `bjc-SmartBase-MP360S` | EXPERIMENTAL |
| Canon SmartBase MP370 | `bjc-SmartBase-MP370` | EXPERIMENTAL |
| Canon SmartBase MP390 | `bjc-SmartBase-MP390` | EXPERIMENTAL |
| Canon SmartBase MP700 | `bjc-SmartBase-MP700` | EXPERIMENTAL |
| Canon SmartBase MP730 | `bjc-SmartBasw-MP730` | EXPERIMENTAL |
| Canon SmartBase MPC400 | `bjc-SmartBase-MPC400` | EXPERIMENTAL |
| Canon SmartBase MPC600F | `bjc-SmartBase-MPC600F` | EXPERIMENTAL |
| Canon TS3100 series | `bjc-TS3100-series` | EXPERIMENTAL |
| Canon TS5000 series | `bjc-TS5000-series` | EXPERIMENTAL |
| Canon TS6000 series | `bjc-TS6000-series` | EXPERIMENTAL |
| Canon TS8000 series | `bjc-TS8000-series` | EXPERIMENTAL |
| Canon TS9000 series | `bjc-TS9000-series` | EXPERIMENTAL |

### 热升华 / 热转印 — 177 个型号（其中 34 个标注 EXPERIMENTAL）

DNP、HiTi、Mitsubishi、Kodak、Sony、Canon SELPHY、Shinko 等照片打印设备

| 型号 | 驱动名 | 备注 |
|---|---|---|
| Canon CP-10 | `canon-cp10` |  |
| Canon CP-100 | `canon-cp100` |  |
| Canon CP-200 | `canon-cp200` |  |
| Canon CP-220 | `canon-cp220` |  |
| Canon CP-300 | `canon-cp300` |  |
| Canon CP-330 | `canon-cp330` |  |
| Canon SELPHY CP1000 | `canon-cp1000` |  |
| Canon SELPHY CP1200 | `canon-cp1200` |  |
| Canon SELPHY CP1300 | `canon-cp1300` |  |
| Canon SELPHY CP1500 | `canon-cp1500` |  |
| Canon SELPHY CP400 | `canon-cp400` |  |
| Canon SELPHY CP500 | `canon-cp500` |  |
| Canon SELPHY CP510 | `canon-cp510` |  |
| Canon SELPHY CP520 | `canon-cp520` |  |
| Canon SELPHY CP530 | `canon-cp530` |  |
| Canon SELPHY CP600 | `canon-cp600` |  |
| Canon SELPHY CP710 | `canon-cp710` |  |
| Canon SELPHY CP720 | `canon-cp720` |  |
| Canon SELPHY CP730 | `canon-cp730` |  |
| Canon SELPHY CP740 | `canon-cp740` |  |
| Canon SELPHY CP750 | `canon-cp750` |  |
| Canon SELPHY CP760 | `canon-cp760` |  |
| Canon SELPHY CP770 | `canon-cp770` |  |
| Canon SELPHY CP780 | `canon-cp780` |  |
| Canon SELPHY CP790 | `canon-cp790` |  |
| Canon SELPHY CP800 | `canon-cp800` |  |
| Canon SELPHY CP810 | `canon-cp810` |  |
| Canon SELPHY CP820 | `canon-cp820` |  |
| Canon SELPHY CP900 | `canon-cp900` |  |
| Canon SELPHY CP910 | `canon-cp910` |  |
| Canon SELPHY ES1 | `canon-es1` |  |
| Canon SELPHY ES2 | `canon-es2` |  |
| Canon SELPHY ES20 | `canon-es20` |  |
| Canon SELPHY ES3 | `canon-es3` |  |
| Canon SELPHY ES30 | `canon-es30` |  |
| Canon SELPHY ES40 | `canon-es40` |  |
| CIAAT Brava 21 | `ciaat-brava-21` |  |
| Citizen CW-01 | `citizen-cw-01` |  |
| Citizen CW-02 | `citizen-cw-02` |  |
| Citizen CX | `citizen-cx` |  |
| Citizen CX-02 | `citizen-cx-02` |  |
| Citizen CX-02W | `citizen-cx-02w` |  |
| Citizen CX-W | `citizen-cx-w` |  |
| Citizen CY | `citizen-cy` |  |
| Citizen CY-02 | `citizen-cy-02` |  |
| Citizen CZ-01 | `citizen-cz-01` |  |
| Citizen OP900 | `citizen-op900` |  |
| Citizen OP900II | `citizen-op900ii` |  |
| Dai Nippon Printing DS40 | `dnp-ds40` |  |
| Dai Nippon Printing DS480 | `dnp-ds480` |  |
| Dai Nippon Printing DS620 | `dnp-ds620` |  |
| Dai Nippon Printing DS680 | `dnp-ds680` |  |
| Dai Nippon Printing DS80 | `dnp-ds80` |  |
| Dai Nippon Printing DS80DX | `dnp-ds80dx` |  |
| Dai Nippon Printing DS820 | `dnp-ds820` |  |
| Dai Nippon Printing DSRX1 | `dnp-dsrx1` |  |
| Dai Nippon Printing QW410 | `dnp-qw410` |  |
| Dai Nippon Printing SL10 | `dnp-sl10` |  |
| Dai Nippon Printing SL20 | `dnp-sl20` | EXPERIMENTAL |
| Fujifilm ASK-2000 | `fujifilm-ask-2000` | EXPERIMENTAL |
| Fujifilm ASK-2500 | `fujifilm-ask-2500` | EXPERIMENTAL |
| Fujifilm ASK-300 | `fujifilm-ask-300` |  |
| Fujifilm ASK-4000 | `fujifilm-ask-4000` | EXPERIMENTAL |
| Fujifilm FinePix-NX-500 | `fujifilm-nx500` |  |
| Fujifilm Printpix-CX-400 | `fujifilm-cx400` |  |
| Fujifilm Printpix-CX-550 | `fujifilm-cx550` |  |
| HiTi P510K | `hiti-p510k` | EXPERIMENTAL |
| HiTi P510L | `hiti-p510l` |  |
| HiTi P510S | `hiti-p510s` |  |
| HiTi P510Si | `hiti-p510si` | EXPERIMENTAL |
| HiTi P518A | `hiti-p518a` | EXPERIMENTAL |
| HiTi P518S | `hiti-p518s` | EXPERIMENTAL |
| HiTi P520L | `hiti-p520l` |  |
| HiTi P525L | `hiti-p525l` |  |
| HiTi P720L | `hiti-p720l` | EXPERIMENTAL |
| HiTi P728L | `hiti-p728l` | EXPERIMENTAL |
| HiTi P750L | `hiti-p750l` | EXPERIMENTAL |
| HiTi Prinhome P461 | `hiti-p461` |  |
| Joyspace U826L | `joyspace-u826` |  |
| Kodak 1400 | `kodak-1400` |  |
| Kodak 305 | `kodak-305` |  |
| Kodak 605 | `kodak-605` |  |
| Kodak 6800 | `kodak-6800` |  |
| Kodak 6850 | `kodak-6850` |  |
| Kodak 6900 | `kodak-6900` | EXPERIMENTAL |
| Kodak 7000 | `kodak-7000` |  |
| Kodak 7010 | `kodak-7010` | EXPERIMENTAL |
| Kodak 7015 | `kodak-7015` | EXPERIMENTAL |
| Kodak 805 | `kodak-805` |  |
| Kodak 8500 | `kodak-8500` | EXPERIMENTAL |
| Kodak 8800 | `kodak-8800` |  |
| Kodak 8810 | `kodak-8810` |  |
| Kodak 9810 | `kodak-9810` |  |
| Kodak EasyShare-G600-Printer-Dock | `kodak-g600-dock` |  |
| Kodak Easyshare-Printer-Dock | `kodak-dock` |  |
| Kodak PD-4000 | `kodak-pd-4000` |  |
| Kodak PD-6000 | `kodak-pd-6000` |  |
| Kodak Photo-Printer | `kodak-photo-printer` |  |
| Kodak Photo-Printer-500 | `kodak-photo-printer-500` |  |
| Kodak Printer-Dock-Plus | `kodak-dock-plus` |  |
| Kodak Printer-Dock-Plus-S3 | `kodak-dock-plus-s3` |  |
| Magicard Rio 2E | `magicard-rio-2e` | EXPERIMENTAL |
| Magicard Tango 2E | `magicard-tango-2e` | EXPERIMENTAL |
| Mitsubishi CP-3020D | `mitsubishi-3020d` | EXPERIMENTAL |
| Mitsubishi CP-3020DA | `mitsubishi-3020da` | EXPERIMENTAL |
| Mitsubishi CP-3020DAE | `mitsubishi-3020dae` | EXPERIMENTAL |
| Mitsubishi CP-3020DE | `mitsubishi-3020de` | EXPERIMENTAL |
| Mitsubishi CP-3020DU | `mitsubishi-3020du` | EXPERIMENTAL |
| Mitsubishi CP-3800DW | `mitsubishi-cp-3800dw` |  |
| Mitsubishi CP-9500DW | `mitsubishi-9500dw` |  |
| Mitsubishi CP-9550D | `mitsubishi-9550d` |  |
| Mitsubishi CP-9550DW | `mitsubishi-9550dw` |  |
| Mitsubishi CP-9550DW-S | `mitsubishi-9550dw-s` |  |
| Mitsubishi CP-9550DZ | `mitsubishi-9550dz` |  |
| Mitsubishi CP-9600DW | `mitsubishi-9600dw` |  |
| Mitsubishi CP-9800D | `mitsubishi-9800d` | EXPERIMENTAL |
| Mitsubishi CP-9800DW | `mitsubishi-9800dw` | EXPERIMENTAL |
| Mitsubishi CP-9800DW-S | `mitsubishi-9800dw-s` |  |
| Mitsubishi CP-9800DZ | `mitsubishi-9800dz` |  |
| Mitsubishi CP-9810D | `mitsubishi-9810d` | EXPERIMENTAL |
| Mitsubishi CP-9810DW | `mitsubishi-9810dw` | EXPERIMENTAL |
| Mitsubishi CP-9820DW-AG | `mitsubishi-9820dw-ag` | EXPERIMENTAL |
| Mitsubishi CP-D707DW | `mitsubishi-d707dw` |  |
| Mitsubishi CP-D70DW | `mitsubishi-d70dw` |  |
| Mitsubishi CP-D80DW | `mitsubishi-d80dw` |  |
| Mitsubishi CP-D90DW | `mitsubishi-d90dw` |  |
| Mitsubishi CP-D90DW-SL | `mitsubishi-d90dwsl` | EXPERIMENTAL |
| Mitsubishi CP-K60DW-S | `mitsubishi-k60dw` |  |
| Mitsubishi CP-M1 | `mitsubishi-cpm1` |  |
| Mitsubishi CP-M15 | `mitsubishi-cpm15` |  |
| Mitsubishi CP-W5000 | `mitsubishi-cpw5000` |  |
| Mitsubishi CP30DW | `mitsubishi-cp30dw` |  |
| Mitsubishi P93D | `mitsubishi-p93d` |  |
| Mitsubishi P95D | `mitsubishi-p95d` |  |
| Nidac Copal DPB-4000 | `nidalcopac-dpb-4000` | EXPERIMENTAL |
| Nidac Copal DPB-6000 | `nidalcopac-dpb-6000` |  |
| Nidac Copal DPB-7000 | `nidalcopac-dpb-7000` | EXPERIMENTAL |
| Olmec OP1000 | `olmec-op1000` |  |
| Olympus P-10 | `olympus-p10` |  |
| Olympus P-11 | `olympus-p11` |  |
| Olympus P-200 | `olympus-p200` |  |
| Olympus P-300 | `olympus-p300` |  |
| Olympus P-300E | `olympus-p300e` |  |
| Olympus P-300U | `olympus-p300u` |  |
| Olympus P-330E | `olympus-p330e` |  |
| Olympus P-330NE | `olympus-p330ne` |  |
| Olympus P-400 | `olympus-p400` |  |
| Olympus P-440 | `olympus-p440` |  |
| Olympus P-S100 | `olympus-ps100` |  |
| Shinko CHC-S1245 | `shinko-chcs1245` |  |
| Shinko CHC-S2145 | `shinko-chcs2145` |  |
| Shinko CHC-S6145 | `shinko-chcs6145` |  |
| Shinko CHC-S6245 | `shinko-chcs6245` | EXPERIMENTAL |
| Shinko CHC-S9045 | `shinko-chcs9045` |  |
| Sinfonia CHC-S1245/E1 | `sinfonia-chcs1245` |  |
| Sinfonia CHC-S2145/S2 | `sinfonia-chcs2145` |  |
| Sinfonia CHC-S2245/S3 | `sinfonia-chcs2245` |  |
| Sinfonia CHC-S6145/CS2 | `sinfonia-chcs6145` |  |
| Sinfonia CHC-S6245/CE1 | `sinfonia-chcs6245` | EXPERIMENTAL |
| Sony DPP-EX5 | `sony-dppex5` |  |
| Sony DPP-EX7 | `sony-dppex7` |  |
| Sony UP-971AD | `sony-up971ad` |  |
| Sony UP-991AD | `sony-up991ad` | EXPERIMENTAL |
| Sony UP-CR10L | `sony-upcr10l` |  |
| Sony UP-CR20L | `sony-upcr20l` | EXPERIMENTAL |
| Sony UP-CX1 | `sony-upcx1` |  |
| Sony UP-D711MD | `sony-upd711` |  |
| Sony UP-D895 | `sony-upd895` |  |
| Sony UP-D897 | `sony-upd897` |  |
| Sony UP-D898 | `sony-upd898` |  |
| Sony UP-D898MD | `sony-upd898md` |  |
| Sony UP-DP10 | `sony-updp10` |  |
| Sony UP-DR100 | `sony-updr100` |  |
| Sony UP-DR150 | `sony-updr150` |  |
| Sony UP-DR200 | `sony-updr200` |  |
| Sony UP-DR80MD | `sony-updr80md` |  |
| Stryker SDP1000 | `stryker-sdp1000` |  |

### DPL 标签打印 — 30 个型号

Datamax-O'Neil 条码/标签打印机

| 型号 | 驱动名 | 备注 |
|---|---|---|
| Datamax-ONeil E4204B Mark III | `datamax_oneil_E4204B` |  |
| Datamax-ONeil E4205A Mark III | `datamax_oneil_E4205A` |  |
| Datamax-ONeil E4206L Mark III | `datamax_oneil_E4206L` |  |
| Datamax-ONeil E4206P Mark III | `datamax_oneil_E4206P` |  |
| Datamax-ONeil E4304B Mark III | `datamax_oneil_E4304B` |  |
| Datamax-ONeil E4305A Mark III | `datamax_oneil_E4305A` |  |
| Datamax-ONeil E4305L Mark III | `datamax_oneil_E4305L` |  |
| Datamax-ONeil E4305P Mark III | `datamax_oneil_E4305P` |  |
| Datamax-ONeil H4212 | `datamax_oneil_H4212` |  |
| Datamax-ONeil H4212X | `datamax_oneil_H4212X` |  |
| Datamax-ONeil H4310 | `datamax_oneil_H4310` |  |
| Datamax-ONeil H4310X | `datamax_oneil_H4310X` |  |
| Datamax-ONeil H4408 | `datamax_oneil_H4408` |  |
| Datamax-ONeil H4606 | `datamax_oneil_H4606` |  |
| Datamax-ONeil H4606X | `datamax_oneil_H4606X` |  |
| Datamax-ONeil H6210 | `datamax_oneil_H6210` |  |
| Datamax-ONeil H6210X | `datamax_oneil_H6210X` |  |
| Datamax-ONeil H6212 | `datamax_oneil_H6212` |  |
| Datamax-ONeil H6212X | `datamax_oneil_H6212X` |  |
| Datamax-ONeil H6308 | `datamax_oneil_H6308` |  |
| Datamax-ONeil H6310X | `datamax_oneil_H6310X` |  |
| Datamax-ONeil H8308 | `datamax_oneil_H8308` |  |
| Datamax-ONeil H8308X | `datamax_oneil_H8308X` |  |
| Datamax-ONeil I4212e Mark II | `datamax_oneil_I4212e` |  |
| Datamax-ONeil I4310e Mark II | `datamax_oneil_I4310e` |  |
| Datamax-ONeil I4606e Mark II | `datamax_oneil_I4606e` |  |
| Datamax-ONeil RL3e | `datamax_oneil_RL3e` |  |
| Datamax-ONeil RL4e | `datamax_oneil_RL4e` |  |
| Honeywell RP2 | `honeywell_rp2` |  |
| Honeywell RP4 | `honeywell_rp4` |  |

### Lexmark 喷墨 — 6 个型号

Lexmark Z/X 系列与 Compaq IJ 系列

| 型号 | 驱动名 | 备注 |
|---|---|---|
| Compaq IJ1200 | `compaq-ij1200` |  |
| Lexmark X73 | `lexmark-x73` |  |
| Lexmark Z42 | `lexmark-z42` |  |
| Lexmark Z43 | `lexmark-z43` |  |
| Lexmark Z52 | `lexmark-z52` |  |
| Lexmark Z53 | `lexmark-z53` |  |

### 通用 PostScript — 2 个型号

PostScript Level 1 / Level 2 通用驱动

| 型号 | 驱动名 | 备注 |
|---|---|---|
| PostScript Level 1 | `ps` |  |
| PostScript Level 2 | `ps2` |  |

### RAW 直通 — 2 个型号

8/16 bit 原始数据直通（不做任何渲染）

| 型号 | 驱动名 | 备注 |
|---|---|---|
| RAW DATA 16 bit | `raw-data-16` |  |
| RAW DATA 8 bit | `raw-data-8` |  |

---

## hplip（HP / Apollo） — 1296 个型号

| 型号 | 驱动 / 备注 |
|---|---|
| Apollo 2100 | hpcups 3.25.6 |
| Apollo 2150 | hpcups 3.25.6 |
| Apollo 2200 | hpcups 3.25.6 |
| Apollo 2500 | hpcups 3.25.6 |
| Apollo 2600 | hpcups 3.25.6 |
| Apollo 2650 | hpcups 3.25.6 |
| Apollo p2000-u | hpcups 3.25.6 |
| Apollo p2250 | hpcups 3.25.6 |
| HP 2000c | hpcups 3.25.6 |
| HP 2500c | hpcups 3.25.6 |
| HP 910 | hpcups 3.25.6 |
| HP 915 | hpcups 3.25.6 |
| HP Amp | hpcups 3.25.6 |
| HP Business Inkjet 1000 | hpcups 3.25.6 |
| HP Business Inkjet 1100 | hpcups 3.25.6 |
| HP Business Inkjet 1200 | hpcups 3.25.6 |
| HP Business Inkjet 2200 | hpcups 3.25.6 |
| HP Business Inkjet 2230 | hpcups 3.25.6 |
| HP Business Inkjet 2250 pcl3 | hpcups 3.25.6 |
| HP Business Inkjet 2250 PS - Ver 1.6 | Postscript (recommended) |
| HP Business Inkjet 2280 pcl3 | hpcups 3.25.6 |
| HP Business Inkjet 2280 PS - v1.0 | Postscript (recommended) |
| HP Business Inkjet 2300 pcl3 | hpcups 3.25.6 |
| HP Business Inkjet 2300 PS v3010.107 | Postscript (recommended) |
| HP Business Inkjet 2600 pcl3 | hpcups 3.25.6 |
| HP Business Inkjet 2600 PS -RC-2.0 | Postscript (recommended) |
| HP Business Inkjet 2800 pcl3 | hpcups 3.25.6 |
| HP Business Inkjet 2800 PS v3010.107 | Postscript (recommended) |
| HP Business Inkjet 3000 pcl3 | hpcups 3.25.6 |
| HP Business Inkjet 3000 PS - RC1.1 | Postscript (recommended) |
| HP CM8050 CM8060 Color MFP with Edgeline Technology | Postscript (recommended) |
| HP Color Inkjet Printer cp1700 | hpcups 3.25.6 |
| HP Color LaserJet 1600 | hpcups 3.25.6 |
| HP Color LaserJet 2500 Series | hpcups 3.25.6 |
| HP Color LaserJet 2500 v3010.107 | Postscript (recommended) |
| HP Color LaserJet 2550 Series | Postscript (recommended) |
| HP Color LaserJet 2600n | hpcups 3.25.6 |
| HP Color LaserJet 2605 | Postscript (recommended) |
| HP Color LaserJet 2700 | Postscript (recommended) |
| HP Color LaserJet 2800 Series | Postscript (recommended) |
| HP Color LaserJet 3000 | Postscript (recommended) |
| HP Color LaserJet 3000 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 3500 | hpcups 3.25.6 |
| HP Color LaserJet 3500n | hpcups 3.25.6 |
| HP Color LaserJet 3550 | hpcups 3.25.6 |
| HP Color LaserJet 3550n | hpcups 3.25.6 |
| HP Color LaserJet 3600 | hpcups 3.25.6 |
| HP Color LaserJet 3700 | Postscript (recommended) |
| HP Color LaserJet 3700 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 3700n | hpcups 3.25.6 |
| HP Color LaserJet 3800 | Postscript (recommended) |
| HP Color LaserJet 3800 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 4500 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 4500 v2014.200 | Postscript (recommended) |
| HP Color LaserJet 4550 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 4550 v3010.107 | Postscript (recommended) |
| HP Color LaserJet 4600 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 4600 v3010.107 | Postscript (recommended) |
| HP Color LaserJet 4610 | Postscript (recommended) |
| HP Color LaserJet 4610 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 4650 | Postscript (recommended) |
| HP Color LaserJet 4650 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 4700 | Postscript (recommended) |
| HP Color LaserJet 4700 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 4730mfp | Postscript (recommended) |
| HP Color LaserJet 4730mfp pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 5 | hpcups 3.25.6 |
| HP Color LaserJet 5/5M v2015.104 | Postscript (recommended) |
| HP Color LaserJet 5500 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 5500 v3010.107 | Postscript (recommended) |
| HP Color LaserJet 5550 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 5550 v3010.107 | Postscript (recommended) |
| HP Color LaserJet 5700 | Postscript (recommended) |
| HP Color LaserJet 5m pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 6700 | Postscript (recommended) |
| HP Color LaserJet 6701 | Postscript (recommended) |
| HP Color LaserJet 8500 | Postscript (recommended) |
| HP Color LaserJet 8500 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 8550 | Postscript (recommended) |
| HP Color LaserJet 8550 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet 9500 | Postscript (recommended) |
| HP Color LaserJet 9500 MFP | Postscript (recommended) |
| HP Color LaserJet 9500 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CM1015 | Postscript (recommended) |
| HP Color LaserJet cm1312 MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CM1312 MFP Series | Postscript (recommended) |
| HP Color LaserJet cm1312nfi MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cm2320 MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CM2320 MFP Series | Postscript (recommended) |
| HP Color LaserJet cm2320fxi MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cm2320n MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cm2320nf MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CM3530 MFP | Postscript (recommended) |
| HP Color LaserJet cm3530 MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CM4540 MFP | Postscript (recommended) |
| HP Color LaserJet cm4540 MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CM4730 MFP | Postscript (recommended) |
| HP Color LaserJet cm4730 MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CM6030 MFP | Postscript (recommended) |
| HP Color LaserJet cm6030 MFP pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cm6040 MFP | hpcups 3.25.6 |
| HP Color LaserJet CM6040 MFP | Postscript (recommended) |
| HP Color LaserJet CM6049 MFP | Postscript (recommended) |
| HP Color LaserJet cm6049 MFP | hpcups 3.25.6 |
| HP Color LaserJet cp1215 | hpcups 3.25.6 |
| HP Color LaserJet cp1217 | hpcups 3.25.6 |
| HP Color LaserJet CP1510 Series | Postscript (recommended) |
| HP Color LaserJet cp1514n pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cp1515n pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cp1518ni pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CP2020 Series | Postscript (recommended) |
| HP Color LaserJet CP2020 Series with Duplexer | Postscript (recommended) |
| HP Color LaserJet cp2025 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cp2025dn pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cp2025n pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cp2025x pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CP3505 | Postscript (recommended) |
| HP Color LaserJet cp3505 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CP3525 | Postscript (recommended) |
| HP Color LaserJet cp3525 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CP4005 | Postscript (recommended) |
| HP Color LaserJet cp4005 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cp4020 Series pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CP4020-CP4520 Series | Postscript (recommended) |
| HP Color LaserJet cp4520 Series pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CP5220 Series | Postscript (recommended) |
| HP Color LaserJet CP5220 Series with Duplexer | Postscript (recommended) |
| HP Color LaserJet cp5225 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cp5225dn pcl3 | hpcups 3.25.6 |
| HP Color LaserJet cp5225n pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CP5520 Series | Postscript (recommended) |
| HP Color LaserJet cp5520 Series pcl3 | hpcups 3.25.6 |
| HP Color LaserJet CP6015 | Postscript (recommended) |
| HP Color LaserJet cp6015 pcl3 | hpcups 3.25.6 |
| HP Color LaserJet E45028 | Postscript (recommended) |
| HP Color LaserJet E55040 | Postscript (recommended) |
| HP Color LaserJet E65050 E65060 | Postscript (recommended) |
| HP Color LaserJet E65150 E65160 | Postscript (recommended) |
| HP Color LaserJet E67550 E67560 | Postscript (recommended) |
| HP Color LaserJet E67650 E67660 | Postscript (recommended) |
| HP Color LaserJet E75245 | Postscript (recommended) |
| HP Color LaserJet E85055 | Postscript (recommended) |
| HP Color LaserJet Enterprise M750 | Postscript (recommended) |
| HP Color LaserJet Flow 5800 | Postscript (recommended) |
| HP Color LaserJet Flow 6800 | Postscript (recommended) |
| HP Color LaserJet Flow E57540 | Postscript (recommended) |
| HP Color LaserJet Flow MFP M680 | Postscript (recommended) |
| HP Color LaserJet flow MFP M880 | Postscript (recommended) |
| HP Color LaserJet Flow X579 | Postscript (recommended) |
| HP Color LaserJet Flow X57945 | Postscript (recommended) |
| HP Color LaserJet Flow x580 | Postscript (recommended) |
| HP Color LaserJet FlowMFP M578 | Postscript (recommended) |
| HP Color LaserJet FlowMFP M776 | Postscript (recommended) |
| HP Color LaserJet M455 | Postscript (recommended) |
| HP Color LaserJet M552 | Postscript (recommended) |
| HP Color LaserJet M553 | Postscript (recommended) |
| HP Color LaserJet M554 | Postscript (recommended) |
| HP Color LaserJet M555 | Postscript (recommended) |
| HP Color LaserJet M651 | Postscript (recommended) |
| HP Color LaserJet M652 M653 | Postscript (recommended) |
| HP Color LaserJet M751 | Postscript (recommended) |
| HP Color LaserJet M855 | Postscript (recommended) |
| HP Color LaserJet M856 | Postscript (recommended) |
| HP Color LaserJet MFP 5800 | Postscript (recommended) |
| HP Color LaserJet MFP 6800 | Postscript (recommended) |
| HP Color LaserJet MFP 6801 | Postscript (recommended) |
| HP Color LaserJet MFP E47528 | Postscript (recommended) |
| HP Color LaserJet MFP E57540 | Postscript (recommended) |
| HP Color LaserJet MFP E77422 | Postscript (recommended) |
| HP Color LaserJet MFP E77428 | Postscript (recommended) |
| HP Color LaserJet MFP E78223 | Postscript (recommended) |
| HP Color LaserJet MFP E78228 | Postscript (recommended) |
| HP Color LaserJet MFP E785 | Postscript (recommended) |
| HP Color LaserJet MFP E78523 | Postscript (recommended) |
| HP Color LaserJet MFP E78528 | Postscript (recommended) |
| HP Color LaserJet MFP M480 | Postscript (recommended) |
| HP Color LaserJet MFP M577 | Postscript (recommended) |
| HP Color LaserJet MFP M578 | Postscript (recommended) |
| HP Color LaserJet MFP M680 | Postscript (recommended) |
| HP Color LaserJet MFP M681 M682 | Postscript (recommended) |
| HP Color LaserJet MFP M776 | Postscript (recommended) |
| HP Color LaserJet MFP X677 | Postscript (recommended) |
| HP Color LaserJet MFP X67755 | Postscript (recommended) |
| HP Color LaserJet MFP X67765 | Postscript (recommended) |
| HP Color LaserJet Pro 4201 | Postscript (recommended) |
| HP Color LaserJet Pro M252 | Postscript (recommended) |
| HP Color LaserJet Pro M452 | Postscript (recommended) |
| HP Color LaserJet Pro M453-4 | Postscript (recommended) |
| HP Color LaserJet Pro M478f-9f | Postscript (recommended) |
| HP Color LaserJet Pro M479 | Postscript (recommended) |
| HP Color LaserJet Pro MFP m176n | hpcups 3.25.6 |
| HP Color LaserJet Pro MFP m177fw | hpcups 3.25.6 |
| HP Color LaserJet Pro MFP M274 | Postscript (recommended) |
| HP Color LaserJet Pro MFP M277 | Postscript (recommended) |
| HP Color LaserJet Pro MFP M377 | Postscript (recommended) |
| HP Color LaserJet Pro MFP M476 | Postscript (recommended) |
| HP Color LaserJet Pro MFP M477 | Postscript (recommended) |
| HP Color LaserJet Pro MFP M481 | Postscript (recommended) |
| HP Color LaserJet v2013.114 | Postscript (recommended) |
| HP Color LaserJet X557 | Postscript (recommended) |
| HP Color LaserJet X654 | Postscript (recommended) |
| HP Color LaserJet X65455 | Postscript (recommended) |
| HP Color LaserJet X65465 | Postscript (recommended) |
| HP Color MFP 8801 | Postscript (recommended) |
| HP Color MFP E78323-25-30 | Postscript (recommended) |
| HP Color MFP E786-25-30-35 | Postscript (recommended) |
| HP Color MFP E78625-30-35 | Postscript (recommended) |
| HP Color MFP E877-40-50-60-70 | Postscript (recommended) |
| HP Color MFP E87740-50-60-70 | Postscript (recommended) |
| HP ColorLaserJet M153-M154 | Postscript (recommended) |
| HP ColorLaserJet M155-M156 | Postscript (recommended) |
| HP ColorLaserJet M253-M254 | Postscript (recommended) |
| HP ColorLaserJet M255-M256 | Postscript (recommended) |
| HP ColorLaserJet MFP M178-M181 | Postscript (recommended) |
| HP ColorLaserJet MFP M182-M185 | Postscript (recommended) |
| HP ColorLaserJet MFP M278-M281 | Postscript (recommended) |

| HP ColorLaserJet MFP M282-M285 | Postscript (recommended) |
| HP cp1160 | hpcups 3.25.6 |
| HP Designjet 4000ps | Postscript (recommended) |
| HP Designjet 4020ps | Postscript (recommended) |
| HP Designjet 4500mfp | Postscript (recommended) |
| HP Designjet 4500ps | Postscript (recommended) |
| HP Designjet 4520mfp | Postscript (recommended) |
| HP Designjet 4520ps | Postscript (recommended) |
| HP Designjet D5800ps | Postscript (recommended) |
| HP Designjet T1100ps 24in | Postscript (recommended) |
| HP Designjet T1100ps 44in | Postscript (recommended) |
| HP Designjet T1120ps 24in | Postscript (recommended) |
| HP Designjet T1120ps 44in | Postscript (recommended) |
| HP Designjet T1200 PostScript | — |
| HP Designjet T1300 PostScript | — |
| HP Designjet T1500 - PostScript | — |
| HP DesignJet T1530ps PS3 | — |
| HP DesignJet T1600 PS3 | — |
| HP DesignJet T1600dr PS3 | — |
| HP DesignJet T1700 - PS | Postscript (recommended) |
| HP DesignJet T1700dr - PS | Postscript (recommended) |
| HP DesignJet T1708 - PS | Postscript (recommended) |
| HP DesignJet T1708dr - PS | Postscript (recommended) |
| HP Designjet T2300 PostScript | — |
| HP Designjet T2500 - PostScript | — |
| HP DesignJet T2530ps PS3 | — |
| HP DesignJet T2600 PS3 | — |
| HP DesignJet T2600dr PS3 | — |
| HP Designjet T3500ps | Postscript (recommended) |
| HP Designjet T7100ps | Postscript (recommended) |
| HP Designjet T7100ps Monochrome | Postscript (recommended) |
| HP Designjet T7200ps | Postscript (recommended) |
| HP Designjet T770ps 24in | Postscript (recommended) |
| HP Designjet T770ps 44in | Postscript (recommended) |
| HP Designjet T790ps 24in | Postscript (recommended) |
| HP Designjet T790ps 44in | Postscript (recommended) |
| HP Designjet T795ps 44in | Postscript (recommended) |
| HP Designjet T920 PostScript | — |
| HP DesignJet T930 - PostScript | — |
| HP DesignJet XL 3600 PS3 | — |
| HP DesignJet XL 3800 MFP PS - PostScript | — |
| HP DesignJet Z2600 PostScript - PS | — |
| HP Designjet Z5200 PostScript - PS | — |
| HP Designjet Z5400 PostScript - PS | — |
| HP DesignJet Z5600 PostScript - PS | — |
| HP DesignJet Z6 24in - PS | Postscript (recommended) |
| HP DesignJet Z6 44in - PS | Postscript (recommended) |
| HP DesignJet Z6 Pro 64in - PS | Postscript (recommended) |
| HP Designjet Z6100ps 42in Photo | Postscript (recommended) |
| HP Designjet Z6100ps 60in Photo | Postscript (recommended) |
| HP Designjet Z6200ps 42in Photo | Postscript (recommended) |
| HP Designjet Z6200ps 60in Photo | Postscript (recommended) |
| HP Designjet Z6600ps | Postscript (recommended) |
| HP DesignJet Z6610ps 60in - PS | Postscript (recommended) |
| HP Designjet Z6800ps Photo | Postscript (recommended) |
| HP DesignJet Z6810ps 42in - PS | Postscript (recommended) |
| HP DesignJet Z6810ps 60in - PS | Postscript (recommended) |
| HP DesignJet Z6dr 44in - PS | Postscript (recommended) |
| HP DesignJet Z9 24in - PS | Postscript (recommended) |
| HP DesignJet Z9 44in - PS | Postscript (recommended) |
| HP DesignJet Z9 Pro 64in - PS | Postscript (recommended) |
| HP DesignJet Z9dr 44in - PS | Postscript (recommended) |
| HP Deskjet 1000 j110 Series | hpcups 3.25.6 |
| HP Deskjet 1010 Series | hpcups 3.25.6 |
| HP Deskjet 1050 j410 Series | hpcups 3.25.6 |
| HP Deskjet 1100 | hpcups 3.25.6 |
| HP Deskjet 1110 Series | hpcups 3.25.6 |
| HP Deskjet 1120 | hpcups 3.25.6 |
| HP Deskjet 1125 | hpcups 3.25.6 |
| HP Deskjet 1200 Series | hpcups 3.25.6 |
| HP Deskjet 1200c | hpcups 3.25.6 |
| HP Deskjet 1220c | hpcups 3.25.6 |
| HP Deskjet 1280 | hpcups 3.25.6 |
| HP Deskjet 1510 Series | hpcups 3.25.6 |
| HP Deskjet 1600c | hpcups 3.25.6 |
| HP Deskjet 1600cm | hpcups 3.25.6 |
| HP Deskjet 1600cn | hpcups 3.25.6 |
| HP Deskjet 2000 j210 Series | hpcups 3.25.6 |
| HP Deskjet 2020 Series | hpcups 3.25.6 |
| HP Deskjet 2050 j510 Series | hpcups 3.25.6 |
| HP Deskjet 2130 Series | hpcups 3.25.6 |
| HP Deskjet 2200 Series | hpcups 3.25.6 |
| HP Deskjet 2300 Series | hpcups 3.25.6 |
| HP Deskjet 2510 Series | hpcups 3.25.6 |
| HP Deskjet 2520 Series | hpcups 3.25.6 |
| HP Deskjet 2540 Series | hpcups 3.25.6 |
| HP Deskjet 2600 Series | hpcups 3.25.6 |
| HP Deskjet 2640 Series | hpcups 3.25.6 |
| HP Deskjet 2700 Series | hpcups 3.25.6 |
| HP Deskjet 2800 Series | hpcups 3.25.6 |
| HP Deskjet 3000 j310 Series | hpcups 3.25.6 |
| HP Deskjet 3050 j610 Series | hpcups 3.25.6 |
| HP Deskjet 3050a j611 Series | hpcups 3.25.6 |
| HP Deskjet 3070 b611 Series | hpcups 3.25.6 |
| HP Deskjet 3320 | hpcups 3.25.6 |
| HP Deskjet 3325 | hpcups 3.25.6 |
| HP Deskjet 3420 | hpcups 3.25.6 |
| HP Deskjet 3425 | hpcups 3.25.6 |
| HP Deskjet 3450 | hpcups 3.25.6 |
| HP Deskjet 350 | hpcups 3.25.6 |
| HP Deskjet 3500 | hpcups 3.25.6 |
| HP Deskjet 3510 Series | hpcups 3.25.6 |
| HP Deskjet 3520 Series | hpcups 3.25.6 |
| HP Deskjet 3540 Series | hpcups 3.25.6 |
| HP Deskjet 3550 | hpcups 3.25.6 |
| HP Deskjet 3600 | hpcups 3.25.6 |
| HP Deskjet 3630 Series | hpcups 3.25.6 |
| HP Deskjet 3650 | hpcups 3.25.6 |
| HP Deskjet 3700 Series | hpcups 3.25.6 |
| HP Deskjet 3740 | hpcups 3.25.6 |
| HP Deskjet 3810 | hpcups 3.25.6 |
| HP Deskjet 3816 | hpcups 3.25.6 |
| HP Deskjet 3819 | hpcups 3.25.6 |
| HP Deskjet 3820 | hpcups 3.25.6 |
| HP Deskjet 3822 | hpcups 3.25.6 |
| HP Deskjet 3830 Series | hpcups 3.25.6 |
| HP Deskjet 3840 | hpcups 3.25.6 |
| HP Deskjet 3870 | hpcups 3.25.6 |
| HP Deskjet 3900 | hpcups 3.25.6 |
| HP Deskjet 3910 | hpcups 3.25.6 |
| HP Deskjet 3920 | hpcups 3.25.6 |
| HP Deskjet 3940 | hpcups 3.25.6 |
| HP Deskjet 400 | hpcups 3.25.6 |
| HP Deskjet 400l | hpcups 3.25.6 |
| HP Deskjet 4100 Series | hpcups 3.25.6 |
| HP Deskjet 4200 Series | hpcups 3.25.6 |
| HP Deskjet 450 | hpcups 3.25.6 |
| HP Deskjet 4510 Series | hpcups 3.25.6 |
| HP Deskjet 4530 Series | hpcups 3.25.6 |
| HP Deskjet 460 | hpcups 3.25.6 |
| HP Deskjet 4610 Series | hpcups 3.25.6 |
| HP Deskjet 4620 Series | hpcups 3.25.6 |
| HP Deskjet 4640 Series | hpcups 3.25.6 |
| HP Deskjet 4670 Series | hpcups 3.25.6 |
| HP Deskjet 4720 Series | hpcups 3.25.6 |
| HP Deskjet 4800 Series | hpcups 3.25.6 |
| HP Deskjet 4900 Series | hpcups 3.25.6 |
| HP Deskjet 500 | hpcups 3.25.6 |
| HP Deskjet 5000 Series | hpcups 3.25.6 |
| HP Deskjet 500c | hpcups 3.25.6 |
| HP Deskjet 505j | hpcups 3.25.6 |
| HP Deskjet 510 | hpcups 3.25.6 |
| HP Deskjet 5100 | hpcups 3.25.6 |
| HP Deskjet 520 | hpcups 3.25.6 |
| HP Deskjet 5200 Series | hpcups 3.25.6 |
| HP Deskjet 540 | hpcups 3.25.6 |
| HP Deskjet 5400 Series | hpcups 3.25.6 |
| HP Deskjet 550c | hpcups 3.25.6 |
| HP Deskjet 5520 Series | hpcups 3.25.6 |
| HP Deskjet 5550 | hpcups 3.25.6 |
| HP Deskjet 5551 | hpcups 3.25.6 |
| HP Deskjet 5552 | hpcups 3.25.6 |
| HP Deskjet 5570 Series | hpcups 3.25.6 |
| HP Deskjet 5600 | hpcups 3.25.6 |
| HP Deskjet 5640 Series | hpcups 3.25.6 |
| HP Deskjet 5650 | hpcups 3.25.6 |
| HP Deskjet 5652 | hpcups 3.25.6 |
| HP Deskjet 5700 | hpcups 3.25.6 |
| HP Deskjet 5730 Series | hpcups 3.25.6 |
| HP Deskjet 5800 | hpcups 3.25.6 |
| HP Deskjet 5810 Series | hpcups 3.25.6 |
| HP Deskjet 5820 Series | hpcups 3.25.6 |
| HP Deskjet 5850 | hpcups 3.25.6 |
| HP Deskjet 5900 Series | hpcups 3.25.6 |
| HP Deskjet 600 | hpcups 3.25.6 |
| HP Deskjet 610c | hpcups 3.25.6 |
| HP Deskjet 610cl | hpcups 3.25.6 |
| HP Deskjet 6120 | hpcups 3.25.6 |
| HP Deskjet 6122 | hpcups 3.25.6 |
| HP Deskjet 6127 | hpcups 3.25.6 |
| HP Deskjet 612c | hpcups 3.25.6 |
| HP Deskjet 630c | hpcups 3.25.6 |
| HP Deskjet 632c | hpcups 3.25.6 |
| HP Deskjet 640c | hpcups 3.25.6 |
| HP Deskjet 648c | hpcups 3.25.6 |
| HP Deskjet 6500 | hpcups 3.25.6 |
| HP Deskjet 6520 Series | hpcups 3.25.6 |
| HP Deskjet 656c | hpcups 3.25.6 |
| HP Deskjet 660 | hpcups 3.25.6 |
| HP Deskjet 6600 | hpcups 3.25.6 |
| HP Deskjet 670 | hpcups 3.25.6 |
| HP Deskjet 670c | hpcups 3.25.6 |
| HP Deskjet 670tv | hpcups 3.25.6 |
| HP Deskjet 672c | hpcups 3.25.6 |
| HP Deskjet 680 | hpcups 3.25.6 |
| HP Deskjet 6800 | hpcups 3.25.6 |
| HP Deskjet 682 | hpcups 3.25.6 |
| HP Deskjet 690c | hpcups 3.25.6 |
| HP Deskjet 692 | hpcups 3.25.6 |
| HP Deskjet 693 | hpcups 3.25.6 |
| HP Deskjet 694 | hpcups 3.25.6 |
| HP Deskjet 6940 Series | hpcups 3.25.6 |
| HP Deskjet 695 | hpcups 3.25.6 |
| HP Deskjet 697 | hpcups 3.25.6 |
| HP Deskjet 6980 Series | hpcups 3.25.6 |
| HP Deskjet 810c | hpcups 3.25.6 |
| HP Deskjet 812c | hpcups 3.25.6 |
| HP Deskjet 815c | hpcups 3.25.6 |
| HP Deskjet 816c | hpcups 3.25.6 |
| HP Deskjet 825c | hpcups 3.25.6 |
| HP Deskjet 830c | hpcups 3.25.6 |
| HP Deskjet 832c | hpcups 3.25.6 |
| HP Deskjet 840c | hpcups 3.25.6 |
| HP Deskjet 841c | hpcups 3.25.6 |
| HP Deskjet 842c | hpcups 3.25.6 |
| HP Deskjet 843c | hpcups 3.25.6 |
| HP Deskjet 845c | hpcups 3.25.6 |
| HP Deskjet 850c | hpcups 3.25.6 |
| HP Deskjet 855c | hpcups 3.25.6 |
| HP Deskjet 870c | hpcups 3.25.6 |
| HP Deskjet 880c | hpcups 3.25.6 |
| HP Deskjet 882c | hpcups 3.25.6 |
| HP Deskjet 890c | hpcups 3.25.6 |
| HP Deskjet 895c | hpcups 3.25.6 |
| HP Deskjet 916c | hpcups 3.25.6 |
| HP Deskjet 920c | hpcups 3.25.6 |
| HP Deskjet 9300 | hpcups 3.25.6 |
| HP Deskjet 930c | hpcups 3.25.6 |
| HP Deskjet 932c | hpcups 3.25.6 |
| HP Deskjet 933c | hpcups 3.25.6 |
| HP Deskjet 934c | hpcups 3.25.6 |
| HP Deskjet 935c | hpcups 3.25.6 |
| HP Deskjet 940c | hpcups 3.25.6 |
| HP Deskjet 948c | hpcups 3.25.6 |
| HP Deskjet 950c | hpcups 3.25.6 |
| HP Deskjet 952c | hpcups 3.25.6 |
| HP Deskjet 955c | hpcups 3.25.6 |
| HP Deskjet 957c | hpcups 3.25.6 |
| HP Deskjet 959c | hpcups 3.25.6 |
| HP Deskjet 9600 | hpcups 3.25.6 |
| HP Deskjet 960c | hpcups 3.25.6 |
| HP Deskjet 970c | hpcups 3.25.6 |
| HP Deskjet 975c | hpcups 3.25.6 |
| HP Deskjet 9800 | hpcups 3.25.6 |
| HP Deskjet 980c | hpcups 3.25.6 |
| HP Deskjet 990c | hpcups 3.25.6 |
| HP Deskjet 995c | hpcups 3.25.6 |
| HP Deskjet d1300 Series | hpcups 3.25.6 |
| HP Deskjet d1400 Series | hpcups 3.25.6 |
| HP Deskjet d1500 Series | hpcups 3.25.6 |
| HP Deskjet d1600 Series | hpcups 3.25.6 |
| HP Deskjet d2300 Series | hpcups 3.25.6 |
| HP Deskjet d2400 Series | hpcups 3.25.6 |
| HP Deskjet d2500 Series | hpcups 3.25.6 |
| HP Deskjet d2600 Series | hpcups 3.25.6 |
| HP Deskjet d4100 Series | hpcups 3.25.6 |
| HP Deskjet d4200 Series | hpcups 3.25.6 |
| HP Deskjet d4300 Series | hpcups 3.25.6 |
| HP Deskjet d5500 Series | hpcups 3.25.6 |
| HP Deskjet d730 | hpcups 3.25.6 |
| HP Deskjet f2100 Series | hpcups 3.25.6 |
| HP Deskjet f2200 Series | hpcups 3.25.6 |
| HP Deskjet f2400 Series | hpcups 3.25.6 |
| HP Deskjet f300 Series | hpcups 3.25.6 |
| HP Deskjet f4100 Series | hpcups 3.25.6 |
| HP Deskjet f4200 Series | hpcups 3.25.6 |
| HP Deskjet f4400 Series | hpcups 3.25.6 |
| HP Deskjet f4500 Series | hpcups 3.25.6 |
| HP Deskjet f735 | hpcups 3.25.6 |
| HP Deskjet Ink Adv 2010 k010 | hpcups 3.25.6 |
| HP Deskjet Ink Adv 2060 k110 | hpcups 3.25.6 |
| HP Deskjet Ink Advant k109a-z | hpcups 3.25.6 |
| HP Deskjet Ink Advant k209a-z | hpcups 3.25.6 |
| HP Deskjet Plus 4100 Series | hpcups 3.25.6 |
| HP Deskjet Plus 6000 Series | hpcups 3.25.6 |
| HP Deskjet Plus 6400 Series | hpcups 3.25.6 |
| HP Envy 100 d410 Series | hpcups 3.25.6 |
| HP Envy 110 Series | hpcups 3.25.6 |
| HP Envy 120 Series | hpcups 3.25.6 |
| HP Envy 4500 Series | hpcups 3.25.6 |
| HP Envy 4510 Series | hpcups 3.25.6 |
| HP Envy 4520 Series | hpcups 3.25.6 |
| HP Envy 5000 Series | hpcups 3.25.6 |
| HP Envy 5530 Series | hpcups 3.25.6 |
| HP Envy 5540 Series | hpcups 3.25.6 |
| HP Envy 5640 Series | hpcups 3.25.6 |
| HP Envy 5660 Series | hpcups 3.25.6 |
| HP Envy 6000 Series | hpcups 3.25.6 |
| HP Envy 6400 Series | hpcups 3.25.6 |
| HP Envy 7640 Series | hpcups 3.25.6 |
| HP Envy 8000 Series | hpcups 3.25.6 |
| HP Envy Inspire 7200 Series | hpcups 3.25.6 |
| HP Envy Inspire 7900 Series | hpcups 3.25.6 |
| HP Envy Photo 6200 Series | hpcups 3.25.6 |
| HP Envy Photo 7100 Series | hpcups 3.25.6 |
| HP Envy Photo 7200 Series | hpcups 3.25.6 |
| HP Envy Photo 7800 Series | hpcups 3.25.6 |
| HP Envy Photo 7900 Series | hpcups 3.25.6 |
| HP Envy Pro 6400 Series | hpcups 3.25.6 |
| HP Ink Tank 110 Series | hpcups 3.25.6 |
| HP Ink Tank 310 Series | hpcups 3.25.6 |
| HP Ink Tank Wireless 410 Series | hpcups 3.25.6 |
| HP Laser Ns 1020 | hpcups 3.25.6 |
| HP Laser Ns MFP 1005 | hpcups 3.25.6 |
| HP LaserJet 100 color MFP M175 | Postscript (recommended) |
| HP LaserJet 1000 | hpcups 3.25.6 |
| HP LaserJet 1005 Series | hpcups 3.25.6 |
| HP LaserJet 1010 | hpcups 3.25.6 |
| HP LaserJet 1012 | hpcups 3.25.6 |
| HP LaserJet 1015 | hpcups 3.25.6 |
| HP LaserJet 1018 | hpcups 3.25.6 |
| HP LaserJet 1020 | hpcups 3.25.6 |
| HP LaserJet 1022 pcl3 | hpcups 3.25.6 |
| HP LaserJet 1022n pcl3 | hpcups 3.25.6 |
| HP LaserJet 1022nw pcl3 | hpcups 3.25.6 |
| HP LaserJet 1100 | hpcups 3.25.6 |
| HP LaserJet 1100a | hpcups 3.25.6 |
| HP LaserJet 1100xi | hpcups 3.25.6 |
| HP LaserJet 1150 | hpcups 3.25.6 |
| HP LaserJet 1160 Series | hpcups 3.25.6 |
| HP LaserJet 1200 | Postscript (recommended) |
| HP LaserJet 1200 pcl3 | hpcups 3.25.6 |
| HP LaserJet 1200n | hpcups 3.25.6 |
| HP LaserJet 1220 | Postscript (recommended) |
| HP LaserJet 1220 pcl3 | hpcups 3.25.6 |
| HP LaserJet 1220se | hpcups 3.25.6 |
| HP LaserJet 1300 pcl3 | hpcups 3.25.6 |
| HP LaserJet 1300 Series | Postscript (recommended) |
| HP LaserJet 1300n pcl3 | hpcups 3.25.6 |
| HP LaserJet 1300xi pcl3 | hpcups 3.25.6 |
| HP LaserJet 1320 | hpcups 3.25.6 |
| HP LaserJet 1320 series | Postscript (recommended) |
| HP LaserJet 1320 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 1320n | hpcups 3.25.6 |
| HP LaserJet 1320nw | hpcups 3.25.6 |
| HP LaserJet 1320tn | hpcups 3.25.6 |
| HP LaserJet 200 color M251 | Postscript (recommended) |
| HP LaserJet 200 color MFP M275 | Postscript (recommended) |
| HP LaserJet 200 color MFP M276 | Postscript (recommended) |
| HP LaserJet 2100 Series | Postscript (recommended) |
| HP LaserJet 2100 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 2200 | Postscript (recommended) |
| HP LaserJet 2200 Series | hpcups 3.25.6 |
| HP LaserJet 2300 | Postscript (recommended) |
| HP LaserJet 2300 Series | hpcups 3.25.6 |
| HP LaserJet 2410 | Postscript (recommended) |
| HP LaserJet 2410 pcl3 | hpcups 3.25.6 |
| HP LaserJet 2420 | Postscript (recommended) |
| HP LaserJet 2420 pcl3 | hpcups 3.25.6 |
| HP LaserJet 2430 | Postscript (recommended) |
| HP LaserJet 2430 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3015 | Postscript (recommended) |
| HP LaserJet 3015 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3020 3030 | Postscript (recommended) |
| HP LaserJet 3020 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3030 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3050 | Postscript (recommended) |
| HP LaserJet 3050 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3052 | Postscript (recommended) |
| HP LaserJet 3052 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3055 | hpcups 3.25.6 |
| HP LaserJet 3100 | hpcups 3.25.6 |
| HP LaserJet 3150 | hpcups 3.25.6 |
| HP LaserJet 3200 | hpcups 3.25.6 |
| HP LaserJet 3200m | Postscript (recommended) |
| HP LaserJet 3300 3310 3320 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3300 Series | Postscript (recommended) |
| HP LaserJet 3330 | hpcups 3.25.6 |
| HP LaserJet 3380 | Postscript (recommended) |
| HP LaserJet 3380 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3390 | Postscript (recommended) |
| HP LaserJet 3390 pcl3 | hpcups 3.25.6 |
| HP LaserJet 3392 | hpcups 3.25.6 |
| HP LaserJet 4 Plus pcl3 | hpcups 3.25.6 |
| HP LaserJet 4 Plus v2013.111 | Postscript (recommended) |
| HP LaserJet 4/4M PostScript 600DPI | — |
| HP LaserJet 400 M401 | Postscript (recommended) |
| HP LaserJet 400 M401dne | Postscript (recommended) |
| HP LaserJet 400 MFP M425 | Postscript (recommended) |
| HP LaserJet 4000 Series | Postscript (recommended) |
| HP LaserJet 4000 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 4050 Series | Postscript (recommended) |
| HP LaserJet 4050 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 4100 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet 4100 MFP v.3010.107 | Postscript (recommended) |
| HP LaserJet 4100 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 4100 Series v.3010.107 | Postscript (recommended) |
| HP LaserJet 4150 Series | hpcups 3.25.6 |
| HP LaserJet 4200 pcl3 | hpcups 3.25.6 |
| HP LaserJet 4200 Series | Postscript (recommended) |
| HP LaserJet 4240 | Postscript (recommended) |
| HP LaserJet 4240 pcl3 | hpcups 3.25.6 |
| HP LaserJet 4250 | Postscript (recommended) |
| HP LaserJet 4250 pcl3 | hpcups 3.25.6 |
| HP LaserJet 4300 pcl3 | hpcups 3.25.6 |
| HP LaserJet 4300 Series | Postscript (recommended) |
| HP LaserJet 4345 MFP | Postscript (recommended) |
| HP LaserJet 4345 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet 4350 | Postscript (recommended) |
| HP LaserJet 4350 pcl3 | hpcups 3.25.6 |
| HP LaserJet 4l | hpcups 3.25.6 |
| HP LaserJet 4ml | hpcups 3.25.6 |
| HP LaserJet 4ML v2013.003 | Postscript (recommended) |
| HP LaserJet 4mp pcl3 | hpcups 3.25.6 |
| HP LaserJet 4MP v2013.103 | Postscript (recommended) |
| HP LaserJet 4si pcl3 | hpcups 3.25.6 |
| HP LaserJet 4Si/4Si MX 600 dpi v2011.110 | Postscript (recommended) |
| HP LaserJet 4v pcl3 | hpcups 3.25.6 |
| HP LaserJet 4V/4MV PostScript | — |
| HP LaserJet 500 color M551 | Postscript (recommended) |
| HP LaserJet 500 color MFP M570 | Postscript (recommended) |
| HP LaserJet 500 color MFP M575 | Postscript (recommended) |
| HP LaserJet 500 MFP M525 | Postscript (recommended) |
| HP LaserJet 5000 Series | Postscript (recommended) |
| HP LaserJet 5000 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 5100 Series | Postscript (recommended) |
| HP LaserJet 5100 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 5200 | Postscript (recommended) |
| HP LaserJet 5200 pcl3 | hpcups 3.25.6 |
| HP LaserJet 5200L | Postscript (recommended) |
| HP LaserJet 5200l pcl3 | hpcups 3.25.6 |
| HP LaserJet 5200LX | Postscript (recommended) |
| HP LaserJet 5200lx | hpcups 3.25.6 |
| HP LaserJet 5l | hpcups 3.25.6 |
| HP LaserJet 5MP | Postscript (recommended) |
| HP LaserJet 5mp pcl3 | hpcups 3.25.6 |
| HP LaserJet 5p | hpcups 3.25.6 |
| HP LaserJet 5si Mopier pcl3 | hpcups 3.25.6 |
| HP LaserJet 5Si Mopier PS | Postscript (recommended) |
| HP LaserJet 5si pcl3 | hpcups 3.25.6 |
| HP LaserJet 5Si/5Si MX PostScript | — |
| HP LaserJet 600 M601 M602 M603 | Postscript (recommended) |
| HP LaserJet 6l | hpcups 3.25.6 |
| HP LaserJet 6mp pcl3 | hpcups 3.25.6 |
| HP LaserJet 6p | hpcups 3.25.6 |
| HP LaserJet 6P/6MP - PostScript | — |
| HP LaserJet 700 color MFP M775 | Postscript (recommended) |
| HP LaserJet 700 M712 | Postscript (recommended) |
| HP LaserJet 8000 Series | Postscript (recommended) |
| HP LaserJet 8000 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 8100 MFP | hpcups 3.25.6 |
| HP LaserJet 8100 Series | Postscript (recommended) |
| HP LaserJet 8100 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 8150 MFP | hpcups 3.25.6 |
| HP LaserJet 8150 Series | Postscript (recommended) |
| HP LaserJet 8150 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 8501 | Postscript (recommended) |
| HP LaserJet 9000 MFP | Postscript (recommended) |
| HP LaserJet 9000 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet 9000 Series | Postscript (recommended) |
| HP LaserJet 9000 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet 9040 | Postscript (recommended) |
| HP LaserJet 9040 9050 MFP | Postscript (recommended) |
| HP LaserJet 9040 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet 9040 pcl3 | hpcups 3.25.6 |
| HP LaserJet 9050 | Postscript (recommended) |
| HP LaserJet 9050 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet 9050 pcl3 | hpcups 3.25.6 |
| HP LaserJet 9055 9065 MFP | Postscript (recommended) |
| HP LaserJet 9055mfp pcl3 | hpcups 3.25.6 |
| HP LaserJet 9065mfp pcl3 | hpcups 3.25.6 |
| HP LaserJet CM1410 Series | Postscript (recommended) |
| HP LaserJet cm1411fn pcl3 | hpcups 3.25.6 |
| HP LaserJet cm1412fn pcl3 | hpcups 3.25.6 |
| HP LaserJet cm1413fn pcl3 | hpcups 3.25.6 |
| HP LaserJet cm1415fn pcl3 | hpcups 3.25.6 |
| HP LaserJet cm1415fnw pcl3 | hpcups 3.25.6 |
| HP LaserJet cm1416fnw pcl3 | hpcups 3.25.6 |
| HP LaserJet cm1417fnw pcl3 | hpcups 3.25.6 |
| HP LaserJet cm1418fnw pcl3 | hpcups 3.25.6 |
| HP LaserJet color flow MFP M575 | Postscript (recommended) |
| HP LaserJet cp1025 | hpcups 3.25.6 |
| HP LaserJet cp1025nw | hpcups 3.25.6 |
| HP LaserJet CP1520 Series | Postscript (recommended) |
| HP LaserJet E40040 | Postscript (recommended) |
| HP LaserJet E50145 | Postscript (recommended) |
| HP LaserJet E60055-E60075 | Postscript (recommended) |
| HP LaserJet E60155 | Postscript (recommended) |
| HP LaserJet E60165 | Postscript (recommended) |
| HP LaserJet E60175 | Postscript (recommended) |
| HP LaserJet E62555-E62575 | Postscript (recommended) |
| HP LaserJet E62655-E62675 | Postscript (recommended) |
| HP LaserJet Flow MFP E52645 | Postscript (recommended) |
| HP LaserJet flow MFP M525 | Postscript (recommended) |
| HP LaserJet Flow MFP M528 | Postscript (recommended) |
| HP LaserJet Flow MFP M630 | Postscript (recommended) |
| HP LaserJet flow MFP M830 | Postscript (recommended) |
| HP LaserJet m1005 | hpcups 3.25.6 |
| HP LaserJet m101-m106 | hpcups 3.25.6 |
| HP LaserJet m109-m112 | hpcups 3.25.6 |
| HP LaserJet m1120 MFP | hpcups 3.25.6 |
| HP LaserJet m1120n MFP | hpcups 3.25.6 |
| HP LaserJet m1319f MFP | hpcups 3.25.6 |
| HP LaserJet m14-m17 | hpcups 3.25.6 |
| HP LaserJet M1522 MFP Series | Postscript (recommended) |
| HP LaserJet m1522nf MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M1536dnf MFP | Postscript (recommended) |
| HP LaserJet m1537dnf MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet m1538dnf MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet m1539dnf MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet m207-m212 | hpcups 3.25.6 |
| HP LaserJet m2727 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M2727 MFP Series | Postscript (recommended) |
| HP LaserJet M3027 MFP | Postscript (recommended) |
| HP LaserJet m3027 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M3035 MFP | Postscript (recommended) |
| HP LaserJet m3035 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M406 | Postscript (recommended) |
| HP LaserJet M407 | Postscript (recommended) |
| HP LaserJet M4345 MFP | Postscript (recommended) |
| HP LaserJet m4345 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M4349 MFP | Postscript (recommended) |
| HP LaserJet m4349 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M4555 MFP | Postscript (recommended) |
| HP LaserJet M5025 MFP | Postscript (recommended) |
| HP LaserJet m5025 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M5035 MFP | Postscript (recommended) |
| HP LaserJet m5035 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet m5039 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M506 | Postscript (recommended) |
| HP LaserJet M507 | Postscript (recommended) |
| HP Laserjet M604 M605 M606 | Postscript (recommended) |
| HP LaserJet M607 M608 M609 | Postscript (recommended) |
| HP LaserJet M610 M611 M612 | Postscript (recommended) |
| HP LaserJet M806 | Postscript (recommended) |
| HP LaserJet M9040 M9050 MFP | Postscript (recommended) |
| HP LaserJet m9040 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet m9050 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet M9059  MFP | Postscript (recommended) |
| HP LaserJet m9059 MFP pcl3 | hpcups 3.25.6 |
| HP LaserJet Managed MFP E826-50-60-70 | Postscript (recommended) |
| HP LaserJet Managed MFP E82650-60-70 | Postscript (recommended) |
| HP LaserJet MFP 8601 | Postscript (recommended) |
| HP LaserJet MFP E42540 | Postscript (recommended) |
| HP LaserJet MFP E72425 | Postscript (recommended) |
| HP LaserJet MFP E72430 | Postscript (recommended) |
| HP LaserJet MFP E72525-30-35 | Postscript (recommended) |
| HP LaserJet MFP E730 | Postscript (recommended) |
| HP LaserJet MFP E73025 | Postscript (recommended) |
| HP LaserJet MFP E73030 | Postscript (recommended) |
| HP LaserJet MFP E731-30-35-40 | Postscript (recommended) |
| HP LaserJet MFP E73130-35-40 | Postscript (recommended) |
| HP LaserJet MFP E77822-25-30 | Postscript (recommended) |
| HP LaserJet MFP E82540-50-60 | Postscript (recommended) |
| HP LaserJet MFP E87640-50-60 | Postscript (recommended) |
| HP LaserJet MFP m129-m134 | hpcups 3.25.6 |
| HP LaserJet MFP m139-m142 | hpcups 3.25.6 |
| HP LaserJet MFP m232-m237 | hpcups 3.25.6 |
| HP LaserJet MFP m28-m31 | hpcups 3.25.6 |
| HP LaserJet MFP M430 | Postscript (recommended) |
| HP LaserJet MFP M431 | Postscript (recommended) |
| HP LaserJet MFP M527 | Postscript (recommended) |
| HP LaserJet MFP M630 | Postscript (recommended) |
| HP LaserJet MFP M631 M632 M633 | Postscript (recommended) |
| HP LaserJet MFP M634 M635 M636 | Postscript (recommended) |
| HP LaserJet MFP M725 | Postscript (recommended) |
| HP LaserJet p1005 | hpcups 3.25.6 |
| HP LaserJet p1006 | hpcups 3.25.6 |
| HP LaserJet p1007 | hpcups 3.25.6 |
| HP LaserJet p1008 | hpcups 3.25.6 |
| HP LaserJet p1009 | hpcups 3.25.6 |
| HP LaserJet p1505 | hpcups 3.25.6 |
| HP LaserJet p1505n zxs | hpcups 3.25.6 |
| HP LaserJet p2014 zxs | hpcups 3.25.6 |
| HP LaserJet p2014n zxs | hpcups 3.25.6 |
| HP LaserJet P2015 Series | Postscript (recommended) |
| HP LaserJet p2015 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet p2015d Series | hpcups 3.25.6 |
| HP LaserJet p2015dn Series | hpcups 3.25.6 |
| HP LaserJet p2015n Series | hpcups 3.25.6 |
| HP LaserJet p2015x Series | hpcups 3.25.6 |
| HP LaserJet p2035 pcl3 | hpcups 3.25.6 |
| HP LaserJet p2035n pcl3 | hpcups 3.25.6 |
| HP LaserJet P2055 | Postscript (recommended) |
| HP LaserJet p2055 pcl3 | hpcups 3.25.6 |
| HP LaserJet p2055d pcl3 | hpcups 3.25.6 |
| HP LaserJet p2055dn pcl3 | hpcups 3.25.6 |
| HP LaserJet p2055x pcl3 | hpcups 3.25.6 |
| HP LaserJet P3004 | Postscript (recommended) |
| HP LaserJet p3004 pcl3 | hpcups 3.25.6 |
| HP LaserJet P3005 | Postscript (recommended) |
| HP LaserJet p3005 pcl3 | hpcups 3.25.6 |
| HP LaserJet P3010 Series | Postscript (recommended) |
| HP LaserJet p3010 Series pcl3 | hpcups 3.25.6 |
| HP LaserJet P4010 Series | Postscript (recommended) |
| HP LaserJet p4014 | hpcups 3.25.6 |
| HP LaserJet p4014dn | hpcups 3.25.6 |
| HP LaserJet p4014n | hpcups 3.25.6 |
| HP LaserJet p4015 | hpcups 3.25.6 |
| HP LaserJet p4015dn | hpcups 3.25.6 |
| HP LaserJet p4015n | hpcups 3.25.6 |
| HP LaserJet p4015tn | hpcups 3.25.6 |
| HP LaserJet p4015x | hpcups 3.25.6 |
| HP LaserJet p4515 | hpcups 3.25.6 |
| HP LaserJet p4515n | hpcups 3.25.6 |
| HP LaserJet p4515tn | hpcups 3.25.6 |
| HP LaserJet p4515x | hpcups 3.25.6 |
| HP LaserJet p4515xm | hpcups 3.25.6 |
| HP LaserJet Pro 3001-3008 | Postscript (recommended) |
| HP LaserJet Pro 4001 | Postscript (recommended) |
| HP LaserJet Pro 4002 | Postscript (recommended) |
| HP LaserJet Pro 4003 | Postscript (recommended) |
| HP LaserJet Pro 4004 | Postscript (recommended) |
| HP LaserJet Pro M118-M119 | Postscript (recommended) |
| HP LaserJet Pro M148-M149 | Postscript (recommended) |
| HP LaserJet Pro M148f-M149f | Postscript (recommended) |
| HP LaserJet Pro M201-M202 | Postscript (recommended) |
| HP LaserJet Pro M203-M206 | Postscript (recommended) |
| HP LaserJet Pro M304-M305 | Postscript (recommended) |
| HP LaserJet Pro M329 | Postscript (recommended) |
| HP LaserJet Pro M402-M403 | Postscript (recommended) |
| HP LaserJet Pro M402-M403n | Postscript (recommended) |
| HP LaserJet Pro M404-M405 | Postscript (recommended) |
| HP LaserJet Pro M428-M429 | Postscript (recommended) |
| HP LaserJet Pro M428f-M429f | Postscript (recommended) |
| HP LaserJet Pro M501 | Postscript (recommended) |
| HP LaserJet Pro M701 | Postscript (recommended) |
| HP LaserJet Pro M706 | Postscript (recommended) |
| HP LaserJet Pro MFP 3101-3108 | Postscript (recommended) |
| HP LaserJet Pro MFP 4101 | Postscript (recommended) |
| HP LaserJet Pro MFP 4102 | Postscript (recommended) |
| HP LaserJet Pro MFP 4103 | Postscript (recommended) |
| HP LaserJet Pro MFP 4104 | Postscript (recommended) |
| HP LaserJet Pro MFP m125a | hpcups 3.25.6 |
| HP LaserJet Pro MFP m125nr | hpcups 3.25.6 |
| HP LaserJet Pro MFP m125nw | hpcups 3.25.6 |
| HP LaserJet Pro MFP m125r | hpcups 3.25.6 |
| HP LaserJet Pro MFP m125rnw | hpcups 3.25.6 |
| HP LaserJet Pro MFP m125s | hpcups 3.25.6 |
| HP LaserJet Pro MFP m126 Plus Series | hpcups 3.25.6 |
| HP LaserJet Pro MFP m126a | hpcups 3.25.6 |
| HP LaserJet Pro MFP m126nw | hpcups 3.25.6 |
| HP LaserJet Pro MFP m127fn | hpcups 3.25.6 |
| HP LaserJet Pro MFP m127fp | hpcups 3.25.6 |
| HP LaserJet Pro MFP m127fs | hpcups 3.25.6 |
| HP LaserJet Pro MFP m127fw | hpcups 3.25.6 |
| HP LaserJet Pro MFP m128fn | hpcups 3.25.6 |
| HP LaserJet Pro MFP m128fp | hpcups 3.25.6 |
| HP LaserJet Pro MFP m128fw | hpcups 3.25.6 |
| HP LaserJet Pro MFP M225-M226 | Postscript (recommended) |
| HP LaserJet Pro MFP M227-M231 | Postscript (recommended) |
| HP LaserJet Pro MFP m25a | hpcups 3.25.6 |
| HP LaserJet Pro MFP m25nw | hpcups 3.25.6 |
| HP LaserJet Pro MFP m26a | hpcups 3.25.6 |
| HP LaserJet Pro MFP m26nw | hpcups 3.25.6 |
| HP LaserJet Pro MFP m27c | hpcups 3.25.6 |
| HP LaserJet Pro MFP m27cnw | hpcups 3.25.6 |
| HP LaserJet Pro MFP M426-M427 | Postscript (recommended) |
| HP LaserJet Pro MFP M435 | Postscript (recommended) |
| HP LaserJet Pro MFP M521 | Postscript (recommended) |
| HP LaserJet Pro p1100 Plus Series | hpcups 3.25.6 |
| HP LaserJet Professional m1132 MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1136 MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1137 MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1138 MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1139 MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1212nf MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1213nf MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1214nfh MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1216nfh MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1217nfw MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1218nfg MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1218nfs MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1219nf MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1219nfg MFP | hpcups 3.25.6 |
| HP LaserJet Professional m1219nfs MFP | hpcups 3.25.6 |
| HP LaserJet Professional p 1102w | hpcups 3.25.6 |
| HP LaserJet Professional p1102 | hpcups 3.25.6 |
| HP LaserJet Professional p1106 | hpcups 3.25.6 |
| HP LaserJet Professional p1106w | hpcups 3.25.6 |
| HP LaserJet Professional p1107 | hpcups 3.25.6 |
| HP LaserJet Professional p1107w | hpcups 3.25.6 |
| HP LaserJet Professional p1108 | hpcups 3.25.6 |
| HP LaserJet Professional p1108w | hpcups 3.25.6 |
| HP LaserJet Professional p1109 | hpcups 3.25.6 |
| HP LaserJet Professional p1109w | hpcups 3.25.6 |
| HP LaserJet Professional p1566 | hpcups 3.25.6 |
| HP LaserJet Professional p1567 | hpcups 3.25.6 |
| HP LaserJet Professional p1568 | hpcups 3.25.6 |
| HP LaserJet Professional p1569 | hpcups 3.25.6 |
| HP LaserJet Professional p1606dn | hpcups 3.25.6 |
| HP LaserJet Professional p1607dn | hpcups 3.25.6 |
| HP LaserJet Professional p1608dn | hpcups 3.25.6 |
| HP LaserJet Professional p1609dn | hpcups 3.25.6 |
| HP LaserJet Tank 1020 | hpcups 3.25.6 |
| HP LaserJet Tank 150x | hpcups 3.25.6 |
| HP LaserJet Tank 250x | hpcups 3.25.6 |
| HP LaserJet Tank MFP 1005 | hpcups 3.25.6 |
| HP LaserJet Tank MFP 160x | hpcups 3.25.6 |
| HP LaserJet Tank MFP 260x | hpcups 3.25.6 |
| HP LJ 300-400 color M351-M451 | Postscript (recommended) |
| HP LJ 300-400 color MFP M375-M475 | Postscript (recommended) |
| HP Mopier 240 | Postscript (recommended) |
| HP Mopier 240 pcl3 | hpcups 3.25.6 |
| HP Mopier 320 | Postscript (recommended) |
| HP Mopier 320 pcl3 | hpcups 3.25.6 |
| HP Neverstop Laser 100x | hpcups 3.25.6 |
| HP Neverstop Laser MFP 120x | hpcups 3.25.6 |
| HP Officejet | hpcups 3.25.6 |
| HP Officejet 100 Mobile l411 | hpcups 3.25.6 |
| HP Officejet 150 Mobile l511 | hpcups 3.25.6 |
| HP Officejet 200 Mobile Series | hpcups 3.25.6 |
| HP Officejet 250 Mobile Series | hpcups 3.25.6 |
| HP Officejet 2620 Series | hpcups 3.25.6 |
| HP Officejet 3830 Series | hpcups 3.25.6 |
| HP Officejet 4000 k210 | hpcups 3.25.6 |
| HP Officejet 4100 Series | hpcups 3.25.6 |
| HP Officejet 4105 | hpcups 3.25.6 |
| HP Officejet 4115 Series | hpcups 3.25.6 |
| HP Officejet 4200 Series | hpcups 3.25.6 |
| HP Officejet 4255 | hpcups 3.25.6 |
| HP Officejet 4300 Series | hpcups 3.25.6 |
| HP Officejet 4400 k410 | hpcups 3.25.6 |
| HP Officejet 4500 g510a-f | hpcups 3.25.6 |
| HP Officejet 4500 g510g-m | hpcups 3.25.6 |
| HP Officejet 4500 g510n-z | hpcups 3.25.6 |
| HP Officejet 4500 k710 | hpcups 3.25.6 |
| HP Officejet 4610 Series | hpcups 3.25.6 |
| HP Officejet 4620 Series | hpcups 3.25.6 |
| HP Officejet 4630 Series | hpcups 3.25.6 |
| HP Officejet 4650 Series | hpcups 3.25.6 |
| HP Officejet 5100 Series | hpcups 3.25.6 |
| HP Officejet 5200 Series | hpcups 3.25.6 |
| HP Officejet 5500 Series | hpcups 3.25.6 |
| HP Officejet 5600 Series | hpcups 3.25.6 |
| HP Officejet 5740 Series | hpcups 3.25.6 |
| HP Officejet 6000 e609a | hpcups 3.25.6 |
| HP Officejet 6000 e609n | hpcups 3.25.6 |
| HP Officejet 6100 | hpcups 3.25.6 |
| HP Officejet 6100 Series | hpcups 3.25.6 |
| HP Officejet 6150 Series | hpcups 3.25.6 |
| HP Officejet 6200 Series | hpcups 3.25.6 |
| HP Officejet 6300 Series | hpcups 3.25.6 |
| HP Officejet 6500 e709a | hpcups 3.25.6 |
| HP Officejet 6500 e709n | hpcups 3.25.6 |
| HP Officejet 6500 e710a-f | hpcups 3.25.6 |
| HP Officejet 6500 e710n-z | hpcups 3.25.6 |
| HP Officejet 6600 | hpcups 3.25.6 |
| HP Officejet 6700 | hpcups 3.25.6 |
| HP Officejet 6800 | hpcups 3.25.6 |
| HP Officejet 6950 | hpcups 3.25.6 |
| HP Officejet 6960 | hpcups 3.25.6 |
| HP Officejet 7000 e809a Series | hpcups 3.25.6 |
| HP Officejet 7100 Series | hpcups 3.25.6 |
| HP Officejet 7110 Series | hpcups 3.25.6 |
| HP Officejet 7200 Series | hpcups 3.25.6 |
| HP Officejet 7300 Series | hpcups 3.25.6 |
| HP Officejet 7400 Series | hpcups 3.25.6 |
| HP Officejet 7500 e910 | hpcups 3.25.6 |
| HP Officejet 7510 Series | hpcups 3.25.6 |
| HP Officejet 7610 Series | hpcups 3.25.6 |
| HP Officejet 8010 Series | hpcups 3.25.6 |
| HP Officejet 8020 Series | hpcups 3.25.6 |
| HP Officejet 8040 Series | hpcups 3.25.6 |
| HP Officejet 8120 Series | hpcups 3.25.6 |
| HP Officejet 8120e Series | hpcups 3.25.6 |
| HP Officejet 8130 Series | hpcups 3.25.6 |
| HP Officejet 8130e Series | hpcups 3.25.6 |
| HP Officejet 8700 | hpcups 3.25.6 |
| HP Officejet 9010 Series | hpcups 3.25.6 |
| HP Officejet 9100 Series pcl3 | hpcups 3.25.6 |
| HP Officejet 9120 Series | hpcups 3.25.6 |
| HP Officejet 9120e Series | hpcups 3.25.6 |
| HP Officejet Color MFP X585 | Postscript (recommended) |
| HP Officejet Color X555 | Postscript (recommended) |
| HP Officejet D Series | hpcups 3.25.6 |
| HP Officejet g55 | hpcups 3.25.6 |
| HP Officejet g55xi | hpcups 3.25.6 |
| HP Officejet g85 | hpcups 3.25.6 |
| HP Officejet g85xi | hpcups 3.25.6 |
| HP Officejet g95 | hpcups 3.25.6 |
| HP Officejet h470 | hpcups 3.25.6 |
| HP Officejet j3500 Series | hpcups 3.25.6 |
| HP Officejet j3600 Series | hpcups 3.25.6 |
| HP Officejet j4500 Series | hpcups 3.25.6 |
| HP Officejet j4660 Series | hpcups 3.25.6 |
| HP Officejet j4680 Series | hpcups 3.25.6 |
| HP Officejet j5500 Series | hpcups 3.25.6 |
| HP Officejet j5700 Series | hpcups 3.25.6 |
| HP Officejet j6400 Series | hpcups 3.25.6 |
| HP Officejet k60 | hpcups 3.25.6 |
| HP Officejet k60xi | hpcups 3.25.6 |
| HP Officejet k7100 | hpcups 3.25.6 |
| HP Officejet k80 | hpcups 3.25.6 |
| HP Officejet k80xi | hpcups 3.25.6 |
| HP Officejet Lx | hpcups 3.25.6 |
| HP Officejet Pro 1150c | hpcups 3.25.6 |
| HP Officejet Pro 1170c Series | hpcups 3.25.6 |
| HP Officejet Pro 251dw Printer | Postscript (recommended) |
| HP Officejet Pro 276dw MFP | Postscript (recommended) |
| HP Officejet Pro 3610 | hpcups 3.25.6 |
| HP Officejet Pro 3620 | hpcups 3.25.6 |
| HP Officejet Pro 6230 | hpcups 3.25.6 |
| HP Officejet Pro 6830 | hpcups 3.25.6 |
| HP Officejet Pro 6960 | hpcups 3.25.6 |
| HP Officejet Pro 6970 | hpcups 3.25.6 |
| HP Officejet Pro 7720 Series | hpcups 3.25.6 |
| HP Officejet Pro 7730 Series | hpcups 3.25.6 |
| HP Officejet Pro 7740 Series | hpcups 3.25.6 |
| HP Officejet Pro 8000 a809 | hpcups 3.25.6 |
| HP Officejet Pro 8000 Enterprise A811a | Postscript (recommended) |
| HP Officejet Pro 8020 Series | hpcups 3.25.6 |
| HP Officejet Pro 8030 Series | hpcups 3.25.6 |
| HP Officejet Pro 8100 | hpcups 3.25.6 |
| HP Officejet Pro 8120 Series | hpcups 3.25.6 |
| HP Officejet Pro 8120e Series | hpcups 3.25.6 |
| HP Officejet Pro 8130 Series | hpcups 3.25.6 |
| HP Officejet Pro 8130e Series | hpcups 3.25.6 |
| HP OfficeJet Pro 8210 | Postscript (recommended) |
| HP Officejet Pro 8500 a909a | hpcups 3.25.6 |
| HP Officejet Pro 8500 a909g | hpcups 3.25.6 |
| HP Officejet Pro 8500 a909n | hpcups 3.25.6 |
| HP Officejet Pro 8500 a910 | hpcups 3.25.6 |
| HP Officejet Pro 8600 | hpcups 3.25.6 |
| HP Officejet Pro 8610 | hpcups 3.25.6 |
| HP Officejet Pro 8620 | hpcups 3.25.6 |
| HP Officejet Pro 8630 | hpcups 3.25.6 |
| HP Officejet Pro 8640 | hpcups 3.25.6 |
| HP Officejet Pro 8660 | hpcups 3.25.6 |
| HP Officejet Pro 8710 | hpcups 3.25.6 |
| HP Officejet Pro 8720 | hpcups 3.25.6 |
| HP OfficeJet Pro 8730 | Postscript (recommended) |
| HP OfficeJet Pro 8732M | Postscript (recommended) |
| HP OfficeJet Pro 8740 | Postscript (recommended) |
| HP Officejet Pro 9010 Series | hpcups 3.25.6 |
| HP Officejet Pro 9020 Series | hpcups 3.25.6 |
| HP Officejet Pro 9110 Series | hpcups 3.25.6 |
| HP Officejet Pro 9110b Series | hpcups 3.25.6 |
| HP Officejet Pro 9110e Series | hpcups 3.25.6 |
| HP Officejet Pro 9120 Series | hpcups 3.25.6 |
| HP Officejet Pro 9120b Series | hpcups 3.25.6 |
| HP Officejet Pro 9120e Series | hpcups 3.25.6 |
| HP Officejet Pro 9130 Series | hpcups 3.25.6 |
| HP Officejet Pro 9130b Series | hpcups 3.25.6 |
| HP Officejet Pro 9130e Series | hpcups 3.25.6 |
| HP Officejet Pro 9720 Series | hpcups 3.25.6 |
| HP Officejet Pro 9720e Series | hpcups 3.25.6 |
| HP Officejet Pro 9730 Series | hpcups 3.25.6 |
| HP Officejet Pro 9730e Series | hpcups 3.25.6 |
| HP Officejet Pro k5300 | hpcups 3.25.6 |
| HP Officejet Pro k5400 | hpcups 3.25.6 |
| HP Officejet Pro k550 | hpcups 3.25.6 |
| HP Officejet Pro k850 | hpcups 3.25.6 |
| HP Officejet Pro k8600 | hpcups 3.25.6 |
| HP Officejet Pro l7300 | hpcups 3.25.6 |
| HP Officejet Pro l7400 | hpcups 3.25.6 |
| HP Officejet Pro l7500 | hpcups 3.25.6 |
| HP Officejet Pro l7600 | hpcups 3.25.6 |
| HP Officejet Pro l7700 | hpcups 3.25.6 |
| HP Officejet Pro X451-X551 Printer | Postscript (recommended) |
| HP Officejet Pro X476-X576 MFP | Postscript (recommended) |
| HP Officejet r40 | hpcups 3.25.6 |
| HP Officejet r40xi | hpcups 3.25.6 |
| HP Officejet r45 | hpcups 3.25.6 |
| HP Officejet r60 | hpcups 3.25.6 |
| HP Officejet r65 | hpcups 3.25.6 |
| HP Officejet r80 | hpcups 3.25.6 |
| HP Officejet r80xi | hpcups 3.25.6 |
| HP Officejet Series 300 | hpcups 3.25.6 |
| HP Officejet Series 310 | hpcups 3.25.6 |
| HP Officejet Series 320 | hpcups 3.25.6 |
| HP Officejet Series 330 | hpcups 3.25.6 |
| HP Officejet Series 350 | hpcups 3.25.6 |
| HP Officejet Series 520 | hpcups 3.25.6 |
| HP Officejet Series 570 | hpcups 3.25.6 |
| HP Officejet Series 580 | hpcups 3.25.6 |
| HP Officejet Series 590 | hpcups 3.25.6 |
| HP Officejet Series 600 | hpcups 3.25.6 |
| HP Officejet Series 610 | hpcups 3.25.6 |
| HP Officejet Series 630 | hpcups 3.25.6 |
| HP Officejet Series 700 | hpcups 3.25.6 |
| HP Officejet Series 710 | hpcups 3.25.6 |
| HP Officejet Series 720 | hpcups 3.25.6 |
| HP Officejet Series 725 | hpcups 3.25.6 |
| HP Officejet T Series | hpcups 3.25.6 |
| HP Officejet v30 | hpcups 3.25.6 |
| HP Officejet v40 | hpcups 3.25.6 |
| HP Officejet v40xi | hpcups 3.25.6 |
| HP Officejet v45 | hpcups 3.25.6 |
| HP PageWide Color 556 | Postscript (recommended) |
| HP PageWide Color 755 | Postscript (recommended) |
| HP PageWide Color E55650 | Postscript (recommended) |
| HP PageWide Color E75160 | Postscript (recommended) |
| HP PageWide Color E77650-E77660 | Postscript (recommended) |
| HP PageWide Color Flow MFP 586 | Postscript (recommended) |
| HP PageWide Color MFP 586 | Postscript (recommended) |
| HP PageWide Color MFP 774 779 | Postscript (recommended) |
| HP PageWide Color MFP 780-785 | Postscript (recommended) |
| HP PageWide Color MFP E58650 | Postscript (recommended) |
| HP PageWide Color P75250 | Postscript (recommended) |
| HP PageWide MFP P57750 | Postscript (recommended) |
| HP PageWide MFP P77740-60zs | Postscript (recommended) |
| HP PageWide P55250 | Postscript (recommended) |
| HP PageWide P75050-60 | Postscript (recommended) |
| HP PageWide P77440 P77940-60 | Postscript (recommended) |
| HP PageWide Pro 352 Printer | Postscript (recommended) |
| HP PageWide Pro 377 MFP | Postscript (recommended) |
| HP PageWide Pro 452 Printer | Postscript (recommended) |
| HP PageWide Pro 477 MFP | Postscript (recommended) |
| HP PageWide Pro 552 Printer | Postscript (recommended) |
| HP PageWide Pro 577 MFP | Postscript (recommended) |
| HP PageWide Pro 750 | Postscript (recommended) |
| HP PageWide Pro MFP 772-777 | Postscript (recommended) |
| HP PageWide XL 3900PS MFP PS3 | — |
| HP PageWide XL 3920 PS MFP - PostScript | — |
| HP PageWide XL 4000 - PostScript | — |
| HP PageWide XL 4000 MFP - PostScript | — |
| HP PageWide XL 4100PS MFP PS3 | — |
| HP PageWide XL 4100PS PS3 | — |
| HP PageWide XL 4200 PS MFP series - PostScript | — |
| HP PageWide XL 4200 PS series - PostScript | — |
| HP PageWide XL 4500 - PostScript | — |
| HP PageWide XL 4500 MFP - PostScript | — |
| HP PageWide XL 4600PS MFP PS3 | — |
| HP PageWide XL 4600PS PS3 | — |
| HP PageWide XL 4700 PS MFP series - PostScript | — |
| HP PageWide XL 4700 PS series - PostScript | — |
| HP PageWide XL 5000 - PostScript | — |
| HP PageWide XL 5000 Blueprinter - PostScript | — |
| HP PageWide XL 5000 MFP - PostScript | — |
| HP PageWide XL 5100 - PostScript | — |
| HP PageWide XL 5100 MFP - PostScript | — |
| HP PageWide XL 5100 MFP Blueprinter - PostScript | — |
| HP PageWide XL 5200 PS MFP series - PostScript | — |
| HP PageWide XL 5200 PS series - PostScript | — |
| HP PageWide XL 6000 - PostScript | — |
| HP PageWide XL 6000 MFP - PostScript | — |
| HP PageWide XL 8000 - PostScript | — |
| HP PageWide XL 8000 Blueprinter - PostScript | — |
| HP PageWide XL 8200 PS series - PostScript | — |
| HP PageWide XL Pro 5200 PS MFP series - PostScript | — |
| HP PageWide XL Pro 8200 PS MFP series - PostScript | — |
| HP Photosmart 100 | hpcups 3.25.6 |
| HP Photosmart 1115 | hpcups 3.25.6 |
| HP Photosmart 1215 | hpcups 3.25.6 |
| HP Photosmart 1218 | hpcups 3.25.6 |
| HP Photosmart 130 | hpcups 3.25.6 |
| HP Photosmart 1315 | hpcups 3.25.6 |
| HP Photosmart 140 Series | hpcups 3.25.6 |
| HP Photosmart 230 | hpcups 3.25.6 |
| HP Photosmart 240 Series | hpcups 3.25.6 |
| HP Photosmart 2570 Series | hpcups 3.25.6 |
| HP Photosmart 2600 Series | hpcups 3.25.6 |
| HP Photosmart 2700 Series | hpcups 3.25.6 |
| HP Photosmart 3100 Series | hpcups 3.25.6 |
| HP Photosmart 320 Series | hpcups 3.25.6 |
| HP Photosmart 3200 Series | hpcups 3.25.6 |
| HP Photosmart 330 Series | hpcups 3.25.6 |
| HP Photosmart 3300 Series | hpcups 3.25.6 |
| HP Photosmart 370 Series | hpcups 3.25.6 |
| HP Photosmart 380 Series | hpcups 3.25.6 |
| HP Photosmart 420 Series | hpcups 3.25.6 |
| HP Photosmart 470 Series | hpcups 3.25.6 |
| HP Photosmart 5510 Series | hpcups 3.25.6 |
| HP Photosmart 5510d Series | hpcups 3.25.6 |
| HP Photosmart 5520 Series | hpcups 3.25.6 |
| HP Photosmart 6510 Series | hpcups 3.25.6 |
| HP Photosmart 6520 Series | hpcups 3.25.6 |
| HP Photosmart 7200 Series | hpcups 3.25.6 |
| HP Photosmart 7345 | hpcups 3.25.6 |
| HP Photosmart 7400 Series | hpcups 3.25.6 |
| HP Photosmart 7510 Series | hpcups 3.25.6 |
| HP Photosmart 7520 Series | hpcups 3.25.6 |
| HP Photosmart 7550 | hpcups 3.25.6 |
| HP Photosmart 7600 Series | hpcups 3.25.6 |
| HP Photosmart 7700 Series | hpcups 3.25.6 |
| HP Photosmart 7800 Series | hpcups 3.25.6 |
| HP Photosmart 7900 Series | hpcups 3.25.6 |
| HP Photosmart 8000 Series | hpcups 3.25.6 |
| HP Photosmart 8100 Series | hpcups 3.25.6 |
| HP Photosmart 8200 Series | hpcups 3.25.6 |
| HP Photosmart 8400 Series | hpcups 3.25.6 |
| HP Photosmart 8700 Series | hpcups 3.25.6 |
| HP Photosmart a310 Series | hpcups 3.25.6 |
| HP Photosmart a320 Series | hpcups 3.25.6 |
| HP Photosmart a430 Series | hpcups 3.25.6 |
| HP Photosmart a440 Series | hpcups 3.25.6 |
| HP Photosmart a510 Series | hpcups 3.25.6 |
| HP Photosmart a520 Series | hpcups 3.25.6 |
| HP Photosmart a530 Series | hpcups 3.25.6 |
| HP Photosmart a610 Series | hpcups 3.25.6 |
| HP Photosmart a620 Series | hpcups 3.25.6 |
| HP Photosmart a630 Series | hpcups 3.25.6 |
| HP Photosmart a640 Series | hpcups 3.25.6 |
| HP Photosmart a710 Series | hpcups 3.25.6 |
| HP Photosmart a820 Series | hpcups 3.25.6 |
| HP Photosmart b010 Series | hpcups 3.25.6 |
| HP Photosmart b109a Series | hpcups 3.25.6 |
| HP Photosmart b110 Series | hpcups 3.25.6 |
| HP Photosmart b8500 Series | hpcups 3.25.6 |
| HP Photosmart c309a Series | hpcups 3.25.6 |
| HP Photosmart c3100 Series | hpcups 3.25.6 |
| HP Photosmart c4100 Series | hpcups 3.25.6 |
| HP Photosmart c4200 Series | hpcups 3.25.6 |
| HP Photosmart c4340 Series | hpcups 3.25.6 |
| HP Photosmart c4380 Series | hpcups 3.25.6 |
| HP Photosmart c4400 Series | hpcups 3.25.6 |
| HP Photosmart c4500 Series | hpcups 3.25.6 |
| HP Photosmart c4600 Series | hpcups 3.25.6 |
| HP Photosmart c4700 Series | hpcups 3.25.6 |
| HP Photosmart c5100 Series | hpcups 3.25.6 |
| HP Photosmart c5200 Series | hpcups 3.25.6 |
| HP Photosmart c5300 Series | hpcups 3.25.6 |
| HP Photosmart c5500 Series | hpcups 3.25.6 |
| HP Photosmart c6100 Series | hpcups 3.25.6 |
| HP Photosmart c6200 Series | hpcups 3.25.6 |
| HP Photosmart c6300 Series | hpcups 3.25.6 |
| HP Photosmart c7100 Series | hpcups 3.25.6 |
| HP Photosmart c7200 Series | hpcups 3.25.6 |
| HP Photosmart c8100 Series | hpcups 3.25.6 |
| HP Photosmart d110 Series | hpcups 3.25.6 |
| HP Photosmart d5060 Series | hpcups 3.25.6 |
| HP Photosmart d5100 Series | hpcups 3.25.6 |
| HP Photosmart d5300 Series | hpcups 3.25.6 |
| HP Photosmart d5400 Series | hpcups 3.25.6 |
| HP Photosmart d6100 Series | hpcups 3.25.6 |
| HP Photosmart d7100 Series | hpcups 3.25.6 |
| HP Photosmart d7200 Series | hpcups 3.25.6 |
| HP Photosmart d7300 Series | hpcups 3.25.6 |
| HP Photosmart d7400 Series | hpcups 3.25.6 |
| HP Photosmart d7500 Series | hpcups 3.25.6 |
| HP Photosmart Estn c510 Series | hpcups 3.25.6 |
| HP Photosmart Ink Adv k510 | hpcups 3.25.6 |
| HP Photosmart p1000 | hpcups 3.25.6 |
| HP Photosmart p1100 | hpcups 3.25.6 |
| HP Photosmart Plus b209a-m | hpcups 3.25.6 |
| HP Photosmart Plus b210 Series | hpcups 3.25.6 |
| HP Photosmart Prem c310 Series | hpcups 3.25.6 |
| HP Photosmart Prem c410 Series | hpcups 3.25.6 |
| HP Photosmart Prem-web c309n-s | hpcups 3.25.6 |
| HP Photosmart Premium c309g-m | hpcups 3.25.6 |
| HP Photosmart Pro b8300 Series | hpcups 3.25.6 |
| HP Photosmart Pro b8800 Series | hpcups 3.25.6 |
| HP Photosmart Wireless b109n-z | hpcups 3.25.6 |
| HP POSTSCRIPT INKJET DEVICES | — |
| HP POSTSCRIPT LASERJET DEVICES | — |
| HP POSTSCRIPT LASERJET PRO DEVICES | — |
| HP Printer Scanner Copier 300 | hpcups 3.25.6 |
| HP PSC 1000 Series | hpcups 3.25.6 |
| HP PSC 1100 Series | hpcups 3.25.6 |
| HP PSC 1200 Series | hpcups 3.25.6 |
| HP PSC 1300 Series | hpcups 3.25.6 |
| HP PSC 1310 Series | hpcups 3.25.6 |
| HP PSC 1358 Series | hpcups 3.25.6 |
| HP PSC 1400 Series | hpcups 3.25.6 |
| HP PSC 1500 Series | hpcups 3.25.6 |
| HP PSC 1600 Series | hpcups 3.25.6 |
| HP PSC 2100 Series | hpcups 3.25.6 |
| HP PSC 2150 Series | hpcups 3.25.6 |
| HP PSC 2170 Series | hpcups 3.25.6 |
| HP PSC 2200 Series | hpcups 3.25.6 |
| HP PSC 2210 Series | hpcups 3.25.6 |
| HP PSC 2300 Series | hpcups 3.25.6 |
| HP PSC 2350 Series | hpcups 3.25.6 |
| HP PSC 2400 Series | hpcups 3.25.6 |
| HP PSC 2500 Series | hpcups 3.25.6 |
| HP PSC 500 | hpcups 3.25.6 |
| HP PSC 720 | hpcups 3.25.6 |
| HP PSC 750 | hpcups 3.25.6 |
| HP PSC 750xi | hpcups 3.25.6 |
| HP PSC 760 | hpcups 3.25.6 |
| HP PSC 780 | hpcups 3.25.6 |
| HP PSC 780xi | hpcups 3.25.6 |
| HP PSC 900 Series | hpcups 3.25.6 |
| HP PSC 920 | hpcups 3.25.6 |
| HP PSC 950 | hpcups 3.25.6 |
| HP PSC 950vr | hpcups 3.25.6 |
| HP PSC 950xi | hpcups 3.25.6 |
| HP Smart Tank 210-220 Series | hpcups 3.25.6 |
| HP Smart Tank 350 Series | hpcups 3.25.6 |
| HP Smart Tank 500 Series | hpcups 3.25.6 |
| HP Smart Tank 510 Series | hpcups 3.25.6 |
| HP Smart Tank 5100 Series | hpcups 3.25.6 |
| HP Smart Tank 520 540 Series | hpcups 3.25.6 |
| HP Smart Tank 530 Series | hpcups 3.25.6 |
| HP Smart Tank 580-590 Series | hpcups 3.25.6 |
| HP Smart Tank 6000 Series | hpcups 3.25.6 |
| HP Smart Tank 610 Series | hpcups 3.25.6 |
| HP Smart Tank 660-670 Series | hpcups 3.25.6 |
| HP Smart Tank 7000 Series | hpcups 3.25.6 |
| HP Smart Tank 710-720 Series | hpcups 3.25.6 |
| HP Smart Tank 7300 Series | hpcups 3.25.6 |
| HP Smart Tank 750 Series | hpcups 3.25.6 |
| HP Smart Tank 7600 Series | hpcups 3.25.6 |
| HP Smart Tank 790 Series | hpcups 3.25.6 |
| HP Smart Tank Plus 550 Series | hpcups 3.25.6 |
| HP Smart Tank Plus 570 Series | hpcups 3.25.6 |
| HP Smart Tank Plus 650 Series | hpcups 3.25.6 |
| HP Smart Tank Wireless 450 Series | hpcups 3.25.6 |
| HP Tango | hpcups 3.25.6 |

## foo2zjs（HP / Oki / Samsung / KONICA / Xerox 等） — 101 个型号

| 型号 | 驱动 / 备注 |
|---|---|
| Dell 1355 | Foomatic/foo2hbpl2 (recommended) |
| Dell C1765 | Foomatic/foo2hbpl2 (recommended) |
| Epson AcuLaser CX17NF | Foomatic/foo2hbpl2 (recommended) |
| Epson AcuLaser M1400 | Foomatic/foo2hbpl2 (recommended) |
| Fuji Xerox DocuPrint CM205 | Foomatic/foo2hbpl2 (recommended) |
| Fuji Xerox DocuPrint CM215 | Foomatic/foo2hbpl2 (recommended) |
| Fuji Xerox DocuPrint M215 | Foomatic/foo2hbpl2 (recommended) |
| Fuji Xerox DocuPrint P205 | Foomatic/foo2hbpl2 (recommended) |
| Generic DDST Printer | Foomatic/foo2ddst |
| Generic GDI Printer | Foomatic/foo2zjs |
| Generic OAKT Printer | Foomatic/foo2oak (recommended) |
| Generic ZJS | Foomatic/foo2hp |
| Generic ZjStream Printer | Foomatic/foo2zjs (recommended) |
| HP Color LaserJet 1500 | Foomatic/foo2oak (recommended) |
| HP Color LaserJet 1600 | Foomatic/foo2hp (recommended) |
| HP Color LaserJet 2600n | Foomatic/foo2hp (recommended) |
| HP Color LaserJet CP1215 | Foomatic/foo2hp (recommended) |
| HP LaserJet 1000 | Foomatic/foo2zjs (recommended) |
| HP LaserJet 1005 | Foomatic/foo2zjs (recommended) |
| HP LaserJet 1018 | Foomatic/foo2zjs-z1 (recommended) |
| HP LaserJet 1020 | Foomatic/foo2zjs-z1 (recommended) |
| HP LaserJet 1022 | Foomatic/foo2zjs-z1 (recommended) |
| HP LaserJet 1022n | Foomatic/foo2zjs-z1 (recommended) |
| HP LaserJet 1022nw | Foomatic/foo2zjs-z1 (recommended) |
| HP LaserJet M1005 MFP | Foomatic/foo2xqx (recommended) |
| HP LaserJet M1120 MFP | Foomatic/foo2xqx (recommended) |
| HP LaserJet M1319 MFP | Foomatic/foo2zjs-z1 (recommended) |
| HP LaserJet P1005 | Foomatic/foo2xqx (recommended) |
| HP LaserJet P1006 | Foomatic/foo2xqx (recommended) |
| HP LaserJet P1007 | Foomatic/foo2xqx (recommended) |
| HP LaserJet P1008 | Foomatic/foo2xqx (recommended) |
| HP LaserJet P1505 | Foomatic/foo2xqx (recommended) |
| HP LaserJet P1505n | Foomatic/foo2xqx (recommended) |
| HP LaserJet P2014 | Foomatic/foo2xqx (recommended) |
| HP LaserJet P2014n | Foomatic/foo2xqx (recommended) |
| HP LaserJet P2035 | Foomatic/foo2zjs-z1 (recommended) |
| HP LaserJet P2035n | Foomatic/foo2zjs-z1 (recommended) |
| HP LaserJet Pro CP1025nw | Foomatic/foo2zjs-z3 (recommended) |
| HP LaserJet Pro M1132s MFP | Foomatic/foo2xqx (recommended) |
| HP LaserJet Pro M12a | Foomatic/foo2zjs-z2 (recommended) |
| HP LaserJet Pro M12w | Foomatic/foo2zjs-z2 (recommended) |
| HP LaserJet Pro P1102 | Foomatic/foo2zjs-z2 (recommended) |
| HP LaserJet Pro P1102w | Foomatic/foo2zjs-z2 (recommended) |
| HP LaserJet Pro P1566 | Foomatic/foo2zjs-z2 (recommended) |
| HP LaserJet Pro P1606dn | Foomatic/foo2zjs-z2 (recommended) |
| HP LaserJet Professional M1212nf MFP | Foomatic/foo2xqx (recommended) |
| KONICA MINOLTA magicolor 1600W | Foomatic/foo2lava (recommended) |
| KONICA MINOLTA magicolor 1680MF | Foomatic/foo2lava (recommended) |
| KONICA MINOLTA magicolor 1690MF | Foomatic/foo2lava (recommended) |
| KONICA MINOLTA magicolor 2430 DL | Foomatic/foo2zjs (recommended) |
| KONICA MINOLTA magicolor 2480 MF | Foomatic/foo2lava (recommended) |
| KONICA MINOLTA magicolor 2490 MF | Foomatic/foo2lava (recommended) |
| KONICA MINOLTA magicolor 2530 DL | Foomatic/foo2lava (recommended) |
| KONICA MINOLTA magicolor 4690MF | Foomatic/foo2lava (recommended) |
| Kyocera KM-1635 | Foomatic/foo2oak-z1 (recommended) |
| Kyocera KM-2035 | Foomatic/foo2oak-z1 (recommended) |
| Lexmark C500 | Foomatic/foo2slx (recommended) |
| Minolta Color PageWorks/Pro L | Foomatic/foo2zjs (recommended) |
| Minolta magicolor 2200 DL | Foomatic/foo2zjs (recommended) |
| Minolta magicolor 2300 DL | Foomatic/foo2zjs (recommended) |
| Minolta magicolor 2430 DL | Foomatic/foo2zjs (recommended) |
| Oki C110 | Foomatic/foo2lava (recommended) |
| Oki C301dn | Foomatic/foo2hiperc (recommended) |
| Oki C3100 | Foomatic/foo2hiperc (recommended) |
| Oki C310dn | Foomatic/foo2hiperc (recommended) |
| Oki C3200 | Foomatic/foo2hiperc (recommended) |
| Oki C3300 | Foomatic/foo2hiperc (recommended) |
| Oki C3400 | Foomatic/foo2hiperc (recommended) |
| Oki C3530 MFP | Foomatic/foo2hiperc (recommended) |
| Oki C5100 | Foomatic/foo2hiperc (recommended) |
| Oki C511dn | Foomatic/foo2hiperc (recommended) |
| Oki C5200 | Foomatic/foo2hiperc (recommended) |
| Oki C5500 | Foomatic/foo2hiperc (recommended) |
| Oki C5600 | Foomatic/foo2hiperc (recommended) |
| Oki C5650 | Foomatic/foo2hiperc (recommended) |
| Oki C5800 | Foomatic/foo2hiperc (recommended) |
| Oki C810 | Foomatic/foo2hiperc-z1 (recommended) |
| Olivetti d-Color P160W | Foomatic/foo2hiperc (recommended) |
| Ricoh SP 112 | Foomatic/foo2ddst (recommended) |
| Ricoh SP 201Nw | Foomatic/foo2ddst (recommended) |
| Samsung CLP-300 | Foomatic/foo2qpdl (recommended) |
| Samsung CLP-310 | Foomatic/foo2qpdl (recommended) |
| Samsung CLP-315 | Foomatic/foo2qpdl (recommended) |
| Samsung CLP-325 | Foomatic/foo2qpdl (recommended) |
| Samsung CLP-365 | Foomatic/foo2qpdl (recommended) |
| Samsung CLP-600 | Foomatic/foo2qpdl (recommended) |
| Samsung CLP-610 | Foomatic/foo2qpdl (recommended) |
| Samsung CLP-620 | Foomatic/foo2qpdl (recommended) |
| Samsung CLX-2160 | Foomatic/foo2qpdl (recommended) |
| Samsung CLX-3160 | Foomatic/foo2qpdl (recommended) |
| Samsung CLX-3175 | Foomatic/foo2qpdl (recommended) |
| Samsung CLX-3185 | Foomatic/foo2qpdl (recommended) |
| Samsung ML-1670 | Foomatic/foo2qpdl (recommended) |
| Samsung ML-1675 | Foomatic/foo2qpdl (recommended) |
| Xerox Phaser 3010 | Foomatic/foo2hbpl2 (recommended) |
| Xerox Phaser 3040 | Foomatic/foo2hbpl2 (recommended) |
| Xerox Phaser 6110 | Foomatic/foo2qpdl (recommended) |
| Xerox Phaser 6115MFP | Foomatic/foo2lava (recommended) |
| Xerox Phaser 6121MFP | Foomatic/foo2lava (recommended) |
| Xerox WorkCentre 3045 | Foomatic/foo2hbpl2 (recommended) |
| Xerox WorkCentre 6015 | Foomatic/foo2hbpl2 (recommended) |

## splix（Samsung / Xerox / Dell 等） — 86 个型号

| 型号 | 驱动 / 备注 |
|---|---|
| Dell 1100 | 2.0.0 |
| Dell 1110 | 2.0.0 |
| Lexmark X215 MFP | 2.0.0 |
| Samsung CLP-200 | 2.0.0 |
| Samsung CLP-300 | 2.0.0 |
| Samsung CLP-310 | 2.0.0 |
| Samsung CLP-310N | 2.0.0 |
| Samsung CLP-315 | 2.0.0 |
| Samsung CLP-500 | 2.0.0 |
| Samsung CLP-510 | 2.0.0 |
| Samsung CLP-550 | 2.0.0 |
| Samsung CLP-600 | 2.0.0 |
| Samsung CLX-216X | 2.0.0 |
| Samsung CLX-2170 | 2.0.0 |
| Samsung CLX-3160 | 2.0.0 |
| Samsung ML-1510 | 2.0.0 |
| Samsung ML-1520 | 2.0.0 |
| Samsung ML-1610 | 2.0.0 |
| Samsung ML-1630 | 2.0.0 |
| Samsung ML-1640 | 2.0.0 |
| Samsung ML-1660 | 2.0.0 |
| Samsung ML-1710 | 2.0.0 |
| Samsung ML-1740 | 2.0.0 |
| Samsung ML-1750 | 2.0.0 |
| Samsung ML-1910 | 2.0.0 |
| Samsung ML-1915 | 2.0.0 |
| Samsung ML-2010 | 2.0.0 |
| Samsung ML-2015 | 2.0.0 |
| Samsung ML-2150 | 2.0.0 |
| Samsung ML-2160 | 2.0.0 |
| Samsung ML-2165 | 2.0.0 |
| Samsung ML-2240 | 2.0.0 |
| Samsung ML-2250 | 2.0.0 |
| Samsung ML-2251 | 2.0.0 |
| Samsung ML-2510 | 2.0.0 |
| Samsung ML-2525 | 2.0.0 |
| Samsung ML-2525W | 2.0.0 |
| Samsung ML-2550 | 2.0.0 |
| Samsung ML-2571 | 2.0.0 |
| Samsung ML-2580 | 2.0.0 |
| Samsung ML-2580N | 2.0.0 |
| Samsung ML-3050 | 2.0.0 |
| Samsung ML-3051 | 2.0.0 |
| Samsung ML-3051ND | 2.0.0 |
| Samsung ML-3310 | 2.0.0 |
| Samsung ML-3310ND | 2.0.0 |
| Samsung ML-3471ND | 2.0.0 |
| Samsung ML-3560 | 2.0.0 |
| Samsung SCX-3200 | 2.0.0 |
| Samsung SCX-4100 | 2.0.0 |
| Samsung SCX-4200 | 2.0.0 |
| Samsung SCX-4216F | 2.0.0 |
| Samsung SCX-4300 | 2.0.0 |
| Samsung SCX-4500 | 2.0.0 |
| Samsung SCX-4521F | 2.0.0 |
| Samsung SCX-4600 | 2.0.0 |
| Samsung SCX-4623f | 2.0.0 |
| Samsung SCX-4623fw | 2.0.0 |
| Samsung SCX-5330N | 2.0.0 |
| Samsung SCX-5530FN | 2.0.0 |
| Samsung SF-565P | 2.0.0 |
| Samsung TRANSLATE ML-2160 | 2.0.0 |
| Samsung TRANSLATE ML-2165 | 2.0.0 |
| Samsung TRANSLATE ML-3310 | 2.0.0 |
| Samsung TRANSLATE ML-3310ND | 2.0.0 |
| Toshiba eSTUDIO180S | 2.0.0 |
| Xerox Phaser 3115 | 2.0.0 |
| Xerox Phaser 3116 | 2.0.0 |
| Xerox Phaser 3117 | 2.0.0 |
| Xerox Phaser 3120 | 2.0.0 |
| Xerox Phaser 3121 | 2.0.0 |
| Xerox Phaser 3122 | 2.0.0 |
| Xerox Phaser 3124 | 2.0.0 |
| Xerox Phaser 3130 | 2.0.0 |
| Xerox Phaser 3140 | 2.0.0 |
| Xerox Phaser 3150 | 2.0.0 |
| Xerox Phaser 3155 | 2.0.0 |
| Xerox Phaser 3160 | 2.0.0 |
| Xerox Phaser 3420 | 2.0.0 |
| Xerox Phaser 3425 | 2.0.0 |
| Xerox Phaser 5500 | 2.0.0 |
| Xerox Phaser 6100 | 2.0.0 |
| Xerox Phaser 6110 | 2.0.0 |
| Xerox WorkCentre 3119 | 2.0.0 |
| Xerox WorkCentre PE114e | 2.0.0 |
| Xerox WorkCentre PE16 | 2.0.0 |

## brlaser（Brother 单色激光）— 29 个型号

| 型号 |
|---|
| DCP-1510 |
| DCP-1600 series |
| DCP-7030 |
| DCP-7040 |
| DCP-7055 |
| DCP-7055W |
| DCP-7060D |
| DCP-7065DN |
| DCP-7080 |
| DCP-7080D |
| DCP-L2500D |
| DCP-L2520D |
| DCP-L2540DW |
| HL-1110 |
| HL-1200 |
| HL-2030 series |
| HL-2140 series |
| HL-2220 series |
| HL-2270DW series |
| HL-5030 series |
| HL-L2300D |
| HL-L2320D |
| HL-L2340D |
| HL-L2360D |
| MFC-1910W |
| MFC-7240 |
| MFC-7360N |
| MFC-7365DN |
| MFC-L2710DW series |

## brhl3040cn（Brother 彩色 LED）— 1 个型号

| 型号 | 说明 |
|---|---|
| HL-3040CN | 闭源 i386 filter，经 box86 转译运行；HL-3070CW 同代引擎可尝试 |

---

## 数据来源与参考

| 内容 | 链接 |
|---|---|
| Gutenprint 官方站点（版本、文档、支持机型总览） | https://gutenprint.sourceforge.net |
| Gutenprint 源码仓库（SourceForge Git，上游唯一官方仓库） | https://sourceforge.net/p/gimp-print/gutenprint/ci/master/tree/ |
| Gutenprint 5.3.5 发布说明（新增机型清单、3600+ 机型口径） | https://sourceforge.net/p/gimp-print/mailman/gimp-print-announce/ |
| Gutenprint 5.3.5 源码包下载 | https://sourceforge.net/projects/gimp-print/files/gutenprint-5.3/5.3.5/ |
| CUPS 官方（PPD/drv 规范、lpadmin 用法） | https://github.com/OpenPrinting/cups |
| OpenWrt 软件包（本清单各 ipk 的上游包定义） | https://github.com/openwrt/packages |
| 本清单的数据来源（编译产物 ipk） | 本仓库 `printing/` 目录 |

> 说明：Gutenprint 上游托管在 SourceForge，**GitHub / Gitee 上没有官方仓库**，搜索到的同名项目均为第三方镜像或历史 fork；
> 引用与比对请以上表中的 SourceForge 仓库为准。本文件所有型号均直接来自 `gutenprint-cups_5.3.5-r1_aarch64_generic.ipk`
> 内的 XML 定义（`/usr/share/gutenprint/5.3/xml/printers/*.xml`），可用下列命令复核：
>
> ```sh
> # 设备上核对总数（应约为 3608 条，含 hplip 等其他栈会更多）
|  |  |
| --- | --- |
> lpinfo -m | grep -c "gutenprint"
> # 查某个型号对应的驱动名
|  |  |
| --- | --- |
> lpinfo -m | grep -i "laserjet 3050"
> ```
