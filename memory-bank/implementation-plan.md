# Implementation Plan for "Dot" Game

This document provides a structured roadmap for building the base version of the "Dot" game in Godot. It covers setup, gameplay mechanics, UI, level systems, and basic polish, with tests to validate each step.

---

## Step 1: Set Up the Project in Godot

- Install the latest stable version of Godot.
- Create a new project named "Dot."
- Set the default resolution to 720x1280 (portrait mode).
- Enable 2D rendering mode.
- Assign a new empty scene as the main scene.

**Test:**
- Run the project in Godot.
- Confirm the game window opens at 720x1280 with no errors.

---

## Step 2: Create the Game Grid

- Add a new scene called "GameGrid."
- Use a `Node2D` as the root node.
- Create a script to generate a 6x6 grid of dots using `Sprite2D` nodes.
- Set each dot to be approximately 85 pixels in diameter.
- Use spacing of approximately 47 pixels between dots (edge-to-edge).
- Center the grid both horizontally and vertically on the screen.
- Assign a default gray color to each dot.

**Test:**
- Attach "GameGrid" to the main scene.
- Launch the game and verify a 6x6 grid of gray dots appears.
- Confirm dots are properly sized and spaced.

---

## Step 3: Implement Dot Coloring

- Modify the grid script to assign random colors (e.g., red, blue, green) to dots.
- Ensure at least three distinct colors are used.

**Test:**
- Run the game and confirm dots display random colors.
- Restart multiple times to ensure color randomization works.

---

## Step 4: Enable Touch Input for Dot Selection

- Add touch input detection to the grid script.
- Allow players to tap dots to select them.
- Highlight selected dots with:
  - 10% scale increase.
  - A subtle glowing effect or thin outline in a contrasting color.

**Test:**
- Test using Godot's touch emulation or a mobile device.
- Tap a dot and verify it highlights with both the scale increase and glow effect.
- Tap multiple dots and ensure only the tapped ones are highlighted.

---

## Step 5: Implement Dot Connection Logic

- Add logic to connect adjacent, same-colored dots when selected.
- Display a line between connected dots with the following properties:
  - Line thickness: 2-3 pixels (approximately 1/10th of dot diameter).
  - Line color: Matching the color of the connected dots.
  - Line style: Solid with 80-90% opacity.
  - Line ends: Rounded where they meet the dots.
- Remove connected dots when three or more are linked.
- Add visual feedback when dots are cleared:
  - Fade-out animation lasting 0.3-0.5 seconds.

**Test:**
- Select three adjacent same-colored dots and confirm they connect with properly styled lines.
- Release the selection and verify the connected dots disappear with the fade-out animation.

---

## Step 6: Refill the Grid After Clearing Dots

- Implement a system to spawn new dots at the top after clearing.
- Ensure new dots fall into empty spaces and are randomly colored.
- Animation for refilling:
  - Existing dots should slide downward with gravity-like motion.
  - New dots appear at top and drop into place.
  - Total animation duration: 0.2-0.3 seconds.
  - No significant delay before new dots are generated (max 0.1s buffer).
  - Include a subtle sparkle or fade-out effect (0.1s) when dots are cleared.

**Test:**
- Clear a group of dots and confirm the grid refills with the specified animations.
- Verify the grid returns to a full 6x6 layout.
- Ensure the refill animation is smooth and occurs immediately after clearing.

---

## Step 7: Add Move Counter and Scoring System

- Create a UI label displaying "Moves: 16."
- Position it at the top of the screen.
- Decrease the count by one each time a valid connection is made.
- Implement the scoring system:
  - Each dot cleared counts for one point.
  - Apply a 0.5 multiplier for special dot clearing (square shape connections).
  - Apply a 0.5 multiplier for connecting 10+ dots at once.
  - Add a UI element to display the current score.

**Test:**
- Start the game and confirm the counter shows "Moves: 16."
- Make a connection and verify it updates to "Moves: 15."
- Clear dots and verify the score increases accordingly.
- Test special connections (squares, 10+ dots) and confirm multipliers are applied.

---

## Step 8: Implement Level Objectives

- Define an objective (e.g., "Clear 10 red dots").
- Add a UI label to display progress (e.g., "0/10 red").
- Track cleared red dots during gameplay.

**Test:**
- Launch the game and ensure the objective label is visible.
- Clear red dots and confirm the progress updates.

---

## Step 9: Create Level Completion Logic

- Display "Level Complete" when the objective is met within the move limit.
- Show "Level Failed" if moves run out before completing the objective.
- Add these as centered UI popups.
- Implement the scoring and star rating based on remaining moves:
  - Base points: 60 for completing level objectives.
  - Additional points: Apply multipliers based on remaining moves.

**Test:**
- Meet the objective with moves remaining and verify "Level Complete" appears.
- Exhaust moves without meeting the objective and confirm "Level Failed" shows.
- Verify the appropriate score is calculated and displayed.

---

## Step 10: Add Star Rating System

- Assign stars based on remaining moves:
  - 3 stars: 5+ moves left.
  - 2 stars: 1-4 moves left.
  - 1 star: 0 moves left.
- Display stars on the "Level Complete" screen.

**Test:**
- Finish with 6 moves left and confirm 3 stars are awarded.
- Finish with 2 moves left and verify 2 stars are shown.

---

## Step 11: Create a Basic Level Map

- Create a "LevelMap" scene with a `Node2D` root.
- Add buttons labeled "1," "2," and "3."
- Set level 1 as unlocked and others as locked.
- Use Roboto font (sans-serif) for all text with the following sizes:
  - Headings: 24-28 points.
  - Buttons: 18-20 points.
  - Body text: 16-18 points.
  - Small text: 12-14 points.
  - Level numbers: 20-24 points.

**Test:**
- Open "LevelMap."
- Confirm level 1 is selectable and levels 2 and 3 are locked.
- Verify font consistency and readability.

---

## Step 12: Link Levels to Gameplay

- Configure the level 1 button to load "GameGrid."
- Pass level-specific data (e.g., objective, moves).
- Store level data in JSON format with the following parameters:
  - level_id: Unique identifier for the level.
  - name: Level title.
  - grid_size: Defines the number of rows and columns.
  - available_colors: Defines which dot colors are present.
  - initial_board_state: The starting arrangement of dots.
  - objectives: What the player needs to accomplish.
  - move_limit: Number of moves available.
  - score_targets: Thresholds for earning 1, 2, or 3 stars.
  - background_theme: Visual style of the level.
  - music_track: Background music.
  - next_level_id: Next level in the sequence.

**Test:**
- Click level 1 on the map.
- Verify the grid loads with the correct objective and move count.
- Confirm level data is properly loaded from the JSON file.

---

## Step 13: Implement Level Progression

- Unlock the next level after completing the current one.
- Store progress locally using Godot's Resource system or JSON.

**Test:**
- Complete level 1 and return to the map.
- Confirm level 2 is unlocked.

---

## Step 14: Add Basic UI Elements

- Create a "MainMenu" scene with "Play" and "Settings" buttons.
- Add a "Settings" scene with audio toggles.
- Ensure UI scales for different screen sizes.
- Follow the Roboto font guidelines for consistency across all screens.

**Test:**
- Open the main menu and click "Settings."
- Toggle audio options and verify the UI updates.
- Check that font sizes and styles are consistent.

---

## Step 15: Implement Audio

- Add looping background music to the main menu and gameplay.
- Include sound effects for dot connections and level completion.
- Use OGG Vorbis format with the following specifications:
  - Background music: 128 kbps, 44.1 kHz, stereo.
  - Sound effects: 96 kbps, 44.1 kHz, mono.
- Implement a 0.5-second crossfade for background music transitions between scenes.

**Test:**
- Start the game and confirm music plays.
- Connect dots and complete a level to ensure sound effects trigger.
- Navigate between scenes and verify smooth audio transitions.

---

## Step 16: Optimize for Mobile

- Test on iOS and Android using Godot's export tools.
- Prioritize testing on iPhones for initial optimization.
- Ensure the following performance benchmarks are met:
  - Frame Rate: 60 FPS target, never below 30 FPS.
  - Memory Usage: Below 150 MB average, 200 MB maximum.
  - Load Times: Under 3 seconds for initial launch, under 1 second for level transitions.
  - Battery Consumption: Less than 5% per 30 minutes of play.
  - App Size: Under 50 MB installed.
  - Touch Responsiveness: Less than 50ms input latency.
  - CPU Usage: Below 20% average, 30% maximum.
- Adjust touch sensitivity if needed.
- Ensure UI elements are large enough for tapping.

**Test:**
- Run on mobile devices, particularly iPhones.
- Verify touch controls work smoothly and UI is tappable.
- Monitor and confirm performance benchmarks are met.

---

## Step 17: Implement Local Save System

- Save progress (unlocked levels, stars) using Godot's Resource system.
- Load saved data on startup.

**Test:**
- Complete a level, exit, and restart the game.
- Confirm the next level remains unlocked.

---

## Step 18: Add Visual Polish

- Replace gray dots with colorful designs.
- Add fade-out animations for cleared dots and a celebratory effect for level completion.

**Test:**
- Play the game and clear dots to see new visuals.
- Ensure animations run smoothly.

---

## Step 19: Implement Achievement System (Basic)

- Plan for 20 total achievements covering various gameplay aspects.
- Keep achievements purely local using Godot's Resource system or JSON.
- Add an achievement for completing level 1 (e.g., "First Victory").
- Show a popup when unlocked.

**Test:**
- Finish level 1 and confirm the popup appears.
- Restart and ensure it doesn't trigger again.

---

## Step 20: Create a Gallery Scene

- Add a "Gallery" scene accessible from the main menu.
- Display unlocked achievements in a grid.

**Test:**
- Unlock the level 1 achievement, then visit the gallery.
- Verify "First Victory" is listed.