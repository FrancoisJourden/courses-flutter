import 'package:courses_flutter/api/item_api.dart';
import 'package:courses_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ItemAddScreen extends StatelessWidget {
  const ItemAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Add an item")),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: _ItemAddForm(),
          ),
        ));
  }
}

class _ItemAddForm extends StatefulWidget {
  const _ItemAddForm();

  @override
  State<_ItemAddForm> createState() => _ItemAddFormState();
}

class _ItemAddFormState extends State<_ItemAddForm> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String? unit;
  String? category;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        _buildNameField(),
        const Gap(10),
        _buildUnitField(),
        const Gap(10),
        _buildCategoryField(),
        const Gap(10),
        _buildValidateButton(),
      ]),
    );
  }

  Widget _buildNameField() => TextFormField(
        decoration: const InputDecoration(labelText: "Name*"),
        onChanged: (value) => name = value,
        validator: (value) {
          if (value!.isEmpty) return "Please give an item name";
          return null;
        },
      );

  Widget _buildUnitField() => TextFormField(
        decoration: const InputDecoration(labelText: "Unit of measure"),
        onChanged: (value) => unit = value.nullIfEmpty(),
        validator: (value) => null,
      );

  Widget _buildCategoryField() => TextFormField(
        decoration: const InputDecoration(labelText: "Category"),
        onChanged: (value) => category = value.nullIfEmpty(),
        validator: (value) => null,
      );

  Widget _buildValidateButton() => FilledButton.icon(
        onPressed: send,
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      );

  void send() async {
    if (!_formKey.currentState!.validate()) return;
    try{
      await ItemApi.add(name, unit, category);
      if(mounted) Navigator.of(context).pop();
    } on Exception{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An unknown error happened"),
      ));
    }
  }
}
