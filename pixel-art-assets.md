# 🌾 国风像素农场物语 — 像素素材清单

> 目标风格：GBA 16-bit 像素风（约 16×16~32×32 单位），色彩饱和，国风田园。
> 本文档按模块列出所有需要绘制的像素素材，含名称、用途、规格、视觉参考，供后续编写 Aseprite Lua 脚本调用。

---

## 📦 图块集 (Tilesets) — 用于 TileMapLayer，16×16 单元

### 1.1 基础地形图块集 (terrain_tileset)

> 核心地表覆盖层，三个地图共用一套图块。

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| T-01 | grass_light | 农场/城镇 浅色草地 | 16×16 | 亮绿色草皮，略有不规则深绿点，GBA 塞尔达风 |
| T-02 | grass_dark | 森林深色草地 | 16×16 | 墨绿色草底，散布深色草簇 |
| T-03 | soil_dry | 普通干土 | 16×16 | 棕褐色松软泥土，细小颗粒感 |
| T-04 | soil_wet | 湿土 | 16×16 | 深棕色，表面有光泽/水渍反光效果 |
| T-05 | path_dirt | 泥路 | 16×16 | 浅黄褐色压实的土路，边缘略模糊 |
| T-06 | path_stone | 石板路 | 16×16 | 灰色不规则石板拼接，缝隙有草 |
| T-07 | sand | 沙地 | 16×16 | 米黄色沙粒，河边/装饰用 |
| T-08 | water_tile | 水面 | 16×16 | 蓝色水面，有波光粼粼的动画帧（2~3帧循环） |
| T-09 | water_edge_top | 水岸上 | 16×16 | 草→水过渡，上边缘土坡 |
| T-10 | water_edge_bottom | 水岸下 | 16×16 | 同上，下边缘 |
| T-11 | water_edge_left | 水岸左 | 16×16 | 同上，左边缘 |
| T-12 | water_edge_right | 水岸右 | 16×16 | 同上，右边缘 |
| T-13 | water_corner_tl | 水岸左上角 | 16×16 | 水岸转角（内角） |
| T-14 | water_corner_tr | 水岸右上角 | 16×16 | 水岸转角 |
| T-15 | water_corner_bl | 水岸左下角 | 16×16 | 水岸转角 |
| T-16 | water_corner_br | 水岸右下角 | 16×16 | 水岸转角 |
| T-17 | fence_wood_h | 木栅栏(横) | 16×16 | 横向原木栅栏，浅棕色 |
| T-18 | fence_wood_v | 木栅栏(竖) | 16×16 | 竖向原木栅栏 |
| T-19 | fence_gate | 栅栏门 | 16×16 | 可开关的木栅栏门 |

### 1.2 耕地状态图块集 (farm_tileset) — 用于 FarmTileManager

> 对应 `HoeDirtState` 枚举，程序通过 atlas 坐标切换显示。

| 编号 | 名称 | 对应状态 | 用途 | 长得像什么 |
|------|------|---------|------|-----------|
| F-01 | dirt_normal | Normal (索引0) | 未耕的普通土 | 与 terrain 的干土类似，但应比背景稍深一圈以标识"可耕种区" |
| F-02 | dirt_tilled | Tilled (索引1) | 已耕待浇水 | 翻过的松软泥土，有犁沟纹理、深棕色 |
| F-03 | dirt_tilled_wet | TilledWet (索引2) | 已耕已浇 | 深褐色湿土，表面微反光，犁沟中带水色 |
| F-04 | planted_stage0 | Planted (索引3) | 刚播种 | 湿土中央冒一小绿点（种子刚发芽） |
| F-05 | planted_stage1 | Planted+1 (索引4) | 幼苗 | 2~3 片嫩绿叶破土，浅绿色 |
| F-06 | planted_stage2 | Planted+2 (索引5) | 中苗 | 约 8×8 大小的绿色植株，茎叶分明 |
| F-07 | planted_stage3 | Planted+3 (索引6) | 成长期 | 约 12×12 绿色植株，开始有花苞或果实雏形 |
| F-08 | mature_generic | Mature (索引7) | 可收获（通用） | 饱满的成熟作物，具体外观由 seed 决定（见作物图标） |

> **注意**: 程序目前硬编码最大生长阶段为 5（索引3~7），后续可通过 CropData.GrowthStages 配置调整。

---

## 🧑 角色精灵 (Sprites) — 32×32~48×48，4 方向 + 行走动画

### 2.1 玩家 (player)

| 编号 | 名称 | 用途 | 帧数 | 长得像什么 |
|------|------|------|------|-----------|
| P-01 | player_idle_down | 站立(下) | 1 帧 | 戴草帽的国风少年/少女正面，圆脸大眼睛，布衣 |
| P-02 | player_idle_up | 站立(上) | 1 帧 | 背面视角，能看到草帽顶和背部 |
| P-03 | player_idle_left | 站立(左) | 1 帧 | 左侧面，能看到手臂自然下垂 |
| P-04 | player_idle_right | 站立(右) | 1 帧 | 右侧面（可镜像 P-03） |
| P-05 | player_walk_down | 行走(下) | 4 帧 | 双腿交替迈步动画，肩膀微晃 |
| P-06 | player_walk_up | 行走(上) | 4 帧 | 背面行走，双腿交替 |
| P-07 | player_walk_left | 行走(左) | 4 帧 | 左侧行走，手臂前后摆动 |
| P-08 | player_walk_right | 行走(右) | 4 帧 | 右侧行走（可镜像 P-07） |
| P-09 | player_hoe_down | 锄地(下) | 2 帧 | 正面举锄→挥下，身体前倾 |
| P-10 | player_hoe_up | 锄地(上) | 2 帧 | 背面挥锄 |
| P-11 | player_hoe_left | 锄地(左) | 2 帧 | 左侧挥锄 |
| P-12 | player_hoe_right | 锄地(右) | 2 帧 | 右侧挥锄 |
| P-13 | player_water_down | 浇水(下) | 2 帧 | 正面提壶→倾壶倒水动作 |
| P-14 | player_water_up | 浇水(上) | 2 帧 | 背面浇水 |
| P-15 | player_water_left | 浇水(左) | 2 帧 | 左侧浇水 |
| P-16 | player_water_right | 浇水(右) | 2 帧 | 右侧浇水 |

### 2.2 NPC 角色 (npcs)

| 编号 | 名称 | 用途 | 帧数 | 长得像什么 |
|------|------|------|------|-----------|
| N-01 | npc_shopkeeper | 杂货铺老板 | 4方向×1帧 | 穿马褂、戴小帽的中年商人，留八字胡 |
| N-02 | npc_old_farmer | 老农（任务NPC） | 4方向×1帧 | 白须老人，卷裤腿，戴斗笠 |
| N-03 | npc_blacksmith | 铁匠 | 4方向×1帧 | 赤膊围裙，肌肉手臂，拿锤子 |
| N-04 | npc_young_woman | 年轻女子 | 4方向×1帧 | 穿碎花布衣的村姑，扎辫子 |
| N-05 | npc_child | 小孩 | 4方向×1帧 | 光脚小男孩，短衫 |

---

## 🎒 物品图标 (Item Icons) — 16×16，用于背包/快捷栏/商店

> 对应 `resources/Items/items_data.json`，每个 Item 有一个 Icon 字段。

### 3.1 种子类 (ItemType.Seed)

| 编号 | 名称 | 对应的作物 | 长得像什么 |
|------|------|-----------|-----------|
| I-S01 | seed_turnip | 萝卜种子 | 棕色小圆粒，右下角标小绿芽标记 |
| I-S02 | seed_cabbage | 白菜种子 | 浅绿色小圆粒 |
| I-S03 | seed_tomato | 番茄种子 | 橙黄色小粒 |
| I-S04 | seed_rice | 水稻种子 | 金黄色谷粒状 |
| I-S05 | seed_wheat | 小麦种子 | 麦黄色长椭粒 |
| I-S06 | seed_corn | 玉米种子 | 黄色三角形粒 |
| I-S07 | seed_pumpkin | 南瓜种子 | 扁平白色瓜子形 |
| I-S08 | seed_eggplant | 茄子种子 | 紫色小圆粒 |
| I-S09 | seed_chili | 辣椒种子 | 红色小尖粒 |
| I-S10 | seed_watermelon | 西瓜种子 | 黑色水滴状 |

### 3.2 农产品 (ItemType.Product)

| 编号 | 名称 | 长得像什么 |
|------|------|-----------|
| I-P01 | product_turnip | 白萝卜，带绿叶根 |
| I-P02 | product_cabbage | 绿色圆白菜，剖面纹理 |
| I-P03 | product_tomato | 红色番茄，高光 |
| I-P04 | product_rice | 金黄色稻穗束 |
| I-P05 | product_wheat | 麦穗 |
| I-P06 | product_corn | 玉米棒，绿色苞叶 |
| I-P07 | product_pumpkin | 橙色南瓜，棱纹 |
| I-P08 | product_eggplant | 紫色长茄子，绿蒂 |
| I-P09 | product_chili | 红色尖辣椒 |
| I-P10 | product_watermelon | 绿条纹西瓜切片 |
| I-P11 | product_apple | 红苹果 |
| I-P12 | product_peach | 粉红桃子 |
| I-P13 | product_tea | 茶叶尖 |
| I-P14 | product_mushroom | 棕色蘑菇 |
| I-P15 | product_honey | 蜂蜜罐 |

### 3.3 工具类 (ItemType.Tool) — 需要 2 套：背包图标 + 手持精灵

| 编号 | 名称 | ToolSubType | 背包图标(16×16) | 手持精灵(配合玩家动作) |
|------|------|------------|----------------|---------------------|
| I-T01 | tool_hoe_basic | Hoe | 木柄锄头，铁质锄刃 | 同图标放大到 24×24 |
| I-T02 | tool_hoe_copper | Hoe | 铜色金属锄头 | 升级版，带铜色光泽 |
| I-T03 | tool_hoe_iron | Hoe | 铁灰色锄头 | 升级版，更大更现代 |
| I-T04 | tool_wateringcan_basic | WateringCan | 木色手柄+铁皮壶身 | 手持浇水壶，壶嘴朝前 |
| I-T05 | tool_wateringcan_copper | WateringCan | 铜皮水壶 | 升级版 |
| I-T06 | tool_wateringcan_iron | WateringCan | 铁皮水壶 | 升级版 |
| I-T07 | tool_axe_basic | Axe | 木柄石斧 | 单手斧（用于砍树动画） |
| I-T08 | tool_pickaxe_basic | Pickaxe | 木柄镐头 | 十字镐 |
| I-T09 | tool_scythe_basic | Scythe | 长柄镰刀 | 弯月形刀片 |

### 3.4 材料类 (ItemType.Material)

| 编号 | 名称 | 长得像什么 |
|------|------|-----------|
| I-M01 | mat_wood | 原木段，木纹截面 |
| I-M02 | mat_stone | 灰色石块 |
| I-M03 | mat_copper_ore | 铜色矿石，闪光点 |
| I-M04 | mat_iron_ore | 暗铁色矿石 |
| I-M05 | mat_cloth | 蓝色布匹卷 |
| I-M06 | mat_rope | 麻绳卷 |
| I-M07 | mat_nail | 铁钉，L 形 |
| I-M08 | mat_brick | 红色砖块 |
| I-M09 | mat_glass | 透明玻璃片 |
| I-M10 | mat_fertilizer | 棕色肥料袋 |

### 3.5 制成品 (ItemType.Crafted)

| 编号 | 名称 | 长得像什么 |
|------|------|-----------|
| I-C01 | crafted_bread | 圆形面包，褐色表皮 |
| I-C02 | crafted_juice | 玻璃杯装橙色果汁 |
| I-C03 | crafted_wine | 陶瓷酒坛，红封口 |
| I-C04 | crafted_pickled | 泡菜坛子 |
| I-C05 | crafted_cheese | 三角形奶酪块 |
| I-C06 | crafted_tofu | 白色方块豆腐 |
| I-C07 | crafted_cake | 圆形桂花糕 |
| I-C08 | crafted_medicine | 中药药包 |

### 3.6 特殊类 (ItemType.Special)

| 编号 | 名称 | 长得像什么 |
|------|------|-----------|
| I-SP1 | special_gift | 红色礼盒，金色丝带 |
| I-SP2 | special_treasure | 宝箱，金色闪光 |
| I-SP3 | special_ticket | 入场券/请柬 |
| I-SP4 | special_letter | 信封，红色火漆 |

---

## 🌍 世界地图装饰 (World Decorations) — 用于场景中的 StaticBody2D / Sprite2D

### 4.1 农场装饰 (Farm)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| W-F01 | farmhouse | 玩家农舍 | 96×64(约3×2格) | 中式农舍，青瓦屋顶，白墙，木门窗，烟囱 |
| W-F02 | barn | 畜棚/仓库 | 64×48(2×1.5格) | 大红色谷仓，金字屋顶，双开门 |
| W-F03 | chicken_coop | 鸡舍 | 48×48(1.5×1.5格) | 小木屋+围栏小鸡舍 |
| W-F04 | well | 水井 | 32×32 | 石砌圆井，木制轱辘，有顶棚 |
| W-F05 | shipping_bin | 出货箱 | 32×32 | 木质箱体，侧边标"出货"字样，翻盖 |
| W-F06 | scarecrow | 稻草人 | 32×48 | 竹竿撑起的稻草人，穿破布衣，带草帽 |
| W-F07 | fence_wood_post | 木栅栏桩 | 16×16 | 竖立的木桩 |
| W-F08 | fence_wood_rail | 木栅栏横杆 | 16×16 | 两横木之间的连接 |
| W-F09 | tree_fruit_apple | 苹果树 | 48×64 | 绿树冠中挂红苹果 |
| W-F10 | tree_fruit_peach | 桃树 | 48×64 | 粉红花朵/果实 |
| W-F11 | tree_fruit_cherry | 樱桃树 | 48×64 | 暗红叶冠，小红果 |
| W-F12 | flower_basket | 花篮装饰 | 16×16 | 竹编小篮，彩色小花 |
| W-F13 | beehive | 蜂箱 | 32×32 | 木箱蜂巢，蜜蜂飞舞动画(2帧) |

### 4.2 小镇装饰 (Town)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| W-T01 | shop_general | 杂货铺 | 80×64 | 中式店铺，招牌"杂货"，柜台摆瓶瓶罐罐 |
| W-T02 | blacksmith | 铁匠铺 | 64×64 | 半开放工坊，有熔炉和铁砧，红火光 |
| W-T03 | inn | 客栈/酒楼 | 80×80(2.5×2.5格) | 二层木楼，招牌旗幡，红灯笼 |
| W-T04 | temple | 土地庙 | 48×48 | 小庙，灰瓦翘角檐，香炉 |
| W-T05 | lamp_post | 路灯/灯笼杆 | 16×48 | 木杆挂红灯笼，发光效果 |
| W-T06 | bench | 长凳 | 32×16 | 木条长椅，可坐下 |
| W-T07 | signpost | 路牌 | 16×32 | 木柱+箭头木牌，写"小镇→" |
| W-T08 | decoration_well | 古井(装饰) | 32×32 | 石栏圆井，比农场的更古老 |
| W-T09 | cart | 木板车 | 48×32 | 两轮木推车，装干草 |

### 4.3 森林装饰 (Forest)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| W-FO1 | tree_pine | 松树 | 48×64 | 深绿色塔形松树 |
| W-FO2 | tree_oak | 橡树 | 48×64 | 大而茂密的阔叶树冠 |
| W-FO3 | tree_palm | 棕榈树 | 48×64 | 热带棕榈，南方场景 |
| W-FO4 | stump | 树桩 | 32×16 | 砍伐后的树桩，年轮纹理 |
| W-FO5 | bush_berry | 浆果丛 | 32×32 | 绿色灌木丛，红色浆果点缀 |
| W-FO6 | rock_big | 大岩石 | 32×32 | 灰色大石，青苔，表面裂纹 |
| W-FO7 | rock_small | 小石头 | 16×16 | 灰色鹅卵石 |
| W-FO8 | tall_grass | 高草丛 | 16×32 | 及腰高狗尾草/芦苇 |
| W-FO9 | flower_wild | 野花丛 | 16×16 | 零星黄/紫/白色野花 |
| W-FO10 | butterfly | 蝴蝶(动画) | 16×16 | 彩色蝴蝶翅膀扇动(2帧动画)，随机飞过 |
| W-FO11 | log | 倒下的圆木 | 32×16 | 横放的原木，截面年轮可见 |
| W-FO12 | bridge_wood | 木桥 | 48×16 | 横跨溪流的木板桥，有栏杆 |

---

## 🖼️ UI 界面素材 — 用于 Control / TextureRect / NinePatchRect

### 5.1 主菜单 (MainMenu)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| UI-01 | mm_background | 主菜单背景图 | 480×270(全屏) | 田园风光全景图——远处山峦、农舍、近处金色麦田、蓝天白云，GBA 色调 |
| UI-02 | mm_title | 游戏标题 | 320×48 | 毛笔字体"国风像素农场物语"，古风横幅感 |
| UI-03 | mm_title_seal | 标题印章装饰 | 32×32 | 红色篆刻印章效果小方块 |
| UI-04 | mm_btn_newgame | "新游戏"按钮 | 96×32 | 木牌/竹简背景，刻字"新游戏" |
| UI-05 | mm_btn_continue | "继续游戏"按钮 | 96×32 | 同上，刻字"继续" |
| UI-06 | mm_btn_exit | "退出"按钮 | 96×32 | 同上，刻字"退出" |
| UI-07 | mm_btn_hover | 按钮高亮 | 96×32 | 按钮悬停时加金色边框/发光 |
| UI-08 | mm_deco_cloud | 装饰浮云 | 48×16 | 白色云朵，主菜单缓慢飘过(2帧) |
| UI-09 | mm_deco_bird | 装饰飞鸟 | 16×16 | 远处飞过的鸟影(2帧) |

### 5.2 HUD (Heads-Up Display)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| UI-10 | hud_panel_bg | HUD 背景板 | 可扩展 | 半透明深色横幅背景，顶部或底部，使用九宫格 |
| UI-11 | hud_corner_tl | HUD 框左上角 | 8×8 | 浅木色装饰角 |
| UI-12 | hud_corner_tr | HUD 框右上角 | 8×8 | 同上 |
| UI-13 | hud_corner_bl | HUD 框左下角 | 8×8 | 同上 |
| UI-14 | hud_corner_br | HUD 框右下角 | 8×8 | 同上 |
| UI-15 | hud_edge_h | HUD 边(水平) | 8×8 | 水平边框填充 |
| UI-16 | hud_edge_v | HUD 边(垂直) | 8×8 | 垂直边框填充 |
| UI-17 | hud_icon_time | 时辰图标 | 16×16 | 日晷/太阳图标，代表当前时辰 |
| UI-18 | hud_icon_season | 季节图标 | 16×16 | 春(🌸)夏(🌻)秋(🍂)冬(❄️) 四季各一种 4 状态 |
| UI-19 | hud_icon_term | 节气图标 | 16×16 | 24 节气通用标记——卷轴样式 |
| UI-20 | hud_icon_money | 铜钱图标 | 16×16 | 圆形方孔铜钱，"文"字样 |
| UI-21 | hud_hotbar_bg | 快捷栏背景 | 8×8(九宫格) | 半透明木色格子底 |
| UI-22 | hud_hotbar_slot | 快捷栏格子 | 32×32 | 深色格子边框，可放物品 |
| UI-23 | hud_hotbar_select | 快捷栏选中框 | 32×32 | 金色高亮边框，标识当前选中格 |

### 5.3 背包界面 (Inventory)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| UI-24 | inv_backdrop | 背包面板背景 | 240×200 可缩放 | 羊皮纸/宣纸纹理底，深色半透明外框 |
| UI-25 | inv_title_bg | 标题横幅 | 240×24 | 写"行囊"字样的古风横幅 |
| UI-26 | inv_slot_bg | 物品格子 | 48×48 | 旧木色方格，内嵌线框 |
| UI-27 | inv_slot_highlight | 格子高亮 | 48×48 | 鼠标悬停/选中时的金色光晕框 |
| UI-28 | inv_icon_default | 空位默认图标 | 16×16 | 格子底部浅色纹理（空位时可见） |
| UI-29 | inv_close_btn | 关闭按钮 | 24×24 | 红色圆形×号，或木制小叉 |
| UI-30 | inv_tab_bg | 分类标签 | 48×24 | 小型竖排标签（全部/工具/材料/食物） |
| UI-31 | inv_tab_active | 标签(激活) | 48×24 | 高亮版本 |

### 5.4 商店界面 (Shop)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| UI-32 | shop_backdrop | 商店面板背景 | 280×240 可缩放 | 木板纹理，比背包更厚实 |
| UI-33 | shop_title_bg | 店名横幅 | 280×24 | 写"杂货铺"等店名的木匾 |
| UI-34 | shop_item_row | 商品行背景 | 280×32 | 浅色木纹条，分隔商品 |
| UI-35 | shop_buy_btn | "购买"按钮 | 64×24 | 绿色/木色小按钮 |
| UI-36 | shop_sell_btn | "出售"按钮 | 64×24 | 红色/木色小按钮 |
| UI-37 | shop_money_display | 金钱显示框 | 80×24 | "持有: ●●文"的显示框 |
| UI-38 | shop_list_scroll | 滚动条 | 8×16 | 古朴的竹制滚动条滑块 |

### 5.5 制作界面 (Crafting)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| UI-39 | craft_backdrop | 制作面板背景 | 280×240 | 操作台纹理，木工台/灶台风格 |
| UI-40 | craft_title_bg | 标题 | 280×24 | "制作"字样 |
| UI-41 | craft_recipe_slot | 配方列表项 | 280×32 | 配方行背景 |
| UI-42 | craft_result_icon | 产物大图标框 | 48×48 | 中央大格展示制作产物 |
| UI-43 | craft_ingredient_icon | 材料小图标框 | 24×24 | 材料清单中每个材料的位置 |
| UI-44 | craft_btn | "制作"按钮 | 80×24 | 绿色按钮，有锤子/锅铲小图标 |
| UI-45 | craft_btn_disabled | 按钮(不可用) | 80×24 | 灰色版，表示材料不足 |
| UI-46 | craft_tab_kitchen | 标签-厨房 | 48×24 | 灶台图标 |
| UI-47 | craft_tab_workshop | 标签-工坊 | 48×24 | 铁砧/齿轮图标 |
| UI-48 | craft_tab_outdoor | 标签-户外 | 48×24 | 树木/锯子图标 |

### 5.6 节气日历 (Calendar)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| UI-49 | cal_backdrop | 日历面板背景 | 320×240 | 古风卷轴展开样式，宣纸底 |
| UI-50 | cal_title | 标题"节气历" | 320×20 | 卷轴顶部书写的大字 |
| UI-51 | cal_term_bg | 节气格子 | 48×32 | 每个节气一个小方框 |
| UI-52 | cal_term_current | 当前节气高亮 | 48×32 | 红色/金色框线的选中态 |
| UI-53 | cal_term_spring | 春季标记 | 16×16 | 小绿叶标记（放入格子左上角） |
| UI-54 | cal_term_summer | 夏季标记 | 16×16 | 小太阳标记 |
| UI-55 | cal_term_autumn | 秋季标记 | 16×16 | 小红叶标记 |
| UI-56 | cal_term_winter | 冬季标记 | 16×16 | 小雪花标记 |
| UI-57 | cal_effect_desc | 节气效果描述框 | 280×32 | 当前节气文字说明区域 |

---

## 🌱 作物各阶段生长状态 (Crop Growth Sprites)

> 通用耕地图块集（F-04~F-08）提供通用生长显示，但不同作物在成熟时应显示不同外观。
> 以下为每个作物的**成熟期**和**产物**精灵，叠加在耕地图块之上显示。

| 编号 | 对应的 CropId | 阶段 | 规格 | 长得像什么 |
|------|-------------|------|------|-----------|
| C-01 | turnip_stage1 | 幼苗 | 16×16 | 两片圆形子叶破土 |
| C-02 | turnip_stage2 | 成株 | 16×16 | 绿叶簇，隐约见白萝卜顶 |
| C-03 | turnip_mature | 成熟 | 16×16 | 白萝卜半露地面，绿叶茂盛 |
| C-04 | cabbage_stage1 | 幼苗 | 16×16 | 小圆叶对生 |
| C-05 | cabbage_stage2 | 成株 | 16×16 | 开始包心，球形 |
| C-06 | cabbage_mature | 成熟 | 16×16 | 紧实圆白菜，绿色纹路 |
| C-07 | tomato_stage1 | 幼苗 | 16×16 | 羽状复叶幼苗 |
| C-08 | tomato_stage2 | 成株 | 16×16 | 高植株，开黄花 |
| C-09 | tomato_mature | 成熟 | 16×16 | 挂红色番茄果实 |
| C-10 | rice_stage1 | 秧苗 | 16×16 | 细长绿苗，水中倒影 |
| C-11 | rice_stage2 | 分蘖 | 16×16 | 绿色稻丛 |
| C-12 | rice_mature | 成熟 | 16×16 | 金黄色稻穗低垂 |
| C-13 | wheat_mature | 成熟 | 16×16 | 金黄色麦穗 |
| C-14 | corn_mature | 成熟 | 16×16 | 玉米秆结玉米棒，紫红须 |
| C-15 | pumpkin_mature | 成熟 | 16×16 | 藤蔓中露出橙色大南瓜 |
| C-16 | eggplant_mature | 成熟 | 16×16 | 紫茄子挂枝 |
| C-17 | chili_mature | 成熟 | 16×16 | 红辣椒簇生 |
| C-18 | watermelon_mature | 成熟 | 16×16 | 绿条纹大西瓜，藤蔓 |

---

## 🎨 粒子/特效 (Particles & Effects)

| 编号 | 名称 | 用途 | 规格 | 长得像什么 |
|------|------|------|------|-----------|
| E-01 | fx_hoe_hit | 锄地特效 | 16×16(4帧) | 泥土飞溅的小粒子，棕色小块 |
| E-02 | fx_water_splash | 浇水粒子 | 16×16(4帧) | 水滴飞散，蓝色透明粒子 |
| E-03 | fx_harvest_sparkle | 收获闪光 | 16×16(3帧) | 金黄色星星闪光 |
| E-04 | fx_seed_plant | 播种粒子 | 8×8(2帧) | 绿色小光点从手撒落 |
| E-05 | fx_money_gain | 赚钱飘字+图标 | 16×16(3帧) | 铜钱图标+数字向上飘 |
| E-06 | fx_water_droplet | 水滴(浇水壶) | 8×8(2帧) | 蓝色水滴从壶嘴飞出 |

---

## 📐 技术规格汇总

| 维度 | 数值 |
|------|------|
| Tile 基础单元 | 16×16 像素 |
| 角色精灵大小 | 32×32 (碰撞箱 16×16) |
| UI 设计分辨率 | 480×270 (Godot window size) |
| 显示缩放 | 整数倍放大到 960×540 / 1440×810 |
| 调色板风格 | GBA 15-bit 色彩，每色不超过 16 阶 |
| 动画帧率 | 行走 4帧/1.5s 循环，工具 2帧/0.5s，粒子 2~4帧/0.3s |
| 色板限制 | 每个 sprite 不超过 16 色（GBA风格） |
| 朝向系统 | 4 方向（下/上/左/右），左右可镜像翻转 |

---

## 📝 后续工作

1. **Aseprite Lua 脚本** — 为每个素材编写 Aseprite Lua 脚本，自动生成对应规格的画布、图层结构、参考色板
2. **生成调色板** — 定义项目全局调色板文件（国风田园色系：土棕、草绿、瓦灰、米白、朱红）
3. **批量导出** — 脚本自动导出为 PNG 并放入对应 `art/` 目录
4. **Godot 导入配置** — 配置 .import 文件，设置纹理滤波、重复模式等
