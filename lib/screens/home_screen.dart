import 'package:e_waste_locator/screens/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ewaste_center.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import 'facility_details_screen.dart';
import 'about_ewaste_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLocationAndData();
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
          .where((c) => c.city.toLowerCase().contains(query.toLowerCase()) || 
                       c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _updateMarkers(filtered);
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
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by city or center name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterCenters,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.recycling, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'E-Waste Locator',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Home Map'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
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
              leading: const Icon(Icons.info_outline),
              title: const Text('About E-Waste'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutEwasteScreen()),
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
                              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                              : const LatLng(28.6139, 77.2090),
                          zoom: 12,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
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
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              ),
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
