import 'package:courses_flutter/api/article_api.dart';
import 'package:courses_flutter/api/item_api.dart';
import 'package:courses_flutter/model/item.dart';
import 'package:courses_flutter/view/item_add_screen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class ArticleAddScreen extends StatelessWidget {
  const ArticleAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add an article"),
      ),
      body: const Padding(padding: EdgeInsets.all(10), child: _ArticleAddForm()),
    );
  }
}

class _ArticleAddForm extends StatefulWidget {
  const _ArticleAddForm();

  @override
  State<_ArticleAddForm> createState() => _ArticleAddFormState();
}

class _ArticleAddFormState extends State<_ArticleAddForm> {
  final _formKey = GlobalKey<FormState>();

  Item? item;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(children: [
            _buildItemRow(),
            const Gap(10),
            _buildQuantityField(),
            const Gap(10),
            _buildValidateButton(),
          ]),
        ));
  }

  Widget _buildItemField() => DropdownSearch<Item>(
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
      );

  Widget _buildAddItemButton() => IconButton(onPressed: addItem, icon: const Icon(Icons.add));

  void addItem() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ItemAddScreen()));
  }

  Widget _buildItemRow() => Row(children: [
        Flexible(child: _buildItemField()),
        _buildAddItemButton(),
      ]);

  Widget _buildQuantityField() => TextFormField(
        decoration: const InputDecoration(labelText: "quantity"),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value!.isEmpty) return "Please enter a quantity";
          if (!RegExp(r"^[0-9]+$").hasMatch(value)) return "Please enter a positive integer";
          return null;
        },
        keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: true),
        onChanged: (value) => setState(() => quantity = int.parse(value)),
      );

  Widget _buildValidateButton() => FilledButton.icon(
        onPressed: send,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text("Add to list"),
      );

  void send() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ArticleAPI.add(item!.id, quantity);
      if(mounted) Navigator.pop(context);
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An unknown error happened"),
      ));
    }
  }
}
