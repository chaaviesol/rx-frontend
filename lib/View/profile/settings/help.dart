import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../app_colors.dart';
import '../../../constants/styles.dart'; // for launching links

class HelpCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Help Center',
          style: text60017black,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // FAQ Section
          Text(
            'Frequently Asked Questions (FAQs)',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          ExpansionTile(
            title: Text('What kind of reports can I submit?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You can submit reports on a variety of medical field observations, including medication errors, equipment malfunctions, and safety hazards.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I submit a report?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Follow these steps to submit a report: \n 1. Tap the "+" button. \n 2. Fill out the report form with details of the observation. \n 3. Attach photos or documents if necessary. \n 4. Submit the report.',
                ),
              ),
            ],
          ),
          // Additional Help Resources
          SizedBox(height: 16.0),
          Text(
            'Additional Resources',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          ListTile(
            title: Text('User Manual'),
            trailing: Icon(Icons.arrow_right),
            onTap: () => launch('https://www.bmsd.net/teleworking-tools-google-drive-guide.pdf'), // Replace with your actual user manual link
          ),
          ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_right),
            onTap: () => launch('https://mailchimp.com/resources/how-to-write-a-privacy-policy/'), // Replace with your privacy policy link
          ),
          ListTile(
            title: Text('Contact Support'),
            trailing: Icon(Icons.arrow_right),
            onTap: () => launch('mailto:admin@chaavie.com'), // Replace with your support email
          ),
        ],
      ),
    );
  }
}