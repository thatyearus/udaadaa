import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/form/exercise_form_view.dart';
import 'package:udaadaa/view/form/food_form_view.dart';
import 'package:udaadaa/view/form/weight_form_view.dart';

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
            _buildSecondaryFAB(
                Icons.sports_gymnastics_rounded, 210, ExerciseFormView()),
          if (_isExpanded)
            _buildSecondaryFAB(Icons.scale_rounded, 140, WeightFormView()),
          if (_isExpanded)
            _buildSecondaryFAB(Icons.dinner_dining_rounded, 70, FoodFormView()),
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
