import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iam_relawan/routing/app_router.dart';
import 'package:iam_relawan/ui/core/themes/app_theme.dart';
import 'package:iam_relawan/ui/core/themes/util.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Inter", "Montserrat");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: theme.light(),
      routerConfig: router,
      // showSemanticsDebugger: true,
    );
  }
}
