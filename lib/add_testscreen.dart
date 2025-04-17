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

  // Define acceptable value ranges for each test
  final Map<String, Map<String, double>> testRanges = {
    'Temperature': {'min': 95.0, 'max': 104.0}, // Fahrenheit
    'Blood Pressure': {'min': 80.0, 'max': 180.0}, // Systolic
    'Blood Sugar': {'min': 70.0, 'max': 200.0}, // mg/dL
    'Heart Rate': {'min': 40.0, 'max': 180.0}, // bpm
  };

  String? selectedTest;
  DateTime? selectedDate;

  final String connectionString =
      'mongodb://admin:1234@ac-uru0tue-shard-00-00.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-01.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-02.pl66lr6.mongodb.net:27017/?replicaSet=atlas-4lamuj-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=flutterProject';

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
  }

  mongo.ObjectId _extractObjectId(String rawId) {
    if (rawId.startsWith('ObjectId("') && rawId.endsWith('")')) {
      return mongo.ObjectId.parse(rawId.substring(10, rawId.length - 2));
    }
    return mongo.ObjectId.parse(rawId);
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
        valueController.text.isEmpty ||
        resultController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

    final formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    try {
      final testValue = double.tryParse(valueController.text);
      if (testValue == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid test value')),
        );
        return;
      }

      // Check if test value is within range
      final range = testRanges[selectedTest];
      if (range != null &&
          (testValue < range['min']! || testValue > range['max']!)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$selectedTest value must be between ${range['min']} and ${range['max']}',
            ),
          ),
        );
        return;
      }

      final testData = {
        "patientId": _extractObjectId(widget.patient['_id']!),
        "testName": selectedTest,
        "testDate": selectedDate,
        "testValue": testValue,
        "result": resultController.text,
      };

      final db = await mongo.Db.create(connectionString);
      await db.open();

      final medicalTestCollection = db.collection('medicalTest');
      await medicalTestCollection.insert(testData);

      await db.close();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test saved to medicalTest collection!')),
      );

      Navigator.pop(context, 'test_added');
    } catch (e, stacktrace) {
      print("❌ Error saving test: $e\n$stacktrace");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving test: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Add New Test", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Test Name",
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
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
                  decoration: InputDecoration(
                    labelText: "Test Date",
                    labelStyle: const TextStyle(fontSize: 16),
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Test Value",
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: resultController,
              decoration: const InputDecoration(
                labelText: "Result",
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: saveTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Save Test",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
