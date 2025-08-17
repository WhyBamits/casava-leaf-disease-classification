// lib/pages/result_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_disease_detection/helpers/context_extension.dart';
import 'package:plant_disease_detection/models/model_result.dart';
import 'package:plant_disease_detection/ui/screens/test_pages/report_page.dart';


class ResultPage extends StatelessWidget {
  final File image;
  final ModelResult? result;
  final bool isSingleResult;

  const ResultPage({
    super.key,
    required this.image,
    this.result,
    required this.isSingleResult,
  });

  String get likelyDiseaseName {
    final res = this.result;
    if (res == null) return "";

    final scores = {
      "Mosaic": res.mosaic,
      "Blight": res.blight,
      "Brown Streak": res.brownStreak,
      "Green Mite": res.greenMite,
    };

    final highest = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    return highest.key;
  }

  double get likelyDiseaseValue {
    final res = this.result;
    if (res == null) return 0;

    final scores = {
      "Mosaic": res.mosaic,
      "Blight": res.blight,
      "Brown Streak": res.brownStreak,
      "Green Mite": res.greenMite,
    };

    final highest = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    return highest.value;
  }

  @override
  Widget build(BuildContext context) {
    return BlurImageBg(
      file: image,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Scan Result"),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.all(30.0),
          children: [
            Container(
              height: context.width * 0.8,
              width: context.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(
                  color: Colors.white,
                  width: 5,
                ),
                image: DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white, height: 0, thickness: 1),
            const SizedBox(height: 30),
            const Text(
              "Scan Result",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (_) {
                if (result == null) return const SizedBox.shrink();

                if (isSingleResult) {
                  return Column(
                    children: [
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ResultInfo(
                          diseaseName: likelyDiseaseName,
                          value: likelyDiseaseValue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportPage(diseaseName: likelyDiseaseName),
                            ),
                          );
                        },
                        child: const Text('Read More'),
                      ),
                    ],
                  );
                } else {
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ResultInfo(
                          diseaseName: "Mosaic",
                          value: result?.mosaic,
                        ),
                        const Divider(height: 0),
                        ResultInfo(
                          diseaseName: "Blight",
                          value: result?.blight,
                        ),
                        const Divider(height: 0),
                        ResultInfo(
                          diseaseName: "Green Mite",
                          value: result?.greenMite,
                        ),
                        const Divider(height: 0),
                        ResultInfo(
                          diseaseName: "Brown Streak",
                          value: result?.brownStreak,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ResultInfo extends StatelessWidget {
  const ResultInfo({
    super.key,
    required this.diseaseName,
    required this.value,
  });

  final String diseaseName;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Image.asset("assets/images/logo.png", height: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              diseaseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                "${(value ?? 0).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: ((value ?? 0) / 100),
                  strokeWidth: 5,
                  backgroundColor: context.primaryColor.withOpacity(.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.primaryColor,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BlurImageBg extends StatelessWidget {
  final Widget child;
  final File file;
  const BlurImageBg({super.key, required this.child, required this.file});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          ),
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(.6),
          ),
        ),
        child,
      ],
    );
  }
}
