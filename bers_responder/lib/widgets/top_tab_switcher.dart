import 'package:flutter/material.dart';

class TopTabSwitcher extends StatelessWidget {
  final String activeTab;
  final void Function(String tab)? onTabChanged;

  const TopTabSwitcher({
    super.key,
    required this.activeTab,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTab(
            label: 'Form',
            tabValue: 'form',
            isActive: activeTab == 'form',
          ),
          _buildTab(
            label: 'History Form',
            tabValue: 'history',
            isActive: activeTab == 'history',
          ),
        ],
      ),
    );
  }

  Expanded _buildTab({
    required String label,
    required String tabValue,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive && onTabChanged != null) {
            onTabChanged!(tabValue);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
