import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/corner_api_client.dart';
import '../theme/corner_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final CornerApiClient _api = CornerApiClient();
  final MapController _mapController = MapController();
  String _selectedCity = 'New York';
  final Set<String> _activeFilters = {'Friends Only'};
  final Set<String> _savedCardNames = {'Eavesdrop', 'Dimes Deli'};
  String _selectedMarker = 'Dimes Deli';
  bool _useAmapTiles = false;
  bool _warmEditorialFilter = true;
  bool _isSheetCollapsed = false;
  late final AnimationController _pulseController;

  static const Map<String, String> _spotMarkerToApiId = {
    'Abraço': 'spot_abraco',
    'Eavesdrop': 'spot_eavesdrop',
    'Dimes Deli': 'spot_dimes',
    "Roman's": 'spot_romans',
  };

  static const Map<String, LatLng> _cityCenters = {
    'New York': LatLng(40.7208, -73.9882),
    'Tokyo': LatLng(35.6508, 139.7028),
    'Paris': LatLng(48.8592, 2.3622),
    'London': LatLng(51.5136, -0.1365),
    'Shanghai': LatLng(31.2135, 121.4452),
  };

  static const Map<String, String> _citySubtitles = {
    'New York': 'Near Nolita & LES',
    'Tokyo': 'Near Daikanyama & Aoyama',
    'Paris': 'Near Le Marais & Canal',
    'London': 'Near Soho & Fitzrovia',
    'Shanghai': 'Near Wukang & Anfu Rd',
  };

  static const Map<String, List<_MapSpotData>> _citySpots = {
    'New York': [
      _MapSpotData(
        id: 'Abraço',
        fullName: 'Abraço Espresso',
        category: 'Standing Coffee',
        price: '\$',
        neighborhoodPrice: 'EAST VILLAGE · \$',
        rating: '4.8',
        walkInfo: '12 min walk · 81 E 7th St',
        description:
            'Authentic standing espresso counter bar with olive oil cake and vinyl energy.',
        markerImage: 'assets/images/img_12.jpg',
        cardImage: 'assets/images/img_19.jpg',
        location: LatLng(40.7272, -73.9861),
        markerSize: 42,
        endorsementText: 'Trending in East Village',
        useFireIcon: true,
      ),
      _MapSpotData(
        id: 'Eavesdrop',
        fullName: 'Eavesdrop',
        category: 'Listening Lounge',
        price: '\$\$\$',
        neighborhoodPrice: 'NOLITA / BK · \$\$\$',
        rating: '4.9',
        walkInfo: '8 min walk · Greenpoint Ave',
        description:
            'Intimate Japanese-inspired listening lounge with bespoke acoustics and seasonal cocktails.',
        markerImage: 'assets/images/img_07.jpg',
        cardImage: 'assets/images/img_14.jpg',
        location: LatLng(40.7232, -73.9818),
        markerSize: 46,
        hasLiveDot: true,
        friendAvatars: ['assets/images/img_08.jpg', 'assets/images/img_09.jpg'],
        endorsementAvatars: [
          'assets/images/img_15.jpg',
          'assets/images/img_16.jpg',
        ],
        endorsementText: 'Saved by Annie & Jake',
      ),
      _MapSpotData(
        id: 'Dimes Deli',
        fullName: 'Dimes Deli',
        category: 'Café & Provisions',
        price: '\$\$',
        neighborhoodPrice: 'CHINATOWN · \$\$',
        rating: '4.8',
        walkInfo: '4 min walk · 143 Division St',
        description:
            'Sunny neighborhood café & provisions on Division St. Sophie’s go-to morning spot.',
        markerImage: 'assets/images/img_10.jpg',
        cardImage: 'assets/images/img_17.jpg',
        location: LatLng(40.7149, -73.9915),
        markerSize: 46,
        friendAvatars: ['assets/images/img_11.jpg'],
        endorsementAvatars: ['assets/images/img_18.jpg'],
        endorsementText: "Sophie's go-to morning spot",
      ),
      _MapSpotData(
        id: "Roman's",
        fullName: "Roman's Wine Cellar",
        category: 'Natural Cellar',
        price: '\$\$\$',
        neighborhoodPrice: 'LOWER MANHATTAN · \$\$\$',
        rating: '4.9',
        walkInfo: '6 min walk · Mulberry St',
        description:
            'Neighborhood Italian & low-intervention bottle shop with warm candlelit tables.',
        markerImage: 'assets/images/img_13.jpg',
        cardImage: 'assets/images/img_13.jpg',
        location: LatLng(40.7185, -73.9862),
        markerSize: 36,
        isSecondaryLabel: true,
        endorsementText: 'Curated by Clara Vance',
      ),
    ],
    'Tokyo': [
      _MapSpotData(
        id: 'Bar Martha',
        fullName: 'Bar Martha Ebisu',
        category: 'Vinyl Bar',
        price: '\$\$\$',
        neighborhoodPrice: 'EBISU · \$\$\$',
        rating: '4.9',
        walkInfo: '5 min walk · Ebisu 1-Chome',
        description:
            'Tannoy speakers, wall-to-wall vinyl records, and smoky single malts.',
        markerImage: 'assets/images/img_21.jpg',
        cardImage: 'assets/images/img_21.jpg',
        location: LatLng(35.6478, 139.7102),
        markerSize: 46,
        hasLiveDot: true,
        friendAvatars: ['assets/images/img_08.jpg'],
        endorsementAvatars: ['assets/images/img_15.jpg'],
        endorsementText: 'Saved by Clara & Kenji',
      ),
      _MapSpotData(
        id: 'Koffee Mameya',
        fullName: 'Koffee Mameya Kakeru',
        category: 'Omakase Coffee',
        price: '\$\$',
        neighborhoodPrice: 'OMOTESANDO · \$\$',
        rating: '4.9',
        walkInfo: '9 min walk · Jingumae',
        description:
            'Bespoke roast tastings in a serene minimalist timber space.',
        markerImage: 'assets/images/img_26.jpg',
        cardImage: 'assets/images/img_26.jpg',
        location: LatLng(35.6542, 139.6985),
        markerSize: 44,
        endorsementText: 'Quiet morning ritual',
      ),
    ],
    'Paris': [
      _MapSpotData(
        id: 'Folderol',
        fullName: 'Folderol Wine & Ice Cream',
        category: 'Natural Wine',
        price: '\$\$',
        neighborhoodPrice: '11E ARR · \$\$',
        rating: '4.9',
        walkInfo: '4 min walk · 10 Rue du Grand Prieuré',
        description:
            'Olive oil ice cream & low-intervention pours spilling onto quiet cobblestones.',
        markerImage: 'assets/images/img_27.jpg',
        cardImage: 'assets/images/img_27.jpg',
        location: LatLng(48.8642, 2.3689),
        markerSize: 46,
        hasLiveDot: true,
        friendAvatars: ['assets/images/img_11.jpg'],
        endorsementText: 'Saved by Eliza & Jules',
      ),
      _MapSpotData(
        id: 'Bambino',
        fullName: 'Bambino Listening Bar',
        category: 'Hi-Fi Bistro',
        price: '\$\$\$',
        neighborhoodPrice: 'SAINT-SÉBASTIEN · \$\$\$',
        rating: '4.8',
        walkInfo: '7 min walk · 25 Rue Saint-Sébastien',
        description:
            'Plywood horn speakers, natural pet-nat, and wood-fired small plates.',
        markerImage: 'assets/images/img_03.jpg',
        cardImage: 'assets/images/img_03.jpg',
        location: LatLng(48.8558, 2.3575),
        markerSize: 42,
        endorsementText: 'Top late-night soundbar',
      ),
    ],
    'London': [
      _MapSpotData(
        id: 'Noble Rot',
        fullName: 'Noble Rot Soho',
        category: 'Wine Bar',
        price: '\$\$\$',
        neighborhoodPrice: 'SOHO · \$\$\$',
        rating: '4.9',
        walkInfo: '6 min walk · 2 Greek St',
        description:
            'Historic Soho townhouse celebrating old-world cellars and literary lunches.',
        markerImage: 'assets/images/img_32.jpg',
        cardImage: 'assets/images/img_32.jpg',
        location: LatLng(51.5148, -0.1312),
        markerSize: 46,
        hasLiveDot: true,
        endorsementText: 'Saved by 194 tastemakers',
      ),
    ],
    'Shanghai': [
      _MapSpotData(
        id: 'Oha Café',
        fullName: 'Oha Eatery & Listening Bar',
        category: 'Natural Wine & Coffee',
        price: '\$\$',
        neighborhoodPrice: 'ANFU / WUKANG · \$\$',
        rating: '4.9',
        walkInfo: '5 min walk · Wukang Rd',
        description:
            'Plane-tree shaded courtyard, artisanal sourdough & natural wine pours.',
        markerImage: 'assets/images/img_22.jpg',
        cardImage: 'assets/images/img_22.jpg',
        location: LatLng(31.2135, 121.4452),
        markerSize: 46,
        hasLiveDot: true,
        friendAvatars: ['assets/images/img_08.jpg', 'assets/images/img_09.jpg'],
        endorsementText: 'Saved by Clara & Friends',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _syncMapSpotsFromBackend(_selectedCity);
  }

  Future<void> _syncMapSpotsFromBackend(String city) async {
    try {
      await _api.fetchMapSpots(
        city: city,
        friendsOnly: _activeFilters.contains('Friends Only'),
      );
    } catch (_) {
      // Offline sanctuary fallback
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<_MapSpotData> get _currentSpots =>
      _citySpots[_selectedCity] ?? _citySpots['New York']!;

  void _selectCity(String city) {
    setState(() {
      _selectedCity = city;
      if (city == 'Shanghai') {
        _useAmapTiles = true;
      }
      final spots = _currentSpots;
      if (spots.isNotEmpty) {
        _selectedMarker = spots.first.id;
      }
    });
    final center = _cityCenters[city] ?? const LatLng(40.7208, -73.9882);
    _mapController.move(center, 14.3);
    _syncMapSpotsFromBackend(city);
  }

  void _toggleFilter(String label) {
    setState(() {
      if (_activeFilters.contains(label)) {
        _activeFilters.remove(label);
      } else {
        _activeFilters.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 60;
    final bottomInset = MediaQuery.paddingOf(context).bottom + 64;
    final spots = _currentSpots;
    final cityCenter =
        _cityCenters[_selectedCity] ?? const LatLng(40.7208, -73.9882);

    // Warm Editorial Sanctuary color matrix (subtle warm linen paper tone on real map tiles)
    const warmEditorialMatrix = ColorFilter.matrix(<double>[
      0.98, 0.02, 0.00, 0, 4, // R
      0.01, 0.96, 0.01, 0, 2, // G
      0.00, 0.02, 0.91, 0, -4, // B
      0, 0, 0, 1, 0, // A
    ]);

    Widget tileLayer = _useAmapTiles
        ? TileLayer(
            urlTemplate:
                'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
            subdomains: const ['1', '2', '3', '4'],
            userAgentPackageName: 'com.corner.story',
            maxZoom: 19,
          )
        : Stack(
            children: [
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.corner.story',
                maxZoom: 16,
              ),
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Reference/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.corner.story',
                maxZoom: 16,
              ),
            ],
          );

    if (_warmEditorialFilter) {
      tileLayer = ColorFiltered(
        colorFilter: warmEditorialMatrix,
        child: tileLayer,
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
      child: Column(
        children: [
          // Real Interactive Map Canvas (Expanded so pan & pinch-zoom work smoothly)
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: cityCenter,
                      initialZoom: 14.3,
                      minZoom: 3,
                      maxZoom: 18.5,
                      backgroundColor: CornerColors.surfaceContainerLow,
                    ),
                    children: [
                      tileLayer,
                      // User Current Location Pulse Dot on Real Coordinates
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              cityCenter.latitude + 0.0008,
                              cityCenter.longitude + 0.0025,
                            ),
                            width: 40,
                            height: 40,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                final v = _pulseController.value;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 14 + (24 * v),
                                      height: 14 + (24 * v),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CornerColors.onTertiaryContainer
                                            .withValues(alpha: (1 - v) * 0.30),
                                      ),
                                    ),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: CornerColors.onTertiaryContainer,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: CornerColors.surface,
                                          width: 2.4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.15),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          // Curated Spot Photo Markers on Real Coordinates
                          ...spots.map(
                            (spot) => Marker(
                              point: spot.location,
                              width: 120,
                              height: 82,
                              child: _MapSpotMarker(
                                title: spot.id,
                                imageAsset: spot.markerImage,
                                size: spot.markerSize,
                                hasLiveDot: spot.hasLiveDot,
                                friendAvatars: spot.friendAvatars,
                                isSecondaryLabel: spot.isSecondaryLabel,
                                isSelected: _selectedMarker == spot.id,
                                onTap: () {
                                  setState(() => _selectedMarker = spot.id);
                                  _mapController.move(spot.location, 15.2);
                                  showSpotDetailModal(
                                    context,
                                    name: spot.fullName,
                                    neighborhoodAndPrice:
                                        spot.neighborhoodPrice,
                                    rating: spot.rating,
                                    description: spot.description,
                                    imageAsset: spot.cardImage,
                                    categoryBadge: spot.category,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Map Floating Controls & City Selector
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: City Dropdown + Quick Switch
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: _cityCenters.keys.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final city = _cityCenters.keys.elementAt(index);
                            final isSelected = city == _selectedCity;
                            return GestureDetector(
                              onTap: () => _selectCity(city),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF000000)
                                      : CornerColors.surface.withValues(
                                          alpha: 0.94,
                                        ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      city,
                                      style: (isSelected
                                              ? CornerTypography.labelMd
                                              : CornerTypography.labelSm)
                                          .copyWith(
                                        color: isSelected
                                            ? CornerColors.onPrimary
                                            : CornerColors.secondary,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: CornerColors.onPrimary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Second Row: Curated Filters Bar + Real Map Tile Source Switch
                      SizedBox(
                        height: 34,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          children: [
                            _MapFilterPill(
                              label: 'Friends Only',
                              icon: Icons.group_rounded,
                              isActive: _activeFilters.contains('Friends Only'),
                              onTap: () => _toggleFilter('Friends Only'),
                            ),
                            const SizedBox(width: 6),
                            _MapFilterPill(
                              label: 'Open Now',
                              isActive: _activeFilters.contains('Open Now'),
                              onTap: () => _toggleFilter('Open Now'),
                            ),
                            const SizedBox(width: 6),
                            _MapFilterPill(
                              label: 'Coffee & Wine',
                              icon: Icons.local_cafe_outlined,
                              isActive:
                                  _activeFilters.contains('Coffee & Wine'),
                              onTap: () => _toggleFilter('Coffee & Wine'),
                            ),
                            const SizedBox(width: 6),
                            _MapFilterPill(
                              label: _useAmapTiles ? '高德瓦片' : 'Carto Editorial',
                              icon: Icons.layers_outlined,
                              isActive: _useAmapTiles,
                              onTap: () {
                                setState(() => _useAmapTiles = !_useAmapTiles);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Action Pills (Zoom, Recenter & List View)
                Positioned(
                  bottom: 22,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Map Style Warm Filter Toggle + Recenter
                      GestureDetector(
                        onTap: () {
                          _mapController.move(cityCenter, 14.3);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: CornerColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.near_me_outlined,
                            size: 20,
                            color: CornerColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: CornerColors.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            builder: (ctx) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DIRECTORY INDEX · $_selectedCity',
                                    style: CornerTypography.labelCaps.copyWith(
                                      color: CornerColors.onTertiaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_citySubtitles[_selectedCity]} (${spots.length})',
                                    style: CornerTypography.headlineSm,
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(spots.length, (i) {
                                    final s = spots[i];
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            _mapController.move(
                                              s.location,
                                              15.5,
                                            );
                                            setState(
                                              () => _selectedMarker = s.id,
                                            );
                                          },
                                          child: _DirectoryIndexRow(
                                            number: '0${i + 1}',
                                            name: s.fullName,
                                            meta:
                                                '${s.category} · ${s.price} · ${s.walkInfo}',
                                          ),
                                        ),
                                        if (i < spots.length - 1)
                                          const Divider(
                                            color: CornerColors.hairline,
                                          ),
                                      ],
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000000),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.format_list_bulleted_rounded,
                                size: 18,
                                color: CornerColors.onPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'List View',
                                style: CornerTypography.labelMd.copyWith(
                                  color: CornerColors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Editorial Bottom Sheet Drawer (Collapsible Luxury Booklet Style)
          GestureDetector(
            onVerticalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 150 && !_isSheetCollapsed) {
                setState(() => _isSheetCollapsed = true);
              } else if (velocity < -150 && _isSheetCollapsed) {
                setState(() => _isSheetCollapsed = false);
              }
            },
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: _isSheetCollapsed ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: CornerColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B1C1A).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tappable Drag Handle & Header Bar to Collapse / Expand
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(
                          () => _isSheetCollapsed = !_isSheetCollapsed,
                        );
                      },
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: CornerColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CURATED FIELD GUIDE',
                                      style: CornerTypography.labelCaps.copyWith(
                                        color:
                                            CornerColors.onTertiaryContainer,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _citySubtitles[_selectedCity] ??
                                          'Near Nolita & LES',
                                      style: CornerTypography.headlineSm,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${spots.length} places',
                                      style: CornerTypography.bodySm.copyWith(
                                        color: CornerColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: CornerColors.surfaceContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _isSheetCollapsed
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: CornerColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isSheetCollapsed) ...[
                      const SizedBox(height: 12),
                      // Horizontal Carousel Preview Booklet
                      SizedBox(
                        height: 256,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: spots.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final spot = spots[index];
                            return _FieldGuideCard(
                              title: spot.fullName,
                              category: spot.category,
                              price: spot.price,
                              walkInfo: spot.walkInfo,
                              imageAsset: spot.cardImage,
                              endorsementText: spot.endorsementText,
                              endorsementAvatars: spot.endorsementAvatars,
                              useFireIcon: spot.useFireIcon,
                              isBookmarked: _savedCardNames.contains(spot.id),
                              onToggleBookmark: () {
                                final wasSaved =
                                    _savedCardNames.contains(spot.id);
                                setState(() {
                                  if (wasSaved) {
                                    _savedCardNames.remove(spot.id);
                                  } else {
                                    _savedCardNames.add(spot.id);
                                  }
                                });
                                final apiId = _spotMarkerToApiId[spot.id];
                                if (apiId != null) {
                                  _api
                                      .toggleSpotBookmark(apiId)
                                      .catchError((_) => !wasSaved);
                                }
                              },
                              onTap: () {
                                setState(() => _selectedMarker = spot.id);
                                _mapController.move(spot.location, 15.4);
                                showSpotDetailModal(
                                  context,
                                  name: spot.fullName,
                                  neighborhoodAndPrice: spot.neighborhoodPrice,
                                  rating: spot.rating,
                                  description: spot.description,
                                  imageAsset: spot.cardImage,
                                  categoryBadge: spot.category,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
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

class _MapSpotData {
  final String id;
  final String fullName;
  final String category;
  final String price;
  final String neighborhoodPrice;
  final String rating;
  final String walkInfo;
  final String description;
  final String markerImage;
  final String cardImage;
  final LatLng location;
  final double markerSize;
  final bool hasLiveDot;
  final bool isSecondaryLabel;
  final bool useFireIcon;
  final List<String> friendAvatars;
  final List<String> endorsementAvatars;
  final String endorsementText;

  const _MapSpotData({
    required this.id,
    required this.fullName,
    required this.category,
    required this.price,
    required this.neighborhoodPrice,
    required this.rating,
    required this.walkInfo,
    required this.description,
    required this.markerImage,
    required this.cardImage,
    required this.location,
    required this.markerSize,
    this.hasLiveDot = false,
    this.isSecondaryLabel = false,
    this.useFireIcon = false,
    this.friendAvatars = const [],
    this.endorsementAvatars = const [],
    required this.endorsementText,
  });
}

class _MapFilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _MapFilterPill({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF000000)
              : CornerColors.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isActive
                    ? CornerColors.onPrimary
                    : CornerColors.onSurface,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: CornerTypography.labelSm.copyWith(
                color: isActive
                    ? CornerColors.onPrimary
                    : CornerColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSpotMarker extends StatelessWidget {
  final String title;
  final String imageAsset;
  final double size;
  final List<String> friendAvatars;
  final bool hasLiveDot;
  final bool isSelected;
  final bool isSecondaryLabel;
  final VoidCallback onTap;

  const _MapSpotMarker({
    required this.title,
    required this.imageAsset,
    required this.size,
    this.friendAvatars = const [],
    this.hasLiveDot = false,
    this.isSelected = false,
    this.isSecondaryLabel = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: CornerColors.surface,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: CornerColors.primary, width: 2.2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (friendAvatars.isNotEmpty)
                Positioned(
                  bottom: -4,
                  right: -6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      friendAvatars.length,
                      (index) => Transform.translate(
                        offset: Offset(index * -5.0, 0),
                        child: Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(
                            color: CornerColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              friendAvatars[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF000000)
                  : CornerColors.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasLiveDot) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: CornerColors.onTertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  title,
                  style: CornerTypography.labelCaps.copyWith(
                    letterSpacing: 0.3,
                    color: isSelected
                        ? CornerColors.onPrimary
                        : (isSecondaryLabel
                            ? CornerColors.secondary
                            : CornerColors.onSurface),
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

class _FieldGuideCard extends StatelessWidget {
  final String title;
  final String category;
  final String price;
  final String walkInfo;
  final String imageAsset;
  final String endorsementText;
  final List<String> endorsementAvatars;
  final bool useFireIcon;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onTap;

  const _FieldGuideCard({
    required this.title,
    required this.category,
    required this.price,
    required this.walkInfo,
    required this.imageAsset,
    required this.endorsementText,
    required this.endorsementAvatars,
    this.useFireIcon = false,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CornerColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 132,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: CornerColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          category,
                          style: CornerTypography.labelCaps.copyWith(
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: onToggleBookmark,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: CornerColors.surface.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 17,
                            color: CornerColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CornerTypography.titleEditorial,
                  ),
                ),
                Text(
                  price,
                  style: CornerTypography.labelCaps.copyWith(
                    color: CornerColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.directions_walk_rounded,
                  size: 15,
                  color: CornerColors.secondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    walkInfo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CornerTypography.bodySm.copyWith(
                      color: CornerColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CornerColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (useFireIcon) ...[
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: CornerColors.onTertiaryContainer,
                    ),
                    const SizedBox(width: 6),
                  ] else if (endorsementAvatars.isNotEmpty) ...[
                    SizedBox(
                      width: endorsementAvatars.length * 13.0 + 4,
                      height: 16,
                      child: Stack(
                        children: List.generate(
                          endorsementAvatars.length,
                          (i) => Positioned(
                            left: i * 11.0,
                            child: ClipOval(
                              child: Image.asset(
                                endorsementAvatars[i],
                                width: 16,
                                height: 16,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      endorsementText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CornerTypography.labelCaps.copyWith(
                        color: CornerColors.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectoryIndexRow extends StatelessWidget {
  final String number;
  final String name;
  final String meta;

  const _DirectoryIndexRow({
    required this.number,
    required this.name,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            number,
            style: CornerTypography.titleEditorial.copyWith(
              fontStyle: FontStyle.italic,
              color: CornerColors.secondary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: CornerTypography.titleEditorial),
                Text(
                  meta,
                  style: CornerTypography.bodySm.copyWith(
                    color: CornerColors.secondary,
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
