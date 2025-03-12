using System;
using System.Runtime.InteropServices;
using Godot;

public partial class ClickThroughWindow : Node2D
{
	[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
	private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

	private const int GWL_EXSTYLE = -20;
	private const int WS_EX_LAYERED = 0x00080000;
	private const int WS_EX_TRANSPARENT = 0x00000020;

	private IntPtr windowHandle;
	private bool isClickThroughEnabled = false;

	public override void _Ready()
	{
		windowHandle = GetGodotWindowHandle();
		if (windowHandle == IntPtr.Zero)
		{
			GD.PrintErr("Failed to find Godot window handle.");
		}
		else
		{
			GD.Print("Godot Window Handle Found: " + windowHandle);
			SetClickThrough(true); // Start in click-through mode
		}
	}

	public override void _Process(double delta)
	{
		if (windowHandle == IntPtr.Zero) return;

		Vector2 mousePos = GetViewport().GetMousePosition();
		Node2D hoveredObject = GetHoveredObject(mousePos);

		if (hoveredObject != null)
		{
			if (isClickThroughEnabled)
			{
				GD.Print("Mouse over: " + hoveredObject.Name + " (Click enabled)");
				SetClickThrough(false); // Allow clicks on objects
			}
		}
		else
		{
			if (!isClickThroughEnabled)
			{
				GD.Print("Mouse over empty space (Click-through enabled)");
				SetClickThrough(true); // Make window transparent again
			}
		}
	}

	private void SetClickThrough(bool enable)
	{
		if (windowHandle == IntPtr.Zero) return;

		if (enable)
		{
			SetWindowLong(windowHandle, GWL_EXSTYLE, WS_EX_LAYERED | WS_EX_TRANSPARENT);
		}
		else
		{
			SetWindowLong(windowHandle, GWL_EXSTYLE, WS_EX_LAYERED);
		}

		isClickThroughEnabled = enable;
	}

	private IntPtr GetGodotWindowHandle()
	{
		// Change "Godot Engine" to match the window title of your game (if custom)
		return FindWindow(null, "DesktopFox (DEBUG)");
	}

	private Node2D GetHoveredObject(Vector2 position)
	{
		var spaceState = GetWorld2D().DirectSpaceState;
		PhysicsPointQueryParameters2D query = new PhysicsPointQueryParameters2D
		{
			Position = position,
			CollideWithAreas = true,
			CollideWithBodies = true
		};

		var results = spaceState.IntersectPoint(query);
		if (results.Count > 0)
		{
			if (results[0].TryGetValue("collider", out Variant colliderVariant))
			{
				if (colliderVariant.AsGodotObject() is Node2D node)
				{
					return node; // Found an interactive object
				}
			}
		}

		return null; // No object under mouse
	}
}
