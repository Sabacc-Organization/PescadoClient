// import 'dart:math';

import 'package:PescadoClient/general_gui.dart';
import 'package:PescadoClient/main.dart';
import 'package:flutter/material.dart';
// import 'package:vector_math/vector_math_64.dart' hide Colors;

const b = 1.25;
const brighteningMatrix = <double>[
  b, 0, 0, 0, 0,
  0, b, 0, 0, 0,
  0, 0, b, 0, 0,
  0, 0, 0, b, 0,
];

class PageTemplateW extends StatelessWidget {
  const PageTemplateW({required child, super.key}) : _child = child;

  final Widget _child;

  @override
  Widget build(BuildContext context) {
    var appwideData = AppwideDataProvider.from(context);
    return Stack(
      children: [
        SizedBox.expand(
          child: AnimatedCrossFade(
            duration: context.findAncestorWidgetOfExactType<MaterialApp>()!.themeAnimationDuration,
            firstChild: SizedBox.expand(
              child: Image.asset(
                "lib/static/img/space.jpg",
                fit: BoxFit.cover,
                alignment: AlignmentGeometry.center,
              ),
            ),
            secondChild: SizedBox.expand(
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(brighteningMatrix),
                child: Image.asset(
                  "lib/static/img/planet.jpg",
                  fit: BoxFit.cover,
                  alignment: AlignmentGeometry.center,
                ),
              ),
            ),
            layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) => Stack(children: [bottomChild, topChild],),
            crossFadeState: appwideData.darkMode? CrossFadeState.showFirst : CrossFadeState.showSecond,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: SabaccAppBarW(),
          body: _child
        ),
      ]
    );
  }
}