import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Introduction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Welcome to our doctor reporting mobile app. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us.',
            ),
            SizedBox(height: 16),
            Text(
              'Information We Collect',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We collect personal information that you voluntarily provide to us when registering at the app, expressing an interest in obtaining information about us or our products and services, when participating in activities on the app or otherwise contacting us.',
            ),
            SizedBox(height: 8),
            Text(
              'The personal information that we collect depends on the context of your interactions with us and the app, the choices you make and the products and features you use. The personal information we collect can include the following: name, email address, phone number, and other similar information.',
            ),
            SizedBox(height: 16),
            Text(
              'How We Use Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We use personal information collected via our app for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations.',
            ),
            SizedBox(height: 8),
            Text(
              'We use the information we collect or receive to: facilitate account creation and logon process, send you marketing and promotional communications, fulfill and manage your orders, post testimonials, request feedback, and to protect our services.',
            ),
            SizedBox(height: 16),
            Text(
              'Sharing Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We may process or share data based on the following legal basis: consent, legitimate interests, performance of a contract, legal obligations, and vital interests.',
            ),
            SizedBox(height: 8),
            Text(
              'We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.',
            ),
            SizedBox(height: 16),
            Text(
              'Security of Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We aim to protect your personal information through a system of organizational and technical security measures.',
            ),
            SizedBox(height: 16),
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'If you have questions or comments about this policy, you may contact us at: support@chaavie.com.',
            ),
            SizedBox(height: 16),
            Text(
              'Updates to This Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We may update this privacy policy from time to time in order to reflect changes to our practices or for other operational, legal, or regulatory reasons.',
            ),
          ],
        ),
      ),
    );
  }
}
