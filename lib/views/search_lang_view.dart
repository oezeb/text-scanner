import 'package:flutter/material.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/widgets/lang_widget.dart';

class SearchLangView extends StatefulWidget {
  const SearchLangView({super.key});

  @override
  State<SearchLangView> createState() => _SearchLangViewState();
}

class _SearchLangViewState extends State<SearchLangView> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: TextField(
          autofocus: true,
          controller: _controller,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: "Search",
            contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            fillColor: Colors.grey[200],
            filled: true,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _controller.text = "";
                });
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          const Divider(),
          Expanded(
            child: FutureBuilder(
              future: LangManager.search(_controller.text),
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
