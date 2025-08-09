import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
            letterSpacing: 1.1,
          ),
        ),
        backgroundColor: const Color(0xFFfbeee6), // Matches body background
        elevation: 0, // Removes shadow to avoid box-like appearance
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFfbeee6),
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
                      ..._buildTermsPoints(),
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
                    'Accept Terms',
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

  List<Widget> _buildTermsPoints() {
    final terms = [
      {
        'title': '1. Acceptance of Terms',
        'content':
        'By using the Aurado app, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.',
      },
      {
        'title': '2. User Responsibilities',
        'content':
        'Users are responsible for:\n• Providing accurate information during registration.\n• Maintaining the confidentiality of their account credentials.\n• Using the app in compliance with all applicable laws.',
      },
      {
        'title': '3. Service Usage',
        'content':
        'Aurado provides task management and organization tools. We reserve the right to modify or discontinue the service at any time without prior notice.',
      },
      {
        'title': '4. Privacy',
        'content':
        'Your privacy is important. Please review our Privacy Policy to understand how we collect and use your data.',
      },
      {
        'title': '5. Termination',
        'content':
        'We may terminate or suspend your account if you violate these terms. Upon termination, your access to the app will be revoked.',
      },
      {
        'title': '6. Intellectual Property',
        'content':
        'All content and designs in Aurado are the property of the app developers and protected by copyright laws. Unauthorized use is prohibited.',
      },
      {
        'title': '7. Limitation of Liability',
        'content':
        'Aurado is provided "as is" without warranties. We are not liable for any indirect damages arising from the use or inability to use the app.',
      },
      {
        'title': '8. Governing Law',
        'content':
        'These terms are governed by the laws of the jurisdiction where the app is registered. Any disputes will be resolved in that jurisdiction’s courts.',
      },
    ];

    return terms
        .map(
          (term) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Color(0xFF4A4A4A), height: 1.4),
            children: [
              TextSpan(
                text: '${term['title']}\n',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800000)),
              ),
              TextSpan(text: term['content']),
            ],
          ),
        ),
      ),
    )
        .toList();
  }
}