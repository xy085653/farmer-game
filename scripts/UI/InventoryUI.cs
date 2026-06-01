using Godot;
using Demo.Core;

namespace Demo.UI;

public partial class InventoryUI : Control
{
    [Export] public GridContainer Grid;
    [Export] public Label TitleLabel;

    private ServiceRegistry _registry;
    private bool _isOpen;

    public override void _Ready()
    {
        _registry = GetNode<ServiceRegistry>("/root/ServiceRegistry");
        Hide();
    }

    public override void _Input(InputEvent @event)
    {
        if (@event.IsActionPressed("toggle_inventory"))
        {
            _isOpen = !_isOpen;
            Visible = _isOpen;
            if (_isOpen) RefreshInventory();
            GetViewport().SetInputAsHandled();
        }
    }

    private void RefreshInventory()
    {
        if (Grid == null || _registry?.InventoryService == null) return;

        // Clear existing slots
        foreach (var child in Grid.GetChildren())
            child.QueueFree();

        var inv = _registry.InventoryService;
        for (int i = 0; i < inv.SlotCount; i++)
        {
            var slot = inv.GetSlot(i);
            var panel = new Panel { Size = new Vector2(64, 64) };

            if (!slot.IsEmpty)
            {
                var label = new Label();
                label.Text = $"{slot.Item.ItemName}\n×{slot.Count}";
                label.HorizontalAlignment = HorizontalAlignment.Center;
                label.VerticalAlignment = VerticalAlignment.Center;
                label.Size = panel.Size;
                panel.AddChild(label);
            }

            Grid.AddChild(panel);
        }
    }
}
