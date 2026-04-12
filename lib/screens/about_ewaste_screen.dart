import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AboutEwasteScreen extends StatelessWidget {
  const AboutEwasteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About E-Waste'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSectionTitle('What is E-Waste?'),
            _buildDescription(
              'Electronic waste (e-waste) refers to any discarded electronic or electrical devices. '
              'It includes everything from old computers, smartphones, and televisions to kitchen appliances like '
              'microwaves and kettles.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Why is it a Problem?'),
            _buildDescription(
              'E-waste contains hazardous materials like lead, mercury, and cadmium. '
              'If disposed of improperly in landfills, these toxins can leak into the soil and water, '
              'posing serious risks to human health and the environment.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('How can you help?'),
            _buildHelpItem(
              Icons.recycling,
              'Use Authorized Centers',
              'Always dispose of your electronics at authorized e-waste collection centers found on this app.',
            ),
            _buildHelpItem(
              Icons.sell,
              'Donate or Sell',
              'If your device still works, consider donating it or selling it instead of throwing it away.',
            ),
            _buildHelpItem(
              Icons.eco,
              'Buy Sustainable',
              'Choose products from companies that offer recycling programs and use fewer toxic chemicals.',
            ),
            const SizedBox(height: 30),
            Center(
              child: Image.network(
                'https://images.unsplash.com/photo-1591391516391-47dadff171ce?q=80&w=1000&auto=format&fit=crop',
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'E-waste is one of the fastest growing waste streams globally.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDescription(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
