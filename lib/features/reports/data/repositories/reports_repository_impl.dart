import 'dart:io';
import 'package:injectable/injectable.dart';

import '../../../../core/network/retrofit/ain_api.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';


@Injectable(as: ReportsRepository)
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource _remote;
  ReportsRepositoryImpl(this._remote);

  @override
  Future<String> createReport(CreateReportRequestDto body) async {
    final res = await _remote.createReport(body);
    return res.id;
  }

  @override
  Future<ReportDto> getReport(String id) => _remote.getReport(id);

  @override
  Future<List<ReportDto>> getFeed(int page, int pageSize) async=>await _remote.getFeed(page, pageSize);
  @override
  Future<List<ReportDto2>> getMyReports(String id,int page, int pageSize) async=>await _remote.getMyReports(id,page, pageSize);


  @override
  Future<void> patchStatus(String id, String statusJsonString) => _remote.patchStatus(id, statusJsonString);

  @override
  Future<ReportInteractionsDto> getInteractions(String id) => _remote.getInteractions(id);

  @override
  Future<void> deleteReport(String id) => _remote.deleteReport(id);

  @override
  Future<MessageResponseDto> updateReport(String id, UpdateReportRequestDto body) => _remote.updateReport(id, body);

  @override
  Future<LikeResponseDto> likeReport(String id) => _remote.likeReport(id);

  @override
  Future<CommentDto> addComment(String id, AddCommentRequestDto body) => _remote.addComment(id, body);

  @override
  Future<List<CommentDto>> getComments(String id, int page, int pageSize) => _remote.getComments(id, page, pageSize);

  @override
  Future<UploadResponseDto> upload(String id, File file) => _remote.upload(id, file);

  @override
  Future<CommentDto> updateComment(String commentId, UpdateCommentRequestDto body) => _remote.updateComment(commentId, body);

  @override
  Future<void> deleteComment(String commentId) => _remote.deleteComment(commentId);
}

