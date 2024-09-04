import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_colors.dart';
import '../../../l10n/app_localization.dart';
import '../../../locale_changes.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({super.key});

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  void _changeLanguage(Locale locale) {
    Provider.of<LocaleNotifier>(context, listen: false).setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = Provider.of<LocaleNotifier>(context).locale;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('change_language'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate('choose_language'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('English'),
              leading: Radio<Locale>(
                value: const Locale('en'),
                groupValue: locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    _changeLanguage(value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Español'),
              leading: Radio<Locale>(
                value: const Locale('es'),
                groupValue: locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    _changeLanguage(value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('മലയാളം'),
              leading: Radio<Locale>(
                value: const Locale('ml'),
                groupValue: locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    _changeLanguage(value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('العربية'),
              leading: Radio<Locale>(
                value: const Locale('ar'),
                groupValue: locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    _changeLanguage(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate('welcome_message'),
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            Text(
              '${AppLocalizations.of(context).translate('current_language')}: ${locale.languageCode == 'en' ? 'English' :
                  locale.languageCode == 'es' ? 'Español' :
                  locale.languageCode == 'ml' ? 'മലയാളം' : 'العربية'}',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
