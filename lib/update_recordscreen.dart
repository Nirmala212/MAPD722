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
  late TextEditingController contactInfoController;
  late TextEditingController roomNumberController;

  // MongoDB connection string (TLS enabled)
  final String connectionString =
      'mongodb://admin:1234@ac-uru0tue-shard-00-00.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-01.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-02.pl66lr6.mongodb.net:27017/?replicaSet=atlas-4lamuj-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=flutterProject';

  mongo.Db? db;
  mongo.DbCollection? collection;

  @override
  void initState() {
    super.initState();
    _connectToMongoDB();

    print("📦 Full patient data: ${widget.patient}");
    print("📞 Contact Info: ${widget.patient['contactInfo']}");
    print("🛏️ Room Number: ${widget.patient['roomNumber']}");

    // Initialize controllers with data
    nameController = TextEditingController(text: widget.patient["fullName"]);
    ageController =
        TextEditingController(text: widget.patient["age"].toString());
    addressController = TextEditingController(text: widget.patient["address"]);
    medicalHistoryController =
        TextEditingController(text: widget.patient["medicalHistory"]);
    contactInfoController =
        TextEditingController(text: widget.patient["contactInfo"]);
    roomNumberController =
        TextEditingController(text: widget.patient["roomNumber"]);
  }

  Future<void> _connectToMongoDB() async {
    try {
      db = mongo.Db(connectionString);
      await db!.open();
      collection = db!.collection('patients');
      print("✅ MongoDB connected");
    } catch (e, stackTrace) {
      print("❌ MongoDB connection error: $e");
      print("StackTrace: $stackTrace");
    }
  }

  Future<void> saveUpdatedPatient() async {
    if (db == null || collection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MongoDB connection failed')),
      );
      return;
    }

    //print(
    // "widget.patient['_id']: ${widget.patient['_id']} (${widget.patient['_id'].runtimeType})");

    late mongo.ObjectId objectId;

    final rawId = widget.patient['_id'];
    print("🧪 Raw _id: $rawId (${rawId.runtimeType})");

    try {
      if (rawId is mongo.ObjectId) {
        objectId = rawId;
      } else if (rawId is Map && rawId['\$oid'] != null) {
        objectId = mongo.ObjectId.parse(rawId['\$oid']);
      } else if (rawId is String) {
        String formattedId = rawId;
        if (formattedId.startsWith("ObjectId(")) {
          formattedId =
              formattedId.replaceAll('ObjectId("', '').replaceAll('")', '');
        }
        objectId = mongo.ObjectId.parse(formattedId);
      } else {
        throw Exception("Invalid _id format");
      }
    } catch (e) {
      print("❌ Failed to parse ObjectId: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid patient ID format')),
      );
      return;
    }

    int age = int.tryParse(ageController.text) ?? -1;
    if (age <= 0 || age > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      return;
    }

    try {
      print("✅ Updating patient with ID: $objectId");

      var result = await collection!.updateOne(
        {'_id': objectId},
        mongo.ModifierBuilder()
          ..set('fullName', nameController.text)
          ..set('age', age)
          ..set('address', addressController.text)
          ..set('medicalHistory', medicalHistoryController.text)
          ..set('contactInfo', contactInfoController.text)
          ..set('roomNumber', roomNumberController.text),
      );

      print("Matched: ${result.nMatched}, Modified: ${result.nModified}");

      if (result.isSuccess && result.nModified > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient record updated successfully!')),
        );

        print("👋 Returning with 'updated'");
        Navigator.pop(context, 'updated');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No changes made to the patient record')),
        );
      }
    } catch (e) {
      print("❌ Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update patient record')),
      );
    }
  }

  @override
  void dispose() {
    db?.close();
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
                controller: contactInfoController),
            _buildTextField("Room Number", Icons.location_on,
                controller: roomNumberController),
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
                  "Update",
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
