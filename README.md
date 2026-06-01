# 🌾 国风像素农场物语

> **GBA 像素风 × 二十四节气 × 中国传统田园生活**

基于 Godot 4.6 + C# (.NET) 开发的 2D 像素农场经营模拟游戏，灵感来自《星露谷物语》，融合中国传统文化中的**二十四节气**机制。

![Godot 4.6](https://img.shields.io/badge/Godot-4.6-478cbf?logo=godot&logoColor=white)
![C#](https://img.shields.io/badge/C%23-12.0-239120?logo=csharp&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-8-512BD4?logo=dotnet&logoColor=white)

---

## 🎮 游戏特色

- **🌾 种田系统** — 整地 → 播种 → 浇水 → 生长 → 收获，完整的农耕流程
- **📅 二十四节气** — 立春、谷雨、芒种、霜降等节气影响作物生长和物价
- **🔨 制作/建造** — 工具升级、农产品加工、建筑建造
- **💰 经济系统** — 铜钱交易、出货箱、节气物价波动
- **🗺️ 大世界地图** — 农场、小镇、森林多区域探索
- **🎨 GBA 像素风** — 色彩饱和的 16-bit 像素画风

## 🏗️ 技术架构

```
表现层 (Scene/UI) ← 事件总线 (EventBus) → 服务层 (Services) → 数据层 (Resource)
```

- **事件驱动架构** — 系统间通过 EventBus 零耦合通信
- **C# 接口设计** — 所有服务通过接口引用，可替换可测试
- **AES 加密存档** — 使用 Godot 内置 `FileAccess.OpenEncryptedWithPass`
- **全平台操作** — 键鼠 + 纯键盘 + 手柄

## 📂 项目结构

```
res://
├── scripts/          # C# 脚本
│   ├── Core/         # EventBus, ServiceRegistry, GameManager
│   ├── Services/     # 6 大服务接口 + 实现
│   ├── Data/         # 游戏数据模型 (Resource)
│   ├── Events/       # 事件类型定义
│   ├── Player/       # 玩家控制器
│   ├── UI/           # UI 控制器
│   ├── World/        # 世界/耕地管理
│   └── Save/         # 存档管理
├── scenes/           # Godot 场景
│   ├── Player/
│   ├── UI/           # HUD, 背包, 商店, 日历, 制作面板
│   └── World/        # 农场, 小镇, 森林
├── resources/        # 游戏数据配置
│   ├── Crops/
│   ├── Items/
│   └── Recipes/
└── art/              # 美术资源
    ├── tilesets/
    ├── sprites/
    └── ui/
```

## 🚀 快速开始

1. 安装 **Godot 4.6 (.NET 版)** 和 **.NET 8 SDK**
2. 克隆本仓库
3. 用 Godot 编辑器打开项目
4. 引擎会自动生成 `.csproj` 并编译 C# 脚本
5. 在编辑器中点击 ▶ 运行

> ⚠️ 首次打开需要 Godot 生成 `.csproj` 文件并编译。如果编译报错，请检查 .NET SDK 版本。

## 🗺️ 开发路线

- ✅ **MVP** — 种田 + 制作/建造 + 经济 + 节气 + 地图
- ⬜ **Phase 2** — 钓鱼系统、NPC 社交
- ⬜ **Phase 3** — 挖矿/战斗、更多节日事件
- ⬜ **Phase 4** — 剧情线、成就系统

## 📜 设计文档

- [设计文档](docs/superpowers/specs/2026-06-01-stardew-farm-game-design.md)
- [实施计划](docs/superpowers/plans/2026-06-01-stardew-farm-game-implementation.md)

---

> 🌱 春耕夏耘，秋收冬藏 — 在像素世界中感受中国节气之美
