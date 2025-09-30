import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../remote/api_constants.dart';

part 'ain_api.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl2)
@singleton
abstract class AinApi {
  factory AinApi(Dio dio, {String baseUrl}) = _AinApi;

  // Auth
  @POST('/api/auth/register')
  Future<RegisterResponseDto> register(@Body() RegisterRequestDto body);

  @POST('/api/auth/verify-otp')
  Future<String> verifyOtp(@Body() VerifyOtpRequestDto body);

  @POST('/api/auth/login')
  Future<AuthTokenResponseDto> login(@Body() LoginRequestDto body);

  @GET('/api/auth/me')
  Future<MeResponseDto> me();

  @POST('/api/auth/forget-password')
  Future<MessageResponseDto> forgetPassword(@Body() ForgetPasswordRequestDto body);

  @POST('/api/auth/reset-password')
  Future<MessageResponseDto> resetPassword(@Body() ResetPasswordRequestDto body);

  @POST('/api/auth/refresh-token')
  Future<RefreshTokenResponseDto> refreshToken(@Body() RefreshTokenRequestDto body);

  // Authorities
  @GET('/api/authorities')
  Future<List<AuthorityDto>> getAuthorities();

  // Reports
  @POST('/api/reports')
  Future<CreatedIdDto> createReport(@Body() CreateReportRequestDto body);

  @GET('/api/reports/{id}')
  Future<ReportDto> getReport(@Path('id') String id);

  @GET('/api/feed')
  Future<List<ReportDto>> getFeed(@Query('page') int page, @Query('pageSize') int pageSize);
  @GET('/api/users/{id}/reports')
  Future<List<ReportDto2>> getMyReports(@Path('id') String id,@Query('page') int page, @Query('pageSize') int pageSize);

  @PATCH('/api/reports/{id}/status')
  Future<void> patchStatus(@Path('id') String id, @Body() String statusJsonString);

  @GET('/api/reports/{id}/interactions')
  Future<ReportInteractionsDto> getInteractions(@Path('id') String id);

  @PUT('/api/reports/{id}')
  Future<MessageResponseDto> updateReport(@Path('id') String id, @Body() UpdateReportRequestDto body);

  @DELETE('/api/reports/{id}')
  Future<void> deleteReport(@Path('id') String id);

  @POST('/api/reports/{id}/like')
  Future<LikeResponseDto> likeReport(@Path('id') String id);

  @POST('/api/reports/{id}/comments')
  Future<CommentDto> addComment(@Path('id') String id, @Body() AddCommentRequestDto body);

  @GET('/api/reports/{id}/comments')
  Future<List<CommentDto>> getComments(
    @Path('id') String id,
    @Query('page') int page,
    @Query('pageSize') int pageSize,
  );

  @PUT('/api/comments/{commentId}')
  Future<CommentDto> updateComment(@Path('commentId') String commentId, @Body() UpdateCommentRequestDto body);

  @DELETE('/api/comments/{commentId}')
  Future<void> deleteComment(@Path('commentId') String commentId);

  // Attachments
  @POST('/api/reports/{id}/attachments')
  @MultiPart()
  Future<UploadResponseDto> uploadAttachment(
    @Path('id') String id,
    @Part(name: 'file') File file,
  );

  // Admin
  @GET('/api/admin/users')
  Future<AdminUsersPageDto> getAdminUsers(
    @Query('page') int page,
    @Query('pageSize') int pageSize,
  );

  @GET('/api/admin/users/{userId}')
  Future<AdminUserDto> getAdminUser(@Path('userId') String userId);

  @PUT('/api/admin/users/{userId}')
  Future<MessageResponseDto> updateAdminUser(@Path('userId') String userId, @Body() UpdateAdminUserRequestDto body);

  @DELETE('/api/admin/users/{userId}')
  Future<void> deleteAdminUser(@Path('userId') String userId);
}

// DTOs (json_serializable)
// Keep minimal now; can expand fields later
class RegisterRequestDto {
  final String email;
  final String displayName;
  final String password;
  RegisterRequestDto({required this.email, required this.displayName, required this.password});
  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) => RegisterRequestDto(
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        password: json['password'] as String,
      );
  Map<String, dynamic> toJson() => {'email': email, 'displayName': displayName, 'password': password};
}

class RegisterResponseDto {
  final String id;
  final String email;
  final String displayName;
  RegisterResponseDto({required this.id, required this.email, required this.displayName});
  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) =>
      RegisterResponseDto(id: json['id'] as String, email: json['email'] as String, displayName: json['displayName'] as String);
  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'displayName': displayName};
}

class VerifyOtpRequestDto {
  final String email;
  final String otp;
  VerifyOtpRequestDto({required this.email, required this.otp});
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class LoginRequestDto {
  final String email;
  final String password;
  LoginRequestDto({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class AuthTokenResponseDto {
  final String token;
  final String userId;
  final String refreshToken;
  final String expiry;
  AuthTokenResponseDto({required this.token, required this.userId, required this.refreshToken, required this.expiry});
  factory AuthTokenResponseDto.fromJson(Map<String, dynamic> json) => AuthTokenResponseDto(
        token: json['token'] as String,
        userId: json['userId'] as String,
        refreshToken: json['refreshToken'] as String,
        expiry: json['expiry'] as String,
      );
}

class MeResponseDto {
  final String id;
  final String email;
  final String displayName;
  final int trustPoints;
  final int badge;
  MeResponseDto({required this.id, required this.email, required this.displayName, required this.trustPoints, required this.badge});
  factory MeResponseDto.fromJson(Map<String, dynamic> json) => MeResponseDto(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        trustPoints: json['trustPoints'] as int,
        badge: json['badge'] as int,
      );
}

class ForgetPasswordRequestDto {
  final String email;
  ForgetPasswordRequestDto({required this.email});
  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequestDto {
  final String email;
  final String otp;
  final String newPassword;
  ResetPasswordRequestDto({required this.email, required this.otp, required this.newPassword});
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp, 'newPassword': newPassword};
}

class RefreshTokenRequestDto {
  final String refreshToken;
  RefreshTokenRequestDto({required this.refreshToken});
  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class RefreshTokenResponseDto {
  final String token;
  final String refreshToken;
  final String expiry;
  RefreshTokenResponseDto({required this.token, required this.refreshToken, required this.expiry});
  factory RefreshTokenResponseDto.fromJson(Map<String, dynamic> json) => RefreshTokenResponseDto(
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String,
        expiry: json['expiry'] as String,
      );
}

class MessageResponseDto {
  final String message;
  MessageResponseDto({required this.message});
  factory MessageResponseDto.fromJson(Map<String, dynamic> json) => MessageResponseDto(message: json['message'] as String);
}

class AuthorityDto {
  final String id;
  final String name;
  final String department;
  AuthorityDto({required this.id, required this.name, required this.department});
  factory AuthorityDto.fromJson(Map<String, dynamic> json) => AuthorityDto(
        id: json['id'] as String,
        name: json['name'] as String,
        department: json['department'] as String,
      );
}

class CreatedIdDto {
  final String id;
  CreatedIdDto({required this.id});
  factory CreatedIdDto.fromJson(Map<String, dynamic> json) => CreatedIdDto(id: json['id'] as String);
}

class AttachmentDto {
  final String id;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String url;
  AttachmentDto({required this.id, required this.fileName, required this.contentType, required this.sizeBytes, required this.url});
  factory AttachmentDto.fromJson(Map<String, dynamic>? json) {
    return AttachmentDto(
      id: json?['id']?.toString() ?? 'dummy_id',
      fileName: json?['fileName']?.toString() ?? 'dummy_file',
      contentType: json?['contentType']?.toString() ?? 'application/octet-stream',
      sizeBytes: (json?['sizeBytes'] as num?)?.toInt() ?? 0,
      url: json?['url']?.toString() ?? 'https://dummy.url/file',
    );
  }

}

String _enumFromDynamic(dynamic value, List<String> orderedNames) {
  if (value is String) return value;
  if (value is num) {
    final idx = value.toInt();
    if (idx >= 1 && idx <= orderedNames.length) return orderedNames[idx - 1];
    if (idx >= 0 && idx < orderedNames.length) return orderedNames[idx];
  }
  return value?.toString() ?? '';
}

class ReportDto2 {
  final String id;
  final String title;
  final String description;
  final int category;
  final int visibility;
  final String status;
  final double latitude;
  final double longitude;
  final String createdAt;
  final String reporterId;
  final String routedAuthorityId;
  final List<AttachmentDto> attachments;

  ReportDto2({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.visibility,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.reporterId,
    required this.routedAuthorityId,
    required this.attachments,
  });

  factory ReportDto2.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Report JSON is null');
    }

    // أي حقل null من السيرفر هيطلع Exception مباشرة
    return ReportDto2(
      id: json['id']?.toString() ?? (throw Exception('Id is null')),
      title: json['title']?.toString() ?? (throw Exception('Title is null')),
      description: json['description']?.toString() ?? (throw Exception('Description is null')),
      category: (json['category'] as num?)?.toInt() ?? (throw Exception('Category is null')),
      visibility: (json['visibility'] as num?)?.toInt() ?? (throw Exception('Visibility is null')),
      status: json['status']?.toString() ?? (throw Exception('Status is null')),
      latitude: (json['latitude'] as num?)?.toDouble() ?? (throw Exception('Latitude is null')),
      longitude: (json['longitude'] as num?)?.toDouble() ?? (throw Exception('Longitude is null')),
      createdAt: json['createdAt']?.toString() ?? (throw Exception('CreatedAt is null')),
      reporterId: json['reporterId']?.toString() ?? (throw Exception('ReporterId is null')),
      routedAuthorityId: json['routedAuthorityId']?.toString() ?? (throw Exception('RoutedAuthorityId is null')),
      attachments: ((json['attachments'] as List<dynamic>?) ?? [])
          .map((e) => AttachmentDto.fromJson(e as Map<String, dynamic>?))
          .toList(),
    );
  }
}
class ReportDto {
   String id;
   String title;
   String description;
   int category;
   int visibility;
   String status;
   double latitude;
   double longitude;
   String createdAt;
   String reporterId;
   String routedAuthorityId;
   List<AttachmentDto> attachments;

  ReportDto({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.visibility,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.reporterId,
    required this.routedAuthorityId,
    required this.attachments,
  });

  factory ReportDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Report JSON is null');
    }

    // أي حقل null من السيرفر هيطلع Exception مباشرة
    return ReportDto(
      id: json['id']?.toString() ?? (throw Exception('Id is null')),
      title: json['title']?.toString() ?? (throw Exception('Title is null')),
      description: json['description']?.toString() ?? (throw Exception('Description is null')),
      category: (json['category'] as num?)?.toInt() ?? (throw Exception('Category is null')),
      visibility: (json['visibility'] as num?)?.toInt() ?? (throw Exception('Visibility is null')),
      status: json['status']?.toString() ?? (throw Exception('Status is null')),
      latitude: (json['latitude'] as num?)?.toDouble() ?? (throw Exception('Latitude is null')),
      longitude: (json['longitude'] as num?)?.toDouble() ?? (throw Exception('Longitude is null')),
      createdAt: json['createdAt']?.toString() ?? (throw Exception('CreatedAt is null')),
      reporterId: json['reporterId']?.toString() ?? (throw Exception('ReporterId is null')),
      routedAuthorityId: json['routedAuthorityId']?.toString() ?? (throw Exception('RoutedAuthorityId is null')),
      attachments: ((json['attachments'] as List<dynamic>?) ?? [])
          .map((e) => AttachmentDto.fromJson(e as Map<String, dynamic>?))
          .toList(),
    );
  }
}

class CreateReportRequestDto {
  final String title;
  final String description;
  final int category;
  final int visibility;
  final double latitude;
  final double longitude;
  final String reporterId;
  CreateReportRequestDto({
    required this.title,
    required this.description,
    required this.category,
    required this.visibility,
    required this.latitude,
    required this.longitude,
    required this.reporterId,
  });
  Map<String, dynamic> toJson() => {
        'Title': title,
        'Description': description,
        'Category': category,
        'Visibility': visibility,
        'Latitude': latitude,
        'Longitude': longitude,
        'ReporterId': reporterId,
      };
}

class UpdateReportRequestDto {
   String title;
  final String description;
  final int category;
  final int visibility;
  final double latitude;
  final double longitude;
  UpdateReportRequestDto({
    required this.title,
    required this.description,
    required this.category,
    required this.visibility,
    required this.latitude,
    required this.longitude,
  });
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'visibility': visibility,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class ReportInteractionsDto extends ReportDto {
  final String? reporterDisplayName;
  final String? authorityName;
   int likeCount;
   int commentCount;
   bool isLikedByCurrentUser;
  final List<CommentDto> recentComments;
  ReportInteractionsDto({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.visibility,
    required super.status,
    required super.latitude,
    required super.longitude,
    required super.createdAt,
    required super.reporterId,
    required super.routedAuthorityId,
    required super.attachments,
    this.reporterDisplayName,
    this.authorityName,
    required this.likeCount,
    required this.commentCount,
    required this.isLikedByCurrentUser,
    required this.recentComments,
  }) : super();

  factory ReportInteractionsDto.fromJson(Map<String, dynamic> json) {
    return ReportInteractionsDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: (json['category'] as num).toInt(),
      visibility: (json['visibility'] as num).toInt(),
      status: _enumFromDynamic(json['status'], const ['Pending','InReview','Dispatched','Resolved','Rejected']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      reporterId: json['reporterId'] as String,
      routedAuthorityId: json['routedAuthorityId'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <AttachmentDto>[],
      reporterDisplayName: json['reporterDisplayName'] as String?,
      authorityName: json['authorityName'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
      recentComments: (json['recentComments'] as List<dynamic>?)
              ?.map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <CommentDto>[],
    );
  }
}

class LikeResponseDto {
  final bool isLiked;
  final String message;
  LikeResponseDto({required this.isLiked, required this.message});
  factory LikeResponseDto.fromJson(Map<String, dynamic> json) =>
      LikeResponseDto(isLiked: json['isLiked'] as bool, message: json['message'] as String);
}

class AddCommentRequestDto {
  final String reportId;
  final String content;
  AddCommentRequestDto({required this.reportId, required this.content});
  Map<String, dynamic> toJson() => {'reportId': reportId, 'content': content};
}

class UpdateCommentRequestDto {
  final String content;
  UpdateCommentRequestDto({required this.content});
  Map<String, dynamic> toJson() => {'content': content};
}

class CommentDto {
  final String id;
  final String reportId;
  final String userId;
  final String userDisplayName;
  final String content;
  final String createdAt;
  final String? updatedAt;
  CommentDto({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.userDisplayName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });
  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
        id: json['id'] as String,
        reportId: json['reportId'] as String,
        userId: json['userId'] as String,
        userDisplayName: json['userDisplayName'] as String,
        content: json['content'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String?,
      );
}

class UploadResponseDto {
  final String id;
  final String url;
  UploadResponseDto({required this.id, required this.url});
  factory UploadResponseDto.fromJson(Map<String, dynamic> json) =>
      UploadResponseDto(id: json['id'] as String, url: json['url'] as String);
}

class AdminUserDto {
  final String id;
  final String email;
  final String displayName;
  final int trustPoints;
  final String badge;
  final String role;
  final bool isEmailConfirmed;
  final String lastLogin;
  final int reportsCount;
  final String createdAt;
  AdminUserDto({
    required this.id,
    required this.email,
    required this.displayName,
    required this.trustPoints,
    required this.badge,
    required this.role,
    required this.isEmailConfirmed,
    required this.lastLogin,
    required this.reportsCount,
    required this.createdAt,
  });
  factory AdminUserDto.fromJson(Map<String, dynamic> json) => AdminUserDto(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        trustPoints: json['trustPoints'] as int,
        badge: json['badge'] as String,
        role: json['role'] as String,
        isEmailConfirmed: json['isEmailConfirmed'] as bool,
        lastLogin: json['lastLogin'] as String,
        reportsCount: json['reportsCount'] as int,
        createdAt: json['createdAt'] as String,
      );
}

class AdminUsersPageDto {
  final List<AdminUserDto> users;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  AdminUsersPageDto({
    required this.users,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
  factory AdminUsersPageDto.fromJson(Map<String, dynamic> json) => AdminUsersPageDto(
        users: (json['users'] as List<dynamic>).map((e) => AdminUserDto.fromJson(e as Map<String, dynamic>)).toList(),
        totalCount: json['totalCount'] as int,
        page: json['page'] as int,
        pageSize: json['pageSize'] as int,
        totalPages: json['totalPages'] as int,
      );
}

class UpdateAdminUserRequestDto {
  final String email;
  final String displayName;
  final String? password;
  UpdateAdminUserRequestDto({required this.email, required this.displayName, this.password});
  Map<String, dynamic> toJson() => {'email': email, 'displayName': displayName, 'password': password};
}

