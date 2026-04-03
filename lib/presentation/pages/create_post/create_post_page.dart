import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/remote/auth_remote_datasource.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../injection_container.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});
  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>
    with TickerProviderStateMixin {
  int _step = 0;
  final _totalSteps = 4;

  PostType _postType = PostType.lost;
  PetType _petType = PetType.dog;
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _lostDate = DateTime.now();
  double? _lat;
  double? _lng;
  String _locationName = '';
  List<String> _imagePaths = [];
  List<String> _imageUrls = [];
  ContactMethod _contactMethod = ContactMethod.phone;
  final _phoneCtrl = TextEditingController();
  bool _anonymous = false;

  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 1 / _totalSteps)
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _colorCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _goStep(int step) {
    setState(() => _step = step);
    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: (step + 1) / _totalSteps,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward(from: 0);
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;
    final paths =
        files.map((f) => f.path).take(AppConstants.maxImages).toList();
    setState(() => _imagePaths = paths);
    if (mounted) {
      context.read<PostBloc>().add(PostImagesUploadRequested(paths));
    }
  }

  Future<void> _submit() async {
    final auth = sl<AuthRemoteDataSource>();
    final uid = auth.currentUser?.uid ?? '';
    final post = PostEntity(
      id: const Uuid().v4(),
      userId: uid,
      type: _postType,
      petType: _petType,
      petName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
      color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      lostDate: _lostDate,
      latitude: _lat ?? AppConstants.defaultLat,
      longitude: _lng ?? AppConstants.defaultLng,
      locationName: _locationName.isEmpty ? 'Unknown location' : _locationName,
      images: _imageUrls,
      contactMethod: _contactMethod,
      phoneNumber:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      isAnonymous: _anonymous,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    if (mounted) context.read<PostBloc>().add(PostCreateRequested(post));
  }

  String _stepLabel(AppLocalizations l) {
    switch (_step) {
      case 0:
        return l.stepPetInfo;
      case 1:
        return l.stepLocation;
      case 2:
        return l.stepPhotos;
      case 3:
        return l.stepContact;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostImagesUploaded) {
          setState(() => _imageUrls = state.urls);
        }
        if (state is PostCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.successPostCreated)),
          );
          context.go('/posts');
        }
        if (state is PostError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l.createPostTitle),
          leading: _step > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => _goStep(_step - 1),
                )
              : null,
        ),
        body: Column(
          children: [
            AnimatedBuilder(
              animation: _progressAnim,
              builder: (_, __) => LinearProgressIndicator(
                value: _progressAnim.value,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Step ${_step + 1} of $_totalSteps',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _stepLabel(l),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStep(l),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(AppLocalizations l) {
    switch (_step) {
      case 0:
        return _StepPetInfo(
          key: const ValueKey(0),
          l: l,
          postType: _postType,
          petType: _petType,
          nameCtrl: _nameCtrl,
          breedCtrl: _breedCtrl,
          colorCtrl: _colorCtrl,
          descCtrl: _descCtrl,
          lostDate: _lostDate,
          onPostTypeChanged: (t) => setState(() => _postType = t),
          onPetTypeChanged: (t) => setState(() => _petType = t),
          onDateChanged: (d) => setState(() => _lostDate = d),
          onNext: () => _goStep(1),
        );
      case 1:
        return _StepLocation(
          key: const ValueKey(1),
          l: l,
          onLocationSelected: (lat, lng, name) {
            setState(() {
              _lat = lat;
              _lng = lng;
              _locationName = name;
            });
          },
          onNext: () => _goStep(2),
        );
      case 2:
        return _StepPhotos(
          key: const ValueKey(2),
          l: l,
          imagePaths: _imagePaths,
          imageUrls: _imageUrls,
          onPickImages: _pickImages,
          onNext: () => _goStep(3),
        );
      case 3:
        return _StepContact(
          key: const ValueKey(3),
          l: l,
          contactMethod: _contactMethod,
          phoneCtrl: _phoneCtrl,
          anonymous: _anonymous,
          onContactMethodChanged: (m) => setState(() => _contactMethod = m),
          onAnonymousChanged: (v) => setState(() => _anonymous = v),
          onSubmit: _submit,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Step 0: Pet Info ─────────────────────────────────────────────────────────
class _StepPetInfo extends StatelessWidget {
  final AppLocalizations l;
  final PostType postType;
  final PetType petType;
  final TextEditingController nameCtrl, breedCtrl, colorCtrl, descCtrl;
  final DateTime lostDate;
  final ValueChanged<PostType> onPostTypeChanged;
  final ValueChanged<PetType> onPetTypeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onNext;

  const _StepPetInfo({
    super.key,
    required this.l,
    required this.postType,
    required this.petType,
    required this.nameCtrl,
    required this.breedCtrl,
    required this.colorCtrl,
    required this.descCtrl,
    required this.lostDate,
    required this.onPostTypeChanged,
    required this.onPetTypeChanged,
    required this.onDateChanged,
    required this.onNext,
  });

  String _postTypeLabel(PostType t) {
    switch (t) {
      case PostType.lost:
        return l.postTypeLost;
      case PostType.found:
        return l.postTypeFound;
      case PostType.resolved:
        return l.postTypeResolved;
    }
  }

  String _petTypeLabel(PetType t) {
    switch (t) {
      case PetType.dog:
        return l.petTypeDog;
      case PetType.cat:
        return l.petTypeCat;
      case PetType.other:
        return l.petTypeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.selectPostType, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: PostType.values.map((t) {
              final selected = postType == t;
              final color = t == PostType.lost
                  ? AppColors.lost
                  : t == PostType.found
                      ? AppColors.found
                      : AppColors.resolved;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPostTypeChanged(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.15)
                          : AppColors.surfaceVariant,
                      border: Border.all(
                          color: selected ? color : AppColors.border,
                          width: selected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          t == PostType.lost
                              ? Icons.search
                              : t == PostType.found
                                  ? Icons.check_circle_outline
                                  : Icons.favorite_outline,
                          color: selected ? color : AppColors.textHint,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _postTypeLabel(t),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? color : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(l.selectPetType, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: PetType.values.map((t) {
              final selected = petType == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPetTypeChanged(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryContainer
                          : AppColors.surfaceVariant,
                      border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.border,
                          width: selected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                            t == PetType.dog
                                ? '🐕'
                                : t == PetType.cat
                                    ? '🐈'
                                    : '🐾',
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          _petTypeLabel(t),
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
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          AppTextField(
              label: l.petName, hint: l.petNameHint, controller: nameCtrl),
          const SizedBox(height: 16),
          AppTextField(
              label: l.breed, hint: l.breedHint, controller: breedCtrl),
          const SizedBox(height: 16),
          AppTextField(
              label: l.colorFeatures,
              hint: l.colorFeaturesHint,
              controller: colorCtrl),
          const SizedBox(height: 16),
          AppTextField(
            label: l.description,
            hint: l.descriptionHint,
            controller: descCtrl,
            maxLines: 4,
          ),
          const SizedBox(height: 28),
          AppButton(
              label: '${l.commonNext}: ${l.stepLocation} →', onPressed: onNext),
        ],
      ),
    );
  }
}

// ── Step 1: Location ─────────────────────────────────────────────────────────
class _StepLocation extends StatefulWidget {
  final AppLocalizations l;
  final void Function(double lat, double lng, String name) onLocationSelected;
  final VoidCallback onNext;
  const _StepLocation(
      {super.key,
      required this.l,
      required this.onLocationSelected,
      required this.onNext});
  @override
  State<_StepLocation> createState() => __StepLocationState();
}

class __StepLocationState extends State<_StepLocation> {
  String _selected = '';

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_rounded,
                      size: 64,
                      color: AppColors.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(l.tapToSelectLocation,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _selected = 'Ho Chi Minh City, Vietnam');
                      widget.onLocationSelected(10.8231, 106.6297, _selected);
                    },
                    icon: const Icon(Icons.my_location, size: 18),
                    label: Text(l.mapMyLocation),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 44)),
                  ),
                ],
              ),
            ),
          ),
          if (_selected.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.found, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_selected)),
              ],
            ),
          ],
          const Spacer(),
          AppButton(
            label: '${l.commonNext}: ${l.stepPhotos} →',
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Photos ────────────────────────────────────────────────────────────
class _StepPhotos extends StatelessWidget {
  final AppLocalizations l;
  final List<String> imagePaths;
  final List<String> imageUrls;
  final VoidCallback onPickImages;
  final VoidCallback onNext;

  const _StepPhotos({
    super.key,
    required this.l,
    required this.imagePaths,
    required this.imageUrls,
    required this.onPickImages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.addPhotos, style: Theme.of(context).textTheme.titleLarge),
          Text(l.addPhotosHint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          if (imagePaths.isEmpty)
            GestureDetector(
              onTap: onPickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary,
                      style: BorderStyle.solid,
                      width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(l.addPhotos,
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: imagePaths
                  .map((path) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(path,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(Icons.image,
                                      color: AppColors.textHint),
                                )),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 16),
          if (imagePaths.isNotEmpty)
            OutlinedButton.icon(
              onPressed: onPickImages,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.addPhotos),
            ),
          if (imageUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.cloud_done, color: AppColors.found, size: 16),
                const SizedBox(width: 6),
                Text('${imageUrls.length} photo(s) uploaded',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.found)),
              ],
            ),
          ],
          const Spacer(),
          AppButton(
              label: '${l.commonNext}: ${l.stepContact} →', onPressed: onNext),
        ],
      ),
    );
  }
}

// ── Step 3: Contact ───────────────────────────────────────────────────────────
class _StepContact extends StatelessWidget {
  final AppLocalizations l;
  final ContactMethod contactMethod;
  final TextEditingController phoneCtrl;
  final bool anonymous;
  final ValueChanged<ContactMethod> onContactMethodChanged;
  final ValueChanged<bool> onAnonymousChanged;
  final VoidCallback onSubmit;

  const _StepContact({
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.contactMethod, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: ContactMethod.values.map((m) {
              final selected = contactMethod == m;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onContactMethodChanged(m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryContainer
                          : AppColors.surfaceVariant,
                      border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.border,
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
                          color:
                              selected ? AppColors.primary : AppColors.textHint,
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
    );
  }
}
