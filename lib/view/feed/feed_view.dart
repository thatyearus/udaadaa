import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/feed.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //
        //   },
        // ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'block_content',
                  child: Text('컨텐츠 차단'),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'block_content':
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('피드 차단'),
                          content: const Text('정말 차단하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '취소',
                                style: AppTextStyles.textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<FeedCubit>().blockFeedPage();
                                Navigator.of(context).pop();
                                Analytics().logEvent("피드_차단");
                              },
                              child: Text(
                                '차단',
                                style: AppTextStyles.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        );
                      });
                  break;
              }
            },
            icon: GestureDetector(
              onTap: () {
                Analytics().logEvent(
                  "피드_더보기",
                );
              },
              child: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: const FeedPageView(),
    );
  }
}
