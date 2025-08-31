import 'dart:math';

class MathSolverService {
  Map<String, dynamic> solve(String input) {
    final s = input.replaceAll(' ', '').replaceAll('−', '-').toLowerCase();
    
    // Vérification des différents types de problèmes
    
    // 1. Développement du binôme
    if (_isBinomialExpansion(s)) {
      return _solveBinomialExpansion(s);
    }
    
    // 2. Lois des exposants
    if (_isExponentLaw(s)) {
      return _solveExponentLaw(s);
    }
    
    // 3. Logarithmes
    if (_isLogarithm(s)) {
      return _solveLogarithm(s);
    }
    
    // 4. Dérivées
    if (_isDerivative(s)) {
      return _solveDerivative(s);
    }
    
    // 5. Trigonométrie
    if (_isTrigonometry(s)) {
      return _solveTrigonometry(s);
    }
    
    // 6. Probabilités
    if (_isProbability(s)) {
      return _solveProbability(s);
    }
    
    // 7. Équations (existant)
    if (s.contains('=')) {
      final parts = s.split('=');
      final left = parts[0];
      final right = parts.sublist(1).join('=');
      final eq = '$left-($right)';
      return _solvePolynomial(eq);
    } else {
      return _solvePolynomial(s);
    }
  }

  // =================== DÉVELOPPEMENT DU BINÔME ===================
  bool _isBinomialExpansion(String s) {
    return RegExp(r'\([^)]+\)\^?\d+').hasMatch(s) || 
           s.contains('(a+b)') || s.contains('(x+') || 
           s.contains('binome') || s.contains('binôme');
  }

  Map<String, dynamic> _solveBinomialExpansion(String s) {
    final steps = <String>[];
    
    // Patterns courants
    final patterns = [
      RegExp(r'\(([^+\-]+)\+([^)]+)\)\^(\d+)'),
      RegExp(r'\(([^+\-]+)-([^)]+)\)\^(\d+)'),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(s);
      if (match != null) {
        final a = match.group(1)!;
        final b = match.group(2)!;
        final n = int.parse(match.group(3)!);
        final isNegative = s.contains('-');
        
        steps.add('Développement de ($a ${isNegative ? '-' : '+'} $b)^$n');
        steps.add('Formule: (a+b)^n = Σ C(n,k) × a^(n-k) × b^k');
        
        if (n <= 5) { // Limiter pour éviter des calculs trop longs
          final result = _expandBinomial(a, b, n, isNegative);
          steps.addAll(result['steps']);
          return {
            'type': 'binomial',
            'steps': steps,
            'result': result['expression']
          };
        }
      }
    }
    
    // Cas généraux
    if (s.contains('(a+b)')) {
      final nMatch = RegExp(r'\^(\d+)').firstMatch(s);
      final n = nMatch != null ? int.parse(nMatch.group(1)!) : 2;
      
      steps.add('Développement de (a+b)^$n');
      steps.add('Formule générale: (a+b)^n = Σ C(n,k) × a^(n-k) × b^k');
      
      if (n == 2) {
        steps.add('(a+b)² = a² + 2ab + b²');
        return {'type': 'binomial', 'steps': steps, 'result': 'a² + 2ab + b²'};
      } else if (n == 3) {
        steps.add('(a+b)³ = a³ + 3a²b + 3ab² + b³');
        return {'type': 'binomial', 'steps': steps, 'result': 'a³ + 3a²b + 3ab² + b³'};
      }
    }
    
    return {'type': 'error', 'steps': [], 'result': 'Format non reconnu'};
  }

  Map<String, dynamic> _expandBinomial(String a, String b, int n, bool isNegative) {
    final steps = <String>[];
    final terms = <String>[];
    
    for (int k = 0; k <= n; k++) {
      final coeff = _binomialCoefficient(n, k);
      final aExp = n - k;
      final bExp = k;
      
      String term = '';
      if (coeff > 1) term += coeff.toString();
      if (aExp > 0) {
        if (aExp == 1) term += a;
        else term += '$a^$aExp';
      }
      if (bExp > 0) {
        final bTerm = isNegative && (bExp % 2 == 1) ? '-$b' : b;
        if (bExp == 1) term += bTerm;
        else term += '${bTerm}^$bExp';
      }
      
      terms.add(term);
      steps.add('k=$k: C($n,$k) × $a^$aExp × $b^$bExp = $term');
    }
    
    return {
      'steps': steps,
      'expression': terms.join(' + ').replaceAll('+ -', '- ')
    };
  }

  int _binomialCoefficient(int n, int k) {
    if (k > n - k) k = n - k;
    int result = 1;
    for (int i = 0; i < k; i++) {
      result = result * (n - i) ~/ (i + 1);
    }
    return result;
  }

  // =================== LOIS DES EXPOSANTS ===================
  bool _isExponentLaw(String s) {
    return RegExp(r'\d+\^\d+[\*\/]\d+\^\d+').hasMatch(s) ||
           RegExp(r'[a-z]\^\d+[\*\/][a-z]\^\d+').hasMatch(s) ||
           s.contains('exposant') || s.contains('puissance');
  }

  Map<String, dynamic> _solveExponentLaw(String s) {
    final steps = <String>[];
    
    // Multiplication: a^m × a^n = a^(m+n)
    final multPattern = RegExp(r'([a-z]|\d+)\^(\d+)\*([a-z]|\d+)\^(\d+)');
    final multMatch = multPattern.firstMatch(s);
    if (multMatch != null) {
      final base1 = multMatch.group(1)!;
      final exp1 = int.parse(multMatch.group(2)!);
      final base2 = multMatch.group(3)!;
      final exp2 = int.parse(multMatch.group(4)!);
      
      if (base1 == base2) {
        steps.add('$base1^$exp1 × $base1^$exp2');
        steps.add('Règle: a^m × a^n = a^(m+n)');
        final result = exp1 + exp2;
        steps.add('$base1^($exp1+$exp2) = $base1^$result');
        
        if (RegExp(r'\d+').hasMatch(base1)) {
          final value = pow(int.parse(base1), result);
          steps.add('= $value');
          return {'type': 'exponent', 'steps': steps, 'result': '$value'};
        }
        
        return {'type': 'exponent', 'steps': steps, 'result': '$base1^$result'};
      }
    }
    
    // Division: a^m ÷ a^n = a^(m-n)
    final divPattern = RegExp(r'([a-z]|\d+)\^(\d+)\/([a-z]|\d+)\^(\d+)');
    final divMatch = divPattern.firstMatch(s);
    if (divMatch != null) {
      final base1 = divMatch.group(1)!;
      final exp1 = int.parse(divMatch.group(2)!);
      final base2 = divMatch.group(3)!;
      final exp2 = int.parse(divMatch.group(4)!);
      
      if (base1 == base2) {
        steps.add('$base1^$exp1 ÷ $base1^$exp2');
        steps.add('Règle: a^m ÷ a^n = a^(m-n)');
        final result = exp1 - exp2;
        steps.add('$base1^($exp1-$exp2) = $base1^$result');
        
        if (RegExp(r'\d+').hasMatch(base1)) {
          final value = pow(int.parse(base1), result);
          steps.add('= $value');
          return {'type': 'exponent', 'steps': steps, 'result': '$value'};
        }
        
        return {'type': 'exponent', 'steps': steps, 'result': '$base1^$result'};
      }
    }
    
    // Puissance de puissance: (a^m)^n = a^(m×n)
    final powerPattern = RegExp(r'\(([a-z]|\d+)\^(\d+)\)\^(\d+)');
    final powerMatch = powerPattern.firstMatch(s);
    if (powerMatch != null) {
      final base = powerMatch.group(1)!;
      final exp1 = int.parse(powerMatch.group(2)!);
      final exp2 = int.parse(powerMatch.group(3)!);
      
      steps.add('($base^$exp1)^$exp2');
      steps.add('Règle: (a^m)^n = a^(m×n)');
      final result = exp1 * exp2;
      steps.add('$base^($exp1×$exp2) = $base^$result');
      
      if (RegExp(r'\d+').hasMatch(base)) {
        final value = pow(int.parse(base), result);
        steps.add('= $value');
        return {'type': 'exponent', 'steps': steps, 'result': '$value'};
      }
      
      return {'type': 'exponent', 'steps': steps, 'result': '$base^$result'};
    }
    
    return {'type': 'error', 'steps': [], 'result': 'Format non reconnu'};
  }

  // =================== LOGARITHMES ===================
  bool _isLogarithm(String s) {
    return s.contains('log') || s.contains('ln') || s.contains('logarithme');
  }

  Map<String, dynamic> _solveLogarithm(String s) {
    final steps = <String>[];
    
    // log(xy) = log(x) + log(y)
    final productPattern = RegExp(r'log\((\d+)\*(\d+)\)');
    final productMatch = productPattern.firstMatch(s);
    if (productMatch != null) {
      final x = int.parse(productMatch.group(1)!);
      final y = int.parse(productMatch.group(2)!);
      steps.add('log($x × $y)');
      steps.add('Propriété: log(xy) = log(x) + log(y)');
      steps.add('log($x) + log($y)');
      
      final logX = log(x) / log(10);
      final logY = log(y) / log(10);
      steps.add('≈ ${logX.toStringAsFixed(3)} + ${logY.toStringAsFixed(3)}');
      final result = logX + logY;
      
      return {'type': 'logarithm', 'steps': steps, 'result': result.toStringAsFixed(3)};
    }
    
    // log(x/y) = log(x) - log(y)
    final quotientPattern = RegExp(r'log\((\d+)\/(\d+)\)');
    final quotientMatch = quotientPattern.firstMatch(s);
    if (quotientMatch != null) {
      final x = int.parse(quotientMatch.group(1)!);
      final y = int.parse(quotientMatch.group(2)!);
      steps.add('log($x ÷ $y)');
      steps.add('Propriété: log(x/y) = log(x) - log(y)');
      steps.add('log($x) - log($y)');
      
      final logX = log(x) / log(10);
      final logY = log(y) / log(10);
      steps.add('≈ ${logX.toStringAsFixed(3)} - ${logY.toStringAsFixed(3)}');
      final result = logX - logY;
      
      return {'type': 'logarithm', 'steps': steps, 'result': result.toStringAsFixed(3)};
    }
    
    // log(x^n) = n × log(x)
    final powerPattern = RegExp(r'log\((\d+)\^(\d+)\)');
    final powerMatch = powerPattern.firstMatch(s);
    if (powerMatch != null) {
      final base = int.parse(powerMatch.group(1)!);
      final exp = int.parse(powerMatch.group(2)!);
      steps.add('log($base^$exp)');
      steps.add('Propriété: log(x^n) = n × log(x)');
      steps.add('$exp × log($base)');
      
      final logBase = log(base) / log(10);
      steps.add('$exp × ${logBase.toStringAsFixed(3)}');
      final result = exp * logBase;
      
      return {'type': 'logarithm', 'steps': steps, 'result': result.toStringAsFixed(3)};
    }
    
    // Logarithme simple
    final simplePattern = RegExp(r'log\((\d+)\)');
    final simpleMatch = simplePattern.firstMatch(s);
    if (simpleMatch != null) {
      final x = int.parse(simpleMatch.group(1)!);
      steps.add('log($x)');
      final result = log(x) / log(10);
      steps.add('≈ ${result.toStringAsFixed(3)}');
      
      return {'type': 'logarithm', 'steps': steps, 'result': result.toStringAsFixed(3)};
    }
    
    // Logarithme naturel
    final lnPattern = RegExp(r'ln\((\d+)\)');
    final lnMatch = lnPattern.firstMatch(s);
    if (lnMatch != null) {
      final x = int.parse(lnMatch.group(1)!);
      steps.add('ln($x)');
      final result = log(x);
      steps.add('≈ ${result.toStringAsFixed(3)}');
      
      return {'type': 'logarithm', 'steps': steps, 'result': result.toStringAsFixed(3)};
    }
    
    return {'type': 'error', 'steps': [], 'result': 'Format non reconnu'};
  }

  // =================== DÉRIVÉES ===================
  bool _isDerivative(String s) {
    return s.contains('d/dx') || s.contains("d'") || s.contains('dérivée') || 
           s.contains('derivative') || s.contains('prime');
  }

  Map<String, dynamic> _solveDerivative(String s) {
    final steps = <String>[];
    
    // Constante: d/dx(c) = 0
    final constPattern = RegExp(r'd\/dx\((\d+)\)');
    final constMatch = constPattern.firstMatch(s);
    if (constMatch != null) {
      final c = constMatch.group(1)!;
      steps.add("d/dx($c)");
      steps.add("Règle: d/dx(c) = 0");
      return {'type': 'derivative', 'steps': steps, 'result': '0'};
    }
    
    // Puissance: d/dx(x^n) = n×x^(n-1)
    final powerPattern = RegExp(r'd\/dx\(x\^(\d+)\)');
    final powerMatch = powerPattern.firstMatch(s);
    if (powerMatch != null) {
      final n = int.parse(powerMatch.group(1)!);
      steps.add("d/dx(x^$n)");
      steps.add("Règle: d/dx(x^n) = n×x^(n-1)");
      
      if (n == 1) {
        return {'type': 'derivative', 'steps': steps, 'result': '1'};
      } else if (n == 2) {
        steps.add("2×x^1 = 2x");
        return {'type': 'derivative', 'steps': steps, 'result': '2x'};
      } else {
        final newExp = n - 1;
        steps.add("$n×x^$newExp");
        return {'type': 'derivative', 'steps': steps, 'result': '${n}x^$newExp'};
      }
    }
    
    // Trigonométrie
    final sinPattern = RegExp(r'd\/dx\(sin\(x\)\)');
    if (sinPattern.hasMatch(s)) {
      steps.add("d/dx(sin(x))");
      steps.add("Règle: d/dx(sin(x)) = cos(x)");
      return {'type': 'derivative', 'steps': steps, 'result': 'cos(x)'};
    }
    
    final cosPattern = RegExp(r'd\/dx\(cos\(x\)\)');
    if (cosPattern.hasMatch(s)) {
      steps.add("d/dx(cos(x))");
      steps.add("Règle: d/dx(cos(x)) = -sin(x)");
      return {'type': 'derivative', 'steps': steps, 'result': '-sin(x)'};
    }
    
    // Logarithme
    final lnPattern = RegExp(r'd\/dx\(ln\(x\)\)');
    if (lnPattern.hasMatch(s)) {
      steps.add("d/dx(ln(x))");
      steps.add("Règle: d/dx(ln(x)) = 1/x");
      return {'type': 'derivative', 'steps': steps, 'result': '1/x'};
    }
    
    return {'type': 'error', 'steps': [], 'result': 'Format non reconnu'};
  }

  // =================== TRIGONOMÉTRIE ===================
  bool _isTrigonometry(String s) {
    return s.contains('sin') || s.contains('cos') || s.contains('tan') ||
           s.contains('trigono') || s.contains('degré') || s.contains('radian');
  }

  Map<String, dynamic> _solveTrigonometry(String s) {
    final steps = <String>[];
    
    // Valeurs particulières
    final anglePattern = RegExp(r'(sin|cos|tan)\((\d+)\)');
    final angleMatch = anglePattern.firstMatch(s);
    if (angleMatch != null) {
      final func = angleMatch.group(1)!;
      final angle = int.parse(angleMatch.group(2)!);
      
      steps.add('$func($angle°)');
      
      double result;
      String exact;
      
      switch (angle) {
        case 0:
          result = func == 'sin' ? 0 : (func == 'cos' ? 1 : 0);
          exact = func == 'sin' ? '0' : (func == 'cos' ? '1' : '0');
          break;
        case 30:
          result = func == 'sin' ? 0.5 : (func == 'cos' ? sqrt(3)/2 : 1/sqrt(3));
          exact = func == 'sin' ? '1/2' : (func == 'cos' ? '√3/2' : '1/√3');
          break;
        case 45:
          result = func == 'sin' ? sqrt(2)/2 : (func == 'cos' ? sqrt(2)/2 : 1);
          exact = func == 'sin' ? '√2/2' : (func == 'cos' ? '√2/2' : '1');
          break;
        case 60:
          result = func == 'sin' ? sqrt(3)/2 : (func == 'cos' ? 0.5 : sqrt(3));
          exact = func == 'sin' ? '√3/2' : (func == 'cos' ? '1/2' : '√3');
          break;
        case 90:
          result = func == 'sin' ? 1 : (func == 'cos' ? 0 : double.infinity);
          exact = func == 'sin' ? '1' : (func == 'cos' ? '0' : 'indéfini');
          break;
        default:
          final radians = angle * pi / 180;
          result = func == 'sin' ? sin(radians) : 
                  (func == 'cos' ? cos(radians) : tan(radians));
          exact = result.toStringAsFixed(4);
      }
      
      steps.add('Valeur exacte: $exact');
      if (exact != result.toStringAsFixed(4)) {
        steps.add('Valeur décimale: ${result.toStringAsFixed(4)}');
      }
      
      return {'type': 'trigonometry', 'steps': steps, 'result': exact};
    }
    
    // Identités trigonométriques
    if (s.contains('sin²') && s.contains('cos²')) {
      steps.add('sin²θ + cos²θ = 1');
      steps.add('Identité fondamentale de Pythagore');
      return {'type': 'trigonometry', 'steps': steps, 'result': '1'};
    }
    
    return {'type': 'error', 'steps': [], 'result': 'Format non reconnu'};
  }

  // =================== PROBABILITÉS ===================
  bool _isProbability(String s) {
    return s.contains('p(') || s.contains('probabilité') || 
           s.contains('chance') || s.contains('prob') ||
           s.contains('/') && (s.contains('sur') || RegExp(r'\d+/\d+').hasMatch(s));
  }

  Map<String, dynamic> _solveProbability(String s) {
    final steps = <String>[];
    
    // Probabilité simple: cas favorables/cas totaux
    final fractionPattern = RegExp(r'(\d+)/(\d+)');
    final fractionMatch = fractionPattern.firstMatch(s);
    if (fractionMatch != null) {
      final favorable = int.parse(fractionMatch.group(1)!);
      final total = int.parse(fractionMatch.group(2)!);
      
      steps.add('P = $favorable/$total');
      steps.add('P = cas favorables / cas totaux');
      
      final probability = favorable / total;
      final percentage = probability * 100;
      
      steps.add('P = ${probability.toStringAsFixed(4)}');
      steps.add('P = ${percentage.toStringAsFixed(2)}%');
      
      return {
        'type': 'probability',
        'steps': steps,
        'result': '${probability.toStringAsFixed(4)} (${percentage.toStringAsFixed(2)}%)'
      };
    }
    
    // Probabilité conditionnelle P(A|B)
    final conditionalPattern = RegExp(r'p\(([^|]+)\|([^)]+)\)');
    final conditionalMatch = conditionalPattern.firstMatch(s);
    if (conditionalMatch != null) {
      final a = conditionalMatch.group(1)!;
      final b = conditionalMatch.group(2)!;
      
      steps.add('P($a|$b)');
      steps.add('Probabilité conditionnelle');
      steps.add('P($a|$b) = P($a ∩ $b) / P($b)');
      
      return {'type': 'probability', 'steps': steps, 'result': 'P($a ∩ $b) / P($b)'};
    }
    
    return {'type': 'error', 'steps': [], 'result': 'Format non reconnu'};
  }

  // =================== ÉQUATIONS (CODE EXISTANT) ===================
  Map<String, dynamic> _solvePolynomial(String expr) {
    try {
      final regex = RegExp(r'([+-]?\d*\.?\d*)x\^?2');
      final aMatch = regex.firstMatch(expr);
      final aStr = aMatch != null ? aMatch.group(1) ?? '1' : '0';
      final a = _parseCoeff(aStr);

      final regexB = RegExp(r'([+-]?\d*\.?\d*)x(?!\^)');
      final bMatch = regexB.firstMatch(expr);
      final bStr = bMatch != null ? bMatch.group(1) ?? '1' : '0';
      final b = _parseCoeff(bStr);

      var remainder = expr;
      if (aMatch != null) remainder = remainder.replaceFirst(aMatch.group(0)!, '');
      if (bMatch != null) remainder = remainder.replaceFirst(bMatch.group(0)!, '');
      
      final cMatch = RegExp(r'([+-]?\d+\.?\d*)').firstMatch(remainder);
      final c = cMatch != null ? double.parse(cMatch.group(1)!) : 0.0;

      if (a.abs() > 1e-12) {
        final delta = b * b - 4 * a * c;
        final steps = <String>[];
        steps.add('Équation: ${_formatCoeff(a)}x² + ${_formatCoeff(b)}x + ${_formatConstant(c)} = 0');
        steps.add('Δ = (${b})² - 4(${a})(${c}) = ${delta.toStringAsFixed(2)}');
        
        if (delta < 0) {
          return {'type': 'quadratic', 'steps': steps, 'result': 'Aucune solution réelle'};
        } else if (delta.abs() < 1e-12) {
          final root = -b / (2 * a);
          steps.add('Solution double: x = ${root.toStringAsFixed(3)}');
          return {'type': 'quadratic', 'steps': steps, 'result': 'x = ${root.toStringAsFixed(3)}'};
        } else {
          final sqrtDelta = sqrt(delta);
          final x1 = (-b + sqrtDelta) / (2 * a);
          final x2 = (-b - sqrtDelta) / (2 * a);
          steps.add('Solutions: x₁ = ${x1.toStringAsFixed(3)}, x₂ = ${x2.toStringAsFixed(3)}');
          return {'type': 'quadratic', 'steps': steps, 'result': 'x₁ = ${x1.toStringAsFixed(3)}, x₂ = ${x2.toStringAsFixed(3)}'};
        }
      } else if (b.abs() > 1e-12) {
        final root = -c / b;
        final steps = [
          'Équation linéaire: ${_formatCoeff(b)}x + ${_formatConstant(c)} = 0',
          'Solution: x = ${root.toStringAsFixed(3)}',
        ];
        return {'type': 'linear', 'steps': steps, 'result': 'x = ${root.toStringAsFixed(3)}'};
      } else {
        if (c.abs() < 1e-12) {
          return {'type': 'identity', 'steps': ['0 = 0'], 'result': 'Infinité de solutions'};
        } else {
          return {'type': 'contradiction', 'steps': ['${c.toStringAsFixed(2)} = 0'], 'result': 'Aucune solution'};
        }
      }
    } catch (e) {
      return {'type': 'error', 'steps': [], 'result': 'Erreur d\'analyse'};
    }
  }

  double _parseCoeff(String s) {
    if (s == '' || s == '+') return 1.0;
    if (s == '-') return -1.0;
    return double.tryParse(s) ?? 0.0;
  }

  String _formatCoeff(double coeff) {
    if (coeff == 1.0) return '';
    if (coeff == -1.0) return '-';
    if (coeff == coeff.toInt()) return coeff.toInt().toString();
    return coeff.toStringAsFixed(2);
  }

  String _formatConstant(double constant) {
    if (constant == constant.toInt()) return constant.toInt().toString();
    return constant.toStringAsFixed(2);
  }
}