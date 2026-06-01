using Godot;
using System.Collections.Generic;
using Demo.Core;
using Demo.Events;

namespace Demo.World;

public enum HoeDirtState { Normal, Tilled, TilledWet, Planted, Mature }

public struct HoeDirtData
{
    public Vector2I TilePos;
    public HoeDirtState State;
    public string CropId;
    public int GrowthStage;
    public float GrowthProgress;
    public bool Watered;
}

public partial class FarmTileManager : Node
{
    private Dictionary<Vector2I, HoeDirtData> _tiles = new();
    private TileMapLayer _groundLayer;
    private EventBus _eventBus;

    public override void _Ready()
    {
        _groundLayer = GetParent().GetNodeOrNull<TileMapLayer>("GroundLayer");
        _eventBus = GetNode<EventBus>("/root/EventBus");
    }

    public bool IsTilled(Vector2I tilePos) =>
        _tiles.ContainsKey(tilePos) && _tiles[tilePos].State >= HoeDirtState.Tilled;

    public bool CanHoe(Vector2I tilePos) =>
        !_tiles.ContainsKey(tilePos) || _tiles[tilePos].State == HoeDirtState.Normal;

    public bool CanPlant(Vector2I tilePos) =>
        _tiles.ContainsKey(tilePos) && _tiles[tilePos].State == HoeDirtState.TilledWet;

    public bool CanWater(Vector2I tilePos) =>
        _tiles.ContainsKey(tilePos) && !_tiles[tilePos].Watered;

    public HoeDirtData? GetTileData(Vector2I tilePos)
    {
        if (_tiles.ContainsKey(tilePos)) return _tiles[tilePos];
        return null;
    }

    public HoeDirtState GetState(Vector2I tilePos)
    {
        if (_tiles.ContainsKey(tilePos)) return _tiles[tilePos].State;
        return HoeDirtState.Normal;
    }

    public void SetTileState(Vector2I tilePos, HoeDirtState state)
    {
        if (_tiles.ContainsKey(tilePos))
        {
            var data = _tiles[tilePos];
            data.State = state;

            if (state == HoeDirtState.Normal)
            {
                data.CropId = null;
                data.GrowthStage = 0;
                data.GrowthProgress = 0f;
                data.Watered = false;
            }

            _tiles[tilePos] = data;
        }
        else
        {
            _tiles[tilePos] = new HoeDirtData
            {
                TilePos = tilePos,
                State = state,
                CropId = null,
                GrowthStage = 0,
                GrowthProgress = 0f,
                Watered = false
            };
        }

        UpdateTileVisual(tilePos);

        if (state == HoeDirtState.Tilled)
        {
            _eventBus?.Publish(new TileHoedEvent(tilePos));
        }
    }

    public void PlantCrop(Vector2I tilePos, string cropId)
    {
        if (!_tiles.ContainsKey(tilePos)) return;

        var data = _tiles[tilePos];
        data.State = HoeDirtState.Planted;
        data.CropId = cropId;
        data.GrowthStage = 0;
        data.GrowthProgress = 0f;
        _tiles[tilePos] = data;

        UpdateTileVisual(tilePos);
        _eventBus?.Publish(new SeedPlantedEvent(cropId, tilePos, 1));
    }

    public void WaterTile(Vector2I tilePos)
    {
        if (!_tiles.ContainsKey(tilePos)) return;

        var data = _tiles[tilePos];
        data.Watered = true;

        if (data.State == HoeDirtState.Tilled)
        {
            data.State = HoeDirtState.TilledWet;
        }

        _tiles[tilePos] = data;

        UpdateTileVisual(tilePos);
        _eventBus?.Publish(new TileWateredEvent(tilePos));
    }

    public void ResetGrowth(Vector2I tilePos, int stage)
    {
        if (!_tiles.ContainsKey(tilePos)) return;

        var data = _tiles[tilePos];
        data.GrowthStage = stage;
        data.GrowthProgress = 0f;
        _tiles[tilePos] = data;

        UpdateTileVisual(tilePos);
    }

    public void AdvanceGrowth(float growthAmount)
    {
        // Collect keys before iterating to avoid modification during iteration
        Vector2I[] keys = new Vector2I[_tiles.Keys.Count];
        _tiles.Keys.CopyTo(keys, 0);

        foreach (Vector2I tilePos in keys)
        {
            if (!_tiles.ContainsKey(tilePos)) continue;

            var data = _tiles[tilePos];

            // Advance growth for planted, watered tiles
            if (data.State == HoeDirtState.Planted && data.Watered)
            {
                data.GrowthProgress += growthAmount;

                int maxStage = 5;

                while (data.GrowthProgress >= 1.0f)
                {
                    data.GrowthProgress -= 1.0f;
                    data.GrowthStage++;

                    if (data.GrowthStage >= maxStage)
                    {
                        data.GrowthStage = maxStage;
                        data.State = HoeDirtState.Mature;
                        data.GrowthProgress = 0f;
                        _eventBus?.Publish(new CropGrownEvent(tilePos, data.GrowthStage, maxStage));
                        break;
                    }

                    _eventBus?.Publish(new CropGrownEvent(tilePos, data.GrowthStage, maxStage));
                }

                UpdateTileVisual(tilePos);
            }

            // Reset watered status at end of day — daily watering needed
            data.Watered = false;

            // Revert TilledWet (unplanted watered tiles) back to Tilled
            if (data.State == HoeDirtState.TilledWet && string.IsNullOrEmpty(data.CropId))
            {
                data.State = HoeDirtState.Tilled;
                UpdateTileVisual(tilePos);
            }

            _tiles[tilePos] = data;
        }
    }

    private void UpdateTileVisual(Vector2I tilePos)
    {
        if (_groundLayer == null) return;

        if (!_tiles.ContainsKey(tilePos))
        {
            // Clear the cell if no tile data exists
            _groundLayer.SetCell(tilePos, -1, Vector2I.Zero);
            return;
        }

        var data = _tiles[tilePos];
        int atlasCoords = data.State switch
        {
            HoeDirtState.Normal => 0,
            HoeDirtState.Tilled => 1,
            HoeDirtState.TilledWet => 2,
            HoeDirtState.Planted => 3 + data.GrowthStage,
            HoeDirtState.Mature => 3 + data.GrowthStage,
            _ => 0
        };

        _groundLayer.SetCell(tilePos, 0, new Vector2I(atlasCoords, 0));
    }
}
