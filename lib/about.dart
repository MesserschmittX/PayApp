import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:paysnap/styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(translate("about_screen.title"))),
        body: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  translate('about_screen.headline1'),
                  style: Styles.aboutHeadline,
                ),
                const SizedBox(height: 10),
                Text(
                  translate('about_screen.description1.1'),
                  style: Styles.aboutText,
                ),
                Text(
                  translate('about_screen.description1.2'),
                  style: Styles.aboutText,
                ),
                Text(
                  translate('about_screen.description1.3'),
                  style: Styles.aboutText,
                ),
                const SizedBox(height: 15),
                SizedBox(
                    width: 150,
                    height: 50,
                    child: Image.asset(
                      'assets/images/bosch_logo.png',
                      alignment: Alignment.centerLeft,
                    )),
                const SizedBox(height: 35),
                Text(
                  translate('about_screen.headline2'),
                  style: Styles.aboutHeadline,
                ),
                const SizedBox(height: 10),
                Text(
                  translate('about_screen.description2.1'),
                  style: Styles.aboutText,
                ),
                Text(
                  translate('about_screen.description2.2'),
                  style: Styles.aboutText,
                ),
                Text(
                  translate('about_screen.description2.3'),
                  style: Styles.aboutText,
                ),
                const SizedBox(height: 15),
                SizedBox(
                    width: 170,
                    height: 50,
                    child: Image.asset(
                      'assets/images/dhbw_cas_logo.png',
                      alignment: Alignment.centerLeft,
                    )),
                const SizedBox(height: 35),
                Text(
                  translate('about_screen.headline3'),
                  style: Styles.aboutHeadline,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                Text(
                  translate('about_screen.description3.1'),
                  style: Styles.aboutText,
                  textAlign: TextAlign.left,
                ),
              ],
            )),
      );
}
