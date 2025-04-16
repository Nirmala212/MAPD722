import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project/recordscreen.dart';

class PatientListscreen extends StatefulWidget {
  const PatientListscreen({super.key});

  @override
  PatientListscreenState createState() => PatientListscreenState();
}

class PatientListscreenState extends State<PatientListscreen> {
  TextEditingController searchController = TextEditingController();
  String selectedFilter = Filter.ALL;
  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;

  final String connectionString =
      'mongodb+srv://admin:1234@flutterproject.pl66lr6.mongodb.net/test?retryWrites=true&w=majority&appName=flutterProject';

  late mongo.Db db;
  late mongo.DbCollection patientCollection;
  late mongo.DbCollection testCollection;

  // Define normal test ranges
  final Map<String, List<double>> testRanges = {
    "Temperature": [36.5, 37.5],
    "Blood Pressure": [80, 120], // If systolic only
    "Blood Sugar": [70, 140],
    "Heart Rate": [60, 100],
  };

  @override
  void initState() {
    super.initState();
    _connectToMongoDB();
  }

  Future<void> _connectToMongoDB() async {
    try {
      db = await mongo.Db.create(connectionString);
      await db.open();
      patientCollection = db.collection('patients');
      testCollection = db.collection('medicalTest');
      await fetchPatients();
    } catch (e) {
      print('❌ MongoDB connection error: $e');
    }
  }

  Future<void> fetchPatients() async {
    try {
      final data = await patientCollection.find().toList();
      List<Map<String, dynamic>> updatedPatients = [];

      for (var patient in data) {
        final tests = await testCollection
            .find(mongo.where
                .eq('patientId', patient['_id'].toString())
                .sortBy('testDate', descending: true))
            .toList();

        String status = "Stable";

        if (tests.isNotEmpty) {
          final latestTest = tests.first;
          final testName = latestTest['testName'];
          final testValue = double.tryParse(latestTest['testValue'].toString());

          if (testName != null &&
              testValue != null &&
              testRanges.containsKey(testName)) {
            final range = testRanges[testName]!;

            if (testValue < range[0] || testValue > range[1]) {
              status = "Critical";
            }
          }
        }

        patient["status"] = status;
        updatedPatients.add(patient);
      }

      if (mounted) {
        setState(() {
          patients = updatedPatients;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  List<Map<String, dynamic>> get filteredPatients {
    return patients.where((patient) {
      final matchesSearch = searchController.text.isEmpty ||
          (patient["fullName"] ?? "")
              .toString()
              .toLowerCase()
              .contains(searchController.text.toLowerCase());

      final matchesFilter = selectedFilter == Filter.ALL ||
          (patient["status"] ?? "").toString().toLowerCase() ==
              selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void refreshPatients() {
    setState(() {
      searchController.clear();
      selectedFilter = Filter.ALL;
      isLoading = true;
    });
    fetchPatients();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:
            const Text("Patient List", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Search Patient",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilterButton(
                            label: "ALL",
                            selectedFilter: selectedFilter,
                            color: Colors.blue,
                            onPressed: () =>
                                setState(() => selectedFilter = Filter.ALL),
                          ),
                          FilterButton(
                            label: "STABLE",
                            selectedFilter: selectedFilter,
                            color: Colors.green,
                            onPressed: () =>
                                setState(() => selectedFilter = Filter.STABLE),
                          ),
                          FilterButton(
                            label: "CRITICAL",
                            selectedFilter: selectedFilter,
                            color: Colors.red,
                            onPressed: () => setState(
                                () => selectedFilter = Filter.CRITICAL),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        final isCritical = patient["status"] == "Critical";
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: isCritical
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          child: ListTile(
                            leading: Icon(
                              Icons.person,
                              color: isCritical ? Colors.red : Colors.green,
                              size: 30,
                            ),
                            title: Text(
                              patient["fullName"] ?? "Unknown",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isCritical ? Colors.red : Colors.green[800],
                              ),
                            ),
                            subtitle: Text(
                              "Age: ${patient["age"] ?? "-"} | Status: ${patient["status"] ?? "-"}",
                              style: const TextStyle(fontSize: 15),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewRecordScreen(
                                    patient: patient.map((key, value) =>
                                        MapEntry(key, value.toString())),
                                  ),
                                ),
                              );

                              if (result == 'deleted') {
                                await fetchPatients();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton.icon(
                    onPressed: refreshPatients,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 27, 108, 229),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final String selectedFilter;
  final VoidCallback onPressed;
  final Color color;

  const FilterButton({
    required this.label,
    required this.selectedFilter,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = label == selectedFilter;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(label),
    );
  }
}

class Filter {
  static const String ALL = "ALL";
  static const String STABLE = "Stable";
  static const String CRITICAL = "Critical";
}
