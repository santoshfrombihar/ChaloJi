import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import 'location_search_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  LatLng _pickupLocation = const LatLng(25.6112, 85.1414); // Default Patna
  String _pickupAddress = 'Fetching current location...';

  LatLng? _destinationLocation;
  String _destinationAddress = '';

  // Live map scrolling pointer updates
  String _mapVisualAddress = "Drag map to select location";
  bool _isGeocodingLoading = false;

  final MapController _mapController = MapController();
  final String mapboxToken =
      'pk.eyJ1Ijoic2FudG9zaHNpbmdoY3NoYXJwIiwiYSI6ImNtcG1wcGswZjBjeTUycXNmdHlicjB3eGEifQ.DmWhDhIDl0q8QhL_oWsHrA';

  bool _isSelectingFromMap = false;
  bool _mapTargetIsPickup = false;
  bool _showRoute = false;
  String _distanceStr = "Calculating...";
  String _timeStr = "Calculating...";
  int _calculatedFare = 0;
  bool _isRouteLoading = false;
  List<Polyline> _polylines = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // 🗺️ Live Reverse Geocoding API for Map Pin Point Tracking
  Future<void> _updateLiveMapAddress(LatLng center) async {
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${center.longitude},${center.latitude}.json'
      '?access_token=$mapboxToken&limit=1',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          setState(() {
            _mapVisualAddress =
                data['features'][0]['place_name'] ??
                data['features'][0]['text'];
          });
        }
      }
    } catch (e) {
      debugPrint("Live Geocoding Error: $e");
    }
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final currentLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _pickupLocation = currentLatLng;
    });
    _mapController.move(_pickupLocation, 15.0);

    // Set direct address for current location
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json?access_token=$mapboxToken&limit=1',
    );
    try {
      final res = await http.get(url);
      final data = json.decode(res.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        setState(() {
          _pickupAddress =
              data['features'][0]['text'] ?? data['features'][0]['place_name'];
        });
      }
    } catch (_) {}
  }

  Future<void> _generateRoute() async {
    if (_destinationLocation == null) return;

    setState(() {
      _isRouteLoading = true;
      _showRoute = false;
    });

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${_pickupLocation.longitude},${_pickupLocation.latitude};'
      '${_destinationLocation!.longitude},${_destinationLocation!.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          double distanceInKms = route['distance'] / 1000.0;
          double durationInMins = route['duration'] / 60.0;

          final geometry = route['geometry']['coordinates'] as List;
          List<LatLng> roadPoints = geometry
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();

          setState(() {
            _polylines = [
              Polyline(
                points: roadPoints,
                strokeWidth: 5.0,
                color: AppTheme.accentColor,
              ),
            ];
            _distanceStr = "${distanceInKms.toStringAsFixed(1)} km";
            _timeStr = "${durationInMins.toStringAsFixed(0)} mins";
            _calculatedFare =
                (40.0 + (distanceInKms * 12.0) + (durationInMins * 1.0))
                    .round();
            _showRoute = true;
            _isRouteLoading = false;
          });

          _mapController.move(
            LatLng(
              (_pickupLocation.latitude + _destinationLocation!.latitude) / 2,
              (_pickupLocation.longitude + _destinationLocation!.longitude) / 2,
            ),
            13.0,
          );
        }
      }
    } catch (e) {
      setState(() => _isRouteLoading = false);
    }
  }

  void _openSearchPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationSearchScreen(
          currentAddress: _pickupAddress,
          currentLatLng: _pickupLocation,
          selectedDestAddress: _destinationAddress,
        ),
      ),
    );

    if (result != null) {
      if (result['pickFromMap'] == true) {
        setState(() {
          _isSelectingFromMap = true;
          _mapTargetIsPickup = result['targetIsPickup'] ?? false;
          _showRoute = false;
          _mapVisualAddress = "Moving map...";
        });
        // Run initial geocoding trigger for central point
        _updateLiveMapAddress(_mapController.camera.center);
      } else {
        setState(() {
          _pickupLocation = result['pickupLatLng'];
          _pickupAddress = result['pickupAddress'];
          _destinationLocation = result['destLatLng'];
          _destinationAddress = result['destAddress'];
          _isSelectingFromMap = false;
        });
        _generateRoute();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickupLocation,
              initialZoom: 14.5,
              onPositionChanged: (position, hasGesture) {
                if (_isSelectingFromMap && hasGesture) {
                  setState(() {
                    if (_mapTargetIsPickup) {
                      _pickupLocation = position.center;
                    } else {
                      _destinationLocation = position.center;
                    }
                  });
                  // ⚡ Live address check on drag release / move updates
                  _updateLiveMapAddress(position.center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken',
                additionalOptions: {'access_token': mapboxToken},
                userAgentPackageName: 'com.chaloji.customer',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (_showRoute) PolylineLayer(polylines: _polylines),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickupLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: AppTheme.accentColor,
                      size: 36,
                    ),
                  ),
                  if (_showRoute && _destinationLocation != null)
                    Marker(
                      point: _destinationLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Center Indicator Pin for Precise Manual Marking
          if (_isSelectingFromMap)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Icon(
                  Icons.location_searching_rounded,
                  color: _mapTargetIsPickup
                      ? AppTheme.accentColor
                      : Colors.redAccent,
                  size: 40,
                ),
              ),
            ),

          // Floating Menu Button
          if (!_isSelectingFromMap)
            Positioned(
              top: 50,
              left: 16,
              child: Builder(
                builder: (context) => FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  shape: const CircleBorder(),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(Icons.menu_rounded),
                ),
              ),
            ),

          if (_isRouteLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            ),

          // Adaptive Bottom Panels
          Align(
            alignment: Alignment.bottomCenter,
            child: _isSelectingFromMap
                ? _buildMapConfirmPanel()
                : (_showRoute
                      ? _buildRideConfirmPanel()
                      : _buildDefaultBookingPanel()),
          ),
        ],
      ),
    );
  }

  // PANEL A: Default View
  Widget _buildDefaultBookingPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome, Santosh Kumar',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'Where are you going?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _openSearchPage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppTheme.accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _destinationAddress.isEmpty
                          ? 'Enter destination address...'
                          : _destinationAddress,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMutedColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // PANEL B: Map Selector with Live Address Display (Solves User Friendliness Issue)
  Widget _buildMapConfirmPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.pin_drop,
                color: _mapTargetIsPickup
                    ? AppTheme.accentColor
                    : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _mapVisualAddress, // ⚡ LIVE LOCATION ADDRESS TEXT FROM MAP UPDATES HERE
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSelectingFromMap = false;
                  if (_mapTargetIsPickup) {
                    _pickupAddress = _mapVisualAddress;
                    _openSearchPage();
                  } else {
                    _destinationAddress = _mapVisualAddress;
                    _generateRoute();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _mapTargetIsPickup
                    ? AppTheme.accentColor
                    : Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _mapTargetIsPickup
                    ? 'Confirm Pickup Location'
                    : 'Confirm Destination Location',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PANEL C: Ride Summary
  Widget _buildRideConfirmPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            "Confirm Ride Details",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: _openSearchPage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _pickupAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppTheme.accentColor,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 16),
                InkWell(
                  onTap: _openSearchPage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _destinationAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Distance: $_distanceStr",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Fare: ₹$_calculatedFare",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight(12),
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Book Ride Now",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            accountName: Text('Santosh Kumar'),
            accountEmail: Text('santosh@gmail.com'),
          ),
        ],
      ),
    );
  }
}
