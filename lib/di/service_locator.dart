// =============================================================================
// 🔌 SERVICE LOCATOR - Injeção de Dependências
// =============================================================================
//
// 🎓 EXPLICAÇÃO PARA APRESENTAÇÃO:
// ---------------------------------
// O Service Locator é um padrão que CENTRALIZA a criação de todas as
// dependências do app em um único lugar.
//
// Sem Service Locator (ruim):
//   final service = SharedPreferencesService();
//   final repo = AlunoRepository(service);  // Precisa criar o service antes
//   final useCase = CadastrarAlunoUseCase(repo);  // Precisa do repo antes
//   // Cada tela teria que criar tudo isso...
//
// Com Service Locator (bom):
//   final viewModel = serviceLocator<HomeViewModel>();  // Pronto!
//   // Todas as dependências já foram criadas uma vez e compartilhadas.
//
// Isso implementa o princípio "D" do SOLID (Dependency Inversion):
//   As classes de cima não criam as de baixo. Elas RECEBEM de fora.
//
// A ordem de criação importa (de baixo para cima na arquitetura):
//   1. Service (mais baixo)
//   2. Repository (usa Service)
//   3. Use Cases (usam Repository)
//   4. Facades (agrupam Use Cases)
//   5. ViewModels (usam Facades)
// =============================================================================

import '../data/services/shared_preferences_service.dart';
import '../data/repositories/aluno_repository.dart';
import '../domain/use_cases/aluno_use_cases.dart';
import '../domain/facades/aluno_facade.dart';
import '../presentation/viewmodels/home_viewmodel.dart';
import '../presentation/viewmodels/cadastro_viewmodel.dart';
import '../presentation/viewmodels/ranking_viewmodel.dart';
import '../presentation/viewmodels/tema_viewmodel.dart';

/// Map que guarda as instâncias registradas.
/// A chave é o Type da classe, o valor é a instância.
final Map<Type, dynamic> _instances = {};

/// Registra uma instância no Service Locator.
///
/// Exemplo: `registerInstance<HomeViewModel>(HomeViewModel(facade));`
void registerInstance<T>(T instance) {
  _instances[T] = instance;
}

/// Obtém uma instância do Service Locator.
///
/// Exemplo: `final vm = serviceLocator<HomeViewModel>();`
T serviceLocator<T>() {
  final instance = _instances[T];
  if (instance == null) {
    throw Exception('$T não foi registrado no Service Locator!');
  }
  return instance as T;
}

/// Inicializa todas as dependências do app.
///
/// DEVE ser chamado no main() antes de runApp().
/// A ordem de inicialização segue a arquitetura de camadas:
/// Service → Repository → Use Cases → Facades → ViewModels
Future<void> setupServiceLocator() async {
  // ===========================================================================
  // CAMADA 1: SERVICES
  // ===========================================================================
  final sharedPrefsService = SharedPreferencesService();
  await sharedPrefsService.init(); // Inicializa o SharedPreferences
  registerInstance<SharedPreferencesService>(sharedPrefsService);

  // ===========================================================================
  // CAMADA 2: REPOSITORIES
  // ===========================================================================
  final alunoRepository = AlunoRepository(sharedPrefsService);
  registerInstance<AlunoRepository>(alunoRepository);

  // ===========================================================================
  // CAMADA 3: USE CASES
  // ===========================================================================
  final cadastrarUseCase = CadastrarAlunoUseCase(alunoRepository);
  final alterarUseCase = AlterarAlunoUseCase(alunoRepository);
  final removerUseCase = RemoverAlunoUseCase(alunoRepository);
  final buscarTodosUseCase = BuscarAlunosUseCase(alunoRepository);
  final buscarPorIdUseCase = BuscarAlunoPorIdUseCase(alunoRepository);
  final calcularRankingUseCase = CalcularRankingUseCase(alunoRepository);

  // ===========================================================================
  // CAMADA 4: FACADES
  // ===========================================================================
  final alunoFacade = AlunoFacade(
    cadastrar: cadastrarUseCase,
    alterar: alterarUseCase,
    remover: removerUseCase,
    buscarTodos: buscarTodosUseCase,
    buscarPorId: buscarPorIdUseCase,
    calcularRanking: calcularRankingUseCase,
  );
  registerInstance<AlunoFacade>(alunoFacade);

  // ===========================================================================
  // CAMADA 5: VIEWMODELS
  // ===========================================================================
  registerInstance<TemaViewModel>(TemaViewModel(sharedPrefsService));
  registerInstance<HomeViewModel>(HomeViewModel(alunoFacade));
  registerInstance<CadastroViewModel>(CadastroViewModel(alunoFacade));
  registerInstance<RankingViewModel>(RankingViewModel(alunoFacade));

  // Carrega o tema salvo
  serviceLocator<TemaViewModel>().carregarTema();
}
