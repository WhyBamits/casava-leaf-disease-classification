import 'package:flutter/material.dart';
import 'package:plant_disease_detection/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentPage = 0;
  bool _isSplash = true;

  final List<_OnboardingStep> steps = [
    _OnboardingStep(
      title: "Cassava Doctor",
      titleStyle: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: Color(0xFF5D7C4A),
      ),
      subtitle: "",
      image: null,
      showUnderline: true,
    ),
    _OnboardingStep(
      title: "Welcome to\nCassava Doctor🧑‍⚕️👨‍⚕️",
      titleStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Color(0xFF5D7C4A),
      ),
      subtitle: "",
      image: "assets/images/1.png",
      showUnderline: false,
    ),
    _OnboardingStep(
      title: "Detect Diseases🦠🦠 Early, Protect Your Harvest",
      titleStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Color.fromARGB(221, 41, 56, 37),
      ),
      subtitle:
          "Scan📸 cassava leaves using your phone and receive instant AI-powered results🦠",
      image: "assets/images/5.png",
      showUnderline: false,
    ),
    _OnboardingStep(
      title:
          "Get started with Cassava Doctor by exploring how easy it is to find diseases🦠 on cassava plants",
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color.fromARGB(255, 50, 65, 35),
      ),
      subtitle: "",
      image: "assets/images/4.png",
      showUnderline: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          currentPage = 1;
          _isSplash = false;
        });
      }
    });
  }

  void _next() {
    if (currentPage < steps.length - 1) {
      setState(() => currentPage++);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentPage];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌿 Background image
          Image.asset(
            'assets/images/be.png', // <-- your background image
            fit: BoxFit.cover,
          ),

          // Optional overlay to increase contrast
          Container(
            color: Colors.white.withOpacity(0.88),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: currentPage == 2
                        ? Column(
                            children: [
                              if (step.image != null)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.26,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.22),
                                            blurRadius: 60,
                                            spreadRadius: 26,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Image.asset(
                                      step.image!,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                    ),
                                  ],
                                ),
                              const Spacer(),
                              Text(
                                step.title,
                                style: step.titleStyle,
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                              _buildDots(),
                            ],
                          )
                        : currentPage == 0
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Cassava ",
                                                style: step.titleStyle.copyWith(
                                                  color: const Color.fromARGB(
                                                      255, 172, 197, 138),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "Doctor",
                                                style: step.titleStyle.copyWith(
                                                  color: const Color.fromARGB(
                                                      255, 45, 48, 44),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (step.showUnderline)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 8),
                                            height: 3,
                                            width: 80,
                                            color: const Color(0xFFB5C99A),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        step.title,
                                        style: step.titleStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                      if (step.subtitle.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          child: Text(
                                            step.subtitle,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (step.image != null)
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.26,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.26,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green
                                                    .withOpacity(0.22),
                                                blurRadius: 60,
                                                spreadRadius: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Image.asset(
                                          step.image!,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                        ),
                                      ],
                                    ),
                                  _buildDots(),
                                ],
                              ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: currentPage == 0 && _isSplash
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF5D7C4A),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: _next,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D7C4A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Icon(
                              currentPage == steps.length - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (index) {
        if (index == 0) return const SizedBox(); // hide splash dot
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 12 : 8,
          height: currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentPage == index ? const Color(0xFF5D7C4A) : Colors.grey[300],
          ),
        );
      }),
    );
  }
}

class _OnboardingStep {
  final String title;
  final TextStyle titleStyle;
  final String subtitle;
  final String? image;
  final bool showUnderline;

  const _OnboardingStep({
    required this.title,
    required this.titleStyle,
    required this.subtitle,
    this.image,
    this.showUnderline = false,
  });
}
