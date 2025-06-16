import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  Map<Permission, PermissionStatus> _statuses = {};

  final Map<Permission, String> _criticalPermissions = {
    Permission.location: 'Location',
    Permission.phone: 'Phone',
  };

  final Map<Permission, String> _optionalPermissions = {
    Permission.microphone: 'Microphone',
    Permission.sms: 'SMS',
  };

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    final allPermissions = {..._criticalPermissions, ..._optionalPermissions};
    final statuses = <Permission, PermissionStatus>{};

    for (final permission in allPermissions.keys) {
      statuses[permission] = await permission.status;
    }

    setState(() => _statuses = statuses);
  }

  Future<void> _handlePermissionToggle(Permission permission) async {
    final status = _statuses[permission];

    if (status == PermissionStatus.granted) {
      // Toggle OFF not supported directly
      openAppSettings(); // Instruct user manually disable
    } else if (status == PermissionStatus.denied) {
      await permission.request();
    } else if (status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }

    _checkAllPermissions();
  }

  Widget _buildSwitchTile(Permission permission, String label) {
    final status = _statuses[permission];
    final isGranted = status == PermissionStatus.granted;

    return SwitchListTile(
      value: isGranted,
      title: Text(label),
      subtitle: Text('Status: ${status?.toString().split('.').last ?? 'Unknown'}'),
      onChanged: (_) => _handlePermissionToggle(permission),
      activeColor: Colors.green,
      inactiveThumbColor: Colors.redAccent,
      inactiveTrackColor: Colors.red.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Permissions")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Disabling permissions may cause the app to misbehave or stop working properly. "
                    "Please enable all critical permissions.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const Text("Critical Permissions", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._criticalPermissions.entries.map((e) => _buildSwitchTile(e.key, e.value)),
          const SizedBox(height: 16),
          const Text("Optional Permissions", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._optionalPermissions.entries.map((e) => _buildSwitchTile(e.key, e.value)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
              icon: IconTheme(
                data: const IconThemeData(color: Colors.black), // ✅ Set icon color here
                child: const Icon(Icons.settings),
              ),
              label: const Text(
                "Open App Settings",
                style: TextStyle(color: Colors.black), // ✅ Label text color
              ),
              onPressed: openAppSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                elevation: 2,
              ),
            ),
        ],
      ),
    );
  }
}
