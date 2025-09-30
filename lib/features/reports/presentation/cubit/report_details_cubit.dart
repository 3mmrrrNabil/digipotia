import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/retrofit/ain_api.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportDetailsState {
  final bool isLoading;
  final ReportInteractionsDto? data;
  final String? error;
  ReportDetailsState({this.isLoading = false, this.data, this.error});

  ReportDetailsState copyWith({bool? isLoading, ReportInteractionsDto? data, String? error}) {
    return ReportDetailsState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

@injectable
class ReportDetailsCubit extends Cubit<ReportDetailsState> {
  final ReportsRepository _repo;
  ReportDetailsCubit(this._repo) : super(ReportDetailsState());


}

