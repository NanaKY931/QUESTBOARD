import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData iconData;
  final Color color;
  final bool isUnlocked;
  final String unlockedAt; // ISO 8601 date string, empty if locked

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt = '',
  });

  Achievement copyWith({
    bool? isUnlocked,
    String? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconData: iconData,
      color: color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// All achievement definitions
  static List<Achievement> get definitions => [
    // Quest completion milestones
    const Achievement(
      id: 'first_blood',
      title: 'First Blood',
      description: 'Complete your first quest',
      iconData: Icons.flash_on,
      color: Color(0xFFE53935),
    ),
    const Achievement(
      id: 'decathlon',
      title: 'Decathlon',
      description: 'Complete 10 quests',
      iconData: Icons.military_tech,
      color: Color(0xFFFF8F00),
    ),
    const Achievement(
      id: 'centurion',
      title: 'Centurion',
      description: 'Complete 50 quests',
      iconData: Icons.account_balance,
      color: Color(0xFF6D4C41),
    ),

    // Category specialists
    const Achievement(
      id: 'scholar',
      title: 'Scholar',
      description: 'Complete 5 Academic quests',
      iconData: Icons.menu_book,
      color: Color(0xFF1E88E5),
    ),
    const Achievement(
      id: 'iron_will',
      title: 'Iron Will',
      description: 'Complete 5 Fitness quests',
      iconData: Icons.fitness_center,
      color: Color(0xFF43A047),
    ),
    const Achievement(
      id: 'life_hacker',
      title: 'Life Hacker',
      description: 'Complete 5 Life quests',
      iconData: Icons.home_filled,
      color: Color(0xFF8E24AA),
    ),

    // Streak milestones
    const Achievement(
      id: 'streak_starter',
      title: 'Streak Starter',
      description: 'Reach a 3-day streak',
      iconData: Icons.local_fire_department,
      color: Color(0xFFFF6D00),
    ),
    const Achievement(
      id: 'on_fire',
      title: 'On Fire',
      description: 'Reach a 7-day streak',
      iconData: Icons.whatshot,
      color: Color(0xFFFF3D00),
    ),
    const Achievement(
      id: 'unstoppable',
      title: 'Unstoppable',
      description: 'Reach a 30-day streak',
      iconData: Icons.rocket_launch,
      color: Color(0xFFD50000),
    ),

    // Level milestones
    const Achievement(
      id: 'level_5',
      title: 'Rising Star',
      description: 'Reach Level 5',
      iconData: Icons.star,
      color: Color(0xFFFDD835),
    ),
    const Achievement(
      id: 'level_10',
      title: 'Veteran',
      description: 'Reach Level 10',
      iconData: Icons.star_half,
      color: Color(0xFFFFB300),
    ),
    const Achievement(
      id: 'level_25',
      title: 'Legend',
      description: 'Reach Level 25',
      iconData: Icons.auto_awesome,
      color: Color(0xFFFF6F00),
    ),

    // Rank
    const Achievement(
      id: 's_class',
      title: 'S-Class Hunter',
      description: 'Reach S-Class rank',
      iconData: Icons.emoji_events,
      color: Color(0xFFFFD600),
    ),

    // Difficulty
    const Achievement(
      id: 'hard_mode',
      title: 'Hard Mode',
      description: 'Complete 5 Hard quests',
      iconData: Icons.dangerous,
      color: Color(0xFFB71C1C),
    ),

    // Perfection
    const Achievement(
      id: 'perfectionist',
      title: 'Perfectionist',
      description: 'Complete 10 quests with zero failed quests on record',
      iconData: Icons.diamond,
      color: Color(0xFF00E5FF),
    ),
  ];
}
