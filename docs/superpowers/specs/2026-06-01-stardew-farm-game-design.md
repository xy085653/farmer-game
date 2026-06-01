# 国风像素农场物语 — 设计文档

> 基于 Godot 4.6 + C# (.NET) 的 2D 像素农场游戏
> 类似星露谷物语，融合中国二十四节气文化
> 设计日期：2026-06-01

---

## 1. 项目概览

### 1.1 游戏定位
2D 顶视角像素农场经营模拟游戏，以中国传统田园生活为背景，以**二十四节气**为核心时间机制。

### 1.2 MVP 范围（初始版本）
- 🌾 **种田系统** — 耕地、播种、浇水、生长、收获、季节轮换
- 🔨 **制作/建造** — 配方合成、工具升级、建筑建造
- 💰 **经济系统** — 商店买卖、出货箱、物价波动

### 1.3 视觉风格
**GBA 像素风** — 类似牧场物语 GBA 版，色彩饱和，角色比例 32×48，细节丰富，顶视角俯视。

### 1.4 明确不包含（将来版本再考虑）
以下系统在 MVP 阶段 **不实现**，留待后续版本：
- 🎣 钓鱼系统
- ⛏️ 挖矿/战斗系统
- 💑 社交/恋爱系统
- 🎪 节日活动

### 1.5 操作方式
全平台支持：键盘 + 鼠标、纯键盘、游戏手柄。

---

## 2. 核心架构

### 2.1 四层架构

```
┌──────────────────────────────────────────┐
│  🎮 表现层 (View/Scene)                   │
│  Player.cs / CropSprite / UI / TileMap   │
│  ↓ 发送事件   ↑ 订阅事件                   │
├──────────────────────────────────────────┤
│  🔗 事件总线 (EventBus) — 单例 Autoload   │
│  C# event Action<T> / 系统间零耦合通信    │
│  ↓ 调度   ↑ 监听                          │
├──────────────────────────────────────────┤
│  ⚙️ 服务层 (Services) — 接口 + 实现        │
│  ITimeService / IFarmService / ...       │
│  ↓ 读写   ↑ 通知                          │
├──────────────────────────────────────────┤
│  💾 数据层 (Data / Resource)              │
│  CropData / SeasonData / SaveData        │
│  Godot Resource (.tres) + JSON 持久化     │
└──────────────────────────────────────────┘
```

### 2.2 事件总线 (EventBus)
- Godot Autoload 单例
- 所有系统间通过 C# `event Action<T>` 通信
- 发布者不关心谁在监听，监听者不关心谁在发布
- 事件示例：`DayStartedEvent`, `SeedPlantedEvent`, `ItemHarvestedEvent`, `TransactionEvent`

### 2.3 服务注册中心 (ServiceRegistry)
- 管理所有服务实例的生命周期
- 游戏启动时注册，关闭时释放
- 服务只通过接口引用，实现可替换

### 2.4 六大核心服务

| 服务 | 职责 | 事件 |
|------|------|------|
| **ITimeService** | 二十四节气 + 昼夜 | OnSolarTermChanged, OnPhaseChanged, OnSeasonChanged |
| **IFarmService** | 耕地 + 作物生长 | OnSeedPlanted, OnCropGrown, OnHarvested |
| **IInventoryService** | 背包 + 物品管理 | OnItemAdded, OnItemRemoved, OnSlotChanged |
| **IEconomyService** | 金钱 + 商店 + 出货 | OnMoneyChanged, OnItemSold, OnShopOpen |
| **IWorldService** | 地图区块 + 场景管理 | OnPlayerMovedMap, OnTimeOfDayChanged |
| **ICraftService** | 合成 + 建筑 | OnRecipeCrafted, OnBuildingPlaced |

---

## 3. 二十四节气时间系统

### 3.1 时间层次
```
年 (Year)
  └─ 季 (Season): 春 / 夏 / 秋 / 冬
       └─ 节气 (SolarTerm): 每季 6 个，共 24 个
            └─ 天 (Day): 每个节气 3 天
                 └─ 时段 (Phase): 晨 / 午 / 夕 / 夜
```

### 3.2 二十四节气列表

| 季节 | 节气 | 游戏内影响 |
|------|------|-----------|
| 🌸 春 | 立春 → 雨水 → 惊蛰 → 春分 → 清明 → 谷雨 | 播种季，作物生长加速，谷雨宜种水稻 |
| ☀️ 夏 | 立夏 → 小满 → 芒种 → 夏至 → 小暑 → 大暑 | 生长高峰，需浇水抗旱，芒种最佳播种期 |
| 🍂 秋 | 立秋 → 处暑 → 白露 → 秋分 → 寒露 → 霜降 | 丰收季，霜降后作物可能冻死 |
| ❄️ 冬 | 立冬 → 小雪 → 大雪 → 冬至 → 小寒 → 大寒 | 休耕季，室内制作、节日活动 |

### 3.3 每日时段
| 时段 | 时间 | 现实时长 |
|------|------|---------|
| 🌅 晨 | 6:00-10:00 | ~2 分钟 |
| ☀️ 午 | 10:00-16:00 | ~3 分钟 |
| 🌆 夕 | 16:00-20:00 | ~2 分钟 |
| 🌙 夜 | 20:00-6:00 | ~1 分钟（跳过，进入休息）|

### 3.4 节气对游戏的影响
- 每个节气有特定的"宜忌"作物（谷雨宜种水稻，白露宜收瓜果）
- 节气当天触发 buff/debuff（立春耕地不耗体力，大暑浇水需求减半）
- 节气变换时触发天气事件（下雨、打雷、降温）
- 全年 24 节气循环，每节气 3 天 = 一年 72 天

### 3.5 核心接口

```csharp
interface ITimeService {
    GameTime CurrentTime { get; }
    SolarTerm CurrentTerm { get; }
    event Action<SolarTerm> OnSolarTermChanged;
    event Action<DayPhase> OnPhaseChanged;
    event Action<Season> OnSeasonChanged;
    void AdvanceToNextDay();
}
```

---

## 4. 地图/世界系统

### 4.1 五大区域
- **🏘️ 农场** — 主角农场，可耕地、建造，核心玩法区域
- **🏪 小镇** — 商店、杂货铺、升级工坊
- **🌲 森林/野外** — 采集资源、偶遇事件
- **⛰️ 山地** — 矿产、石材资源
- **🏞️ 河边/湖边** — 水资源、季节性景观

### 4.2 地图技术方案
- 使用 Godot 4 `TileMapLayer` 分层渲染
  - `GroundLayer` — 地形（草地/耕地/道路）
  - `DecorationLayer` — 装饰（花/草/石头）
  - `BuildingLayer` — 建筑（房子/篱笆）
  - `ObjectLayer` — 互动对象（箱子/机器）
- 摄像机跟随玩家，`Clamp` 到地图边界
- 分区块加载避免一次渲染全图

---

## 5. 种田系统

### 5.1 核心流程

```
① 整地: 用锄头在草地 → "已耕"泥土状态
② 播种: 手持种子 → 点击耕地 → 消耗种子 + 体力 → 出现小苗
③ 浇水: 用水壶浇灌 → 保持湿润（每日必需）
④ 生长: 每天结束时 → 判断水分+节气 → 推进生长阶段 (4-6 阶段)
⑤ 收获: 成熟后 → 右键收获 → 物品进背包（部分可连续收获）
```

### 5.2 作物数据 Resource

```csharp
[GlobalClass]
public partial class CropData : Resource {
    string CropName;              // "水稻"
    Texture2D[] GrowthStages;     // 5 个生长阶段精灵
    float BaseGrowthDays;         // 基础生长天数
    SolarTerm[] PreferredTerms;   // 宜种节气(谷雨等)
    ItemData HarvestItem;         // 收获产物
    bool CanRegrow;               // 是否可连续收获
    int RegrowDays;               // 再生间隔
    Season[] AllowedSeasons;      // 可种植季节
}
```

### 5.3 耕地 Tile 状态机
```
普通草地 → 已耕(干) → 已耕(湿) → 已种植(阶段1) → ... → 成熟
                ↑                        ↑
            不浇水变干              每天推进阶段
```

---

## 6. 制作/建造系统

### 6.1 制作分类
| 类型 | 说明 | 示例 |
|------|------|------|
| 🔧 工具升级 | 铜→银→金 | 锄头、水壶、斧头 |
| 🥘 加工 | 农产品增值 | 稻谷→米, 水果→果酱 |
| 🏠 建筑 | 设施建造 | 仓库、工坊、厨房 |
| 🎁 特殊 | 装饰/礼物 | 节气灯笼 |

### 6.2 配方数据 Resource

```csharp
[GlobalClass]
public partial class RecipeData : Resource {
    ItemData ResultItem;       // 产出物品
    int ResultCount;           // 产出数量
    Ingredient[] Ingredients;  // 所需材料 [{itemId, count}]
    WorkbenchType Bench;       // 在哪制作
    int RequiredLevel;         // 需要的工具等级
}
```

### 6.3 建筑发展路线
- **初期**: 小木屋（家）、3×3 耕地
- **中期**: 仓库、工坊、厨房、扩大耕地
- **后期**: 房屋升级、自动灌溉、酿酒坊、节气祭坛

---

## 7. 经济系统

### 7.1 货币
- **🪙 铜钱** — 基础货币，以"文"为单位

### 7.2 交易场所
- **🏪 杂货铺** — 购买种子、工具、日常用品
- **📦 出货箱** — 放在家门口，农产品自动出售
- **📜 订单板** — 村民发布需求，完成后获得额外奖励

### 7.3 经济循环
```
🌾 种田 → 🧺 收获 + 加工增值 → 📦 出货/🏪 出售
    → 🪙 获得铜钱 → 买种子/工具升级
    → 生产效率提升 → 更多产出
```

**节气物价系统**: 应季作物价格更高，反季作物价格降低。

---

## 8. 物品/背包系统

### 8.1 物品分类
- 🌱 **种子** — 各类作物种子
- 🌾 **农产品** — 收获的作物
- 🥘 **加工品** — 制作加工的产物
- 🔧 **工具** — 农具/工具
- 🧱 **建材** — 建筑原材料
- 🎁 **特殊** — 任务物品/礼物

### 8.2 背包设计
- 主背包 24 格（可升级扩充）
- 快捷工具栏 8 格（对应数字键 1-8）
- 同类物品可堆叠（最大 99）

---

## 9. 玩家控制

### 9.1 键鼠
| 操作 | 按键 |
|------|------|
| 移动 | WASD / 方向键 |
| 交互/使用工具 | 鼠标左键 / Space |
| 拾取/菜单 | 鼠标右键 / E |
| 切换工具 | 数字键 1-8 / 鼠标滚轮 |
| 打开背包 | Tab / I |
| 菜单/暂停 | Esc |

### 9.2 手柄
- 左摇杆 / 十字键 — 移动
- A / B / X / Y — 交互/工具/背包/菜单
- RB/LB — 切换工具

---

## 10. 数据持久化

### 10.1 自动保存
- 每天结束时自动保存
- 保存内容: 玩家位置、背包、耕地状态、金钱、天数、建筑
- 使用 Godot 4 内置加密 API `FileAccess.OpenEncryptedWithPass`，AES 加密二进制格式
- 存储路径: `user://saves/save.dat`
- 同时保存 SHA256 校验值，加载时验证数据完整性
- 开发模式下可通过编译标志切换为明文 JSON 方便调试

```csharp
// 保存
var file = FileAccess.OpenEncryptedWithPass(savePath, FileAccess.ModeFlags.Write, "game-key-v1");
file.StoreVar(saveData);  // Dictionary 自动序列化
file.Close();

// 加载
var file = FileAccess.OpenEncryptedWithPass(savePath, FileAccess.ModeFlags.Read, "game-key-v1");
var data = file.GetVar() as Dictionary;
file.Close();
```

### 10.2 配置数据
- 所有游戏数据使用 Godot `Resource` 子系统
- `CropData.tres` — 作物数据表
- `RecipeData.tres` — 配方表
- `ItemData.tres` — 物品数据库
- 数据可随时编辑，无需改代码

---

## 11. 项目结构

```
res://
├── addons/                  # 第三方插件
├── scenes/
│   ├── Game.tscn            # 主场景入口
│   ├── UI/                  # UI 场景
│   │   ├── HUD.tscn         # 游戏内 HUD
│   │   ├── Inventory.tscn   # 背包界面
│   │   ├── Shop.tscn        # 商店界面
│   │   └── Calendar.tscn    # 节气日历
│   ├── Player/
│   │   ├── Player.tscn      # 玩家角色
│   │   └── Player.cs        # 玩家控制逻辑
│   ├── World/
│   │   ├── Farm.tscn        # 农场地图
│   │   ├── Town.tscn        # 小镇地图
│   │   └── Forest.tscn      # 森林地图
│   └── Objects/
│       ├── Crop.tscn        # 作物实例
│       ├── HoeDirt.tscn     # 耕地块
│       └── Building.tscn    # 建筑实例
├── scripts/
│   ├── Core/
│   │   ├── EventBus.cs      # 事件总线 (Autoload)
│   │   └── ServiceRegistry.cs
│   ├── Services/
│   │   ├── ITimeService.cs / TimeService.cs
│   │   ├── IFarmService.cs / FarmService.cs
│   │   ├── IInventoryService.cs / InventoryService.cs
│   │   ├── IEconomyService.cs / EconomyService.cs
│   │   ├── IWorldService.cs / WorldService.cs
│   │   └── ICraftService.cs / CraftService.cs
│   ├── Data/
│   │   ├── CropData.cs
│   │   ├── RecipeData.cs
│   │   ├── ItemData.cs
│   │   └── GameTime.cs
│   └── Events/
│       ├── TimeEvents.cs
│       ├── FarmEvents.cs
│       ├── InventoryEvents.cs
│       └── EconomyEvents.cs
├── resources/
│   ├── Crops/              # 作物数据 .tres
│   ├── Recipes/            # 配方数据 .tres
│   └── Items/              # 物品数据 .tres
├── art/
│   ├── tilesets/           # 地图瓦片集
│   ├── sprites/            # 角色/物体精灵
│   └── ui/                 # UI 素材
├── project.godot
└── docs/
    └── superpowers/
        └── specs/          # 设计文档
```
