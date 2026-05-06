import 'package:flutter/material.dart';
import 'package:ingressinho_frontzinho/Core/Widgets/meu_app_bar.dart';
import 'package:ingressinho_frontzinho/Core/Widgets/meu_hamburguer.dart';

class MeusIngressos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeuAppBar(),
      drawer: MeuHamburguer(),
      backgroundColor: const Color.fromRGBO(27, 27, 27, 1),
    );
  }
}
