import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class EditTestScreen extends StatefulWidget {
  final Map<String, dynamic> test;

  const EditTestScreen({Key? key, required this.test}) : super(key: key);

  @override
  State<EditTestScreen> createState() => _EditTestScreenState();
}

class _EditTestScreenState extends State<EditTestScreen> {
  late TextEditingController resultController;
  late TextEditingController valueController;
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
      'mongodb+srv://admin:1234@flutterproject.pl66lr6.mongodb.net/test?retryWrites=true&w=majority&appName=flutterProject';

  @override
  void initState() {
    super.initState();

    resultController = TextEditingController(text: widget.test['result']);
    valueController =
        TextEditingController(text: widget.test['testValue'].toString());

    dateController = TextEditingController(
      text: widget.test['testDate'] is DateTime
          ? (widget.test['testDate'] as DateTime)
              .toIso8601String()
              .split('T')
              .first
          : widget.test['testDate'].toString(),
    );

    selectedTest = widget.test['testName'];
    selectedDate = DateTime.tryParse(widget.test['testDate'].toString());
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

  void updateTest() async {
    if (resultController.text.isEmpty || valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

    final formattedDate = selectedDate != null
        ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
        : widget.test['testDate'].toString();

    final testData = {
      "testName": selectedTest ?? widget.test['testName'],
      "testDate": formattedDate,
      "result": resultController.text,
      "testValue": valueController.text,
    };

    try {
      final db = await mongo.Db.create(connectionString);
      await db.open();

      final medicalTestCollection = db.collection('medicalTest');
      await medicalTestCollection.updateOne(
        mongo.where.id(widget.test['_id']),
        mongo.ModifierBuilder()
          ..set('testName', testData['testName'])
          ..set('testDate', testData['testDate'])
          ..set('result', testData['result'])
          ..set('testValue', testData['testValue']),
      );

      await db.close();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test updated successfully!')),
      );

      Navigator.pop(context, 'updated');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating test: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Test Information",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Test Name",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
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
                  decoration: const InputDecoration(
                    labelText: "Test Date",
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
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
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: resultController,
              decoration: const InputDecoration(
                labelText: "Test Result",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: updateTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Save Changes",
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
