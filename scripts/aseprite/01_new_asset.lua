--------------------------------------------------------------------------------
--  画布初始化脚本 (兼容 Aseprite v1.2.15+)
--  用法: Ctrl+N 建画布 -> 运行此脚本
--  功能: 清空 -> 建图层 -> 导色板
--  参考: https://www.aseprite.org/api/
--
--  v1.2.15 注意事项:
--    - 用 app.activeSprite (app.sprite 是 v1.3 才加的)
--    - Cel.frameNumber 只读 (v1.2.35 后才可写)
--    - 网格/缩放让用户手动操作(Ctrl+G/Ctrl+滚轮)，不同版本命令名不一致
--------------------------------------------------------------------------------

-- 配置 ----------------------------------------------------------------
local LAYERS = {
  { name = "细节描边", opacity = 255, blend = BlendMode.NORMAL },
  { name = "高光",     opacity = 255, blend = BlendMode.SCREEN },
  { name = "阴影",     opacity = 255, blend = BlendMode.MULTIPLY },
  { name = "固有色",   opacity = 255, blend = BlendMode.NORMAL },
  { name = "草稿轮廓", opacity = 200, blend = BlendMode.NORMAL },
}

local PALETTE = {
  { 0xE8, 0xD4, 0xA8 },  -- 宣纸米白
  { 0xC0, 0x8A, 0x53 },  -- 木色
  { 0x8B, 0x5E, 0x3C },  -- 深棕
  { 0x5A, 0x3E, 0x2B },  -- 深褐(轮廓线)
  { 0x4A, 0x6F, 0x3A },  -- 草绿
  { 0x6B, 0x9E, 0x4A },  -- 嫩绿
  { 0x3A, 0x7D, 0x5C },  -- 深绿
  { 0x7E, 0xC8, 0xE3 },  -- 天蓝
  { 0x4A, 0x90, 0xD9 },  -- 深蓝
  { 0xD4, 0x4A, 0x3E },  -- 朱红
  { 0xE8, 0xA4, 0x3A },  -- 金黄
  { 0xF0, 0xD0, 0x78 },  -- 淡黄
  { 0xD4, 0x7A, 0x9A },  -- 粉红
  { 0x94, 0x6A, 0x4A },  -- 赭石
  { 0xF0, 0xE8, 0xD0 },  -- 骨白
  { 0x2A, 0x2A, 0x2A },  -- 近黑
}

-- 主逻辑 ----------------------------------------------------------------

local sprite = app.activeSprite
if not sprite then
  return app.alert("请先新建一个画布 (Ctrl+N)")
end

-- 1. 清空所有 cel
for _, cel in ipairs(sprite.cels) do
  cel.image:clear(Color(0, 0, 0, 0))
end

-- 2. 删掉全部旧图层
local oldLayers = {}
for _, layer in ipairs(sprite.layers) do
  oldLayers[#oldLayers + 1] = layer
end
for i = #oldLayers, 1, -1 do
  sprite:deleteLayer(oldLayers[i])
end

-- 3. 从底往上建新层
for i = #LAYERS, 1, -1 do
  local def = LAYERS[i]
  local layer = sprite:newLayer()
  layer.name = def.name
  layer.opacity = def.opacity
  layer.blendMode = def.blend

  -- 每层每帧都要有 cel
  for f = 1, #sprite.frames do
    local cel = layer:cel(f)
    if cel then
      cel.image:clear(Color(0, 0, 0, 0))
    else
      cel = sprite:newCel(layer, f)
      if cel then
        cel.image:clear(Color(0, 0, 0, 0))
      end
    end
  end
end

-- 4. 追加色板 (Palette 索引是 0-based)
local pal = sprite.palettes[1]
local oldCount = #pal
pal:resize(oldCount + #PALETTE)
for i, c in ipairs(PALETTE) do
  pal:setColor(oldCount + i - 1, Color(c[1], c[2], c[3], c[4] or 255))
end
sprite:setPalette(pal)

-- 5. 取消选择

-----------------------------------------------------------------------
--  注意: 以下命令在不同版本可能不存在, 用 pcall 包裹避免报错
--  如果失败, 用户可以手动操作:
--    网格开关: Ctrl+G
--    放大:     Ctrl+滚轮
--    取消选区: Ctrl+D
-----------------------------------------------------------------------

pcall(function() app.command.DeselectMask{} end)

app.refresh()

-- 6. 完成提示
local mode = sprite.colorMode == ColorMode.RGB and "RGB"
          or sprite.colorMode == ColorMode.GRAYSCALE and "灰度"
          or "索引色"

app.alert("画布初始化完成\n"
  .. "尺寸: " .. sprite.width .. "x" .. sprite.height .. "\n"
  .. "模式: " .. mode .. "\n"
  .. "图层: " .. #sprite.layers .. "层\n"
  .. "色板: " .. #sprite.palettes[1] .. "色\n\n"
  .. "网格: Ctrl+G  缩放: Ctrl+滚轮")
