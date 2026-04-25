import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<GameProvider>();
      if (_isLogin) {
        await provider.login(_emailController.text.trim(), _passController.text.trim());
      } else {
        await provider.signUp(_emailController.text.trim(), _passController.text.trim());
      }
      // main.dart Bootloader will handle navigation
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.bg(context)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Shield
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(50),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shield, size: 70, color: AppColors.gold),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    _isLogin ? 'WELCOME BACK' : 'CREATE ACCOUNT',
                    style: AppText.display(size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'THE BOARD AWAITS YOUR RETURN' : 'JOIN THE RANKS OF LEGENDS',
                    style: AppText.label(size: 11, color: colors.textMuted, spacing: 3),
                  ),
                  const SizedBox(height: 48),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.crimson.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.crimson.withAlpha(50)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.crimson, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: AppText.label(size: 11, color: AppColors.crimson),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        _buildLabel('EMAIL ADDRESS'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppText.body(size: 16),
                          decoration: const InputDecoration(
                            hintText: 'adventurer@realm.com',
                            prefixIcon: Icon(Icons.alternate_email, color: AppColors.gold, size: 20),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildLabel('PASSWORD'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passController,
                          obscureText: true,
                          style: AppText.body(size: 16),
                          decoration: const InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(Icons.lock_outline, color: AppColors.gold, size: 20),
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _isLoading ? null : _submit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: AppGradients.gold,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withAlpha(60),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _isLogin ? 'ENTER REALM' : 'FORGE ACCOUNT',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        letterSpacing: 2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Toggle
                  GestureDetector(
                    onTap: () => setState(() {
                      _isLogin = !_isLogin;
                      _error = null;
                    }),
                    child: RichText(
                      text: TextSpan(
                        style: AppText.label(size: 13, color: colors.textSecondary),
                        children: [
                          TextSpan(text: _isLogin ? "NEW ADVENTURER? " : "ALREADY A MEMBER? "),
                          TextSpan(
                            text: _isLogin ? "JOIN NOW" : "LOGIN HERE",
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppText.label(size: 10, color: AppColors.of(context).textMuted, spacing: 2),
    );
  }
}
