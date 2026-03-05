import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import 'features/splash/splash_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/cycles/pages/cycle_detail_page.dart';
import 'features/public_laudo/pages/laudo_public_page.dart';
import 'features/cycles/repositories/cycles_repository.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _listenDeepLinks();
  }

  void _listenDeepLinks() {
    _appLinks.uriLinkStream.listen(
      (uri) {
        try {
          // =========================
          // DEEP LINK INTERNO (APP)
          // sterilink://cycle/123
          // =========================
          if (uri.scheme == 'sterilink' &&
              uri.host == 'cycle' &&
              uri.pathSegments.isNotEmpty) {
            final cycleNumber = uri.pathSegments.first;

            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) =>
                    CycleDetailPage.fromDeepLink(cycleNumber),
              ),
            );
            return;
          }

          // =========================
          // URL PÚBLICA DO LAUDO
          // https://sterilink.app/laudo/{id}
          // =========================
          if (uri.scheme == 'https' &&
              uri.host == 'sterilink.app' &&
              uri.pathSegments.length >= 2 &&
              uri.pathSegments.first == 'laudo') {
            final id = uri.pathSegments[1];

            final cycle =
                CyclesRepository.instance.findById(id);

            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) =>
                    LaudoPublicPage.fromCycle(cycle),
              ),
            );
          }
        } catch (e) {
          debugPrint('Erro ao processar deep link: $e');
        }
      },
      onError: (err) {
        debugPrint('Erro no stream de deep link: $err');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
