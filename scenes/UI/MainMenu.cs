using Godot;

namespace Demo.UI;

public partial class MainMenu : Control
{
    private Button _newGameBtn;
    private Button _continueBtn;
    private Button _exitBtn;

    public override void _Ready()
    {
        _newGameBtn = GetNode<Button>("NewGameBtn");
        _continueBtn = GetNode<Button>("ContinueBtn");
        _exitBtn = GetNode<Button>("ExitBtn");

        _newGameBtn.Connect("pressed", new Callable(this, nameof(OnNewGame)));
        _continueBtn.Connect("pressed", new Callable(this, nameof(OnContinue)));
        _exitBtn.Connect("pressed", new Callable(this, nameof(OnExit)));
    }

    private void OnNewGame()
    {
        // Start a new game - load the Game scene
        GetTree().ChangeSceneToFile("res://scenes/Game.tscn");
    }

    private void OnContinue()
    {
        // Load saved game
        // First load the Game scene, then restore from save
        GetTree().ChangeSceneToFile("res://scenes/Game.tscn");
    }

    private void OnExit()
    {
        GetTree().Quit();
    }
}
