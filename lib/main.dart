import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/cubit/form_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/main_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<BottomNavCubit>(create: (context) => BottomNavCubit()),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            context.read<AuthCubit>(),
          ),
        ),
        BlocProvider<FormCubit>(
            create: (context) => FormCubit(
                  context.read<ProfileCubit>(),
                )),
        BlocProvider<FeedCubit>(
          create: (context) => FeedCubit(
            context.read<AuthCubit>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: appTheme,
        home: const MainView(),
      ),
    );
  }
}
