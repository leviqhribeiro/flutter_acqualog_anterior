import 'package:bloc/bloc.dart';
import 'package:canteiro/blocs/bloc_event.dart';
import 'package:canteiro/helpers/mask_helper.dart';
import 'package:canteiro/models/address.dart';
import 'package:canteiro/resources/via_cep_api_provider.dart';

class CEPTextEditingFormFieldBloc extends Bloc<BlocEvent<CEPTextEditingFormFieldBlocEvent>, CEPTextEditingFormFieldBlocState> {
  CEPTextEditingFormFieldBloc(CEPTextEditingFormFieldBlocState initialState) : super(initialState);

  final viacepApiProvider = const ViewCEPApiProvider();

  @override
  Stream<CEPTextEditingFormFieldBlocState> mapEventToState(BlocEvent<CEPTextEditingFormFieldBlocEvent> event) async* {
    switch(event.event) {
      case CEPTextEditingFormFieldBlocEvent.searchAddress:
        if(event.data is String) {
          final unmaskedCEP = MaskHelper.unmask(event.data);
          if(unmaskedCEP != state.lastSearchedCEP) {
            final newState = CEPTextEditingFormFieldBlocState.fromState(state);
            newState.status = SearchAddressByCepStatus.searching;
            yield newState;
            yield await _searchAddress(unmaskedCEP);
          }
        }

        break;
    }
  }

  Future<CEPTextEditingFormFieldBlocState> _searchAddress(String cep) async {
    final newState = CEPTextEditingFormFieldBlocState.fromState(state);
    try {
      final response = await viacepApiProvider.findAddressByCep(cep: cep);
      if(response.success) {
        newState.lastSearchedCEP = cep;
        newState.address = response.body;
      }
    }
    catch(e) {}
    newState.status = SearchAddressByCepStatus.searchFinished;
    return newState;
  }

}

enum CEPTextEditingFormFieldBlocEvent {
  searchAddress
}

class CEPTextEditingFormFieldBlocState {
  CEPTextEditingFormFieldBlocState();
  CEPTextEditingFormFieldBlocState.fromState(CEPTextEditingFormFieldBlocState state) {
    lastSearchedCEP = state.lastSearchedCEP;
    address = state.address;
    status = state.status;
  }
  String lastSearchedCEP;
  Address address;
  SearchAddressByCepStatus status = SearchAddressByCepStatus.none;
}

enum SearchAddressByCepStatus {
  none,
  searching,
  searchFinished,
}