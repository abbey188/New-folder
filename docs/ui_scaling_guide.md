# UI Scaling and Responsive Design Guide for Dot

This document outlines the UI scaling and responsive design approach used in the Dot game to ensure a consistent user experience across various device sizes and resolutions.

## Core Concepts

### 1. Design Reference Resolution

The game is designed with a reference resolution of 720x1280 pixels (portrait mode). This is a common mobile game resolution that works well on most smartphones.

```gdscript
const DESIGN_WIDTH = 720
const DESIGN_HEIGHT = 1280
```

### 2. Scaling Approach

We use a hybrid scaling approach:
- **Content Scaling**: The `canvas_items` stretch mode scales the entire game content to fit the viewport.
- **Expand Aspect**: This preserves the aspect ratio while ensuring the entire viewport is covered, potentially showing more of the game world on wider screens.

```gdscript
# In project.godot:
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

### 3. Safe Area Margins

To ensure UI elements don't get cut off by notches, punch holes, or screen edges, we implement safe area margins:

```gdscript
# Margin percentages for safe areas
const TOP_MARGIN_PERCENT = 5
const BOTTOM_MARGIN_PERCENT = 5
const SIDE_MARGIN_PERCENT = 3
```

### 4. Device Classification

The system detects the device type based on screen width:

```gdscript
const TABLET_MIN_WIDTH = 768
const DESKTOP_MIN_WIDTH = 1024

func get_device_class() -> String:
    var width = get_viewport().size.x
    
    if width >= DESKTOP_MIN_WIDTH:
        return "desktop"
    elif width >= TABLET_MIN_WIDTH:
        return "tablet"
    else:
        return "phone"
```

## Implementation Components

### 1. UIScaling Singleton

A global autoload script that:
- Calculates scaling factors based on current device resolution
- Provides safe area margins
- Offers utility functions for scaling UI elements

Access it anywhere with: `get_node("/root/UIScaling")`

### 2. Responsive Container

A reusable scene that automatically:
- Applies appropriate margins based on device type
- Adjusts to orientation changes
- Repositions content based on UI scaling

### 3. Theme System

A centralized theme resource (`dot_theme.tres`) ensures consistent styling across the app with:
- Standardized colors
- Consistent button styles
- Typography scale
- Properly sized interactive elements for touch

## Best Practices

1. **Use Control Nodes with Anchors**: Always use Control nodes with proper anchors (typically `anchors_preset = 15` for full-screen containers)

2. **Containers for Layout**: Use HBoxContainer, VBoxContainer, and MarginContainer to create flexible layouts

3. **Size Flags**: Use size_flags_horizontal and size_flags_vertical to control how elements use available space

4. **Custom Minimum Size**: Set custom_minimum_size for UI elements that need specific dimensions

5. **Theme Overrides**: Use theme overrides for exceptions rather than creating new styles for each element

6. **Safe Areas**: Always place UI elements within safe area containers to prevent cutoff

## Handling Orientation Changes

The system automatically recalculates scaling factors and margins on viewport size changes:

```gdscript
func _on_viewport_size_changed():
    # Re-apply the safe area margins
    if get_node_or_null("/root/UIScaling") and safe_area:
        var ui_scaling = get_node("/root/UIScaling")
        
        # Recalculate because UIScaling would have updated its values
        var margins = Vector4(
            ui_scaling.left_margin,
            ui_scaling.top_margin,
            ui_scaling.right_margin,
            ui_scaling.bottom_margin
        )
        
        safe_area.add_theme_constant_override("margin_left", margins.x)
        safe_area.add_theme_constant_override("margin_top", margins.y)
        safe_area.add_theme_constant_override("margin_right", margins.z)
        safe_area.add_theme_constant_override("margin_bottom", margins.w)
```

## Adding New Screens

When creating new UI screens:

1. Start with a Control node as the root
2. Apply the dot_theme.tres theme
3. Add a MarginContainer for safe area
4. Use VBoxContainer for vertical layouts
5. Test on multiple resolutions using the Editor's viewport resize handles

## Testing

Always test your UI on multiple device sizes:
- Phone (Portrait): 360x640, 375x667, 390x844
- Phone (Landscape): 640x360, 667x375, 844x390
- Tablet: 768x1024, 834x1194, 1024x1366
- Desktop: 1280x720, 1920x1080

The in-editor preview tool is useful for quick testing, but real device testing is recommended for production. 