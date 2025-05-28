import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/global_data/watch/video.dart';

abstract class SearchState {
  final List<User> users;
  final List<Video> videos;

  SearchState(this.users, this.videos);
}

class SearchInitial extends SearchState {
  SearchInitial(super.users, super.videos);
}

class SearchLoading extends SearchState {
  SearchLoading(super.users, super.videos);
}

class SearchLoaded extends SearchState {
  SearchLoaded(super.users, super.videos);
}

class SearchError extends SearchState {
  final String message;

  SearchError(super.users, super.videos, this.message);
}

class SearchCubit extends Cubit<SearchState> {
  final ContentRepository repository;

  SearchCubit()
      : repository = getIt<ContentRepository>(),
        super(SearchInitial([], []));

  Future<void> searchForUser(String keyword, {bool showLoading = true}) async {
    try {
      if (showLoading) {
        emit(SearchLoading(state.users, state.videos));
      }
      final result = await repository.searchForUser(keyword);
      result.fold(
        (error) => emit(SearchError(state.users, state.videos,
            error.message ?? 'Error fetching users')),
        (users) {
          emit(SearchLoaded(users, state.videos));
        },
      );
      searchForVideo(keyword, showLoading: false);
    } catch (e) {
      emit(SearchError(state.users, state.videos, e.toString()));
    }
  }

  Future<void> searchForVideo(String keyword, {bool showLoading = true}) async {
    try {
      if (showLoading) {
        emit(SearchLoading(state.users, state.videos));
      }
      final result = await repository.searchForVideo(keyword);
      result.fold(
        (error) => emit(SearchError(state.users, state.videos,
            error.message ?? 'Error fetching videos')),
        (videos) {
          emit(SearchLoaded(state.users, videos));
        },
      );
      searchForUser(keyword, showLoading: false);
    } catch (e) {
      emit(SearchError(state.users, state.videos, e.toString()));
    }
  }
}
