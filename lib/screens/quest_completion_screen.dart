import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class QuestCompletionScreen extends StatefulWidget {
  final String questId;
  const QuestCompletionScreen({super.key, required this.questId});

  @override
  State<QuestCompletionScreen> createState() => _QuestCompletionScreenState();
}

class _QuestCompletionScreenState extends State<QuestCompletionScreen> {
  CameraController? _controller;
  bool _isInit = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // Cameras are now stored in GameProvider — read them without BuildContext
    // by using a post-frame callback so the widget tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cams = context.read<GameProvider>().cameras;
      if (cams.isNotEmpty) {
        _controller = CameraController(cams[0], ResolutionPreset.medium);
        _controller!.initialize().then((_) {
          if (!mounted) return;
          setState(() => _isInit = true);
        }).catchError((_) {
          // Camera unavailable on this device — fall through gracefully
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final image = await _controller!.takePicture();
      
      // Attempt to move to permanent storage
      String finalPath;
      try {
        final directory = await getApplicationDocumentsDirectory();
        finalPath = join(
            directory.path, 'proof_${DateTime.now().millisecondsSinceEpoch}.png');
        await image.saveTo(finalPath);
      } catch (saveError) {
        debugPrint('Failed to save to docs directory, using temp path: $saveError');
        finalPath = image.path; // Fallback to temp path if moving fails
      }

      if (!mounted) return;
      await context.read<GameProvider>().completeQuest(widget.questId, finalPath);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Camera capture error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture Error: ${e.toString().split('\n').first}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCameras = context.read<GameProvider>().cameras.isNotEmpty;
    if (!hasCameras) return _buildNoCameraView();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'PROOF OF COMPLETION',
          style: AppText.heading(size: 15, color: AppColors.gold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isInit
          ? Stack(
              fit: StackFit.expand,
              children: [
                // Camera feed
                CameraPreview(_controller!),

                // Vignette overlay
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.transparent, Color(0x55000000)],
                      radius: 1.0,
                    ),
                  ),
                ),

                // Instruction banner
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'CAPTURE YOUR PROOF OF COMPLETION',
                        style: AppText.label(
                            size: 10, color: AppColors.gold, spacing: 1),
                      ),
                    ),
                  ),
                ),

                // Shutter button
                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isCapturing ? null : _takePicture,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withAlpha(90),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _isCapturing
                            ? const Padding(
                                padding: EdgeInsets.all(22),
                                child: CircularProgressIndicator(
                                  color: AppColors.gold,
                                  strokeWidth: 2,
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
    );
  }

  Widget _buildNoCameraView() {
    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      appBar: AppBar(
        title: Text('COMPLETE QUEST',
            style: AppText.heading(size: 17, color: AppColors.gold)),
        backgroundColor: AppColors.of(context).bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.of(context).bgCard,
                  border: Border.all(color: AppColors.of(context).borderSubtle),
                ),
                child: Icon(
                  Icons.no_photography_outlined,
                  size: 56,
                  color: AppColors.of(context).textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Text('No Camera Detected',
                  style: AppText.heading(
                      size: 20, color: AppColors.of(context).textSecondary)),
              const SizedBox(height: 8),
              Text(
                'You can still complete this quest\nwithout a photo proof.',
                textAlign: TextAlign.center,
                style: AppText.label(
                    size: 13, color: AppColors.of(context).textMuted, spacing: 0.3),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () async {
                  await context
                      .read<GameProvider>()
                      .completeQuest(widget.questId, 'MOCK_PATH');
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                  decoration: BoxDecoration(
                    gradient: AppGradients.gold,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(90),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.black, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'MARK COMPLETE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 2,
                        ),
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
}
