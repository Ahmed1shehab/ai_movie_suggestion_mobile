import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/constants.dart';
import 'package:ai_movie_suggestion/data/data_souce/local_data_source.dart';
import 'package:ai_movie_suggestion/data/data_souce/remote_data_source.dart';
import 'package:ai_movie_suggestion/data/data_souce/user_profile_local_data_source.dart';
import 'package:ai_movie_suggestion/data/network/app_api.dart';
import 'package:ai_movie_suggestion/data/network/dio_factory.dart';
import 'package:ai_movie_suggestion/data/network/movieServiceClient.dart';
import 'package:ai_movie_suggestion/data/network/network_info.dart';
import 'package:ai_movie_suggestion/data/repository/repository_impl.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/add_like_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/get_user_data_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/login_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_now_playing_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_popular_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_top_rated_movies_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_upcoming_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/movie_details_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/search_movies_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/similar_movies_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/register_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/send_notification_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/send_prompt_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/verify_email_usecase.dart';
import 'package:ai_movie_suggestion/presentation/auth/login/viewmodel/login_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/auth/register/viewmodel/register_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/auth/verify_email/viewmodel/verify_email_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/new_releases/viewmodel/new_releases_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/now_playing/viewmodel/now_playing_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/trending/viewmodel/trending_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/home/viewmodel/home_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/movie_detail/viewmodel/movie_detail_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/view/pages/watchlist/viewmodel/watchlist_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/viewmodel/profile_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/suggest_me/viewmodel/suggest_me_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/send_notifcations/viewmodel/send_notifications_viewmodel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final instance = GetIt.instance;
Future<void> initAppModule() async {
  // Shared Preferences
  if (!instance.isRegistered<SharedPreferences>()) {
    final sharedPrefs = await SharedPreferences.getInstance();
    instance.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  }

  // App preferences
  if (!instance.isRegistered<AppPreferences>()) {
    instance.registerLazySingleton<AppPreferences>(() => AppPreferences(instance()));
  }

  // Network info - Connectivity
  if (!instance.isRegistered<Connectivity>()) {
    instance.registerFactory<Connectivity>(() => Connectivity());
  }

  // Network info - NetworkInfo
  if (!instance.isRegistered<NetworkInfo>()) {
    instance.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(instance<Connectivity>()),
    );
  }

  // Dio factory
  if (!instance.isRegistered<DioFactory>()) {
    instance.registerLazySingleton<DioFactory>(() => DioFactory(instance()));
  }

  // Dio instance + AppServiceClient
  if (!instance.isRegistered<AppServiceClient>()) {
    Dio dio = await instance<DioFactory>().getDio();
    instance.registerLazySingleton<AppServiceClient>(
      () => AppServiceClient(dio, baseUrl: Constants.baseUrl),
    );
  }

  // Movie API Dio instance + MovieServiceClient
  if (!instance.isRegistered<MovieServiceClient>()) {
    Dio movieDio = await instance<DioFactory>().getMovieDio();
    instance.registerLazySingleton<MovieServiceClient>(
      () => MovieServiceClient(movieDio, baseUrl: Constants.movieBaseUrl),
    );
  }

  // Remote data source
  if (!instance.isRegistered<RemoteDataSource>()) {
    instance.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(instance(), instance(), Constants.apiKey),
    );
  }

  // Local data source
  if (!instance.isRegistered<LocalDataSource>()) {
    instance.registerLazySingleton<LocalDataSource>(
      () => LocalDataSourceImpl(),
    );
  }

  // Local User data source
  if (!instance.isRegistered<UserProfileLocalDataSource>()) {
    instance.registerLazySingleton<UserProfileLocalDataSource>(
      () => UserProfileLocalDataSourceImpl(),
    );
  }

  // Repository
  if (!instance.isRegistered<Repository>()) {
    instance.registerLazySingleton<Repository>(
      () => RepositoryImpl(instance(), instance(), instance(), instance(), instance()),
    );
  }
}

initLoginModule() {
  if (!GetIt.I.isRegistered<LoginUsecase>()) {
    instance.registerFactory<LoginUsecase>(() => LoginUsecase(instance()));
    instance.registerFactory<LoginViewmodel>(
        () => LoginViewmodel(instance(), instance()));
  }
}

initRegisterModule() {
  if (!GetIt.I.isRegistered<RegisterUsecase>()) {
    instance
        .registerFactory<RegisterUsecase>(() => RegisterUsecase(instance()));
    instance.registerFactory<RegisterViewmodel>(
        () => RegisterViewmodel(instance(), instance()));
  }
}

initVerifyEmailModule() {
  if (!GetIt.I.isRegistered<VerifyEmailUsecase>()) {
    instance.registerFactory<VerifyEmailUsecase>(
        () => VerifyEmailUsecase(instance()));
    instance.registerFactory<VerifyEmailViewmodel>(
        () => VerifyEmailViewmodel(instance(), instance()));
  }
}

initTopRatedModule() {
  if (!GetIt.I.isRegistered<SearchMoviesUsecase>()) {
    instance.registerLazySingleton<SearchMoviesUsecase>(
      () => SearchMoviesUsecase(instance()),
    );
  }
  if (!GetIt.I.isRegistered<GetTopRatedMoviesUseCase>()) {
    instance.registerFactory<GetTopRatedMoviesUseCase>(
        () => GetTopRatedMoviesUseCase(instance()));
    instance.registerFactory<TopRatedViewModel>(
        () => TopRatedViewModel(instance(), instance()));
  }
}

initPopularModule() {
  if (!GetIt.I.isRegistered<GetPopularUsecase>()) {
    instance.registerFactory<GetPopularUsecase>(
        () => GetPopularUsecase(instance()));
    instance.registerFactory<TrendingViewmodel>(
        () => TrendingViewmodel(instance()));
  }
}

initNowPlayingModule() {
  if (!GetIt.I.isRegistered<GetNowPlayingMoviesUseCase>()) {
    instance.registerFactory<GetNowPlayingMoviesUseCase>(
        () => GetNowPlayingMoviesUseCase(instance()));
    instance.registerFactory<NowPlayingViewmodel>(
        () => NowPlayingViewmodel(instance()));
  }
}

initNewReleaseModule() {
  if (!GetIt.I.isRegistered<GetUpcomingUsecase>()) {
    instance.registerFactory<GetUpcomingUsecase>(
        () => GetUpcomingUsecase(instance()));
    instance.registerFactory<NewReleasesViewmodel>(
        () => NewReleasesViewmodel(instance()));
  }
}

void initMovieDetailsModule() {
  if (!GetIt.I.isRegistered<MovieDetailsUseCase>()) {
    instance.registerLazySingleton<MovieDetailsUseCase>(
        () => MovieDetailsUseCase(instance()));
    instance.registerLazySingleton<SimilarMoviesUsecase>(
        () => SimilarMoviesUsecase(instance()));

    // Register AddLikeUsecase
    instance.registerLazySingleton<AddLikeUsecase>(
        () => AddLikeUsecase(instance()));

    // Update MovieDetailsViewModel factory to include AddLikeUsecase
    instance.registerFactory<MovieDetailsViewModel>(() => MovieDetailsViewModel(
          instance(),
          instance(),
          instance(),
          instance(),
        ));
  }
}

initSendNotificationModule() {
  if (!GetIt.I.isRegistered<SendNotificationUsecase>()) {
    instance.registerFactory<SendNotificationUsecase>(
        () => SendNotificationUsecase(instance()));
    instance.registerFactory<SendNotificationViewModel>(
        () => SendNotificationViewModel(instance()));
  }
}


initSuggestMeModule() {
  if (!GetIt.I.isRegistered<SendPromptUsecase>()) {
    instance.registerFactory<SendPromptUsecase>(
        () => SendPromptUsecase(instance()));
    instance.registerFactory<SuggestMeViewmodel>(
        () => SuggestMeViewmodel(instance(),instance()));
  }
}


initProfileModule() {
  if (!GetIt.I.isRegistered<GetUserDataUsecase>()) {
    instance.registerFactory<GetUserDataUsecase>(
        () => GetUserDataUsecase(instance()));
    instance.registerFactory<ProfileViewModel>(
        () => ProfileViewModel(instance(),));
  }
}
void initWatchlistModule() {
  if (!GetIt.instance.isRegistered<WatchlistViewModel>()) {
    GetIt.instance.registerFactory<WatchlistViewModel>(
      () => WatchlistViewModel(
        GetIt.instance<AppPreferences>(),
        GetIt.instance<MovieDetailsUseCase>(),
      ),
    );
  }
}