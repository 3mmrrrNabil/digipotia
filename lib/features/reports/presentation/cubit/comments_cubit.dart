import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/retrofit/ain_api.dart';
import '../../domain/repositories/reports_repository.dart';

class CommentsState {
  final bool isLoading;
  final List<CommentDto> items;
  final String? error;
  final int page;
  final bool hasMore;
  CommentsState({this.isLoading = false, this.items = const [], this.error, this.page = 1, this.hasMore = true});

  CommentsState copyWith({bool? isLoading, List<CommentDto>? items, String? error, int? page, bool? hasMore}) {
    return CommentsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@injectable
class CommentsCubit extends Cubit<CommentsState> {
  final ReportsRepository _repo;
  CommentsCubit(this._repo) : super(CommentsState());

  late String _reportId;

  void init(String reportId) {
    _reportId = reportId;
    loadFirstPage();
  }

  Future<void> loadFirstPage({int pageSize = 20}) async {
    emit(state.copyWith(isLoading: true, error: null, page: 1));
    try {
      final items = await _repo.getComments(_reportId, 1, pageSize);
      emit(state.copyWith(isLoading: false, items: items, page: 1, hasMore: items.length == pageSize));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMore({int pageSize = 20}) async {
    if (!state.hasMore || state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    final next = state.page + 1;
    try {
      final items = await _repo.getComments(_reportId, next, pageSize);
      emit(state.copyWith(
        isLoading: false,
        page: next,
        items: [...state.items, ...items],
        hasMore: items.length == pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addComment(String content) async {
    try {
      final created = await _repo.addComment(_reportId, AddCommentRequestDto(reportId: _reportId, content: content));
      emit(state.copyWith(items: [created, ...state.items]));
    } catch (_) {}
  }

  Future<void> editComment(String commentId, String content) async {
    try {
      final updated = await _repo.updateComment(commentId, UpdateCommentRequestDto(content: content));
      final next = [...state.items];
      final idx = next.indexWhere((e) => e.id == commentId);
      if (idx != -1) {
        next[idx] = updated;
        emit(state.copyWith(items: next));
      }
    } catch (_) {}
  }

  Future<void> removeComment(String commentId) async {
    try {
      await _repo.deleteComment(commentId);
      emit(state.copyWith(items: state.items.where((e) => e.id != commentId).toList()));
    } catch (_) {}
  }
}

