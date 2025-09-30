import '../../../../core/network/retrofit/ain_api.dart';

abstract class ProfileRepository {
  Future<MeResponseDto> me();
}

