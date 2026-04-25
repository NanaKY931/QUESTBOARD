import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/quest.dart';
import '../theme/app_theme.dart';

class TrophyRoomScreen extends StatelessWidget {
  const TrophyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completedQuests = context.watch<GameProvider>().completedQuests;
    // Show only quests that have real photo proof
    final photos = completedQuests
        .where((q) => q.mediaProofPath.isNotEmpty && q.mediaProofPath != 'MOCK_PATH')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      appBar: AppBar(
        title: Text('TROPHY ROOM', style: AppText.heading(size: 17, color: AppColors.gold)),
        backgroundColor: AppColors.of(context).bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (photos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${photos.length} PHOTOS',
                  style: AppText.label(size: 11, color: AppColors.gold, spacing: 1),
                ),
              ),
            ),
        ],
      ),
      body: completedQuests.isEmpty
          ? _buildEmptyState(
              context: context,
              icon: Icons.emoji_events_outlined,
              title: 'No Trophies Yet',
              subtitle: 'Complete quests to earn your first trophy!',
            )
          : photos.isEmpty
              ? _buildEmptyState(
                  context: context,
                  icon: Icons.photo_camera_outlined,
                  title: 'No Photos Yet',
                  subtitle:
                      'Take proof photos when completing quests\nto fill your trophy room!',
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) =>
                      _TrophyTile(quest: photos[index]),
                ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.of(context).textMuted),
          const SizedBox(height: 16),
          Text(title,
              style: AppText.heading(size: 18, color: AppColors.of(context).textSecondary)),
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
}

// ── Trophy tile ──────────────────────────────────

class _TrophyTile extends StatelessWidget {
  final Quest quest;
  const _TrophyTile({required this.quest});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(quest.mediaProofPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.of(context).bgSurface,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.of(context).textMuted,
                    size: 28,
                  ),
                ),
              ),
            ),
            // Title gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xCC000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  quest.title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.file(
                  File(quest.mediaProofPath),
                  fit: BoxFit.contain,
                ),
              ),
              // Close button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
              // Quest name banner
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: Text(
                    quest.title,
                    style: AppText.body(size: 15, color: AppColors.of(context).textPrimary),
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
