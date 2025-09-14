import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Academy extends StatelessWidget {
  const Academy({super.key});

  final List<Map<String, String>> striveCourses = const [
    {
      "title": "Wellness",
      "image": "lib/assets/images/lonely.png",
      "url": "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/"
    },
    {
      "title": "Stress Management",
      "image": "lib/assets/images/stress.png",
      "url": "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/"
    },
    {
      "title": "Loneliness",
      "image": "lib/assets/images/loneliness.png",
      "url": "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/"
    },
  ];

  final List<Map<String, String>> professionalSkills = const [
    {
      "title": "Management",
      "image": "lib/assets/images/management.png",
      "url": "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/"
    },
    {
      "title": "Leadership",
      "image": "lib/assets/images/leadership.png",
      "url": "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/"
    },
    {
      "title": "Decision Making",
      "image": "lib/assets/images/dec.png",
      "url": "https://course.strive-high.com/topics/understanding-and-managing-loneliness-onboard/"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "StriveHigh",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "StriveHigh Courses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Horizontal scroll - StriveHigh Courses
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: striveCourses.length,
                itemBuilder: (context, index) {
                  return CourseCard(
                    title: striveCourses[index]['title']!,
                    image: striveCourses[index]['image']!,
                    url: striveCourses[index]['url']!,
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Professional Skills",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Horizontal scroll - Professional Skills
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: professionalSkills.length,
                itemBuilder: (context, index) {
                  return CourseCard(
                    title: professionalSkills[index]['title']!,
                    image: professionalSkills[index]['image']!,
                    url: professionalSkills[index]['url']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 250),
            // Bottom Banner
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Your calm compass, day and night",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Chat with an expert whenever you need. We're here for you, 24/7",
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          launchUrl(
                            Uri.parse("tel:+911234567890"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text("Call", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          launchUrl(
                            Uri.parse("https://example.com/chat"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text("Chat", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String image;
  final String url;

  const CourseCard({
    super.key,
    required this.title,
    required this.image,
    required this.url,
  });

  Future<void> _launchURL() async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Commander, can't launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launchURL,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 80, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
