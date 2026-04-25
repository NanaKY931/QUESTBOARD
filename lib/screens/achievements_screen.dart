import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/achievement.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════
// ACHIEVEMENTS SCREEN
// ══════════════════════════════════════════════════

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  // Hardcoded grouping so no model changes are needed
  static const Map<String, List<String>> _sections = {
    'QUEST MILESTONES': ['first_blood', 'decathlon', 'centurion'],
    'SPECIALISTS':      ['scholar', 'iron_will', 'life_hacker'],
    'STREAKS':          ['streak_starter', 'on_fire', 'unstoppable'],
    'LEVELS':           ['level_5', 'level_10', 'level_25'],
    'LEGENDS':          ['s_class', 'hard_mode', 'perfectionist'],
  };

  @override
  Widget build(BuildContext context) {
    final achievements = context.watch<GameProvider>().achievements;
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final total = achievements.length;
    final progress = total == 0 ? 0.0 : unlockedCount / total;

    // Build an id→Achievement lookup for section rendering
    final Map<String, Achievement> byId = {
      for (final a in achievements) a.id: a,
    };

    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      appBar: AppBar(
        title: Text('ACHIEVEMENTS', style: AppText.heading(size: 17, color: AppColors.gold)),
        backgroundColor: AppColors.of(context).bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // ── Progress banner ──
          _buildProgressBanner(context, unlockedCount, total, progress),

          // ── Sectioned grids ──
          ..._sections.entries.map((entry) {
            final sectionItems = entry.value
                .map((id) => byId[id])
                .whereType<Achievement>()
                .toList();
            if (sectionItems.isEmpty) return const SizedBox.shrink();
            return _buildSection(context, entry.key, sectionItems);
          }),
        ],
      ),
    );
  }

  Widget _buildProgressBanner(BuildContext context, int unlocked, int total, double progress) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withAlpha(40)),
        boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(15), blurRadius: 28)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GLORY PROGRESS',
                style: AppText.label(size: 10, color: AppColors.of(context).textMuted, spacing: 2),
              ),
              Text('$unlocked / $total', style: AppText.stat(size: 20, color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(60), blurRadius: 8)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.gold.withAlpha(25),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progress >= 1.0
                ? '🏆  ALL ACHIEVEMENTS UNLOCKED!'
                : '${(progress * 100).round()}% COMPLETE — KEEP GOING!',
            style: AppText.label(
              size: 11,
              color: progress >= 1.0 ? AppColors.gold : AppColors.of(context).textSecondary,
              spacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Achievement> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10, left: 2),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                title,
                style: AppText.label(size: 11, color: AppColors.of(context).textSecondary, spacing: 2),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _BadgeTile(achievement: items[index]),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ══════════════════════════════════════════════════
// BADGE TILE
// ══════════════════════════════════════════════════

class _BadgeTile extends StatelessWidget {
  final Achievement achievement;
  const _BadgeTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.of(context).bgCard : AppColors.of(context).bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnlocked
                ? achievement.color.withAlpha(120)
                : AppColors.of(context).borderSubtle,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: achievement.color.withAlpha(60),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isUnlocked)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: achievement.color.withAlpha(20),
                    ),
                  ),
                Icon(
                  achievement.iconData,
                  size: 28,
                  color: isUnlocked ? achievement.color : AppColors.of(context).textMuted,
                ),
                if (!isUnlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).bgSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock, size: 11, color: AppColors.of(context).textMuted),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: AppText.label(
                  size: 10,
                  color: isUnlocked ? AppColors.of(context).textPrimary : AppColors.of(context).textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.of(context).borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Badge icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? achievement.color.withAlpha(25)
                    : AppColors.of(context).bgSurface,
                border: Border.all(
                  color: isUnlocked
                      ? achievement.color.withAlpha(100)
                      : AppColors.of(context).borderSubtle,
                  width: 2,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                            color: achievement.color.withAlpha(70),
                            blurRadius: 24),
                      ]
                    : null,
              ),
              child: Icon(
                achievement.iconData,
                size: 52,
                color: isUnlocked ? achievement.color : AppColors.of(context).textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: AppText.heading(
                size: 20,
                color: isUnlocked ? AppColors.of(context).textPrimary : AppColors.of(context).textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: AppText.body(size: 14, color: AppColors.of(context).textSecondary),
            ),
            const SizedBox(height: 16),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: achievement.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: achievement.color.withAlpha(80)),
                ),
                child: Text(
                  'Unlocked on ${achievement.unlockedAt}',
                  style: AppText.label(size: 12, color: achievement.color),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.of(context).bgSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.of(context).borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: AppColors.of(context).textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'LOCKED',
                      style: AppText.label(size: 11, color: AppColors.of(context).textMuted, spacing: 1),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
