/// Lista de cursos disponíveis no IFPR - Campus Paranaguá.
const List<String> kCursosDisponiveis = [
  'INFO',
  'MEC',
  'MAMB',
  'PROD',
  'TADS',
  'TGA',
];

/// Range de anos para o campo Turma/Ano.
const int kTurmaAnoInicio = 1998;
const int kTurmaAnoFim = 2026;

/// Gera a lista de anos disponíveis para seleção (1998 a 2026).
List<int> get kTurmaAnosDisponiveis => List.generate(
  kTurmaAnoFim - kTurmaAnoInicio + 1,
  (i) => kTurmaAnoInicio + i,
);

/// Os 15 critérios de popularidade com nome e descrição.
/// A soma das 15 notas (1 a 5 cada) forma o "Nível Lenda" (15 a 75 pontos).
const List<Map<String, String>> kCriterios = [
  {
    'id': 'resenha',
    'nome': 'Resenha',
    'descricao':
        'Mede o quanto o aluno anima a turma, puxa conversa e contribui para deixar o ambiente mais descontraído.',
  },
  {
    'id': 'presenca_vip',
    'nome': 'Presença VIP',
    'descricao':
        'Avalia o quanto o aluno é lembrado, percebido ou reconhecido pelos colegas no dia a dia da turma.',
  },
  {
    'id': 'aura',
    'nome': 'Aura',
    'descricao':
        'Representa a energia geral do aluno: presença, estilo, jeito de ser e impacto que causa no ambiente.',
  },
  {
    'id': 'modo_parceiro',
    'nome': 'Modo Parceiro',
    'descricao':
        'Mede o quanto o aluno ajuda os colegas, colabora nas atividades e demonstra espírito de parceria.',
  },
  {
    'id': 'carisma_natural',
    'nome': 'Carisma Natural',
    'descricao':
        'Avalia a facilidade do aluno para socializar, conversar e criar boas relações com os colegas.',
  },
  {
    'id': 'humor_milhoes',
    'nome': 'Humor de Milhões',
    'descricao':
        'Representa o quanto o aluno contribui com bom humor, brincadeiras saudáveis e momentos divertidos.',
  },
  {
    'id': 'energia_grupo',
    'nome': 'Energia de Grupo',
    'descricao':
        'Mede a participação do aluno em trabalhos, eventos, jogos, dinâmicas e atividades coletivas da turma.',
  },
  {
    'id': 'criatividade_caotica',
    'nome': 'Criatividade Caótica',
    'descricao':
        'Avalia a capacidade do aluno de ter ideias diferentes, soluções inesperadas e comentários geniais.',
  },
  {
    'id': 'modo_atleta',
    'nome': 'Modo Atleta',
    'descricao':
        'Representa a aptidão esportiva, a disposição física e o espírito competitivo saudável do aluno.',
  },
  {
    'id': 'talento_palco',
    'nome': 'Talento de Palco',
    'descricao':
        'Mede a aptidão artística do aluno, como música, canto, instrumentos, dança, ritmo ou presença em apresentações.',
  },
  {
    'id': 'drip_escolar',
    'nome': 'Drip Escolar',
    'descricao':
        'Avalia o estilo pessoal do aluno, considerando roupas, tênis, cabelo, acessórios e presença visual.',
  },
  {
    'id': 'coracao_dorama',
    'nome': 'Coração de Dorama',
    'descricao':
        'Representa o carisma afetivo, a gentileza e aquela vibe de protagonista romântico, sem expor relacionamentos reais.',
  },
  {
    'id': 'queridinho_professores',
    'nome': 'Queridinho dos Professores',
    'descricao':
        'Mede a boa relação do aluno com os professores, considerando respeito, participação, educação e responsabilidade.',
  },
  {
    'id': 'cerebro_turbo',
    'nome': 'Cérebro Turbo',
    'descricao':
        'Avalia o desempenho nos estudos, a facilidade para aprender, resolver problemas e se destacar academicamente.',
  },
  {
    'id': 'caos_controlado',
    'nome': 'Caos Controlado',
    'descricao':
        'Mede o quanto o aluno é bagunceiro, zoeiro ou imprevisível, mas ainda dentro dos limites do respeito e da convivência saudável.',
  },
];

/// Nota mínima por critério.
const int kNotaMinima = 1;

/// Nota máxima por critério.
const int kNotaMaxima = 5;

/// Pontuação mínima possível (15 critérios × 1 estrela).
const int kPontuacaoMinima = 15;

/// Pontuação máxima possível (15 critérios × 5 estrelas).
const int kPontuacaoMaxima = 75;

/// Chave usada na tabela `config` para salvar a preferência de tema.
const String kChaveTemaEscuro = 'tema_escuro';
