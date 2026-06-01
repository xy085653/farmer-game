namespace Demo.Events;

public record ItemAddedEvent(string ItemId, int Count, int SlotIndex);

public record ItemRemovedEvent(string ItemId, int Count, int SlotIndex);

public record InventoryChangedEvent;
