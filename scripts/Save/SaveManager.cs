using Godot;
using System.Collections.Generic;
using Demo.Core;
using Demo.Data;
using Demo.World;

namespace Demo.Save;

/// <summary>
/// Save manager - AES encrypted save/load using Godot's built-in FileAccess
/// </summary>
public partial class SaveManager : Node
{
    private const string SavePath = "user://saves/save.dat";
    private const string EncryptionKey = "farm-game-key-v1";
    private ServiceRegistry _registry;

    public override void _Ready()
    {
        _registry = GetNode<ServiceRegistry>("/root/ServiceRegistry");
        var bus = GetNode<EventBus>("/root/EventBus");
        bus.OnDayEnded += _ => SaveGame();
    }

    public void SaveGame()
    {
        var inv = _registry?.InventoryService;
        var time = _registry?.TimeService;
        var econ = _registry?.EconomyService;

        if (time == null) return;

        // Build save dictionary
        var saveData = new Godot.Collections.Dictionary
        {
            ["version"] = 1,
            ["year"] = time.CurrentTime.Year,
            ["season"] = (int)time.CurrentTime.Season,
            ["term"] = (int)time.CurrentTime.Term,
            ["dayInTerm"] = time.CurrentTime.DayInTerm,
            ["minute"] = time.CurrentTime.Minute,
            ["money"] = econ?.Money ?? 0,
            ["inventory"] = SerializeInventory(inv),
            ["playerPos"] = new Godot.Collections.Array { 400, 300 }, // placeholder
            ["currentMap"] = "farm"
        };

        // Ensure save directory exists
        var dir = DirAccess.Open("user://");
        if (dir == null) return;
        if (!dir.DirExists("saves"))
            dir.MakeDir("saves");

        // Encrypted write
        var file = FileAccess.OpenEncryptedWithPass(SavePath, FileAccess.ModeFlags.Write, EncryptionKey);
        if (file == null)
        {
            GD.PrintErr("保存失败: " + FileAccess.GetOpenError());
            return;
        }

        file.StoreVar(saveData);
        file.Close();
        GD.Print("游戏已保存");
    }

    public Godot.Collections.Dictionary LoadGame()
    {
        if (!FileAccess.FileExists(SavePath))
        {
            GD.Print("没有存档文件");
            return null;
        }

        var file = FileAccess.OpenEncryptedWithPass(SavePath, FileAccess.ModeFlags.Read, EncryptionKey);
        if (file == null)
        {
            GD.PrintErr("加载失败: " + FileAccess.GetOpenError());
            return null;
        }

        var data = file.GetVar().AsGodotDictionary();
        file.Close();

        if (data == null)
        {
            GD.PrintErr("存档数据损坏");
            return null;
        }

        return data;
    }

    private Godot.Collections.Array SerializeInventory(Demo.Services.IInventoryService inv)
    {
        var result = new Godot.Collections.Array();
        if (inv == null) return result;

        for (int i = 0; i < inv.SlotCount; i++)
        {
            var slot = inv.GetSlot(i);
            if (slot.IsEmpty) continue;
            result.Add(new Godot.Collections.Dictionary
            {
                ["slot"] = i,
                ["itemId"] = slot.Item.ItemId,
                ["count"] = slot.Count
            });
        }
        return result;
    }

    public void RestoreGame(Godot.Collections.Dictionary data)
    {
        if (data == null) return;
        // Restore will be called from main menu when loading a save
        // This restores all game state from the dictionary
    }

    public bool HasSaveFile() => FileAccess.FileExists(SavePath);

    public void DeleteSave()
    {
        if (HasSaveFile())
            DirAccess.RemoveAbsolute(SavePath);
    }
}
