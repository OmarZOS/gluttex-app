import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CeliacScreen extends StatefulWidget {
  @override
  _CeliacScreenState createState() => _CeliacScreenState();
}

class _CeliacScreenState extends State<CeliacScreen> {
  bool _diarrheaIsSelected = false;
  bool _abdominalPainIsSelected = false;
  bool _ironDeficiencyIsSelected = false;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: Container(
            color: const Color.fromARGB(255, 131, 103, 66),
            child: TabBar(
              // indicatorColor: Colors.orangeAccent,
              tabs: [
                const Tab(icon: Icon(CupertinoIcons.suit_heart)),
                const Tab(icon: Icon(CupertinoIcons.waveform_path_ecg)),
                const Tab(icon: Icon(CupertinoIcons.info_circle)),
              ],
              indicatorColor: Colors.orange,
              // overlayColor: Colors.orange,
              labelColor: Colors
                  .orange, // Optional: set the color of the selected tab label
              unselectedLabelColor: Colors
                  .grey, // Optional: set the color of the unselected tab labels
            )),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you having symptoms?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  // Add your symptom widgets here
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    children: [
                      FilterChip(
                        label: Text('Chronic diarrhea'),
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
                        label: Text('Iron-deficiency anemia'),
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
                        label: Text('Abdominal pain and bloating'),
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
                  SizedBox(height: 9.0),
                  TextFormField(
                    // initialValue: _app_user_name,
                    decoration: const InputDecoration(
                        labelText: 'Have you eaten a non gluten-free product?'),
                    // onSaved: (value) => _app_user_name = value,
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
                  SizedBox(height: 9),
                  TextFormField(
                    // initialValue: _app_user_name,
                    decoration:
                        const InputDecoration(labelText: 'Quantity consumed'),
                    // onSaved: (value) => _app_user_name = value,
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
                  SizedBox(height: 9),
                  TextFormField(
                    // initialValue: _app_user_name,
                    decoration:
                        const InputDecoration(labelText: 'How much time?'),
                    // onSaved: (value) => _app_user_name = value,
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
                  Text(
                    'Recommendations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Text('1. Avoid gluten-containing products.'),
                  Text('2. Follow a balanced diet.'),
                  Text('3. Keep a symptom diary.'),
                  Text('4. Consult with your healthcare provider regularly.'),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blood Tests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  _buildLineChart('TTG-IgA', [10, 12, 14, 13, 15], Colors.blue),
                  SizedBox(height: 16.0),
                  _buildLineChart('DGP-IgA and DGP-IgG', [20, 22, 21, 23, 24],
                      Colors.green, [15, 18, 17, 19, 21], Colors.orange),
                  SizedBox(height: 16.0),
                  _buildLineChart('EMA-IgA', [30, 32, 31, 33, 34], Colors.red),
                  SizedBox(height: 16.0),
                  _buildLineChart(
                      'Total Serum IgA', [40, 42, 41, 43, 44], Colors.purple),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is Celiac Disease?',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Celiac disease is a serious autoimmune disorder that can occur in genetically predisposed people where the ingestion of gluten leads to damage in the small intestine.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Symptoms:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Common symptoms of celiac disease include diarrhea, abdominal pain, bloating, weight loss, fatigue, and more.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Diagnosis and Treatment:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Celiac disease can be diagnosed through blood tests and confirmed with a biopsy of the small intestine. Treatment involves a strict gluten-free diet.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Living with Celiac Disease:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Living with celiac disease requires careful attention to diet and lifestyle. It is essential to avoid gluten-containing foods and be vigilant about cross-contamination.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Resources and Support:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'There are many resources available for individuals with celiac disease, including support groups, online communities, and dietary guides.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Consult Your Doctor:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'If you suspect you have celiac disease or have been diagnosed, it is crucial to work closely with your healthcare provider to manage your condition effectively.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(String title, List<double> values, Color color,
      [List<double>? secondaryValues, Color? secondaryColor]) {
    List<FlSpot> spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    List<FlSpot>? secondarySpots;
    if (secondaryValues != null) {
      secondarySpots = secondaryValues
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.0),
        Container(
          height: 200,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitles: (value) {
                    return 'Day ${value.toInt()}';
                  },
                ),
                leftTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  getTitles: (value) {
                    return value.toString();
                  },
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 4,
                  colors: [color],
                  belowBarData: BarAreaData(show: false),
                ),
                if (secondarySpots != null)
                  LineChartBarData(
                    spots: secondarySpots,
                    isCurved: true,
                    barWidth: 4,
                    colors: [secondaryColor!],
                    belowBarData: BarAreaData(show: false),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void main() => runApp(MaterialApp(home: CeliacScreen()));
