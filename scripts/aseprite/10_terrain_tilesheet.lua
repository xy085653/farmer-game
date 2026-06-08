--------------------------------------------------------------------------------
--  地形图块集生成脚本 (terrain_tilesheet)
--  在空白画布上运行，生成 16×16 地形图块排布成 tilesheet
--  输出适合 Godot TileMapLayer 使用的图块纹理
--
--  参考: https://www.aseprite.org/api/
--    image:clear(color)           -- 填充矩形
--    image:drawPixel(x, y, color) -- 画单个像素
--    image:drawImage(src, point)  -- 合成图像
--    cel.image = newImage         -- 替换 cel 图像
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 1. 颜色定义 (与项目 16 色调色板一致)
--------------------------------------------------------------------------------
local C = {}
C.bg     = Color(0xE8, 0xD4, 0xA8)  -- 宣纸米白
C.wood   = Color(0xC0, 0x8A, 0x53)  -- 木色
C.brown  = Color(0x8B, 0x5E, 0x3C)  -- 深棕
C.dark   = Color(0x5A, 0x3E, 0x2B)  -- 深褐(轮廓线)
C.grn    = Color(0x4A, 0x6F, 0x3A)  -- 草绿(基础)
C.lgrn   = Color(0x6B, 0x9E, 0x4A)  -- 嫩绿(植物)
C.dgrn   = Color(0x3A, 0x7D, 0x5C)  -- 深绿(树荫)
C.sky    = Color(0x7E, 0xC8, 0xE3)  -- 天蓝(水/天空)
C.blue   = Color(0x4A, 0x90, 0xD9)  -- 深蓝(水面)
C.red    = Color(0xD4, 0x4A, 0x3E)  -- 朱红
C.gold   = Color(0xE8, 0xA4, 0x3A)  -- 金黄
C.yel    = Color(0xF0, 0xD0, 0x78)  -- 淡黄
C.pink   = Color(0xD4, 0x7A, 0x9A)  -- 粉红
C.ochre  = Color(0x94, 0x6A, 0x4A)  -- 赭石
C.bone   = Color(0xF0, 0xE8, 0xD0)  -- 骨白
C.blk    = Color(0x2A, 0x2A, 0x2A)  -- 近黑

-- 简写颜色查找表：字符 -> Color
local COL = {
  ["."] = nil,        -- 透明
  ["b"] = C.bg,       -- 宣纸米白 (background)
  ["w"] = C.wood,     -- 木色
  ["n"] = C.brown,    -- 深棕
  ["k"] = C.dark,     -- 深褐 (dark)
  ["g"] = C.grn,      -- 草绿 (green)
  ["l"] = C.lgrn,     -- 嫩绿 (light green)
  ["d"] = C.dgrn,     -- 深绿 (dark green)
  ["s"] = C.sky,      -- 天蓝 (sky)
  ["u"] = C.blue,     -- 深蓝 (blue/water)
  ["r"] = C.red,      -- 朱红
  ["o"] = C.gold,     -- 金黄 (gold)
  ["y"] = C.yel,      -- 淡黄 (yellow)
  ["p"] = C.pink,     -- 粉红
  ["h"] = C.ochre,    -- 赭石 (ochre)
  ["e"] = C.bone,     -- 骨白 (bone)
  ["t"] = C.blk,      -- 近黑 (black/outline)

  -- 半色调: 小写字母表示纯色, 大写字母表示混入杂色纹理
  ["G"] = nil,  -- 草绿 + 随机深绿点 (在生成时处理)
  ["L"] = nil,  -- 嫩绿 + 随机草绿点
}

--------------------------------------------------------------------------------
-- 2. 图块像素数据 (每个图块 = 16x16 的字符矩阵)
--    字符映射到 COL 表中的颜色
--    "." = 透明
--------------------------------------------------------------------------------

-- 字符图块解析: 每行是一个字符串, 从左到右对应 16 列像素
-- 用 16 个字符表示一行 (因为一眼能看出模式)

local TILE_DATA = {}

-- T-01: grass_light (浅色草地)
TILE_DATA.grass_light = {
  ".llllllllllll..",
  "lllllllllllllll",
  "lllllllllllllll",
  "llllgllllllllll",
  "llllllllgllglll",
  "lllllllllllllll",
  "lllllglllllllll",
  "llllllllllgllll",
  "lllglllllllllll",
  "lllllllllllllll",
  "llllllllgllllll",
  "llllgllllllllgl",
  "lllllllllllllll",
  "lllllllllllllll",
  "llllllgllllllll",
  ".llllllllllll..",
}

-- T-02: grass_dark (深色草地 - 森林用)
TILE_DATA.grass_dark = {
  ".ddddddddddd...",
  "dddddddddddddd.",
  "ddddgdddddddddd",
  "dddddddddgddddd",
  "dddgddddddddddd",
  "dddddddddddgddd",
  "ddddgdddddddddd",
  "ddddddddddddddd",
  "ddddddddgdddddd",
  "ddgdddddddddddd",
  "ddddddddddddgdd",
  "ddddgdddddddddd",
  "ddddddddddddddd",
  "ddddddddgdddddd",
  "ddddddddddddgdd",
  ".ddddddddddd...",
}

-- T-03: soil_dry (干土)
TILE_DATA.soil_dry = {
  "................",
  "..hhhhhhhhhh....",
  ".hhhhhhhhhhhh...",
  ".hhhhhhhhhhhh...",
  ".hhhhhhhhhhhh...",
  ".hhShhhhShhhhh..",
  ".hhhhhhhhhhhh...",
  ".hhhhhShhhhhh...",
  ".hhhhhhhhhhhh...",
  ".hhShhhhhhShh...",
  ".hhhhhhhhhhhh...",
  ".hhhhhhhhhhhh...",
  ".hhhhhhhhhhhh...",
  "..hhhhhhhhhh....",
  "................",
  "................",
}
-- 修正: soil_dry 中的 S 实际上是 ochre 的变体, 用 h
-- 重新定义 soil_dry 不使用 S
TILE_DATA.soil_dry = {
  "................",
  "..hhhhhhhhhh....",
  ".hhhhhhhhhhhh...",
  ".hhhhhhhhhhhh...",
  ".hhhhhhhhhhhh...",
  ".hh nh nh hhh...",
  ".hhhhhhhhhhhh...",
  ".hhhh nh hhhh...",
  ".hhhhhhhhhhhh...",
  ".hh nh hh nhh...",
  ".hhhhhhhhhhhh...",
  ".hhhhhhhhhhhh...",
  ".hhhhhhhhhhhh...",
  "..hhhhhhhhhh....",
  "................",
  "................",
}

-- T-04: soil_wet (湿土)
TILE_DATA.soil_wet = {
  "................",
  "..nnnnnnnnnn....",
  ".nnnnnnnnnnnnn..",
  ".nnnnnnnnnnnnn..",
  ".nnn nnnn nnnn..",
  ".nnnhnnnnhnnnn..",
  ".nnnnnnnnnnnnn..",
  ".nnnnnnnnnnnnn..",
  ".nnnn nnnnnnnn..",
  ".nnnhnnnnnnhnn..",
  ".nnnnnnnnnnnnn..",
  ".nnnnnnnnnnnnn..",
  ".nnnnnnnnnnnnn..",
  "..nnnnnnnnnn....",
  "................",
  "................",
}

-- T-05: path_dirt (泥路)
TILE_DATA.path_dirt = {
  "................",
  "...oooooooo.....",
  "..ooooo oooo....",
  "..oooooooooo....",
  "..oo oooooooo...",
  "..oooooooo oo...",
  "..oooooooooo....",
  "...oooooooo.....",
  "....ooooooo.....",
  "...ooooooooo....",
  "..oooooooooo....",
  "..oooo oooooo...",
  "..oooooooooo....",
  "...oooooooo.....",
  "................",
  "................",
}
-- 修正: path_dirt 用 ochre + 混入 dry soil
-- 重新定义用 h (ochre) 和少量 w (木色)
TILE_DATA.path_dirt = {
  "................",
  "...hhhhhhhh.....",
  "..hhhhhhwhhh....",
  "..hhhhhhhhhh....",
  "..hhwhhhhhhhh...",
  "..hhhhhhhhwhh...",
  "..hhhhhhhhhh....",
  "...hhhhhhhh.....",
  "....hhhhhhh.....",
  "...hhhhhhhhh....",
  "..hhhhhhhhhh....",
  "..hhhhwhhhhh....",
  "..hhhhhhhhhh....",
  "...hhhhhhhh.....",
  "................",
  "................",
}

-- T-06: water_tile (水面, 2 帧动画)
TILE_DATA.water_tile = {}
TILE_DATA.water_tile[1] = {
  "uuuuuuuuuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
  "uusuuuuuuuusuuuu",
  "uuuuuuuuuuuuuuuu",
  "uuuuusuuuuuuuuuu",
  "uuuuuuuuuuuusuuu",
  "uusuuuuuuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
  "uuuuuusuuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
  "uuuuuuuusuuuuuuu",
  "uusuuuuuuuuuuuuu",
  "uuuuuuuuuuuusuuu",
  "uuuuuuuuuuuuuuuu",
  "uuuuuusuuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
}
TILE_DATA.water_tile[2] = {
  "uuuuuuuuuuuuuuuu",
  "uuuusuuuuuuuuuuu",
  "uuuuuuuuuusuuuuu",
  "uuuuuuuuuuuuuuuu",
  "usuuuuuuuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
  "uuuuusuuuuuuuuuu",
  "uuuuuuuuuuusuuuu",
  "uuuuuuuuuuuuuuuu",
  "uusuuuuuuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
  "uuuuuuusuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
  "uuusuuuuuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
  "uuuuuuuusuuuuuuu",
}

-- T-07: water_edge_top (水岸上)
TILE_DATA.water_edge_top = {
  "llllllllllllllll",
  "llllllllllllllll",
  "llllllllllllllll",
  "llllllllllllllll",
  "................",
  ".......u........",
  "......uuu.......",
  ".....uuuuu......",
  "....uuuuuuu.....",
  "...uuuuuuuuu....",
  "..uuuuuuuuuuu...",
  ".uuuuuuuuuuuuu..",
  "uuuuuuuuuuuuuuuu",
  "uuuuuuuuuuuuuuuu",
  "uuuusuuuuuusuuuu",
  "uuuuuuuuuuuuuuuu",
}

-- T-08: fence_wood_h (木栅栏横)
TILE_DATA.fence_wood_h = {
  "................",
  "................",
  "..nkn..nkn..nkn.",
  "..www..www..www.",
  "..nkn..nkn..nkn.",
  "................",
  "................",
  "nnnnnnnnnnnnnnnn",
  "wwwwwwwwwwwwwwww",
  "nnnnnnnnnnnnnnnn",
  "................",
  "................",
  "..nkn..nkn..nkn.",
  "..www..www..www.",
  "..nkn..nkn..nkn.",
  "................",
}

-- T-09: fence_wood_v (木栅栏竖)
TILE_DATA.fence_wood_v = {
  "......nnn.......",
  "......www.......",
  "......nnn.......",
  ".......n........",
  ".......w........",
  ".......n........",
  ".......n........",
  ".......w........",
  ".......n........",
  ".......n........",
  ".......w........",
  ".......n........",
  "......nnn.......",
  "......www.......",
  "......nnn.......",
  ".......n........",
}

--------------------------------------------------------------------------------
-- 3. 图块布局: 在 tilesheet 上的行列位置
--    { name, row, col, frames }  帧数 >1 表示动画图块
--------------------------------------------------------------------------------
local TILE_LAYOUT = {
  { name = "grass_light",    row = 0, col = 0, frames = 1 },
  { name = "grass_dark",     row = 0, col = 1, frames = 1 },
  { name = "soil_dry",       row = 0, col = 2, frames = 1 },
  { name = "soil_wet",       row = 0, col = 3, frames = 1 },
  { name = "path_dirt",      row = 0, col = 4, frames = 1 },
  { name = "water_tile",     row = 1, col = 0, frames = 2 },
  { name = "water_edge_top", row = 1, col = 2, frames = 1 },
  { name = "fence_wood_h",   row = 1, col = 3, frames = 1 },
  { name = "fence_wood_v",   row = 1, col = 4, frames = 1 },
}

local TILE_SIZE = 16  -- 每个图块 16×16
local COLS = 8        -- tilesheet 列数
local ROWS = 4        -- tilesheet 行数

--------------------------------------------------------------------------------
-- 4. 绘图函数
--------------------------------------------------------------------------------

-- 解析一个字符并返回颜色, 支持半色调大写字母的随机混色
local rng = nil  -- 没有随机种子, 用固定偏移保证可复现
local offset = 0

function parseChar(ch, x, y)
  local color = COL[ch]
  if color then
    return color  -- 纯色, 直接返回
  end

  -- 大写字母 = 主色 + 杂色点 (基于位置决定, 确保确定性)
  if ch == "G" then
    -- 草绿底 + 随机深绿点 (基于坐标)
    if (x + y * 3) % 5 == 0 or (x * 7 + y) % 4 == 0 then
      return C.dgrn
    end
    return C.grn
  end
  if ch == "L" then
    if (x + y * 2) % 4 == 0 then
      return C.grn
    end
    return C.lgrn
  end
  if ch == "S" then
    if (x * 3 + y) % 3 == 0 then
      return C.brown
    end
    return C.ochre
  end

  return nil  -- 透明
end

-- 根据字符串数组绘制一个 16×16 图块
function drawTile(tileData, frameIndex)
  -- 如果没有多帧, frameIndex 为 1
  local data
  if type(tileData[1]) == "table" then
    -- 多帧: tileData = { frame1, frame2, ... }
    data = tileData[frameIndex or 1]
  else
    data = tileData
  end

  local img = Image(TILE_SIZE, TILE_SIZE, ColorMode.RGB)
  img:clear(Color(0, 0, 0, 0))

  for y = 0, TILE_SIZE - 1 do
    local row = data[y + 1]
    if row then
      for x = 0, TILE_SIZE - 1 do
        local ch = row:sub(x + 1, x + 1)
        if ch and ch ~= "" and ch ~= "." then
          local color = COL[ch]
          if not color and ch:match("%u") then
            -- 大写字母 = 半色调
            if ch == "G" then
              color = ((x + y * 3) % 5 == 0 or (x * 7 + y) % 4 == 0) and C.dgrn or C.grn
            elseif ch == "L" then
              color = ((x + y * 2) % 4 == 0) and C.grn or C.lgrn
            elseif ch == "S" then
              color = ((x * 3 + y) % 3 == 0) and C.brown or C.ochre
            elseif ch == "U" then
              color = ((x + y) % 3 == 0) and C.sky or C.blue
            else
              color = COL[ch:lower()]
            end
          end
          if color then
            img:drawPixel(x, y, color)
          end
        end
      end
    end
  end

  return img
end

-- 将图块绘制到 tilesheet 的指定位置
function blitTile(targetImg, tileData, gridCol, gridRow, frameIndex)
  local tileImg = drawTile(tileData, frameIndex)
  local px = gridCol * TILE_SIZE
  local py = gridRow * TILE_SIZE
  targetImg:drawImage(tileImg, Point(px, py))
end

--------------------------------------------------------------------------------
-- 5. 主逻辑: 生成 tilesheet
--------------------------------------------------------------------------------

local sprite = app.activeSprite
if not sprite then
  return app.alert("请先新建一个空白画布")
end

-- 确定需要的帧数 (取所有图块的最大帧数)
local maxFrames = 1
for _, t in ipairs(TILE_LAYOUT) do
  if t.frames and t.frames > maxFrames then
    maxFrames = t.frames
  end
end

-- 确认画布尺寸正确
local expectedW = COLS * TILE_SIZE
local expectedH = ROWS * TILE_SIZE
if sprite.width < expectedW or sprite.height < expectedH then
  return app.alert("画布太小！请新建 " .. expectedW .. "×" .. expectedH .. " 的 RGB 透明画布")
end

-- 先清空所有 cel
for _, cel in ipairs(sprite.cels) do
  cel.image:clear(Color(0, 0, 0, 0))
end

-- 设置网格辅助 (16×16)
sprite.gridBounds = Rectangle(0, 0, TILE_SIZE, TILE_SIZE)

-- 确保有足够的帧
while #sprite.frames < maxFrames do
  sprite:newEmptyFrame()
end

-- 构建一个颜色查找用的 palette (方便预览)
local pal = sprite.palettes[1]
local colorList = { C.bg, C.wood, C.brown, C.dark, C.grn, C.lgrn, C.dgrn,
                    C.sky, C.blue, C.red, C.gold, C.yel, C.pink, C.ochre,
                    C.bone, C.blk }
local oldCount = #pal
pal:resize(oldCount + #colorList)
for i, c in ipairs(colorList) do
  pal:setColor(oldCount + i - 1, c)
end
sprite:setPalette(pal)

-- 为每一帧生成 tilesheet
for frame = 1, maxFrames do
  -- 获取该帧的所有图层, 找一个可用的
  local targetLayer = nil
  for _, layer in ipairs(sprite.layers) do
    local cel = layer:cel(frame)
    if cel then
      targetLayer = layer
      break
    end
  end

  if not targetLayer then
    local l = sprite:newLayer()
    l.name = "tiles"
    local cel = sprite:newCel(l, frame)
    cel.image:clear(Color(0, 0, 0, 0))
    targetLayer = l
  end

  local cel = targetLayer:cel(frame)
  local img = cel.image

  -- 清空
  img:clear(Color(0, 0, 0, 0))

  -- 绘制每个图块
  for _, t in ipairs(TILE_LAYOUT) do
    local tileKey = t.name
    local tileData = TILE_DATA[tileKey]
    if tileData then
      local f = frame
      if t.frames and t.frames < frame then
        f = t.frames  -- 如果该图块帧数不够, 循环使用最后一帧
      end
      blitTile(img, tileData, t.col, t.row, f)
    end
  end
end

-- 缩放视图方便查看
app.command.Zoom { percentage = 400 }

-- 更新色板显示
app.refresh()

-- 输出完成信息
app.alert("地形图块集生成完成！\n"
  .. "尺寸: " .. expectedW .. "×" .. expectedH .. "\n"
  .. "图块: " .. #TILE_LAYOUT .. " 种\n"
  .. "帧数: " .. maxFrames .. " (水波动画)\n"
  .. "网格: 16×16 (Ctrl+G 可切换显示)\n\n"
  .. "图块布局:\n"
  .. "Row 0: 草地浅 草地深 干土 湿土 泥路\n"
  .. "Row 1: 水面(2帧)  水岸顶 栅栏横 栅栏竖\n\n"
  .. "保存为 PNG 即可导入 Godot TileSet")
