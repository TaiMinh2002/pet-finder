import 'package:flutter/material.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language = 'vi';
  bool _notificationsEnabled = true;
  double _radius = AppConstants.defaultNotifRadius;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString(AppConstants.keyLanguage) ?? 'vi';
    });
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, lang);
    setState(() => _language = lang);
    // Live switch — no restart needed
    localeNotifier.value = Locale(lang);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(label: l.settingsLanguage),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.primary,
                label: l.settingsLanguage,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _language,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textHint, size: 20),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      items: [
                        DropdownMenuItem(value: 'en', child: Text(l.languageEn)),
                        DropdownMenuItem(value: 'vi', child: Text(l.languageVi)),
                      ],
                      onChanged: (v) => v != null ? _setLanguage(v) : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(label: l.settingsNotifications),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.notifications_rounded,
                iconColor: AppColors.cta,
                label: l.settingsNotifications,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.cta,
                  inactiveThumbColor: AppColors.textHint,
                  inactiveTrackColor: AppColors.surfaceVariant,
                ),
              ),
              const Divider(indent: 56, endIndent: 16),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingsTile(
                      icon: Icons.radar_rounded,
                      iconColor: AppColors.lost,
                      label: '${l.settingsRadius}: ${_radius.toInt()} km',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.lost,
                          inactiveTrackColor: AppColors.lostContainer,
                          thumbColor: AppColors.lost,
                          overlayColor: AppColors.lost.withValues(alpha: 0.1),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        ),
                        child: Slider(
                          value: _radius,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          onChanged: (v) => setState(() => _radius = v),
                        ),
                      ),
                    ),
                  ],
                ),
                crossFadeState: _notificationsEnabled
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(label: l.settingsAbout),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_rounded,
                iconColor: AppColors.found,
                label: l.settingsVersion,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.foundContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppConstants.appVersion,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.found,
                    ),
                  ),
                ),
              ),
              const Divider(indent: 56, endIndent: 16),
              Builder(
                builder: (context) => _SettingsTile(
                  icon: Icons.favorite_rounded,
                  iconColor: AppColors.lost,
                  label: AppLocalizations.of(context).settingsMadeWith,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textHint,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget? trailing;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          )),
      trailing: trailing,
    );
  }
}
