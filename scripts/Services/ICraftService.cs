using System.Collections.Generic;
using Godot;
using Demo.Data;

namespace Demo.Services;

public interface ICraftService
{
    IReadOnlyList<RecipeData> GetAvailableRecipes(WorkbenchType bench);
    bool CanCraft(RecipeData recipe);
    bool Craft(RecipeData recipe);
    bool PlaceBuilding(string buildingId, Vector2I position);
}
