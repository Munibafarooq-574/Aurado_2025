import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/ color_utils.dart';
import '../providers/preferences_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
            letterSpacing: 1.1,
          ),
        ),
        backgroundColor: fromHex(prefs.themeColor), // Matches body background
        elevation: 0, // Removes shadow to avoid box-like appearance
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: fromHex(prefs.themeColor),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100), // Padding so content isn't hidden by button
                child: Container(
                  decoration: BoxDecoration(
                    color: null, // Removed background color to avoid box effect
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: const Text(
                          'Last Updated: August 09, 2025',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._buildPrivacyPoints(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF800000).withOpacity(0.4),
                  ),
                  child: const Text(
                    'Accept Policy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPrivacyPoints() {
    final privacyPoints = [
      {
        'title': '1. Information We Collect',
        'content':
        'We collect information you provide, such as your name, email, and task data, to enhance your experience with Aurado.',
      },
      {
        'title': '2. How We Use Your Information',
        'content':
        'We use your data to provide, maintain, and improve our services, and to personalize your experience within the app.',
      },
      {
        'title': '3. Data Sharing',
        'content':
        'We do not sell your personal information. Data may be shared with service providers or as required by law.',
      },
      {
        'title': '4. Security',
        'content':
        'We implement reasonable security measures to protect your data, though no method is 100% secure.',
      },
      {
        'title': '5. User Rights',
        'content':
        'You have the right to access, correct, or delete your personal data. Contact us to exercise these rights.',
      },
      {
        'title': '6. Cookies',
        'content':
        'We use cookies to enhance functionality and analyze usage. You can manage cookie preferences in your browser settings.',
      },
      {
        'title': '7. Changes to Policy',
        'content':
        'We may update this Privacy Policy. Significant changes will be communicated to you via the app.',
      },
      {
        'title': '8. Contact Us',
        'content':
        'For questions or concerns, reach out to us at munibaawan574@gmail.com.',
      },
    ];

    return privacyPoints
        .map(
          (point) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Color(0xFF4A4A4A), height: 1.4),
            children: [
              TextSpan(
                text: '${point['title']}\n',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800000)),
              ),
              TextSpan(text: point['content']),
            ],
          ),
        ),
      ),
    )
        .toList();
  }
}