using Godot;
using Demo.Core;
using Demo.Data;

namespace Demo.UI;

public partial class ShopUI : Control
{
    [Export] public ItemList ItemList;
    [Export] public Label TitleLabel;
    [Export] public Label MoneyLabel;
    [Export] public Button BuyButton;
    [Export] public Button CloseButton;

    private ServiceRegistry _registry;
    private Godot.Collections.Array<ItemData> _currentStock = new();

    public override void _Ready()
    {
        _registry = GetNode<ServiceRegistry>("/root/ServiceRegistry");
        CloseButton?.Connect("pressed", new Callable(this, nameof(CloseShop)));
        BuyButton?.Connect("pressed", new Callable(this, nameof(OnBuyPressed)));
        Hide();
    }

    public void OpenShop(string shopName, Godot.Collections.Array<ItemData> stock)
    {
        _currentStock = stock;
        TitleLabel.Text = shopName;
        Visible = true;
        RefreshUI();
    }

    private void RefreshUI()
    {
        ItemList?.Clear();
        foreach (var item in _currentStock)
        {
            if (item != null)
                ItemList.AddItem($"{item.ItemName}  \U0001fa99{item.BasePrice}文");
        }
        MoneyLabel.Text = $"持有: \U0001fa99 {_registry?.EconomyService?.Money ?? 0}文";
    }

    private void OnBuyPressed()
    {
        var selected = ItemList?.GetSelectedItems();
        if (selected == null || selected.Count == 0) return;
        int idx = selected[0];
        if (idx < 0 || idx >= _currentStock.Count) return;

        var item = _currentStock[idx];
        _registry?.EconomyService?.BuyItem(item, 1);
        RefreshUI();
    }

    private void CloseShop()
    {
        Visible = false;
    }
}
