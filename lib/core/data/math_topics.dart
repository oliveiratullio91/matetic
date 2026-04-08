enum MathTopic {
  addition('Adicao'),
  subtraction('Subtracao'),
  multiplication('Multiplicacao'),
  division('Divisao'),
  mixedOperations('Operacoes mistas'),
  fractions('Fracoes'),
  percentages('Porcentagem'),
  powers('Potencias'),
  equations('Equacoes'),
  sequences('Sequencias');

  const MathTopic(this.label);

  final String label;
}
