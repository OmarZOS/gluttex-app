import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'GeoJSON Map',
      home: CeliacScreen(),
    );
  }
}

class Patient {
  String name;
  String diagnosis;
  Map<String, double> bloodTestIndicators;

  Patient(
      {required this.name,
      this.diagnosis = '',
      required this.bloodTestIndicators});
}

class Advice {
  String title;
  String description;

  Advice({required this.title, required this.description});
}

class CeliacScreen extends StatefulWidget {
  const CeliacScreen({super.key});

  @override
  _CeliacScreenState createState() => _CeliacScreenState();
}

class _CeliacScreenState extends State<CeliacScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _diagnosisController = TextEditingController();
  final Map<String, double> _bloodTestIndicators = {
    'Anti-TTG IgA': 0.0,
    'Total IgA': 0.0,
    'Anti-DGP IgG': 0.0,
  };
  final List<Advice> _adviceList = [
    Advice(
        title: 'Gluten-Free Diet',
        description: 'Avoid all foods containing gluten.'),
    Advice(
        title: 'Regular Checkups',
        description: 'Visit your doctor regularly to monitor your condition.'),
  ];
  String _diagnosis = '';

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _diagnosis = _diagnosisController.text;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Diagnosis updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Celiac Patient Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Indicators from Blood Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._bloodTestIndicators.entries.map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }),
            const SizedBox(height: 20),
            const Text(
              'Insert Diagnosis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _diagnosisController,
                    decoration: const InputDecoration(labelText: 'Diagnosis'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a diagnosis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Diagnosis: $_diagnosis',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recommended Advice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._adviceList.map((advice) {
              return ListTile(
                title: Text(advice.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(advice.description),
              );
            }),
          ],
        ),
      ),
    );
  }
}
