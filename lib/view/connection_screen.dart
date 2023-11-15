import 'package:courses_flutter/api/auth_api.dart';
import 'package:courses_flutter/view/shopping_list_screen.dart';
import 'package:flutter/material.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: _ConnectionFormWidget(),
          ),
        ),
      );
}

class _ConnectionFormWidget extends StatefulWidget {
  const _ConnectionFormWidget();

  @override
  State<_ConnectionFormWidget> createState() => _ConnectionFormWidgetState();
}

class _ConnectionFormWidgetState extends State<_ConnectionFormWidget> {
  final _formKey = GlobalKey<FormState>();


  String email = AuthAPI.user?.email ?? "";
  String password = "";

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildEmailField(),
          _buildPasswordField(),
          _buildValidateButton(),
        ]),
      );

  Future<void> connect() async {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      await AuthAPI.login(email, password);
      if (context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return const ShoppingListScreen();
        }));
      }
    } on InvalidAuthException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid email or password"),
      ));
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An unexpected error happened."),
      ));
    }
  }

  Widget _buildEmailField() => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        decoration: const InputDecoration(labelText: "Email"),
        keyboardType: TextInputType.emailAddress,
        initialValue: email,
        validator: (value) {
          if (value!.isEmpty) return ("Please fill the email");
          if (!RegExp(r"^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$").hasMatch(email)) {
            return ("Please fill a valid email");
          }
          return null;
        },
        onChanged: (value) => email = value,
      ));

  Widget _buildPasswordField() => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        decoration: const InputDecoration(labelText: "Password"),
        initialValue: password,
        obscureText: true,
        validator: (value) {
          if (value!.isEmpty) return ("Please fill the password");
          return null;
        },
        onChanged: (value) => password = value,
      ));

  Widget _buildValidateButton() => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: FilledButton.icon(
        icon: const Icon(Icons.login),
        label: const Text("Connect"),
        onPressed: connect,
      ));
}
