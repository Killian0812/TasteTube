import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/global_data/watch/comment.dart';
import 'package:timeago/timeago.dart' as timeago;

void showCommentsBottomSheet(BuildContext context, SingleVideoCubit cubit) {
  final TextEditingController commentController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.6,
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      "Comments",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SingleVideoCubit, SingleVideoState>(
                    bloc: cubit,
                    builder: (context, state) {
                      final comments = state.comments.reversed.toList();

                      if (comments.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "Be the first to comment!",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 30),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return CommentTile(comment: comment, cubit: cubit);
                        },
                      );
                    },
                  ),
                ),
                CommentInputField(
                  commentController: commentController,
                  cubit: cubit,
                  focusNode: focusNode,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class CommentTile extends StatelessWidget {
  final Comment comment;
  final SingleVideoCubit cubit;

  const CommentTile({super.key, required this.comment, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final String relativeTime =
        timeago.format(comment.createdAt, allowFromNow: true);
    final expansionTileController = ExpansionTileController();

    return GestureDetector(
      onLongPress: () async {
        bool? confirmed = await showConfirmDialog(
          context,
          title: "Confirm delete comment",
          body: 'Are you sure you want to delete this comment?',
        );
        if (confirmed != true) {
          return;
        }
        await cubit.deleteComment(comment);
      },
      child: ExpansionTile(
        controller: expansionTileController,
        tilePadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(comment.avatar),
        ),
        title: Text(
          comment.username,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.text,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  relativeTime,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 30),
                if (comment.replies.isNotEmpty)
                  Text(
                    '${comment.replies.length} replies',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(width: 30),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    cubit.setReplyToComment(comment);
                    expansionTileController.expand();
                    FocusScope.of(context).requestFocus();
                  },
                  child: Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const SizedBox.shrink(),
        childrenPadding: const EdgeInsets.only(left: 30),
        children: [
          for (Comment reply in comment.replies.reversed)
            ReplyTile(reply: reply, cubit: cubit),
        ],
      ),
    );
  }
}

class ReplyTile extends StatelessWidget {
  final Comment reply;
  final SingleVideoCubit cubit;

  const ReplyTile({super.key, required this.reply, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final String relativeTime = timeago.format(reply.createdAt);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () async {
        bool? confirmed = await showConfirmDialog(
          context,
          title: "Confirm delete comment",
          body: 'Are you sure you want to delete this comment?',
        );
        if (confirmed != true) {
          return;
        }
        await cubit.deleteComment(reply);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 40.0, right: 10.0),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(reply.avatar),
        ),
        title: Text(
          reply.username,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reply.text,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              relativeTime,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentInputField extends StatelessWidget {
  final TextEditingController commentController;
  final SingleVideoCubit cubit;
  final FocusNode focusNode;

  const CommentInputField({
    super.key,
    required this.commentController,
    required this.cubit,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BlocBuilder<SingleVideoCubit, SingleVideoState>(
        bloc: cubit,
        builder: (context, state) => Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: commentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: state.replyingComment != null
                      ? 'Replying to ${state.replyingComment!.username}'
                      : "Add a comment...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: state.replyingComment != null
                      ? IconButton(
                          onPressed: () {
                            cubit.setReplyToComment(null);
                            commentController.clear();
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  cubit.postComment(commentController.text);
                  commentController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
