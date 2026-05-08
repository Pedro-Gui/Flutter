// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskController)
final taskControllerProvider = TaskControllerProvider._();

final class TaskControllerProvider
    extends $NotifierProvider<TaskController, TaskState> {
  TaskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskControllerHash();

  @$internal
  @override
  TaskController create() => TaskController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskState>(value),
    );
  }
}

String _$taskControllerHash() => r'62a78ee215aa187fd70fba89b788daf5772ad08c';

abstract class _$TaskController extends $Notifier<TaskState> {
  TaskState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TaskState, TaskState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskState, TaskState>,
              TaskState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(tasksStream)
final tasksStreamProvider = TasksStreamProvider._();

final class TasksStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  TasksStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return tasksStream(ref);
  }
}

String _$tasksStreamHash() => r'00072848b0a5377f865945f0a8da49e4abce9709';
