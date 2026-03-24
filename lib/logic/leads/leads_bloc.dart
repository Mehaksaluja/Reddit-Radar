import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/lead_model.dart';
import '../../data/services/reddit_service.dart';

// Events
abstract class LeadsEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class FetchLeads extends LeadsEvent {}

// States
abstract class LeadsState extends Equatable {
  @override
  List<Object> get props => [];
}
class LeadsInitial extends LeadsState {}
class LeadsLoading extends LeadsState {}
class LeadsLoaded extends LeadsState {
  final List<LeadModel> leads; // Using LeadModel instead of Map
  LeadsLoaded(this.leads);
}
class LeadsError extends LeadsState {
  final String message;
  LeadsError(this.message);
}

// BLoC Logic
class LeadsBloc extends Bloc<LeadsEvent, LeadsState> {
  final RedditService redditService;

  LeadsBloc(this.redditService) : super(LeadsInitial()) {
    on<FetchLeads>((event, emit) async {
      emit(LeadsLoading());
      try {
        final leads = await redditService.fetchHotLeads();
        emit(LeadsLoaded(leads));
      } catch (e) {
        emit(LeadsError("Failed to fetch leads: $e"));
      }
    });
  }
}