
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';


import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Manual/provider/eventProvider.dart';
import 'package:rx_route_new/services/services.dart';

import 'New Rx Project/Manager/BottomNav/Travel plan/Manual/provider/DynamicFormProvider.dart';
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
  final apiService = ApiService(baseUrl:'http://52.66.145.37:3004' );

  // await AndroidAlarmManager.initialize();
  await _requestPermissions();
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_)=>LocaleNotifier(),),
      ChangeNotifierProvider(create: (_)=>EventProvider(apiService: apiService)),
      ChangeNotifierProvider(create: (_)=>DynamicFormProvider())
      // ChangeNotifierProvider(create: (_)=>AuthViewModel()),
    ],
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400
          ),
            child: const MyApp()),
      )));
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
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
            fontFamily: 'Inter',
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.whiteColor
          ),
          initialRoute: RoutesName.splash,
          onGenerateRoute: Routes.generateRoute,
        );
      }
    );
  }
}
