using Godot;

namespace Demo.Events;

public record RecipeCraftedEvent(string RecipeId, string ResultItemId, int Count);

public record BuildingPlacedEvent(string BuildingId, string Name, Vector2I Position);
