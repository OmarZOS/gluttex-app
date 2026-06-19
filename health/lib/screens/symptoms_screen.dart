import 'package:flutter/material.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});
  @override
  _SymptomScreenState createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  bool _diarrheaIsSelected = false;
  bool _abdominalPainIsSelected = false;
  bool _ironDeficiencyIsSelected = false;
  bool _fatigueIsSelected = false;

  String? _consumption_response;
  String? _quantity_consumed;
  String? _time_since_consumption;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you having symptoms?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          // Add your symptom widgets here
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            children: [
              FilterChip(
                label: const Text('Chronic diarrhea'),
                selected: _diarrheaIsSelected,
                onSelected: (bool value) {
                  setState(() {
                    _diarrheaIsSelected = value;
                  });
                },
                selectedColor: const Color.fromARGB(255, 70, 109,
                    141), // Change to the color you want when selected
              ),
              FilterChip(
                label: const Text('Iron-deficiency anemia'),
                selected: _ironDeficiencyIsSelected,
                onSelected: (bool value) {
                  setState(() {
                    _ironDeficiencyIsSelected = value;
                  });
                },
                selectedColor: const Color.fromARGB(255, 70, 109,
                    141), // Change to the color you want when selected
              ),
              FilterChip(
                label: const Text('Fatigue'),
                selected: _fatigueIsSelected,
                onSelected: (bool value) {
                  setState(() {
                    _fatigueIsSelected = value;
                  });
                },
                selectedColor: const Color.fromARGB(255, 70, 109,
                    141), // Change to the color you want when selected
              ),
              FilterChip(
                label: const Text('Abdominal pain and bloating'),
                selected: _abdominalPainIsSelected,
                onSelected: (bool value) {
                  setState(() {
                    _abdominalPainIsSelected = value;
                  });
                },
                selectedColor: const Color.fromARGB(255, 70, 109,
                    141), // Change to the color you want when selected
              ),
            ],
          ),
          const SizedBox(height: 9.0),
          TextFormField(
            // initialValue: _app_user_name,
            decoration: const InputDecoration(
                labelText: 'Have you consumed a non gluten-free product?'),
            onSaved: (value) => _consumption_response = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a appUser description';
              }

              if ((value).length >= 300) {
                return 'Character limit: 300.';
              }
              return null;
            },
          ),
          const SizedBox(height: 9),
          TextFormField(
            // initialValue: _app_user_name,
            decoration:
                const InputDecoration(labelText: 'Quantity consumed if any'),
            onSaved: (value) => _quantity_consumed = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a appUser description';
              }

              if ((value).length >= 300) {
                return 'Character limit: 300.';
              }
              return null;
            },
          ),
          const SizedBox(height: 9),
          TextFormField(
            // initialValue: _app_user_name,
            decoration: const InputDecoration(
                labelText: 'How much time since it has been consumed?'),
            onSaved: (value) => _time_since_consumption = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a appUser description';
              }

              if ((value).length >= 300) {
                return 'Character limit: 300.';
              }
              return null;
            },
          ),
          const SizedBox(height: 9),
          ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data Submitted successfully."),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Center(
                child: Text("Submit"),
              )),

          const Text(
            'Recommendations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          const Text('1. Avoid gluten-containing products.'),
          const Text('2. Follow a balanced diet.'),
          const Text('3. Keep a symptom diary.'),
          const Text('4. Consult with your healthcare provider regularly.'),
        ],
      ),
    );
  }
}
