using Godot;
using System.Collections.Generic;

namespace Demo.Services;

public partial class WorldService : Node, IWorldService
{
    private readonly Dictionary<string, PackedScene> _mapScenes = new();
    private Node _currentMapInstance;
    private string _currentMapName;

    public string CurrentMap => _currentMapName;

    public override void _Ready()
    {
        _mapScenes["farm"] = ResourceLoader.Load<PackedScene>("res://scenes/World/Farm.tscn");
        _mapScenes["town"] = ResourceLoader.Load<PackedScene>("res://scenes/World/Town.tscn");
        _mapScenes["forest"] = ResourceLoader.Load<PackedScene>("res://scenes/World/Forest.tscn");

        GD.Print("WorldService: Map scenes loaded");
    }

    public void SwitchMap(string mapName)
    {
        string key = mapName.ToLower();

        if (!_mapScenes.ContainsKey(key))
        {
            GD.PrintErr($"WorldService: Map '{mapName}' not found");
            return;
        }

        // Remove old map instance from the scene tree
        if (_currentMapInstance != null)
        {
            GetTree().Root.RemoveChild(_currentMapInstance);
            _currentMapInstance.QueueFree();
            _currentMapInstance = null;
        }

        // Instantiate and add the new map
        _currentMapInstance = _mapScenes[key].Instantiate<Node>();
        GetTree().Root.AddChild(_currentMapInstance);
        _currentMapName = key;

        GD.Print($"WorldService: Switched to map '{key}'");
    }

    public Vector2 GetPlayerSpawnPosition(string mapName)
    {
        return mapName.ToLower() switch
        {
            "farm" => new Vector2(400, 300),
            "town" => new Vector2(200, 500),
            "forest" => new Vector2(100, 100),
            _ => Vector2.Zero
        };
    }
}
