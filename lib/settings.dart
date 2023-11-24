import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'user_changePassword.dart';

import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: Text('General'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  value: Text('English'),
                ),
              ],
            ),
            SettingsSection(
              title: Text('Account'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.password),
                  title: Text('Change password'),
                  onPressed: (context) async => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => UserChangePassword())),
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onPressed: (context) async => logout(context),
                ),
              ],
            ),
          ],
        ),
      );

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Login()));
  }
}
