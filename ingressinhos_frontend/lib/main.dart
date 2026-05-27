import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/auth_gate.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/register_client_page.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/register_seller_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/cart_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/issued_tickets_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/seller_events_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/cart_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/home_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/my_tickets_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/register_event_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/seller_events_page.dart';

void main() {
  setup();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>()..checkAuthentication(),
        ),

        BlocProvider<EventsCubit>(
          create: (_) => getIt<EventsCubit>(),
        ),

        BlocProvider<CartCubit>(
          create: (_) => getIt<CartCubit>(),
        ),

        BlocProvider<IssuedTicketsCubit>(
          create: (_) => getIt<IssuedTicketsCubit>(),
        ),

        BlocProvider<SellerEventsCubit>(
          create: (_) => getIt<SellerEventsCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
        routes: {
          '/login': (context) => LoginPage(),
          '/registerclient': (context) => RegisterClientPage(),
          '/registerseller': (context) => RegisterSellerPage(),
          '/registerevent': (context) => RegisterEventPage(),
          '/home': (context) => HomePage(),
          '/cart': (context) => CartPage(),
          '/mytickets': (context) => MyTicketsPage(),
          '/seller-events': (context) => SellerEventsPage(),
        },
      ),
    );
  }
}
