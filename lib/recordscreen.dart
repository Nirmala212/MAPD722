import 'package:flutter/material.dart';
import 'package:project/add_testscreen.dart';
import 'package:project/update_recordscreen.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ViewRecordScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  ViewRecordScreen({Key? key, required this.patient}) : super(key: key);

  final List<Map<String, String>> testHistory = [
    {"testName": "Blood Test", "testDate": "2024-01-15", "result": "Normal"},
    {"testName": "X-Ray", "testDate": "2024-02-20", "result": "Clear"},
  ];

  final String connectionString =
      'mongodb+srv://admin:1234@flutterproject.pl66lr6.mongodb.net/test?retryWrites=true&w=majority&appName=flutterProject';

  void _editPatient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePatientRecordScreen(
          patient: patient.map((key, value) => MapEntry(key, value.toString())),
        ),
      ),
    );
  }

  Future<void> _deletePatient(BuildContext context) async {
    print("🧨 Delete button pressed");

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Patient"),
          content: const Text("Are you sure you want to delete this patient?"),
          actions: [
            TextButton(
              onPressed: () async {
                print("✅ YES clicked");

                Navigator.of(dialogContext).pop(); // Close the dialog

                try {
                  final db = await mongo.Db.create(connectionString);
                  await db.open();
                  final collection = db.collection('patients');

                  // Properly handle ObjectId
                  final dynamic idField = patient['_id'];
                  final mongo.ObjectId id = idField is mongo.ObjectId
                      ? idField
                      : mongo.ObjectId.parse(idField.toString());

                  final result = await collection.deleteOne({'_id': id});
                  await db.close();

                  if (result.nRemoved == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Patient deleted successfully!')),
                    );
                    Navigator.of(context).pop(); // Go back one screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to delete patient.')),
                    );
                  }
                } catch (e) {
                  print("❌ Error deleting patient: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error occurred while deleting: $e')),
                  );
                }
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                print("❎ NO clicked");
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _deletePatient(BuildContext context) async {
  //   print("🧨 Delete button pressed");

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Delete Patient"),
  //         content: const Text("Are you sure you want to delete this patient?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.of(context).pop(); // Close the dialog

  //               try {
  //                 final db = await mongo.Db.create(connectionString);
  //                 await db.open();
  //                 final collection = db.collection('patients');

  //                 final idRaw = patient['_id'];
  //                 print("Deleting patient with _id: $idRaw");

  //                 if (idRaw == null) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('Invalid patient ID.')),
  //                   );
  //                   return;
  //                 }

  //                 final mongo.ObjectId id = (idRaw is mongo.ObjectId)
  //                     ? idRaw
  //                     : mongo.ObjectId.parse(idRaw.toString());

  //                 final result = await collection.deleteOne({'_id': id});
  //                 await db.close();

  //                 if (result.nRemoved == 1) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                         content: Text('Patient deleted successfully!')),
  //                   );
  //                   Navigator.of(context).pop(); // Go back one screen
  //                 } else {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                         content: Text('Failed to delete patient.')),
  //                   );
  //                 }
  //               } catch (e) {
  //                 print("Error deleting patient: $e");
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content:
  //                         Text('Error occurred while deleting patient: $e'),
  //                   ),
  //                 );
  //               }
  //             },
  //             child: const Text("Yes"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: const Text("No"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _addTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTestScreen(
          patient: patient.map((key, value) => MapEntry(key, value.toString())),
        ),
      ),
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
            onPressed: () => _editPatient(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePatient(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Full Name: ${patient["fullName"] ?? 'N/A'}",
                style: TextStyle(fontSize: 20)),
            Text("Age: ${patient["age"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Address: ${patient["address"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Medical History: ${patient["medicalHistory"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Contact Info: ${patient["contactInfo"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Room Number: ${patient["roomNumber"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Temperature: ${patient["temperature"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Blood Pressure: ${patient["bloodPressure"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Heart Rate: ${patient["heartRate"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            Text("Respiratory Rate: ${patient["respiratoryRate"] ?? 'N/A'}",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
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
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () => _addTest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
