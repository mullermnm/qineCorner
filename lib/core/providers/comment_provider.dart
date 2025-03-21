import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/models/comment.dart';
import 'package:qine_corner/core/providers/article_provider.dart';
import 'package:qine_corner/core/services/article_service.dart';

class CommentNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final ArticleService _service;
  final String articleId;

  CommentNotifier(this._service, this.articleId) : super(const AsyncValue.loading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      state = const AsyncValue.loading();
      final comments = await _service.getComments(articleId);
      if (!mounted) return;
      state = AsyncValue.data(comments);
    } catch (e, st) {
      if (!mounted) return;
      print('Error loading comments: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addComment(String content, {String? parentId}) async {
    try {
      print('Adding comment with parentId: $parentId'); // Debug log
      
      final newComment = await _service.addComment(
        articleId,
        content,
        parentId: parentId,
      );
      
      if (!mounted) return;

      state.whenData((comments) {
        if (parentId == null) {
          // Add as a top-level comment
          state = AsyncValue.data([newComment, ...comments]);
        } else {
          // Add as a reply
          final updatedComments = _addReply(comments, parentId, newComment);
          state = AsyncValue.data(updatedComments);
        }
      });
    } catch (e, st) {
      if (!mounted) return;
      print('Error adding comment: $e'); // Debug log
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  List<Comment> _addReply(List<Comment> comments, String parentId, Comment reply) {
    return comments.map((comment) {
      if (comment.id == parentId) {
        // Add the new reply to the existing replies
        final updatedReplies = [reply, ...comment.replies];
        return comment.copyWith(replies: updatedReplies);
      }
      // Also check nested replies
      if (comment.replies.isNotEmpty) {
        final updatedReplies = _addReply(comment.replies, parentId, reply);
        return comment.copyWith(replies: updatedReplies);
      }
      return comment;
    }).toList();
  }

  List<Comment> _updateCommentLike(List<Comment> comments, String commentId, bool liked) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        return comment.copyWith(
          isLiked: liked,
          likes: liked ? comment.likes + 1 : comment.likes - 1,
        );
      }
      // Also check replies
      if (comment.replies.isNotEmpty) {
        final updatedReplies = _updateCommentLike(comment.replies, commentId, liked);
        if (updatedReplies != comment.replies) {
          return comment.copyWith(replies: updatedReplies);
        }
      }
      return comment;
    }).toList();
  }

  Future<void> likeComment(String commentId) async {
    try {
      await _service.likeComment(commentId);
      state.whenData((comments) {
        state = AsyncValue.data(_updateCommentLike(comments, commentId, true));
      });
    } catch (e, st) {
      print('Error liking comment: $e');
      // Revert the optimistic update if the API call fails
      state.whenData((comments) {
        state = AsyncValue.data(_updateCommentLike(comments, commentId, false));
      });
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unlikeComment(String commentId) async {
    try {
      await _service.unlikeComment(commentId);
      state.whenData((comments) {
        state = AsyncValue.data(_updateCommentLike(comments, commentId, false));
      });
    } catch (e, st) {
      print('Error unliking comment: $e');
      // Revert the optimistic update if the API call fails
      state.whenData((comments) {
        state = AsyncValue.data(_updateCommentLike(comments, commentId, true));
      });
      state = AsyncValue.error(e, st);
    }
  }
}

final commentProvider = StateNotifierProvider.family<CommentNotifier, AsyncValue<List<Comment>>, String>(
  (ref, articleId) => CommentNotifier(
    ref.read(articleServiceProvider),
    articleId,
  ),
); 