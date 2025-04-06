import 'package:flutter/material.dart';
import 'package:project/add_testscreen.dart';
import 'package:project/update_recordscreen.dart';

class ViewRecordScreen extends StatelessWidget {
  final Map<String, String> patient;

  ViewRecordScreen({Key? key, required this.patient}) : super(key: key);

  // List of sample test history (You can replace this with actual data from the database)
  final List<Map<String, String>> testHistory = [
    {"testName": "Blood Test", "testDate": "2024-01-15", "result": "Normal"},
    {"testName": "X-Ray", "testDate": "2024-02-20", "result": "Clear"},
  ];

  // Method to handle editing the patient data (you can implement your own logic here)
  void _editPatient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UpdatePatientRecordScreen(patient: patient)),
    );
  }

  // Method to handle deleting the patient data
  void _deletePatient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Patient"),
          content: const Text("Are you sure you want to delete this patient?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Add your delete logic here (e.g., remove patient from database)
                // For example: deletePatient(patient);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Patient deleted successfully!')),
                );
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  // Method to navigate to AddTestScreen to add new test
  void _addTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTestScreen(patient: patient)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Record"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPatient(context), // Call edit function
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePatient(context), // Call delete function
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Full Name: ${patient["name"]}",
                style: TextStyle(fontSize: 20)),
            Text("Age: ${patient["age"]}", style: TextStyle(fontSize: 18)),
            Text("Address: ${patient["address"]}",
                style: TextStyle(fontSize: 18)),
            Text("Status: ${patient["status"]}",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // Section for displaying test history
            const Text("Test History:", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: testHistory.length,
                itemBuilder: (context, index) {
                  final test = testHistory[index];
                  return Card(
                    child: ListTile(
                      title: Text(test["testName"]!),
                      subtitle: Text(
                          "Date: ${test["testDate"]} | Result: ${test["result"]}"),
                    ),
                  );
                },
              ),
            ),

            // Button to add a new test
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () => _addTest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue background
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Add New Test",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
