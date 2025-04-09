import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetstreamCubit, GetstreamState>(
      builder: (context, state) {
        if (state is GetstreamSuccess) {
          return StreamChat(
            client: state.client,
            child: const ResponsiveChat(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ResponsiveChat extends StatelessWidget {
  const ResponsiveChat({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.isDesktop || sizingInformation.isTablet) {
          return const SplitView();
        }

        return ChannelListPage(
          onTap: (c) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StreamChannel(
                channel: c,
                child: ChannelPage(
                  onBackPressed: (context) {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SplitView extends StatefulWidget {
  const SplitView({super.key});

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  Channel? selectedChannel;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Flexible(
          child: ChannelListPage(
            onTap: (channel) {
              setState(() {
                selectedChannel = channel;
              });
            },
            selectedChannel: selectedChannel,
          ),
        ),
        // Vertical separator
        VerticalDivider(width: 1),
        Flexible(
          flex: 2,
          child: Scaffold(
            body: selectedChannel != null
                ? StreamChannel(
                    key: ValueKey(selectedChannel!.cid),
                    channel: selectedChannel!,
                    child: const ChannelPage(showBackButton: false),
                  )
                : Center(
                    child: Text(
                      'Pick a channel to show the messages 💬',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({
    super.key,
    this.onTap,
    this.selectedChannel,
  });

  final void Function(Channel)? onTap;
  final Channel? selectedChannel;

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  late StreamChannelListController _listController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
        _updateController();
      });
    });
  }

  void _initializeController() {
    _listController = StreamChannelListController(
      client: StreamChat.of(context).client,
      filter: Filter.in_(
        'members',
        [StreamChat.of(context).currentUser!.id],
      ),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 20,
    );
  }

  void _updateController() {
    _listController.dispose();
    Filter baseFilter = Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    );
    _listController = StreamChannelListController(
      client: StreamChat.of(context).client,
      filter: _searchQuery.isNotEmpty
          ? Filter.and([
              baseFilter,
              Filter.contains('name', _searchQuery),
            ])
          : baseFilter,
      channelStateSort: const [SortOption('last_message_at')],
      limit: 20,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
        ),
        elevation: 1,
      ),
      body: StreamChannelListView(
        onChannelTap: widget.onTap,
        controller: _listController,
        itemBuilder: (context, channels, index, defaultWidget) {
          return defaultWidget.copyWith(
            selected: channels[index] == widget.selectedChannel,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }
}

class ChannelPage extends StatefulWidget {
  const ChannelPage({
    super.key,
    this.showBackButton = true,
    this.onBackPressed,
  });

  final bool showBackButton;
  final void Function(BuildContext)? onBackPressed;

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  late final messageInputController = StreamMessageInputController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamChannelHeader(
        onBackPressed: widget.onBackPressed != null
            ? () {
                widget.onBackPressed!(context);
              }
            : null,
        showBackButton: widget.showBackButton,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              threadBuilder: (_, parent) => ThreadPage(parent: parent!),
              messageBuilder: (
                context,
                messageDetails,
                messages,
                defaultWidget,
              ) {
                const threshold = 0.2;
                final isMyMessage = messageDetails.isMyMessage;
                final swipeDirection = isMyMessage
                    ? SwipeDirection.endToStart
                    : SwipeDirection.startToEnd;

                return Swipeable(
                  key: ValueKey(messageDetails.message.id),
                  direction: swipeDirection,
                  swipeThreshold: threshold,
                  onSwiped: (details) => reply(messageDetails.message),
                  backgroundBuilder: (context, details) {
                    final alignment = isMyMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft;
                    final progress =
                        math.min(details.progress, threshold) / threshold;
                    var offset = Offset.lerp(
                      const Offset(-24, 0),
                      const Offset(12, 0),
                      progress,
                    )!;
                    if (isMyMessage) {
                      offset = Offset(-offset.dx, -offset.dy);
                    }
                    final streamTheme = StreamChatTheme.of(context);

                    return Align(
                      alignment: alignment,
                      child: Transform.translate(
                        offset: offset,
                        child: Opacity(
                          opacity: progress,
                          child: SizedBox.square(
                            dimension: 30,
                            child: CustomPaint(
                              painter: AnimatedCircleBorderPainter(
                                progress: progress,
                                color: streamTheme.colorTheme.borders,
                              ),
                              child: Center(
                                child: StreamSvgIcon.reply(
                                  size: 18,
                                  color: streamTheme.colorTheme.accentPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: defaultWidget.copyWith(onReplyTap: reply),
                );
              },
            ),
          ),
          StreamMessageInput(
            onQuotedMessageCleared: messageInputController.clearQuotedMessage,
            focusNode: focusNode,
            messageInputController: messageInputController,
          ),
        ],
      ),
    );
  }

  void reply(Message message) {
    messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    messageInputController.dispose();
    super.dispose();
  }
}

class ThreadPage extends StatelessWidget {
  const ThreadPage({
    super.key,
    required this.parent,
  });

  final Message parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamThreadHeader(
        parent: parent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              parentMessage: parent,
            ),
          ),
          StreamMessageInput(
            messageInputController: StreamMessageInputController(
              message: Message(parentId: parent.id),
            ),
          ),
        ],
      ),
    );
  }
}
