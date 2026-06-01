using Godot;
using System.Collections.Generic;
using Demo.Data;
using Demo.Events;
using Demo.Core;

namespace Demo.Services;

public partial class CraftService : Node, ICraftService
{
    private EventBus _bus;
    private ServiceRegistry _registry;
    private List<RecipeData> _recipes = new();

    public override void _Ready()
    {
        _bus = GetNode<EventBus>("/root/EventBus");
        _registry = GetNode<ServiceRegistry>("/root/ServiceRegistry");
        LoadRecipes();
    }

    private void LoadRecipes()
    {
        var dir = DirAccess.Open("res://resources/Recipes");
        if (dir == null) return;
        foreach (var file in dir.GetFiles())
        {
            if (!file.EndsWith(".tres") && !file.EndsWith(".res")) continue;
            var recipe = ResourceLoader.Load<RecipeData>($"res://resources/Recipes/{file}");
            if (recipe != null) _recipes.Add(recipe);
        }
    }

    public IReadOnlyList<RecipeData> GetAvailableRecipes(WorkbenchType bench)
    {
        return _recipes.FindAll(r => r.Workbench == bench);
    }

    public bool CanCraft(RecipeData recipe)
    {
        var inv = _registry?.InventoryService;
        if (inv == null) return false;

        foreach (var ingredient in recipe.Ingredients)
        {
            if (ingredient?.Item == null) continue;
            if (!inv.HasItem(ingredient.Item.ItemId, ingredient.Count))
                return false;
        }
        return true;
    }

    public bool Craft(RecipeData recipe)
    {
        if (!CanCraft(recipe)) return false;
        var inv = _registry.InventoryService;

        // Consume ingredients
        foreach (var ingredient in recipe.Ingredients)
        {
            if (ingredient?.Item == null) continue;
            inv.RemoveItemById(ingredient.Item.ItemId, ingredient.Count);
        }

        // Add result
        inv.AddItem(recipe.ResultItem, recipe.ResultCount);
        _bus.Publish(new RecipeCraftedEvent(recipe.RecipeId, recipe.ResultItem.ItemId, recipe.ResultCount));
        return true;
    }

    public bool PlaceBuilding(string buildingId, Vector2I position)
    {
        _bus.Publish(new BuildingPlacedEvent(buildingId, buildingId, position));
        return true;
    }
}
