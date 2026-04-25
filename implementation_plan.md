# QuestBoard: Daily Streak & Achievement System

Add two complementary gamification features that drive daily engagement and long-term progression.

## Feature 1: Daily Streak System

**Concept:** Track consecutive days where the player completes at least one quest. Display a fire streak counter on the dashboard and apply bonus EXP multipliers for longer streaks.

**Streak Multipliers:**
| Streak | Multiplier |
|--------|-----------|
| 0–2 days | 1.0× |
| 3–6 days | 1.25× |
| 7–13 days | 1.5× |
| 14–29 days | 1.75× |
| 30+ days | 2.0× |

## Feature 2: Achievement/Badge System

**Concept:** 15 unlockable badges earned through milestones. Displayed in a dedicated "Achievements" screen with locked/unlocked visuals and a popup animation on unlock.

**Starter Badge List (15 badges):**

| Badge | Trigger | Icon |
|-------|---------|------|
| First Blood | Complete 1 quest | ⚔️ |
| Decathlon | Complete 10 quests | 🏅 |
| Centurion | Complete 50 quests | 🏛️ |
| Scholar | Complete 5 Academic quests | 📚 |
| Iron Will | Complete 5 Fitness quests | 💪 |
| Life Hacker | Complete 5 Life quests | 🏠 |
| Streak Starter | Reach a 3-day streak | 🔥 |
| On Fire | Reach a 7-day streak | 🔥🔥 |
| Unstoppable | Reach a 30-day streak | ☄️ |
| Level 5 | Reach level 5 | ⭐ |
| Level 10 | Reach level 10 | 🌟 |
| Level 25 | Reach level 25 | 💫 |
| S-Class Hunter | Reach S-Class rank | 🏆 |
| Hard Mode | Complete 5 Hard quests | 💀 |
| Perfectionist | Complete 10 quests with no failures | ✨ |

---

## Proposed Changes

### Database Layer

#### [MODIFY] [database_helper.dart](file:///c:/Users/kkaid/Downloads/Flutter%20apps/QUESTBOARD/lib/data/database_helper.dart)

- **Bump DB version** from 1 → 2 with migration
- **Add columns to `Player_Stats`:** `current_streak` (INT), `longest_streak` (INT), `last_quest_date` (TEXT, ISO date string)
- **New table `Achievements`:** `id` (TEXT PK), `unlocked_at` (TEXT, nullable — null = locked)
- Add methods: `getAchievements()`, `unlockAchievement(id, date)`, `getUnlockedAchievementIds()`

---

### Models

#### [MODIFY] [player.dart](file:///c:/Users/kkaid/Downloads/Flutter%20apps/QUESTBOARD/lib/models/player.dart)

- Add fields: `currentStreak` (int), `longestStreak` (int), `lastQuestDate` (String)
- Update `toMap()`, `fromMap()`, `copyWith()`

#### [NEW] `lib/models/achievement.dart`

- `Achievement` class with: `id`, `title`, `description`, `iconData` (IconData), `isUnlocked`, `unlockedAt`
- Static list of all 15 achievement definitions

---

### Provider

#### [MODIFY] [game_provider.dart](file:///c:/Users/kkaid/Downloads/Flutter%20apps/QUESTBOARD/lib/providers/game_provider.dart)

- **Streak logic in `completeQuest()`:**
  - Compare `lastQuestDate` to today
  - Same day → no streak change
  - Yesterday → increment streak
  - Older → reset streak to 1
  - Update `longestStreak` if current exceeds it
- **EXP multiplier:** Apply streak multiplier to `quest.expReward` before adding
- **Achievement checking:** After every quest completion / level up / streak change, run `_checkAchievements()` to scan for newly unlocked badges
- **New state:** `List<Achievement> _achievements`, `List<Achievement> _newlyUnlocked` (for popup display)
- Load achievements on `init()`

---

### Screens

#### [MODIFY] [dashboard_screen.dart](file:///c:/Users/kkaid/Downloads/Flutter%20apps/QUESTBOARD/lib/screens/dashboard_screen.dart)

- Add **streak display** in the stats header: fire icon + streak count + current multiplier
- Add **achievements icon** button in the app bar (next to Trophy Room)
- Show **achievement unlock popup** (dialog/snackbar) when `newlyUnlocked` is non-empty

#### [NEW] `lib/screens/achievements_screen.dart`

- Grid display of all 15 badges
- Locked badges: greyed out with lock overlay
- Unlocked badges: full color with glow/shimmer effect + unlock date
- Tap on unlocked badge → detail bottom sheet with title, description, date earned

---

## Verification Plan

### Automated Tests
```bash
cd "c:\Users\kkaid\Downloads\Flutter apps\QUESTBOARD"
flutter analyze
```

### Manual Verification
- Build and run on emulator/device
- Create and complete quests to verify streak increments and EXP multiplier displays correctly
- Check that achievements unlock at proper thresholds
- Verify database migration doesn't corrupt existing data
