import 'package:arts/ui/homepage.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //const Text("")
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Container(
          margin: const EdgeInsets.fromLTRB(5, 20, 5, 20),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: "Benvenuto in ",
                ),
                TextSpan(
                  text: "ARTS",
                  style: TextStyle(fontFamily: "DaVinci", fontSize: 25),
                ),
                TextSpan(
                  text: ", \nil tuo viaggio inizia qui\n",
                ),
                TextSpan(
                    text: "Felice di rivederti!",
                    style: TextStyle(fontSize: 30))
              ],
            ),
          )),
      const LoginForm(),
      InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          child: const Text("Entra in un secondo momento",
              style: TextStyle(fontSize: 20))),
    ]));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 10),
                    child:
                        const Text("Email: ", style: TextStyle(fontSize: 20))),
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "name@example.dom",
                      hintStyle: TextStyle(fontSize: 15)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la tua email!';
                    }
                    return null;
                  },
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    child: const Text("Password: ",
                        style: TextStyle(fontSize: 20))),
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "********",
                      hintStyle: TextStyle(fontSize: 15)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la tua password';
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}
