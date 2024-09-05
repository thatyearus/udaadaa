import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/record/exercise_record_view.dart';
import 'package:udaadaa/view/record/food_record_view.dart';
import 'package:udaadaa/view/record/weight_record_view.dart';

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
          if (_isExpanded)
            _buildSecondaryFAB(Icons.sports_gymnastics_rounded, 210,
                const ExerciseRecordView()),
          if (_isExpanded)
            _buildSecondaryFAB(Icons.scale_rounded, 140, WeightRecordView()),
          if (_isExpanded)
            _buildSecondaryFAB(
                Icons.dinner_dining_rounded, 70, FoodRecordView()),
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

  Widget _buildSecondaryFAB(IconData icon, double bottom, Widget page) {
    return Positioned(
      bottom: bottom,
      right: 0,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
        child: Icon(icon),
      ),
    );
  }
}
