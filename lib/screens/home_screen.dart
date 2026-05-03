import 'package:e_waste_locator/screens/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/ewaste_center.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import 'facility_details_screen.dart';
import 'about_ewaste_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  List<EwasteCenter> _allCenters = [];
  bool _loading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initLocationAndData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndData() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _loading = false;
      });
      _loadMarkers();
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _loading = false);
    }
  }

  void _loadMarkers() {
    final firestoreService = FirestoreService();
    firestoreService.getEwasteCenters().listen((centers) {
      if (mounted) {
        setState(() {
          _allCenters = centers;
          _updateMarkers(centers);
        });
      }
    });
  }

  void _updateMarkers(List<EwasteCenter> centers) {
    setState(() {
      _markers.clear();
      for (var center in centers) {
        _markers.add(
          Marker(
            markerId: MarkerId(center.id),
            position: LatLng(center.latitude, center.longitude),
            infoWindow: InfoWindow(
              title: center.name,
              snippet: center.city,
              onTap: () => _navigateToDetails(center),
            ),
          ),
        );
      }
    });
  }

  void _filterCenters(String query) {
    if (query.isEmpty) {
      _updateMarkers(_allCenters);
    } else {
      final filtered = _allCenters
          .where((c) =>
              c.city.toLowerCase().contains(query.toLowerCase()) ||
              c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _updateMarkers(filtered);
    }
  }

  /// Geocodes the typed city name and animates the map camera to it.
  Future<void> _searchCity() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Dismiss keyboard
    _searchFocusNode.unfocus();

    setState(() => _isSearching = true);

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty && _mapController != null) {
        final loc = locations.first;
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(loc.latitude, loc.longitude),
              zoom: 13,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not find location for "$query"'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      // Also filter facility markers for the searched city
      _filterCenters(query);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location not found: "$query". Check spelling.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _navigateToDetails(EwasteCenter center) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FacilityDetailsScreen(center: center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Waste Locator'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchCity(),
              onChanged: _filterCenters,
              decoration: InputDecoration(
                hintText: 'Search city or center name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.location_city),
                        tooltip: 'Go to city on map',
                        onPressed: _searchCity,
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child:
                        Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AuthService.instance.currentUser?['name'] ??
                        'Guest User',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AuthService.instance.currentUser?['email'] ?? '',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Color(0xFF2E7D32)),
              title: const Text('Home Map'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings,
                  color: Color(0xFF2E7D32)),
              title: const Text('Admin Panel'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
              title: const Text('About E-Waste'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutEwasteScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                AuthService.instance.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition != null
                              ? LatLng(_currentPosition!.latitude,
                                  _currentPosition!.longitude)
                              : const LatLng(28.6139, 77.2090),
                          zoom: 12,
                        ),
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        myLocationEnabled: true,
                        markers: _markers,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: true,
                        compassEnabled: true,
                      ),
                      if (_currentPosition == null)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Card(
                            color: Colors.redAccent,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Location permission pending or denied.',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
              ),
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
