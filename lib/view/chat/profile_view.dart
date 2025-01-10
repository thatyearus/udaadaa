import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';

class ProfileView extends StatelessWidget {
  // final String imageUrl;
  final String nickname;
  final String userId;

  const ProfileView({
    super.key,
    // required this.imageUrl,
    required this.nickname,
    required this.userId,
  });

/*
  Future<void> _blockUser() async {
    try {
      await supabase.Supabase.instance.client.from('blocked_users').insert({
        'blocked_user_id': userId,
        'user_id': supabase.Supabase.instance.client.auth.currentUser!.id,
      });
      getMessages(groupChannel);
    } catch (e) {
      debugPrint('Error blocking user: $e');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                /*
                CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 50,
                ),*/
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary[50],
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: 16.0),
                Text(
                  nickname,
                  style: AppTextStyles.headlineLarge(
                    const TextStyle(color: AppColors.white),
                  ),
                ),
                const SizedBox(height: 32.0),
                Divider(color: AppColors.neutral[100]),
                GestureDetector(
                  onTap: () {
                    // await _blockUser();
                    Navigator.pop(context);
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(16.0),
                    child: const Column(
                      children: [
                        Icon(Icons.block, color: Colors.white, size: 40),
                        SizedBox(height: 8.0),
                        Text(
                          '차단',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void navigateToProfileView(
  BuildContext context,
  String nickname,
  String userId,
) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ProfileView(
        nickname: nickname,
        userId: userId,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
  );
}
