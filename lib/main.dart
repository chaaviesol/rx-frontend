
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


import 'package:flutter_localizations/flutter_localizations.dart';

import 'Util/Routes/routes.dart';
import 'Util/Routes/routes_name.dart';
import 'app_colors.dart';
import 'l10n/app_localization.dart';
import 'locale_changes.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> _requestPermissions() async {
  // Request permission to show notifications
  await Permission.notification.request();
  // Add more permissions as needed
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await AndroidAlarmManager.initialize();
  await _requestPermissions();
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_)=>LocaleNotifier(),),
      // ChangeNotifierProvider(create: (_)=>AuthViewModel()),
    ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleNotifier>(
      builder: (context,localeNotifer,child) {
        return MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('ml'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
          title: 'RXROUTE',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          initialRoute: RoutesName.splash,
          onGenerateRoute: Routes.generateRoute,
        );
      }
    );
  }
}
