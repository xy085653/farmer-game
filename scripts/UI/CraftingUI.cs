using Godot;
using Demo.Core;
using Demo.Data;

namespace Demo.UI;

public partial class CraftingUI : Control
{
    [Export] public ItemList RecipeList;
    [Export] public Label RecipeNameLabel;
    [Export] public Label IngredientLabel;
    [Export] public Button CraftButton;
    [Export] public Button CloseButton;
    [Export] public WorkbenchType CurrentBench;

    private ServiceRegistry _registry;
    private RecipeData _selectedRecipe;

    public override void _Ready()
    {
        _registry = GetNode<ServiceRegistry>("/root/ServiceRegistry");
        CraftButton?.Connect("pressed", new Callable(this, nameof(OnCraftPressed)));
        CloseButton?.Connect("pressed", new Callable(this, nameof(CloseCrafting)));
        RecipeList?.Connect("item_selected", new Callable(this, nameof(OnRecipeSelected)));
        Hide();
    }

    public void OpenCrafting(WorkbenchType bench)
    {
        CurrentBench = bench;
        Visible = true;
        RefreshRecipes();
    }

    private void RefreshRecipes()
    {
        RecipeList?.Clear();
        var recipes = _registry?.CraftService?.GetAvailableRecipes(CurrentBench);
        if (recipes == null) return;

        foreach (var recipe in recipes)
        {
            if (recipe != null)
                RecipeList.AddItem($"{recipe.RecipeName} x{recipe.ResultCount}");
        }
    }

    private void OnRecipeSelected(long index)
    {
        var recipes = _registry?.CraftService?.GetAvailableRecipes(CurrentBench);
        if (recipes == null || index < 0 || index >= recipes.Count) return;

        _selectedRecipe = recipes[(int)index];
        RecipeNameLabel.Text = _selectedRecipe.RecipeName;

        string ingredients = "材料:\n";
        foreach (var ing in _selectedRecipe.Ingredients)
        {
            if (ing?.Item != null)
                ingredients += $"  {ing.Item.ItemName} x{ing.Count}\n";
        }
        IngredientLabel.Text = ingredients;
    }

    private void OnCraftPressed()
    {
        if (_selectedRecipe == null) return;
        if (_registry?.CraftService?.Craft(_selectedRecipe) == true)
        {
            GD.Print($"制作成功: {_selectedRecipe.RecipeName}");
            RefreshRecipes();
        }
    }

    private void CloseCrafting()
    {
        Visible = false;
    }
}
