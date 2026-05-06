import 'package:flutter/material.dart';
import 'package:ingressinho_frontzinho/Presentation/home.dart';

class MeuHamburguer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 27, 27, 27),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 27, 60, 87)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(radius: 30, backgroundColor: Color.fromARGB(255, 200, 200, 200)),
                SizedBox(width: 15),
                Text(
                  "Vinicius Brandi",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 200, 200, 200),
                    fontWeight: FontWeight(600),
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home, color: Color.fromARGB(255, 200, 200, 200),),
            title: const Text("Inicio", style: TextStyle(color: Color.fromARGB(255, 200, 200, 200))),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.confirmation_num, color: Color.fromARGB(255, 200, 200, 200)),
            title: const Text("Meus Ingressos", style: TextStyle(color: Color.fromARGB(255, 200, 200, 200)),),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
          ),
        ],
      ),
    );
  }
}
