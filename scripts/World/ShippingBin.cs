using Godot;
using System.Collections.Generic;
using Demo.Core;
using Demo.Events;

namespace Demo.World;

public partial class ShippingBin : StaticBody2D
{
    private ServiceRegistry _registry;
    private List<(string ItemId, int Count)> _pendingItems = new();

    public override void _Ready()
    {
        _registry = GetNode<ServiceRegistry>("/root/ServiceRegistry");
        var bus = GetNode<EventBus>("/root/EventBus");
        bus.OnDayEnded += OnDayEnded;
    }

    public void DepositItem(string itemId, int count)
    {
        var inventory = _registry?.InventoryService;
        if (inventory == null || !inventory.HasItem(itemId, count)) return;
        inventory.RemoveItemById(itemId, count);
        _pendingItems.Add((itemId, count));
    }

    private void OnDayEnded(DayEndedEvent evt)
    {
        var economy = _registry?.EconomyService;
        if (economy == null || _pendingItems.Count == 0) return;

        int totalEarned = 0;
        // Process all pending items
        foreach (var (itemId, count) in _pendingItems)
        {
            // Get item data - need to find the ItemData for this itemId
            // For MVP, just sum up based on item lookup
            totalEarned += count * 10; // placeholder: 10文 per item
        }
        economy.AddMoney(totalEarned, "出货箱结算");
        _pendingItems.Clear();
        GD.Print($"出货箱结算: 共 {totalEarned} 文");
    }
}
