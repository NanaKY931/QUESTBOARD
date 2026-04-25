class PlayerStats {
  final String userId;
  final String name;
  final int level;
  final int currentExp;
  final int hp;
  final int totalCompletedQuests;
  final String rank;
  final int currentStreak;
  final int longestStreak;
  final String lastQuestDate; // ISO 8601 date-only string (yyyy-MM-dd)

  PlayerStats({
    required this.userId,
    required this.name,
    required this.level,
    required this.currentExp,
    required this.hp,
    required this.totalCompletedQuests,
    required this.rank,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastQuestDate = '',
  });

  /// Returns the EXP multiplier based on current streak length
  double get streakMultiplier {
    if (currentStreak >= 30) return 2.0;
    if (currentStreak >= 14) return 1.75;
    if (currentStreak >= 7) return 1.5;
    if (currentStreak >= 3) return 1.25;
    return 1.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'level': level,
      'current_exp': currentExp,
      'hp': hp,
      'total_completed_quests': totalCompletedQuests,
      'rank': rank,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_quest_date': lastQuestDate,
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      userId: map['user_id'] as String,
      name: map['name'] as String,
      level: map['level'] as int,
      currentExp: map['current_exp'] as int,
      hp: map['hp'] as int,
      totalCompletedQuests: map['total_completed_quests'] as int,
      rank: map['rank'] as String,
      currentStreak: (map['current_streak'] as int?) ?? 0,
      longestStreak: (map['longest_streak'] as int?) ?? 0,
      lastQuestDate: (map['last_quest_date'] as String?) ?? '',
    );
  }

  PlayerStats copyWith({
    String? userId,
    String? name,
    int? level,
    int? currentExp,
    int? hp,
    int? totalCompletedQuests,
    String? rank,
    int? currentStreak,
    int? longestStreak,
    String? lastQuestDate,
  }) {
    return PlayerStats(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      hp: hp ?? this.hp,
      totalCompletedQuests: totalCompletedQuests ?? this.totalCompletedQuests,
      rank: rank ?? this.rank,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastQuestDate: lastQuestDate ?? this.lastQuestDate,
    );
  }
}
