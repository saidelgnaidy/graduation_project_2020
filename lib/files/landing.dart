import 'package:flutter/material.dart';
import 'package:sanai3i/files/reusable.dart';

import 'login_signup.dart';
import 'settings.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  int bottomIndex = 1;
  double logoH = 150;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenData = MediaQuery.of(context);

    Widget _buildContent(BuildContext context) {
      switch (bottomIndex) {
        case 0:
          return SignUp();
        case 1:
          return const Login();
        default:
          return const Text('Error 404');
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffE4E6EB),
        body: Column(
          children: <Widget>[
            const SizedBox(height: 28),
            Expanded(
              child: Container(
                width: screenData.size.width,
                margin: const EdgeInsets.fromLTRB(6, 0, 6, 2),
                decoration: containerDecoration(const Color(0xffF6F6F6)),
                child: Column(
                  children: <Widget>[
                    FadeY(
                      delay: 0.0,
                      duration: const Duration(milliseconds: 350),
                      child: AnimatedContainer(
                        width: screenData.size.width,
                        curve: Curves.easeOutBack,
                        height: logoH,
                        duration: const Duration(milliseconds: 400),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                'images/sanai3i.png',
                              ),
                              fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    _buildContent(context),
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        bottomIndex = 1;
                        logoH = 180;
                      });
                    },
                    child: AnimatedContainer(
                      margin: const EdgeInsets.fromLTRB(10, 3, 10, 5),
                      height: 35,
                      duration: const Duration(milliseconds: 450),
                      decoration: btnDecoration(bottomIndex == 1 ? kActiveBtnColor : Colors.white, 30),
                      curve: Curves.easeOutBack,
                      child: Center(
                        child: Text(
                          lang(context, 'currentAcc')!,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: bottomIndex == 1 ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        bottomIndex = 0;
                        logoH = 120;
                      });
                    },
                    child: AnimatedContainer(
                      margin: const EdgeInsets.fromLTRB(10, 3, 10, 5),
                      height: 35,
                      duration: const Duration(milliseconds: 450),
                      decoration: btnDecoration(bottomIndex == 0 ? kActiveBtnColor : Colors.white, 30),
                      curve: Curves.easeOutBack,
                      child: Center(
                        child: Text(
                          lang(context, 'newAcc')!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: bottomIndex == 0 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
