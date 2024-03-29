import 'package:flutter/material.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/about_view.dart';
import 'package:text_scanner/views/lang_manager_view.dart';
import 'package:text_scanner/views/widgets/ad_banner_widget.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.grey[900],
      ),
      body: Column(children: [
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Manage languages"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LangManagerView()),
                  );
                },
                dense: true,
              ),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text("Rate us"),
                onTap: () {
                  Channel.openUrl(PLAY_STORE_URL);
                },
                dense: true,
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Share with Friends"),
                onTap: () {
                  Channel.shareText(PLAY_STORE_URL);
                },
                dense: true,
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("About"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutView()),
                  );
                },
                dense: true,
              ),
            ],
          ),
        )
      ]),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
