import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/feature/inbox/data/channel_settings.dart';
import 'package:taste_tube/feature/inbox/domain/chat_channel_repo.dart';

abstract class ChatChannelState {
  final ChannelSettings settings;

  const ChatChannelState(this.settings);
}

class ChatChannelLoading extends ChatChannelState {
  ChatChannelLoading() : super(ChannelSettings(autoResponse: true));
}

class ChatChannelLoaded extends ChatChannelState {
  const ChatChannelLoaded(super.settings);
}

class ChatChannelError extends ChatChannelState {
  final String message;

  const ChatChannelError(super.settings, this.message);
}

class ChatChannelCubit extends Cubit<ChatChannelState> {
  final String channelId;
  ChatChannelCubit(this.channelId) : super(ChatChannelLoading());
  final ChatChannelRepository repository = getIt<ChatChannelRepository>();

  Future<void> getSettings() async {
    try {
      final result = await repository.getSettings(channelId);
      result.fold(
        (error) => emit(ChatChannelError(
          state.settings,
          error.message ?? 'Error fetching channel settings',
        )),
        (settings) {
          emit(ChatChannelLoaded(settings));
        },
      );
    } catch (e) {
      emit(ChatChannelError(state.settings, e.toString()));
    }
  }

  Future<void> updateSettings({
    required bool autoResponse,
  }) async {
    try {
      final result = await repository.updateSettings(
        channelId,
        autoResponse: autoResponse,
      );
      result.fold(
        (error) => emit(ChatChannelError(
          state.settings,
          error.message ?? 'Error updating channel settings',
        )),
        (settings) {
          emit(ChatChannelLoaded(settings));
        },
      );
    } catch (e) {
      emit(ChatChannelError(state.settings, e.toString()));
    }
  }
}
