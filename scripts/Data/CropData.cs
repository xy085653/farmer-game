using Godot;

namespace Demo.Data;

[GlobalClass]
public partial class CropData : Resource
{
    [Export] public string CropId { get; set; } = "";
    [Export] public string CropName { get; set; } = "";
    [Export] public ItemData SeedItem { get; set; } = null;
    [Export] public ItemData HarvestItem { get; set; } = null;
    [Export] public float BaseGrowthDays { get; set; } = 5f;
    [Export] public int GrowthStages { get; set; } = 5;
    [Export] public Godot.Collections.Array<Texture2D> StageSprites { get; set; } = new();
    [Export] public Godot.Collections.Array<SolarTerm> PreferredTerms { get; set; } = new();
    [Export] public bool CanRegrow { get; set; }
    [Export] public int RegrowDays { get; set; } = 3;
    [Export] public int HarvestCount { get; set; } = 1;
    [Export] public Godot.Collections.Array<Season> AllowedSeasons { get; set; } = new();
}
