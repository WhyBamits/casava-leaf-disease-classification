import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:plant_disease_detection/services/image_classifier_http.dart';
import 'package:plant_disease_detection/ui/providers/model_threshold.dart';
import 'package:plant_disease_detection/ui/providers/model_type_provider.dart';
import 'package:plant_disease_detection/ui/widgets/credits_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final modelType = ref.watch(modelTypeProvider);
    final notifier = ref.read(modelTypeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("Classifier Settings")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Select Model",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Your selection will determine which model to processes the image",
                      ),
                    ],
                  ),
                ),ModelTypeTile(
                  title: "Recommended Model",
                  subtitle: "This option allows process your image using "
                      "an advanced model with improved accuracy for detecting plant diseases.",
                  isSelected: modelType == ModelType.version2,
                  onTap: () => notifier.changeType(ModelType.version2),
                ),
                ModelTypeTile(
                  title: "Server model (HTTP)",
                  subtitle: "This option allows your request to be processed "
                      "on a django server running the model. This option is slow "
                      "and has a max file size of 1.0MB.",
                  isSelected: modelType == ModelType.version3,
                  onTap: () => notifier.changeType(ModelType.version3),
                ),
               
              /*    ModelTypeTile(
                  title: "Server model (HTTP)",
                  subtitle: "This option allows your request to be processed "
                      "on a django server running the model. This option is slow "
                      "and has a max file size of ${ImageClassifierHttp.maxSizeInMb}MB",
                  isSelected: modelType == ModelType.http,
                  onTap: () => notifier.changeType(ModelType.http),
                ), */
                Divider(color: Colors.grey[300]),
                Consumer(
                  builder: (_, ref, __) {
                    final value = ref.watch(modelThresholdProvider);
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Invalid Result Threshold",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Any result below the set threshold is regarded as an invalid result. "
                            "Hence, if all results are below the set threshold, the input is regarded as invalid.",
                          ),
                          const SizedBox(height: 10),
                          Text("Threshold: $value%", style: TextStyle(fontSize: 18),),
                          const SizedBox(height: 16),
                          Slider(
                            value: value.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 10,
                            onChanged: ref
                                .read(modelThresholdProvider.notifier)
                                .changeThreshold,
                            label: "$value%",
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          CreditsWidget(textColor: Colors.black),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ModelTypeTile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isSelected;
  const ModelTypeTile({
    super.key,
    this.title,
    this.subtitle,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title ?? "NA"),
      subtitle: subtitle == null ? null : Text(subtitle!),
      onTap: onTap,
      leading: Checkbox(value: isSelected, onChanged: (_) => onTap?.call()),
    );
  }
}
