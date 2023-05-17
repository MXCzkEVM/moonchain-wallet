import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef DisposablePresenterProvider<Presenter extends StateNotifier<State>,
        State>
    = AutoDisposeStateNotifierProvider<Presenter, State>;

typedef DisposablePresenterFamilyProvider<
        Presenter extends StateNotifier<State>, State, Param>
    = AutoDisposeStateNotifierProviderFamily<Presenter, State, Param>;

typedef PresenterProvider<Presenter extends StateNotifier<State>, State>
    = StateNotifierProvider<Presenter, State>;
