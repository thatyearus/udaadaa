import 'package:flutter/material.dart';
import 'package:udaadaa/widgets/feed.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/models/image.dart';

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
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white,),
          ),
        ],
      ),
      body: FutureBuilder<List<ImageModel>>(
        future: _fetchImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            return FeedPageView(images: snapshot.data!);
          }
        }
      )
    );
  }
}

Future<List<ImageModel>> _fetchImages() async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('images')
      .select('id, img_url');

  if (data.length == 0){
    throw "No data";
  }else{
    return data.map((item) => ImageModel.fromMap(map: item)).toList();
  }
}
