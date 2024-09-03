import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/widgets/fab.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(icon: const Icon(Icons.settings_rounded), onPressed: () {}),
      ]),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state is ProfileLoaded)
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person),
                    ),
                    AppSpacing.horizontalSizedBoxS,
                    Text(state.user),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                },
                child: const Text('Sign Out'),
              ),
              Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GridTile(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const MyRecordView()));
                          },
                          child: Container(
                            color: AppColors.neutral[100],
                            child: Center(
                              child: Text('Item $index'),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          );
        },
      ),
      floatingActionButton: const AddFabButton(),
    );
  }
}
