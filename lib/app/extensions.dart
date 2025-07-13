import 'package:ai_movie_suggestion/app/constants.dart';
import 'package:ai_movie_suggestion/data/mapper/mapper.dart';
import 'package:ai_movie_suggestion/data/response/movie_list_response.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_render_impl.dart';

extension NonNullString on String? {
  String orEmpty() {
    if (this == null) {
      return Constants.empty;
    } else {
      return this!;
    }
  }
}

extension NonNullInt on int? {
  int orZero() {
    if (this == null) {
      return Constants.zero;
    } else {
      return this!;
    }
  }
}

extension FlowStateExtension on FlowState {}

// Extension for convenience
extension MovieDetailResponseX on MovieDetailResponse {
  MovieDetail toDomain() => MovieMapper.fromResponse(this);
}


// extension MovieListExtensions on List<MovieEntity> {
//   List<MovieEntity> sortByRating() {
//     return [...this]..sort((a, b) => b.rating.compareTo(a.rating));
//   }

//   List<MovieEntity> sortByReleaseDate() {
//     return [...this]..sort((a, b) {
//       if (a.releaseDate == null && b.releaseDate == null) return 0;
//       if (a.releaseDate == null) return 1;
//       if (b.releaseDate == null) return -1;
//       return b.releaseDate!.compareTo(a.releaseDate!);
//     });
//   }

//   List<MovieEntity> sortByPopularity() {
//     return [...this]..sort((a, b) => b.popularity.compareTo(a.popularity));
//   }

//   List<MovieEntity> filterByGenre(int genreId) {
//     return where((movie) => movie.genreIds.contains(genreId)).toList();
//   }

//   List<MovieEntity> filterByRating(double minRating) {
//     return where((movie) => movie.rating >= minRating && movie.hasValidRating).toList();
//   }

//   List<MovieEntity> filterByYear(int year) {
//     return where((movie) => movie.releaseDate?.year == year).toList();
//   }

//   List<MovieEntity> searchByTitle(String query) {
//     final lowerQuery = query.toLowerCase();
//     return where((movie) =>
//         movie.title.toLowerCase().contains(lowerQuery) ||
//         movie.originalTitle.toLowerCase().contains(lowerQuery)).toList();
//   }
// }

// extension MovieEntityExtensions on MovieEntity {
//   bool isRecentlyReleased() {
//     if (releaseDate == null) return false;
//     final now = DateTime.now();
//     final difference = now.difference(releaseDate!);
//     return difference.inDays <= 30; // Released within 30 days
//   }

//   bool isUpcoming() {
//     if (releaseDate == null) return false;
//     return releaseDate!.isAfter(DateTime.now());
//   }

//   bool isHighRated() {
//     return rating >= 7.0 && hasValidRating;
//   }

//   String get shortOverview {
//     if (overview.length <= 100) return overview;
//     return '${overview.substring(0, 100)}...';
//   }
// }