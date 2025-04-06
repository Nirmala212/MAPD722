import 'package:flutter/material.dart';

class UpdatePatientRecordScreen extends StatefulWidget {
  final Map<String, String> patient;

  const UpdatePatientRecordScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  _UpdatePatientRecordScreenState createState() =>
      _UpdatePatientRecordScreenState();
}

class _UpdatePatientRecordScreenState extends State<UpdatePatientRecordScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController statusController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the patient's data
    nameController = TextEditingController(text: widget.patient["name"]);
    ageController = TextEditingController(text: widget.patient["age"]);
    statusController = TextEditingController(text: widget.patient["status"]);
  }

  void saveUpdatedPatient() {
    // Here, you should save the updated data to the database or your data source
    // For now, let's just print the updated data
    print(
        "Updated Patient: ${nameController.text}, ${ageController.text}, ${statusController.text}");

    // Once the data is saved, navigate back to the PatientListScreen
    Navigator.pop(
        context); // This will go back to the previous screen (PatientListScreen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Patient Record")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: statusController,
              decoration: const InputDecoration(labelText: "Status"),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: saveUpdatedPatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
