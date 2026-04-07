import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';

class MapLocationPicker extends StatefulWidget {
  /// Nếu null → tự động lấy GPS hiện tại khi mở
  final LatLng? initialPosition;

  const MapLocationPicker({super.key, this.initialPosition});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  // Fallback cuối cùng nếu GPS cũng thất bại: Hà Nội
  static const _fallback = LatLng(21.0285, 105.8542);

  LatLng? _picked;
  String _locationName = '';
  bool _geocoding = false;
  bool _loadingGps = false;

  // Search
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  List<Location> _searchResults = [];
  final _searchFocus = FocusNode();

  final _mapController = MapController();

  // ── Khởi tạo ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _picked = widget.initialPosition;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.initialPosition!, 15);
        _reverseGeocode(widget.initialPosition!);
      });
    } else {
      // Không có vị trí truyền vào → lấy GPS hiện tại
      WidgetsBinding.instance.addPostFrameCallback((_) => _initGps());
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Lấy GPS khi mở màn hình lần đầu ─────────────────────────────────────
  Future<void> _initGps() async {
    setState(() => _loadingGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      final latLng = LatLng(pos.latitude, pos.longitude);
      _mapController.move(latLng, 15);
      // Chỉ di chuyển bản đồ, chưa đặt marker—người dùng tự nhấn chọn
    } catch (_) {
      // Fallback: bản đồ giữ nguyên _fallback
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  // ── Nút GPS (trong lúc xem bản đồ) ──────────────────────────────────────
  Future<void> _goToMyLocation() async {
    setState(() => _loadingGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      final latLng = LatLng(pos.latitude, pos.longitude);
      _mapController.move(latLng, 16);
      setState(() {
        _picked = latLng;
        _locationName = '';
      });
      _reverseGeocode(latLng);
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  // ── Tìm kiếm địa chỉ ─────────────────────────────────────────────────────
  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await locationFromAddress(q);
      if (mounted) setState(() => _searchResults = results);
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _selectSearchResult(Location loc) async {
    final latLng = LatLng(loc.latitude, loc.longitude);
    _searchCtrl.clear();
    _searchFocus.unfocus();
    setState(() {
      _searchResults = [];
      _picked = latLng;
      _locationName = '';
    });
    // Đảm bảo move sau khi setState + rebuild xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mapController.move(latLng, 15);
    });
    _reverseGeocode(latLng);
  }

  // ── Reverse geocode ───────────────────────────────────────────────────────
  Future<void> _reverseGeocode(LatLng pos) async {
    if (!mounted) return;
    setState(() => _geocoding = true);
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        // Ưu tiên: tên địa điểm cụ thể → số nhà + đường → phường → quận → tỉnh
        final name = p.name?.trim() ?? '';
        final thoroughfare = p.thoroughfare?.trim() ?? ''; // tên đường
        final subThoroughfare = p.subThoroughfare?.trim() ?? ''; // số nhà
        final subLocality = p.subLocality?.trim() ?? ''; // phường/xã
        final locality = p.locality?.trim() ?? ''; // quận/huyện
        final adminArea = p.administrativeArea?.trim() ?? ''; // tỉnh/tp

        // Ghép số nhà + tên đường
        final street = [subThoroughfare, thoroughfare]
            .where((s) => s.isNotEmpty)
            .join(' ');

        // Nếu name khác với tên đường thì dùng làm tiền tố (vd: "Công viên Yên Sở")
        final parts = <String>[];
        if (name.isNotEmpty && name != thoroughfare && name != street) {
          parts.add(name);
        }
        if (street.isNotEmpty) parts.add(street);
        if (subLocality.isNotEmpty) parts.add(subLocality);
        if (locality.isNotEmpty) parts.add(locality);
        if (adminArea.isNotEmpty) parts.add(adminArea);

        if (mounted) {
          setState(() => _locationName =
              parts.isNotEmpty ? parts.join(', ') : _coord(pos));
        }
      }
    } catch (_) {
      if (mounted) setState(() => _locationName = _coord(pos));
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  String _coord(LatLng pos) =>
      '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';

  // ── Nhấn bản đồ ──────────────────────────────────────────────────────────
  void _onTap(TapPosition _, LatLng pos) {
    _searchFocus.unfocus();
    setState(() {
      _searchResults = [];
      _picked = pos;
      _locationName = '';
    });
    _reverseGeocode(pos);
  }

  void _confirm() {
    if (_picked == null) return;
    Navigator.of(context).pop({
      'lat': _picked!.latitude,
      'lng': _picked!.longitude,
      'name': _locationName.isEmpty ? _coord(_picked!) : _locationName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí trên bản đồ'),
        actions: [
          if (_picked != null)
            TextButton(
              onPressed: _geocoding ? null : _confirm,
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Bản đồ ────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _fallback,
              initialZoom: 13,
              onTap: _onTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pet_finder',
              ),
              if (_picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _picked!,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_pin,
                        color: AppColors.lost,
                        size: 44,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Thanh tìm kiếm + kết quả ──────────────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Search field
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _search,
                    decoration: InputDecoration(
                      hintText: 'Tìm địa chỉ, phường, quận...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchResults = []);
                                  },
                                )
                              : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),

                // Danh sách kết quả tìm kiếm
                if (_searchResults.isNotEmpty)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final loc = _searchResults[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_outlined,
                                color: AppColors.primary, size: 20),
                            title: Text(
                              '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: () => _selectSearchResult(loc),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Hướng dẫn khi chưa chọn ──────────────────────────────────────
          if (_picked == null && _searchResults.isEmpty)
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Nhấn lên bản đồ để đánh dấu vị trí',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),

          // ── Nút GPS ───────────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: _picked != null ? 200 : 24,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              onPressed: _loadingGps ? null : _goToMyLocation,
              backgroundColor: Colors.white,
              child: _loadingGps
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // ── Panel xác nhận ────────────────────────────────────────────────
          if (_picked != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 12)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.lost, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _geocoding || _locationName.isEmpty
                                  ? 'Đang lấy địa chỉ...'
                                  : _locationName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    _geocoding ? AppColors.textSecondary : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _geocoding ? null : _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Xác nhận vị trí',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
