using Godot;
using Demo.Data;
using Demo.World;

namespace Demo.Services;

public interface IFarmService
{
    bool HoeTile(Vector2 worldPos);
    bool PlantSeed(Vector2 worldPos, ItemData seedItem);
    bool WaterTile(Vector2 worldPos);
    bool HarvestCrop(Vector2 worldPos);
    void TickGrowth(GameTime time);
    HoeDirtState GetTileState(Vector2 worldPos);
}
