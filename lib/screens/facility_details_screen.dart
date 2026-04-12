import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ewaste_center.dart';

class FacilityDetailsScreen extends StatelessWidget {
  final EwasteCenter center;

  const FacilityDetailsScreen({super.key, required this.center});

  Future<void> _launchNavigation() async {
    final url = 'google.navigation:q=${center.latitude},${center.longitude}';
    final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=${center.latitude},${center.longitude}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
      await launchUrl(Uri.parse(fallbackUrl));
    } else {
      throw 'Could not launch navigation.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(center.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center Header Card
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.business, size: 60, color: Color(0xFF2E7D32)),
                    const SizedBox(height: 10),
                    Text(
                      center.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Details Section
            _buildInfoRow(context, Icons.location_on, 'Address', center.address),
            _buildInfoRow(context, Icons.location_city, 'City', center.city),
            _buildInfoRow(context, Icons.phone, 'Contact', center.contact),
            
            const SizedBox(height: 20),
            Text(
              'Accepted Items',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: center.acceptedItems.map((item) => Chip(
                label: Text(item),
                backgroundColor: const Color(0xFFE8F5E9),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              )).toList(),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _launchNavigation,
                icon: const Icon(Icons.directions),
                label: const Text(
                  'GET DIRECTIONS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
