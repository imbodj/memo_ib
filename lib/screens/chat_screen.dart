

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
<<<<<<< HEAD
import 'message.dart';
import 'solver.dart';
=======
import '../enums/conversation_state.dart';
import '../models/learning_data.dart';
import '../models/exercise.dart';
import '../models/message.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/message_bubble.dart';
>>>>>>> 9195555 (Ajout des nouveaux models et widgets)

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
<<<<<<< HEAD
  final MathSolverService _mathSolver = MathSolverService();

  bool _isTyping = false;

=======

  bool _isTyping = false;
>>>>>>> 9195555 (Ajout des nouveaux models et widgets)
  late AnimationController _typingAnimationController;

  ConversationState _currentState = ConversationState.selectTheme;
  String? _selectedTheme;
  String? _selectedLesson;
  int _currentExerciseIndex = 0;
  bool _showingSolution = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  Future<void> _initMessages() async {
    await _loadMessages();
    if (_messages.isEmpty) {
      _addMessage(Message(
<<<<<<< HEAD
        text:
            "Bonjour ! Je suis votre assistant mathématiques pour le programme IB AA. Posez-moi vos questions !",
=======
        text: "Bonjour ! Je suis votre assistant mathématiques pour le programme IB maths AA.\n\n**Choisissez un thème :**\n\n• Thème 1: Nombres et Algèbre \n• Thème 2: Fonctions\n• Thème 3: Géométrie et Trigonométrie \n• Thème 4: Statistiques et Probabilités\n• Thème 5: Analyse mathématique\n\n Tapez simplement le numéro du thème (1, 2, 3, 4, ou 5).",
>>>>>>> 9195555 (Ajout des nouveaux models et widgets)
        isUser: false,
        timestamp: DateTime.now(),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
    }
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('chat_messages') ?? [];

    setState(() {
      _messages.clear();
      _messages.addAll(
        messagesJson.map((json) => Message.fromJson(jsonDecode(json))).toList(),
      );
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson =
        _messages.map((msg) => jsonEncode(msg.toJson())).toList();
    await prefs.setStringList('chat_messages', messagesJson);
  }

  void _addMessage(Message message) {
    setState(() {
      _messages.add(message);
    });
    _saveMessages();
    _scrollToBottom();
  }

  Future<void> _deleteMessage(String messageId) async {
    setState(() {
      _messages.removeWhere((msg) => msg.id == messageId);
    });
    await _saveMessages();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _processUserInput(String userInput) {
    String input = userInput.toLowerCase().trim();

    switch (_currentState) {
      case ConversationState.selectTheme:
        return _handleThemeSelection(input);
      case ConversationState.selectLesson:
        return _handleLessonSelection(input);
      case ConversationState.inExercise:
        return _handleExerciseInteraction(input);
      default:
        return "Je n'ai pas compris votre demande.";
    }
  }

  String _handleThemeSelection(String input) {
    Map<String, String> themeMap = {
      '1': 'Thème 1: Nombres et Algèbre',
      'theme 1': 'Thème 1: Nombres et Algèbre',
      'thème 1': 'Thème 1: Nombres et Algèbre',
      '2': 'Thème 2: Fonctions',
      'theme 2': 'Thème 2: Fonctions',
      'thème 2': 'Thème 2: Fonctions',
      '3': 'Thème 3: Géométrie et Trigonométrie',
      'theme 3': 'Thème 3: Géométrie et Trigonométrie',
      'thème 3': 'Thème 3: Géométrie et Trigonométrie',
      '4': 'Thème 4: Statistiques et Probabilités',
      'theme 4': 'Thème 4: Statistiques et Probabilités',
      'thème 4': 'Thème 4: Statistiques et Probabilités',
      '5': 'Thème 5: Analyse mathématique',
      'theme 5': 'Thème 5: Analyse mathématique',
      'thème 5': 'Thème 5: Analyse mathématique',
    };
    String? selectedTheme = themeMap[input.toLowerCase()];

    if (selectedTheme != null && LearningData.themes.containsKey(selectedTheme)) {
      _selectedTheme = selectedTheme;
      _currentState = ConversationState.selectLesson;
      var lessons = LearningData.themes[selectedTheme]!.keys.toList();
      String lessonsList = lessons.asMap().entries.map((entry) =>
        "• ${entry.key + 1}. ${entry.value}").join('\n');
      return "Excellent choix ! Vous avez sélectionné : **$selectedTheme**\n\n**Choisissez une leçon :**\n\n$lessonsList\n\nTapez le numéro de la leçon que vous souhaitez travailler.";
    }

    return "Je n'ai pas reconnu votre choix. Veuillez taper le numéro du thème (1, 2, 3, 4, ou 5) ou le nom du thème.";
  }

  String _handleLessonSelection(String input) {
    if (_selectedTheme == null) {
      _currentState = ConversationState.selectTheme;
      return "Une erreur s'est produite. Recommençons par choisir un thème.";
    }
    var lessons = LearningData.themes[_selectedTheme!]!.keys.toList();

    int? lessonIndex;
    try {
      lessonIndex = int.parse(input) - 1;
    } catch (e) {
      for (int i = 0; i < lessons.length; i++) {
        if (lessons[i].toLowerCase().contains(input)) {
          lessonIndex = i;
          break;
        }
      }
    }

    if (lessonIndex != null && lessonIndex >= 0 && lessonIndex < lessons.length) {
      _selectedLesson = lessons[lessonIndex];
      _currentState = ConversationState.inExercise;
      _currentExerciseIndex = 0;
      _showingSolution = false;

      var exercises = LearningData.themes[_selectedTheme!]![_selectedLesson!]!;
      var totalExercises = exercises.length;
      var exercise = exercises[0];

      return "Parfait ! Commençons avec : **$_selectedLesson**\n\n**Exercice 1/$totalExercises:**\n\n${exercise.question}\n\n💡 Tapez 'correction' pour voir la solution, ou donnez votre réponse !";
    }

    return "Numéro de leçon invalide. Veuillez choisir un numéro entre 1 et ${lessons.length}.";
  }

  String _handleExerciseInteraction(String input) {
    if (_selectedTheme == null || _selectedLesson == null) {
      _currentState = ConversationState.selectTheme;
      return "Une erreur s'est produite. Recommençons.";
    }

    var exercises = LearningData.themes[_selectedTheme!]![_selectedLesson!]!;
    var totalExercices = exercises.length;

    if (input.contains('correction') || input.contains('solution')) {
      if (!_showingSolution) {
        _showingSolution = true;
        var currentExercise = exercises[_currentExerciseIndex];
        return "**Solution de l'exercice ${_currentExerciseIndex + 1}:**\n\n${currentExercise.solution}\n\n📚 Tapez 'suivant' pour l'exercice suivant, 'menu' pour revenir au menu principal, ou 'leçons' pour changer de leçon.";
      } else {
        return "La solution est déjà affichée ci-dessus ! Tapez 'suivant' pour continuer.";
      }
    }

    if (input.contains('suivant') || input.contains('next')) {
      if (_currentExerciseIndex < exercises.length - 1) {
        _currentExerciseIndex++;
        _showingSolution = false;
        var exercise = exercises[_currentExerciseIndex];
        return "**Exercice ${_currentExerciseIndex + 1}/$totalExercices:**\n\n${exercise.question}\n\n💡 Tapez 'correction' pour voir la solution !";
      } else {
        return "🎉 Félicitations ! Vous avez terminé tous les exercices de cette leçon.\n\n**Options :**\n• Tapez 'recommencer' pour refaire cette leçon\n• Tapez 'leçons' pour choisir une autre leçon\n• Tapez 'menu' pour revenir au menu principal";
      }
    }

    if (input.contains('recommencer') || input.contains('restart')) {
      _currentExerciseIndex = 0;
      _showingSolution = false;
      var exercise = exercises[0];
      return "**Recommençons la leçon : $_selectedLesson**\n\n**Exercice 1/$totalExercices:**\n\n${exercise.question}\n\n💡 Tapez 'correction' pour voir la solution !";
    }

    if (input.contains('leçons') || input.contains('lessons')) {
      _currentState = ConversationState.selectLesson;
      _selectedLesson = null;

      var lessons = LearningData.themes[_selectedTheme!]!.keys.toList();
      String lessonsList = lessons.asMap().entries.map((entry) =>
        "• ${entry.key + 1}. ${entry.value}").join('\n');

      return "**Choisissez une nouvelle leçon du $_selectedTheme :**\n\n$lessonsList\n\nTapez le numéro de la leçon.";
    }

    if (input.contains('menu') || input.contains('thèmes') || input.contains('themes')) {
      _currentState = ConversationState.selectTheme;
      _selectedTheme = null;
      _selectedLesson = null;

      return "**Retour au menu principal. Choisissez un thème :**\n\n• Thème 1: Nombres et Algèbre\n• Thème 2: Fonctions \n• Thème 3: Géométrie et Trigonométrie \n• Thème 4: Statistiques et Probabilités\n• Thème 5: Analyse mathématique\n\n Tapez le numéro du thème.";
    }

    if (!_showingSolution) {
      return "Merci pour votre réponse ! 📝\n\nTapez 'correction' pour voir la solution détaillée et comparer avec votre approche.";
    }

    return "Commandes disponibles :\n• 'correction' - Voir la solution\n• 'suivant' - Exercice suivant\n• 'leçons' - Changer de leçon\n• 'menu' - Retour au menu principal";
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final userMessage = Message(
      text: _messageController.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _addMessage(userMessage);
    String userInput = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _isTyping = true;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isTyping = false;
    });
    String response = _processUserInput(userInput);

<<<<<<< HEAD
    // Tentative de résolution avec le solver
    final solution = _mathSolver.solve(userMessage.text);

    String response;
    if (solution['type'] != 'error' && solution['result'] != null) {
      final steps = (solution['steps'] as List<String>).join('\n');
      response = """**Résolution étape par étape :**  
$steps  

**Résultat :** ${solution['result']}""";
    } else {
      // Ici, ça tombera bien dans _generateMathResponse si rien n’est reconnu
      response = _generateMathResponse(userMessage.text);
    }
=======
>>>>>>> 9195555 (Ajout des nouveaux models et widgets)
    _addMessage(Message(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_bot',
    ));
  }

<<<<<<< HEAD
  // ═══════════════════════════════════════════════════════════════════════════
  // GÉNÉRATION DES RÉPONSES MATHÉMATIQUES
  // ═══════════════════════════════════════════════════════════════════════════

  String _generateMathResponse(String question) {
    final lowerQuestion = question.toLowerCase();

    // Équations du premier degré
    if (lowerQuestion.contains('équation') &&
        (lowerQuestion.contains('premier') || lowerQuestion.contains('ax+b'))) {
      return '''**Équations du premier degré : ax + b = 0**

**Forme générale :** ax + b = 0 où a ≠ 0

**Solution :** x = -b/a

**Exemple :** 3x + 6 = 0
- 3x = -6
- x = -6/3 = -2

**Méthode :** Isoler x en déplaçant les termes.''';
    }

    // Équations du second degré
    if (lowerQuestion.contains('équation') &&
        (lowerQuestion.contains('second') || lowerQuestion.contains('ax²'))) {
      return '''**Équations du second degré : ax² + bx + c = 0**

**Discriminant :** Δ = b² - 4ac

**Solutions :**
- Si Δ > 0 : x = (-b ± √Δ)/(2a)
- Si Δ = 0 : x = -b/(2a)
- Si Δ < 0 : Pas de solution réelle

**Exemple :** x² - 5x + 6 = 0
- Δ = 25 - 24 = 1
- x = (5 ± 1)/2 = 3 ou 2''';
    }

    // Développement du binôme
    if (lowerQuestion.contains('binôme') || lowerQuestion.contains('(a+b)')) {
      return '''**Développement du binôme (a+b)ⁿ**

**Formule générale :** (a+b)ⁿ = Σ C(n,k) × aⁿ⁻ᵏ × bᵏ

**Coefficient binomial :** C(n,k) = n!/(k!(n-k)!)

**Terme général :** Tₖ₊₁ = C(n,k) × aⁿ⁻ᵏ × bᵏ

**Exemples courants :**
- (a+b)² = a² + 2ab + b²
- (a+b)³ = a³ + 3a²b + 3ab² + b³''';
    }

    // Lois des exposants
    if (lowerQuestion.contains('exposant') ||
        lowerQuestion.contains('puissance')) {
      return '''**Lois des exposants**

**Règles principales :**
- aᵐ × aⁿ = aᵐ⁺ⁿ
- aᵐ ÷ aⁿ = aᵐ⁻ⁿ
- (aᵐ)ⁿ = aᵐⁿ
- (ab)ⁿ = aⁿbⁿ
- a⁰ = 1 (si a ≠ 0)
- a⁻ⁿ = 1/aⁿ

**Exemples :**
- 2³ × 2² = 2⁵ = 32
- x⁴ ÷ x² = x² 
- (3²)³ = 3⁶ = 729''';
    }

    // Logarithmes
    if (lowerQuestion.contains('logarithme') || lowerQuestion.contains('log')) {
      return '''**Logarithmes**

**Définition :** Si aˣ = b, alors log_a(b) = x

**Propriétés principales :**
- log_a(xy) = log_a(x) + log_a(y)
- log_a(x/y) = log_a(x) - log_a(y)
- log_a(xⁿ) = n × log_a(x)
- log_a(a) = 1
- log_a(1) = 0

**Changement de base :** log_a(x) = log_b(x)/log_b(a)

**Logarithme naturel :** ln(x) = log_e(x)''';
    }

    // Dérivées
    if (lowerQuestion.contains('dérivée') ||
        lowerQuestion.contains('derivative')) {
      return '''**Dérivées - Règles de base**

**Fonctions de base :**
- d/dx(c) = 0
- d/dx(x) = 1
- d/dx(xⁿ) = nxⁿ⁻¹
- d/dx(sin x) = cos x
- d/dx(cos x) = -sin x
- d/dx(ln x) = 1/x

**Règles de calcul :**
- (f + g)' = f' + g'
- (cf)' = cf'
- (fg)' = f'g + fg' (règle du produit)''';
    }

    // Trigonométrie
    if (lowerQuestion.contains('trigonométrie') ||
        lowerQuestion.contains('sin') ||
        lowerQuestion.contains('cos')) {
      return '''**Trigonométrie - Identités fondamentales**

**Identité de Pythagore :** sin²θ + cos²θ = 1

**Autres identités :**
- tan θ = sin θ / cos θ
- 1 + tan²θ = sec²θ
- sin(a ± b) = sin a cos b ± cos a sin b
- cos(a ± b) = cos a cos b ∓ sin a sin b

**Valeurs particulières :** sin 30° = 1/2, cos 30° = √3/2''';
    }

    // Probabilités
    if (lowerQuestion.contains('probabilité') ||
        lowerQuestion.contains('statistique')) {
      return '''**Probabilités de base**

**Probabilité :** P(A) = nombre de cas favorables / nombre de cas totaux

**Règles :**
- 0 ≤ P(A) ≤ 1
- P(A') = 1 - P(A)
- P(A ∪ B) = P(A) + P(B) - P(A ∩ B)

**Probabilité conditionnelle :** P(A|B) = P(A ∩ B)/P(B)''';
    }

    // Primitives
    if (lowerQuestion.contains('primitive') ||
        lowerQuestion.contains('intégrale')) {
      return '''**Primitives - Règles de base**

**Fonctions usuelles :**
- ∫ c dx = cx + C
- ∫ xⁿ dx = xⁿ⁺¹/(n+1) + C  (n ≠ -1)
- ∫ 1/x dx = ln|x| + C
- ∫ eˣ dx = eˣ + C
- ∫ cos x dx = sin x + C
- ∫ sin x dx = -cos x + C

**Exemple :**
∫ (x² + 1) dx  
= x³/3 + x + C
''';
    }

// Terme général du binôme
    if (lowerQuestion.contains('terme') && lowerQuestion.contains('binôme')) {
      return '''**Terme général du développement du binôme**

Soit (a+b)ⁿ.  
Le terme de rang k+1 (k = 0, 1, ..., n) est :

Tₖ₊₁ = C(n,k) × aⁿ⁻ᵏ × bᵏ

**Exemple :**  
Dans (x+2)⁵, le terme en k=2 est :  
T₃ = C(5,2) × x³ × 2² = 10 × x³ × 4 = 40x³
''';
    }

    // Réponse par défaut
    return '''Je me concentre sur les mathématiques du programme IB AA. Je peux vous aider avec :

• **Équations** (1er et 2nd degré)
• **Développement du binôme** (a+b)ⁿ
• **Lois des exposants** et logarithmes
• **Dérivées** et calcul différentiel
• **Trigonométrie** de base
• **Probabilités** et statistiques

Pouvez-vous reformuler votre question en lien avec ces thèmes ?''';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGUES ET INTERACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

=======
>>>>>>> 9195555 (Ajout des nouveaux models et widgets)
  void _showDeleteDialog(Message message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le message'),
          content:
              const Text('Êtes-vous sûr de vouloir supprimer ce message ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMessage(message.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

<<<<<<< HEAD
  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGETS DE L'INTERFACE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF6C5CE7),
            child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(0),
                    const SizedBox(width: 4),
                    _buildDot(1),
                    const SizedBox(width: 4),
                    _buildDot(2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final animationValue = _typingAnimationController.value;
    final dotAnimation = ((animationValue * 3) - index).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Color.lerp(
          Colors.grey.withOpacity(0.5),
          const Color(0xFF6C5CE7),
          dotAnimation,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser) ...[
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF6C5CE7),
                      child:
                          Icon(Icons.smart_toy, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: GestureDetector(
                      onLongPress: () => _showDeleteDialog(message),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isUser
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF6C5CE7),
                                    Color(0xFF74B9FF)
                                  ],
                                )
                              : null,
                          color: isUser
                              ? null
                              : isDark
                                  ? const Color(0xFF2D2D2D)
                                  : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isUser ? 18 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMessageContent(message.text, isUser, isDark),
                            const SizedBox(height: 4),
                            Text(
                              "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontSize: 10,
                                color: isUser
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isUser) ...[
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person,
                          color: Colors.grey, size: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent(String text, bool isUser, bool isDark) {
    if (text.contains('∫') ||
        text.contains('Σ') ||
        text.contains('²') ||
        text.contains('³') ||
        text.contains('√') ||
        text.contains('dx') ||
        text.contains('sin') ||
        text.contains('cos') ||
        text.contains('tan')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _parseTextWithMath(text, isUser, isDark),
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isUser
              ? Colors.white
              : isDark
                  ? Colors.white
                  : Colors.black87,
          height: 1.4,
        ),
      );
    }
  }

  List<Widget> _parseTextWithMath(String text, bool isUser, bool isDark) {
    List<Widget> widgets = [];
    List<String> lines = text.split('\n');

    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isUser
                    ? Colors.white
                    : isDark
                        ? Colors.white
                        : Colors.black87,
              ),
            ),
          ),
        );
      } else if (line.contains('∫') ||
          line.contains('²') ||
          line.contains('³') ||
          line.contains('√') ||
          line.contains('dx') ||
          line.contains('Σ')) {
        try {
          widgets.add(
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.white.withOpacity(0.2)
                    : isDark
                        ? Colors.grey[800]
                        : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isUser
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              // Ajout du scroll horizontal pour les formules longues
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  line,
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: isUser
                        ? Colors.white
                        : isDark
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        } catch (e) {
          widgets.add(
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  color: isUser
                      ? Colors.white
                      : isDark
                          ? Colors.white
                          : Colors.black87,
                ),
              ),
            ),
          );
        }
      } else {
        widgets.add(
          Text(
            line,
            style: TextStyle(
              fontSize: 16,
              color: isUser
                  ? Colors.white
                  : isDark
                      ? Colors.white
                      : Colors.black87,
              height: 1.4,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTRUCTION DE L'INTERFACE PRINCIPALE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assistant Mathématiques',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Effacer l\'historique'),
                  content: const Text(
                      'Voulez-vous supprimer tout l\'historique des conversations ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          _messages.clear();
                        });
                        await _saveMessages();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index], index);
              },
            ),
          ),
          _buildInputSection(isDark),
        ],
      ),
    );
  }

=======
>>>>>>> 9195555 (Ajout des nouveaux models et widgets)
  Widget _buildInputSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 17),
                decoration: const InputDecoration(
                  hintText: 'Tapez votre réponse ou une commande...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
=======

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assistant Mathématiques',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Effacer l\'historique'),
                  content: const Text('Voulez-vous supprimer tout l\'historique des conversations ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          _messages.clear();
                          _currentState = ConversationState.selectTheme;
                          _selectedTheme = null;
                          _selectedLesson = null;
                          _currentExerciseIndex = 0;
                          _showingSolution = false;
                        });
                        await _saveMessages();
                        _addMessage(Message(
                          text: "Bonjour ! Je suis votre assistant mathématiques pour le programme IB AA.\n\n**Choisissez un thème :**\n\n• Thème 1: Nombres et Algèbre\n• Thème 2: Fonctions\n• Thème 3: Géométrie et Trigonométrie\n• Thème 4: Statistiques et Probabilités\n• Thème 5: Analyse mathématique\n\nTapez simplement le numéro du thème (1, 2, 3, 4, ou 5).",
                          isUser: false,
                          timestamp: DateTime.now(),
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                        ));
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return TypingIndicator(typingAnimationController: _typingAnimationController);
                }
                return MessageBubble(
                  message: _messages[index],
                  index: index,
                  onLongPress: _showDeleteDialog,
                );
              },
            ),
          ),
          _buildInputSection(isDark),
        ],
      ),
    );
  }
>>>>>>> 9195555 (Ajout des nouveaux models et widgets)
}
