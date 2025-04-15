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
  late mongo.DbCollection collection;

  @override
  void initState() {
    super.initState();
    print("Initializing PatientListscreen...");
    _connectToMongoDB();
  }

  Future<void> _connectToMongoDB() async {
    print("Attempting MongoDB connection...");
    try {
      db = await mongo.Db.create(connectionString);
      await db.open();
      print("✅ MongoDB connected successfully.");

      collection = db.collection('patients');
      print("✅ Collection selected: ${collection.collectionName}");

      await fetchPatients();
    } catch (e) {
      print('❌ MongoDB connection error: $e');
    }
  }

  Future<void> fetchPatients() async {
    try {
      final data = await collection.find().toList();
      print("Fetched ${data.length} patients from database.");
      print("Raw data: $data");

      setState(() {
        patients = data.map((patient) {
          // Safety check: assign defaults if missing fields
          final age = patient["age"] ?? 0;
          final temp = patient["temperature"] ?? 98.6;

          patient["status"] = (age > 60 || temp < 98.0) ? "Critical" : "Stable";

          return patient;
        }).toList();
      });
    } catch (e) {
      print('Error fetching patients: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
      appBar: AppBar(title: const Text("List of Patients")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: "Search Patient",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return Card(
                        color: patient["status"] == "Critical"
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        child: ListTile(
                          title: Text(
                            patient["fullName"] ?? "Unknown",
                            style: TextStyle(
                              color: patient["status"] == "Critical"
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Age: ${patient["age"] ?? "-"} | Status: ${patient["status"] ?? "-"}",
                          ),
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
                              await fetchPatients(); // Refresh the list after deletion
                              setState(() {}); // Trigger UI rebuild
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: refreshPatients,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text("Refresh"),
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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
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
