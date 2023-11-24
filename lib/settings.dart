import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'login.dart';
import 'user_changePassword.dart';

import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                leading: Icon(Icons.language),
                title: Text(translate(
                    'settings_screen.general_settings.language_setting.name')),
                value: Text(translate('current_language')),
                onPressed: (context) async => changeLanguage(context),
              ),
            ],
          ),
          SettingsSection(
            title: Text(translate('settings_screen.account_settings.title')),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.password),
                title: Text(translate(
                    'settings_screen.account_settings.change_password')),
                onPressed: (context) async => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => UserChangePassword())),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.logout),
                title:
                    Text(translate('settings_screen.account_settings.logout')),
                onPressed: (context) async => logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showDemoActionSheet(
      {required BuildContext context, required Widget child}) {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => child).then((String? value) {
      if (value != null) changeLocale(context, value);
    });
  }

  void changeLanguage(BuildContext context) {
    showDemoActionSheet(
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
            onPressed: () => Navigator.pop(context, 'en'),
          ),
          CupertinoActionSheetAction(
            child: Text(translate(
                'settings_screen.general_settings.language_setting.language.de')),
            onPressed: () => Navigator.pop(context, 'de'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate(
              'settings_screen.general_settings.language_setting.cancel_button')),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Login()));
  }
}
