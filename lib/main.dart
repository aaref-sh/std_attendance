import 'package:flutter/material.dart';
import 'package:std_attendance/routes/login.dart';
import 'package:std_attendance/routes/scan_code.dart';
import 'package:std_attendance/routes/select_session.dart';
import 'package:std_attendance/shared/components/base_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: <String, WidgetBuilder>{
        'loading': (BuildContext context) => const BaseRoute(
              body: LoadingScreen(),
              routeName: "الدخول",
              icon: Icons.lock_open_outlined,
            ),
        'scan': (BuildContext context) => const BaseRoute(
            body: Scan(),
            routeName: "مسح",
            icon: Icons.qr_code_scanner_outlined),
        'selectsession': (BuildContext context) => const BaseRoute(
            body: SelectSession(),
            routeName: "اختيار جلسة",
            icon: Icons.task_outlined),
      },
      home: const BaseRoute(
        body: LoadingScreen(fromHome: true),
        icon: Icons.lock_open_outlined,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
