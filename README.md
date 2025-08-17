
# 🌿 Cassava Leaf Disease Classification - Flutter App

A Flutter mobile application that classifies cassava leaf diseases using a machine learning model. The app allows users (especially farmers and agricultural experts) to identify cassava plant health issues by capturing or uploading an image of a cassava leaf. The model predicts the disease type and helps guide timely interventions.

---

## 🚀 Features

* 📸 Capture or upload a photo of a cassava leaf
* 🤖 On-device ML model or API integration for disease classification
* 📊 Instant predictions with confidence scores
* 📝 Disease information and suggested treatments
* 🌐 Multilingual support (optional)
* 🔌 Offline support (if using on-device model)
* 🎨 Clean and intuitive UI

---

## 🧠 Machine Learning Model

The classification model is trained to identify the following cassava leaf conditions:

| Class Label              | Description                      |
| ------------------------ | -------------------------------- |
| Cassava Bacterial Blight | Yellowing, wilting               |
| Cassava Brown Streak     | Yellow patches, root rot         |
| Cassava Mosaic Disease   | Mosaic pattern, leaf distortion  |
| Green Mite Damage        | Leaf discoloration, edge curling |
| Healthy                  | No visible disease symptoms      |

**Model Format:**

* TensorFlow Lite (`.tflite`) for on-device inference
  *or*
* REST API using Flask/Django backend with hosted model


## 🧰 Tech Stack

| Tech                      | Usage                          |
| ------------------------- | ------------------------------ |
| Flutter                   | Frontend framework             |
| Dart                      | Programming language           |
| TensorFlow Lite           | ML model inference (on-device) |
| Python + Flask (optional) | Backend model serving (API)    |
| Firebase (optional)       | Image storage or analytics     |

---

## 🛠️ How to Run the App

1. **Clone the repository**

   ```bash
   
   cd cassava-leaf-disease-classification
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   ```bash
   flutter run
   ```

4. **(Optional)** Add your `.tflite` model and labels to the assets folder.

---

## 🧪 Dataset Used

* [Cassava Leaf Disease Dataset](https://www.kaggle.com/datasets/c/plant-pathology/cassava-leaf-disease-classification)
* Includes \~21,000 labeled cassava leaf images across 5 classes

---

## 🔍 How Classification Works

1. The user uploads or takes a photo of a cassava leaf.
2. The app processes the image and resizes it to the expected model input shape.
3. The image is passed through the trained model.
4. The model outputs a prediction with probabilities.
5. The predicted class and its info are shown to the user.

---

## 📁 Project Structure

```bash
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── upload_screen.dart
│   └── result_screen.dart
├── services/
│   ├── model_inference.dart
├── utils/
│   └── disease_info.dart
assets/
├── model.tflite
├── labels.txt
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
  image_picker: ^latest
  tflite: ^latest
  flutter_spinkit: ^latest
  path_provider: ^latest
```

---

## 📌 Future Enhancements

* 📡 Cloud inference fallback
* 📚 In-app disease treatment guide
* 🔍 Model accuracy improvements
* 🧪 Model training notebook (for contributors)
* 🌍 Localization & multi-language support

---

## 🤝 Contributing

Pull requests and contributions are welcome! Please fork the repository and submit a PR.

---

## 📜 License

This project is open-source under the MIT License.

---

## 🙋‍♂️ Acknowledgments

* TensorFlow Team
* Kaggle Cassava Leaf Disease Dataset
* Flutter Dev Community


## 📱 App Screenshots
Let me know if you'd like a markdown copy or a `README.md` file directly.

Casava leaf disease![IMG-20250723-WA0001](https://github.com/user-attachments/assets/42e76f6e-5b5e-4c73-8ccd-6905e6ddc302)
![IMG-20250723-WA0002](https://github.com/user-attachments/assets/15caf9a1-56d1-43a3-8d05-5850ff12622e)
![IMG-20250723-WA0003](https://github.com/user-attachments/assets/ff3f41ce-2b06-44d2-bc76-5817bbd38d31)
![IMG-20250723-WA0004](https://github.com/user-attachments/assets/dbcafb46-f234-41e0-890a-32d5350c06e4)
![IMG-20250723-WA0006](https://github.com/user-attachments/assets/a372cc76-9b00-493f-a5f8-b130a8898799)
![IMG-20250723-WA0005](https://github.com/user-attachments/assets/f3ef166a-5000-44ae-bda8-aab02c4af52d)
![IMG-20250723-WA0007](https://github.com/user-attachments/assets/4011b832-e75c-451c-a3c9-057f8909ef21)
![IMG-20250723-WA0009](https://github.com/user-attachments/assets/e7fcc8ac-24dc-4537-a361-5c55d06fba3e)
![IMG-20250723-WA0008](https://github.com/user-attachments/assets/b3fc6d99-cf65-4bf9-a04c-78a77df68f19)
![IMG-20250723-WA0010](https://github.com/user-attachments/assets/9e922926-c11b-4ba0-9dc4-e9989ced1516)
![IMG-20250723-WA0011](https://github.com/user-attachments/assets/f23e385b-fe50-4029-ae20-c11f6a344ccc)
 classification mobile app dart
Screenshots
