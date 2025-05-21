import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/models/profile.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/newonboarding/recommend_calorie_view.dart';

class ProfileOnboardingView extends StatefulWidget {
  const ProfileOnboardingView({super.key});

  @override
  State<ProfileOnboardingView> createState() => _ProfileOnboardingViewState();
}

class _ProfileOnboardingViewState extends State<ProfileOnboardingView>
    with TickerProviderStateMixin {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _targetWeightAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _targetWeightSlideAnimation;

  bool _isHeightValid = false;
  bool _isTargetWeightValid = false;
  bool _showHeightText = true;
  bool _showTargetWeightText = true;
  late FocusNode _heightFocusNode;
  late FocusNode _targetWeightFocusNode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _targetWeightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _targetWeightSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(
      parent: _targetWeightAnimationController,
      curve: Curves.easeOutCubic,
    ));
    _heightFocusNode = FocusNode();
    _targetWeightFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _targetWeightController.dispose();
    _animationController.dispose();
    _targetWeightAnimationController.dispose();
    _heightFocusNode.dispose();
    _targetWeightFocusNode.dispose();
    super.dispose();
  }

  void _onHeightChanged(String value) {
    if (value.isNotEmpty && double.tryParse(value) != null) {
      setState(() {
        _isHeightValid = true;
        _showHeightText = false;
      });
      _animationController.forward();
    } else {
      setState(() {
        _isHeightValid = false;
        _showHeightText = true;
      });
      _animationController.reverse();
    }
  }

  void _onTargetWeightChanged(String value) {
    if (value.isNotEmpty && double.tryParse(value) != null) {
      setState(() {
        _isTargetWeightValid = true;
        _showTargetWeightText = false;
      });
      _targetWeightAnimationController.forward();
    } else {
      setState(() {
        _isTargetWeightValid = false;
        _showTargetWeightText = true;
      });
      _targetWeightAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Profile? profile = context.read<AuthCubit>().getCurProfile;
    debugPrint('Profile ID: ${profile?.id}');
    debugPrint('Profile Created At: ${profile?.nickname}');

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showHeightText ? 1.0 : 0.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '키를 입력해주세요',
                          style: AppTextStyles.displayMedium(
                            const TextStyle(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'cm 단위로 입력해주세요',
                          style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                            color: AppColors.neutral[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildInputField(
                      controller: _heightController,
                      hintText: '키',
                      suffixText: 'cm',
                      onChanged: _onHeightChanged,
                      onTap: () {
                        if (_isTargetWeightValid) {
                          _targetWeightAnimationController.reverse();
                          setState(() {
                            _isTargetWeightValid = false;
                            _showTargetWeightText = true;
                          });
                        }
                      },
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _showTargetWeightText ? 1.0 : 0.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '목표 몸무게를 입력해주세요',
                                  style: AppTextStyles.textTheme.displayMedium
                                      ?.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'kg 단위로 입력해주세요',
                                  style: AppTextStyles.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppColors.neutral[400],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          SlideTransition(
                            position: _targetWeightSlideAnimation,
                            child: _buildInputField(
                              controller: _targetWeightController,
                              hintText: '목표 몸무게',
                              suffixText: 'kg',
                              onChanged: _onTargetWeightChanged,
                              onTap: () {
                                if (_isHeightValid) {
                                  _animationController.reverse();
                                  setState(() {
                                    _isHeightValid = false;
                                    _showHeightText = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 48,
                      child: FloatingActionButton.extended(
                        backgroundColor: (_heightController.text.isNotEmpty &&
                                _targetWeightController.text.isNotEmpty)
                            ? AppColors.primary
                            : AppColors.neutral[300],
                        elevation: 2,
                        onPressed: (_heightController.text.isNotEmpty &&
                                _targetWeightController.text.isNotEmpty)
                            ? () {
                                context.read<AuthCubit>().updateProfile(
                                      _heightController.text,
                                      _targetWeightController.text,
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RecommendCalorieView(),
                                  ),
                                );
                              }
                            : null,
                        label: Text(
                          "다음",
                          style:
                              AppTextStyles.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String suffixText,
    required Function(String) onChanged,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: AppTextStyles.textTheme.headlineMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.textTheme.headlineMedium?.copyWith(
            color: AppColors.neutral[300],
          ),
          suffixText: suffixText,
          suffixStyle: AppTextStyles.textTheme.headlineMedium?.copyWith(
            color: AppColors.neutral[400],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
