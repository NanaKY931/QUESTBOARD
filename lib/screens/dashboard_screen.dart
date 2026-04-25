import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/game_provider.dart';
import '../models/achievement.dart';
import '../models/player.dart';
import '../models/quest.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'create_quest_screen.dart';
import 'trophy_room_screen.dart';
import 'quest_completion_screen.dart';
import 'achievements_screen.dart';

// ══════════════════════════════════════════════════
// DASHBOARD SCREEN
// ══════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _hasCheckedUnlocks = false;
  late TabController _tabController;
  int? _lastHp;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final player = provider.player;
    if (player == null) return const Scaffold();

    // Show achievement unlock popup once after build
    if (provider.newlyUnlocked.isNotEmpty && !_hasCheckedUnlocks) {
      _hasCheckedUnlocks = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showUnlockDialog(context, provider.newlyUnlocked);
          provider.clearNewlyUnlocked();
        }
      });
    } else if (provider.newlyUnlocked.isEmpty) {
      _hasCheckedUnlocks = false;
    }

    final colors = AppColors.of(context);

    // --- HP Damage Feedback ---
    if (_lastHp != null && player.hp < _lastHp!) {
      final damage = _lastHp! - player.hp;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'OUCH! You took $damage damage from missed deadlines!',
                      style: AppText.label(size: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.crimson,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }
    _lastHp = player.hp;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: _buildAppBar(player, context),
      body: Column(
        children: [
          _buildStatsHeader(player),
          // ── Tab bar ──
          Container(
            color: AppColors.of(context).bgCard,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_activity_outlined, size: 14),
                      const SizedBox(width: 6),
                      Text('ACTIVE (${provider.pendingQuests.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'HISTORY (${provider.completedQuests.length + provider.failedQuests.length})',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestList(provider.pendingQuests, context),
                _buildHistoryList(provider.completedQuests, provider.failedQuests),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateQuestScreen()),
          );
        },
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────
  AppBar _buildAppBar(PlayerStats player, BuildContext context) {
    final colors = AppColors.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    
    const rankColors = {
      'S-Class': Color(0xFFFFD600),
      'A-Class': Color(0xFFFF6D00),
      'B-Class': Color(0xFF00C8D4),
      'C-Class': Color(0xFF00E676),
      'D-Class': Color(0xFF9090B8),
      'E-Class': Color(0xFF555577),
    };
    final rankColor = rankColors[player.rank] ?? colors.textMuted;

    return AppBar(
      backgroundColor: colors.bgCard.withAlpha(180),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.gold.withAlpha(70), blurRadius: 10),
            ],
          ),
          child: const Icon(Icons.shield, color: AppColors.gold, size: 26),
        ),
      ),
      title: Column(
        children: [
          Text(
            player.name.toUpperCase(),
            style: AppText.heading(size: 15, color: colors.textPrimary),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: rankColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: rankColor.withAlpha(100)),
            ),
            child: Text(
              player.rank.toUpperCase(),
              style: AppText.label(size: 9, color: rankColor, spacing: 1.5),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
            color: AppColors.gold,
            size: 20,
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.crimson, size: 20),
          onPressed: () => context.read<GameProvider>().logout(),
        ),
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined, color: AppColors.gold),
          tooltip: 'Achievements',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.photo_library_outlined, color: AppColors.gold),
          tooltip: 'Trophy Room',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TrophyRoomScreen()),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Stats header ────────────────────────────────
  Widget _buildStatsHeader(PlayerStats player) {
    final expNeeded = player.level * 100;
    final expProgress = (player.currentExp / expNeeded).clamp(0.0, 1.0);
    final hpProgress = (player.hp / 100).clamp(0.0, 1.0);
    final hasStreak = player.currentStreak > 0;

    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(gradient: AppGradients.header(context)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Level orb
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.gold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(100),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${player.level}',
                      style: GoogleFonts.exo2(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'LVL',
                      style: GoogleFonts.exo2(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Stat bars
              Expanded(
                child: Column(
                  children: [
                    _buildStatBar(
                      label: '❤️  HP',
                      value: '${player.hp}/100',
                      progress: hpProgress,
                      color: AppColors.crimson,
                    ),
                    const SizedBox(height: 10),
                    _buildStatBar(
                      label: '⚡  EXP',
                      value: '${player.currentExp}/$expNeeded',
                      progress: expProgress,
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Streak row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: hasStreak ? AppColors.orange.withAlpha(18) : colors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasStreak ? AppColors.orange.withAlpha(70) : colors.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: hasStreak ? AppColors.orange : colors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${player.currentStreak} DAY${player.currentStreak == 1 ? '' : 'S'} STREAK',
                  style: AppText.label(
                    size: 12,
                    color: hasStreak ? AppColors.orange : colors.textMuted,
                    spacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withAlpha(60)),
                  ),
                  child: Text(
                    '${player.streakMultiplier}× EXP',
                    style: AppText.label(
                      size: 11,
                      color: player.streakMultiplier > 1.0
                          ? AppColors.gold
                          : colors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'BEST ${player.longestStreak}',
                  style: AppText.label(size: 10, color: colors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Rank progress row
          _buildRankProgress(player),
        ],
      ),
    );
  }

  Widget _buildStatBar({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.label(size: 11, color: AppColors.of(context).textSecondary)),
            Text(value, style: AppText.stat(size: 11, color: color)),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: color.withAlpha(50), blurRadius: 6)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  // ── Rank progress widget ────────────────────────
  //
  // Shows current class, a fill bar, and the quest count to the next class.
  // Thresholds match _calculateRank() in GameProvider:
  //   E→0 D: 100  |  D→C: 300  |  C→B: 600  |  B→A: 1000  |  A→S: 1500
  Widget _buildRankProgress(PlayerStats player) {
    final colors = AppColors.of(context);
    final int completed = player.totalCompletedQuests;

    // Determine current band and what we're progressing toward
    final bool isMaxRank = completed >= 1500;
    final int floor;
    final int ceiling;
    final String nextRank;

    if (completed >= 1500) {
      floor = 1500; ceiling = 1500; nextRank = 'S-Class';
    } else if (completed >= 1000) {
      floor = 1000; ceiling = 1500; nextRank = 'S-Class';
    } else if (completed >= 600) {
      floor = 600;  ceiling = 1000; nextRank = 'A-Class';
    } else if (completed >= 300) {
      floor = 300;  ceiling = 600;  nextRank = 'B-Class';
    } else if (completed >= 100) {
      floor = 100;  ceiling = 300;  nextRank = 'C-Class';
    } else {
      floor = 0;    ceiling = 100;  nextRank = 'D-Class';
    }

    final double progress = isMaxRank
        ? 1.0
        : ((completed - floor) / (ceiling - floor)).clamp(0.0, 1.0);

    const rankColors = <String, Color>{
      'S-Class': Color(0xFFFFD600),
      'A-Class': Color(0xFFFF6D00),
      'B-Class': Color(0xFF00C8D4),
      'C-Class': Color(0xFF00E676),
      'D-Class': Color(0xFF9090B8),
      'E-Class': Color(0xFF555577),
    };
    final Color barColor = isMaxRank
        ? AppColors.gold
        : (rankColors[nextRank] ?? colors.textMuted);

    final String progressLabel = isMaxRank
        ? '🏆 MAX RANK ACHIEVED'
        : '${completed - floor} / ${ceiling - floor} QUESTS → $nextRank';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.military_tech, size: 14, color: barColor),
                  const SizedBox(width: 5),
                  Text(
                    'RANK PROGRESS',
                    style: AppText.label(size: 10, color: colors.textMuted, spacing: 1.5),
                  ),
                ],
              ),
              Text(
                progressLabel,
                style: AppText.label(
                  size: 10,
                  color: isMaxRank ? AppColors.gold : barColor,
                  spacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: barColor.withAlpha(25),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quest lists ─────────────────────────────────
  Widget _buildQuestList(List<Quest> quests, BuildContext context) {
    if (quests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.add_task,
        title: 'No Active Quests',
        subtitle: 'Tap + to forge a new quest\nand begin your adventure!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        return Dismissible(
          key: Key(quest.id),
          direction: DismissDirection.startToEnd,
          // Require confirmation before committing the dismiss
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.of(context).bgCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  'Abandon Quest?',
                  style: AppText.heading(size: 17, color: AppColors.of(context).textPrimary),
                ),
                content: Text(
                  'This quest will be permanently removed.\nThis action cannot be undone.',
                  style: AppText.body(size: 14, color: AppColors.of(context).textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'KEEP IT',
                      style: AppText.label(size: 13, color: AppColors.of(context).textMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      'ABANDON',
                      style: AppText.label(size: 13, color: AppColors.crimson),
                    ),
                  ),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (_) {
            context.read<GameProvider>().deleteQuest(quest.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '"${quest.title}" abandoned.',
                  style: AppText.label(size: 13, color: Colors.white),
                ),
                backgroundColor: AppColors.crimson,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            );
          },
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.crimson,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 22),
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white, size: 26),
                const SizedBox(width: 8),
                Text(
                  'ABANDON',
                  style: AppText.label(size: 12, color: Colors.white, spacing: 1.5),
                ),
              ],
            ),
          ),
          child: _QuestCard(quest: quest),
        );
      },
    );
  }

  Widget _buildHistoryList(List<Quest> completed, List<Quest> failed) {
    final all = [...completed, ...failed]
      ..sort((a, b) => b.deadline.compareTo(a.deadline));

    if (all.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No History Yet',
        subtitle: 'Complete or fail quests\nto see them here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: all.length,
      itemBuilder: (context, index) => _QuestCard(quest: all[index]),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: AppColors.of(context).textMuted),
          const SizedBox(height: 16),
          Text(title, style: AppText.heading(size: 17, color: AppColors.of(context).textSecondary)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppText.label(size: 13, color: AppColors.of(context).textMuted, spacing: 0.3),
          ),
        ],
      ),
    );
  }

  // ── Achievement popup ───────────────────────────
  void _showUnlockDialog(BuildContext context, List<Achievement> unlocked) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.of(context).bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withAlpha(20),
                  border: Border.all(color: AppColors.gold.withAlpha(80), width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.gold.withAlpha(70), blurRadius: 20),
                  ],
                ),
                child: const Icon(Icons.emoji_events, color: AppColors.gold, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'ACHIEVEMENT UNLOCKED',
                textAlign: TextAlign.center,
                style: AppText.heading(size: 14, color: AppColors.gold),
              ),
              const SizedBox(height: 20),
              ...unlocked.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: a.color.withAlpha(25),
                          border: Border.all(color: a.color.withAlpha(100), width: 2),
                          boxShadow: [
                            BoxShadow(color: a.color.withAlpha(60), blurRadius: 12),
                          ],
                        ),
                        child: Icon(a.iconData, color: a.color, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title,
                                style: AppText.heading(
                                    size: 14, color: AppColors.of(context).textPrimary)),
                            const SizedBox(height: 2),
                            Text(a.description,
                                style: AppText.body(
                                    size: 12, color: AppColors.of(context).textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CLAIM GLORY!',
                      textAlign: TextAlign.center,
                      style: AppText.label(size: 16, color: Colors.black, spacing: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// QUEST CARD
// ══════════════════════════════════════════════════

class _QuestCard extends StatelessWidget {
  final Quest quest;
  const _QuestCard({required this.quest});

  Color get _difficultyColor {
    switch (quest.difficulty) {
      case 'Easy':
        return AppColors.easy;
      case 'Hard':
        return AppColors.hard;
      default:
        return AppColors.medium;
    }
  }

  Color get _categoryColor {
    switch (quest.category) {
      case 'Academic':
        return AppColors.academic;
      case 'Fitness':
        return AppColors.fitness;
      default:
        return AppColors.life;
    }
  }

  IconData get _categoryIcon {
    switch (quest.category) {
      case 'Academic':
        return Icons.menu_book;
      case 'Fitness':
        return Icons.fitness_center;
      default:
        return Icons.home_filled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(quest.deadline) ?? DateTime.now();
    final deadlineStr = DateFormat('MMM dd, hh:mm a').format(dt);
    final isPast = dt.isBefore(DateTime.now());
    final isCompleted = quest.status == 'Completed';
    final isFailed = quest.status == 'Failed';
    final isPending = quest.status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.of(context).bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).borderSubtle),
        boxShadow: isCompleted
            ? [BoxShadow(color: AppColors.emerald.withAlpha(20), blurRadius: 8)]
            : isFailed
                ? [BoxShadow(color: AppColors.crimson.withAlpha(20), blurRadius: 8)]
                : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: _difficultyColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category icon bubble
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _categoryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _categoryColor.withAlpha(60)),
                            ),
                            child: Icon(_categoryIcon, color: _categoryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          // Title + tags
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quest.title,
                                  style: AppText.body(
                                    size: 15,
                                    color: isCompleted
                                        ? AppColors.of(context).textMuted
                                        : AppColors.of(context).textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _difficultyColor.withAlpha(25),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: _difficultyColor.withAlpha(80)),
                                      ),
                                      child: Text(
                                        quest.difficulty.toUpperCase(),
                                        style: AppText.label(
                                            size: 9, color: _difficultyColor),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      quest.category.toUpperCase(),
                                      style: AppText.label(
                                        size: 9,
                                        color: AppColors.of(context).textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status / Action
                          if (isPending)
                            _buildCompleteButton(context)
                          else
                            _buildStatusChip(isCompleted),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (quest.description.isNotEmpty) ...[
                        Text(
                          quest.description,
                          style: AppText.body(
                            size: 13,
                            color: AppColors.of(context).textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Bottom row: Deadline + EXP
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: isPast && isPending
                                ? AppColors.crimson
                                : AppColors.of(context).textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deadlineStr,
                            style: AppText.label(
                              size: 11,
                              color: isPast && isPending
                                  ? AppColors.crimson
                                  : AppColors.of(context).textMuted,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.bolt, size: 13, color: AppColors.gold),
                          const SizedBox(width: 2),
                          Text(
                            '${quest.expReward} EXP',
                            style: AppText.label(size: 12, color: AppColors.gold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuestCompletionScreen(questId: quest.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppGradients.gold,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: AppColors.gold.withAlpha(70), blurRadius: 10),
          ],
        ),
        child: Text(
          'DONE',
          style: AppText.label(size: 12, color: Colors.black, spacing: 1),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isCompleted) {
    final color = isCompleted ? AppColors.emerald : AppColors.crimson;
    final label = isCompleted ? '✓ DONE' : '✗ FAILED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label, style: AppText.label(size: 11, color: color)),
    );
  }
}
