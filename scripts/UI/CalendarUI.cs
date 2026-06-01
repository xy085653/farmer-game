using Godot;
using Demo.Data;

namespace Demo.UI;

public partial class CalendarUI : Control
{
    [Export] public GridContainer TermGrid;
    [Export] public Label CurrentTermLabel;
    [Export] public Label EffectLabel;
    [Export] public Button CloseButton;

    private static readonly SolarTerm[] AllTerms = (SolarTerm[])System.Enum.GetValues(typeof(SolarTerm));

    public override void _Ready()
    {
        CloseButton?.Connect("pressed", new Callable(this, nameof(CloseCalendar)));
        Hide();
        PopulateGrid();
    }

    private void PopulateGrid()
    {
        if (TermGrid == null) return;
        foreach (var term in AllTerms)
        {
            var label = new Label();
            var season = SolarTermHelper.GetSeason(term);
            string seasonIcon = season switch
            {
                Season.Spring => "\U0001f338", Season.Summer => "☀️",
                Season.Autumn => "\U0001f342", Season.Winter => "❄️",
                _ => ""
            };
            label.Text = $"{seasonIcon} {SolarTermHelper.GetDisplayName(term)}";
            TermGrid.AddChild(label);
        }
    }

    public void OpenCalendar()
    {
        Visible = true;
        // Highlight current term
    }

    private void CloseCalendar()
    {
        Visible = false;
    }
}
