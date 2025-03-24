# Game Design Document: Dot

## 1. Game Overview

"Dot" is a mobile puzzle game where players connect dots of the same color to achieve level-specific objectives within a limited number of moves. The game features a star-based progression system, an achievement system with unlockable collectibles, and a gallery to view achievements. The design emphasizes a **minimalist, visually engaging aesthetic** optimized for mobile devices, with smooth touch controls and rewarding feedback.

## 2. Core Gameplay Mechanics

- **Dot-Connecting**: Players connect matching dots of the same color by dragging a line between them using intuitive touch controls. When connected, the dots disappear, and new dots fall from above to fill the grid.
- **Moves Limit**: Each level has a set number of moves (e.g., "16 MOVES"). Players must complete objectives within this limit.
- **Feedback**: Subtle animations (e.g., glowing dots when connected) and sound effects provide feedback for actions like connecting dots or completing levels.

## 3. Level Objectives and Difficulty

- **Objectives**: Levels feature varied goals, including:
  - Clearing a specific number of dots (e.g., "6/15 blue").
  - Achieving a target score.
  - Forming specific patterns (e.g., lines, squares).
  - Completing levels within time or move constraints.
- **Increasing Difficulty**: As players progress, levels introduce:
  - **Obstacles**: Blocked or locked dots that require special actions to clear.
  - **Special Dots**: Bombs or wildcards that affect gameplay.
  - **Constraints**: Fewer moves or additional challenges.
- **Tutorial Levels**: Early levels gradually introduce mechanics to onboard new players.

## 4. Star System and Progression

- **Stars Earned**: Players earn 1–3 stars per level based on performance (e.g., moves remaining or score achieved).
- **Level Map**: A map screen displays levels as nodes connected by a path. Each node shows the level number and stars earned (e.g., "LEVEL 12" with stars).
- **Progression Bar**: A bar tracks total stars and shows progress toward the next achievement milestone (e.g., 10, 20, 30 stars).
- **Resource Indicators**: The top of the screen shows:
  - Lives (e.g., "4" hearts with a regeneration timer).
  - Currency (e.g., "25" coins).

## 5. Achievement System

- **Milestone Unlocks**: Collectibles are unlocked when players reach star milestones (e.g., 10, 20, 30 stars).
- **Popup Notifications**: Upon unlocking an achievement, a celebratory popup appears with:
  - A title (e.g., "EXCEPTIONAL TRIUMPH").
  - A glowing badge or icon.
  - A brief description.
  - Animations and sound effects.
  - Buttons: "Continue" and "View All Achievements."
- **Failure Popups**: When out of lives, a modal appears with:
  - A sad character.
  - Remaining lives (e.g., 1 red heart, 4 gray).
  - A timer (e.g., "NEXT LIFE IN 17:39").
  - An option to "Refill Lives" using currency.

## 6. Gallery System

- **Access**: Reachable from the main menu or achievement popups via "View All Achievements."
- **Display**: Unlocked collectibles are shown in an interactive grid with icons and descriptions.
- **Interaction**: Tapping an achievement reveals details or plays a short animation.

## 7. UI and UX Design

- **Touch Controls**: Optimized for mobile with responsive dot-connecting and large, tappable buttons (e.g., "Restart," "Exit to Map").
- **Visual Design**: A minimalist dark blue gradient background keeps focus on gameplay. UI elements are rounded for a modern look.
- **Navigation Bar**: At the bottom, icons include Home, Map, and Options.
- **Life System**: Lives regenerate over time (e.g., "16:47" timer). Players can refill lives using currency.
- **Settings Menu**: Accessible via a gear icon, offering toggles for:
  - Music (on by default).
  - Sound Effects (on by default).
  - Haptics (on by default).
  - Colorblind Mode (off by default).

## 8. Visual and Audio Feedback

- **Animations**: Smooth animations for dot connections, level completions, and achievement unlocks (e.g., sparkles, glowing effects).
- **Sound Effects**: Subtle audio cues for actions like connecting dots, earning stars, or unlocking achievements.
- **Popup Feedback**: Achievement popups feature celebratory animations and sounds; failure popups use softer tones.

## 9. Settings and Accessibility

- **Settings Menu**: Includes options for:
  - Toggling music, sound effects, and haptics.
  - Enabling colorblind mode for accessibility.
- **UI Consistency**: All screens maintain a uniform aesthetic with rounded elements and clear, tappable buttons.

## Summary

"Dot" is designed to be an engaging, mobile-optimized puzzle game with intuitive controls, rewarding progression, and a clean, minimalist aesthetic. The star-based system and achievements provide motivation, while the gallery and interactive elements enhance replayability. The UI and UX are tailored for mobile, ensuring a smooth and enjoyable player experience.