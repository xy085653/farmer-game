using Godot;
using Demo.Core;
using Demo.Data;

namespace Demo.Player;

public class ToolManager
{
    private PlayerController _player;
    private EventBus _bus;

    public ToolManager(PlayerController player)
    {
        _player = player;
        _bus = player.GetNode<EventBus>("/root/EventBus");
    }

    public void UseEquippedTool(Vector2 direction)
    {
        var registry = ServiceRegistry.Instance;
        if (registry?.InventoryService == null) return;

        var currentTool = registry.InventoryService.CurrentTool;
        if (currentTool.IsEmpty) return;

        if (currentTool.Item.Type != ItemType.Tool) return;

        Vector2 targetPos = _player.GlobalPosition + direction * 32;

        switch (currentTool.Item.ToolSubType)
        {
            case ToolType.Hoe:
                registry.FarmService?.HoeTile(targetPos);
                break;

            case ToolType.WateringCan:
                registry.FarmService?.WaterTile(targetPos);
                break;
        }
    }
}
