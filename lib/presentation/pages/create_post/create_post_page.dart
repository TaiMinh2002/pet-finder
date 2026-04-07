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
import 'step_pet_info.dart';
import 'step_location.dart';
import 'step_photos.dart';
import 'step_contact.dart';

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
    final l = AppLocalizations.of(context);
    if (_lat == null || _lng == null || _locationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorLocationRequired)),
      );
      _goStep(1);
      return;
    }

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
      latitude: _lat!,
      longitude: _lng!,
      locationName: _locationName,
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
                    l.createPostStep(_step + 1, _totalSteps),
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
        return StepPetInfo(
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
        return StepLocation(
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
        return StepPhotos(
          key: const ValueKey(2),
          l: l,
          imagePaths: _imagePaths,
          imageUrls: _imageUrls,
          onPickImages: _pickImages,
          onNext: () => _goStep(3),
        );
      case 3:
        return StepContact(
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
