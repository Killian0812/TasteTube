import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart' as log;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/injection.dart';

final streamClient = StreamChatClient(
  'cd5kkff8cewb',
  logLevel: Level.OFF,
);

class GetstreamCubit extends Cubit<GetstreamState> {
  GetstreamCubit() : super(GetstreamInitial());

  final log.Logger logger = getIt<log.Logger>();

  Future<void> initializeClient(AuthData userData, String streamToken) async {
    emit(GetstreamLoading());

    try {
      final user = await streamClient.connectUser(
        User(
          id: userData.userId,
          name: userData.username,
          image: userData.image,
        ),
        streamToken,
      );

      logger.i('Stream User connected: $user');
      emit(GetstreamSuccess());
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
  GetstreamSuccess();
}

class GetstreamFailure extends GetstreamState {
  final String error;

  GetstreamFailure(this.error);
}
