import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanai3i/files/reusable.dart';

import 'database.dart';
import 'settings.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? _phone, _token;
  String? errorDetails = '';
  bool phoneValidationError = false;
  bool firebaseNetError = false;
  bool firebasePhoneFormatError = false;
  bool invalidToken = false;
  String? cCode;
  final _formKey = GlobalKey<FormState>();

  Future loginWithPhone(String? phone) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
      phoneNumber: '$cCode$_phone',
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);

        Navigator.pop(context);
      },
      verificationFailed: (var authException) {
        if (authException.message == 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.') {
          setState(() {
            firebaseNetError = true;
            loading = false;
          });
        }
        if (authException.code == 'invalidCredential') {
          setState(() {
            phoneValidationError = true;
            errorDetails = lang(context, 'phoneNotCorrect');
            loading = false;
          });
        }
      },
      codeSent: (String verificationId, [int? forceResendToken]) {
        setState(() => loading = false);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Center(child: Text(lang(context, 'validation')!)),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFieldReusable(
                          hintOfTextFiled: lang(context, 'validationKey'),
                          onChanged: (token) => _token = token,
                          keyboardType: TextInputType.phone,
                          length: 6,
                        ),
                        invalidToken == true ? Text(lang(context, 'ensureKey')!) : const SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              color: kActiveBtnColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                lang(context, 'cancel')!,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                            RaisedButton(
                              color: kActiveBtnColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                lang(context, 'checkKey')!,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                  Future.delayed(const Duration(seconds: 5)).then((value) => loading = false);
                                });
                                try {
                                  AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: _token!);
                                  var result = await _auth.signInWithCredential(credential);

                                  if (result.user != null) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  setState(() {
                                    invalidToken = true;
                                    loading = false;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        loading == true ? const CircularProgressIndicator() : const SizedBox(),
                      ],
                    );
                  },
                ),
              );
            });
      },
      codeAutoRetrievalTimeout: (codeRetrieval) {
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 60),
              FadeY(
                duration: const Duration(milliseconds: 200),
                delay: 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 35,
                      width: 55,
                      decoration: roundedContainerDecoration(kActiveBtnColor),
                      child: CountryCodePicker(
                        onChanged: (code) {
                          cCode = code.dialCode;
                        },
                        showFlag: false,
                        hideSearch: true,
                        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        initialSelection: 'EG',
                        favorite: const ['SA', 'EG', 'AE', 'SY', 'OM', 'MC', 'KW', 'JO', 'IR', 'IQ', 'PS', 'QA', 'BH', 'YE', 'TN', 'DZ', 'LB', 'LY'],
                        showFlagDialog: true,
                        comparator: (a, b) => b.name!.compareTo(a.name!),
                        onInit: (code) {
                          cCode = code!.dialCode;
                        },
                      ),
                    ),
                    TextFieldReusable(
                      hintOfTextFiled: lang(context, 'phone'),
                      onSaved: (_phoneSignup) {
                        _phone = "$_phoneSignup";
                      },
                      keyboardType: TextInputType.phone,
                      length: 50,
                      validator: (value) {
                        setState(() {
                          value!.isEmpty ? phoneValidationError = true : phoneValidationError = false;
                        });
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              phoneValidationError == false
                  ? const SizedBox()
                  : Text(
                      errorDetails!,
                      style: const TextStyle(color: Colors.red),
                    ),
              firebasePhoneFormatError == false
                  ? const SizedBox()
                  : Text(
                      lang(context, 'phoneNotCorrect')!,
                      style: const TextStyle(color: Colors.red),
                    ),
              FadeY(
                duration: const Duration(milliseconds: 200),
                delay: 0.4,
                child: SizedBox(
                  width: 120,
                  height: 35,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    color: kActiveBtnColor,
                    onPressed: () async {
                      _formKey.currentState!.validate();
                      if (phoneValidationError == false) {
                        _formKey.currentState!.save();
                        loading = true;
                        try {
                          await DatabaseService().ifAPhoneNumberRegistered(_phone).then((QuerySnapshot doc) {
                            if (doc.docs.isEmpty) {
                              setState(() {
                                phoneValidationError = true;
                                errorDetails = lang(context, 'notRegistered');
                                loading = false;
                              });
                            } else if (doc.docs.isNotEmpty) {
                              loginWithPhone(_phone);
                            } else if (doc == null) {
                              loading = false;
                              print('doc is null *******');
                            }
                          });
                        } catch (e) {
                          setState(() {
                            loading = false;
                            firebaseNetError = true;
                            errorDetails = lang(context, 'checkConnection');
                          });
                          print('******** $e');
                        }
                      } else {
                        setState(() {
                          errorDetails = lang(context, 'required');
                        });
                      }
                    },
                    child: Center(
                      child: loading == false
                          ? Text(
                              lang(context, 'login')!,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : AnimatedContainer(
                              duration: const Duration(milliseconds: 250), padding: const EdgeInsets.all(5), child: const CircularProgressIndicator()),
                    ),
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

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? _phone, _name, _token, _jop, _shop;
  String? _accountTypeSelected;
  String? _selectedJop;
  String? _selectedShop;
  String? errorDetails = '';
  bool nameValidationError = false;
  bool phoneValidationError = false;
  bool firebaseNetError = false;
  bool firebasePhoneFormatError = false;
  bool jopValidationError = false;
  bool shopValidationError = false;
  bool invalidToken = false;
  int selectedAccountTypeIndex = 0;
  String? cCode;
  final _formKey = GlobalKey<FormState>();

  Future signupWithPhone(String? phone) async {
    setState(() {
      firebaseNetError = false;
      firebasePhoneFormatError = false;
    });
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
      phoneNumber: "$cCode$_phone",
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        var result = await _auth.signInWithCredential(credential);
        final user = result.user;
        Navigator.pop(context);
        if (user != null) {
          DatabaseService().addRegisteredPhoneNumber(_phone);
          if (_accountTypeSelected == 'عميل') {
            await DatabaseService(uid: user.uid).createNewUser(_name, null, _phone, null, null, true, [], user.uid, null, null, [], cCode);
          } else if (_accountTypeSelected == 'صنايعي') {
            await DatabaseService(uid: user.uid).createNewUser(_name, _jop, _phone, 0.toString(), null, true, [], user.uid, null, [], [], cCode);
          } else if (_accountTypeSelected == 'محلات') {
            await DatabaseService(uid: user.uid).createNewUser(_name, _shop, _phone, 0.toString(), null, true, [], user.uid, null, [], [], cCode);
          } else {
            setState(() {
              errorDetails = 'Something Went Wrong';
            });
          }
        } else {
          setState(() {
            errorDetails = 'Something Went Wrong';
          });
        }
      },
      verificationFailed: (var authException) {
        if (authException.code == 'network-request-failed') {
          setState(() {
            firebaseNetError = true;
            errorDetails = lang(context, 'checkConnection');
            loading = false;
          });
        }
        if (authException.code == 'invalidCredential') {
          setState(() {
            firebasePhoneFormatError = true;
            loading = false;
          });
        }
        if (authException.code == 'invalid-phone-number') {
          setState(() {
            loading = false;
            errorDetails = lang(context, 'phoneNotCorrect');
            firebasePhoneFormatError = true;
          });
        }
        print(authException.code);
      },
      codeSent: (String verificationId, [int? forceResendToken]) {
        setState(() => loading = false);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Center(child: Text(lang(context, 'validation')!)),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFieldReusable(
                          hintOfTextFiled: lang(context, 'validationKey'),
                          onChanged: (token) => _token = token,
                          keyboardType: TextInputType.phone,
                          length: 6,
                        ),
                        invalidToken == true ? Text(lang(context, 'ensureKey')!) : const SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                invalidToken = false;
                                Navigator.pop(context);
                              },
                              color: kActiveBtnColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                lang(context, 'cancel')!,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                            RaisedButton(
                              color: kActiveBtnColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                lang(context, 'checkKey')!,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              ),
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                try {
                                  AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: _token!);
                                  var result = await _auth.signInWithCredential(credential);
                                  final user = result.user;
                                  if (user != null) DatabaseService().addRegisteredPhoneNumber(_phone);
                                  if (_accountTypeSelected == lang(context, 'client')) {
                                    await DatabaseService(uid: user!.uid)
                                        .createNewUser(_name, null, _phone, null, null, true, [], user.uid, null, null, [], cCode);
                                  }
                                  if (_accountTypeSelected == lang(context, 'worker')) {
                                    await DatabaseService(uid: user!.uid)
                                        .createNewUser(_name, _jop, _phone, '0', null, true, [], user.uid, null, [], [], cCode);
                                  }
                                  if (_accountTypeSelected == lang(context, 'shop')) {
                                    await DatabaseService(uid: user!.uid)
                                        .createNewUser(_name, _shop, _phone, '0', null, true, [], user.uid, null, [], [], cCode);
                                  }
                                  if (user != null) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  setState(() {
                                    invalidToken = true;
                                    loading = false;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        loading == true ? const CircularProgressIndicator() : const SizedBox(),
                      ],
                    );
                  },
                ),
              );
            });
      },
      codeAutoRetrievalTimeout: (codeRetrieval) {
        setState(() {
          loading = false;
        });
        print(codeRetrieval);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenData = MediaQuery.of(context);

    Widget _buildExtra(BuildContext context) {
      switch (selectedAccountTypeIndex) {
        case 0:
          return const SizedBox(height: 0);
        case 1:
          return FadeY(
            delay: 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 120,
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              height: 35,
              child: RaisedButton(
                onPressed: () async {
                  _formKey.currentState!.validate();
                  if (nameValidationError == false && phoneValidationError == false) {
                    _formKey.currentState!.save();
                    loading = true;
                    try {
                      await DatabaseService().ifAPhoneNumberRegistered(_phone).then((QuerySnapshot doc) {
                        if (doc.docs.isEmpty) {
                          signupWithPhone(_phone);
                        } else if (doc.docs.isNotEmpty) {
                          setState(() {
                            phoneValidationError = true;
                            firebasePhoneFormatError = false;
                            errorDetails = lang(context, 'isRegistered');
                            loading = false;
                          });
                        } else if (doc == null) {
                          setState(() {
                            loading = false;
                            errorDetails = lang(context, 'checkConnection');
                          });
                        }
                      });
                    } catch (e) {
                      setState(() {
                        loading = false;
                        firebaseNetError = true;
                        errorDetails = lang(context, 'checkConnection');
                      });
                      print('******** $e');
                    }
                  } else {
                    setState(() {
                      errorDetails = lang(context, 'required');
                    });
                  }
                },
                color: kActiveBtnColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                child: loading == false
                    ? Text(
                        lang(context, 'signup')!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : Container(
                        padding: const EdgeInsets.all(5),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
              ),
            ),
          );
        case 2:
          return FadeY(
            delay: 0.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: <Widget>[
                Container(
                  height: 35,
                  width: screenData.size.width * .7 - (20),
                  decoration: roundedContainerDecoration(kActiveBtnColor),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Center(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        items: jopList.map((JopShopTile jop) {
                          return DropdownMenuItem<String>(
                            value: jop.nameAr,
                            child: Center(
                              child: Text(
                                langCode(context) == 'ar' ? jop.nameAr! : jop.nameEn!,
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? jop) {
                          setState(() {
                            _selectedJop = jop;
                            _jop = jop;
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        hint: Center(
                            child: _jop == null
                                ? Text(lang(context, 'jop')!, style: const TextStyle(color: Colors.grey))
                                : Text('$_jop', style: const TextStyle(color: Colors.white))),
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
                jopValidationError == false
                    ? const SizedBox()
                    : Text(
                        lang(context, 'selectJop')!,
                        style: const TextStyle(color: Colors.red),
                      ),
                SizedBox(
                  width: 120,
                  height: 35,
                  child: RaisedButton(
                    onPressed: () async {
                      if (_selectedJop == null) {
                        setState(() {
                          jopValidationError = true;
                        });
                      }
                      if (_selectedJop != null) {
                        setState(() {
                          jopValidationError = false;
                        });
                      }
                      _formKey.currentState!.validate();
                      if (nameValidationError == false && phoneValidationError == false && _jop != null) {
                        _formKey.currentState!.save();
                        loading = true;
                        try {
                          await DatabaseService().ifAPhoneNumberRegistered(_phone).then((QuerySnapshot doc) {
                            if (doc.docs.isEmpty) {
                              signupWithPhone(_phone);
                            } else if (doc.docs.isNotEmpty) {
                              setState(() {
                                phoneValidationError = true;
                                loading = false;
                                errorDetails = lang(context, 'isRegistered');
                                firebasePhoneFormatError = false;
                              });
                            } else if (doc == null) {
                              setState(() {
                                loading = false;
                                errorDetails = lang(context, 'checkConnection');
                              });
                            }
                          });
                        } catch (e) {
                          setState(() {
                            loading = false;
                            firebaseNetError = true;
                            errorDetails = lang(context, 'checkConnection');
                          });
                          print('******** $e');
                        }
                      } else {
                        setState(() {
                          errorDetails = lang(context, 'required');
                        });
                      }
                    },
                    color: kActiveBtnColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    child: loading == false
                        ? Text(
                            lang(context, 'signup')!,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                        : Container(
                            padding: const EdgeInsets.all(5),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                  ),
                ),
              ],
            ),
          );
        case 3:
          return FadeY(
            duration: const Duration(milliseconds: 200),
            delay: 0.0,
            child: Column(
              children: <Widget>[
                AnimatedContainer(
                  height: 35,
                  width: screenData.size.width * .7 - (20),
                  decoration: roundedContainerDecoration(kActiveBtnColor),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  duration: const Duration(milliseconds: 250),
                  child: Center(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        items: shopsList.map((JopShopTile shop) {
                          return DropdownMenuItem<String>(
                            value: shop.nameAr,
                            child: Center(
                              child: Text(
                                langCode(context) == 'ar' ? shop.nameAr! : shop.nameEn!,
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? shop) {
                          setState(() {
                            _selectedShop = shop;
                            _shop = shop;
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        hint: Center(
                            child: _selectedShop == null
                                ? Text(lang(context, 'myShop')!, style: const TextStyle(color: Colors.grey))
                                : Text('$_selectedShop', style: const TextStyle(color: Colors.white))),
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
                shopValidationError == false
                    ? const SizedBox()
                    : Text(
                        lang(context, 'selectShop')!,
                        style: const TextStyle(color: Colors.red),
                      ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 120,
                  height: 35,
                  child: RaisedButton(
                    onPressed: () async {
                      if (_selectedShop == null) {
                        setState(() {
                          shopValidationError = true;
                        });
                      }
                      if (_selectedShop != null) {
                        setState(() {
                          shopValidationError = false;
                        });
                      }
                      _formKey.currentState!.validate();
                      if (nameValidationError == false && phoneValidationError == false && _shop != null) {
                        _formKey.currentState!.save();
                        loading = true;
                        try {
                          await DatabaseService().ifAPhoneNumberRegistered(_phone).then((QuerySnapshot doc) {
                            if (doc.docs.isEmpty) {
                              signupWithPhone(_phone);
                            } else if (doc.docs.isNotEmpty) {
                              setState(() {
                                phoneValidationError = true;
                                firebasePhoneFormatError = false;
                                loading = false;
                                errorDetails = lang(context, 'isRegistered');
                              });
                            } else if (doc == null) {
                              setState(() {
                                loading = false;
                                errorDetails = lang(context, 'checkConnection');
                              });
                            }
                          });
                        } catch (e) {
                          setState(() {
                            loading = false;
                            firebaseNetError = true;
                            errorDetails = lang(context, 'checkConnection');
                          });
                          print('******** $e');
                        }
                      } else {
                        setState(() {
                          errorDetails = lang(context, 'required');
                        });
                      }
                    },
                    color: kActiveBtnColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    child: loading == false
                        ? Text(
                            lang(context, 'signup')!,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                        : AnimatedContainer(
                            padding: const EdgeInsets.all(5),
                            duration: const Duration(milliseconds: 250),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                  ),
                ),
              ],
            ),
          );
        default:
          return const Text('Error 404');
      }
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              firebaseNetError == false
                  ? const SizedBox(height: 10)
                  : Text(
                      errorDetails!,
                      style: const TextStyle(color: Colors.red),
                    ),
              FadeY(
                duration: const Duration(milliseconds: 200),
                delay: 0.2,
                reversed: true,
                child: SizedBox(
                  width: screenData.size.width * .7,
                  child: TextFieldReusable(
                    hintOfTextFiled: lang(context, 'name'),
                    onSaved: (_nameSignup) => _name = _nameSignup,
                    keyboardType: TextInputType.text,
                    length: 40,
                    validator: (value) {
                      setState(() {
                        value!.isEmpty ? nameValidationError = true : nameValidationError = false;
                      });
                      return null;
                    },
                  ),
                ),
              ),
              nameValidationError == false
                  ? const SizedBox()
                  : Text(
                      lang(context, 'enterName')!,
                      style: const TextStyle(color: Colors.red),
                    ),
              FadeY(
                duration: const Duration(milliseconds: 200),
                delay: 0.4,
                reversed: true,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 35,
                        width: 55,
                        decoration: roundedContainerDecoration(kActiveBtnColor),
                        child: CountryCodePicker(
                          onChanged: (code) {
                            cCode = code.dialCode;
                            print(cCode);
                          },
                          showFlag: false,
                          hideSearch: true,
                          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          initialSelection: 'EG',
                          favorite: const ['SA', 'EG', 'AE', 'SY', 'OM', 'MC', 'KW', 'JO', 'IR', 'IQ', 'PS', 'QA', 'BH', 'YE', 'TN', 'DZ', 'LB', 'LY'],
                          showFlagDialog: true,
                          comparator: (a, b) => b.name!.compareTo(a.name!),
                          onInit: (code) {
                            cCode = code!.dialCode;
                          },
                        ),
                      ),
                      SizedBox(
                        width: screenData.size.width * .522,
                        child: TextFieldReusable(
                          hintOfTextFiled: lang(context, 'phone'),
                          onSaved: (_phoneSignup) {
                            _phone = "$_phoneSignup";
                            print(_phone);
                          },
                          keyboardType: TextInputType.phone,
                          length: 50,
                          validator: (value) {
                            setState(() {
                              value!.isEmpty ? phoneValidationError = true : phoneValidationError = false;
                            });
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              phoneValidationError == false
                  ? const SizedBox()
                  : Text(
                      errorDetails!,
                      style: const TextStyle(color: Colors.red),
                    ),
              firebasePhoneFormatError == false
                  ? const SizedBox()
                  : Text(
                      lang(context, 'phoneNotCorrect')!,
                      style: const TextStyle(color: Colors.red),
                    ),
              FadeY(
                reversed: true,
                duration: const Duration(milliseconds: 200),
                delay: 0.6,
                child: Container(
                  height: 35,
                  width: screenData.size.width * .7 - (20),
                  decoration: roundedContainerDecoration(kActiveBtnColor),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Center(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        items: <String?>[
                          lang(context, 'client'),
                          lang(context, 'worker'),
                          lang(context, 'shop'),
                        ].map((String? accountType) {
                          return DropdownMenuItem<String>(
                            value: accountType,
                            child: Center(
                              child: Text(
                                accountType!,
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? accountType) {
                          setState(() {
                            _accountTypeSelected = accountType;
                            if (_accountTypeSelected == lang(context, 'client')) {
                              selectedAccountTypeIndex = 1;
                            } else if (_accountTypeSelected == lang(context, 'worker')) {
                              selectedAccountTypeIndex = 2;
                            } else if (_accountTypeSelected == lang(context, 'shop')) {
                              selectedAccountTypeIndex = 3;
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        hint: Center(
                            child: _accountTypeSelected == null
                                ? Text(lang(context, 'accType')!, style: const TextStyle(color: Colors.grey))
                                : Text('$_accountTypeSelected', style: const TextStyle(color: Colors.white))),
                        isExpanded: true,
                        autofocus: false,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: _buildExtra(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
