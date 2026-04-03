import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/post_entity.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapCtrl = MapController();
  LatLng _center =
      const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(const PostsLoadRequested());
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _center = LatLng(pos.latitude, pos.longitude));
      _mapCtrl.move(_center, 14);
    } catch (_) {}
    setState(() => _locating = false);
  }

  Color _markerColor(PostType type) {
    switch (type) {
      case PostType.lost:
        return AppColors.lost;
      case PostType.found:
        return AppColors.found;
      case PostType.resolved:
        return AppColors.resolved;
    }
  }

  IconData _markerIcon(PetType petType) {
    switch (petType) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.catching_pokemon;
      case PetType.other:
        return Icons.cruelty_free;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              final posts = state is PostsLoaded ? state.posts : <PostEntity>[];
              return FlutterMap(
                mapController: _mapCtrl,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: AppConstants.defaultZoom,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(20.56, 105.28), // Southwest
                      const LatLng(21.39, 106.02), // Northeast
                    ),
                  ),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom |
                        InteractiveFlag.scrollWheelZoom,
                  ),
                  onTap: (_, __) {},
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.petfinder.app',
                  ),
                  MarkerLayer(
                    markers: posts.map((post) {
                      return Marker(
                        point: LatLng(post.latitude, post.longitude),
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => context.push('/posts/${post.id}'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _markerColor(post.type),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: _markerColor(post.type)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              _markerIcon(post.petType),
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pets,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LegendDot(
                              color: AppColors.lost, label: l.filterLost),
                          const SizedBox(width: 8),
                          _LegendDot(
                              color: AppColors.found, label: l.filterFound),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 16,
            child: GestureDetector(
              onTap: _goToMyLocation,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _locating
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
