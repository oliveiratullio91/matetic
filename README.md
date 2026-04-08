# Matetic

Jogo de matematica multiplataforma feito em Flutter para `web`, `Android`, `iOS` e `Windows`.

O projeto foi construido com foco em progressao estilo saga, fases curtas, score, combo, modos de jogo, missoes, eventos, personalizacao e recursos de acessibilidade.

## Estado atual

O `Matetic` ja conta com:

- campanha com `500 fases`
- mapa em trilha estilo saga
- progressao com estrelas, capitulos e medalhas
- gameplay com score, combo, boosters e modificadores
- modos extras de jogo e treino por topico
- perfil, ranking, loja, eventos e missoes
- calendario diario, streak e passe simples
- personalizacao com temas, avatares, molduras, efeitos e mascotes
- acessibilidade com alto contraste, texto maior, movimento reduzido e treino sem cronometro

## Estrutura

O projeto esta organizado assim:

- `lib/app`: bootstrap, tema e rotas
- `lib/core`: dados, estado global e widgets compartilhados
- `lib/features`: telas e fluxos por dominio
- `docx`: documentos de produto e arquitetura
- `test`: testes do app

## Como executar

1. Instale o Flutter.
2. Entre na pasta do projeto.
3. Rode os comandos:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Para gerar a versao web:

```bash
flutter build web
```

## Pipeline

O repositório inclui:

- CI com `flutter analyze`, `flutter test` e `flutter build web`
- workflow de deploy para GitHub Pages

Se o GitHub Pages ainda nao estiver ativo, habilite em:

- `Settings > Pages`
- `Source: GitHub Actions`

## Proximos passos

As proximas frentes mais importantes para o projeto sao:

- backend real com Firebase ou Supabase
- autenticacao real e sincronizacao entre dispositivos
- ranking online de verdade
- desafios assíncronos e multiplayer
- expansao de conteudo matematico e balanceamento fino da campanha

## Projeto

Repositorio: [github.com/oliveiratullio91/matetic](https://github.com/oliveiratullio91/matetic)
