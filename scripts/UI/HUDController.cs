using Godot;
using Demo.Core;
using Demo.Data;

namespace Demo.UI;

public partial class HUDController : Control
{
    [Export] public Label TimeLabel;
    [Export] public Label SeasonLabel;
    [Export] public Label TermLabel;
    [Export] public Label MoneyLabel;
    [Export] public Control HotbarContainer;

    private ServiceRegistry _registry;

    public override void _Ready()
    {
        _registry = GetNode<ServiceRegistry>("/root/ServiceRegistry");
        var bus = GetNode<EventBus>("/root/EventBus");

        // Subscribe to events
        bus.OnPhaseChanged += _ => UpdateHUD();
        bus.OnSolarTermChanged += _ => UpdateHUD();
        bus.OnSeasonChanged += _ => UpdateHUD();
        bus.OnMoneyChanged += _ => UpdateHUD();
        bus.OnInventoryChanged += _ => UpdateHotbar();

        UpdateHUD();
    }

    private void UpdateHUD()
    {
        if (_registry?.TimeService == null) return;
        var time = _registry.TimeService.CurrentTime;

        if (TimeLabel != null)
            TimeLabel.Text = $"{SolarTermHelper.GetPhaseName(time.Phase)}";
        if (SeasonLabel != null)
            SeasonLabel.Text = $"{SolarTermHelper.GetSeasonName(time.Season)} 第{time.Year}年";
        if (TermLabel != null)
            TermLabel.Text = $"{SolarTermHelper.GetDisplayName(time.Term)} 第{time.DayInTerm}日";
        if (MoneyLabel != null && _registry.EconomyService != null)
            MoneyLabel.Text = $"\U0001fa99 {_registry.EconomyService.Money}文";
    }

    private void UpdateHotbar()
    {
        // Update hotbar icons - rebuild children from inventory slots 0-7
        if (HotbarContainer == null || _registry?.InventoryService == null) return;

        // Clear existing
        foreach (var child in HotbarContainer.GetChildren())
            child.QueueFree();

        for (int i = 0; i < _registry.InventoryService.HotbarSize; i++)
        {
            var slot = _registry.InventoryService.GetSlot(i);
            var panel = new Panel();
            panel.Size = new Vector2(40, 40);
            panel.MouseFilter = Control.MouseFilterEnum.Ignore;

            if (!slot.IsEmpty)
            {
                var label = new Label();
                label.Text = $"{slot.Item.ItemName}\n×{slot.Count}";
                label.HorizontalAlignment = HorizontalAlignment.Center;
                label.VerticalAlignment = VerticalAlignment.Center;
                label.Size = panel.Size;
                panel.AddChild(label);
            }

            // Highlight selected
            if (i == _registry.InventoryService.CurrentHotbarIndex)
            {
                panel.Modulate = new Color(1, 1, 0.8f); // slight yellow tint
            }

            HotbarContainer.AddChild(panel);
        }
    }
}
