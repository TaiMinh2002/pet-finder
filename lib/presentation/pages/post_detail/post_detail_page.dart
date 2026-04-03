import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/datasources/remote/post_remote_datasource.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../injection_container.dart';
import '../../widgets/common/post_type_badge.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  const PostDetailPage({super.key, required this.postId});
  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  PostEntity? _post;
  bool _loading = true;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      final ds = sl<PostRemoteDataSource>();
      final model = await ds.getPostById(widget.postId);
      if (mounted) {
        setState(() {
          _post = model.toEntity();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? Center(child: Text(l.commonError))
              : _buildContent(context, _post!, l),
    );
  }

  Widget _buildContent(
      BuildContext context, PostEntity post, AppLocalizations l) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: post.hasImages
                ? Stack(
                    children: [
                      PageView.builder(
                        itemCount: post.images.length,
                        onPageChanged: (i) => setState(() => _currentImage = i),
                        itemBuilder: (_, i) => CachedNetworkImage(
                          imageUrl: post.images[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (post.images.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              post.images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentImage == i ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentImage == i
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Container(
                    color: post.isLost
                        ? AppColors.lostContainer
                        : AppColors.foundContainer,
                    child: Icon(
                      Icons.pets,
                      size: 80,
                      color: post.isLost ? AppColors.lost : AppColors.found,
                    ),
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PostTypeBadge(type: post.type),
                    const Spacer(),
                    Text(
                      DateFormatter.timeAgo(post.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.petName ?? l.petTypeDog,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                if (post.breed != null) ...[
                  const SizedBox(height: 4),
                  Text(post.breed!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          )),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: l.lostDate,
                  value: DateFormatter.shortDate(post.lostDate),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: l.locationLabel,
                  value: post.locationName,
                ),
                if (post.color != null) ...[
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.palette_outlined,
                    label: l.colorFeatures,
                    value: post.color!,
                  ),
                ],
                const SizedBox(height: 20),
                Text(l.description,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(post.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        )),
                const SizedBox(height: 32),
                if (post.phoneNumber != null && !post.isAnonymous)
                  ElevatedButton.icon(
                    onPressed: () => _callPhone(post.phoneNumber!),
                    icon: const Icon(Icons.phone, size: 20),
                    label: Text(l.contactOwner),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ],
    );
  }
}
