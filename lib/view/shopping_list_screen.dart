import 'package:courses_flutter/utils.dart';
import 'package:courses_flutter/api/api.dart';
import 'package:courses_flutter/api/article_api.dart';
import 'package:courses_flutter/api/item_api.dart';
import 'package:courses_flutter/model/article.dart';
import 'package:courses_flutter/model/item.dart';
import 'package:courses_flutter/view/article_add_screen.dart';
import 'package:courses_flutter/view/connection_screen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<Article>? _articles;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _articles = null);
    try {
      final data = await ArticleAPI.getList();
      setState(() => _articles = data);
    } on UnauthenticatedException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Token mort")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My shopping list")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RefreshIndicator(onRefresh: _fetchData, child: _buildContent()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onAddButtonClick(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> onAddButtonClick(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const ArticleAddScreen();
    }));
    _fetchData();
  }

  Widget _buildContent() {
    if (_articles == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_articles!.isEmpty) {
      return ListView(children: const [Center(child: Text("No article in shopping list"))]);
    } else {
      return ListView.separated(
        itemBuilder: (context, index) => ShoppingListElementWidget(article: _articles![index]),
        itemCount: _articles!.length,
        separatorBuilder: (BuildContext context, int index) => const Gap(10),
      );
    }
  }
}

class ShoppingListElementWidget extends StatefulWidget {
  const ShoppingListElementWidget({super.key, required this.article});

  final Article article;

  @override
  State<ShoppingListElementWidget> createState() => _ShoppingListElementWidgetState();
}

class _ShoppingListElementWidgetState extends State<ShoppingListElementWidget> {
  Item? _item;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await ItemApi.get(widget.article.itemId);
      setState(() => _item = data);
    } on UnauthenticatedException {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ConnectionScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) return const Text("Loading item...");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_item!.name.capitalizeWords()),
        Text("${widget.article.quantity} ${_item?.unit ?? ""}")
      ],
    );
  }
}
