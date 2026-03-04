import 'package:ai_movie_suggestion/presentation/resources/assets_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for opening URLs

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE94057); // Example primary color
    const Color secondaryBlack = Color(0xFF222222);
    const Color whiteColor = Colors.white;

    // Function to launch URLs
    Future<void> _launchUrl(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              Align(
                alignment: Alignment.center,
                child: Text(AppStrings.contactMe,
                    style: Theme.of(context).textTheme.headlineLarge),
              ),
              const SizedBox(height: 80),

              const CircleAvatar(
                radius: 100,
                // Replace with your image asset or network image
                backgroundImage: AssetImage(ImagesAssets.meImage),
                backgroundColor: primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ahmed Khaled Shehab',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: whiteColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Software Developer',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Contact Information Section
              _buildContactItem(
                context,
                icon: Icons.link,
                title: 'LinkedIn',
                subtitle: 'linkedin.com/in/ahmed-shehab-6767652b3/',
                onTap: () => _launchUrl(
                    'https://www.linkedin.com/in/ahmed-shehab-6767652b3/'),
              ),
              const Divider(color: Colors.grey, height: 1),
              _buildContactItem(
                context,
                icon: Icons.code,
                title: 'GitHub',
                subtitle: 'github.com/Ahmed1shehab',
                onTap: () => _launchUrl('https://github.com/Ahmed1shehab'),
              ),
              const Divider(color: Colors.grey, height: 1),
              _buildContactItem(
                context,
                icon: Icons.email,
                title: 'Email',
                subtitle: 'ahmed.shehab.7355@gmail.com',
                onTap: () => _launchUrl('mailto:ahmed.shehab.7355@gmail.com'),
              ),
              const Divider(color: Colors.grey, height: 1),
              _buildContactItem(
                context,
                icon: Icons.phone,
                title: 'Phone',
                subtitle: '+20 155 042 7589',
                onTap: () => _launchUrl('tel:+201550427589'),
              ),
              const Divider(color: Colors.grey, height: 1),
              _buildContactItem(
                context,
                icon: Icons.link,
                title: 'LeetCode',
                subtitle: 'leetcode.com/u/AhmedShehab21/',
                onTap: () =>
                    _launchUrl('https://leetcode.com/u/AhmedShehab21/'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each contact list item
  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }
}
