import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo show Db, ObjectId;

class AddTestScreen extends StatefulWidget {
  final Map<String, String> patient;

  const AddTestScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<AddTestScreen> createState() => _AddTestScreenState();
}

class _AddTestScreenState extends State<AddTestScreen> {
  final TextEditingController resultController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  late TextEditingController dateController;

  final List<String> testOptions = [
    'Temperature',
    'Blood Pressure',
    'Blood Sugar',
    'Heart Rate',
  ];

  String? selectedTest;
  DateTime? selectedDate;

  final String connectionString =
      'mongodb://admin:1234@ac-uru0tue-shard-00-00.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-01.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-02.pl66lr6.mongodb.net:27017/?replicaSet=atlas-4lamuj-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=flutterProject';

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
  }

  void _pickTestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void saveTest() async {
    if (selectedTest == null ||
        selectedDate == null ||
        resultController.text.isEmpty ||
        valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

    final formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    final testData = {
      "patientId": mongo.ObjectId.parse(widget.patient['_id']!),
      "testName": selectedTest,
      "testDate": formattedDate,
      "result": resultController.text,
      "testValue": valueController.text,
    };

    try {
      final db = await mongo.Db.create(connectionString);
      await db.open();

      final medicalTestCollection = db.collection('medicalTest');
      await medicalTestCollection.insert(testData);

      await db.close();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test saved to medicalTest collection!')),
      );

      Navigator.pop(
          context, testData); // Return the test data to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving test: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Test")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Test Name"),
              value: selectedTest,
              items: testOptions.map((test) {
                return DropdownMenuItem(
                  value: test,
                  child: Text(test),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTest = value;
                });
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickTestDate,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: "Test Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Test Value"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: resultController,
              decoration: const InputDecoration(labelText: "Test Result"),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: saveTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Save Test",
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
