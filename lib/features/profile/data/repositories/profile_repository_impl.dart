import 'package:injectable/injectable.dart';

import '../../../../core/network/retrofit/ain_api.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  ProfileRepositoryImpl(this._remote);

  @override
  Future<MeResponseDto> me() => _remote.me();
}

