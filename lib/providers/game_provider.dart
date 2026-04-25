import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../data/database_helper.dart';
import '../models/player.dart';
import '../models/quest.dart';
import '../models/achievement.dart';
import '../services/notification_service.dart';
import '../services/vibration_service.dart';
import '../services/auth_service.dart';

class GameProvider extends ChangeNotifier {
  PlayerStats? _player;
  List<Quest> _quests = [];
  List<Achievement> _achievements = [];
  List<Achievement> _newlyUnlocked = [];
  bool _isLoading = true;
  String? _userId;
  Timer? _deadlineTimer;
  List<CameraDescription> _cameras = [];

  PlayerStats? get player => _player;
  List<Quest> get quests => _quests;
  List<Achievement> get achievements => _achievements;
  List<Achievement> get newlyUnlocked => _newlyUnlocked;
  bool get isLoading => _isLoading;
  String? get userId => _userId;
  bool get isAuthenticated => _userId != null;
  List<CameraDescription> get cameras => _cameras;

  List<Quest> get pendingQuests =>
      _quests.where((q) => q.status == 'Pending').toList();
  List<Quest> get completedQuests =>
      _quests.where((q) => q.status == 'Completed').toList();
  List<Quest> get failedQuests =>
      _quests.where((q) => q.status == 'Failed').toList();

  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Load available cameras into the provider
    try {
      _cameras = await availableCameras();
    } catch (_) {
      _cameras = [];
    }

    _userId = await _authService.getAuthenticatedUserId();

    if (_userId != null) {
      await loadUserData();
    }

    // Start periodic check for deadlines while app is open
    _deadlineTimer?.cancel();
    _deadlineTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_userId != null && _player != null) {
        _checkMissedDeadlines();
      }
    });

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _deadlineTimer?.cancel();
    super.dispose();
  }

  Future<void> loadUserData() async {
    if (_userId == null) return;
    
    _player = await DatabaseHelper.instance.getPlayer(_userId!);
    
    _quests = await DatabaseHelper.instance.getAllQuests(_userId!);
    await _loadAchievements();

    if (_player != null) {
      await _checkMissedDeadlines();
      await _checkAchievements();
    }
  }

  Future<void> login(String email, String password) async {
    final user = await _authService.login(email, password);
    if (user != null) {
      _userId = user.id;
      await loadUserData();
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    final user = await _authService.signUp(email, password);
    if (user != null) {
      _userId = user.id;
      await loadUserData();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _userId = null;
    _player = null;
    _quests = [];
    _achievements = [];
    notifyListeners();
  }

  Future<void> _loadAchievements() async {
    if (_userId == null) return;
    final unlocked = await DatabaseHelper.instance.getUnlockedAchievements(_userId!);
    _achievements = Achievement.definitions.map((def) {
      if (unlocked.containsKey(def.id)) {
        return def.copyWith(isUnlocked: true, unlockedAt: unlocked[def.id]);
      }
      return def;
    }).toList();
  }

  Future<void> createPlayer(String name) async {
    if (_userId == null) return;
    final newPlayer = PlayerStats(
      userId: _userId!,
      name: name,
      level: 1,
      currentExp: 0,
      hp: 100,
      totalCompletedQuests: 0,
      rank: 'E-Class',
      currentStreak: 0,
      longestStreak: 0,
      lastQuestDate: '',
    );
    await DatabaseHelper.instance.createPlayer(newPlayer);
    _player = newPlayer;
    notifyListeners();
  }

  // FIX: Made async so DB writes and player updates are properly awaited;
  // also calls notifyListeners() and saves rank to DB.
  Future<void> _checkMissedDeadlines() async {
    bool hasDamage = false;
    for (var quest in _quests.toList()) {
      if (quest.status == 'Pending') {
        final deadline = DateTime.parse(quest.deadline);
        if (deadline.isBefore(DateTime.now())) {
          await _failQuestInternal(quest); // FIX: awaited — HP + DB saves complete before continuing
          hasDamage = true;
        }
      }
    }
    if (hasDamage) {
      _calculateRank(); // FIX: moved after await loop — rank reflects all newly-failed quests
      // FIX: Save rank change back to DB (this was missing before)
      await DatabaseHelper.instance.updatePlayer(_player!);
      // Small delay to prevent haptic racing with DB writes
      Future.delayed(const Duration(milliseconds: 500), () {
        VibrationService.playDamageHaptic();
      });
      notifyListeners();
    }
  }

  Future<void> addQuest(Quest quest) async {
    await DatabaseHelper.instance.insertQuest(quest);
    _quests.add(quest);

    // Notifications
    try {
      await _notificationService.showQuestAcceptedNotification(quest.title);
      await _notificationService.scheduleQuestDeadline(
          quest.id, quest.title, DateTime.parse(quest.deadline));
    } catch (e) {
      debugPrint('Notification error: $e');
    }

    notifyListeners();
  }

  /// Permanently deletes a Pending quest from the DB and in-memory list.
  /// Rank is recalculated and persisted after removal.
  Future<void> deleteQuest(String questId) async {
    await DatabaseHelper.instance.deleteQuest(questId);
    try {
      await _notificationService.cancelQuestDeadline(questId);
    } catch (_) {}
    _quests.removeWhere((q) => q.id == questId);
    if (_player != null) {
      _calculateRank();
      await DatabaseHelper.instance.updatePlayer(_player!);
    }
    notifyListeners();
  }

  Future<void> completeQuest(String questId, String mediaPath) async {
    final int index = _quests.indexWhere((q) => q.id == questId);
    if (index == -1) return;

    final Quest quest = _quests[index];

    // --- Streak logic ---
    _updateStreak();
    // FIX: Persist streak change immediately so it isn't lost if app crashes later
    await DatabaseHelper.instance.updatePlayer(_player!);

    // --- Apply EXP multiplier ---
    final double multiplier = _player!.streakMultiplier;
    final int boostedExp = (quest.expReward * multiplier).round();

    final Quest updatedQuest =
        quest.copyWith(status: 'Completed', mediaProofPath: mediaPath);

    await DatabaseHelper.instance.updateQuest(updatedQuest);
    await _notificationService.cancelQuestDeadline(quest.id);

    _quests[index] = updatedQuest;

    _player = _player!.copyWith(
      currentExp: _player!.currentExp + boostedExp,
      totalCompletedQuests: _player!.totalCompletedQuests + 1,
    );

    // Level up logic (100 EXP per level)
    int expNeeded = _player!.level * 100;
    while (_player!.currentExp >= expNeeded) {
      _player = _player!.copyWith(
        level: _player!.level + 1,
        currentExp: _player!.currentExp - expNeeded,
        hp: 100, // heal on level up
      );
      expNeeded = _player!.level * 100;
      VibrationService.playLevelUpHaptic();
    }

    _calculateRank();
    await DatabaseHelper.instance.updatePlayer(_player!);

    // --- Check achievements ---
    _newlyUnlocked = [];
    await _checkAchievements();

    notifyListeners();
  }

  void _updateStreak() {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (_player!.lastQuestDate == todayStr) {
      // Already completed a quest today — no streak change
      return;
    }

    int newStreak;
    if (_player!.lastQuestDate.isEmpty) {
      // Very first quest ever
      newStreak = 1;
    } else {
      final lastDate = DateTime.parse(_player!.lastQuestDate);
      final diff = DateTime(today.year, today.month, today.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      if (diff == 1) {
        newStreak = _player!.currentStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    final int newLongest =
        newStreak > _player!.longestStreak ? newStreak : _player!.longestStreak;

    _player = _player!.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastQuestDate: todayStr,
    );
  }

  Future<void> _checkAchievements() async {
    final int completed = completedQuests.length;
    final int academicCompleted =
        completedQuests.where((q) => q.category == 'Academic').length;
    final int fitnessCompleted =
        completedQuests.where((q) => q.category == 'Fitness').length;
    final int lifeCompleted =
        completedQuests.where((q) => q.category == 'Life').length;
    final int hardCompleted =
        completedQuests.where((q) => q.difficulty == 'Hard').length;
    final int streak = _player!.currentStreak;
    final int level = _player!.level;
    final String rank = _player!.rank;
    final int failed = failedQuests.length;

    final Map<String, bool Function()> checks = {
      'first_blood': () => completed >= 1,
      'decathlon': () => completed >= 10,
      'centurion': () => completed >= 50,
      'scholar': () => academicCompleted >= 5,
      'iron_will': () => fitnessCompleted >= 5,
      'life_hacker': () => lifeCompleted >= 5,
      'streak_starter': () => streak >= 3,
      'on_fire': () => streak >= 7,
      'unstoppable': () => streak >= 30,
      'level_5': () => level >= 5,
      'level_10': () => level >= 10,
      'level_25': () => level >= 25,
      's_class': () => rank == 'S-Class',
      'hard_mode': () => hardCompleted >= 5,
      'perfectionist': () => completed >= 10 && failed == 0,
    };

    final todayStr = DateTime.now().toIso8601String().split('T').first;

    for (int i = 0; i < _achievements.length; i++) {
      final a = _achievements[i];
      if (!a.isUnlocked && checks.containsKey(a.id) && checks[a.id]!()) {
        _achievements[i] = a.copyWith(isUnlocked: true, unlockedAt: todayStr);
        _newlyUnlocked.add(_achievements[i]);
        if (_userId != null) {
          await DatabaseHelper.instance.unlockAchievement(_userId!, a.id, todayStr);
        }
      }
    }
  }

  /// Call this from a widget after showing the popup to clear the queue
  void clearNewlyUnlocked() {
    _newlyUnlocked = [];
  }

  // FIX: Now properly Future<void> — async DB writes are awaited,
  // errors won't be silently lost.
  Future<void> _failQuestInternal(Quest quest) async {
    final Quest updatedQuest = quest.copyWith(status: 'Failed');
    await DatabaseHelper.instance.updateQuest(updatedQuest);
    final int index = _quests.indexWhere((q) => q.id == quest.id);
    if (index != -1) _quests[index] = updatedQuest;

    int newHp = _player!.hp - 20; // 20 HP penalty per missed quest
    if (newHp < 0) newHp = 0;

    _player = _player!.copyWith(hp: newHp);
    await DatabaseHelper.instance.updatePlayer(_player!);
  }

  /// Calculates rank from total completed quests (milestone thresholds).
  ///
  /// Thresholds (cumulative completed quests):
  ///   E-Class :    0 – 99
  ///   D-Class :  100 – 299   (+100 from E)
  ///   C-Class :  300 – 599   (+200 from D)
  ///   B-Class :  600 – 999   (+300 from C)
  ///   A-Class : 1000 – 1499  (+400 from B)
  ///   S-Class : 1500 +       (+500 from A)
  ///
  /// HP = 0 overrides rank to E-Class.
  void _calculateRank() {
    if (_player == null) return;

    final int completed = _player!.totalCompletedQuests;

    String newRank;
    if (completed >= 1500) {
      newRank = 'S-Class';
    } else if (completed >= 1000) {
      newRank = 'A-Class';
    } else if (completed >= 600) {
      newRank = 'B-Class';
    } else if (completed >= 300) {
      newRank = 'C-Class';
    } else if (completed >= 100) {
      newRank = 'D-Class';
    } else {
      newRank = 'E-Class';
    }

    if (_player!.hp == 0) newRank = 'E-Class'; // Penalty for zero HP

    _player = _player!.copyWith(rank: newRank);
  }
}
