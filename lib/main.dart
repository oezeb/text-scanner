import 'package:flutter/material.dart';
import 'package:text_scanner/data.dart';
import 'package:text_scanner/item.dart';
import 'package:text_scanner/widgets/item_widget.dart';
import 'package:text_scanner/widgets/multi_select_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Recents'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _multiSelect = false;
  String _selected = "";

  _onTap(Item item, bool? selected) {}

  _onLongPress(Item item, bool? selected) {
    setState(() {
      _selected = item.id;
      _multiSelect = true;
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
                  icon: Icon(Icons.arrow_back))
              : null,
          title: Text(widget.title),
          actions: _multiSelect
              ? []
              : [
                  IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
                ],
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: Colors.grey[900],
        ),
        body: Center(
          child: _multiSelect
              ? FutureBuilder(
                  future: getItems(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return MultiSelectWidget(
                        all: snapshot.data as List<Item>,
                        selected: {_selected},
                      );
                    } else {
                      return LinearProgressIndicator();
                    }
                  }),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          fillColor: Colors.grey[300],
                          filled: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 5, 10, 10),
                          hintText: "Search",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child:
                              Row(children: [Icon(Icons.sort), Text("Sort")]),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                    Divider(),
                    Expanded(
                      child: FutureBuilder(
                        future: getItems(),
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
                            return LinearProgressIndicator();
                          }
                        },
                      ),
                    )
                  ],
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _multiSelect
            ? null
            : FloatingActionButton(
                onPressed: () {},
                tooltip: 'Increment',
                child: const Icon(
                  Icons.add,
                  size: 40,
                ),
              ),
      ),
    );
  }
}
