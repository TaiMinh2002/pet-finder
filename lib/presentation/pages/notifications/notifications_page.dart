import 'package:flutter/material.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import '../../widgets/common/empty_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.notificationsTitle)),
      body: EmptyState(
        title: l.notificationsEmpty,
        subtitle: l.notificationsEmptyHint,
        icon: Icons.notifications_none_rounded,
      ),
    );
  }
}
