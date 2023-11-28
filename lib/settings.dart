import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'user_change_password.dart';

import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('settings_screen.title')),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(translate('settings_screen.general_settings.title')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language, color: Styles.primaryColor),
                title: Text(translate(
                    'settings_screen.general_settings.language_setting.name')),
                value: Text(translate('current_language')),
                onPressed: (context) async => changeLanguage(context),
              ),
              SettingsTile.navigation(
                leading: darkMode
                    ? const Icon(Icons.dark_mode, color: Styles.primaryColor)
                    : const Icon(Icons.light_mode, color: Styles.primaryColor),
                title: Text(translate(
                    'settings_screen.general_settings.dark_mode_setting.name')),
                value: Text(darkMode
                    ? translate(
                        'settings_screen.general_settings.dark_mode_setting.themes.dark')
                    : translate(
                        'settings_screen.general_settings.dark_mode_setting.themes.light')),
                onPressed: (context) async => await switchTheme(context),
              ),
            ],
          ),
          SettingsSection(
            title: Text(translate('settings_screen.account_settings.title')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.password, color: Styles.primaryColor),
                title: Text(translate(
                    'settings_screen.account_settings.change_password')),
                onPressed: (context) async => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const UserChangePassword())),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.logout, color: Styles.primaryColor),
                title:
                    Text(translate('settings_screen.account_settings.logout')),
                onPressed: (context) async => logout(() => Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const Login()))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future switchTheme(context) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setBool(
        'isDark', Theme.of(context).brightness == Brightness.light);

    Styles.changeBrightness!(Brightness.dark == Theme.of(context).brightness
        ? Brightness.light
        : Brightness.dark);
  }

  void showLanguageSwitcher(
      {required BuildContext context, required Widget child}) {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => child).then((String? value) {
      if (value != null) changeLocale(context, value);
    });
  }

  void changeLanguage(BuildContext context) {
    showLanguageSwitcher(
      context: context,
      child: CupertinoActionSheet(
        title: Text(translate(
            'settings_screen.general_settings.language_setting.dialog.title')),
        message: Text(translate(
            'settings_screen.general_settings.language_setting.dialog.message')),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(translate(
                'settings_screen.general_settings.language_setting.language.en')),
            onPressed: () async {
              await saveLocale('en', context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(translate(
                'settings_screen.general_settings.language_setting.language.de')),
            onPressed: () async {
              await saveLocale('de', context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, null),
          child: Text(translate(
              'settings_screen.general_settings.language_setting.cancel_button')),
        ),
      ),
    );
  }

  Future saveLocale(String locale, context) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setString('language', locale);

    final snackBar = SnackBar(
      content: Text(translate(
          'settings_screen.general_settings.language_setting.restart_app_notification')),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Navigator.pop(context, locale);
  }

  Future<void> logout(Function done) async {
    await FirebaseAuth.instance.signOut();
    done();
  }
}
