namespace Demo.Events;

public record MoneyChangedEvent(int OldAmount, int NewAmount, string Reason);

public record ItemSoldEvent(string ItemId, int Count, int TotalPrice);
