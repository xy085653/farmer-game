using Godot;
using Demo.Core;
using Demo.Events;

namespace Demo.Player;

public partial class PlayerController : CharacterBody2D
{
    [Export] public float Speed = 120f;

    private AnimatedSprite2D _sprite;
    private Vector2 _facingDirection = Vector2.Down;
    private EventBus _bus;
    private ToolManager _toolManager;

    public override void _Ready()
    {
        _sprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
        _bus = GetNode<EventBus>("/root/EventBus");
        _toolManager = new ToolManager(this);
    }

    public override void _PhysicsProcess(double delta)
    {
        HandleMovement();
        HandleInteraction();
    }

    private void HandleMovement()
    {
        Vector2 inputDir = Input.GetVector("move_left", "move_right", "move_up", "move_down");
        Velocity = inputDir * Speed;

        if (inputDir != Vector2.Zero)
        {
            _facingDirection = inputDir;
        }

        MoveAndSlide();
    }

    private void HandleInteraction()
    {
        if (Input.IsActionJustPressed("use_tool"))
        {
            _toolManager.UseEquippedTool(_facingDirection);
        }
        if (Input.IsActionJustPressed("interact"))
        {
            TryInteract();
        }
        // Hotbar selection (keys 1-8)
        for (int i = 0; i < 8; i++)
        {
            if (Input.IsActionJustPressed($"hotbar_{i + 1}"))
            {
                var registry = ServiceRegistry.Instance;
                registry?.InventoryService?.SetHotbarIndex(i);
            }
        }
    }

    private void TryInteract()
    {
        // Raycast in facing direction to find interactable objects
        var spaceState = GetWorld2D().DirectSpaceState;
        var query = PhysicsRayQueryParameters2D.Create(GlobalPosition, GlobalPosition + _facingDirection * 32);
        query.CollisionMask = 2;  // interactable layer
        var result = spaceState.IntersectRay(query);
        if (result.Count > 0 && result["collider"].AsGodotObject() is Node node)
        {
            node.Call("Interact");
        }
    }
}
