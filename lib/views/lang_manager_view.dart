import 'package:flutter/material.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/search_lang_view.dart';
import 'package:text_scanner/views/widgets/lang_widget.dart';

class LangManagerView extends StatefulWidget {
  const LangManagerView({super.key});

  @override
  State<LangManagerView> createState() => _LangManagerViewState();
}

class _LangManagerViewState extends State<LangManagerView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Languages"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchLangView()),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          const Divider(),
          Expanded(
            child: FutureBuilder(
              future: LangManager.languages,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var langs = snapshot.data as List<Lang>;
                  return ListView.builder(
                    itemCount: langs.length,
                    itemBuilder: (context, index) => LangWidget(
                      name: langs[index].name,
                      code: langs[index].code,
                    ),
                  );
                } else {
                  return const LinearProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
