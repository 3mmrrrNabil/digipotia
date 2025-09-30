import 'package:injectable/injectable.dart';

import '../../../../core/network/retrofit/ain_api.dart';

abstract class ProfileRemoteDataSource {
  Future<MeResponseDto> me();
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final AinApi _api;
  ProfileRemoteDataSourceImpl(this._api);

  @override
  Future<MeResponseDto> me() => _api.me();
}

