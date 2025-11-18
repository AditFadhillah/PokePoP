# Integration Guide: Notify React When ENTER is Pressed

## What Changed

We added a new function `notify_enter_pressed()` to `js_bridge.gd` that sends a signal to React when ENTER is pressed in the game.

## How to Integrate

Find the script that handles the "PRESS ENTER TO START GAME" screen. This is likely in your main menu or intro scene.

### Option 1: In the script that handles the intro/menu

```gdscript
extends Node2D  # or whatever your base class is

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ENTER:
            # Your existing code to start the game
            start_game()  # or whatever you call
            
            # NEW: Notify React that ENTER was pressed
            if JSBridge:
                JSBridge.notify_enter_pressed()

func start_game():
    # Your existing game start logic
    pass
```

### Option 2: If you're using a signal-based approach

```gdscript
# In your menu/intro script
func _on_start_game_pressed():
    # Your existing code
    transition_to_game()
    
    # NEW: Notify React
    if JSBridge:
        JSBridge.notify_enter_pressed()
```

### Option 3: In a centralized input handler

If you have a global input handler (like in an autoload):

```gdscript
# In your global input handler
func _unhandled_input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ENTER:
            if game_state == INTRO_SCREEN:  # or whatever your state is
                # Notify React
                if JSBridge:
                    JSBridge.notify_enter_pressed()
```

## Flow After Integration

1. **User clicks "🎮 Start Game & Load Trainer"** in React
2. **React sends PRESS_ENTER** signal to Godot
3. **Godot simulates ENTER keypress**
4. **Godot detects ENTER was pressed** (in your game code)
5. **Godot calls `JSBridge.notify_enter_pressed()`**
6. **React receives `ENTER_PRESSED_IN_GAME` signal**
7. **React waits 2 seconds**
8. **React sends trainer data**
9. **Game displays trainer** ✅

## Testing

1. Make sure `JSBridge` autoload exists (check Project Settings > Autoload)
2. Add the notification call to your ENTER handler
3. Re-export the game to web
4. Test by clicking "🎮 Start Game & Load Trainer" button
5. Check browser console for:
   - "Sent ENTER_PRESSED_IN_GAME signal to React"
   - "ENTER pressed in game, waiting 2 seconds before sending trainer data..."
   - "Sending trainer to game: [trainer_name]"

## Common Issues

**Issue**: Signal not being sent
- **Solution**: Make sure `JSBridge` is properly added as an autoload in Project Settings

**Issue**: Trainer still not appearing
- **Solution**: Check browser console for errors, ensure the 2-second delay is enough

**Issue**: Multiple signals being sent
- **Solution**: Add a flag to prevent multiple calls, like:
  ```gdscript
  var enter_notified = false
  
  func _input(event):
      if event.keycode == KEY_ENTER and not enter_notified:
          enter_notified = true
          if JSBridge:
              JSBridge.notify_enter_pressed()
  ```
