import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sanai3i/files/result_map.dart';
import 'package:sanai3i/files/settings.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database.dart';

bool loading = false;
double iconScale = 4;
Color kActiveBtnColor = const Color(0xff27496D);

containerDecoration(Color? containerColor) {
  return BoxDecoration(
    color: containerColor,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.1),
        spreadRadius: .25,
        blurRadius: 2,
        offset: const Offset(.5, .5),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        spreadRadius: .25,
        blurRadius: 2,
        offset: const Offset(-.5, -.5),
      ),
    ],
    borderRadius: const BorderRadius.all(Radius.circular(8)),
  );
}

roundedContainerDecoration(Color containerColor) {
  return BoxDecoration(
    color: containerColor,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.1),
        spreadRadius: .25,
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
    borderRadius: const BorderRadius.all(Radius.circular(50)),
  );
}

btnDecoration(Color containerColor, double radius) {
  return BoxDecoration(
    color: containerColor,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.2),
        spreadRadius: .5,
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        spreadRadius: .5,
        blurRadius: 2,
        offset: const Offset(0, -1),
      ),
    ],
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

containerDecorationWithBorders(containerColor) {
  return BoxDecoration(
      color: containerColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.1),
          spreadRadius: .5,
          blurRadius: 2,
          offset: const Offset(0, 3),
        ),
      ],
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      border: Border.all(color: kActiveBtnColor, width: 1.5));
}

dropDownDecoration() {
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.1),
        spreadRadius: 1.0,
        blurRadius: 5,
        offset: const Offset(3, 3),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(.1),
        spreadRadius: 1.0,
        blurRadius: 5,
        offset: const Offset(-3, 3),
      ),
    ],
    borderRadius: const BorderRadius.all(Radius.circular(10)),
  );
}

enum _AniProps { opacity, translateX }

class JopShopTile {
  String? nameAr, nameEn;
  ImageProvider? icon;
  JopShopTile({this.nameAr, this.icon, this.nameEn});
}

class FadeY extends StatelessWidget {
  final double delay;
  final Widget child;
  final Duration duration;
  final bool? reversed;

  const FadeY({super.key, required this.delay, required this.duration, this.reversed, required this.child});

  @override
  Widget build(BuildContext context) {
    bool direction = reversed ?? false;
    final tween = MultiTween<_AniProps>()
      ..add(_AniProps.opacity, Tween(begin: .4, end: 1.0))
      ..add(_AniProps.translateX, Tween(begin: 20.0, end: 0.0));

    // ignore: missing_required_param
    return PlayAnimation<MultiTweenValues<_AniProps>>(
      delay: const Duration(milliseconds: 150),
      duration: duration,
      child: child,
      tween: tween,
      builder: (context, child, value) => Opacity(
        opacity: value.get(_AniProps.opacity),
        child: Transform.translate(
          offset: Offset(0, direction ? value.get(_AniProps.translateX) : -value.get(_AniProps.translateX)),
          child: child,
        ),
      ),
    );
  }
}

class FadeX extends StatelessWidget {
  final double delay;
  final Widget child;
  final Duration duration;
  final bool? reversed;

  const FadeX({super.key, required this.delay, required this.duration, this.reversed, required this.child});

  @override
  Widget build(BuildContext context) {
    bool direction = reversed ?? false;

    final tween = MultiTween<_AniProps>()
      ..add(_AniProps.opacity, Tween(begin: .4, end: 1.0))
      ..add(_AniProps.translateX, Tween(begin: 20.0, end: 0.0));

    return PlayAnimation<MultiTweenValues<_AniProps>>(
      delay: const Duration(milliseconds: 150),
      duration: duration,
      child: child,
      tween: tween,
      builder: (context, child, value) => Opacity(
        opacity: value.get(_AniProps.opacity),
        child: Transform.translate(
          offset: Offset(direction ? value.get(_AniProps.translateX) : -value.get(_AniProps.translateX), 0.0),
          child: child,
        ),
      ),
    );
  }
}

class DropDownMenuItem extends StatelessWidget {
  final Function? onTap;
  final String? title;
  final IconData? icon;
  const DropDownMenuItem({this.onTap, this.title, this.icon});
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onTap as void Function()?,
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              title!,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.right,
            ),
            const SizedBox(
              width: 15,
            ),
            Icon(
              icon,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsMenuItem extends StatelessWidget {
  final Function? onTap;
  final String? title;
  const SettingsMenuItem({this.onTap, this.title});
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onTap as void Function()?,
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            title!,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }
}

showPhoneDialog(String? phone1, phone2, cCode, BuildContext context) {
  showModal(
      configuration: const FadeScaleTransitionConfiguration(),
      context: context,
      builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: kActiveBtnColor,
                  onPressed: () {
                    launch('tel:$phone1');
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        height: 38,
                        child: IconButton(
                          icon: Image.asset(
                            'images/wa.png',
                          ),
                          onPressed: () {
                            launch('https://api.whatsapp.com/send?phone=$cCode$phone1');
                          },
                        ),
                      ),
                      Text(
                        phone1!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.right,
                      ),
                      const Icon(
                        Icons.phone,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
                phone2 != null
                    ? RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: kActiveBtnColor,
                        onPressed: () {
                          launch('tel:$phone2');
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              height: 38,
                              child: IconButton(
                                icon: Image.asset(
                                  'images/wa.png',
                                ),
                                onPressed: () {
                                  launch('https://api.whatsapp.com/send?phone=$cCode$phone2');
                                },
                              ),
                            ),
                            Text(
                              phone2,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(
                              Icons.phone,
                              color: Colors.white,
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: kActiveBtnColor,
                    child: Text(
                      lang(context, 'cancel')!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ));
}

showRateDialog(String? uid, BuildContext context) {
  showModal(
      configuration: const FadeScaleTransitionConfiguration(),
      context: context,
      builder: (context) {
        String? _newRate;
        String _comment = '';
        String _name = '';
        bool _star1 = false, _star2 = false, _star3 = false, _star4 = false, _star5 = false, notSelected = false;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _selectedStar(int num, BuildContext context) {
                if (num == 1) {
                  setState(() {
                    _star1 = true;
                    _star2 = false;
                    _star3 = false;
                    _star4 = false;
                    _star5 = false;
                  });
                } else if (num == 2) {
                  setState(() {
                    _star1 = true;
                    _star2 = true;
                    _star3 = false;
                    _star4 = false;
                    _star5 = false;
                  });
                } else if (num == 3) {
                  setState(() {
                    _star1 = true;
                    _star2 = true;
                    _star3 = true;
                    _star4 = false;
                    _star5 = false;
                  });
                } else if (num == 4) {
                  setState(() {
                    _star1 = true;
                    _star2 = true;
                    _star3 = true;
                    _star4 = true;
                    _star5 = false;
                  });
                } else {
                  setState(() {
                    _star1 = true;
                    _star2 = true;
                    _star3 = true;
                    _star4 = true;
                    _star5 = true;
                  });
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          _selectedStar(1, context);
                          _newRate = 1.toString();
                        },
                        child: _star1
                            ? const Icon(
                                Icons.star,
                                size: 28,
                                color: Colors.yellow,
                              )
                            : const Icon(Icons.star_border, size: 28),
                      ),
                      InkWell(
                        onTap: () {
                          _selectedStar(2, context);
                          _newRate = 2.toString();
                        },
                        child: _star2
                            ? const Icon(
                                Icons.star,
                                size: 28,
                                color: Colors.yellow,
                              )
                            : const Icon(Icons.star_border, size: 28),
                      ),
                      InkWell(
                        onTap: () {
                          _selectedStar(3, context);
                          _newRate = 3.toString();
                        },
                        child: _star3
                            ? const Icon(
                                Icons.star,
                                size: 28,
                                color: Colors.yellow,
                              )
                            : const Icon(Icons.star_border, size: 28),
                      ),
                      InkWell(
                        onTap: () {
                          _selectedStar(4, context);
                          _newRate = 4.toString();
                        },
                        child: _star4
                            ? const Icon(
                                Icons.star,
                                size: 28,
                                color: Colors.yellow,
                              )
                            : const Icon(Icons.star_border, size: 28),
                      ),
                      InkWell(
                        onTap: () {
                          _selectedStar(5, context);
                          _newRate = 5.toString();
                        },
                        child: _star5
                            ? const Icon(
                                Icons.star,
                                size: 28,
                                color: Colors.yellow,
                              )
                            : const Icon(Icons.star_border, size: 28),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: notSelected ? Text(lang(context, 'selectRate')!) : const SizedBox(),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: kActiveBtnColor, width: 1),
                    ),
                    child: TextField(
                      textAlign: TextAlign.right,
                      onChanged: (name) {
                        _name = name;
                      },
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintText: lang(context, 'name'),
                        hintStyle: const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: kActiveBtnColor, width: 1),
                    ),
                    child: TextField(
                      textAlign: TextAlign.right,
                      onChanged: (comment) {
                        _comment = comment;
                      },
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintText: lang(context, 'writeReview'),
                        hintStyle: const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                        child: Text(
                          lang(context, 'cancel')!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        color: kActiveBtnColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child: Text(
                          lang(context, 'review')!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        color: kActiveBtnColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () {
                          if (_newRate != null) {
                            DatabaseService(uid: uid).updateUserRate(name: _name, comment: _comment, rate: _newRate);
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: ' $_newRate  👌 ',
                              gravity: ToastGravity.BOTTOM,
                            );
                          } else {
                            setState(() {
                              notSelected = true;
                            });
                          }
                        },
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        );
      });
}

showCommentDialog({List? comments, required BuildContext context}) {
  showModal(
      configuration: const FadeScaleTransitionConfiguration(),
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: <Widget>[
            RawMaterialButton(
              fillColor: kActiveBtnColor,
              shape: const StadiumBorder(),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                lang(context, 'cancel')!,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if (comments!.isEmpty) {
                return Text(
                  lang(context, 'noReviews')!,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  textDirection: TextDirection.rtl,
                );
              } else {
                return SizedBox(
                  width: 300,
                  height: 500,
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            int.parse(comments[index]['stars']) == 1
                                ? const Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.yellow,
                                  )
                                : int.parse(comments[index]['stars']) == 2
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: const <Widget>[
                                          Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.yellow,
                                          ),
                                          Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.yellow,
                                          ),
                                        ],
                                      )
                                    : int.parse(comments[index]['stars']) == 3
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: const <Widget>[
                                              Icon(
                                                Icons.star,
                                                size: 18,
                                                color: Colors.yellow,
                                              ),
                                              Icon(
                                                Icons.star,
                                                size: 18,
                                                color: Colors.yellow,
                                              ),
                                              Icon(
                                                Icons.star,
                                                size: 18,
                                                color: Colors.yellow,
                                              ),
                                            ],
                                          )
                                        : int.parse(comments[index]['stars']) == 4
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: const <Widget>[
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: const <Widget>[
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: Colors.yellow,
                                                  ),
                                                ],
                                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "${comments[index]['name']}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textDirection: TextDirection.rtl,
                                ),
                                Text(
                                  lang(context, 'rateBy')!,
                                  style: const TextStyle(fontSize: 16),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${comments[index]['comment']} ",
                                style: const TextStyle(fontSize: 14),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        );
      });
}

class PositionedBtn extends StatelessWidget {
  final Function? onPressed;
  final IconData? icon;
  const PositionedBtn({this.onPressed, this.icon});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: RaisedButton(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
        onPressed: onPressed as void Function()?,
        child: Center(
            child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        )),
        color: kActiveBtnColor,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final Icon? suffixIcon;
  final String? initialValue;
  final bool? editEnabled;
  final Function? onChange;
  final bool? validator;
  final style;
  final containerWidth;
  final TextInputType? keyboardType;

  const CustomTextField({super.key, this.suffixIcon, this.initialValue, this.editEnabled, this.onChange, this.validator, required this.style, required this.containerWidth, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: editEnabled! ? containerDecorationWithBorders(Colors.white) : containerDecoration(Colors.white),
      width: containerWidth,
      height: 37,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 250),
      child: TextFormField(
        onChanged: onChange as void Function(String)?,
        enabled: editEnabled,
        textAlign: TextAlign.center,
        keyboardType: keyboardType,
        style: style,
        decoration: InputDecoration(
            hintText: initialValue,
            hintStyle: const TextStyle(color: Colors.black, fontSize: 15),
            border: InputBorder.none,
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.purpleAccent), borderRadius: BorderRadius.all(Radius.circular(15))),
            suffixIcon: suffixIcon,
            prefix: validator!
                ? Text(
                    lang(context, 'required')!,
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                  )
                : const SizedBox(
                    width: 25,
                  )),
      ),
    );
  }
}

class TextFieldReusable extends StatelessWidget {
  final String? hintOfTextFiled;
  final Function? onSaved;
  final TextInputType? keyboardType;
  final int? length;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const TextFieldReusable(
      {super.key, this.hintOfTextFiled, this.onSaved, this.keyboardType, this.length, this.validator, this.controller, this.onChanged});
  @override
  Widget build(BuildContext context) {
    var screenData = MediaQuery.of(context);
    return AnimatedContainer(
      height: 35,
      width: screenData.size.width * .6,
      duration: const Duration(milliseconds: 100),
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      decoration: roundedContainerDecoration(kActiveBtnColor),
      child: TextFormField(
        validator: validator,
        controller: controller,
        keyboardType: keyboardType,
        autofocus: false,
        maxLength: length,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          fillColor: kActiveBtnColor,
          counter: const SizedBox.shrink(),
          hintText: '$hintOfTextFiled',
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
        onSaved: onSaved as void Function(String?)?,
        onChanged: onChanged,
      ),
    );
  }
}

class CustomGridView extends StatelessWidget {
  final List gridViewType;

  const CustomGridView({super.key, required this.gridViewType});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 1, childAspectRatio: 1.25, mainAxisSpacing: 1),
      itemCount: gridViewType.length,
      padding: const EdgeInsets.all(5),
      itemBuilder: (context, index) {
        return OpenContainer(
          closedElevation: 0,
          closedColor: Colors.transparent,
          openElevation: 0,
          openColor: Colors.transparent,
          closedBuilder: (context, action) {
            return FadeY(
              duration: const Duration(milliseconds: 300),
              delay: index / 10 * .5,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: containerDecoration(Colors.grey[50]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(25, 15, 25, 20),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: gridViewType[index].icon,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      langCode(context) == 'ar' ? gridViewType[index].nameAr : gridViewType[index].nameEn,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
          openBuilder: (context, action) {
            return ResultsInMaps(
              jopOrShop: gridViewType[index].nameAr,
              jopShopTile: gridViewType[index],
            );
          },
        );
      },
    );
  }
}

class MyCustomTile extends StatefulWidget {
  final Model modelDetails;

  const MyCustomTile({super.key, required this.modelDetails});

  @override
  _MyCustomTileState createState() => _MyCustomTileState();
}

class _MyCustomTileState extends State<MyCustomTile> {
  bool _isBookmarked = false;
  String _rate = '';

  ifUserIsBookmarked(String? uid) async {
    final user = FirebaseAuth.instance.currentUser!;
    List bookmarks = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get().then((DocumentSnapshot documentSnapshot) {
      return documentSnapshot.get('Bookmark');
    });
    if (bookmarks.contains(uid)) {
      setState(() {
        _isBookmarked = true;
      });
    } else {
      _isBookmarked = false;
    }
  }

  addUserToBookmark() async {
    final user = FirebaseAuth.instance.currentUser!;
    List bookmarks = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get().then((DocumentSnapshot documentSnapshot) {
      return documentSnapshot.get('Bookmark');
    });
    if (!bookmarks.contains(widget.modelDetails.myUID)) {
      setState(() {
        DatabaseService(uid: user.uid).updateUsersBookmarks(widget.modelDetails.myUID);
        _isBookmarked = true;
      });
    } else {
      setState(() {
        DatabaseService(uid: user.uid).deleteUsersBookmarks(widget.modelDetails.myUID);
        _isBookmarked = false;
      });
    }
  }

  @override
  void initState() {
    ifUserIsBookmarked(widget.modelDetails.myUID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (widget.modelDetails.ratedMe!.isEmpty) {
      _rate = 0.0.toString();
    } else {
      _rate = (double.parse(widget.modelDetails.rate!) / widget.modelDetails.ratedMe!.length).toString();
    }

    return TweenAnimationBuilder(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0.8, end: 1.0),
        builder: (context, dynamic value, child) {
          return Transform.scale(
            scale: value,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 80,
                    width: size.width - 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          spreadRadius: .5,
                          blurRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  Positioned(
                    child: IconButton(
                      icon: const Icon(
                        Icons.phone,
                        size: 20,
                      ),
                      onPressed: () {
                        showPhoneDialog(widget.modelDetails.phone, widget.modelDetails.phone2, widget.modelDetails.cCode, context);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 1,
                    child: _isBookmarked != null
                        ? IconButton(
                            icon: _isBookmarked
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  )
                                : const Icon(
                                    Icons.bookmark,
                                    size: 20,
                                  ),
                            onPressed: () {
                              addUserToBookmark();
                            },
                          )
                        : const CircularProgressIndicator(),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xdd27496D),
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: (widget.modelDetails.picURL == null
                              ? const AssetImage('images/profilePic.png')
                              : CachedNetworkImageProvider(widget.modelDetails.picURL!)) as ImageProvider<Object>,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 15,
                    bottom: 5,
                    child: Container(
                      width: 50,
                      height: 18,
                      decoration: containerDecoration(kActiveBtnColor),
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                            child: Text(
                              _rate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 100,
                    child: Text(
                      widget.modelDetails.name!,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 100,
                    child: widget.modelDetails.isAvailable!
                        ? Text(
                            lang(context, 'free')!,
                            style: const TextStyle(fontSize: 14),
                          )
                        : Text(
                            lang(context, 'notFree')!,
                            style: const TextStyle(fontSize: 14),
                          ),
                  ),
                  Positioned(
                      bottom: 10,
                      left: 50,
                      child: Text(
                        '${lang(context, 'reviews')}  ${widget.modelDetails.ratedMe!.length}',
                        style: const TextStyle(fontSize: 12),
                      )),
                  Positioned(
                    top: 40,
                    child: SizedBox(
                      width: 40,
                      height: .5,
                      child: Divider(
                        thickness: .5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 40,
                    child: SizedBox(
                      height: 80,
                      width: .5,
                      child: VerticalDivider(
                        thickness: .5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

divider() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 5),
    child: Divider(
      height: 1,
      color: Colors.black26,
      thickness: .5,
    ),
  );
}

List<JopShopTile> jopList = [
  JopShopTile(
      nameAr: 'ميكانيكي',
      nameEn: "mechanistic",
      icon: const AssetImage(
        'images/mec.png',
      )),
  JopShopTile(
      nameAr: 'كهربائي',
      nameEn: "Electrician",
      icon: const AssetImage(
        'images/kah.png',
      )),
  JopShopTile(
      nameAr: 'سمسار عقارات',
      nameEn: "realtor",
      icon: const AssetImage(
        'images/rays.png',
      )),
  JopShopTile(nameAr: 'نجار مسلح', nameEn: "mechanistic", icon: const AssetImage('images/nag.png')),
  JopShopTile(
      nameAr: 'نجار باب',
      nameEn: "Carpenter",
      icon: const AssetImage(
        'images/nag.png',
      )),
  JopShopTile(
      nameAr: 'لحام كهربائي',
      nameEn: 'welder',
      icon: const AssetImage(
        'images/l7am.png',
      )),
  JopShopTile(
      nameAr: 'حلاق',
      nameEn: 'Hair dresser',
      icon: const AssetImage(
        'images/7laq.png',
      )),
  JopShopTile(
      nameAr: 'خياط',
      nameEn: 'Dressmaker',
      icon: const AssetImage(
        'images/5yat.png',
      )),
  JopShopTile(nameAr: 'رئيس عمال', nameEn: 'Foreman', icon: const AssetImage('images/aml.png')),
  JopShopTile(nameAr: 'سائق سيارة أجرة', nameEn: 'Cab Driver', icon: const AssetImage('images/swaqt.png')),
  JopShopTile(nameAr: 'سائق اتوبيس', nameEn: 'Bus-man', icon: const AssetImage('images/swaq.png')),
  JopShopTile(
      nameAr: 'عامل باليومية',
      nameEn: 'Workman',
      icon: const AssetImage(
        'images/aml.png',
      )),
  JopShopTile(nameAr: 'كوافير متنقل', nameEn: 'Hair Stylist', icon: const AssetImage('images/seb.png')),
  JopShopTile(
      nameAr: 'عامل نظافة',
      nameEn: 'Cleaner',
      icon: const AssetImage(
        'images/nzafa.jpg',
      )),
  JopShopTile(
      nameAr: 'جزار',
      nameEn: 'Butcher',
      icon: const AssetImage(
        'images/gzar.png',
      )),
  JopShopTile(
      nameAr: 'سباك',
      nameEn: 'Plumber',
      icon: const AssetImage(
        'images/seb.png',
      )),
  JopShopTile(
      nameAr: 'نقاش',
      nameEn: "engraver",
      icon: const AssetImage(
        'images/nak.png',
      )),
  JopShopTile(
      nameAr: 'عامل بناء',
      nameEn: "builder",
      icon: const AssetImage(
        'images/aml.png',
      )),
  JopShopTile(
      nameAr: 'سيراميك',
      nameEn: "Ceramic",
      icon: const AssetImage(
        'images/aml.png',
      )),
  JopShopTile(
      nameAr: 'استرجي',
      nameEn: "Furniture paint",
      icon: const AssetImage(
        'images/nak.png',
      )),
  JopShopTile(
      nameAr: 'حداد',
      nameEn: "Smith",
      icon: const AssetImage(
        'images/had.png',
      )),
  JopShopTile(
      nameAr: 'فني الوميتال',
      nameEn: "Alumital technician",
      icon: const AssetImage(
        'images/aml.png',
      )),
  JopShopTile(
      nameAr: 'صيانة دش',
      nameEn: "TV maintenance",
      icon: const AssetImage(
        'images/sey.png',
      )),
  JopShopTile(
      nameAr: 'تنجيد و ستائر',
      nameEn: "upholstery",
      icon: const AssetImage(
        'images/aml.png',
      )),
  JopShopTile(
      nameAr: 'فني تكييفات',
      nameEn: "Air conditioning technician",
      icon: const AssetImage(
        'images/tec.png',
      )),
  JopShopTile(
      nameAr: 'صيانة اجهزة منزلية',
      nameEn: "Appliances Maintenance",
      icon: const AssetImage(
        'images/sey.png',
      )),
  JopShopTile(nameAr: 'فلاتر مياه', nameEn: "Water filters", icon: const AssetImage('images/fil.png')),
  JopShopTile(
      nameAr: 'محارة',
      nameEn: "plasterer",
      icon: const AssetImage(
        'images/nak.png',
      )),
  JopShopTile(
      nameAr: 'حمامات سباحة',
      nameEn: "swimming pool",
      icon: const AssetImage(
        'images/sba.png',
      )),
  JopShopTile(
      nameAr: 'تدفئة مركزية',
      nameEn: "Central heating",
      icon: const AssetImage(
        'images/tec.png',
      )),
  JopShopTile(
      nameAr: 'طباخ',
      nameEn: "Chef",
      icon: const AssetImage(
        'images/tap.png',
      )),
];

List<JopShopTile> shopsList = [
  JopShopTile(
      nameAr: 'جزارة',
      nameEn: 'Butchery',
      icon: const AssetImage(
        'images/gzar.png',
      )),
  JopShopTile(
      nameAr: 'مشويات',
      nameEn: 'Barbecue',
      icon: const AssetImage(
        'images/m4w.png',
      )),
  JopShopTile(
      nameAr: 'مطبعة',
      nameEn: 'Printing press',
      icon: const AssetImage(
        'images/mtb3a.jpg',
      )),
  JopShopTile(
      nameAr: 'مغسلة',
      nameEn: 'laundry',
      icon: const AssetImage(
        'images/m8sla.png',
      )),
  JopShopTile(
      nameAr: 'مخبز',
      nameEn: 'bakery',
      icon: const AssetImage(
        'images/m5bz.png',
      )),
  JopShopTile(
      nameAr: 'ورشة خراطة',
      nameEn: 'Turning workshop',
      icon: const AssetImage(
        'images/5rata.png',
      )),
  JopShopTile(
      nameAr: 'حدايد و بويات',
      nameEn: "Iron and paint",
      icon: const AssetImage(
        'images/7dayd.jpg',
      )),
  JopShopTile(
      nameAr: 'زجاج',
      nameEn: 'Glass',
      icon: const AssetImage(
        'images/zogag.png',
      )),
  JopShopTile(
      nameAr: 'مطابخ',
      nameEn: "Kitchens",
      icon: const AssetImage(
        'images/matb5.png',
      )),
  JopShopTile(
      nameAr: 'معرض سيراميك',
      nameEn: "Ceramics Showroom",
      icon: const AssetImage(
        'images/blat.png',
      )),
  JopShopTile(nameAr: 'تكييفات', nameEn: 'Air conditioning', icon: const AssetImage('images/takyyf.png')),
  JopShopTile(
      nameAr: 'دهانات و ديكورات',
      nameEn: "Paints and Decorations",
      icon: const AssetImage(
        'images/dhanat.png',
      )),
  JopShopTile(
      nameAr: 'ادوات صحية',
      nameEn: "Plumbing equipment",
      icon: const AssetImage(
        'images/sepaka.png',
      )),
  JopShopTile(
      nameAr: 'كهرباء و اضاءة',
      nameEn: "Electricity equipment",
      icon: const AssetImage(
        'images/khrba.png',
      )),
  JopShopTile(
      nameAr: 'اثاث منزلي',
      nameEn: "Home furniture",
      icon: const AssetImage(
        'images/asas.png',
      )),
  JopShopTile(
      nameAr: 'رخام و جيرانيت',
      nameEn: "Marble and granite",
      icon: const AssetImage(
        'images/ro5am.png',
      )),
  JopShopTile(nameAr: 'عدد و ادوات', nameEn: "tools & equipment ", icon: const AssetImage('images/adwat.png')),
  JopShopTile(
      nameAr: 'خامات خشب',
      nameEn: 'Wood materials',
      icon: const AssetImage(
        'images/5a4b.png',
      )),
  JopShopTile(
      nameAr: 'مكافحة حشرات',
      nameEn: 'Anti Bugs',
      icon: const AssetImage(
        'images/7shrat.png',
      )),
  JopShopTile(
      nameAr: 'كاميرات مراقبة',
      nameEn: "security cameras",
      icon: const AssetImage(
        'images/camera.png',
      )),
  JopShopTile(
      nameAr: 'مراتب و ستائر',
      nameEn: 'Mattresses and curtains',
      icon: const AssetImage(
        'images/mratb.png',
      )),
  JopShopTile(
      nameAr: 'اجهزة منزلية',
      nameEn: "Home appliances",
      icon: const AssetImage(
        'images/agheza.png',
      )),
  JopShopTile(
      nameAr: 'مشتل',
      nameEn: 'nursery',
      icon: const AssetImage(
        'images/mshtl.png',
      )),
  JopShopTile(
      nameAr: 'سجاد و موكيت',
      nameEn: "carpeting",
      icon: const AssetImage(
        'images/segad.png',
      )),
  JopShopTile(
      nameAr: 'خدمات نقل',
      nameEn: "Transfer services",
      icon: const AssetImage(
        'images/nakl.png',
      )),
  JopShopTile(
      nameAr: 'مواتير مياه',
      nameEn: 'Water motors',
      icon: const AssetImage(
        'images/motor.png',
      )),
  JopShopTile(
      nameAr: 'مصاعد',
      nameEn: 'Elevators',
      icon: const AssetImage(
        'images/mes3d.png',
      )),
];
