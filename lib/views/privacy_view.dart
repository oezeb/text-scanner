import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/widgets/ad_banner_widget.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          const Divider(),
          Expanded(
            child: FutureBuilder(
              future: rootBundle.loadString("assets/privacy-policy.md"),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data as String,
                    onTapLink: (text, href, title) {
                      if (href != null) Channel.openUrl(href);
                    },
                  );
                } else {
                  return const LinearProgressIndicator();
                }
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
