// =============================================================================
// 🧪 TESTES - CadastroViewModel (integração ViewModel → Facade → Repository)
// =============================================================================
//
// Exercita o caminho real de salvar um aluno a partir da ViewModel:
//   salvarCommand → facade.cadastrar → UseCase → Repository → SharedPreferences.
// Valida também a NORMALIZAÇÃO das notas (sempre 15 critérios, valores 1..5)
// e o modo edição (carregarParaEdicao + alterar).
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piramid_game/core/constants.dart';
import 'package:piramid_game/core/result.dart';
import 'package:piramid_game/data/repositories/aluno_repository.dart';
import 'package:piramid_game/data/services/shared_preferences_service.dart';
import 'package:piramid_game/domain/facades/aluno_facade.dart';
import 'package:piramid_game/domain/models/aluno.dart';
import 'package:piramid_game/domain/use_cases/aluno_use_cases.dart';
import 'package:piramid_game/presentation/viewmodels/cadastro_viewmodel.dart';

AlunoFacade _montarFacade(AlunoRepository repo) => AlunoFacade(
      cadastrar: CadastrarAlunoUseCase(repo),
      alterar: AlterarAlunoUseCase(repo),
      remover: RemoverAlunoUseCase(repo),
      buscarTodos: BuscarAlunosUseCase(repo),
      buscarPorId: BuscarAlunoPorIdUseCase(repo),
      calcularRanking: CalcularRankingUseCase(repo),
    );

void main() {
  late AlunoRepository repo;
  late CadastroViewModel vm;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final service = SharedPreferencesService();
    await service.init();
    repo = AlunoRepository(service);
    vm = CadastroViewModel(_montarFacade(repo));
  });

  List<Aluno> alunosSalvos() =>
      (repo.buscarTodos() as Success<List<Aluno>>).value;

  test('cadastra via salvarCommand e persiste 15 notas válidas (1..5)', () async {
    vm.nome.value = 'Coquinha';
    vm.curso.value = 'TADS';
    vm.turmaAno.value = 2026;
    vm.atualizarNota('aura', 5);
    vm.atualizarNota('resenha', 4);

    await vm.salvarCommand.execute();

    final alunos = alunosSalvos();
    expect(alunos.length, 1);
    final salvo = alunos.first;
    expect(salvo.nome, 'Coquinha');
    expect(salvo.curso, 'TADS');
    // Normalização: sempre os 15 critérios
    expect(salvo.notas.length, kCriterios.length);
    expect(salvo.notas['aura'], 5);
    expect(salvo.notas['resenha'], 4);
    // Todos dentro do intervalo permitido
    expect(salvo.notas.values.every((n) => n >= kNotaMinima && n <= kNotaMaxima),
        isTrue);
  });

  test('nome vazio não persiste e expõe erro no command', () async {
    vm.nome.value = '   ';
    await vm.salvarCommand.execute();

    expect(vm.salvarCommand.result.value, isA<Failure>());
    expect(vm.salvarCommand.error.value, isNotNull);
    expect(alunosSalvos(), isEmpty);
  });

  test('modo edição: carregarParaEdicao + salvar altera o mesmo aluno (mesmo id)',
      () async {
    // cadastra um aluno inicial
    await repo.cadastrar(Aluno(
      id: 'aluno-1',
      nome: 'Antigo',
      curso: 'INFO',
      turmaAno: 2020,
      dataNascimento: DateTime(2003, 1, 1),
    ));

    // entra em edição e altera
    vm.carregarParaEdicao(alunosSalvos().first);
    expect(vm.isEdicao.value, isTrue);
    vm.nome.value = 'Atualizado';
    vm.curso.value = 'MEC';

    await vm.salvarCommand.execute();

    final alunos = alunosSalvos();
    expect(alunos.length, 1); // não duplicou
    expect(alunos.first.id, 'aluno-1'); // mesmo id
    expect(alunos.first.nome, 'Atualizado');
    expect(alunos.first.curso, 'MEC');
  });
}
