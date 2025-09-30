// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:digipotia/auth/data/api/auth_retrofit.dart' as _i539;
import 'package:digipotia/auth/data/auth_repo_impl/auth_repo_impl.dart'
    as _i779;
import 'package:digipotia/auth/data/data_source/auth_data_source.dart' as _i259;
import 'package:digipotia/auth/data/data_source/auth_data_source_impl.dart'
    as _i1057;
import 'package:digipotia/auth/domain/repo/auth_repo.dart' as _i386;
import 'package:digipotia/auth/domain/use_case/forget_password_use_case.dart'
    as _i134;
import 'package:digipotia/auth/domain/use_case/login_usecase.dart' as _i166;
import 'package:digipotia/auth/domain/use_case/register_usecase.dart' as _i779;
import 'package:digipotia/auth/domain/use_case/reset_password_use_case.dart'
    as _i33;
import 'package:digipotia/auth/domain/use_case/verify_reset_code_use_case.dart'
    as _i1057;
import 'package:digipotia/auth/presentation/view_model/forget_password/forget_password_cubit.dart'
    as _i863;
import 'package:digipotia/auth/presentation/view_model/login/login_cubit.dart'
    as _i909;
import 'package:digipotia/auth/presentation/view_model/register/register_cubit.dart'
    as _i426;
import 'package:digipotia/core/logger/logger_module.dart' as _i919;
import 'package:digipotia/core/network/remote/api_manager.dart' as _i903;
import 'package:digipotia/core/network/remote/dio_module.dart' as _i612;
import 'package:digipotia/core/network/retrofit/ain_api.dart' as _i35;
import 'package:digipotia/features/profile/data/datasources/profile_remote_data_source.dart'
    as _i845;
import 'package:digipotia/features/profile/data/repositories/profile_repository_impl.dart'
    as _i633;
import 'package:digipotia/features/profile/domain/repositories/profile_repository.dart'
    as _i15;
import 'package:digipotia/features/profile/presentation/cubit/profile_cubit.dart'
    as _i1038;
import 'package:digipotia/features/reports/data/datasources/reports_remote_data_source.dart'
    as _i535;
import 'package:digipotia/features/reports/data/repositories/reports_repository_impl.dart'
    as _i643;
import 'package:digipotia/features/reports/domain/repositories/reports_repository.dart'
    as _i31;
import 'package:digipotia/features/reports/presentation/cubit/comments_cubit.dart'
    as _i631;
import 'package:digipotia/features/reports/presentation/cubit/feed_cubit.dart'
    as _i21;
import 'package:digipotia/features/reports/presentation/cubit/report_details_cubit.dart'
    as _i801;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:pretty_dio_logger/pretty_dio_logger.dart' as _i528;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final loggerModule = _$LoggerModule();
    final dioModule = _$DioModule();
    gh.singleton<_i903.ApiManager>(() => _i903.ApiManager());
    gh.lazySingleton<_i974.Logger>(() => loggerModule.loggerProvider);
    gh.lazySingleton<_i974.PrettyPrinter>(() => loggerModule.prettyPrinter);
    gh.lazySingleton<_i528.PrettyDioLogger>(
        () => dioModule.providerInterceptor());
    gh.lazySingleton<_i612.AuthInterceptor>(
        () => dioModule.provideAuthInterceptor());
    gh.lazySingleton<_i361.Dio>(() => dioModule.provideDio(
          gh<_i528.PrettyDioLogger>(),
          gh<_i612.AuthInterceptor>(),
        ));
    gh.lazySingleton<_i539.AuthRetrofitClient>(
        () => _i539.AuthRetrofitClient(gh<_i361.Dio>()));
    gh.lazySingleton<_i35.AinApi>(
        () => dioModule.provideAinApi(gh<_i361.Dio>()));
    gh.factory<_i259.AuthDataSource>(() => _i1057.AuthDataSourceImpl(
          gh<_i539.AuthRetrofitClient>(),
          gh<_i903.ApiManager>(),
          gh<_i539.AuthRetrofitClient>(),
        ));
    gh.lazySingleton<_i845.ProfileRemoteDataSource>(
        () => _i845.ProfileRemoteDataSourceImpl(gh<_i35.AinApi>()));
    gh.lazySingleton<_i15.ProfileRepository>(
        () => _i633.ProfileRepositoryImpl(gh<_i845.ProfileRemoteDataSource>()));
    gh.factory<_i386.AuthRepository>(() => _i779.AuthRepositoryImpl(
          gh<_i903.ApiManager>(),
          gh<_i259.AuthDataSource>(),
        ));
    gh.factory<_i134.ForgotPasswordUseCase>(
        () => _i134.ForgotPasswordUseCase(gh<_i386.AuthRepository>()));
    gh.factory<_i779.RegisterUseCase>(
        () => _i779.RegisterUseCase(gh<_i386.AuthRepository>()));
    gh.factory<_i33.ResetPasswordUseCase>(
        () => _i33.ResetPasswordUseCase(gh<_i386.AuthRepository>()));
    gh.factory<_i1057.VerifyResetCodeUseCase>(
        () => _i1057.VerifyResetCodeUseCase(gh<_i386.AuthRepository>()));
    gh.factory<_i166.LoginUseCase>(
        () => _i166.LoginUseCase(gh<_i386.AuthRepository>()));
    gh.factory<_i535.ReportsRemoteDataSource>(
        () => _i535.ReportsRemoteDataSourceImpl(gh<_i35.AinApi>()));
    gh.factory<_i31.ReportsRepository>(
        () => _i643.ReportsRepositoryImpl(gh<_i535.ReportsRemoteDataSource>()));
    gh.factory<_i863.ForgetPasswordCubit>(() => _i863.ForgetPasswordCubit(
          gh<_i134.ForgotPasswordUseCase>(),
          gh<_i1057.VerifyResetCodeUseCase>(),
          gh<_i33.ResetPasswordUseCase>(),
        ));
    gh.factory<_i631.CommentsCubit>(
        () => _i631.CommentsCubit(gh<_i31.ReportsRepository>()));
    gh.factory<_i21.FeedCubit>(
        () => _i21.FeedCubit(gh<_i31.ReportsRepository>()));
    gh.factory<_i801.ReportDetailsCubit>(
        () => _i801.ReportDetailsCubit(gh<_i31.ReportsRepository>()));
    gh.factory<_i1038.ProfileCubit>(() => _i1038.ProfileCubit(
          gh<_i15.ProfileRepository>(),
          gh<_i31.ReportsRepository>(),
        ));
    gh.factory<_i909.LoginCubit>(
        () => _i909.LoginCubit(gh<_i166.LoginUseCase>()));
    gh.factory<_i426.RegisterCubit>(
        () => _i426.RegisterCubit(gh<_i779.RegisterUseCase>()));
    return this;
  }
}

class _$LoggerModule extends _i919.LoggerModule {}

class _$DioModule extends _i612.DioModule {}
