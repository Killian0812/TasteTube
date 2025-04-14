import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/feature/search/domain/search_repo.dart';
import 'package:taste_tube/core/injection.dart';

abstract class SearchState {
  final List<User> users;

  SearchState(this.users);
}

class SearchInitial extends SearchState {
  SearchInitial(super.users);
}

class SearchLoading extends SearchState {
  SearchLoading(super.users);
}

class SearchSuccess extends SearchState {
  final String message;

  SearchSuccess(super.users, this.message);
}

class SearchLoaded extends SearchState {
  SearchLoaded(super.users);
}

class SearchError extends SearchState {
  final String message;

  SearchError(super.users, this.message);
}

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository searchRepo;

  SearchCubit()
      : searchRepo = getIt<SearchRepository>(),
        super(SearchInitial([]));

  Future<void> searchForUser(String keyword) async {
    try {
      emit(SearchLoading(state.users));
      final result = await searchRepo.searchForUser(keyword);
      result.fold(
        (error) => emit(
            SearchError(state.users, error.message ?? 'Error fetching users')),
        (users) {
          emit(SearchLoaded(users));
        },
      );
    } catch (e) {
      emit(SearchError(state.users, e.toString()));
    }
  }
}
