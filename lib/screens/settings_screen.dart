import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_theme.dart';
import '../providers/theme_provider.dart';
import '../services/haptics.dart';
import '../services/storage_service.dart';
import '../widgets/floating_particles.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _hapticEnabled;
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = StorageService.getHapticEnabled();
    _soundEnabled = StorageService.getSoundEnabled();
  }

  Future<void> _openUrl(String urlString) async {
    Haptics.select();
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $urlString'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: currentTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: FloatingParticles(
              particleColor: currentTheme.textPrimary.withValues(alpha: 0.08),
              count: 16,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: currentTheme.appBarFg,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 1.5,
                          color: currentTheme.appBarFg,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    children: [
                      // Official Website / Support Card
                      GestureDetector(
                        onTap: () => _openUrl('https://wordsearch.appstick.com.bd/'),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00B894),
                                Color(0xFF009688),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF55EFC4),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF009688).withValues(alpha: 0.35),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.public_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Official Website',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          'GENERAL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: currentTheme.textMuted,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: currentTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: currentTheme.border.withValues(alpha: 0.4),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              title: Text(
                                'Sound Effects',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: currentTheme.textPrimary,
                                ),
                              ),
                              value: _soundEnabled,
                              activeThumbColor: currentTheme.switchActiveColor,
                              onChanged: (value) {
                                setState(() => _soundEnabled = value);
                                StorageService.setSoundEnabled(value);
                              },
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                              color: currentTheme.border.withValues(alpha: 0.2),
                            ),
                            SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              title: Text(
                                'Haptic Feedback',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: currentTheme.textPrimary,
                                ),
                              ),
                              value: _hapticEnabled,
                              activeThumbColor: currentTheme.switchActiveColor,
                              onChanged: (value) {
                                setState(() => _hapticEnabled = value);
                                StorageService.setHapticEnabled(value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          'THEME',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: currentTheme.textMuted,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: currentTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: currentTheme.border.withValues(alpha: 0.4),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: AppThemes.all.map((theme) {
                            final isSelected = theme.id == currentTheme.id;
                            final isLast = theme.id == AppThemes.all.last.id;
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: theme.playBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.playBg.withValues(alpha: 0.4),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    theme.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: currentTheme.textPrimary,
                                    ),
                                  ),
                                  trailing: isSelected
                                    ? Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: currentTheme.playBg,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      )
                                    : null,
                                  onTap: () {
                                    Haptics.select();
                                    ref.read(themeProvider.notifier).setTheme(theme.id);
                                  },
                                ),
                                if (!isLast)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 20,
                                    endIndent: 20,
                                    color: currentTheme.border.withValues(alpha: 0.2),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          'LEGAL & ABOUT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: currentTheme.textMuted,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: currentTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: currentTheme.border.withValues(alpha: 0.4),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0984E3).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.privacy_tip_rounded,
                                  color: Color(0xFF0984E3),
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: currentTheme.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'How we respect and protect your data',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: currentTheme.textMuted,
                                ),
                              ),
                              trailing: Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                                color: currentTheme.textMuted,
                              ),
                              onTap: () => _openUrl('https://wordsearch.appstick.com.bd/privacy-policy.html'),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                              color: currentTheme.border.withValues(alpha: 0.2),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.description_rounded,
                                  color: Color(0xFF6C5CE7),
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                'Terms & Conditions',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: currentTheme.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Usage terms and license details',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: currentTheme.textMuted,
                                ),
                              ),
                              trailing: Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                                color: currentTheme.textMuted,
                              ),
                              onTap: () => _openUrl('https://wordsearch.appstick.com.bd/terms.html'),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                              color: currentTheme.border.withValues(alpha: 0.2),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00B894).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.business_rounded,
                                  color: Color(0xFF00B894),
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                'Developer',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: currentTheme.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Appstick Ltd (appstick.com.bd)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: currentTheme.textMuted,
                                ),
                              ),
                              trailing: Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                                color: currentTheme.textMuted,
                              ),
                              onTap: () => _openUrl('https://appstick.com.bd/'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Word Search - Classic Puzzle',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: currentTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Version 1.0.0 (Build 1)',
                              style: TextStyle(
                                fontSize: 12,
                                color: currentTheme.textMuted.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
