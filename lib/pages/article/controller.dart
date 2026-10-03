import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/image_preview_type.dart';
import 'package:PiliPlus/models/dynamics/article_content_model.dart'
    show ArticleContentModel, OpusTocItem, Pic;
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/models/model_avatar.dart';
import 'package:PiliPlus/models_new/article/article_view/data.dart';
import 'package:PiliPlus/models_new/dynamic/dyn_mention/item.dart';
import 'package:PiliPlus/pages/common/dyn/common_dyn_controller.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/url_utils.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ArticleController extends CommonDynController {
  late String id;
  late String type;

  late String url;
  late int commentId;
  @override
  int get oid => commentId;
  late int commentType;
  @override
  int get replyType => commentType;
  final summary = Summary();
  @override
  MentionItem? get mentionItem => summary.author?.mentionItem;

  late final RxInt topIndex = 0.obs;

  @override
  dynamic get sourceId => commentType == 12 ? 'cv$commentId' : id;

  final RxBool isLoaded = false.obs;
  DynamicItemModel? opusData; // 标题信息从summary获取, 动态没有favorite
  ArticleViewData? articleData;
  final stats = Rxn<ModuleStatModel>();

  List<ArticleContentModel>? get opus =>
      opusData?.modules.moduleContent ?? articleData?.opus?.content;

  /// opus 正文列表的控制器，用于目录跳转
  final listController = ListController();

  List<OpusTocItem>? _tocList;
  List<OpusTocItem>? get tocList => _tocList;
  final RxBool hasToc = false.obs;

  List<SourceModel>? _images;
  List<SourceModel> images() => _images ??= opus!
      .where((e) => e.paraType == 2 && e.pic != null)
      .map((e) => SourceModel(url: e.pic!.pics!.first.url!))
      .toList();

  /// 文集信息：opus 路径取 module_collection，read 路径取 /x/article/view 的 list
  ModuleCollection? get collection =>
      opusData?.modules.moduleCollection ?? articleData?.collection;

  /// opus 文首封面(服务端已带真实宽高)
  List<Pic>? get opusCoverPics =>
      opusData?.modules.moduleTop?.display?.album?.pics;

  /// read 文首封面(仅有 URL，由 ArticleCoverGallery 解析真实宽高)
  List<String>? get readCoverUrls =>
      opusData == null ? articleData?.originImageUrls : null;

  @override
  void onInit() {
    super.onInit();
    final params = Get.parameters;
    id = params['id']!;
    type = params['type']!;

    // to opus
    if (type == 'read') {
      UrlUtils.parseRedirectUrl('https://www.bilibili.com/read/cv$id/').then((
        url,
      ) {
        if (url != null) {
          final opusId = PiliScheme.uriDigitRegExp.firstMatch(url)?.group(1);
          if (opusId != null) {
            id = opusId;
            type = 'opus';
          }
          Get.putOrFind(() => this, tag: type + id);
        }
        init();
      });
    } else {
      init();
    }
  }

  void init() {
    url = type == 'read'
        ? 'https://www.bilibili.com/read/cv$id'
        : 'https://www.bilibili.com/opus/$id';
    commentType = type == 'picture' ? 11 : 12;

    _queryContent();
  }

  Future<bool> queryOpus(String opusId) async {
    final res = await DynamicsHttp.opusDetail(opusId: opusId);
    if (res case Success(:final response)) {
      //fallback
      if (response.fallback?.id != null) {
        id = response.fallback!.id!;
        type = 'read';
        init();
        return false;
      }
      opusData = response;
      commentType = response.basic!.commentType!;
      commentId = int.parse(response.basic!.commentIdStr!);
      if (showDynActionBar) {
        if (response.modules.moduleStat != null) {
          stats.value = response.modules.moduleStat;
        } else {
          getArticleInfo();
        }
      }
      summary
        ..author ??= response.modules.moduleAuthor
        ..title ??= response.modules.moduleTag?.text;
      return true;
    } else {
      loadingState.value = res as Error;
      return false;
    }
  }

  Future<bool> queryRead(int cvid) async {
    final res = await DynamicsHttp.articleView(cvId: cvid);
    if (res case Success(:final response)) {
      articleData = response;
      summary
        ..author ??= response.author
        ..title ??= response.title
        ..cover ??= response.originImageUrls?.firstOrNull;

      if (showDynActionBar) {
        getArticleInfo();
      }
      return true;
    } else {
      loadingState.value = res as Error;
      return false;
    }
  }

  // stats
  Future<bool> getArticleInfo([bool isGetCover = false]) async {
    final res = await DynamicsHttp.articleInfo(cvId: commentId);
    if (res case Success(:final response)) {
      summary
        ..cover ??= response.originImageUrls?.firstOrNull
        ..title ??= response.title;

      stats.value ??= ModuleStatModel(
        comment: DynamicStat(count: response.stats?.reply),
        forward: DynamicStat(count: response.stats?.share),
        like: DynamicStat(
          count: response.stats?.like,
          status: response.stats?.like == 1,
        ),
        favorite: DynamicStat(
          count: response.stats?.favorite,
          status: response.favorite,
        ),
      );
      return true;
    }
    if (isGetCover) {
      res.toast();
    }
    return false;
  }

  // 请求动态内容
  Future<void> _queryContent() async {
    if (type != 'read') {
      isLoaded.value = await queryOpus(id);
    } else {
      commentId = int.parse(id);
      commentType = 12;
      isLoaded.value = await queryRead(commentId);
    }
    if (isLoaded.value) {
      _buildToc();
      queryData();
      if (Accounts.heartbeat.isLogin && !Pref.historyPause) {
        VideoHttp.historyReport(aid: commentId, type: 5);
      }
    }
  }

  // 从 opus 正文段落中提取标题(H1/H2/H3)生成文章目录
  void _buildToc() {
    final content = opus;
    if (content == null || content.isEmpty) {
      _tocList = null;
      hasToc.value = false;
      return;
    }
    final list = <OpusTocItem>[];
    for (int i = 0; i < content.length; i++) {
      final element = content[i];
      if (element.paraType != 8) continue;
      final heading = element.heading;
      final nodes = heading?.nodes;
      if (nodes == null || nodes.isEmpty) continue;
      final title = nodes
          .map((e) => e.word?.words ?? e.rich?.text ?? '')
          .join()
          .trim();
      if (title.isEmpty) continue;
      list.add(
        OpusTocItem(
          level: heading?.level ?? 1,
          title: title,
          anchorIndex: i,
        ),
      );
    }
    _tocList = list.isEmpty ? null : list;
    hasToc.value = list.isNotEmpty;
  }

  // 目录点击跳转到对应段落
  void jumpToToc(int anchorIndex) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        final offset = listController.getOffsetToReveal(anchorIndex, 0.0);
        if (offset.isFinite && scrollController.hasClients) {
          scrollController.jumpTo(offset);
        }
      } catch (_) {}
    });
  }

  @override
  void onClose() {
    listController.dispose();
    super.onClose();
  }

  Future<void> onFav() async {
    final favorite = stats.value?.favorite;
    if (favorite == null) return;
    final isFav = favorite.status ?? false;
    final res = type == 'read'
        ? isFav
              ? await FavHttp.delFavArticle(id: commentId)
              : await FavHttp.addFavArticle(id: commentId)
        : await FavHttp.communityAction(opusId: id, action: isFav ? 4 : 3);
    if (res.isSuccess) {
      favorite
        ..status = !isFav
        ..count = (favorite.count ?? 0) + (isFav ? -1 : 1);
      stats.refresh();
      SmartDialog.showToast('${isFav ? '取消' : ''}收藏成功');
    } else {
      res.toast();
    }
  }

  Future<void> onLike() async {
    final like = stats.value?.like;
    if (like == null) return;
    final isLike = like.status ?? false;
    final res = await DynamicsHttp.thumbDynamic(
      dynamicId: opusData?.idStr ?? articleData?.dynIdStr,
      up: isLike ? 2 : 1,
    );
    if (res.isSuccess) {
      like
        ..status = !isLike
        ..count = (like.count ?? 0) + (isLike ? -1 : 1);
      stats.refresh();
      SmartDialog.showToast(!isLike ? '点赞成功' : '取消赞');
    } else {
      res.toast();
    }
  }

  @override
  Future<void> onReload() {
    if (!isLoaded.value) {
      return Future.syncValue(null);
    }
    return super.onReload();
  }
}

class Summary {
  Avatar? author;
  String? title;
  String? cover;

  Summary({this.author, this.title, this.cover});
}
