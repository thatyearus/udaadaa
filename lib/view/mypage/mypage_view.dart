import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/widgets/fab.dart';
import 'package:udaadaa/widgets/my_profile.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final myFeeds =
        context.select((FeedCubit feedCubit) => feedCubit.getMyFeeds);

    return Scaffold(
      appBar: AppBar(actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: 'change_nickname',
                child: Text('닉네임 변경'),
              ),
              const PopupMenuItem(
                value: 'alarm_setting',
                child: Text("알람 설정"),
              ),
            ];
          },
          onSelected: (value) {
            switch (value) {
              case 'change_nickname':
                // TODO: 닉네임 변경 기능 구현
                break;
              case 'alarm_setting':
                // TODO: 알람 설정 기능 구현
                break;
            }
          },
          icon: const Icon(Icons.settings_rounded),
        ),
      ]),
      body: RefreshIndicator(
        onRefresh: () => context.read<FeedCubit>().fetchMyFeeds(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyProfile(),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                },
                child: const Text('Sign Out'),
              ),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: myFeeds.length,
                  itemBuilder: (context, index) {
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyRecordView(initialPage: index),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            width: double.infinity,
                            height: double.infinity,
                            imageUrl: myFeeds[index].imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: const AddFabButton(),
    );
  }
}
