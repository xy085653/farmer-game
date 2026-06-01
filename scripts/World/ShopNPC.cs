using Godot;

namespace Demo.World;

public partial class ShopNPC : StaticBody2D
{
    [Export] public string ShopName = "杂货铺";
    [Export] public Godot.Collections.Array<ItemData> ShopItems = new();

    public void Interact()
    {
        // Open shop UI - will be connected by UI system later
        GD.Print($"打开 {ShopName}");
        // Publish event to open shop UI
        var bus = GetNodeOrNull<EventBus>("/root/EventBus");
        // For now just log; UI integration in Task 11
    }
}
