import 'package:flutter/material.dart';
import 'package:project/add_testscreen.dart';
import 'package:project/update_recordscreen.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ViewRecordScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ViewRecordScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<ViewRecordScreen> createState() => _ViewRecordScreenState();
}

class _ViewRecordScreenState extends State<ViewRecordScreen> {
  late Map<String, dynamic> patient;

  final String connectionString =
      'mongodb+srv://admin:1234@flutterproject.pl66lr6.mongodb.net/test?retryWrites=true&w=majority&appName=flutterProject';

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
  }

  mongo.ObjectId extractObjectId(dynamic idField) {
    try {
      if (idField is mongo.ObjectId) {
        return idField;
      }

      final idStr = idField.toString();

      if (idStr.startsWith('ObjectId("') && idStr.endsWith('")')) {
        final hex = idStr.substring(10, 34);
        return mongo.ObjectId.parse(hex);
      }

      if (idStr.length == 24 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(idStr)) {
        return mongo.ObjectId.parse(idStr);
      }
    } catch (_) {}

    throw ArgumentError('Invalid ObjectId format: $idField');
  }

  Future<void> _fetchLatestPatientData() async {
    try {
      final db = await mongo.Db.create(connectionString);
      await db.open();
      final collection = db.collection('patients');

      final id = extractObjectId(patient['_id']);

      final latest = await collection.findOne({'_id': id});
      await db.close();

      if (latest != null) {
        setState(() {
          patient = latest;
        });
      }
    } catch (e) {
      print("❌ Error fetching updated patient data: $e");
    }
  }

  Future<void> _editPatient(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePatientRecordScreen(
          patient: patient.map((key, value) => MapEntry(key, value.toString())),
        ),
      ),
    );

    if (result == 'updated') {
      await _fetchLatestPatientData();
    }
  }

  Future<void> _addTest(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTestScreen(
          patient: patient.map((key, value) => MapEntry(key, value.toString())),
        ),
      ),
    );

    if (result == 'test_added') {
      await _fetchLatestPatientData();
    }
  }

  Future<void> _deletePatient(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Patient"),
          content: const Text("Are you sure you want to delete this patient?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog

                try {
                  final db = await mongo.Db.create(connectionString);
                  await db.open();
                  final collection = db.collection('patients');

                  final idField = patient['_id'];
                  late mongo.ObjectId id;

                  if (idField is mongo.ObjectId) {
                    id = idField;
                  } else if (idField is Map && idField['\$oid'] != null) {
                    id = mongo.ObjectId.parse(idField['\$oid']);
                  } else if (idField is String) {
                    String formattedId = idField;
                    if (formattedId.startsWith("ObjectId(")) {
                      formattedId = formattedId
                          .replaceAll('ObjectId("', '')
                          .replaceAll('")', '');
                    }
                    id = mongo.ObjectId.parse(formattedId);
                  } else {
                    throw Exception("Invalid _id format");
                  }

                  final result = await collection.deleteOne({'_id': id});
                  await db.close();

                  if (result.nRemoved == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Patient deleted successfully!')),
                    );
                    Navigator.of(context)
                        .pop('deleted'); // Pop to previous screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to delete patient.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error occurred while deleting: $e')),
                  );
                }
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("No"),
            ),
          ],
        );
      },
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
        child: SingleChildScrollView(
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
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () => _addTest(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
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
      ),
    );
  }
}
