import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:sanai3i/files/result_map.dart';
import 'package:sanai3i/files/reusable.dart';
import 'package:sanai3i/files/settings.dart';

class HomePage extends StatefulWidget {
  final Function onHomeBtnPressed;
  const HomePage({required this.onHomeBtnPressed});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double initialScrollOffset = Random().nextInt(10) * 130.0;
    var screenData = MediaQuery.of(context);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          FadeY(
            duration: const Duration(milliseconds: 250),
            delay: 0.0,
            child: Center(
                child: Text(
              lang(context, 'lookingFor')!,
              style: const TextStyle(fontSize: 18),
            )),
          ),
          const SizedBox(
            height: 35,
          ),
          FadeY(
            duration: const Duration(milliseconds: 250),
            delay: 0.2,
            child: HomeRaisedBtn(
              screenData: screenData,
              title: lang(context, 'worker'),
              onPressed: () {
                widget.onHomeBtnPressed(3);
              },
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          FadeY(
            duration: const Duration(milliseconds: 250),
            delay: 0.4,
            child: HomeListView(
              initialScrollOffset: initialScrollOffset,
              list: jopList,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          FadeY(
            duration: const Duration(milliseconds: 250),
            delay: 0.6,
            child: HomeRaisedBtn(
              screenData: screenData,
              title: lang(context, 'shop'),
              onPressed: () {
                widget.onHomeBtnPressed(4);
              },
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          FadeY(
            duration: const Duration(milliseconds: 250),
            delay: 0.8,
            child: SizedBox(
              height: 90,
              child: HomeListView(
                initialScrollOffset: initialScrollOffset,
                list: shopsList,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeListView extends StatelessWidget {
  const HomeListView({
    required this.initialScrollOffset,
    this.list,
  });

  final double initialScrollOffset;
  final List? list;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list!.length,
        padding: const EdgeInsets.symmetric(vertical: 2),
        controller: ScrollController(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: true,
        ),
        itemBuilder: (context, index) {
          return OpenContainer(
            closedElevation: 0,
            closedColor: Colors.transparent,
            openElevation: 0,
            openColor: Colors.transparent,
            transitionDuration: const Duration(milliseconds: 300),
            transitionType: ContainerTransitionType.fade,
            closedBuilder: (context, action) {
              return Container(
                margin: const EdgeInsets.all(3),
                decoration: containerDecoration(Colors.grey[50]),
                width: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(25, 10, 25, 15),
                        decoration: BoxDecoration(
                          image: DecorationImage(image: list![index].icon, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        langCode(context) == 'ar' ? list![index].nameAr : list![index].nameEn,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
            openBuilder: (context, action) {
              return ResultsInMaps(
                jopOrShop: list![index].nameAr,
                jopShopTile: list![index],
              );
            },
          );
        },
      ),
    );
  }
}

class HomeRaisedBtn extends StatelessWidget {
  final MediaQueryData screenData;
  final Function? onPressed;
  final String? title;

  const HomeRaisedBtn({super.key, required this.screenData, this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenData.size.width * .55,
      height: 32.5,
      child: RaisedButton(
          elevation: 4,
          color: kActiveBtnColor,
          splashColor: Colors.amber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(
                width: 30,
              ),
              Text(title!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              title == lang(context, 'worker')
                  ? Image.asset(
                      'images/worker.png',
                      scale: 2.8,
                    )
                  : Image.asset(
                      'images/shop.png',
                      scale: 4.5,
                    ),
            ],
          ),
          onPressed: onPressed as void Function()?),
    );
  }
}
