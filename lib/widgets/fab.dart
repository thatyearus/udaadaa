import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';

class AddFabButton extends StatefulWidget {
  const AddFabButton({super.key});

  @override
  State<StatefulWidget> createState() => _AddFabButtonState();
}

class _AddFabButtonState extends State<AddFabButton> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_isExpanded) _buildSecondaryFAB(Icons.camera_alt, 70),
          if (_isExpanded) _buildSecondaryFAB(Icons.photo, 140),
          if (_isExpanded) _buildSecondaryFAB(Icons.video_call, 210),
          _buildMainFAB(),
        ],
      ),
    );
  }

  Widget _buildMainFAB() {
    return FloatingActionButton(
      onPressed: () {
        _toggleExpanded();
      },
      backgroundColor: (_isExpanded
          ? AppColors.neutral[100]
          : Theme.of(context).primaryColor),
      foregroundColor: (_isExpanded
          ? Theme.of(context).primaryColor
          : AppColors.neutral[100]),
      child: Icon(_isExpanded ? Icons.close : Icons.add),
    );
  }

  Widget _buildSecondaryFAB(IconData icon, double bottom) {
    return Positioned(
      bottom: bottom,
      right: 0,
      child: FloatingActionButton(
        onPressed: () {
          // 각 FAB에 대한 액션
        },
        child: Icon(icon),
      ),
    );
  }
}
