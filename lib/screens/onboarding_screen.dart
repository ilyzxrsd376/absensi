import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      "animation": "assets/lottie/education1.json",
      "title": "Selamat Datang!",
      "description": "Aplikasi sekolah modern untuk mendukung kegiatan belajarmu setiap hari.",
    },
    {
      "animation": "assets/lottie/education2.json",
      "title": "Fitur Interaktif",
      "description": "Dari presensi, event, hingga leaderboard, semua ada di genggaman tanganmu.",
    },
    {
      "animation": "assets/lottie/education3.json",
      "title": "Ayo Mulai!",
      "description": "Buka peluang baru dan maksimalkan pengalaman belajarmu bersama kami.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  animationPath: onboardingPages[index]['animation']!,
                  title: onboardingPages[index]['title']!,
                  description: onboardingPages[index]['description']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _pageController.jumpToPage(onboardingPages.length - 1);
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                Row(
                  children: List.generate(
                    onboardingPages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 8,
                      width: _currentPageIndex == index ? 20 : 8,
                      decoration: BoxDecoration(
                        color: _currentPageIndex == index
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_currentPageIndex == onboardingPages.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPageIndex == onboardingPages.length - 1 ? "Mulai" : "Next",
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
