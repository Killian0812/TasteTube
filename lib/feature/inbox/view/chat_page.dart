import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/injection.dart';

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

        return ChannelListPage(onTap: (c) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => StreamChat(
                client: getIt<GetstreamCubit>().client!,
                child: StreamChannel(
                  channel: c,
                  child: ChannelPage(channel: c),
                ),
              ),
            ),
          );
        });
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
        VerticalDivider(width: 1),
        Flexible(
          flex: 2,
          child: Scaffold(
            body: selectedChannel != null
                ? StreamChannel(
                    key: ValueKey(selectedChannel!.cid),
                    channel: selectedChannel!,
                    child: ChannelPage(
                      showBackButton: false,
                      channel: selectedChannel!,
                    ),
                  )
                : Center(
                    child: Text(
                      'TasteTube Messaging 💬',
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
  late final StreamChannelListController _listController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<User>? _searchResults;

  @override
  void initState() {
    super.initState();
    _listController = StreamChannelListController(
      client: StreamChat.of(context).client,
      filter: Filter.in_(
        'members',
        [StreamChat.of(context).currentUser!.id],
      ),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 20,
    );
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
        _searchUsers();
      });
    });
  }

  Future<void> _searchUsers() async {
    if (_searchQuery.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }

    final client = StreamChat.of(context).client;
    try {
      final response = await client.queryUsers(
        filter: Filter.and([
          Filter.notEqual('id', client.state.currentUser!.id),
          Filter.autoComplete('name', _searchQuery),
        ]),
        sort: const [SortOption('name')],
        pagination: const PaginationParams(limit: 20),
      );
      setState(() => _searchResults = response.users);
    } catch (e) {
      setState(() => _searchResults = []);
    }
  }

  Future<void> _createChannel(User user) async {
    final client = StreamChat.of(context).client;
    final channel = client.channel(
      'messaging',
      extraData: {
        'members': [client.state.currentUser!.id, user.id],
      },
    );

    await channel.watch();
    widget.onTap?.call(channel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
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
      body: _searchQuery.isEmpty
          ? StreamChannelListView(
              onChannelTap: widget.onTap,
              controller: _listController,
              itemBuilder: (context, channels, index, defaultWidget) {
                return defaultWidget.copyWith(
                  selected: channels[index] == widget.selectedChannel,
                );
              },
            )
          : _searchResults == null
              ? const SizedBox.shrink()
              : ListView.builder(
                  itemCount: _searchResults!.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults![index];
                    return ListTile(
                      leading: CircleAvatar(
                        foregroundImage: NetworkImage(user.image!),
                      ),
                      title: Text(user.name),
                      onTap: () => _createChannel(user),
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
    required this.channel,
  });

  final bool showBackButton;
  final Channel channel;

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  late final messageInputController = StreamMessageInputController();
  final focusNode = FocusNode();

  Channel get channel => widget.channel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamChannelHeader(
        onImageTap: () {
          if (channel.isGroup) return;
          final otherUser = channel.state!.members.firstWhere(
            (member) => member.userId != channel.client.state.currentUser!.id,
          );
          context.push('/user/${otherUser.userId}');
        },
        onBackPressed: () => context.pop(),
        showBackButton: widget.showBackButton,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              threadBuilder: (context, parent) => const SizedBox.shrink(),
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
                                child: StreamSvgIcon.reply(size: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: defaultWidget.copyWith(
                    showEditMessage: true,
                    showDeleteMessage: true,
                    onReplyTap: reply,
                    showReactionPicker: true,
                    onThreadTap: (p0) {},
                  ),
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
