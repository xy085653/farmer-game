using Godot;
using System.Collections.Generic;
using Demo.Core;
using Demo.Data;
using Demo.Events;
using Demo.World;

namespace Demo.Services;

public partial class FarmService : Node, IFarmService
{
    private EventBus _eventBus;
    private Dictionary<string, CropData> _cropDataByCropId = new();
    private Dictionary<string, CropData> _cropDataBySeedId = new();

    public override void _Ready()
    {
        _eventBus = GetNode<EventBus>("/root/EventBus");
        LoadCropData();
        _eventBus.OnDayEnded += OnDayEnded;
    }

    private void LoadCropData()
    {
        _cropDataByCropId.Clear();
        _cropDataBySeedId.Clear();

        using var dir = DirAccess.Open("res://resources/Crops/");
        if (dir == null)
        {
            GD.PrintErr("FarmService: Could not open Crops directory");
            return;
        }

        dir.ListDirBegin();
        string fileName;
        while ((fileName = dir.GetNext()) != "")
        {
            if (!fileName.EndsWith(".tres") && !fileName.EndsWith(".res"))
                continue;

            string path = "res://resources/Crops/" + fileName;
            var cropData = ResourceLoader.Load<CropData>(path);
            if (cropData == null)
                continue;

            _cropDataByCropId[cropData.CropId] = cropData;
            if (cropData.SeedItem != null)
                _cropDataBySeedId[cropData.SeedItem.ItemId] = cropData;
        }
        dir.ListDirEnd();

        GD.Print($"FarmService: Loaded {_cropDataByCropId.Count} crops");
    }

    private static Vector2I WorldToTile(Vector2 worldPos)
    {
        return new Vector2I(
            Mathf.FloorToInt(worldPos.X / 32),
            Mathf.FloorToInt(worldPos.Y / 32)
        );
    }

    private FarmTileManager GetTileManager()
    {
        var farm = GetTree().Root.GetNodeOrNull("Farm");
        return farm?.GetNodeOrNull<FarmTileManager>("FarmTileManager");
    }

    public bool HoeTile(Vector2 worldPos)
    {
        var tilePos = WorldToTile(worldPos);
        var tileManager = GetTileManager();
        if (tileManager == null)
            return false;
        if (!tileManager.CanHoe(tilePos))
            return false;
        tileManager.SetTileState(tilePos, HoeDirtState.Tilled);
        return true;
    }

    public bool PlantSeed(Vector2 worldPos, ItemData seedItem)
    {
        if (seedItem == null)
            return false;

        if (!_cropDataBySeedId.TryGetValue(seedItem.ItemId, out var cropData))
            return false;

        var tilePos = WorldToTile(worldPos);
        var tileManager = GetTileManager();
        if (tileManager == null)
            return false;

        // Check season is allowed for this crop
        var timeService = ServiceRegistry.Instance?.TimeService;
        if (timeService == null)
            return false;
        var currentSeason = timeService.CurrentTime.Season;
        if (cropData.AllowedSeasons.Count > 0 && !cropData.AllowedSeasons.Contains(currentSeason))
            return false;

        // Check tile is in TilledWet state
        if (tileManager.GetState(tilePos) != HoeDirtState.TilledWet)
            return false;

        // Remove seed from inventory
        var inventory = ServiceRegistry.Instance?.InventoryService;
        if (inventory == null)
            return false;
        if (!inventory.RemoveItemById(seedItem.ItemId, 1))
            return false;

        // Plant the crop (FarmTileManager.PlantCrop publishes SeedPlantedEvent internally)
        tileManager.PlantCrop(tilePos, cropData.CropId);
        return true;
    }

    public bool WaterTile(Vector2 worldPos)
    {
        var tilePos = WorldToTile(worldPos);
        var tileManager = GetTileManager();
        if (tileManager == null)
            return false;
        tileManager.WaterTile(tilePos);
        return true;
    }

    public bool HarvestCrop(Vector2 worldPos)
    {
        var tilePos = WorldToTile(worldPos);
        var tileManager = GetTileManager();
        if (tileManager == null)
            return false;

        var tileData = tileManager.GetTileData(tilePos);
        if (tileData == null)
            return false;

        var data = tileData.Value;
        if (data.State != HoeDirtState.Mature)
            return false;
        if (string.IsNullOrEmpty(data.CropId))
            return false;

        if (!_cropDataByCropId.TryGetValue(data.CropId, out var cropData))
            return false;

        // Check if growth stage has reached max stages
        int maxStage = cropData.GrowthStages - 1;
        if (data.GrowthStage < maxStage)
            return false;

        // Add harvest item to inventory
        var inventory = ServiceRegistry.Instance?.InventoryService;
        if (inventory == null)
            return false;
        inventory.AddItem(cropData.HarvestItem, cropData.HarvestCount);

        // Handle regrow or revert
        if (cropData.CanRegrow)
        {
            tileManager.ResetGrowth(tilePos, 0);
        }
        else
        {
            tileManager.SetTileState(tilePos, HoeDirtState.Tilled);
        }

        // Publish harvest event
        _eventBus?.Publish(new CropHarvestedEvent(tilePos, cropData.HarvestItem.ItemId, cropData.HarvestCount));
        return true;
    }

    public void TickGrowth(GameTime time)
    {
        var timeService = ServiceRegistry.Instance?.TimeService;
        if (timeService == null)
            return;

        var effect = timeService.GetCurrentTermEffect();
        float growth = 1.0f * effect.GrowthMultiplier;

        var tileManager = GetTileManager();
        tileManager?.AdvanceGrowth(growth);
    }

    public HoeDirtState GetTileState(Vector2 worldPos)
    {
        var tilePos = WorldToTile(worldPos);
        var tileManager = GetTileManager();
        if (tileManager == null)
            return HoeDirtState.Normal;
        return tileManager.GetState(tilePos);
    }

    private void OnDayEnded(DayEndedEvent evt)
    {
        TickGrowth(evt.Time);
    }
}
