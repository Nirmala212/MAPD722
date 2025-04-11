import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo; // MongoDB Dart library
import 'package:project/homescreen.dart'; // Your HomeScreen

class AddPatientscreen extends StatefulWidget {
  const AddPatientscreen({super.key});

  @override
  AddPatientscreenState createState() => AddPatientscreenState();
}

class AddPatientscreenState extends State<AddPatientscreen> {
  // TextEditing controllers for all the fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController respiratoryRateController =
      TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController roomNumberController = TextEditingController();

  // MongoDB connection setup (updated with mongodb+srv://)
  final String connectionString =
      'mongodb+srv://admin:1234@flutterproject.pl66lr6.mongodb.net/test?retryWrites=true&w=majority&appName=flutterProject';
  late mongo.Db db;
  late mongo.DbCollection collection;

  @override
  void initState() {
    super.initState();
    _connectToMongoDB();
  }

  // Connect to MongoDB
  Future<void> _connectToMongoDB() async {
    db = await mongo.Db.create(connectionString);
    await db.open();
    collection =
        db.collection('patients'); // 'patients' is your collection name
  }

  // Function to save the patient to MongoDB
  Future<void> savePatient() async {
    final patientData = {
      'fullName': fullNameController.text,
      'age': int.parse(ageController.text),
      'address': addressController.text,
      'medicalHistory': medicalHistoryController.text,
      'temperature': double.parse(temperatureController.text),
      'bloodPressure': bloodPressureController.text,
      'heartRate': heartRateController.text,
      'respiratoryRate': respiratoryRateController.text,
      'contactInfo':
          contactInfoController.text, // Fixed case to match the field
      'roomNumber': roomNumberController.text, // Fixed case to match the field
      'status':
          'Stable', // Default status, can be customized based on conditions
    };

    // Insert data into MongoDB collection
    try {
      await collection.insertOne(patientData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient added successfully!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add patient')),
      );
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    db.close(); // Close the MongoDB connection when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Patient Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              _buildTextField("Full Name", Icons.person,
                  controller: fullNameController),
              _buildTextField("Age", Icons.calendar_today,
                  controller: ageController, isNumber: true),
              _buildTextField("Address", Icons.home,
                  controller: addressController),
              _buildTextField("Contact Info", Icons.contact_phone,
                  controller: contactInfoController),
              _buildTextField("Room Number", Icons.location_on,
                  controller: roomNumberController),
              _buildTextField("Medical History", Icons.history,
                  controller: medicalHistoryController),
              _buildTextField("Temperature", Icons.heat_pump,
                  controller: temperatureController, isNumber: true),
              _buildTextField("Blood Pressure", Icons.monitor_heart,
                  controller: bloodPressureController),
              _buildTextField("Heart Rate", Icons.favorite,
                  controller: heartRateController),
              _buildTextField("Respiratory Rate", Icons.air,
                  controller: respiratoryRateController),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed:
                      savePatient, // Save patient to MongoDB when pressed
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("Add Patient"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Textfield widget
Widget _buildTextField(String label, IconData icon,
    {bool isNumber = false, required TextEditingController controller}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    ),
  );
}
