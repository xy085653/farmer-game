using Godot;

namespace Demo.Data;

public enum ItemType { Seed, Product, Tool, Material, Crafted, Special }
public enum ToolType { Hoe, WateringCan, Axe, Pickaxe, Scythe }

[GlobalClass]
public partial class ItemData : Resource
{
    [Export] public string ItemId { get; set; } = "";
    [Export] public string ItemName { get; set; } = "";
    [Export] public string Description { get; set; } = "";
    [Export] public ItemType Type { get; set; }
    [Export] public ToolType ToolSubType { get; set; }
    [Export] public int BasePrice { get; set; }
    [Export] public int MaxStack { get; set; } = 99;
    [Export] public Texture2D Icon { get; set; } = null;
    [Export] public int UpgradeLevel { get; set; }
    [Export] public int EnergyCost { get; set; }
}
