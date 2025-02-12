import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/screens/main_chat.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ChatRepository>(
      create: (context) => ChatRepositoryImpl(),
      child: BlocProvider(
        create: (context) => ChatBloc(
          repository: context.read<ChatRepository>(),
        ),
        child: MaterialApp(
          title: 'MCP Chat',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5B9BD5),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: false,
            ),
            drawerTheme: const DrawerThemeData(
              elevation: 1,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5B9BD5),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: false,
            ),
            drawerTheme: const DrawerThemeData(
              elevation: 1,
            ),
          ),
          home: const ChatScreen(),
        ),
      ),
    );
  }
}
