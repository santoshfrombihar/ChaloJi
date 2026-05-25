import 'package:flutter/material.dart';
import 'package:chaloji_driver/core/theme/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isOnline = false;
  int _currentIndex = 0;
  late AnimationController _toggleController;
  late Animation<double> _toggleAnim;
  LatLng _currentLocation = LatLng(25.5941, 85.1376);
  bool _locationLoaded = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _toggleAnim = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _toggleController.dispose();
    super.dispose();
  }

  void _toggleOnline() {
    setState(() => _isOnline = !_isOnline);
    _isOnline ? _toggleController.forward() : _toggleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildHomeTab(), _buildEarningsTab(), _buildProfileTab()],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Home Tab ────────────────────────────────────────
  Widget _buildHomeTab() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          _buildStatusBanner(),
          Expanded(child: _buildMapPlaceholder()),
          _buildBottomCard(),
        ],
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Driver avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🛺', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          // Driver info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Santosh Kumar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      '4.8 rating',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMutedColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification bell
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Banner ────────────────────────────────────
  Widget _buildStatusBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: _isOnline
          ? const Color(0xFF10B981).withOpacity(0.12)
          : const Color(0xFFEF4444).withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isOnline
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isOnline
                ? 'You are Online — Ready for rides'
                : 'You are Offline — Go online to earn',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _isOnline
                  ? const Color(0xFF059669)
                  : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController, // ✅ controller add
          options: MapOptions(initialCenter: _currentLocation, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.chaloji.driver',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation, // ✅ dynamic location
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // ✅ My Location button
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'location',
            onPressed: () {
              if (_locationLoaded) {
                _mapController.move(_currentLocation, 15);
              } else {
                _getCurrentLocation();
              }
            },
            backgroundColor: Colors.white,
            elevation: 4,
            child: const Icon(
              Icons.my_location_rounded,
              color: AppTheme.primaryColor,
            ),
          ),
        ),

        // ✅ GO ONLINE / GO OFFLINE toggle button
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _toggleOnline,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: _isOnline
                      ? const Color(0xFF10B981)
                      : AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isOnline
                                  ? const Color(0xFF10B981)
                                  : AppTheme.primaryColor)
                              .withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isOnline
                          ? Icons.radio_button_checked_rounded
                          : Icons.power_settings_new_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isOnline ? 'GO\nOFFLINE' : 'GO\nONLINE',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Stats Card ────────────────────────────────
  Widget _buildBottomCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _statItem('Today\'s Rides', '0', Icons.directions_car_outlined),
          _divider(),
          _statItem('Earnings', '₹0', Icons.currency_rupee_rounded),
          _divider(),
          _statItem('Online Time', '0h 0m', Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.accentColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE2E8F0),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  // ── Earnings Tab ─────────────────────────────────────
  Widget _buildEarningsTab() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: const Row(
              children: [
                Text(
                  'Earnings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Total earnings card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, Color(0xFF334155)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Earnings Today',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹0.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            _EarningChip(
                              label: '0 Rides',
                              icon: Icons.directions_car_outlined,
                            ),
                            SizedBox(width: 12),
                            _EarningChip(
                              label: '0h Online',
                              icon: Icons.timer_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // No rides yet
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No rides yet today',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Go online and start accepting rides',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile Tab ──────────────────────────────────────
  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('🛺', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Santosh Kumar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'KYC Approved',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Menu items
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _menuItem(
                    Icons.directions_car_outlined,
                    'My Vehicle',
                    'Auto — BR01 AB 1234',
                  ),
                  _menuItem(
                    Icons.receipt_long_outlined,
                    'Ride History',
                    'View all past rides',
                  ),
                  _menuItem(
                    Icons.account_balance_wallet_outlined,
                    'Earnings & Payouts',
                    'Withdraw your earnings',
                  ),
                  _menuItem(
                    Icons.help_outline_rounded,
                    'Help & Support',
                    'Get help anytime',
                  ),
                  _menuItem(Icons.privacy_tip_outlined, 'Privacy Policy', ''),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Logout
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppTheme.primaryColor, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMutedColor,
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textMutedColor,
            size: 20,
          ),
          onTap: () {},
        ),
        const Divider(height: 1, indent: 56, color: Color(0xFFE2E8F0)),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      // ✅ Pehle last known location lo — fast
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        setState(() {
          _currentLocation = LatLng(lastKnown.latitude, lastKnown.longitude);
          _locationLoaded = true;
        });
        _mapController.move(_currentLocation, 15);
      }

      // ✅ Phir accurate location lo
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, // ✅ locationSettings nahi
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });
        _mapController.move(_currentLocation, 15);
      }
    } catch (e) {
      print('Location error: $e');
    }
  }

  // ── Bottom Navigation ────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: AppTheme.textMutedColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Helper Widget ────────────────────────────────────
class _EarningChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _EarningChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
