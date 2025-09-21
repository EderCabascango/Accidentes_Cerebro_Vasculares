import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const StrokePredictorApp());
}

class StrokePredictorApp extends StatelessWidget {
  const StrokePredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stroke Predictor',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const PredictorForm(),
    );
  }
}

class PredictorForm extends StatefulWidget {
  const PredictorForm({super.key});

  @override
  State<PredictorForm> createState() => _PredictorFormState();
}

class _PredictorFormState extends State<PredictorForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final ageController = TextEditingController();
  final glucoseController = TextEditingController();
  final bmiController = TextEditingController();

  String gender = 'Male';
  String everMarried = 'No';
  String workType = 'Private';
  String residenceType = 'Urban';
  String smokingStatus = 'never smoked';
  bool hypertension = false;
  bool heartDisease = false;

  String result = "";

  Future<void> predictStroke() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/predict/');

    final body = {
      "gender": gender,
      "age": double.parse(ageController.text),
      "hypertension": hypertension ? 1 : 0,
      "heart_disease": heartDisease ? 1 : 0,
      "ever_married": everMarried,
      "work_type": workType,
      "Residence_type": residenceType,
      "avg_glucose_level": double.parse(glucoseController.text),
      "bmi": double.parse(bmiController.text),
      "smoking_status": smokingStatus,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          result = data["stroke_prediction"] == 1
              ? "¡Alto riesgo de ACV!"
              : "Bajo riesgo de ACV.";
        });
      } else {
        setState(() {
          result = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error de conexión: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Predicción de ACV')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: glucoseController,
                decoration: const InputDecoration(
                  labelText: 'Nivel de glucosa',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: bmiController,
                decoration: const InputDecoration(labelText: 'IMC'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text("Hipertensión"),
                value: hypertension,
                onChanged: (value) => setState(() => hypertension = value),
              ),
              SwitchListTile(
                title: const Text("Enfermedad cardíaca"),
                value: heartDisease,
                onChanged: (value) => setState(() => heartDisease = value),
              ),
              DropdownButtonFormField(
                value: gender,
                decoration: const InputDecoration(labelText: 'Género'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Female', child: Text('Femenino')),
                ],
                onChanged: (value) => setState(() => gender = value!),
              ),
              DropdownButtonFormField(
                value: everMarried,
                decoration: const InputDecoration(labelText: 'Casado'),
                items: const [
                  DropdownMenuItem(value: 'Yes', child: Text('Sí')),
                  DropdownMenuItem(value: 'No', child: Text('No')),
                ],
                onChanged: (value) => setState(() => everMarried = value!),
              ),
              DropdownButtonFormField(
                value: workType,
                decoration: const InputDecoration(labelText: 'Tipo de trabajo'),
                items: const [
                  DropdownMenuItem(value: 'Private', child: Text('Privado')),
                  DropdownMenuItem(
                    value: 'Self-employed',
                    child: Text('Independiente'),
                  ),
                  DropdownMenuItem(value: 'Govt_job', child: Text('Gobierno')),
                  DropdownMenuItem(value: 'children', child: Text('Niño')),
                  DropdownMenuItem(
                    value: 'Never_worked',
                    child: Text('Nunca trabajó'),
                  ),
                ],
                onChanged: (value) => setState(() => workType = value!),
              ),
              DropdownButtonFormField(
                value: residenceType,
                decoration: const InputDecoration(labelText: 'Residencia'),
                items: const [
                  DropdownMenuItem(value: 'Urban', child: Text('Urbano')),
                  DropdownMenuItem(value: 'Rural', child: Text('Rural')),
                ],
                onChanged: (value) => setState(() => residenceType = value!),
              ),
              DropdownButtonFormField(
                value: smokingStatus,
                decoration: const InputDecoration(labelText: 'Tabaquismo'),
                items: const [
                  DropdownMenuItem(
                    value: 'formerly smoked',
                    child: Text('Exfumador'),
                  ),
                  DropdownMenuItem(
                    value: 'never smoked',
                    child: Text('Nunca fumó'),
                  ),
                  DropdownMenuItem(value: 'smokes', child: Text('Fumador')),
                  DropdownMenuItem(
                    value: 'Unknown',
                    child: Text('Desconocido'),
                  ),
                ],
                onChanged: (value) => setState(() => smokingStatus = value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: predictStroke,
                child: const Text("Predecir"),
              ),
              const SizedBox(height: 20),
              Text(result, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
