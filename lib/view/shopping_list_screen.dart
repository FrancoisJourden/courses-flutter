import 'package:courses_flutter/utils.dart';
import 'package:courses_flutter/api/api.dart';
import 'package:courses_flutter/api/article_api.dart';
import 'package:courses_flutter/api/item_api.dart';
import 'package:courses_flutter/model/article.dart';
import 'package:courses_flutter/model/item.dart';
import 'package:courses_flutter/view/article_add_screen.dart';
import 'package:courses_flutter/view/connection_screen.dart';
import 'package:flutter/material.dart';

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
      data.sort(Article.compare);
      setState(() => _articles = data);
    } on UnauthenticatedException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Token mort")));
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My shopping list")),
      body: RefreshIndicator(onRefresh: _fetchData, child: _buildContent()),
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
      return ListView.builder(
        itemBuilder: (context, index) => _ShoppingListElementWidget(article: _articles![index]),
        itemCount: _articles!.length,
      );
    }
  }
}

class _ShoppingListElementWidget extends StatefulWidget {
  const _ShoppingListElementWidget({required this.article});

  final Article article;

  @override
  State<_ShoppingListElementWidget> createState() => _ShoppingListElementWidgetState();
}

class _ShoppingListElementWidgetState extends State<_ShoppingListElementWidget> {
  Item? _item;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) return const Text("Loading item...");
    if (widget.article.taken != null) {
      return _ShoppingListTakenElementWidget(article: widget.article, item: _item!);
    }
    if (widget.article.canceled != null) {
      return _ShoppingListCanceledElementWidget(article: widget.article, item: _item!);
    }

    return Dismissible(
      key: Key(_item!.id.toString()),
      confirmDismiss: _confirmDismiss,
      background: _validateBackground(),
      secondaryBackground: _cancelBackground(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_item!.name.capitalizeWords()),
            Text("${widget.article.quantity} ${_item?.unit ?? ""}")
          ],
        ),
      ),
    );
  }

  Future<void> _fetchData() async {
    try {
      final data = await ItemApi.get(widget.article.itemId);
      setState(() => _item = data);
    } on UnauthenticatedException {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ConnectionScreen()));
      }
    }
  }

  Widget _validateBackground() => Container(
        color: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Icon(Icons.shopping_cart_checkout, color: Colors.white)],
        ),
      );

  Widget _cancelBackground() => Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Icon(Icons.remove_shopping_cart, color: Colors.white)],
        ),
      );

  Future<bool> _confirmDismiss(DismissDirection direction) async {
    if (DismissDirection.startToEnd == direction) return _validateArticle();
    if (DismissDirection.endToStart == direction) return _cancelArticle();

    return false;
  }

  Future<bool> _validateArticle() async {
    try {
      await ArticleAPI.validate(widget.article.id);
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> _cancelArticle() async {
    try {
      await ArticleAPI.cancel(widget.article.id);
      return true;
    } on Exception {
      return false;
    }
  }
}

class _ShoppingListTakenElementWidget extends StatelessWidget {
  const _ShoppingListTakenElementWidget({required this.article, required this.item});

  final Article article;
  final Item item;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          const Icon(Icons.check, color: Colors.green),
          Text(item.name.capitalizeWords()),
        ]),
        Text("${article.quantity} ${item.unit ?? ""}")
      ],
    ),
  );
}

class _ShoppingListCanceledElementWidget extends StatelessWidget {
  const _ShoppingListCanceledElementWidget({required this.article, required this.item});

  final Article article;
  final Item item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.remove_shopping_cart, color: Colors.redAccent),
              Text(item.name.capitalizeWords()),
            ]),
            Text("${article.quantity} ${item.unit ?? ""}")
          ],
        ),
      );
}
