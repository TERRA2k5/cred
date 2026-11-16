import 'package:credd/Screens/Home.dart';
import 'package:credd/bloc/SDUIBloc.dart';
import 'package:credd/bloc/SDUIEvent.dart';
import 'package:credd/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies(); // Initialize get_it here

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRED Assessment',
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        // Fetch the BLoC from get_it and immediately add the fetch event
        create: (context) => getIt<SDUIBloc>()..add(const FetchSDUIData()),
        child: const HomePage(),
      ),
    );
  }
}