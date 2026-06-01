using Demo.Data;

namespace Demo.Services;

public interface IEconomyService
{
    int Money { get; }
    bool AddMoney(int amount, string reason = "");
    bool SpendMoney(int amount, string reason = "");
    int GetSellPrice(ItemData item);
    bool BuyItem(ItemData item, int count = 1);
    bool SellItem(ItemData item, int count = 1);
}
