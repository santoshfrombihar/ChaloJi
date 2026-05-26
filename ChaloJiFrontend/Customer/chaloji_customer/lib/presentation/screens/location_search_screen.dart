import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';

class LocationSearchScreen extends StatefulWidget {
  final String currentAddress;
  final LatLng currentLatLng;
  final String? selectedDestAddress;

  const LocationSearchScreen({
    super.key,
    required this.currentAddress,
    required this.currentLatLng,
    this.selectedDestAddress,
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  final String _mapboxToken =
      'pk.eyJ1Ijoic2FudG9zaHNpbmdoY3NoYXJwIiwiYSI6ImNtcG1wcGswZjBjeTUycXNmdHlicjB3eGEifQ.DmWhDhIDl0q8QhL_oWsHrA';

  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  bool _isSearchingPickup = false;
  bool _isManualPickupEnabled = false;

  String? _selectedPickupAddress;
  LatLng? _selectedPickupLatLng;
  String? _selectedDestinationAddress;
  LatLng? _selectedDestinationLatLng;

  @override
  void initState() {
    super.initState();
    _pickupController.text = widget.currentAddress;
    _selectedPickupAddress = widget.currentAddress;
    _selectedPickupLatLng = widget.currentLatLng;

    if (widget.selectedDestAddress != null &&
        widget.selectedDestAddress!.isNotEmpty) {
      _destinationController.text = widget.selectedDestAddress!;
      _selectedDestinationAddress = widget.selectedDestAddress;
    }
  }

  Future<void> _fetchSuggestions(String query, bool isPickup) async {
    setState(() {
      _isSearchingPickup = isPickup;
    });

    if (query.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json'
      '?access_token=$_mapboxToken'
      '&country=in'
      '&proximity=${widget.currentLatLng.longitude},${widget.currentLatLng.latitude}'
      '&types=poi,address,neighborhood,locality',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List features = data['features'] ?? [];

        setState(() {
          _suggestions = features.map((feature) {
            final List coordinates = feature['geometry']['coordinates'];
            return {
              'title': feature['text'] ?? '',
              'subtitle': feature['place_name'] ?? '',
              'latlng': LatLng(coordinates[1], coordinates[0]),
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _validateAndSubmit() {
    if (_selectedPickupLatLng == null || _selectedDestinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Pickup and Destination!'),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'pickFromMap': false,
      'pickupAddress': _selectedPickupAddress,
      'pickupLatLng': _selectedPickupLatLng,
      'destAddress': _selectedDestinationAddress,
      'destLatLng': _selectedDestinationLatLng,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Search Location',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: AppTheme.accentColor,
                        size: 14,
                      ),
                      Container(width: 2, height: 40, color: Colors.grey[400]),
                      const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _pickupController,
                          enabled: _isManualPickupEnabled,
                          onChanged: (value) => _fetchSuggestions(value, true),
                          style: TextStyle(
                            color: _isManualPickupEnabled
                                ? AppTheme.primaryColor
                                : Colors.grey[600],
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Current Location (Pickup)',
                            isDense: true,
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(height: 16, color: Color(0xFFE2E8F0)),
                        TextField(
                          controller: _destinationController,
                          autofocus: true,
                          onChanged: (value) => _fetchSuggestions(value, false),
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Where to? (Destination)',
                            isDense: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Toggle Switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change or Enter Pickup Manually',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Switch(
                  value: _isManualPickupEnabled,
                  activeColor: AppTheme.accentColor,
                  onChanged: (value) {
                    setState(() {
                      _isManualPickupEnabled = value;
                      if (!value) {
                        _pickupController.text = widget.currentAddress;
                        _selectedPickupAddress = widget.currentAddress;
                        _selectedPickupLatLng = widget.currentLatLng;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          // 🗺️ Map Shortcuts (Clean UX Layout)
          if (_isManualPickupEnabled)
            ListTile(
              leading: const Icon(
                Icons.map_outlined,
                color: AppTheme.accentColor,
              ),
              title: const Text(
                'Choose Pickup from Map',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.pop(context, {
                'pickFromMap': true,
                'targetIsPickup': true,
              }),
            ),
          ListTile(
            leading: const Icon(
              Icons.pin_drop_outlined,
              color: Colors.redAccent,
            ),
            title: const Text(
              'Choose Destination from Map',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            onTap: () => Navigator.pop(context, {
              'pickFromMap': true,
              'targetIsPickup': false,
            }),
          ),
          const Divider(),

          if (_isLoading)
            const LinearProgressIndicator(color: AppTheme.accentColor),

          // Suggestions List
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final place = _suggestions[index];
                return ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                  ),
                  title: Text(
                    place['title'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    place['subtitle'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    setState(() {
                      if (_isSearchingPickup) {
                        _pickupController.text = place['title'];
                        _selectedPickupAddress = place['title'];
                        _selectedPickupLatLng = place['latlng'];
                      } else {
                        _destinationController.text = place['title'];
                        _selectedDestinationAddress = place['title'];
                        _selectedDestinationLatLng = place['latlng'];
                      }
                      _suggestions = [];
                    });
                    if (_selectedPickupLatLng != null &&
                        _selectedDestinationLatLng != null) {
                      _validateAndSubmit();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
