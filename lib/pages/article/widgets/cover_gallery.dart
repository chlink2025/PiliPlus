import 'dart:math' show min;

import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/gesture/horizontal_drag_gesture_recognizer.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart'
    show tabBarScrollPhysics;
import 'package:PiliPlus/models/common/image_preview_type.dart';
import 'package:PiliPlus/models/dynamics/article_content_model.dart' show Pic;
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// 文章文首封面画廊。
///
/// [pics] 为 opus 路径(服务端已带真实宽高)；
/// [urls] 为 read 路径(仅有 URL)，组件内异步解析真实宽高后再布局，
/// 解析完成前按 16:9 占位，保证与 opus 的显示效果一致。
class ArticleCoverGallery extends StatefulWidget {
  const ArticleCoverGallery({
    super.key,
    this.pics,
    this.urls,
    required this.maxWidth,
    required this.maxHeight,
    required this.topIndex,
  });

  final List<Pic>? pics;
  final List<String>? urls;
  final double maxWidth;
  final double maxHeight;
  final RxInt topIndex;

  @override
  State<ArticleCoverGallery> createState() => _ArticleCoverGalleryState();
}

class _ArticleCoverGalleryState extends State<ArticleCoverGallery> {
  final Map<String, (int, int)> _sizes = {};
  final List<(ImageStream, ImageStreamListener)> _listeners = [];

  @override
  void initState() {
    super.initState();
    _resolveSizes();
  }

  @override
  void didUpdateWidget(ArticleCoverGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.urls != oldWidget.urls) {
      _clearListeners();
      _resolveSizes();
    }
  }

  @override
  void dispose() {
    _clearListeners();
    super.dispose();
  }

  void _clearListeners() {
    for (final (stream, listener) in _listeners) {
      stream.removeListener(listener);
    }
    _listeners.clear();
    _sizes.clear();
  }

  /// read 路径没有宽高信息，异步解析真实尺寸(与显示共用同一图片缓存)
  void _resolveSizes() {
    if (widget.pics != null) return;
    final urls = widget.urls;
    if (urls == null) return;
    for (final url in urls) {
      if (url.isEmpty || _sizes.containsKey(url)) continue;
      final stream = CachedNetworkImageProvider(
        ImageUtils.thumbnailUrl(url, 60),
      ).resolve(ImageConfiguration.empty);
      final listener = ImageStreamListener(
        (info, _) {
          _sizes[url] = (info.image.width, info.image.height);
          if (mounted) setState(() {});
        },
      );
      stream.addListener(listener);
      _listeners.add((stream, listener));
    }
  }

  List<Pic> get _pics {
    if (widget.pics case final pics?) return pics;
    final urls = widget.urls;
    if (urls == null) return const [];
    return urls
        .where((e) => e.isNotEmpty)
        .map((e) {
          final size = _sizes[e];
          return Pic.fromJson({
            'url': e,
            'width': size?.$1 ?? 16,
            'height': size?.$2 ?? 9,
          });
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pics = _pics;
    if (pics.isEmpty) return const SizedBox.shrink();
    final length = pics.length;
    final first = pics.first;
    double height;
    if (first.height != null && first.width != null) {
      final ratio = first.height! / first.width!;
      height = min(widget.maxWidth * ratio, widget.maxHeight * 0.55);
    } else {
      height = widget.maxHeight * 0.55;
    }
    return Stack(
      clipBehavior: .none,
      children: [
        Container(
          height: height,
          width: widget.maxWidth,
          margin: const .only(bottom: 10),
          child: PageView.builder(
            physics: tabBarScrollPhysics,
            horizontalDragGestureRecognizer:
                CustomHorizontalDragGestureRecognizer.new,
            onPageChanged: widget.topIndex.call,
            itemCount: length,
            itemBuilder: (context, index) {
              final pic = pics[index];
              int? memCacheWidth, memCacheHeight;
              if (pic.isLongPic ?? false) {
                memCacheWidth = widget.maxWidth.cacheSize(context);
              } else if (pic.width != null && pic.height != null) {
                if (pic.width! > pic.height!) {
                  memCacheWidth = widget.maxWidth.cacheSize(context);
                } else {
                  memCacheHeight = height.cacheSize(context);
                }
              }
              return GestureDetector(
                behavior: .opaque,
                onTap: () => PageUtils.imageView(
                  quality: 60,
                  imgList: pics.map((e) => SourceModel(url: e.url!)).toList(),
                  initialPage: index,
                ),
                child: Hero(
                  tag: pic.url!,
                  child: Stack(
                    clipBehavior: .none,
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        height: height,
                        width: widget.maxWidth,
                        memCacheWidth: memCacheWidth,
                        memCacheHeight: memCacheHeight,
                        fit: pic.isLongPic == true ? BoxFit.cover : null,
                        imageUrl: ImageUtils.thumbnailUrl(pic.url, 60),
                        fadeInDuration: const Duration(milliseconds: 120),
                        fadeOutDuration: const Duration(milliseconds: 120),
                        placeholder: (_, _) => const SizedBox.shrink(),
                      ),
                      if (pic.isLongPic == true)
                        const PBadge(
                          right: 12,
                          bottom: 12,
                          text: '长图',
                          type: .primary,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Obx(
          () => PBadge(
            top: 12,
            right: 12,
            type: .gray,
            text: '${widget.topIndex.value + 1}/$length',
          ),
        ),
      ],
    );
  }
}
