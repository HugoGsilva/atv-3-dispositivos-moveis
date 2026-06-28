import '../data/services/shared_preferences_service.dart';
import '../data/repositories/aluno_repository.dart';
import '../domain/use_cases/aluno_use_cases.dart';
import '../domain/facades/aluno_facade.dart';
import '../presentation/viewmodels/home_viewmodel.dart';
import '../presentation/viewmodels/cadastro_viewmodel.dart';
import '../presentation/viewmodels/ranking_viewmodel.dart';
import '../presentation/viewmodels/detalhe_viewmodel.dart';
import '../presentation/viewmodels/tema_viewmodel.dart';

/// Map que guarda as instâncias registradas (Type → instância).
final Map<Type, dynamic> _instances = {};

/// Registra uma instância no Service Locator.
void registerInstance<T>(T instance) {
  _instances[T] = instance;
}

/// Obtém uma instância do Service Locator.
T serviceLocator<T>() {
  final instance = _instances[T];
  if (instance == null) {
    throw Exception('$T não foi registrado no Service Locator!');
  }
  return instance as T;
}

/// Inicializa todas as dependências do app. Deve ser chamado no main()
/// antes de runApp(): Service → Repository → Use Cases → Facades → ViewModels.
Future<void> setupServiceLocator() async {
  // Services
  final sharedPrefsService = SharedPreferencesService();
  await sharedPrefsService.init();
  registerInstance<SharedPreferencesService>(sharedPrefsService);

  // Repositories
  final alunoRepository = AlunoRepository(sharedPrefsService);
  registerInstance<AlunoRepository>(alunoRepository);

  // Use Cases
  final cadastrarUseCase = CadastrarAlunoUseCase(alunoRepository);
  final alterarUseCase = AlterarAlunoUseCase(alunoRepository);
  final removerUseCase = RemoverAlunoUseCase(alunoRepository);
  final buscarTodosUseCase = BuscarAlunosUseCase(alunoRepository);
  final buscarPorIdUseCase = BuscarAlunoPorIdUseCase(alunoRepository);
  final calcularRankingUseCase = CalcularRankingUseCase(alunoRepository);

  // Facades
  final alunoFacade = AlunoFacade(
    cadastrar: cadastrarUseCase,
    alterar: alterarUseCase,
    remover: removerUseCase,
    buscarTodos: buscarTodosUseCase,
    buscarPorId: buscarPorIdUseCase,
    calcularRanking: calcularRankingUseCase,
  );
  registerInstance<AlunoFacade>(alunoFacade);

  // ViewModels
  registerInstance<TemaViewModel>(TemaViewModel(sharedPrefsService));
  registerInstance<HomeViewModel>(HomeViewModel(alunoFacade));
  registerInstance<CadastroViewModel>(CadastroViewModel(alunoFacade));
  registerInstance<RankingViewModel>(RankingViewModel(alunoFacade));
  registerInstance<DetalheViewModel>(DetalheViewModel(alunoFacade));

  // Carrega o tema salvo
  serviceLocator<TemaViewModel>().carregarTema();
}
