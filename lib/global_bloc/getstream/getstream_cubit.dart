import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';

class GetstreamCubit extends Cubit<GetstreamState> {
  GetstreamCubit() : super(GetstreamInitial());

  StreamChatClient? get client =>
      state is GetstreamSuccess ? (state as GetstreamSuccess).client : null;

  Future<void> initializeClient(AuthData userData, String streamToken) async {
    emit(GetstreamLoading());

    try {
      final client = StreamChatClient(
        'uwbbeybqn98y',
        logLevel: Level.OFF,
      );

      await client.connectUser(
        User(
          id: userData.userId,
          name: userData.username,
          image: userData.image,
        ),
        streamToken,
      );

      emit(GetstreamSuccess(client));
    } catch (e) {
      emit(GetstreamFailure('Failed to initialize Stream client: $e'));
    }
  }
}

abstract class GetstreamEvent {}

class InitializeStreamClient extends GetstreamEvent {
  final String userId;
  final String streamToken;

  InitializeStreamClient(this.userId, this.streamToken);
}

abstract class GetstreamState {}

class GetstreamInitial extends GetstreamState {}

class GetstreamLoading extends GetstreamState {}

class GetstreamSuccess extends GetstreamState {
  final StreamChatClient client;

  GetstreamSuccess(this.client);
}

class GetstreamFailure extends GetstreamState {
  final String error;

  GetstreamFailure(this.error);
}
