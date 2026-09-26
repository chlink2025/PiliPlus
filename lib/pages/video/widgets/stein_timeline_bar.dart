import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models_new/video/video_stein_edgeinfo/story.dart';
import 'package:material_ui/material_ui.dart';

class SteinTimelineBar extends StatefulWidget {
  const SteinTimelineBar({
    super.key,
    required this.timeline,
    required this.currentId,
    required this.onJump,
    required this.onRestart,
  });

  final List<Story> timeline;
  final int? currentId;
  final ValueChanged<Story> onJump;
  final VoidCallback onRestart;

  @override
  State<SteinTimelineBar> createState() => _SteinTimelineBarState();
}

class _SteinTimelineBarState extends State<SteinTimelineBar> {
  static const double _itemWidth = 128;
  static const double _itemSpacing = 8;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  @override
  void didUpdateWidget(covariant SteinTimelineBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentId != widget.currentId ||
        oldWidget.timeline.length != widget.timeline.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    }
  }

  int get _currentIndex {
    if (widget.timeline.isEmpty) return -1;
    final id = widget.currentId;
    if (id != null) {
      final i = widget.timeline.indexWhere((e) => e.id == id);
      if (i >= 0) return i;
    }
    final i = widget.timeline.indexWhere((e) => e.isCurrent == 1);
    if (i >= 0) return i;
    return widget.timeline.length - 1;
  }

  void _scrollToCurrent() {
    if (!_controller.hasClients) return;
    final index = _currentIndex;
    if (index < 0) return;
    final offset = 72 + index * (_itemWidth + _itemSpacing);
    _controller.animateTo(
      offset.clamp(0.0, _controller.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = _currentIndex;
    return Container(
      height: 92,
      decoration: const BoxDecoration(
        color: Color(0xAA000000),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: widget.timeline.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: _itemSpacing),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _restartItem();
          }
          return _storyItem(
            colorScheme,
            widget.timeline[index - 1],
            index - 1 == currentIndex,
          );
        },
      ),
    );
  }

  Widget _restartItem() {
    return InkWell(
      onTap: widget.onRestart,
      borderRadius: BorderRadius.circular(6),
      child: const SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restart_alt, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              '重新开始',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storyItem(ColorScheme colorScheme, Story story, bool current) {
    final cover = story.cover?.isNotEmpty == true
        ? story.cover
        : (story.cid != null
              ? 'https://i0.hdslb.com/bfs/steins-gate/${story.cid}_screenshot.jpg'
              : null);
    return InkWell(
      onTap: () => widget.onJump(story),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: _itemWidth,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: current ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            NetworkImgLayer(
              src: cover,
              width: 52,
              height: 52,
              quality: 100,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                story.title?.isNotEmpty == true
                    ? story.title!
                    : '节点 ${story.id}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: current ? colorScheme.primary : Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
