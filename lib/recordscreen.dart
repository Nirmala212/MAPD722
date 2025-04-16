import 'package:flutter/material.dart';
import 'package:project/add_testscreen.dart';
import 'package:project/update_recordscreen.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project/edit_testscreen.dart';

class ViewRecordScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ViewRecordScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<ViewRecordScreen> createState() => _ViewRecordScreenState();
}

class _ViewRecordScreenState extends State<ViewRecordScreen> {
  late Map<String, dynamic> patient;
  List<Map<String, dynamic>> testList = [];

  final String connectionString =
      'mongodb+srv://admin:1234@flutterproject.pl66lr6.mongodb.net/test?retryWrites=true&w=majority&appName=flutterProject';

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
    _fetchTestData();
  }

  mongo.ObjectId extractObjectId(dynamic idField) {
    try {
      if (idField is mongo.ObjectId) return idField;

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

  Future<void> _fetchTestData() async {
    try {
      final db = await mongo.Db.create(connectionString);
      await db.open();
      final testCollection = db.collection('medicalTest');

      final patientId = extractObjectId(patient['_id']);
      final tests = await testCollection
          .find(mongo.where
              .eq('patientId', patientId)
              .sortBy('testDate', descending: true))
          .toList();

      await db.close();

      setState(() {
        testList = tests.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("❌ Error fetching test data: $e");
    }
  }

  Future<void> _deleteTest(String testId) async {
    try {
      final db = await mongo.Db.create(connectionString);
      await db.open();
      final testCollection = db.collection('medicalTest');

      String cleanId = testId;
      if (testId.startsWith("ObjectId(")) {
        cleanId = testId
            .replaceAll("ObjectId(", "")
            .replaceAll(")", "")
            .replaceAll("'", "")
            .replaceAll("\"", "");
      }

      final result = await testCollection
          .deleteOne({'_id': mongo.ObjectId.parse(cleanId)});
      await db.close();

      if (result.nRemoved == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test deleted successfully!')),
        );
        _fetchTestData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete test.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while deleting: $e')),
      );
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
      await _fetchTestData();
    }
  }

  Future<void> _editTest(
      BuildContext context, Map<String, dynamic> test) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTestScreen(test: test),
      ),
    );

    if (result == 'updated' || result == 'test_updated') {
      await _fetchTestData();
    }
  }

  Future<void> _editPatient(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePatientRecordScreen(
          // patient: patient.map((key, value) => MapEntry(key, value.toString())),
          patient: Map<String, dynamic>.from(patient),
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        patient = result;
      });
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
                Navigator.of(dialogContext).pop();

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
                    Navigator.of(context).pop('deleted');
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
        title:
            const Text("Patient Record", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
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
              // Patient Information Section
              _buildPatientInfoSection(),

              const SizedBox(height: 30),
              const Divider(),
              const Text(
                "Medical Test History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Test History Section
              testList.isEmpty
                  ? const Text("No test records found.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: testList.length,
                      itemBuilder: (context, index) {
                        final test = testList[index];
                        return _buildTestHistoryCard(context, test);
                      },
                    ),

              const SizedBox(height: 20),
              // Add Test Button
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () => _addTest(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  child: const Text("Add New Test",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build patient info section
  Widget _buildPatientInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatientInfoItem("Full Name", patient["fullName"]),
        _buildPatientInfoItem("Age", patient["age"].toString()),
        _buildPatientInfoItem("Address", patient["address"]),
        _buildPatientInfoItem("Medical History", patient["medicalHistory"]),
        _buildPatientInfoItem(
            "Contact Info", patient["contactInfo"].toString()),
        _buildPatientInfoItem("Room Number", patient["roomNumber"].toString()),
      ],
    );
  }

  // Helper to build each item in the patient info
  Widget _buildPatientInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Helper to build the test history card
  Widget _buildTestHistoryCard(
      BuildContext context, Map<String, dynamic> test) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Text(test["testName"] ?? "Test Name"),
        subtitle: Text(
          "Date: ${test["testDate"] ?? "N/A"}\nResult: ${test["result"] ?? "N/A"}",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete,
              color: Color.fromARGB(255, 90, 112, 218)),
          onPressed: () => _deleteTest(test["_id"].toString()),
        ),
        onTap: () => _editTest(context, test),
      ),
    );
  }
}
