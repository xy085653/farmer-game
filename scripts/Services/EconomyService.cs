using Godot;
using Demo.Core;
using Demo.Data;
using Demo.Events;

namespace Demo.Services;

public partial class EconomyService : Node, IEconomyService
{
    private EventBus _eventBus;
    private int _money = 500;

    public int Money => _money;

    public override void _Ready()
    {
        _eventBus = GetNode<EventBus>("/root/EventBus");
    }

    public bool AddMoney(int amount, string reason = "")
    {
        if (amount <= 0)
            return false;

        int oldAmount = _money;
        _money += amount;
        _eventBus.Publish(new MoneyChangedEvent(oldAmount, _money, reason));
        return true;
    }

    public bool SpendMoney(int amount, string reason = "")
    {
        if (amount <= 0)
            return false;

        if (_money < amount)
            return false;

        int oldAmount = _money;
        _money -= amount;
        _eventBus.Publish(new MoneyChangedEvent(oldAmount, _money, reason));
        return true;
    }

    public int GetSellPrice(ItemData item)
    {
        if (item == null)
            return 0;

        var timeService = ServiceRegistry.Instance?.TimeService;
        float multiplier = timeService?.GetCurrentTermEffect().PriceMultiplier ?? 1.0f;
        return Mathf.RoundToInt(item.BasePrice * multiplier);
    }

    public bool BuyItem(ItemData item, int count = 1)
    {
        if (item == null || count <= 0)
            return false;

        int totalCost = item.BasePrice * count;
        string reason = $"购买 {item.ItemName} x{count}";

        if (!SpendMoney(totalCost, reason))
            return false;

        var inventory = ServiceRegistry.Instance?.InventoryService;
        if (inventory == null)
            return false;

        bool result = inventory.AddItem(item, count);
        if (!result)
        {
            // Refund if inventory is full
            AddMoney(totalCost, $"退款: 背包已满");
            return false;
        }

        return true;
    }

    public bool SellItem(ItemData item, int count = 1)
    {
        if (item == null || count <= 0)
            return false;

        var inventory = ServiceRegistry.Instance?.InventoryService;
        if (inventory == null)
            return false;

        if (!inventory.HasItem(item.ItemId, count))
            return false;

        inventory.RemoveItemById(item.ItemId, count);

        int price = GetSellPrice(item) * count;
        AddMoney(price, $"出售 {item.ItemName} x{count}");

        _eventBus.Publish(new ItemSoldEvent(item.ItemId, count, price));
        return true;
    }
}
