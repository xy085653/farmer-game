using Godot;

namespace Demo.Services;

public interface IWorldService
{
    string CurrentMap { get; }
    void SwitchMap(string mapName);
    Vector2 GetPlayerSpawnPosition(string mapName);
}
