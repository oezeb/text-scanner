import 'package:flutter/material.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/privacy_view.dart';
import 'package:text_scanner/views/widgets/ad_banner_widget.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          children: [
            const Divider(),
            SizedBox(
              height: 128,
              child: Image.asset("assets/logo-no-background.png"),
            ),
            const Divider(),
            ListTile(
              title: Text("v${versionName ?? '*.*.*'}"),
              onTap: () {},
              dense: true,
            ),
            const Divider(),
            ListTile(
              title: const Text("Privacy"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyView()),
                );
              },
              dense: true,
            ),
            const Divider(),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
