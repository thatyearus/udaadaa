import 'package:flutter/material.dart';
import 'package:udaadaa/widgets/feed.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
                  // TODO: 컨텐츠 차단 기능 구현
                  break;
              }
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: const FeedPageView(),
    );
  }
}
