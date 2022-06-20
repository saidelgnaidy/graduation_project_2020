import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sanai3i/app_locales.dart';
import 'package:sanai3i/files/database.dart';
import 'package:sanai3i/files/landing.dart';
import 'package:sanai3i/files/reusable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'files/main_navigation.dart';

String? selectedCode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Sanai3i());
}

class Sanai3i extends StatefulWidget {
  const Sanai3i({Key? key}) : super(key: key);

  @override
  _Sanai3iState createState() => _Sanai3iState();
}

class _Sanai3iState extends State<Sanai3i> {
  @override
  void initState() {
    loadLang();
    super.initState();
  }

  void loadLang() async {
    SharedPreferences getLangCode = await SharedPreferences.getInstance();
    var value = getLangCode.getString('langCode');
    setState(() {
      selectedCode = value;
    });
  }

  Future<bool> saveLang(String code) async {
    SharedPreferences saveLangCode = await SharedPreferences.getInstance();
    return await saveLangCode.setString('langCode', code);
  }

  @override
  Widget build(BuildContext context) {
    return selectedCode != null
        ? GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasFocus) {
                currentFocus.unfocus();
              }
            },
            child: StreamProvider<User?>.value(
              value: DatabaseService().userState,
              initialData: null,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'صنايعي',
                theme: ThemeData(fontFamily: 'TajawalRegular'),
                home: selectedCode != null
                    ? const Wrapper()
                    : Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FadeY(
                                delay: 0.0,
                                duration: const Duration(milliseconds: 350),
                                child: AnimatedContainer(
                                  curve: Curves.easeOutBack,
                                  height: 150,
                                  duration: const Duration(milliseconds: 400),
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'images/sanai3i.png',
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              FadeX(
                                delay: 0.1,
                                duration: const Duration(milliseconds: 300),
                                child: SizedBox(
                                  width: 200,
                                  child: RaisedButton(
                                    color: kActiveBtnColor,
                                    shape: const StadiumBorder(),
                                    child: const Text(
                                      'العربية',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        saveLang('ar');
                                        selectedCode = 'ar';
                                      });
                                    },
                                  ),
                                ),
                              ),
                              FadeX(
                                delay: 0.2,
                                duration: const Duration(milliseconds: 300),
                                child: SizedBox(
                                  width: 200,
                                  child: RaisedButton(
                                    color: kActiveBtnColor,
                                    shape: const StadiumBorder(),
                                    child: const Text(
                                      'English',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        saveLang('en');
                                        selectedCode = 'en';
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                supportedLocales: const [
                  Locale('ar', ''),
                  Locale('en', ''),
                ],
                localizationsDelegates: const [GlobalMaterialLocalizations.delegate, AppLocale.delegate],
                localeResolutionCallback: (currentLocale, supportedLocales) {
                  if (selectedCode != null) {
                    return Locale(selectedCode!, '');
                  } else {
                    print('else');
                    if (currentLocale != null) {
                      for (Locale locale in supportedLocales) {
                        if (locale.languageCode == currentLocale.languageCode) return currentLocale;
                      }
                    }
                    if (supportedLocales.contains(currentLocale)) {
                      return currentLocale;
                    } else {
                      return supportedLocales.first;
                    }
                  }
                },
              ),
            ),
          )
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'TajawalRegular'),
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeY(
                      delay: 0.0,
                      duration: const Duration(milliseconds: 350),
                      child: AnimatedContainer(
                        curve: Curves.easeOutBack,
                        height: 150,
                        duration: const Duration(milliseconds: 400),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'images/sanai3i.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    FadeX(
                      delay: 0.1,
                      duration: const Duration(milliseconds: 300),
                      child: SizedBox(
                        width: 200,
                        child: RaisedButton(
                          color: kActiveBtnColor,
                          shape: const StadiumBorder(),
                          child: const Text(
                            'العربية',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              saveLang('ar');
                              selectedCode = 'ar';
                            });
                          },
                        ),
                      ),
                    ),
                    FadeX(
                      delay: 0.2,
                      duration: const Duration(milliseconds: 300),
                      child: SizedBox(
                        width: 200,
                        child: RaisedButton(
                          color: kActiveBtnColor,
                          shape: const StadiumBorder(),
                          child: const Text(
                            'English',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              saveLang('en');
                              selectedCode = 'en';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? userState = Provider.of<User?>(context);
    if (userState == null) {
      return LoginScreen();
    } else {
      return MainNavigation();
    }
  }
}
