import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_button.dart';
import 'map_location_picker.dart';

class StepLocation extends StatefulWidget {
  final AppLocalizations l;
  final void Function(double lat, double lng, String name) onLocationSelected;
  final VoidCallback onNext;

  const StepLocation({
    super.key,
    required this.l,
    required this.onLocationSelected,
    required this.onNext,
  });

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  String _selected = '';
  double? _lat;
  double? _lng;
  bool _loadingGps = false;

  // ── Lấy vị trí GPS hiện tại ──────────────────────────────────────────────
  Future<void> _useCurrentLocation() async {
    if (!mounted) return;
    setState(() => _loadingGps = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage(widget.l.commonError);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage(widget.l.commonError);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      var locationName = widget.l.unknownLocation;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final parts = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
          ]
              .where((part) => part != null && part.trim().isNotEmpty)
              .cast<String>()
              .toList();
          if (parts.isNotEmpty) {
            locationName = parts.join(', ');
          }
        }
      } catch (_) {
        // Fall back to a generic label if reverse geocoding fails.
      }

      if (!mounted) return;
      _applyLocation(position.latitude, position.longitude, locationName);
    } catch (_) {
      _showMessage(widget.l.commonError);
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  // ── Mở bản đồ để chọn thủ công ───────────────────────────────────────────
  Future<void> _pickOnMap() async {
    final initial =
        (_lat != null && _lng != null) ? LatLng(_lat!, _lng!) : null;

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(initialPosition: initial),
      ),
    );

    if (result != null && mounted) {
      _applyLocation(
        result['lat'] as double,
        result['lng'] as double,
        result['name'] as String,
      );
    }
  }

  void _applyLocation(double lat, double lng, String name) {
    setState(() {
      _lat = lat;
      _lng = lng;
      _selected = name;
    });
    widget.onLocationSelected(lat, lng, name);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final hasLocation = _selected.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Nút chọn trên bản đồ ────────────────────────────────────
            GestureDetector(
              onTap: _pickOnMap,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasLocation ? AppColors.primary : AppColors.border,
                    width: hasLocation ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map_rounded,
                        size: 48,
                        color: hasLocation
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chọn trên bản đồ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: hasLocation
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nhấn để mở bản đồ và đánh dấu vị trí',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textHint,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Dòng phân cách ───────────────────────────────────────────
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'hoặc',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textHint),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 12),

            // ── Nút vị trí hiện tại ──────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _loadingGps ? null : _useCurrentLocation,
              icon: _loadingGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_loadingGps ? l.commonLoading : l.mapMyLocation),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            // ── Địa điểm đã chọn ─────────────────────────────────────────
            if (hasLocation) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.found.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.found.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.found, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vị trí đã chọn',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.found,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(_selected, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_location_alt_outlined,
                          size: 20, color: AppColors.primary),
                      onPressed: _pickOnMap,
                      tooltip: 'Đổi vị trí',
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // ── Nút tiếp theo ────────────────────────────────────────────
            AppButton(
              label: '${l.commonNext}: ${l.stepPhotos} →',
              onPressed: !hasLocation
                  ? () => _showMessage(l.errorLocationRequired)
                  : widget.onNext,
            ),
          ],
        ),
      ),
    );
  }
}
