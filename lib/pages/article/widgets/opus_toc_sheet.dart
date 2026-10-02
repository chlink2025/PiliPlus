import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/models/dynamics/article_content_model.dart'
    show OpusTocItem;
import 'package:PiliPlus/models/dynamics/result.dart' show ModuleCollection;
import 'package:PiliPlus/models_new/article/article_list/article.dart';
import 'package:PiliPlus/pages/article/controller.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 官方风格的目录弹窗：双 Tab(目录 / 文集)
Future<void> showOpusTocSheet(
  BuildContext context,
  ArticleController controller, {
  bool initialCollection = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _OpusTocSheet(
      controller: controller,
      initialCollection: initialCollection,
    ),
  );
}

enum _TocTab { toc, collection }

class _OpusTocSheet extends StatefulWidget {
  const _OpusTocSheet({
    required this.controller,
    required this.initialCollection,
  });

  final ArticleController controller;
  final bool initialCollection;

  @override
  State<_OpusTocSheet> createState() => _OpusTocSheetState();
}

class _OpusTocSheetState extends State<_OpusTocSheet>
    with SingleTickerProviderStateMixin {
  ModuleCollection? get _collection =>
      widget.controller.opusData?.modules.moduleCollection;

  late final List<_TocTab> _tabs = [
    _TocTab.toc,
    if (_collection != null) _TocTab.collection,
  ];

  late final TabController _tabController;

  late final Future<List<ArticleListItemModel>?> _collectionFuture =
      _collection == null
      ? Future<List<ArticleListItemModel>?>.value(null)
      : DynamicsHttp.articleList(id: _collection!.id!).then(
          (res) => res.dataOrNull?.articles,
        );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      initialIndex: widget.initialCollection && _collection != null ? 1 : 0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: Column(
        children: [
          if (_tabs.length > 1)
            TabBar(
              controller: _tabController,
              tabs: _tabs
                  .map(
                    (e) => Tab(text: e == _TocTab.toc ? '目录' : '文集'),
                  )
                  .toList(),
            )
          else
            const Padding(
              padding: .only(top: 4, bottom: 8),
              child: Text('目录', style: TextStyle(fontWeight: .bold)),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map(_buildTab).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(_TocTab tab) => switch (tab) {
    _TocTab.toc => _buildToc(),
    _TocTab.collection => _buildCollection(),
  };

  Widget _buildToc() {
    final toc = widget.controller.tocList ?? const <OpusTocItem>[];
    final minLevel = toc.fold<int>(
      toc.isEmpty ? 1 : toc.first.level,
      (min, e) => e.level < min ? e.level : min,
    );
    return ListView.builder(
      itemCount: toc.length,
      itemBuilder: (context, index) {
        final item = toc[index];
        return ListTile(
          dense: true,
          contentPadding: .only(
            left: 16.0 + (item.level - minLevel) * 16.0,
            right: 16.0,
          ),
          title: Text(
            item.title,
            maxLines: 2,
            overflow: .ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: item.level == minLevel ? .bold : null,
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            widget.controller.jumpToToc(item.anchorIndex);
          },
        );
      },
    );
  }

  Widget _buildCollection() {
    final collection = _collection!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  collection.name ?? '',
                  style: const TextStyle(fontWeight: .bold, fontSize: 15),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ),
              if (collection.count?.isNotEmpty == true)
                Text(
                  collection.count!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ArticleListItemModel>?>(
            future: _collectionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final articles = snapshot.data;
              if (articles == null || articles.isEmpty) {
                return const Center(child: Text('加载失败'));
              }
              return ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final item = articles[index];
                  return ListTile(
                    dense: true,
                    leading: SizedBox(
                      width: 24,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      item.title ?? '',
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      final dynIdStr = item.dynIdStr;
                      Get.toNamed(
                        '/articlePage',
                        parameters: {
                          'id': dynIdStr ?? item.id!.toString(),
                          'type': dynIdStr != null ? 'opus' : 'read',
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
