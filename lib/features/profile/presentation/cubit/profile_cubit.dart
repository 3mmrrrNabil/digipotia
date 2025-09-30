import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/retrofit/ain_api.dart';
import '../../../reports/domain/repositories/reports_repository.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileState {
  final bool isLoading;
  final bool isSuccess;
  final List<ReportDto2> allItems;
  final MeResponseDto? data;
  final String? error;

  ProfileState(
      this.isSuccess,
      this.allItems, {
        this.isLoading = false,
        this.data,
        this.error,
      });

  factory ProfileState.initial() => ProfileState(
    false, // isSuccess false مبدئياً
    const [], // لا توجد تقارير في البداية
    isLoading: false,
    data: null,
    error: null,
  );

  ProfileState copyWith({
    bool? isLoading,
    MeResponseDto? data,
    String? error,
    List<ReportDto2>? allItems,
    bool? isSuccess,
  }) {
    return ProfileState(
      isSuccess ?? this.isSuccess,
      allItems ?? this.allItems,
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;
  final ReportsRepository _repo2;

  ProfileCubit(this._repo, this._repo2) : super(ProfileState.initial());
  int countStatus4() {
    return state.allItems.where((report) => report.status == '4').length;
  }
  Future<void> load({int retryCount = 0}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final res = await _repo.me();

      if (res == null && retryCount < 3) {
        // إعادة المحاولة لحد 3 مرات
        await Future.delayed(const Duration(seconds: 1));
        return load(retryCount: retryCount + 1);
      }

      emit(state.copyWith(isLoading: false, data: res, isSuccess: true));
      await getMyReports(res.id);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString(), isSuccess: false));
    }
  }

  Future<void> getMyReports(String id, {int retryCount = 0}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await _repo2.getMyReports(id, 1, 100);

      if ((items.isEmpty || items == null) && retryCount < 3) {
        await Future.delayed(const Duration(seconds: 1));
        return getMyReports(id, retryCount: retryCount + 1);
      }

      emit(state.copyWith(isLoading: false, allItems: items, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString(), allItems: [], isSuccess: false));
    }
  }
}
