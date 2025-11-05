import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> slides = [
    {
      'title': 'Find Nearby Parking',
      'desc': 'Locate available parking slots in your city instantly!',
      'anim': 'assests/animations/car_animation.json',
    },
    {
      'title': 'Book Instantly',
      'desc': 'Reserve your parking spot before you arrive.',
      'anim': 'assests/animations/parking_slot.json',
    },
    {
      'title': 'Navigate Easily',
      'desc': 'Use the map view to reach your booked slot quickly.',
      'anim': 'assests/animations/locations.json',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F3F), Color(0xFF007BFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (index) {
            setState(() => currentPage = index);
          },
          itemCount: slides.length,
          itemBuilder: (context, index) {
            final slide = slides[index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(slide['anim']!, height: 300),
                const SizedBox(height: 30),
                Text(
                  slide['title']!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    slide['desc']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: Colors.white70),
                  ),
                  onPressed: () {
                    if (index == slides.length - 1) {
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    child: Text(
                      index == slides.length - 1 ? 'Get Started' : 'Next →',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
