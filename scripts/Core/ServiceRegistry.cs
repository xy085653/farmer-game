using Godot;

namespace Demo.Core;

public partial class ServiceRegistry : Node
{
    public static ServiceRegistry Instance { get; private set; }

    public Demo.Services.ITimeService TimeService { get; private set; }
    public Demo.Services.IInventoryService InventoryService { get; private set; }
    public Demo.Services.IFarmService FarmService { get; private set; }
    public Demo.Services.IEconomyService EconomyService { get; private set; }
    public Demo.Services.ICraftService CraftService { get; private set; }
    public Demo.Services.IWorldService WorldService { get; private set; }

    private bool _registered;

    public bool IsReady => _registered;

    public override void _EnterTree()
    {
        Instance = this;
    }

    public void RegisterServices()
    {
        if (_registered) return;

        TimeService = new Demo.Services.TimeService();
        InventoryService = new Demo.Services.InventoryService();
        FarmService = new Demo.Services.FarmService();
        EconomyService = new Demo.Services.EconomyService();
        CraftService = new Demo.Services.CraftService();
        WorldService = new Demo.Services.WorldService();

        AddServiceNode(TimeService);
        AddServiceNode(InventoryService);
        AddServiceNode(FarmService);
        AddServiceNode(EconomyService);
        AddServiceNode(CraftService);
        AddServiceNode(WorldService);

        _registered = true;
    }

    private void AddServiceNode(object service)
    {
        if (service is Node node)
            AddChild(node);
        else
            GD.PrintErr($"Service {service?.GetType().Name} is not a Node and cannot be added to scene tree");
    }

    public override void _ExitTree()
    {
        Instance = null;
    }
}
