import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TabControllerCubit extends Cubit<TabController> {
  final int length;
  late TabController tabController;

  TabControllerCubit({required TickerProvider vsync, required this.length})
      : super(TabController(length: length, vsync: vsync)) {
    tabController = state;
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        emit(tabController);
      }
    });
  }

  void updateTabIndex(int index) {
    tabController.animateTo(index);
    emit(tabController);
  }

  @override
  Future<void> close() {
    tabController.dispose();
    return super.close();
  }
}

class ApplicantAdvertsTabControllerCubit extends TabControllerCubit {
  ApplicantAdvertsTabControllerCubit(
      {required super.vsync, required super.length});
}

class ApplicantBookingsTabControllerCubit extends TabControllerCubit {
  ApplicantBookingsTabControllerCubit(
      {required super.vsync, required super.length});
}

class ApplicantSettingsTabControllerCubit extends TabControllerCubit {
  ApplicantSettingsTabControllerCubit(
      {required super.vsync, required super.length});
}

class AdvertiserAdvertsTabControllerCubit extends TabControllerCubit {
  AdvertiserAdvertsTabControllerCubit(
      {required super.vsync, required super.length});
}

class AdvertiserApplicationsTabControllerCubit extends TabControllerCubit {
  AdvertiserApplicationsTabControllerCubit(
      {required super.vsync, required super.length});
}

class AdvertiserSettingsTabControllerCubit extends TabControllerCubit {
  AdvertiserSettingsTabControllerCubit(
      {required super.vsync, required super.length});
}
