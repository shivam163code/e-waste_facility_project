import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ewaste_center.dart';
import '../services/firestore_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _contactController = TextEditingController();
  final _itemsController = TextEditingController();

  bool _isSaving = false;

  /// Holds the preview location — set immediately on valid form submit.
  LatLng? _savedLocation;
  String? _savedFacilityName;
  bool _firestoreSaveSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _contactController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> _saveFacility() async {
    if (_formKey.currentState!.validate()) {
      final lat = double.parse(_latController.text);
      final lng = double.parse(_lngController.text);
      final name = _nameController.text;

      // ── Step 1: Show map preview IMMEDIATELY (dummy output) ──────────
      setState(() {
        _isSaving = true;
        _savedLocation = LatLng(lat, lng);
        _savedFacilityName = name;
        _firestoreSaveSuccess = false;
      });

      // Auto-scroll to map after short delay so map renders first
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });

      // ── Step 2: Save to Firestore in background ──────────────────────
      final newCenter = EwasteCenter(
        id: '',
        name: name,
        address: _addressController.text,
        city: _cityController.text,
        latitude: lat,
        longitude: lng,
        contact: _contactController.text,
        acceptedItems:
            _itemsController.text.split(',').map((e) => e.trim()).toList(),
      );

      try {
        await _firestoreService.addCenter(newCenter);
        if (mounted) {
          setState(() => _firestoreSaveSuccess = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Facility saved to database successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Map preview stays visible even on Firestore error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not save to database: $e'),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add E-Waste Facility'),
        actions: [
          if (_savedLocation != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Add another facility',
              onPressed: _resetForm,
            ),
        ],
      ),
      body: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Form ──────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Facility Name',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.home),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latController,
                                decoration: const InputDecoration(
                                  labelText: 'Latitude',
                                  prefixIcon: Icon(Icons.north),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true, signed: true),
                                validator: (v) =>
                                    double.tryParse(v!) == null ? 'Invalid' : null,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: _lngController,
                                decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                  prefixIcon: Icon(Icons.east),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true, signed: true),
                                validator: (v) =>
                                    double.tryParse(v!) == null ? 'Invalid' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _contactController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _itemsController,
                          decoration: const InputDecoration(
                            labelText: 'Accepted Items (comma separated)',
                            hintText: 'e.g. Mobile, Laptop, Battery',
                            prefixIcon: Icon(Icons.devices),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: (_savedLocation == null && !_isSaving)
                                ? _saveFacility
                                : null,
                            icon: _isSaving && !_firestoreSaveSuccess
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(_savedLocation == null
                                    ? Icons.save
                                    : Icons.check_circle),
                            label: Text(
                              _savedLocation == null
                                  ? (_isSaving ? 'Saving...' : 'SAVE FACILITY')
                                  : 'FACILITY SAVED ✓',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _savedLocation == null
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Map Preview (appears immediately on save click) ────
                  if (_savedLocation != null) ...[
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Icon(Icons.map, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Facility Location Preview',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32)),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _firestoreSaveSuccess
                                ? Colors.green.shade100
                                : _isSaving
                                    ? Colors.blue.shade50
                                    : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSaving && !_firestoreSaveSuccess)
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5),
                                )
                              else
                                Icon(
                                  _firestoreSaveSuccess
                                      ? Icons.cloud_done
                                      : Icons.cloud_off,
                                  size: 12,
                                  color: _firestoreSaveSuccess
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                _firestoreSaveSuccess
                                    ? 'Saved'
                                    : _isSaving
                                        ? 'Saving...'
                                        : 'Local preview',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _firestoreSaveSuccess
                                      ? Colors.green.shade700
                                      : _isSaving
                                          ? Colors.blue.shade700
                                          : Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"$_savedFacilityName" pinned at:\n'
                      'Lat ${_savedLocation!.latitude.toStringAsFixed(5)}, '
                      'Lng ${_savedLocation!.longitude.toStringAsFixed(5)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 280,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _savedLocation!,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('saved_facility'),
                              position: _savedLocation!,
                              infoWindow: InfoWindow(
                                title: _savedFacilityName ?? 'Facility',
                                snippet: _cityController.text,
                              ),
                            ),
                          },
                          zoomControlsEnabled: true,
                          mapToolbarEnabled: false,
                          myLocationButtonEnabled: false,
                          compassEnabled: false,
                          liteModeEnabled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text('Add Another Facility'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _addressController.clear();
    _cityController.clear();
    _latController.clear();
    _lngController.clear();
    _contactController.clear();
    _itemsController.clear();
    setState(() {
      _savedLocation = null;
      _savedFacilityName = null;
      _firestoreSaveSuccess = false;
      _isSaving = false;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
}
