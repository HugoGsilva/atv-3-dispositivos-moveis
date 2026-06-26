# 📚 Documentação Técnica — PiramidGame IFPR-Pguá

> **Material de estudo para apresentação.** Este documento descreve o app camada
> por camada, com **localização exata** de cada arquivo/função, o que entra e o
> que sai, e com quem cada peça conversa. Foi escrito para você conseguir
> responder perguntas do tipo *"onde a tela X dispara a ação Y?"*, *"qual camada
> valida Z e onde fica?"*, *"como a UI conversa com o back-end (dados)?"*.

> ⚠️ **Sobre a terminologia.** O enunciado da atividade fala em "controllers",
> "middlewares", "rotas", "webview ↔ backend". Esses são termos do mundo **web**.
> Este projeto é um app **Flutter** com **Arquitetura Limpa + MVVM**, então não
> existem literalmente "controllers" nem "middlewares". A seção
> [Mapa de terminologia](#-mapa-de-terminologia-web--flutter) traduz cada termo
> para o equivalente real deste projeto — use-a para responder com segurança.

---

## Índice

1. [Resumo do objetivo do projeto](#1-resumo-do-objetivo-do-projeto)
2. [Análise: objetivo × código atual](#2-análise-objetivo--código-atual)
3. [Mapa de terminologia (web → Flutter)](#-mapa-de-terminologia-web--flutter)
4. [Visão geral da arquitetura](#3-visão-geral-da-arquitetura)
5. [Documentação por camada](#4-documentação-por-camada)
   - [4.1 Core (Result, Command, Constants)](#41-core-blocos-transversais)
   - [4.2 Camada de Dados — Service](#42-camada-de-dados--service)
   - [4.3 Camada de Dados — Repository](#43-camada-de-dados--repository)
   - [4.4 Domínio — Model](#44-domínio--model-aluno)
   - [4.5 Domínio — Use Cases](#45-domínio--use-cases)
   - [4.6 Domínio — Facade](#46-domínio--facade)
   - [4.7 Apresentação — ViewModels](#47-apresentação--viewmodels)
   - [4.8 Apresentação — Pages (telas)](#48-apresentação--pages-telas)
   - [4.9 Apresentação — Widgets](#49-apresentação--widgets-reutilizáveis)
   - [4.10 Injeção de dependências](#410-injeção-de-dependências-service-locator)
   - [4.11 Bootstrap e rotas](#411-bootstrap-main--rotas-app)
6. [Mapa de fluxo de uma ação ponta-a-ponta](#5-mapa-de-fluxo-de-uma-ação-ponta-a-ponta)
7. [Decisões de design visual (tema verde)](#6-decisões-de-design-visual-tema-verde)
8. [Testes](#7-testes)
9. [Correções e mudanças aplicadas](#8-correções-e-mudanças-aplicadas)

---

## 1. Resumo do objetivo do projeto

*(Resumido com minhas palavras a partir do PDF `Ranking de Popularidade dos Alunos.pdf`.)*

O **PiramidGame IFPR-Pguá** é um app **Flutter**, de fins didáticos, que monta um
**ranking de popularidade** dos alunos do **IFPR – Campus Paranaguá**. A ideia
(envolta numa história bem-humorada da turma) é cadastrar alunos e avaliá-los em
**15 critérios descontraídos** (Resenha, Aura, Carisma Natural, Drip Escolar,
Caos Controlado etc.), cada um com uma nota de **1 a 5 estrelas** (*Star Rating*).

- A soma das 15 notas forma o **Nível Lenda**, que vai de **15** (todos os
  critérios com 1 estrela) a **75** (todos com 5).
- O app gera um **ranking** ordenado do maior para o menor Nível Lenda, com
  destaque de pódio para os 3 primeiros.
- Cada aluno tem: **nome** (digitado, obrigatório), **apelido** (digitado),
  **curso** (seleção: INFO, MEC, MAMB, PROD, TADS, TGA), **turma/ano** (seleção
  1998–2026) e **data de nascimento** (DatePicker).
- Os dados ficam **salvos localmente** no aparelho via **SharedPreferences**
  (lista de alunos → JSON → SharedPreferences, e o caminho inverso ao abrir).

**Requisitos técnicos obrigatórios** (todos exigidos pelo PDF): Flutter,
SharedPreferences, **go_router** (navegação), **Flutter Signals** (estado
reativo), arquivo próprio de **tema** com alternância **claro/escuro** em tempo
de execução, padrão **MVVM**, padrão **Command** (ações de tela), padrão
**Result** (retornos entre camadas), **SOLID** e **Arquitetura Limpa** na
organização em camadas:

```
services → repositories → use cases → facade de use cases → viewmodel → UI
```

**Funcionalidades obrigatórias:** cadastrar, listar, visualizar detalhes,
alterar, remover (com confirmação) alunos; exibir ranking; alternar tema.
**Telas obrigatórias:** Splash e Sobre o App (as demais são livres).

---

## 2. Análise: objetivo × código atual

Comparei o PDF com o código em `lib/`. Resumo:

### ✅ O que já está cumprido (e onde)

| Requisito | Atende? | Onde no código |
|---|---|---|
| Flutter | ✅ | projeto inteiro / `pubspec.yaml` |
| SharedPreferences (persistência local) | ✅ | `lib/data/services/shared_preferences_service.dart` |
| go_router (navegação) | ✅ | `lib/app.dart` (`_router`) |
| Flutter Signals (reatividade) | ✅ | todos os ViewModels + `signal()` no `Command` |
| Arquivo próprio de tema | ✅ | `lib/presentation/theme/app_theme.dart` |
| Tema claro/escuro em runtime | ✅ | `TemaViewModel` + `Watch` no `app.dart` |
| Padrão MVVM | ✅ | `presentation/viewmodels/*` + `pages/*` |
| Padrão Command | ✅ | `lib/core/command.dart` (`Command0`/`Command1`) |
| Padrão Result | ✅ | `lib/core/result.dart` (`Success`/`Failure`) |
| Camadas (Clean Architecture) | ✅ | `core/`, `data/`, `domain/`, `presentation/`, `di/` |
| Cadastro: nome, curso, turma/ano, apelido, nascimento | ✅ | `cadastro_page.dart` + `cadastro_viewmodel.dart` |
| Cursos pré-definidos (INFO…TGA) | ✅ | `lib/core/constants.dart` → `kCursosDisponiveis` |
| Turma/ano 1998–2026 (seleção) | ✅ | `constants.dart` → `kTurmaAnosDisponiveis` |
| Data de nascimento por DatePicker | ✅ | `cadastro_page.dart` → `_selecionarData` |
| 15 critérios + Star Rating 1–5 | ✅ | `constants.dart` → `kCriterios` + `star_rating.dart` |
| Nível Lenda (15–75) | ✅ | `Aluno.nivelLenda` em `domain/models/aluno.dart` |
| Ranking ordenado + pódio | ✅ | `CalcularRankingUseCase` + `ranking_page.dart` |
| CRUD completo | ✅ | use cases + repository + pages |
| Remoção com confirmação | ✅ | `home_page.dart` e `detalhe_aluno_page.dart` (AlertDialog) |
| Tela Splash | ✅ | `lib/presentation/pages/splash_page.dart` |
| Tela Sobre o App | ✅ | `lib/presentation/pages/sobre_app_page.dart` |

**Conclusão:** o app já nascia **funcionalmente completo** e bem arquitetado.

### ⚠️ O que faltava / estava incorreto (e foi corrigido nesta entrega)

1. **🐞 BUG REAL na persistência (corrigido).** Em
   `data/repositories/aluno_repository.dart`, o método `buscarTodos()` retornava
   `const Success([])` quando ainda **não havia nenhum aluno salvo**. Uma lista
   `const` é **imutável**. Como `cadastrar`/`alterar`/`remover` fazem
   `.add()`/`.removeWhere()` sobre essa lista, o app **quebrava ao cadastrar o
   PRIMEIRO aluno** com o erro `Cannot add to an unmodifiable list`. Ou seja: num
   celular recém-instalado, o cadastro nunca funcionaria. **Esse bug foi
   descoberto pelos testes** e corrigido (ver [seção 8](#8-correções-e-mudanças-aplicadas)).

2. **🎨 Interface visual genérica e fora da identidade pedida.** O tema original
   era **roxo/violeta**. O pedido é um app **minimalista, moderno e em tons de
   verde**. Toda a paleta foi reescrita (ver [seção 6](#6-decisões-de-design-visual-tema-verde)).

3. **🧪 Testes inexistentes.** Havia só um `widget_test.dart` vazio (sem
   asserções). Foi criada uma **suíte de 29 testes** cobrindo model, Result,
   Command, repository, use cases e um smoke test de widget (ver [seção 7](#7-testes)).

---

## 🔁 Mapa de terminologia (web → Flutter)

Use esta tabela para traduzir as perguntas "estilo web" para o que existe de fato
no projeto:

| Termo do enunciado (web) | Equivalente neste app Flutter | Arquivo |
|---|---|---|
| **Controller** (controla a tela, recebe a ação do usuário) | **ViewModel** (MVVM) | `presentation/viewmodels/*.dart` |
| **Middleware de validação** (valida antes de processar) | **Use Case** (regra de negócio) — ex.: nome obrigatório | `domain/use_cases/aluno_use_cases.dart` |
| **Rotas / Router** | **GoRouter** | `lib/app.dart` |
| **Serviço / camada de acesso a dados (DAO)** | **Service** (SharedPreferences) | `data/services/shared_preferences_service.dart` |
| **Repositório / Model de dados** | **Repository** + **Model** | `data/repositories/aluno_repository.dart`, `domain/models/aluno.dart` |
| **Comunicação webview ↔ backend** | **UI ↔ ViewModel** via **Signals** (estado) e **Commands** (ações) | `pages/*` ↔ `viewmodels/*` |
| **Response padronizada (200/erro)** | **Result** (`Success`/`Failure`) | `lib/core/result.dart` |
| **Injeção de dependência / container** | **Service Locator** | `lib/di/service_locator.dart` |

> Exemplo de resposta pronta: *"A validação do nome obrigatório fica na camada de
> regras de negócio, em `domain/use_cases/aluno_use_cases.dart`, na classe
> `CadastrarAlunoUseCase.call()` — é o equivalente a um middleware de validação."*

---

## 3. Visão geral da arquitetura

O app segue **Arquitetura Limpa** com fluxo de dependências em camadas. Cada
camada só conhece a camada imediatamente abaixo (regra de dependência):

```
┌──────────────────────────────────────────────────────────────┐
│  UI (Pages + Widgets)   →  só conversa com a ViewModel         │  presentation/pages, presentation/widgets
├──────────────────────────────────────────────────────────────┤
│  ViewModel              →  estado (Signals) + ações (Commands) │  presentation/viewmodels
├──────────────────────────────────────────────────────────────┤
│  Facade de Use Cases    →  agrupa os use cases                 │  domain/facades
├──────────────────────────────────────────────────────────────┤
│  Use Cases              →  regras de negócio (1 por ação)      │  domain/use_cases
├──────────────────────────────────────────────────────────────┤
│  Repository             →  converte JSON ⇄ Aluno               │  data/repositories
├──────────────────────────────────────────────────────────────┤
│  Service                →  acesso cru ao SharedPreferences     │  data/services
└──────────────────────────────────────────────────────────────┘
        ▲ Transversais: core/ (Result, Command, Constants)  |  di/ (Service Locator)
```

**Regra de ouro (do PDF):** a **UI nunca** acessa Service/Repository/
SharedPreferences direto — ela fala **só com a ViewModel**. O **Result** é o
"envelope" que viaja de baixo para cima carregando sucesso ou erro.

### Estrutura de pastas (`lib/`)

```
lib/
├── main.dart                         # Ponto de entrada (bootstrap)
├── app.dart                          # MaterialApp.router + GoRouter (rotas)
├── core/                             # Blocos transversais (sem dependências de camada)
│   ├── result.dart                   #   Padrão Result (Success/Failure)
│   ├── command.dart                  #   Padrão Command (Command0/Command1)
│   └── constants.dart                #   Cursos, anos, 15 critérios, chaves, limites
├── data/                             # CAMADA DE DADOS
│   ├── services/
│   │   └── shared_preferences_service.dart   # Acesso cru ao SharedPreferences
│   └── repositories/
│       └── aluno_repository.dart     # JSON ⇄ Aluno + CRUD persistido
├── domain/                           # CAMADA DE DOMÍNIO
│   ├── models/
│   │   └── aluno.dart                # Model Aluno (+ nivelLenda, toJson/fromJson)
│   ├── use_cases/
│   │   └── aluno_use_cases.dart      # 6 use cases (regras de negócio)
│   └── facades/
│       └── aluno_facade.dart         # Fachada que agrupa os use cases
├── presentation/                     # CAMADA DE APRESENTAÇÃO (UI)
│   ├── theme/
│   │   ├── app_theme.dart            # Tema (paleta verde, Material 3) claro/escuro
│   │   └── criterio_icons.dart       # Ícone de cada um dos 15 critérios
│   ├── viewmodels/
│   │   ├── tema_viewmodel.dart       # Estado do tema claro/escuro
│   │   ├── home_viewmodel.dart       # Estado da lista de alunos
│   │   ├── cadastro_viewmodel.dart   # Estado do formulário cadastro/edição
│   │   └── ranking_viewmodel.dart    # Estado do ranking
│   ├── widgets/
│   │   ├── star_rating.dart          # Componente de 5 estrelas
│   │   ├── aluno_avatar.dart         # Avatar reutilizável (inicial + gradiente)
│   │   └── aluno_card.dart           # Card de aluno na lista
│   └── pages/
│       ├── splash_page.dart          # Tela de abertura (obrigatória)
│       ├── home_page.dart            # Lista de alunos (tela principal)
│       ├── cadastro_page.dart        # Formulário cadastro/edição
│       ├── detalhe_aluno_page.dart   # Detalhes + editar/remover
│       ├── ranking_page.dart         # Ranking com pódio
│       └── sobre_app_page.dart       # Sobre o App (obrigatória)
└── di/
    └── service_locator.dart          # Injeção de dependências (monta tudo)
```

---

## 4. Documentação por camada

> Para cada arquivo: **caminho**, **o que faz**, **o que expõe** (funções/campos),
> **entra/sai** e **com quem conversa**.

### 4.1 Core (blocos transversais)

#### `lib/core/result.dart` — Padrão Result
- **O que faz:** define o "envelope" de retorno usado entre TODAS as camadas.
- **Expõe:**
  - `sealed class Result<T>` — só pode ser `Success` ou `Failure` (garante que
    todo retorno é tratado).
  - `class Success<T> { final T value; }` — operação deu certo, carrega o dado.
  - `class Failure<T> { final String message; }` — deu errado, carrega o motivo.
- **Entra/Sai:** é um tipo de dado; não tem lógica. Consumido via `switch`
  (pattern matching) ou `is Success<...>`.
- **Conversa com:** todo mundo (repository, use cases, facade, viewmodels, command).

#### `lib/core/command.dart` — Padrão Command
- **O que faz:** encapsula uma **ação de tela** como objeto, com estado reativo.
- **Expõe:**
  - `class Command0<R>` — comando **sem** parâmetro. Construtor recebe
    `Future<Result<R>> Function()`.
  - `class Command1<R, A>` — comando **com 1** parâmetro `A`.
  - Campos reativos (Signals) em ambos: `running` (bool, está executando),
    `result` (`Result<R>?`, último resultado), `error` (`String?`, mensagem).
  - Método `execute()` (Command0) / `execute(A arg)` (Command1).
- **Entra:** a função-ação (definida no ViewModel). **Sai:** atualiza
  `running`/`result`/`error`, que a UI observa via `Watch`.
- **Lógica importante (`execute`, `command.dart:74` e `:125`):**
  1. se `running == true`, **retorna sem fazer nada** (proteção contra duplo
     clique); 2. liga `running`; 3. roda a ação; 4. guarda `result`; 5. se for
  `Failure`, copia a mensagem para `error`; 6. `catch` transforma exceção
  inesperada em `Failure`; 7. `finally` desliga `running`.
- **Conversa com:** ViewModels (que o criam) e UI (que o dispara e observa).

#### `lib/core/constants.dart` — Constantes do domínio
- **O que faz:** centraliza valores fixos (evita "strings mágicas").
- **Expõe:**
  - `kCursosDisponiveis` (`List<String>`) — INFO, MEC, MAMB, PROD, TADS, TGA.
  - `kTurmaAnoInicio = 1998`, `kTurmaAnoFim = 2026`, e o getter
    `kTurmaAnosDisponiveis` (gera a lista de anos).
  - `kCriterios` (`List<Map<String,String>>`) — os **15 critérios** com
    `id`, `nome`, `descricao`.
  - `kNotaMinima = 1`, `kNotaMaxima = 5`, `kPontuacaoMinima = 15`,
    `kPontuacaoMaxima = 75`.
  - `kChaveAlunos = 'alunos_json'`, `kChaveTemaEscuro = 'tema_escuro'` — chaves
    do SharedPreferences.
- **Conversa com:** model, viewmodels, pages, repository (chave de storage).

### 4.2 Camada de Dados — Service

#### `lib/data/services/shared_preferences_service.dart`
- **O que faz:** camada **mais baixa**. Fala direto com o `SharedPreferences`
  (armazenamento local chave→valor). **Só conhece String/bool** — não conhece
  `Aluno`. (Princípio **S** do SOLID: responsabilidade única.)
- **Expõe:**
  - `Future<void> init()` — obtém a instância do SharedPreferences. **Deve ser
    chamado uma vez** no boot (feito no `service_locator.dart`).
  - `Future<bool> saveString(String key, String value)`
  - `String? getString(String key)` (null se a chave não existir)
  - `Future<bool> saveBool(String key, bool value)`
  - `bool? getBool(String key)`
  - `Future<bool> remove(String key)`
- **Entra:** chave + valor primitivo. **Sai:** primitivo ou null.
- **Conversa com:** `AlunoRepository` (alunos) e `TemaViewModel` (tema).

### 4.3 Camada de Dados — Repository

#### `lib/data/repositories/aluno_repository.dart`
- **O que faz:** **intermediário** entre o JSON cru e o objeto `Aluno`. Converte
  `String JSON ⇄ List<Aluno>` e implementa o CRUD persistido. Usa `Result`.
- **Recebe por injeção:** `SharedPreferencesService _service` (Dependency
  Inversion — princípio **D** do SOLID).
- **Expõe:**
  - `Result<List<Aluno>> buscarTodos()` — lê a String da chave `kChaveAlunos`,
    faz `jsonDecode` e mapeia cada item com `Aluno.fromJson`. **Sem dados →
    `Success(<Aluno>[])` (lista vazia MODIFICÁVEL).**
  - `Result<Aluno> buscarPorId(String id)` — usa `buscarTodos` + `firstWhere`;
    não achou → `Failure('Aluno não encontrado')`.
  - `Future<Result<void>> cadastrar(Aluno aluno)` — busca todos, `.add`, salva.
  - `Future<Result<void>> alterar(Aluno aluno)` — busca, `indexWhere` pelo `id`;
    não achou → `Failure(...)`; senão substitui e salva.
  - `Future<Result<void>> remover(String id)` — busca, `removeWhere` pelo `id`, salva.
  - *(privado)* `Future<Result<void>> _salvarTodos(List<Aluno> alunos)` —
    `toJson` em cada um → `jsonEncode` → `saveString`.
- **Entra:** objetos `Aluno` / `id`. **Sai:** `Result<...>`.
- **Conversa com:** `SharedPreferencesService` (abaixo) e os Use Cases (acima).
- **Fluxo de persistência:**
  `List<Aluno> → toJson() → jsonEncode → String → SharedPreferences` e o inverso
  na leitura.

### 4.4 Domínio — Model (`Aluno`)

#### `lib/domain/models/aluno.dart`
- **O que faz:** representa o **dado** Aluno (a "ficha cadastral"). É imutável
  (campos `final`); mudanças geram **cópia** via `copyWith`.
- **Campos:** `id` (UUID v4, gerado se não informado), `nome`, `curso`,
  `turmaAno` (int), `apelido` (default `''`), `dataNascimento` (DateTime),
  `notas` (`Map<String,int>`: id do critério → nota 1–5; default = todos em 1).
- **Expõe:**
  - `int get nivelLenda` — **soma das 15 notas** (`notas.values.fold(...)`). É a
    regra do "Nível Lenda" (15–75). **Local exato:** `aluno.dart:89`.
  - `Map<String,dynamic> toJson()` — serializa (DateTime vira ISO-8601 string).
  - `factory Aluno.fromJson(Map<String,dynamic>)` — desserializa.
  - `Aluno copyWith({...})` — cópia com campos alterados (o `id` nunca muda).
  - `toString()`.
- **Conversa com:** Repository (serialização) e camadas acima (uso do objeto).

### 4.5 Domínio — Use Cases

#### `lib/domain/use_cases/aluno_use_cases.dart`
- **O que faz:** cada classe é **uma ação** do sistema (1 responsabilidade). É
  aqui que moram as **regras de negócio / validações** (equivalente a
  "middleware de validação"). Todas usam o padrão `call()` (dá para chamar a
  instância como função).
- **Recebem por injeção:** `AlunoRepository _repository`.
- **Classes expostas:**
  - `CadastrarAlunoUseCase` — **valida: nome não pode ser vazio** (`aluno.nome.trim().isEmpty → Failure('O nome do aluno é obrigatório')`), senão `repository.cadastrar`. **Local:** `aluno_use_cases.dart:47`.
  - `AlterarAlunoUseCase` — mesma validação de nome + `repository.alterar`.
  - `RemoverAlunoUseCase` — valida `id` não vazio + `repository.remover`.
  - `BuscarAlunosUseCase` — repassa `repository.buscarTodos`.
  - `BuscarAlunoPorIdUseCase` — repassa `repository.buscarPorId`.
  - `CalcularRankingUseCase` — **regra do ranking:** busca todos e **ordena por
    `nivelLenda` decrescente** (`..sort((a,b) => b.nivelLenda.compareTo(a.nivelLenda))`). **Local:** `aluno_use_cases.dart:117`.
- **Entra:** `Aluno` ou `id`. **Sai:** `Result<...>`.
- **Conversa com:** Repository (abaixo) e Facade (acima).

### 4.6 Domínio — Facade

#### `lib/domain/facades/aluno_facade.dart`
- **O que faz:** **fachada** que agrupa os 6 use cases num único ponto, para a
  ViewModel não precisar conhecer cada use case separado.
- **Recebe por injeção (construtor nomeado):** os 6 use cases.
- **Expõe métodos finos que repassam:** `cadastrar(aluno)`, `alterar(aluno)`,
  `remover(id)`, `buscarTodos()`, `buscarPorId(id)`, `calcularRanking()`.
- **Conversa com:** Use Cases (abaixo) e ViewModels (acima). É o **único** ponto
  do domínio que as ViewModels enxergam.

### 4.7 Apresentação — ViewModels

> ViewModels = o "cérebro" de cada tela (equivalente a **controller**). Mantêm
> **estado** com Signals e disparam **ações** com Commands. Não conhecem widgets.

#### `lib/presentation/viewmodels/tema_viewmodel.dart`
- **O que faz:** controla o tema claro/escuro (estado **global**).
- **Recebe:** `SharedPreferencesService`.
- **Expõe:** `final isDarkMode = signal<bool>(false)`; `void carregarTema()` (lê
  a chave `kChaveTemaEscuro`); `Future<void> alternarTema()` (inverte e **salva**).
- **Conversa com:** Service (persistência do tema) e `app.dart` + `home_page.dart`
  (que observam `isDarkMode`).

#### `lib/presentation/viewmodels/home_viewmodel.dart`
- **O que faz:** estado da **lista de alunos** da Home.
- **Recebe:** `AlunoFacade`.
- **Expõe:** `final alunos = signal<List<Aluno>>([])`;
  `Command0<List<Aluno>> carregarCommand` (carrega via `facade.buscarTodos`);
  `Command1<void,String> removerCommand` (remove pelo id e **recarrega** a lista).
- **Conversa com:** Facade (abaixo) e `home_page.dart` (acima).

#### `lib/presentation/viewmodels/cadastro_viewmodel.dart`
- **O que faz:** estado do **formulário** de cadastro **e** edição.
- **Recebe:** `AlunoFacade`.
- **Expõe (Signals de cada campo):** `isEdicao`, `alunoId`, `nome`, `curso`,
  `turmaAno`, `apelido`, `dataNascimento`, `notas`.
  - `Command0<void> salvarCommand` — decide entre `facade.alterar` (se
    `isEdicao`) ou `facade.cadastrar`.
  - `void carregarParaEdicao(Aluno)` — preenche os signals para editar.
  - `void atualizarNota(String criterioId, int nota)` — troca a nota criando um
    **novo Map** (Signals só detecta mudança de referência). **Local:** `cadastro_viewmodel.dart:93`.
  - `int get nivelLendaAtual` — soma das notas em tempo real (mostrado no topo).
  - `void limpar()` — zera o formulário (modo cadastro novo).
- **Conversa com:** Facade (abaixo) e `cadastro_page.dart` (acima).

#### `lib/presentation/viewmodels/ranking_viewmodel.dart`
- **O que faz:** estado do **ranking**.
- **Recebe:** `AlunoFacade`.
- **Expõe:** `final ranking = signal<List<Aluno>>([])`;
  `Command0<List<Aluno>> calcularCommand` (chama `facade.calcularRanking`).
- **Conversa com:** Facade e `ranking_page.dart`.

### 4.8 Apresentação — Pages (telas)

> As pages **observam** os Signals das ViewModels com `Watch((context){...})` e
> **disparam** Commands. Navegação sempre via `go_router` (`context.go/push/pop`).

#### `lib/presentation/pages/splash_page.dart` *(obrigatória)*
- **O que faz:** abertura animada (fade + scale). Mostra nome, subtítulo e
  "IFPR – Campus Paranaguá". Após **3 segundos** navega para `/home`
  (`Future.delayed` no `initState`, `splash_page.dart:59`).
- **Conversa com:** nenhuma ViewModel (tela puramente visual) + `go_router`.

#### `lib/presentation/pages/home_page.dart` *(tela principal)*
- **O que faz:** lista de alunos. `initState` dispara
  `_viewModel.carregarCommand.execute()`. Mostra loading / estado vazio
  (`_EstadoVazio`) / lista. No topo, um cabeçalho `_Cabecalho` destaca o **líder
  atual** (maior Nível Lenda) e a contagem. Cada item é um `AlunoCard` dentro de
  um `Dismissible` (arrastar p/ remover, com **diálogo de confirmação** em
  `_confirmarRemocao`). A AppBar tem botões de **alternar tema**, **Ranking** e
  **Sobre**. FAB "Novo Aluno" abre `/cadastro`.
- **Usa:** `HomeViewModel`, `TemaViewModel` (via `serviceLocator`).
- **Conversa com:** ViewModels + go_router.

#### `lib/presentation/pages/cadastro_page.dart`
- **O que faz:** formulário. `TextFormField` (nome, apelido), `DropdownButtonFormField`
  (curso, turma/ano), `InputDecorator`+`showDatePicker` (nascimento, em
  `_selecionarData`), e a lista dos 15 critérios com `StarRating`. Mostra o
  **Nível Lenda em tempo real**. Botão salva via `salvarCommand`; em `Success`
  mostra SnackBar e `context.pop()`. Valida o `Form` com `GlobalKey<FormState>`.
- **Modo edição:** se chega com `alunoParaEditar != null`, chama
  `carregarParaEdicao` no `initState`.
- **Usa:** `CadastroViewModel`.

#### `lib/presentation/pages/detalhe_aluno_page.dart`
- **O que faz:** detalhes completos de um aluno (recebe `alunoId` pela rota).
  Carrega via `facade.buscarPorId`. Mostra header, **Nível Lenda em destaque com
  barra de progresso** (`nivelLenda / kPontuacaoMaxima`) e as 15 notas em
  `StarRating` **readOnly**. AppBar com **Editar** (vai p/ `/cadastro` passando o
  aluno via `extra`) e **Remover** (com confirmação em `_confirmarRemocao`).
- **Observação arquitetural:** esta tela fala direto com a **Facade**
  (`serviceLocator<AlunoFacade>()`) por ser uma consulta pontual de leitura —
  não há ViewModel dedicada de detalhe.

#### `lib/presentation/pages/ranking_page.dart`
- **O que faz:** ranking ordenado. `initState` dispara `calcularCommand`. Os **3
  primeiros** aparecem num **pódio** (`_Podio`: 2º à esquerda, 1º ao centro e
  maior, 3º à direita; cores ouro/prata/bronze, coroa no 1º, pedestais de alturas
  diferentes). Do **4º em diante**, lista enxuta (`_LinhaRanking`), cada linha
  navegável para o detalhe. Estado vazio próprio quando não há alunos.
- **Usa:** `RankingViewModel`.

#### `lib/presentation/pages/sobre_app_page.dart` *(obrigatória)*
- **O que faz:** explica objetivo, contexto IFPR, critérios, cálculo do Nível
  Lenda, armazenamento local e temas — em cartões (`_buildSection`). Conteúdo
  baseado no "texto sugerido" do PDF.
- **Conversa com:** nenhuma ViewModel (tela estática).

### 4.9 Apresentação — Widgets reutilizáveis

#### `lib/presentation/widgets/star_rating.dart`
- **O que faz:** componente de **5 estrelas** clicáveis (ou `readOnly`).
- **Expõe (props):** `rating` (1–5), `onChanged` (callback ao tocar), `size`,
  `readOnly`. É `StatelessWidget` — quem guarda o estado é a ViewModel (MVVM).
- **Usado em:** `cadastro_page` (editável) e `detalhe_aluno_page` (readOnly).

#### `lib/presentation/widgets/aluno_card.dart`
- **O que faz:** card resumido do aluno na lista (avatar, nome/apelido,
  curso·turma e **selo do Nível Lenda** colorido por faixa em `_corNivel`).
- **Expõe (props):** `aluno`, `onTap`.
- **Usado em:** `home_page`.

#### `lib/presentation/widgets/aluno_avatar.dart`
- **O que faz:** avatar **reutilizável** (mesmo estilo em todo o app): inicial do
  nome sobre o gradiente da marca (verde). Tamanho e gradiente configuráveis (o
  pódio passa cores ouro/prata/bronze).
- **Expõe (props):** `nome`, `size`, `gradient`.
- **Usado em:** `aluno_card`, `home_page` (líder), `ranking_page` (pódio e lista),
  `detalhe_aluno_page`.

#### `lib/presentation/theme/criterio_icons.dart`
- **O que faz:** função `IconData criterioIcon(String id)` que dá um ícone a cada
  um dos 15 critérios (ex.: `aura → auto_awesome`, `modo_atleta → sports_soccer`).
- **Usado em:** `cadastro_page` e `detalhe_aluno_page` (deixa a lista de
  critérios visual, não só texto).

### 4.10 Injeção de dependências (Service Locator)

#### `lib/di/service_locator.dart`
- **O que faz:** monta TODAS as dependências **uma vez**, na ordem das camadas, e
  as disponibiliza por tipo.
- **Expõe:**
  - `void registerInstance<T>(T instance)` — registra no `Map<Type,dynamic>`.
  - `T serviceLocator<T>()` — recupera (lança se não registrado).
  - `Future<void> setupServiceLocator()` — **chamada no `main()`**; cria na ordem
    **Service → Repository → Use Cases → Facade → ViewModels** e, por fim,
    `carregarTema()`.
- **Conversa com:** praticamente todas as classes (é o "montador"). Implementa o
  **D** do SOLID (as classes recebem dependências em vez de criá-las).

### 4.11 Bootstrap (`main`) + Rotas (`app`)

#### `lib/main.dart`
- **O que faz:** ponto de entrada. (1) `WidgetsFlutterBinding.ensureInitialized()`
  (necessário antes de usar plugins); (2) `await setupServiceLocator()`;
  (3) `runApp(const PiramidGameApp())`.

#### `lib/app.dart`
- **O que faz:** define o `GoRouter` (`_router`) e o widget raiz
  `PiramidGameApp`. Envolve o `MaterialApp.router` num `Watch` que observa
  `TemaViewModel.isDarkMode` para alternar `themeMode` em tempo real.
- **Rotas (path → tela):**

  | path | tela | parâmetro |
  |---|---|---|
  | `/` | `SplashPage` | — |
  | `/home` | `HomePage` | — |
  | `/cadastro` | `CadastroPage` | `extra: Aluno?` (edição) |
  | `/aluno/:id` | `DetalheAlunoPage` | `pathParameters['id']` |
  | `/ranking` | `RankingPage` | — |
  | `/sobre` | `SobreAppPage` | — |

---

## 5. Mapa de fluxo de uma ação ponta-a-ponta

### Exemplo A — **Cadastrar um aluno** (do clique ao disco e de volta)

```
1. Usuário toca no FAB "Novo Aluno"
   → home_page.dart  → context.push('/cadastro')

2. GoRouter (app.dart) abre CadastroPage  (extra == null → modo cadastro)
   → cadastro_page.dart  initState → _viewModel.limpar()

3. Usuário preenche os campos. Cada onChanged grava no Signal:
   → cadastro_viewmodel.dart  (nome.value, curso.value, notas via atualizarNota...)

4. Usuário toca "Cadastrar Aluno"
   → cadastro_page.dart  _salvar() → valida o Form → salvarCommand.execute()

5. Command roda a ação interna _salvar() do ViewModel
   → cadastro_viewmodel.dart  monta o Aluno e chama facade.cadastrar(aluno)

6. Facade repassa ao Use Case
   → aluno_facade.dart  cadastrar() → CadastrarAlunoUseCase.call()

7. Use Case VALIDA (nome não vazio) e chama o Repository
   → aluno_use_cases.dart:47  → aluno_repository.dart  cadastrar()

8. Repository: buscarTodos() → lista.add(aluno) → _salvarTodos()
   → toJson + jsonEncode → service.saveString(kChaveAlunos, json)

9. Service grava no SharedPreferences (disco)
   → shared_preferences_service.dart  saveString()

10. Sobe Result<void> = Success por todas as camadas até o Command
    → command.dart  result.value = Success; running = false

11. UI reage: cadastro_page mostra SnackBar de sucesso e context.pop()
    → volta à Home, que recarrega a lista (carregarCommand.execute())
```

**Quem valida o quê:** o **nome obrigatório** é checado em DOIS pontos — no
`Form` da UI (`validator` do TextFormField) e, de forma autoritativa, no
**Use Case** (`CadastrarAlunoUseCase`, `aluno_use_cases.dart:47`). A regra de
negócio "fonte da verdade" é a do Use Case.

### Exemplo B — **Exibir o ranking**

```
RankingPage.initState → calcularCommand.execute()
  → ranking_viewmodel.dart _calcularRanking()
  → aluno_facade.dart calcularRanking()
  → CalcularRankingUseCase.call()  (ORDENA por nivelLenda desc — aluno_use_cases.dart:117)
  → aluno_repository.dart buscarTodos() → service.getString() → SharedPreferences
  ← Success(List<Aluno> ordenada) sobe até ranking.value
  → ranking_page.dart Watch reconstrói a lista, com pódio para top 3
```

### Exemplo C — **Alternar tema** (estado global reativo)

```
HomePage AppBar (IconButton) → temaViewModel.alternarTema()
  → tema_viewmodel.dart  isDarkMode.value = !isDarkMode.value  + saveBool no Service
  → app.dart  Watch observa isDarkMode → MaterialApp troca themeMode (claro↔escuro)
  (a preferência fica salva e é relida por carregarTema() no próximo boot)
```

---

## 6. Decisões de design visual (tema verde)

> Pedido: app **minimalista, moderno, em tons de verde**. Tudo está centralizado
> em **`lib/presentation/theme/app_theme.dart`** (classes `AppColors` e
> `AppTheme`). Nenhuma cor "solta" nas telas — as telas puxam do tema
> (`theme.colorScheme.primary`, `AppColors.*`).

### Paleta (esmeralda → menta, com acento âmbar)

| Token | Claro | Escuro | Uso |
|---|---|---|---|
| `primary` | `#1B8A5A` (esmeralda) | `#4ADE80` (menta claro) | cor principal, botões, FAB, acentos |
| `secondary` | `#34D399` (menta) | `#6EE7B7` (menta suave) | gradientes, faixa intermediária |
| `background` | `#F2F7F4` (off-white verde) | `#0E1512` (quase-preto verde) | fundo do Scaffold |
| `surface` | `#FFFFFF` | `#18211C` (verde-grafite) | cards, campos |
| `textPrimary` | `#13241B` | `#E6F0EA` | títulos/corpo |
| `textSecondary` | `#5B7268` | `#9DB3A8` | textos auxiliares |
| `starColor` | `#FBBF24` (âmbar) | (mesmo) | estrelas (acento, contraste com verde) |
| `gold/silver/bronze` | `#FFD700`/`#C0C0C0`/`#CD7F32` | (mesmos) | pódio do ranking |

**Por quê verde + âmbar?** O verde carrega a ideia de **crescimento/destaque**
(combina com "subir no ranking" / "Nível Lenda"). Usar **âmbar só nas estrelas e
no pódio** evita poluição visual: a interface fica majoritariamente verde e
neutra, e o dourado vira o ponto de atenção natural (a nota). Isso é o que dá o
ar **minimalista**.

### Como o tema é construído (decisão técnica)
- O `ColorScheme` é gerado por **`ColorScheme.fromSeed`** (Material 3) a partir
  da cor-semente verde `#1B8A5A`. Isso cria automaticamente tons **harmônicos**
  (primary, secondary, containers, `onSurfaceVariant`, `outline`…), em vez de um
  "recolor" manual. Depois **sobrescrevemos só as superfícies** para um neutro
  levemente esverdeado (a identidade verde aparece até no "branco" do fundo).
- O método `AppTheme._build(brightness)` constrói **claro e escuro com o mesmo
  código** (sem duplicação) — princípio DRY.

### Linguagem visual (o que torna o design "intencional", não genérico)
- **Cards flat:** `elevation: 0`, **sem sombra**, com **borda sutil de 1px**
  (`outlineVariant`) e cantos `20`. Visual limpo e moderno (antes eram cards com
  sombra padrão do Material).
- **Inputs preenchidos sem moldura dura:** `filled` com `surfaceContainerHighest`
  e **borda invisível**; só o **foco** mostra a linha verde. Menos "ruído".
- **AppBar flat:** funde com o fundo (`surface`), sem elevação, título forte.
- **Pílulas/chips** com cantos arredondados para informações (curso, turma).
- **Tipografia** com leve *tracking* negativo nos títulos (`headlineLarge` 30/w800,
  `titleLarge` 17/w600) e corpo com altura de linha 1.4–1.45 — leitura confortável.
- **Espaçamento** em grid de 8pt; padding 16–20; raio padrão 16.

### Componentes de tela desenhados (não são widgets "de fábrica")
- **Splash** (`splash_page.dart`): emblema *squircle* translúcido com uma
  **pirâmide de 3 degraus + estrela** (alusão ao nome e ao ranking), nome com
  tracking negativo, *pill* do IFPR e barra de progresso fina. Gradiente verde.
- **Home — cabeçalho "Líder atual"** (`home_page.dart`, `_Cabecalho`): banner em
  gradiente com o aluno de maior Nível Lenda, contagem de alunos e atalho mental
  para o ranking. Estado vazio acolhedor com ícone em círculo.
- **Ranking — pódio** (`ranking_page.dart`, `_Podio`): os **3 primeiros** num
  pódio real (2º à esquerda, **1º ao centro e maior**, 3º à direita), com avatares
  emoldurados na cor da posição, coroa no 1º e pedestais de alturas diferentes;
  do 4º em diante, lista enxuta (`_LinhaRanking`).
- **Cadastro** (`cadastro_page.dart`): campos agrupados em **seções com
  cabeçalho**, **resumo do Nível Lenda em tempo real** com barra de progresso, e
  cada critério num *tile* com **ícone próprio** (`criterio_icons.dart`).
- **Detalhe** (`detalhe_aluno_page.dart`): header com avatar grande, *chips* de
  curso/turma/nascimento, **Nível Lenda em destaque** com barra de progresso e as
  15 notas (readonly) com ícones.
- **Avatar único** (`aluno_avatar.dart`): mesmo estilo de avatar em todas as
  telas (consistência = sinal de design cuidado).

### Componentes temáticos centralizados (em `AppTheme`)
`appBarTheme`, `cardTheme`, `elevatedButtonTheme`/`filledButtonTheme`,
`inputDecorationTheme`, `chipTheme`, `dividerTheme`, `listTileTheme`,
`snackBarTheme`, `dialogTheme`, `floatingActionButtonTheme`, `textTheme` — todos
derivados do `ColorScheme`, para o app inteiro herdar a identidade
automaticamente e a troca claro/escuro ser instantânea.

---

## 7. Testes

Suíte em `test/`. Rodar com: `flutter test`. **Resultado atual: 32 testes,
todos passando** ✅ (e `flutter analyze` sem nenhum issue).

| Arquivo | O que cobre |
|---|---|
| `test/result_test.dart` | `Success`/`Failure` carregam valor/mensagem e o pattern matching (`switch`) separa os dois casos. (3 testes) |
| `test/aluno_model_test.dart` | `nivelLenda` (mín. 15 / máx. 75), notas default (15 critérios em 1), geração de UUID único, **round-trip `toJson`/`fromJson`**, e `copyWith` (preserva `id`, não muta o original). (6 testes) |
| `test/aluno_repository_test.dart` | CRUD persistido sobre SharedPreferences (mock): lista vazia, cadastrar/acumular, `buscarPorId` (achado e `Failure` quando não existe), `alterar` (substitui / `Failure` em id inexistente), `remover`, e **persistência entre instâncias** ("reabrir o app"). (9 testes) |
| `test/use_cases_test.dart` | Regras de negócio: nome vazio → `Failure` **sem persistir** (cadastrar/alterar), id vazio → `Failure` (remover), e **ordenação do ranking** (maior Nível Lenda primeiro) + ranking vazio. (6 testes) |
| `test/command_test.dart` | `Command0`/`Command1`: sucesso preenche `result`/zera `error`/desliga `running`; `Failure` preenche `error`; exceção vira `Failure`; **proteção contra duplo clique**; `Command1` repassa o argumento. (5 testes) |
| `test/cadastro_viewmodel_test.dart` | **Integração ViewModel → Facade → Use Case → Repository**: salvar via `salvarCommand` persiste com **as 15 notas normalizadas (1..5)**; nome vazio não persiste e expõe erro no command; modo edição (`carregarParaEdicao` + salvar) altera o **mesmo id** sem duplicar. (3 testes) |
| `test/widget_test.dart` | **Smoke test de integração**: boota o app real (Service Locator + SharedPreferences mock), confere a Splash e a navegação automática para a Home vazia. (1 teste) |

**Técnica usada:** `SharedPreferences.setMockInitialValues({})` no `setUp` isola o
"disco" a cada teste; os testes de repository/use case rodam sobre o
SharedPreferences **real em modo mock** (teste de integração leve, não usa
dublê manual), o que garante que a serialização JSON também é exercitada.

---

## 8. Correções e mudanças aplicadas

Registro do que foi alterado nesta entrega (todas validadas por `flutter analyze`
+ `flutter test`):

1. **🐞 Bug crítico de persistência — corrigido.**
   `lib/data/repositories/aluno_repository.dart`, `buscarTodos()`: trocado
   `return const Success([])` por `return Success(<Aluno>[])`. A lista `const`
   era **imutável**, então `cadastrar/alterar/remover` (que fazem
   `.add`/`.removeWhere`) quebravam com `Cannot add to an unmodifiable list` ao
   manipular o **primeiro** aluno (storage vazio). **Impacto:** sem a correção, um
   app recém-instalado **nunca conseguiria cadastrar ninguém**. Descoberto pelos
   testes de repository/use case.

2. **🛡️ Robustez de I/O — notas normalizadas ao salvar.**
   `lib/presentation/viewmodels/cadastro_viewmodel.dart` (`_salvar`): antes de
   montar o `Aluno`, as notas passam por normalização que **garante os 15
   critérios** e **fixa cada valor em 1..5** (`clamp`). Impede persistir um Map
   incompleto/fora do intervalo. Coberto por `cadastro_viewmodel_test.dart`.

3. **🎨 Sistema de tema reescrito (Material 3, verde).**
   `lib/presentation/theme/app_theme.dart`: `ColorScheme.fromSeed` com semente
   verde + superfícies neutras esverdeadas; **cards flat com borda sutil**,
   **inputs preenchidos sem moldura**, AppBar flat, chips/diálogos/snackbars
   temados; claro e escuro gerados pelo mesmo `_build(brightness)`.

4. **🎨 Telas redesenhadas (design intencional).**
   - **Splash:** emblema com pirâmide de degraus + estrela, *pill* IFPR, progresso fino.
   - **Home:** cabeçalho "Líder atual" (gradiente) + contagem; estado vazio acolhedor; cards flat.
   - **Ranking:** **pódio real** para o top 3 + lista enxuta do 4º em diante.
   - **Cadastro:** seções com cabeçalho, resumo do Nível Lenda com barra, critérios com **ícone**.
   - **Detalhe:** header com avatar, chips, Nível Lenda em destaque, notas com ícones.

5. **🧩 Novos componentes reutilizáveis.**
   `lib/presentation/widgets/aluno_avatar.dart` (avatar único do app) e
   `lib/presentation/theme/criterio_icons.dart` (ícone por critério). O
   `aluno_card.dart` foi reescrito (selo de Nível Lenda + mini-tags) e enxugou
   props para apenas `aluno`/`onTap`.

6. **🧪 Suíte de testes criada e ampliada.** `result_test.dart`,
   `aluno_model_test.dart`, `aluno_repository_test.dart`, `use_cases_test.dart`,
   `command_test.dart`, `cadastro_viewmodel_test.dart`; e `widget_test.dart`
   (antes vazio) virou um smoke test real. **32 testes, todos passando.**

---

*Documento mantido junto ao código. Caminho exato sempre que possível para
facilitar consulta durante a apresentação. Em caso de dúvida "onde fica X?",
comece pela [seção 4](#4-documentação-por-camada) (por camada) ou pela
[seção 5](#5-mapa-de-fluxo-de-uma-ação-ponta-a-ponta) (fluxo ponta-a-ponta).*
