using Godot;
using System.Collections.Generic;
using Demo.Data;

namespace Demo.Data;

/// <summary>
/// Save data model - all persistent game state
/// </summary>
public struct SaveData
{
    public Vector2 PlayerPosition;
    public string CurrentMap;

    public GameTime GameTime;

    public List<SavedSlot> InventorySlots;
    public int Money;

    public List<SavedTile> FarmTiles;
    public List<SavedBuilding> Buildings;
}

public struct SavedSlot
{
    public string ItemId;
    public int Count;
}

public struct SavedTile
{
    public Vector2I Position;
    public int State;
    public string CropId;
    public int GrowthStage;
    public float GrowthProgress;
}

public struct SavedBuilding
{
    public string BuildingId;
    public Vector2I Position;
}
