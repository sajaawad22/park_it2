import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "images/onboarding1.png",
      "title": "",
      "description": "Reserve your parking spot in advance for a hassle-free experience! With just a few taps,  secure your space before arriving and save time, avoid stress, and guarantee convenience every trip",
    },
    {
      "image": "images/onboarding2.png",
      "title": "",
      "description": "Effortlessly book and pay for your parking in seconds! Enjoy a fast, secure, and seamless process, giving you peace of mind and more time for what matters. guarantee convenience every trip",
    },
    {
      "image": "images/onboarding3.png",
      "title": "",
      "description": "Need more time? Easily extend your parking with just a few taps, ensuring flexibility and peace of mind without any hassle.",
    },
  ];

  void goToLoginScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  image: onboardingData[index]["image"]!,
                  title: onboardingData[index]["title"]!,
                  description: onboardingData[index]["description"]!,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (index) => buildDot(index),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 350,
              child: ElevatedButton(
                onPressed: currentIndex == onboardingData.length - 1
                    ? goToLoginScreen
                    : () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color(0xFFFF5177),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(currentIndex == onboardingData.length - 1 ? "Get Started" : "Next",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 350,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color(0xFFFFDCE4),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child:Text("Skip",
                  style: TextStyle(fontSize: 18, fontWeight:FontWeight.bold, color: Color(0xFFFF5177),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      height: 10,
      width: currentIndex == index ? 20 : 10,
      decoration: BoxDecoration(
        color: currentIndex == index ? Color(0xFFFF5177) : Color(0xFFFFDCE4),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String image, title, description;

  OnboardingContent({required this.image, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 400),
          Text(
            title,
            style: TextStyle(fontSize: 1, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
