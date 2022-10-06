import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:text_scanner/utils.dart';
import 'package:text_scanner/views/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final _splashVM = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _splashVM.addListener(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeView(title: "Recents"),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class SplashViewModel extends ChangeNotifier {
  SplashViewModel() {
    _init();
  }

  Future<void> _init() async {
    await init();
    notifyListeners();
  }
}
