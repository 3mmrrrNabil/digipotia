import '../../../../core/network/retrofit/ain_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/reports_repository.dart';

class FeedState {
  final ReportInteractionsDto? data;
  final bool isLoading;
  final bool isSuccess;
  final List<ReportDto> allItems;
  final List<ReportDto> securityItems;
  final List<ReportDto> safetyItems;
  final List<ReportDto> trafficItems;
  final List<ReportDto> environmentItems;
  final List<ReportDto> otherItems;
  final String? error;
  final Map<String, ReportInteractionsDto> postsMap; // موجود
  final Map<String, int> localCommentCounts; // ✅ جديد: عدد الكومنت المحلي

  FeedState({
    this.data,
    this.isLoading = false,
    this.isSuccess = false,
    required this.allItems,
    required this.securityItems,
    required this.safetyItems,
    required this.trafficItems,
    required this.environmentItems,
    required this.otherItems,
    this.error,
    required this.postsMap,
    required this.localCommentCounts, // ✅ مطلوب
  });

  FeedState copyWith({
    bool? isLoading,
    bool? isSuccess,
    List<ReportDto>? allItems,
    List<ReportDto>? securityItems,
    List<ReportDto>? safetyItems,
    List<ReportDto>? trafficItems,
    List<ReportDto>? environmentItems,
    List<ReportDto>? otherItems,
    String? error,
    ReportInteractionsDto? data,
    Map<String, ReportInteractionsDto>? postsMap,
    Map<String, int>? localCommentCounts, // ✅ تحديث الماب الجديد
  }) {
    return FeedState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      allItems: allItems ?? this.allItems,
      securityItems: securityItems ?? this.securityItems,
      safetyItems: safetyItems ?? this.safetyItems,
      trafficItems: trafficItems ?? this.trafficItems,
      environmentItems: environmentItems ?? this.environmentItems,
      otherItems: otherItems ?? this.otherItems,
      error: error,
      data: data ?? this.data,
      postsMap: postsMap ?? this.postsMap,
      localCommentCounts: localCommentCounts ?? this.localCommentCounts, // ✅ تحديث
    );
  }
}

@injectable
class FeedCubit extends Cubit<FeedState> {
  final ReportsRepository _repo;
  List<String> searchResults = [];

  FeedCubit(this._repo)
      : super(FeedState(
    allItems: [],
    securityItems: [],
    safetyItems: [],
    trafficItems: [],
    environmentItems: [],
    otherItems: [],
    postsMap: {},
    localCommentCounts: {}, // ✅ نبدأ فاضية
  ));
  void updateLocalCommentCount(String postId, int newCount) {
    final updatedLocalComments = Map<String, int>.from(state.localCommentCounts);
    updatedLocalComments[postId] = newCount;
    emit(state.copyWith(localCommentCounts: updatedLocalComments));
  }

  /// أو دالة بسيطة للزيادة بمقدار واحد لو حبيت
  void incrementComment(String postId) {
    final updatedLocalComments = Map<String, int>.from(state.localCommentCounts);
    updatedLocalComments[postId] = (updatedLocalComments[postId] ?? 0) + 1;
    emit(state.copyWith(localCommentCounts: updatedLocalComments));
  }

  void searchByDisplayName(String query) {
    final lowerQuery = query.toLowerCase();

    searchResults = state.allItems
        .where((item) {
      final post = state.postsMap[item.id];
      return post?.reporterDisplayName?.toLowerCase().contains(lowerQuery) ?? false;
    })
        .map((e) => e.id)
        .toList();

    emit(state.copyWith(isLoading: false));
  }

  Future<void> loadFirstPage() async {
    emit(state.copyWith(isLoading: true, postsMap: {}, localCommentCounts: {}));

    try {
      final items = await _repo.getFeed(1, 1000);
      final allIds = items.map((e) => e.id ?? "1").toList();
      await loadAllInteractions(allIds);

      final security = items.where((e) => e.category == 1).toList();
      final safety = items.where((e) => e.category == 2).toList();
      final traffic = items.where((e) => e.category == 3).toList();
      final environment = items.where((e) => e.category == 4).toList();
      final other = items.where((e) => e.category == 5).toList();

      // ✅ بعد تحميل البيانات
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        allItems: items,
        securityItems: security,
        safetyItems: safety,
        trafficItems: traffic,
        environmentItems: environment,
        otherItems: other,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: e.toString(),
      ));
    }
  }

  ReportInteractionsDto? getPostById(String id) {
    return state.postsMap[id];
  }

  Future<void> loadAllInteractions(List<String> allIds) async {
    try {
      final futures = allIds.map((id) => _repo.getInteractions(id));
      final results = await Future.wait(futures);

      final updatedMap = Map<String, ReportInteractionsDto>.from(state.postsMap);
      final updatedLocalComments = Map<String, int>.from(state.localCommentCounts);
      for (int i = 0; i < allIds.length; i++) {
        final id = allIds[i] ?? "1";
        updatedMap[id] = results[i];
        updatedLocalComments[id] = results[i].commentCount ?? 0; // ✅ عدد الكومنت الافتراضي
      }

      emit(state.copyWith(postsMap: updatedMap, localCommentCounts: updatedLocalComments));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

}
