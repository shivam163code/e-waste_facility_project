import 'package:flutter/material.dart';
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

  Future<void> _saveFacility() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final newCenter = EwasteCenter(
        id: '', // Firestore will generate this
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
        contact: _contactController.text,
        acceptedItems: _itemsController.text.split(',').map((e) => e.trim()).toList(),
      );

      try {
        await _firestoreService.addCenter(newCenter);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facility added successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add E-Waste Facility'),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Facility Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) => double.tryParse(v!) == null ? 'Invalid' : null,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            controller: _lngController,
                            decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) => double.tryParse(v!) == null ? 'Invalid' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _itemsController,
                      decoration: const InputDecoration(
                        labelText: 'Accepted Items (comma separated)',
                        hintText: 'e.g. Mobile, Laptop, Battery',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveFacility,
                        child: const Text('SAVE FACILITY'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
