import '../models/personality_question.dart';

class PersonalityTestService {
  static const List<PersonalityQuestion> questions = [
    PersonalityQuestion(
      id: 1,
      question: 'At a party do you:',
      optionA: 'Interact with many, including strangers',
      optionB: 'Interact with a few, known to you',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 2,
      question: 'Are you more:',
      optionA: 'Realistic than speculative',
      optionB: 'Speculative than realistic',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 3,
      question: 'Is it worse to:',
      optionA: 'Have your "head in the clouds"',
      optionB: 'Be "in a rut"',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 4,
      question: 'Are you more impressed by:',
      optionA: 'Principles',
      optionB: 'Emotions',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 5,
      question: 'Are you more drawn toward the:',
      optionA: 'Convincing',
      optionB: 'Touching',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 6,
      question: 'Do you prefer to work:',
      optionA: 'To deadlines',
      optionB: 'Just "whenever"',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 7,
      question: 'Do you tend to choose:',
      optionA: 'Rather carefully',
      optionB: 'Somewhat impulsively',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 8,
      question: 'At parties do you:',
      optionA: 'Stay late, with increasing energy',
      optionB: 'Leave early with decreased energy',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 9,
      question: 'Are you more attracted to:',
      optionA: 'Sensible people',
      optionB: 'Imaginative people',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 10,
      question: 'Are you more interested in:',
      optionA: 'What is actual',
      optionB: 'What is possible',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 11,
      question: 'In judging others are you more swayed by:',
      optionA: 'Laws than circumstances',
      optionB: 'Circumstances than laws',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 12,
      question: 'In approaching others is your inclination to be somewhat:',
      optionA: 'Objective',
      optionB: 'Personal',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 13,
      question: 'Are you more:',
      optionA: 'Punctual',
      optionB: 'Leisurely',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 14,
      question: 'Does it bother you more having things:',
      optionA: 'Incomplete',
      optionB: 'Completed',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 15,
      question: 'In your social groups do you:',
      optionA: "Keep abreast of others' happenings",
      optionB: 'Get behind on the news',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 16,
      question: 'In doing ordinary things are you more likely to:',
      optionA: 'Do it the usual way',
      optionB: 'Do it your own way',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 17,
      question: 'Writers should:',
      optionA: '"Say what they mean and mean what they say"',
      optionB: 'Express things more by use of analogy',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 18,
      question: 'Which appeals to you more:',
      optionA: 'Consistency of thought',
      optionB: 'Harmonious human relationships',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 19,
      question: 'Are you more comfortable in making:',
      optionA: 'Logical judgments',
      optionB: 'Value judgments',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 20,
      question: 'Do you want things:',
      optionA: 'Settled and decided',
      optionB: 'Unsettled and undecided',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 21,
      question: 'Would you say you are more:',
      optionA: 'Serious and determined',
      optionB: 'Easy-going',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 22,
      question: 'In phoning do you:',
      optionA: 'Rarely question that it will all be said',
      optionB: 'Rehearse what you\'ll say',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 23,
      question: 'Facts:',
      optionA: '"Speak for themselves"',
      optionB: 'Illustrate principles',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 24,
      question: 'Are visionaries:',
      optionA: 'Somewhat annoying',
      optionB: 'Rather fascinating',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 25,
      question: 'Are you more often:',
      optionA: 'A cool-headed person',
      optionB: 'A warm-hearted person',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 26,
      question: 'Is it worse to be:',
      optionA: 'Unjust',
      optionB: 'Merciless',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 27,
      question: 'Should one usually let events occur:',
      optionA: 'By careful selection and choice',
      optionB: 'Randomly and by chance',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 28,
      question: 'Do you feel better about:',
      optionA: 'Having purchased',
      optionB: 'Having the option to buy',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 29,
      question: 'In company do you:',
      optionA: 'Initiate conversation',
      optionB: 'Wait to be approached',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 30,
      question: 'Common sense is:',
      optionA: 'Rarely questionable',
      optionB: 'Frequently questionable',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 31,
      question: 'Children often do not:',
      optionA: 'Make themselves useful enough',
      optionB: 'Exercise their fantasy enough',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 32,
      question: 'In making decisions do you feel more comfortable with:',
      optionA: 'Standards',
      optionB: 'Feelings',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 33,
      question: 'Are you more:',
      optionA: 'Firm than gentle',
      optionB: 'Gentle than firm',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 34,
      question: 'Which is more admirable:',
      optionA: 'The ability to organize and be methodical',
      optionB: 'The ability to adapt and make do',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 35,
      question: 'Do you put more value on:',
      optionA: 'Definite',
      optionB: 'Open-minded',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 36,
      question: 'Does new and non-routine interaction with others:',
      optionA: 'Stimulate and energize you',
      optionB: 'Tax your reserves',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 37,
      question: 'Are you more frequently:',
      optionA: 'A practical sort of person',
      optionB: 'A fanciful sort of person',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 38,
      question: 'Are you more likely to:',
      optionA: 'See how others are useful',
      optionB: 'See how others see',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 39,
      question: 'Which is more satisfying:',
      optionA: 'To discuss an issue thoroughly',
      optionB: 'To arrive at agreement on an issue',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 40,
      question: 'Which rules you more:',
      optionA: 'Your head',
      optionB: 'Your heart',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 41,
      question: 'Are you more comfortable with work that is:',
      optionA: 'Contracted',
      optionB: 'Done on a casual basis',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 42,
      question: 'Do you tend to look for:',
      optionA: 'The orderly',
      optionB: 'Whatever turns up',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 43,
      question: 'Do you prefer:',
      optionA: 'Many friends with brief contact',
      optionB: 'A few friends with more lengthy contact',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 44,
      question: 'Do you go more by:',
      optionA: 'Facts',
      optionB: 'Principles',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 45,
      question: 'Are you more interested in:',
      optionA: 'Production and distribution',
      optionB: 'Design and research',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 46,
      question: 'Which is more of a compliment:',
      optionA: '"There is a very logical person."',
      optionB: '"There is a very sentimental person."',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 47,
      question: 'Do you value in yourself more that you are:',
      optionA: 'Unwavering',
      optionB: 'Devoted',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 48,
      question: 'Do you more often prefer the:',
      optionA: 'Final and unalterable statement',
      optionB: 'Tentative and preliminary statement',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 49,
      question: 'Are you more comfortable:',
      optionA: 'After a decision',
      optionB: 'Before a decision',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 50,
      question: 'Do you:',
      optionA: 'Speak easily and at length with strangers',
      optionB: 'Find little to say to strangers',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 51,
      question: 'Are you more likely to trust your:',
      optionA: 'Experience',
      optionB: 'Hunch',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 52,
      question: 'Do you feel:',
      optionA: 'More practical than ingenious',
      optionB: 'More ingenious than practical',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 53,
      question: 'Which person is more to be complimented – one of:',
      optionA: 'Clear reason',
      optionB: 'Strong feeling',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 54,
      question: 'Are you inclined more to be:',
      optionA: 'Fair-minded',
      optionB: 'Sympathetic',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 55,
      question: 'Is it preferable mostly to:',
      optionA: 'Make sure things are arranged',
      optionB: 'Just let things happen',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 56,
      question: 'In relationships should most things be:',
      optionA: 'Re-negotiable',
      optionB: 'Random and circumstantial',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 57,
      question: 'When the phone rings do you:',
      optionA: 'Hasten to get to it first',
      optionB: 'Hope someone else will answer',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 58,
      question: 'Do you prize more in yourself:',
      optionA: 'A strong sense of reality',
      optionB: 'A vivid imagination',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 59,
      question: 'Are you drawn more to:',
      optionA: 'Fundamentals',
      optionB: 'Overtones',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 60,
      question: 'Which seems the greater error:',
      optionA: 'To be too passionate',
      optionB: 'To be too objective',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 61,
      question: 'Do you see yourself as basically:',
      optionA: 'Hard-headed',
      optionB: 'Soft-hearted',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 62,
      question: 'Which situation appeals to you more:',
      optionA: 'The structured and scheduled',
      optionB: 'The unstructured and unscheduled',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 63,
      question: 'Are you a person that is more:',
      optionA: 'Routinized than whimsical',
      optionB: 'Whimsical than routinized',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 64,
      question: 'Are you more inclined to be:',
      optionA: 'Easy to approach',
      optionB: 'Somewhat reserved',
      dimensionA: 'E', dimensionB: 'I',
    ),
    PersonalityQuestion(
      id: 65,
      question: 'In writings do you prefer:',
      optionA: 'The more literal',
      optionB: 'The more figurative',
      dimensionA: 'S', dimensionB: 'N',
    ),
    PersonalityQuestion(
      id: 66,
      question: 'Is it harder for you to:',
      optionA: 'Identify with others',
      optionB: 'Utilize others',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 67,
      question: 'Which do you wish more for yourself:',
      optionA: 'Clarity of reason',
      optionB: 'Strength of compassion',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 68,
      question: 'Which is the greater fault:',
      optionA: 'Being indiscriminate',
      optionB: 'Being critical',
      dimensionA: 'T', dimensionB: 'F',
    ),
    PersonalityQuestion(
      id: 69,
      question: 'Do you prefer the:',
      optionA: 'Planned event',
      optionB: 'Unplanned event',
      dimensionA: 'J', dimensionB: 'P',
    ),
    PersonalityQuestion(
      id: 70,
      question: 'Do you tend to be more:',
      optionA: 'Deliberate than spontaneous',
      optionB: 'Spontaneous than deliberate',
      dimensionA: 'J', dimensionB: 'P',
    ),
  ];

  /// Scores the given answers (map of question id → 'A' or 'B') and returns MBTI type string
  static String calculateType(Map<int, String> answers) {
    int eCount = 0, iCount = 0;
    int sCount = 0, nCount = 0;
    int tCount = 0, fCount = 0;
    int jCount = 0, pCount = 0;

    for (final q in questions) {
      final answer = answers[q.id];
      if (answer == null) continue;
      final dim = answer == 'A' ? q.dimensionA : q.dimensionB;
      switch (dim) {
        case 'E': eCount++; break;
        case 'I': iCount++; break;
        case 'S': sCount++; break;
        case 'N': nCount++; break;
        case 'T': tCount++; break;
        case 'F': fCount++; break;
        case 'J': jCount++; break;
        case 'P': pCount++; break;
      }
    }

    final ei = eCount >= iCount ? 'E' : 'I';
    final sn = sCount >= nCount ? 'S' : 'N';
    final tf = tCount >= fCount ? 'T' : 'F';
    final jp = jCount >= pCount ? 'J' : 'P';

    return '$ei$sn$tf$jp';
  }

  static Map<String, int> getDimensionScores(Map<int, String> answers) {
    int eCount = 0, iCount = 0;
    int sCount = 0, nCount = 0;
    int tCount = 0, fCount = 0;
    int jCount = 0, pCount = 0;

    for (final q in questions) {
      final answer = answers[q.id];
      if (answer == null) continue;
      final dim = answer == 'A' ? q.dimensionA : q.dimensionB;
      switch (dim) {
        case 'E': eCount++; break;
        case 'I': iCount++; break;
        case 'S': sCount++; break;
        case 'N': nCount++; break;
        case 'T': tCount++; break;
        case 'F': fCount++; break;
        case 'J': jCount++; break;
        case 'P': pCount++; break;
      }
    }

    return {
      'E': eCount, 'I': iCount,
      'S': sCount, 'N': nCount,
      'T': tCount, 'F': fCount,
      'J': jCount, 'P': pCount,
    };
  }
}
