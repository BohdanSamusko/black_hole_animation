import 'dart:math';

import 'package:flutter/material.dart';

class BlackHoleAnimScreen extends StatefulWidget {
  const BlackHoleAnimScreen({Key? key}) : super(key: key);

  @override
  State<BlackHoleAnimScreen> createState() => _BlackHoleAnimScreenState();
}

class _BlackHoleAnimScreenState extends State<BlackHoleAnimScreen>
    with TickerProviderStateMixin {
  final int holeAnimationSpeed = 200;
  final int cardAnimationSpeed = 600;
  final int delayBetweenAnimations = 100;

  final double cardSize = 150;

  late final holeSizeTweenAnim = Tween<double>(begin: 0, end: cardSize * 1.5);
  late final holeAnimationController = AnimationController(
      vsync: this, duration: Duration(milliseconds: holeAnimationSpeed));

  double get holeSize => holeSizeTweenAnim.evaluate(holeAnimationController);

  late final cardTransitionAnimationController = AnimationController(
      vsync: this, duration: Duration(milliseconds: cardAnimationSpeed));

  late final cardTransitionTween = Tween<double>(begin: 0, end: cardSize * 2)
      .chain(CurveTween(curve: Curves.easeInBack));

  double get cardTransition =>
      cardTransitionTween.evaluate(cardTransitionAnimationController);

  late final cardRotationTween = Tween<double>(begin: 0, end: 0.5)
      .chain(CurveTween(curve: Curves.easeInBack));

  late final fabIconRotationTween = Tween<double>(begin: 0, end: pi);

  double get cardRotationAngle =>
      cardRotationTween.evaluate(cardTransitionAnimationController);

  late final cardElevationTween = Tween<double>(begin: 2, end: 24);

  double get cardElevation =>
      cardElevationTween.evaluate(cardTransitionAnimationController);

  double get fabIconAngle =>
      fabIconRotationTween.evaluate(cardTransitionAnimationController);

  bool _isCardVisible = true;

  @override
  void initState() {
    super.initState();
    holeAnimationController.addListener(() {
      setState(() {});
    });
    cardTransitionAnimationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Black hole animation'),
      ),
      body: Center(
        child: SizedBox(
          width: cardSize * 2,
          height: cardSize * 1.25,
          child: Stack(alignment: Alignment.bottomCenter, children: [
            SizedBox(
              width: holeSize,
              child: Image.asset(
                'assets/hole.png',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
                child: ClipPath(
              clipper: BlackHoleClipper(),
              child: Center(
                child: Transform.translate(
                    offset: Offset(0, cardTransition),
                    child: Transform.rotate(
                        angle: cardRotationAngle,
                        child: PopUpCard(
                          size: cardSize,
                          elevation: cardElevation,
                        ))),
              ),
            ))
          ]),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              _triggerAnimation();
            },
            child: Transform.rotate(
              angle: fabIconAngle,
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _triggerAnimation() async {
    holeAnimationController.forward();
    if (_isCardVisible) {
      await cardTransitionAnimationController.forward();
      _isCardVisible = false;
    } else {
      await cardTransitionAnimationController.reverse();
      _isCardVisible = true;
    }
    Future.delayed(Duration(milliseconds: delayBetweenAnimations))
        .then((value) => holeAnimationController.reverse());
  }

  @override
  void dispose() {
    holeAnimationController.dispose();
    cardTransitionAnimationController.dispose();
    super.dispose();
  }
}

class BlackHoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    const shiftValue = 85;
    path.moveTo(0, size.height / 2);
    path.arcTo(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2 + shiftValue / 2),
            width: size.width,
            height: size.height - shiftValue),
        0,
        pi,
        true);
    path.lineTo(0, -1000);
    path.lineTo(size.width, -1000);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class PopUpCard extends StatelessWidget {
  const PopUpCard({Key? key, required this.size, required this.elevation})
      : super(key: key);

  final double size;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), color: Colors.orange),
          child: const Center(
              child: Text(
            'Here is\nthe card!',
            textAlign: TextAlign.center,
          )),
        ),
      ),
    );
  }
}
