import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqs = [
    {
      'question': ' Cassava Doctor?',
      'answer': 'Cassava Doctor is an app that helps detect and classify diseases in cassava plants using images of their leaves.'
    },
    {
      'question': 'How do I use the disease scanner?',
      'answer': 'Go to the scan page, select or capture a cassava leaf image, and the app will predict possible diseases.'
    },
    {
      'question': 'Can I chat with an expert?',
      'answer': 'Yes, use the Cassava Chatbot in the drawer to ask questions about cassava diseases and farming.'
    },
    {
      'question': 'Where can I find educational content?',
      'answer': 'Open the drawer and tap on "Educational Content" for articles, videos, and tips.'
    },
    {
      'question': 'Is my data private?',
      'answer': 'Yes, your images and questions are only used for disease detection and support within the app.'
    },
    {
      'question': 'Which year and where was Cassava Doctor made?',
      'answer': 'Cassava DOctor is made this year 2025, By UENR student. ITS department.'
    },
  ];

  final TextEditingController _questionController = TextEditingController();
  final List<String> submittedQuestions = [];

  void _submitQuestion() {
    final question = _questionController.text.trim();
    if (question.isNotEmpty) {
      setState(() {
        submittedQuestions.add(question);
        _questionController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your question has been submitted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs & Questions'),
        backgroundColor: Colors.green[700],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 12),
            ...faqs.map((faq) => Card(
                  color: Colors.green[50],
                  child: ExpansionTile(
                    title: Text(
                      faq['question']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          faq['answer']!,
                          style: const TextStyle(fontFamily: 'Roboto'),
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 32),
            const Text(
              'Ask a Question',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                hintText: 'Type your question...',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              child: const Text('Submit'),
            ),
            if (submittedQuestions.isNotEmpty) ...[
              const Divider(height: 32),
              const Text(
                'Your Submitted Questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              ...submittedQuestions.map((q) => ListTile(
                    leading: const Icon(Icons.question_answer, color: Colors.green),
                    title: Text(q),
                  )),
            ]
          ],
        ),
      ),
    );
  }
}
