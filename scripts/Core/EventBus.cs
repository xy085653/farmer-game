using Godot;

namespace Demo.Core;

public partial class EventBus : Node
{
    // Time Events
    public event System.Action<Demo.Events.SolarTermEvent> OnSolarTermChanged;
    public event System.Action<Demo.Events.DayPhaseEvent> OnPhaseChanged;
    public event System.Action<Demo.Events.SeasonEvent> OnSeasonChanged;
    public event System.Action<Demo.Events.DayStartedEvent> OnDayStarted;
    public event System.Action<Demo.Events.DayEndedEvent> OnDayEnded;

    // Farm Events
    public event System.Action<Demo.Events.SeedPlantedEvent> OnSeedPlanted;
    public event System.Action<Demo.Events.CropGrownEvent> OnCropGrown;
    public event System.Action<Demo.Events.CropHarvestedEvent> OnCropHarvested;
    public event System.Action<Demo.Events.TileHoedEvent> OnTileHoed;
    public event System.Action<Demo.Events.TileWateredEvent> OnTileWatered;

    // Inventory Events
    public event System.Action<Demo.Events.ItemAddedEvent> OnItemAdded;
    public event System.Action<Demo.Events.ItemRemovedEvent> OnItemRemoved;
    public event System.Action<Demo.Events.InventoryChangedEvent> OnInventoryChanged;

    // Economy Events
    public event System.Action<Demo.Events.MoneyChangedEvent> OnMoneyChanged;
    public event System.Action<Demo.Events.ItemSoldEvent> OnItemSold;

    // Craft Events
    public event System.Action<Demo.Events.RecipeCraftedEvent> OnRecipeCrafted;
    public event System.Action<Demo.Events.BuildingPlacedEvent> OnBuildingPlaced;

    public void Publish<T>(T eventData)
    {
        switch (eventData)
        {
            case Demo.Events.SolarTermEvent e: OnSolarTermChanged?.Invoke(e); break;
            case Demo.Events.DayPhaseEvent e: OnPhaseChanged?.Invoke(e); break;
            case Demo.Events.SeasonEvent e: OnSeasonChanged?.Invoke(e); break;
            case Demo.Events.DayStartedEvent e: OnDayStarted?.Invoke(e); break;
            case Demo.Events.DayEndedEvent e: OnDayEnded?.Invoke(e); break;
            case Demo.Events.SeedPlantedEvent e: OnSeedPlanted?.Invoke(e); break;
            case Demo.Events.CropGrownEvent e: OnCropGrown?.Invoke(e); break;
            case Demo.Events.CropHarvestedEvent e: OnCropHarvested?.Invoke(e); break;
            case Demo.Events.TileHoedEvent e: OnTileHoed?.Invoke(e); break;
            case Demo.Events.TileWateredEvent e: OnTileWatered?.Invoke(e); break;
            case Demo.Events.ItemAddedEvent e: OnItemAdded?.Invoke(e); break;
            case Demo.Events.ItemRemovedEvent e: OnItemRemoved?.Invoke(e); break;
            case Demo.Events.InventoryChangedEvent e: OnInventoryChanged?.Invoke(e); break;
            case Demo.Events.MoneyChangedEvent e: OnMoneyChanged?.Invoke(e); break;
            case Demo.Events.ItemSoldEvent e: OnItemSold?.Invoke(e); break;
            case Demo.Events.RecipeCraftedEvent e: OnRecipeCrafted?.Invoke(e); break;
            case Demo.Events.BuildingPlacedEvent e: OnBuildingPlaced?.Invoke(e); break;
            default:
                GD.PrintErr($"EventBus: Unhandled event type {typeof(T)}");
                break;
        }
    }
}
