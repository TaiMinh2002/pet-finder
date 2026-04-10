import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/post_entity.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class StepContact extends StatelessWidget {
  final AppLocalizations l;
  final ContactMethod contactMethod;
  final TextEditingController phoneCtrl;
  final bool anonymous;
  final ValueChanged<ContactMethod> onContactMethodChanged;
  final ValueChanged<bool> onAnonymousChanged;
  final VoidCallback onSubmit;

  const StepContact({
    super.key,
    required this.l,
    required this.contactMethod,
    required this.phoneCtrl,
    required this.anonymous,
    required this.onContactMethodChanged,
    required this.onAnonymousChanged,
    required this.onSubmit,
  });

  String _contactLabel(ContactMethod m) {
    switch (m) {
      case ContactMethod.phone:
        return l.contactPhone;
      case ContactMethod.zalo:
        return l.contactZalo;
      case ContactMethod.both:
        return l.contactBoth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.contactMethod,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: ContactMethod.values.map((m) {
                final selected = contactMethod == m;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Semantics(
                      label: _contactLabel(m),
                      button: true,
                      selected: selected,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onContactMethodChanged(m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryContainer
                                : AppColors.surfaceVariant,
                            border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: selected ? 2 : 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                m == ContactMethod.phone
                                    ? Icons.phone_outlined
                                    : m == ContactMethod.zalo
                                        ? Icons.chat_outlined
                                        : Icons.contact_phone_outlined,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textHint,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _contactLabel(m),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: l.phoneNumber,
              hint: l.phoneNumberHint,
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: anonymous,
                  onChanged: onAnonymousChanged,
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.postAnonymously,
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(l.loginSubtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            BlocBuilder<PostBloc, PostState>(
              builder: (context, state) => AppButton(
                label: l.publishPost,
                loading: state is PostCreating,
                onPressed: onSubmit,
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
