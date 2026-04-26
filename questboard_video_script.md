# QuestBoard — Video Presentation Script
**Target Duration:** ~6:30 minutes (Approx. 950 words at normal speaking pace)

> [!TIP]
> **Recording Setup Before You Start:**
> 1. Have your Android emulator (or physical device) open and mirrored on screen.
> 2. Open the app to the **Auth Screen** (log out if you are already logged in).
> 3. Have your IDE (VS Code/Android Studio) open in the background to show code snippets when necessary.

---

### 1. Introduction & Background (0:00 - 1:00)

**[Camera/Screen: Your face or title slide with your Name, Student ID, Date, and App Title]**

"Hello, my name is **[Your Name]**, my Student ID is **[Your ID]**, and today is **[Date]**. Welcome to my Mobile Application Development final project presentation. 

My application is called **QuestBoard**. It’s an offline-first, gamified personal productivity app built entirely in Flutter. 

The problem I set out to solve is simple: standard to-do lists are boring, and they lack immediate consequences. People abandon them because checking a box doesn't feel rewarding. 

QuestBoard fixes this by applying the 'game effect'. It wraps your daily tasks in the immersive mechanics of a role-playing game. You don't just complete chores—you embark on quests. Completing them earns you EXP, builds daily streaks, and ranks you up. Missing deadlines actually damages your HP. It’s designed for university students and young professionals who need a stronger, more engaging feedback loop to build habits."

---

### 2. Architecture & Tech Stack (1:00 - 1:45)

**[Screen: Switch to your IDE showing `pubspec.yaml` or `database_helper.dart`]**

"Before we dive into the UI, let’s quickly look under the hood. 

QuestBoard is built using a layered MVVM-influenced architecture with the `Provider` package handling reactive state management. 

Because privacy and speed are critical for personal journals, the app is 100% **offline-first**. Everything is stored locally on the device using a custom SQLite database via the `sqflite` package. 

For authentication, I implemented offline secure registration. Passwords are mathematically hashed using `bcrypt` before they ever touch the database, and session tokens are locked safely in the device’s OS keychain using `flutter_secure_storage`. 

Finally, I integrated native device features using the `camera` package for photo proof, `flutter_local_notifications` for background alerts, and the `http` package for a bonus Web API feature."

---

### 3. App Walkthrough: Auth & The Dashboard (1:45 - 3:00)

**[Screen: Switch to the Emulator showing the Auth Screen, then log in]**

"Let's look at the app. Here on the Auth screen, you can see our Dark Fantasy RPG aesthetic. I used Google Fonts—specifically Cinzel and Rajdhani—combined with glassmorphism blur effects to make it feel like a premium game interface.

I’ll log into my existing account. Notice the custom animated bootloader fetching our local data.

**[Screen: Dashboard loads]**

Welcome to the Dashboard. At the top, we have our Player HUD. You can see my current Class Rank, my Level, my EXP progress bar, and my HP. 

I’ve also implemented a dynamic Rank Progress bar right below it, which calculates exactly how many quests I need to reach the next tier—like moving from D-Class to C-Class. 

At the very bottom, you’ll see our **Web API Bonus feature**. Every time you open the app, or every hour it stays open, the `http` package reaches out to a public API to pull a random motivational 'Quote of the Day'. We also set up a background timer to push these quotes as native notifications every 2 hours to keep the user motivated even when the app is minimized."

---

### 4. Creating a Quest & Push Notifications (3:00 - 4:15)

**[Screen: Click the '+' FAB to open the Create Quest form]**

"Let’s create a new task. I’ll tap the Floating Action Button to open the Quest Creation form. 
I’ll title this *'Record App Demo'*, set the category to *Academic*, and make the difficulty *Medium*. 

For the deadline, I’ll set it just a few minutes from now. The app has form validation to prevent past deadlines. 

**[Screen: Save the Quest. Wait for the 'Quest Accepted' push notification to appear at the top of the emulator]**

When I hit save, a few things happen. The quest is written to the SQLite database, the UI updates reactively via Provider, and... there it is! A native Android Push Notification confirms we’ve accepted the quest. 

Because we targeted Android 14, I had to explicitly program the app to request `POST_NOTIFICATIONS` and `EXACT_ALARM` permissions in the `AndroidManifest`. The app will also trigger high-priority push notifications at precisely 15, 10, 5, and 1 minute before this quest expires to warn the user."

---

### 5. Failure & Penalties (4:15 - 5:00)

**[Screen: Show a failed quest, or wait for the deadline to pass to show the HP penalty]**

"But what happens if we fail? 
If that deadline passes, our `GameProvider` background timer catches it. The quest is marked as 'Failed', and the player instantly loses 20 HP. 

**[Screen: Point to the red HP bar or swipe-to-delete a quest]**

When damage is taken, the phone triggers a distinct haptic vibration using the `vibration` package, and the screen updates immediately. If HP hits zero, your rank gets severely penalized. It makes procrastination actually sting. 
If you made a mistake, you can also swipe left to permanently abandon a quest, which safely cancels all scheduled notifications."

---

### 6. Success, Camera Integration & Achievements (5:00 - 6:00)

**[Screen: Tap a pending quest to Complete it. The Camera screen opens.]**

"Let's complete a quest instead. I'll tap this pending quest. 
To prove we actually did the work, QuestBoard requires evidence. This opens a custom camera interface built with the `camera` package. 

**[Screen: Snap a photo, click the checkmark]**

I’ll snap a photo of my laptop. This image is saved to the local file system, and its file path is linked to the quest in our SQLite database. 

**[Screen: Return to dashboard, point out the EXP increase]**

Upon completion, we gain EXP based on the difficulty. If we complete quests on consecutive days, our 'Streak Multiplier' kicks in, boosting our EXP. If we hit the 100 EXP threshold, we level up, and our HP is fully restored!

Also, hitting specific milestones—like completing 10 quests or reaching Level 5—triggers our Achievement Engine. The app evaluates 15 different logical conditions and pushes an animated popup when a new badge is unlocked."

---

### 7. Trophy Room & Conclusion (6:00 - 6:30)

**[Screen: Navigate to the Trophy Room via the bottom navigation bar]**

"Finally, we can visit the Trophy Room. This gallery pulls all our saved camera images from the local storage, creating a visual diary of our productivity journey. 

In conclusion, QuestBoard successfully merges local database architecture, hardware integration, and background scheduling into a cohesive, gamified experience. It meets all functional requirements and the Web API bonus while remaining fast and offline-first. 

Thank you for watching."
