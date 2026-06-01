using Godot;

namespace Demo.Data;

public enum WorkbenchType { None, Kitchen, Workshop, Outdoor }

[GlobalClass]
public partial class RecipeData : Resource
{
    [Export] public string RecipeId { get; set; } = "";
    [Export] public string RecipeName { get; set; } = "";
    [Export] public ItemData ResultItem { get; set; } = null;
    [Export] public int ResultCount { get; set; } = 1;
    [Export] public Godot.Collections.Array<Ingredient> Ingredients { get; set; } = new();
    [Export] public WorkbenchType Workbench { get; set; }
    [Export] public int RequiredToolLevel { get; set; }
    [Export] public string Description { get; set; } = "";
}

[GlobalClass]
public partial class Ingredient : Resource
{
    [Export] public ItemData Item { get; set; } = null;
    [Export] public int Count { get; set; } = 1;
}
