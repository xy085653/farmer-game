using Godot;

namespace Demo.Events;

public record SeedPlantedEvent(string CropId, Vector2I TilePos, int Count);

public record CropGrownEvent(Vector2I TilePos, int NewStage, int MaxStage);

public record CropHarvestedEvent(Vector2I TilePos, string ItemId, int Count);

public record TileHoedEvent(Vector2I TilePos);

public record TileWateredEvent(Vector2I TilePos);
