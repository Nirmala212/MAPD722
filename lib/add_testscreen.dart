import 'package:flutter/material.dart';
import 'package:project/recordscreen.dart';

// Screen to add a new test for the patient
class AddTestScreen extends StatelessWidget {
  final Map<String, String> patient;

  const AddTestScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final testNameController = TextEditingController();
    final testDateController = TextEditingController();
    final resultController = TextEditingController();

    void saveTest() {
      // Save the new test data (you can replace this with actual database logic)
      print(
          "New Test: ${testNameController.text}, ${testDateController.text}, ${resultController.text}");

      // After saving, navigate back to the ViewRecordScreen
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Add New Test")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: testNameController,
              decoration: const InputDecoration(labelText: "Test Name"),
            ),
            TextField(
              controller: testDateController,
              decoration: const InputDecoration(labelText: "Test Date"),
            ),
            TextField(
              controller: resultController,
              decoration: const InputDecoration(labelText: "Test Result"),
            ),
            const Spacer(), // Push the Save button to the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: saveTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue background
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
