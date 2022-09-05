import 'package:flutter/material.dart';
import 'package:text_scanner/database.dart';
import 'package:text_scanner/models.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/item_view.dart';
import 'package:text_scanner/views/search_item_view.dart';
import 'package:text_scanner/views/setting_view.dart';
import 'package:text_scanner/views/widgets/floating_button_widget.dart';
import 'package:text_scanner/views/widgets/item_widget.dart';
import 'package:text_scanner/views/widgets/multi_select_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.title});
  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _multiSelect = false;
  String _selected = "";

  _onTap(Item item, bool? selected) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemView(item: item)),
    );
  }

  _onLongPress(Item item, bool? selected) {
    setState(() {
      _selected = item.id;
      _multiSelect = true;
    });
  }

  @override
  void initState() {
    super.initState();
    itemsdb.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_multiSelect) {
          setState(() {
            _multiSelect = false;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _multiSelect
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _multiSelect = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back))
              : null,
          title: Text(widget.title),
          actions: _multiSelect
              ? []
              : [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingView(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: Colors.grey[900],
        ),
        body: Center(
          child: _multiSelect
              ? FutureBuilder(
                  future: itemsdb.get(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return MultiSelectWidget(
                        all: snapshot.data as List<Item>,
                        selected: {_selected},
                        onEmptyList: () {
                          setState(() {
                            _multiSelect = false;
                          });
                        },
                      );
                    } else {
                      return const LinearProgressIndicator();
                    }
                  }),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchItemView(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            Text(
                              "Search",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: FutureBuilder(
                        future: itemsdb.get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final items = snapshot.data as List<Item>;
                            return ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) => ItemWidget(
                                item: items[index],
                                onTap: _onTap,
                                onLongPress: _onLongPress,
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
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _multiSelect ? null : const FloatingButton(),
      ),
    );
  }
}
