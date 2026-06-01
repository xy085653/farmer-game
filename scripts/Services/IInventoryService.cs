using Demo.Data;

namespace Demo.Services;

public struct InventorySlot
{
    public ItemData Item;
    public int Count;
    public readonly bool IsEmpty => Item == null || Count <= 0;
}

public interface IInventoryService
{
    int SlotCount { get; }
    int HotbarSize { get; }
    InventorySlot GetSlot(int index);
    bool AddItem(ItemData item, int count = 1);
    bool RemoveItem(int slotIndex, int count = 1);
    bool RemoveItemById(string itemId, int count = 1);
    int GetItemCount(string itemId);
    bool HasItem(string itemId, int count = 1);
    int FindSlotForItem(string itemId);
    int FindEmptySlot();
    void SwapSlots(int from, int to);
    void SetHotbarIndex(int index);
    int CurrentHotbarIndex { get; }
    InventorySlot CurrentTool { get; }
}
