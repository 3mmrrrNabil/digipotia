import 'dart:io';
import 'package:injectable/injectable.dart';

import '../../../../core/network/retrofit/ain_api.dart';

abstract class ReportsRemoteDataSource {
  Future<CreatedIdDto> createReport(CreateReportRequestDto body);
  Future<ReportDto> getReport(String id);
  Future<List<ReportDto>> getFeed(int page, int pageSize);
  Future<List<ReportDto2>> getMyReports(String id, int page, int pageSize);
  Future<void> patchStatus(String id, String statusJsonString);
  Future<ReportInteractionsDto> getInteractions(String id);
  Future<MessageResponseDto> updateReport(String id, UpdateReportRequestDto body);
  Future<void> deleteReport(String id);
  Future<LikeResponseDto> likeReport(String id);
  Future<CommentDto> addComment(String id, AddCommentRequestDto body);
  Future<List<CommentDto>> getComments(String id, int page, int pageSize);
  Future<UploadResponseDto> upload(String id, File file);
  Future<CommentDto> updateComment(String commentId, UpdateCommentRequestDto body);
  Future<void> deleteComment(String commentId);
}

@Injectable(as: ReportsRemoteDataSource)
class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final AinApi _api;
  ReportsRemoteDataSourceImpl(this._api);

  @override
  Future<CreatedIdDto> createReport(CreateReportRequestDto body) => _api.createReport(body);

  @override
  Future<ReportDto> getReport(String id) => _api.getReport(id);

  @override
  Future<List<ReportDto>> getFeed(int page, int pageSize) async=>await _api.getFeed(page, pageSize);

  @override
  Future<List<ReportDto2>> getMyReports(String id, int page, int pageSize) async=>await _api.getMyReports(id,page, pageSize);

  @override
  Future<void> patchStatus(String id, String statusJsonString) => _api.patchStatus(id, statusJsonString);

  @override
  Future<ReportInteractionsDto> getInteractions(String id) => _api.getInteractions(id);

  @override
  Future<MessageResponseDto> updateReport(String id, UpdateReportRequestDto body) => _api.updateReport(id, body);

  @override
  Future<void> deleteReport(String id) => _api.deleteReport(id);

  @override
  Future<LikeResponseDto> likeReport(String id) => _api.likeReport(id);

  @override
  Future<CommentDto> addComment(String id, AddCommentRequestDto body) => _api.addComment(id, body);

  @override
  Future<List<CommentDto>> getComments(String id, int page, int pageSize) => _api.getComments(id, page, pageSize);

  @override
  Future<UploadResponseDto> upload(String id, File file) => _api.uploadAttachment(id, file);

  @override
  Future<CommentDto> updateComment(String commentId, UpdateCommentRequestDto body) => _api.updateComment(commentId, body);

  @override
  Future<void> deleteComment(String commentId) => _api.deleteComment(commentId);
}

