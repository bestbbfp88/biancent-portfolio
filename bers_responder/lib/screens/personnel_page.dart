import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PersonnelPage extends StatefulWidget {
  const PersonnelPage({super.key});

  @override
  State<PersonnelPage> createState() => _PersonnelPageState();
}

class _PersonnelPageState extends State<PersonnelPage> {
  List<Map<String, dynamic>> _personnelList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPersonnel();
  }

  /// 🔥 Fetch personnel linked by authenticated UID → ER_ID → unit_ID
  Future<void> _fetchPersonnel() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      String uid = user.uid;

      // ✅ Step 1: Fetch ER_ID from responder_unit by matching the authenticated UID
      DatabaseReference unitRef = FirebaseDatabase.instance.ref("responder_unit");
      DataSnapshot unitSnapshot = await unitRef
          .orderByChild("ER_ID")
          .equalTo(uid)
          .get();

      if (unitSnapshot.exists && unitSnapshot.value != null) {
        final Map<dynamic, dynamic> unitData = unitSnapshot.value as Map<dynamic, dynamic>;

        // ✅ Iterate through matching ER_IDs
        for (var entry in unitData.entries) {
          final unit = entry.value as Map<dynamic, dynamic>;
          String unitId = entry.key; // ✅ Get the unit_ID

          // ✅ Step 2: Fetch personnel by matching the unit_ID in responder_personnel
          DatabaseReference personnelRef = FirebaseDatabase.instance.ref("responder_personnel");
          DataSnapshot personnelSnapshot = await personnelRef
              .orderByChild("unit_ID")
              .equalTo(unitId)
              .get();

          if (personnelSnapshot.exists && personnelSnapshot.value != null) {
            final Map<dynamic, dynamic> personnelData = personnelSnapshot.value as Map<dynamic, dynamic>;

            personnelData.forEach((key, value) {
              final personnel = value as Map<dynamic, dynamic>;

              _personnelList.add({
                "erp_fname": personnel["erp_fname"] ?? "N/A",
                "erp_lname": personnel["erp_lname"] ?? "N/A",
                "erp_Contact": personnel["erp_Contact"] ?? "N/A",
                "erp_Status": personnel["erp_Status"] ?? "N/A",
                "unit_ID": personnel["unit_ID"] ?? "N/A",
              });
            });
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("❌ Error fetching personnel: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel List'),
        backgroundColor: Colors.redAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _personnelList.isEmpty
              ? const Center(child: Text("No personnel found"))
              : ListView.builder(
                  itemCount: _personnelList.length,
                  itemBuilder: (context, index) {
                    final personnel = _personnelList[index];

                    String name = "${personnel['erp_fname']} ${personnel['erp_lname']}".trim();
                    String contact = personnel['erp_Contact'] ?? "N/A";
                    String status = personnel['erp_Status'] ?? "N/A";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.redAccent),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Contact: $contact"),
                            Text("Status: $status"),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
    );
  }
}
