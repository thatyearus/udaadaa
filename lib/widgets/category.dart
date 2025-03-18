import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';

class CategoryButtonsContainer extends StatefulWidget {
  final ValueChanged<FeedCategory> onCategorySelected;

  const CategoryButtonsContainer({super.key, required this.onCategorySelected});

  @override
  State<CategoryButtonsContainer> createState() =>
      _CategoryButtonsContainerState();
}

class _CategoryButtonsContainerState extends State<CategoryButtonsContainer> {
  FeedCategory _selectedCategory = FeedCategory.all; // 기본 선택 카테고리

  void _selectCategory(FeedCategory category) {
    /*setState(() {
      _selectedCategory = category;
    });*/
    widget.onCategorySelected(category); // 선택된 카테고리 콜백 호출
  }

  @override
  Widget build(BuildContext context) {
    _selectedCategory = context
        .select<FeedCubit, FeedCategory>((cubit) => cubit.getFeedCategory);
    return Align(
      alignment: Alignment.topLeft, // 카테고리 위치를 조정하고 싶다면 이 부분 수정
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10), // 위치 조정을 위한 패딩
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CategoryButton(
              emoji: "👏",
              text: "전체",
              isSelected: _selectedCategory == FeedCategory.all,
              onPressed: () => _selectCategory(FeedCategory.all),
            ),
            const SizedBox(width: 10), // 버튼 간격
            _CategoryButton(
              emoji: "🏆️",
              text: "챌린지",
              isSelected: _selectedCategory == FeedCategory.challenge,
              onPressed: () => _selectCategory(FeedCategory.challenge),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String emoji;
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const _CategoryButton({
    required this.emoji,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.8),
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          elevation: 0),
      onPressed: onPressed,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: emoji,
              style: const TextStyle(fontFamily: 'tossface', fontSize: 14),
            ),
            TextSpan(
              text: " $text",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
