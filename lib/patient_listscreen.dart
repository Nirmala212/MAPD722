import 'package:flutter/material.dart';
import 'package:project/recordscreen.dart';

class PatientListscreen extends StatefulWidget {
  const PatientListscreen({super.key});

  @override
  _PatientListscreenState createState() => _PatientListscreenState();
}

class _PatientListscreenState extends State<PatientListscreen> {
  TextEditingController searchController = TextEditingController();
  String selectedFilter = "ALL";

  // Sample patient data (Replace this with actual data fetched from MongoDB)
  List<Map<String, String>> patients = [
    {"name": "John Doe", "age": "45", "status": "Stable"},
    {"name": "Jane Smith", "age": "34", "status": "Critical"},
    {"name": "Alice Johnson", "age": "29", "status": "Stable"},
    {"name": "Bob Brown", "age": "50", "status": "Critical"},
  ];

  List<Map<String, String>> get filteredPatients {
    return patients.where((patient) {
      final matchesSearch = searchController.text.isEmpty ||
          patient["name"]!
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
      final matchesFilter = selectedFilter == "ALL" ||
          patient["status"]!.toLowerCase() == selectedFilter.toLowerCase();
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void refreshPatients() {
    setState(() {
      // Reset the search field and filter
      searchController.clear();
      selectedFilter = "ALL";

      // Fetch new data from MongoDB or update existing list
      patients = [
        {"name": "John Doe", "age": "45", "status": "Stable"},
        {"name": "Jane Smith", "age": "34", "status": "Critical"},
        {"name": "Alice Johnson", "age": "29", "status": "Stable"},
        {"name": "Bob Brown", "age": "50", "status": "Critical"},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List of Patients")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
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
                            setState(() => selectedFilter = "ALL")),
                    FilterButton(
                        label: "STABLE",
                        selectedFilter: selectedFilter,
                        color: Colors.green,
                        onPressed: () =>
                            setState(() => selectedFilter = "Stable")),
                    FilterButton(
                        label: "CRITICAL",
                        selectedFilter: selectedFilter,
                        color: Colors.red,
                        onPressed: () =>
                            setState(() => selectedFilter = "Critical")),
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
                      patient["name"]!,
                      style: TextStyle(
                        color: patient["status"] == "Critical"
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                        "Age: ${patient["age"]} | Status: ${patient["status"]}"),
                    onTap: () {
                      // Navigate to recordscreen and pass the selected patient
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewRecordScreen(patient: patient),
                        ),
                      );
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
