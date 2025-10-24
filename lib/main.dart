import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
    }
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Banking App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: _checkFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data == true
              ? const OnboardingScreen()
              : const OnboardingScreen();
        },
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _waveOffsetAnimation;
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Welcome to Coop Banking',
      'description':
      'Experience secure and seamless banking at your fingertips.',
      'image': 'images/semless.png',
    },
    {
      'title': 'Instant Transfers',
      'description': 'Send money to anyone, anytime, with just a few taps.',
      'image': 'images/transfer.png',
    },
    {
      'title': 'Track Your Finances',
      'description':
      'Monitor your spending and savings with real-time insights.',
      'image': 'images/semless.png',
    },
    {
      'title': 'Pay Bills Easily',
      'description': 'Manage and pay your bills quickly and securely.',
      'image': 'images/semless.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _imageScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _waveOffsetAnimation = Tween<double>(begin: 0.0, end: 30.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.slowMiddle),
    );

    _animationController.forward();

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
        _animationController.reset();
        _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const SplashScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return ClipPath(
                clipper: WaveClipper(offset: _waveOffsetAnimation.value),
                child: Stack(
                    children: [
                      Container(
                        height: screenHeight * 0.4,
                        color: const Color(0xFF00ADEF),
                        child: Container(
                            padding: EdgeInsets.only(top: (screenHeight * 0.4) * 0.2 ),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.logout),
                                Text(
                                  "Gamtaa App",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFFFFFFFF),
                                  ),
                                  textAlign: TextAlign.center,)
                              ],
                            )

                        ),)
                      ,

                    ]
                )
                ,
              );
            },
          ),

          CustomPaint(
            painter: ParticlePainter(animation: _animationController),
            size: Size(screenWidth, screenHeight),
          ),


          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AnimatedBuilder(
                    //   animation: _imageScaleAnimation,
                    //   builder: (context, child) {
                    //     return Transform.scale(
                    //       scale: _imageScaleAnimation.value,
                    //       child: Image.asset(
                    //         _slides[index]['image']!,
                    //         width: screenWidth * 0.5,
                    //         height: screenWidth * 0.5,
                    //         errorBuilder: (context, error, stackTrace) {
                    //           return Image.asset(
                    //             'images/coopbank.jpg',
                    //             width: screenWidth * 0.2,
                    //             height: screenWidth * 0.2,
                    //           );
                    //         },
                    //       ),
                    //     );
                    //   },
                    // ),
                    SizedBox(height: screenHeight * 0.03),
                    AnimatedBuilder(
                      animation: _textOpacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Text(
                            _slides[index]['title']!,
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF00ADEF),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    AnimatedBuilder(
                      animation: _textOpacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                            ),
                            child: Text(
                              _slides[index]['description']!,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),);
            },
          ),
          Positioned(
            bottom: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  width:
                  _currentPage == index
                      ? screenWidth * 0.03
                      : screenWidth * 0.02,
                  height: screenWidth * 0.02,
                  decoration: BoxDecoration(
                    color:
                    _currentPage == index
                        ? const Color(0xFF00ADEF)
                        : Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            right: screenWidth * 0.05,
            child: TextButton(
              onPressed: _navigateToNext,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.05,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _slides.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _navigateToNext();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADEF),
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, screenHeight * 0.06),
              ),
              child: Text(
                _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;

  ParticlePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
    Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = math.Random(0);
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          (random.nextDouble() * size.height * 0.4) + (animation.value * 50);
      final radius = random.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaveClipper extends CustomClipper<Path> {
  final double offset;

  WaveClipper({this.offset = 0.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height);
    path.quadraticBezierTo(
      size.width / 4,
      size.height - 40 + offset,
      size.width / 2,
      size.height - 40,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height - 40 - offset,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Welcome to Splash Screen')),
    );
  }
}
