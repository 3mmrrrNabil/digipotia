import 'dart:io';

import '../../../../core/network/retrofit/ain_api.dart';

abstract class ReportsRepository {
  Future<String> createReport(CreateReportRequestDto body);
  Future<ReportDto> getReport(String id);
  Future<List<ReportDto>> getFeed(int page, int pageSize);
  Future<List<ReportDto2>> getMyReports(String id,int page, int pageSize);
  Future<void> patchStatus(String id, String statusJsonString);
  Future<ReportInteractionsDto> getInteractions(String id);
  Future<void> deleteReport(String id);
  Future<MessageResponseDto> updateReport(String id, UpdateReportRequestDto body);
  Future<LikeResponseDto> likeReport(String id);
  Future<CommentDto> addComment(String id, AddCommentRequestDto body);
  Future<List<CommentDto>> getComments(String id, int page, int pageSize);
  Future<UploadResponseDto> upload(String id, File file);
  Future<CommentDto> updateComment(String commentId, UpdateCommentRequestDto body);
  Future<void> deleteComment(String commentId);
}

