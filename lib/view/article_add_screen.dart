import 'package:courses_flutter/api/article_api.dart';
import 'package:courses_flutter/api/item_api.dart';
import 'package:courses_flutter/model/item.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArticleAddScreen extends StatelessWidget {
  const ArticleAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add an article"),
      ),
      body: const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: ArticleAddForm()),
    );
  }
}

class ArticleAddForm extends StatefulWidget {
  const ArticleAddForm({super.key});

  @override
  State<ArticleAddForm> createState() => _ArticleAddFormState();
}

class _ArticleAddFormState extends State<ArticleAddForm> {
  final _formKey = GlobalKey<FormState>();

  Item? item;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildItemField(), _buildQuantityField(), _buildValidateButton()]),
        ));
  }

  Widget _buildItemField() => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DropdownSearch<Item>(
        popupProps: const PopupProps.dialog(
          isFilterOnline: true,
          showSearchBox: true,
          searchDelay: Duration(milliseconds: 500),
          dialogProps: DialogProps(shape: RoundedRectangleBorder()),
        ),
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(labelText: "Item"),
        ),
        validator: (item) {
          if (item == null) return ("Please choose an item");
          return null;
        },
        asyncItems: ItemApi.search,
        itemAsString: (item) => item.name,
        onChanged: (newItem) => setState(() => item = newItem),
      ));

  Widget _buildQuantityField() => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        decoration: const InputDecoration(labelText: "quantity"),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value!.isEmpty) return "Please enter a quantity";
          if (!RegExp(r"^[0-9]+$").hasMatch(value)) return "Please enter a positive integer";
          return null;
        },
        keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: true),
        onChanged: (value) => setState(() => quantity = int.parse(value)),
      ));

  Widget _buildValidateButton() => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: FilledButton.icon(
        onPressed: () {
          if(!_formKey.currentState!.validate()) return;
          try {
            ArticleAPI.add(item!.id, quantity);
            Navigator.pop(context);
          }on Exception{
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("An unknown error happened"),
            ));
          }
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text("Add to list"),
      ));
}
