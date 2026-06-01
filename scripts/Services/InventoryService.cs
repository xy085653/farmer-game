using Godot;
using Demo.Data;
using Demo.Events;
using Demo.Core;

namespace Demo.Services;

public partial class InventoryService : Node, IInventoryService
{
    private const int DefaultSlotCount = 24;
    private const int DefaultHotbarSize = 8;

    private InventorySlot[] _slots;
    private EventBus _eventBus;
    private int _currentHotbarIndex;

    public int SlotCount => DefaultSlotCount;
    public int HotbarSize => DefaultHotbarSize;

    public int CurrentHotbarIndex => _currentHotbarIndex;

    public InventorySlot CurrentTool => _slots[_currentHotbarIndex];

    public override void _Ready()
    {
        _slots = new InventorySlot[DefaultSlotCount];
        for (int i = 0; i < DefaultSlotCount; i++)
        {
            _slots[i] = new InventorySlot { Item = null, Count = 0 };
        }

        _eventBus = GetNode<EventBus>("/root/EventBus");
        _currentHotbarIndex = 0;
    }

    public InventorySlot GetSlot(int index)
    {
        if (index < 0 || index >= DefaultSlotCount)
            return default;

        return _slots[index];
    }

    public bool AddItem(ItemData item, int count = 1)
    {
        if (item == null || count <= 0)
            return false;

        int remaining = count;
        int maxStack = item.MaxStack;

        // Step 1: Stack onto existing slots with same ItemId and room
        for (int i = 0; i < DefaultSlotCount && remaining > 0; i++)
        {
            if (!_slots[i].IsEmpty && _slots[i].Item.ItemId == item.ItemId && _slots[i].Count < maxStack)
            {
                var slot = _slots[i];
                int space = maxStack - slot.Count;
                int toAdd = Mathf.Min(remaining, space);
                slot.Count += toAdd;
                remaining -= toAdd;
                _slots[i] = slot;
                _eventBus.Publish(new ItemAddedEvent(item.ItemId, toAdd, i));
            }
        }

        // Step 2: Fill empty slots
        for (int i = 0; i < DefaultSlotCount && remaining > 0; i++)
        {
            if (_slots[i].IsEmpty)
            {
                int toAdd = Mathf.Min(remaining, maxStack);
                _slots[i] = new InventorySlot { Item = item, Count = toAdd };
                remaining -= toAdd;
                _eventBus.Publish(new ItemAddedEvent(item.ItemId, toAdd, i));
            }
        }

        _eventBus.Publish(new InventoryChangedEvent());
        return remaining == 0;
    }

    public bool RemoveItem(int slotIndex, int count = 1)
    {
        if (slotIndex < 0 || slotIndex >= DefaultSlotCount || count <= 0)
            return false;

        var slot = _slots[slotIndex];
        if (slot.IsEmpty)
            return false;

        string itemId = slot.Item.ItemId;
        int toRemove = Mathf.Min(count, slot.Count);
        slot.Count -= toRemove;

        if (slot.Count <= 0)
        {
            slot.Item = null;
            slot.Count = 0;
        }

        _slots[slotIndex] = slot;
        _eventBus.Publish(new ItemRemovedEvent(itemId, toRemove, slotIndex));
        _eventBus.Publish(new InventoryChangedEvent());
        return true;
    }

    public bool RemoveItemById(string itemId, int count = 1)
    {
        if (string.IsNullOrEmpty(itemId) || count <= 0)
            return false;

        int remaining = count;

        for (int i = 0; i < DefaultSlotCount && remaining > 0; i++)
        {
            if (!_slots[i].IsEmpty && _slots[i].Item.ItemId == itemId)
            {
                var slot = _slots[i];
                int toRemove = Mathf.Min(remaining, slot.Count);
                slot.Count -= toRemove;
                remaining -= toRemove;

                if (slot.Count <= 0)
                {
                    slot.Item = null;
                    slot.Count = 0;
                }

                _slots[i] = slot;
                _eventBus.Publish(new ItemRemovedEvent(itemId, toRemove, i));
            }
        }

        int totalRemoved = count - remaining;
        if (totalRemoved > 0)
            _eventBus.Publish(new InventoryChangedEvent());

        return remaining == 0;
    }

    public int GetItemCount(string itemId)
    {
        int total = 0;

        for (int i = 0; i < DefaultSlotCount; i++)
        {
            if (!_slots[i].IsEmpty && _slots[i].Item.ItemId == itemId)
            {
                total += _slots[i].Count;
            }
        }

        return total;
    }

    public bool HasItem(string itemId, int count = 1)
    {
        return GetItemCount(itemId) >= count;
    }

    public int FindSlotForItem(string itemId)
    {
        for (int i = 0; i < DefaultSlotCount; i++)
        {
            if (!_slots[i].IsEmpty && _slots[i].Item.ItemId == itemId)
            {
                return i;
            }
        }

        return -1;
    }

    public int FindEmptySlot()
    {
        for (int i = 0; i < DefaultSlotCount; i++)
        {
            if (_slots[i].IsEmpty)
            {
                return i;
            }
        }

        return -1;
    }

    public void SwapSlots(int from, int to)
    {
        if (from < 0 || from >= DefaultSlotCount || to < 0 || to >= DefaultSlotCount)
            return;

        if (from == to)
            return;

        (_slots[from], _slots[to]) = (_slots[to], _slots[from]);
        _eventBus.Publish(new InventoryChangedEvent());
    }

    public void SetHotbarIndex(int index)
    {
        if (index >= 0 && index < DefaultHotbarSize)
        {
            _currentHotbarIndex = index;
        }
    }
}
