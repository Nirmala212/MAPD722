import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class UpdatePatientRecordScreen extends StatefulWidget {
  final Map<String, dynamic>
      patient; // Change to dynamic for better flexibility

  const UpdatePatientRecordScreen({super.key, required this.patient});

  @override
  // ignore: library_private_types_in_public_api
  _UpdatePatientRecordScreenState createState() =>
      _UpdatePatientRecordScreenState();
}

class _UpdatePatientRecordScreenState extends State<UpdatePatientRecordScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController addressController;
  late TextEditingController medicalHistoryController;
  late TextEditingController ContactInfoController;
  late TextEditingController RoomNumberController;

  // MongoDB connection string (TLS enabled)
  final String connectionString =
      'mongodb+srv://admin:1234@flutterproject.pl66lr6.mongodb.net/test?retryWrites=true&w=majority&appName=flutterProject';

  late mongo.Db db;
  late mongo.DbCollection collection;

  @override
  void initState() {
    super.initState();
    _connectToMongoDB();

    // Initialize controllers with data
    nameController = TextEditingController(text: widget.patient["fullName"]);
    ageController =
        TextEditingController(text: widget.patient["age"].toString());
    addressController = TextEditingController(text: widget.patient["address"]);
    medicalHistoryController =
        TextEditingController(text: widget.patient["medicalHistory"]);
    ContactInfoController =
        TextEditingController(text: widget.patient["contactInfo"]);
    RoomNumberController =
        TextEditingController(text: widget.patient["roomNumber"]);
  }

  Future<void> _connectToMongoDB() async {
    try {
      db = mongo.Db(connectionString);
      await db.open();
      collection = db.collection('patients');
      print("✅ MongoDB connected");
    } catch (e) {
      print("❌ MongoDB connection error: $e");
    }
  }

  Future<void> saveUpdatedPatient() async {
    if (widget.patient['_id'] == null || widget.patient['_id']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid patient ID')),
      );
      return;
    }

    // Validating age input to ensure it's a valid number
    int age = int.tryParse(ageController.text) ?? -1;
    if (age <= 0 || age > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      return;
    }

    try {
      var result = await collection.updateOne(
        {'_id': mongo.ObjectId.parse(widget.patient['_id']!)},
        mongo.ModifierBuilder()
          ..set('fullName', nameController.text)
          ..set('age', age)
          ..set('address', addressController.text)
          ..set('medicalHistory', medicalHistoryController.text)
          ..set('contactInfo', ContactInfoController.text)
          ..set('roomNumber', RoomNumberController.text),
      );

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient record updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No changes made to the patient record')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update patient record')),
      );
      print('Update error: $e');
    }
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
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
            _buildTextField("Full Name", Icons.person,
                controller: nameController),
            _buildTextField("Age", Icons.calendar_today,
                controller: ageController, isNumber: true),
            _buildTextField("Address", Icons.home,
                controller: addressController),
            _buildTextField("Medical History", Icons.history,
                controller: medicalHistoryController),
            _buildTextField("Contact Info", Icons.contact_phone,
                controller: ContactInfoController),
            _buildTextField("Room Number", Icons.location_on,
                controller: RoomNumberController),
            const SizedBox(height: 20),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {bool isNumber = false, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
