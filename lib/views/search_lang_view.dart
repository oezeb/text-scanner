import 'package:flutter/material.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/widgets/ad_banner_widget.dart';
import 'package:text_scanner/views/widgets/lang_widget.dart';

class SearchLangView extends StatefulWidget {
  const SearchLangView({super.key});

  @override
  State<SearchLangView> createState() => _SearchLangViewState();
}

class _SearchLangViewState extends State<SearchLangView> {
  final _controller = TextEditingController();
  late List<Lang> _langs;

  @override
  void initState() {
    _langs = LangManager.search(
      _controller.text,
      scanLanguages.values.toList(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: TextField(
          autofocus: true,
          controller: _controller,
          onChanged: (value) {
            setState(() {
              _langs = LangManager.search(
                _controller.text,
                scanLanguages.values.toList(),
              );
            });
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
                  _langs = LangManager.search(
                    _controller.text,
                    scanLanguages.values.toList(),
                  );
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
            child: ListView.builder(
              itemCount: _langs.length,
              itemBuilder: (context, index) => LangWidget(
                key: Key(_langs[index].code),
                lang: _langs[index],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
