import 'package:flutter/material.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/item_view.dart';
import 'package:text_scanner/views/widgets/ad_banner_widget.dart';
import 'package:text_scanner/views/widgets/item_widget.dart';

class SearchItemView extends StatefulWidget {
  const SearchItemView({super.key});

  @override
  State<SearchItemView> createState() => _SearchItemViewState();
}

class _SearchItemViewState extends State<SearchItemView> {
  final _controller = TextEditingController();

  _onTap(Item item, bool? selected) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemView(item: item)),
    );
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
      body: Column(children: [
        const Divider(),
        Expanded(
          child: FutureBuilder(
            future: itemsdb.search(_controller.text),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final items = snapshot.data as List<Item>;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => ItemWidget(
                    item: items[index],
                    onTap: _onTap,
                  ),
                );
              } else {
                return Column(
                  children: const [
                    LinearProgressIndicator(),
                  ],
                );
              }
            },
          ),
        ),
      ]),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
