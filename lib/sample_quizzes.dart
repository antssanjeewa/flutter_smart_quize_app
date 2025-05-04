import 'models/question.dart';
import 'models/quiz.dart';

final List<Quiz> sampleQuizzes = [
  Quiz(
    id: 'quiz1',
    title: 'General Knowledge',
    categoryId: 'cat1',
    timeLimit: 60,
    questions: [
      Question(
        text: 'What is the capital of France?',
        options: ['Berlin', 'London', 'Paris', 'Madrid'],
        correctOptionIndex: 2,
      ),
      Question(
        text: 'Which planet is known as the Red Planet?',
        options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
        correctOptionIndex: 1,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz2',
    title: 'Science Basics',
    categoryId: 'cat2',
    timeLimit: 90,
    questions: [
      Question(
        text: 'What gas do plants absorb from the atmosphere?',
        options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
        correctOptionIndex: 2,
      ),
      Question(
        text: 'What is the chemical symbol for water?',
        options: ['O2', 'H2O', 'CO2', 'NaCl'],
        correctOptionIndex: 1,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz3',
    title: 'Math Challenge',
    categoryId: 'cat3',
    timeLimit: 45,
    questions: [
      Question(
        text: 'What is 15 × 3?',
        options: ['45', '30', '60', '50'],
        correctOptionIndex: 0,
      ),
      Question(
        text: 'What is the square root of 64?',
        options: ['6', '7', '8', '9'],
        correctOptionIndex: 2,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz4',
    title: 'World Capitals',
    categoryId: 'cat1',
    timeLimit: 60,
    questions: [
      Question(
        text: 'What is the capital of Japan?',
        options: ['Beijing', 'Seoul', 'Tokyo', 'Bangkok'],
        correctOptionIndex: 2,
      ),
      Question(
        text: 'What is the capital of Canada?',
        options: ['Toronto', 'Ottawa', 'Vancouver', 'Montreal'],
        correctOptionIndex: 1,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz5',
    title: 'Computer Science',
    categoryId: 'cat4',
    timeLimit: 75,
    questions: [
      Question(
        text: 'What does CPU stand for?',
        options: [
          'Central Process Unit',
          'Central Processing Unit',
          'Computer Power Unit',
          'Central Performance Unit',
        ],
        correctOptionIndex: 1,
      ),
      Question(
        text: 'Which company developed the Android OS?',
        options: ['Apple', 'Google', 'Microsoft', 'Samsung'],
        correctOptionIndex: 1,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz6',
    title: 'History Facts',
    categoryId: 'cat5',
    timeLimit: 60,
    questions: [
      Question(
        text: 'Who was the first president of the United States?',
        options: [
          'George Washington',
          'Thomas Jefferson',
          'Abraham Lincoln',
          'John Adams',
        ],
        correctOptionIndex: 0,
      ),
      Question(
        text: 'In which year did World War II end?',
        options: ['1940', '1945', '1950', '1939'],
        correctOptionIndex: 1,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz7',
    title: 'Geography Mix',
    categoryId: 'cat6',
    timeLimit: 70,
    questions: [
      Question(
        text: 'Which continent has the most countries?',
        options: ['Asia', 'Europe', 'Africa', 'South America'],
        correctOptionIndex: 2,
      ),
      Question(
        text: 'Which ocean is the largest?',
        options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
        correctOptionIndex: 3,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz8',
    title: 'Sports Trivia',
    categoryId: 'cat7',
    timeLimit: 50,
    questions: [
      Question(
        text: 'Which country won the FIFA World Cup in 2018?',
        options: ['Germany', 'Argentina', 'France', 'Brazil'],
        correctOptionIndex: 2,
      ),
      Question(
        text: 'How many players are on a basketball team on the court?',
        options: ['5', '6', '7', '8'],
        correctOptionIndex: 0,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz9',
    title: 'Literature & Books',
    categoryId: 'cat8',
    timeLimit: 65,
    questions: [
      Question(
        text: 'Who wrote "Romeo and Juliet"?',
        options: [
          'William Shakespeare',
          'Charles Dickens',
          'Jane Austen',
          'Mark Twain',
        ],
        correctOptionIndex: 0,
      ),
      Question(
        text: 'In which novel does the character "Atticus Finch" appear?',
        options: [
          '1984',
          'Moby Dick',
          'To Kill a Mockingbird',
          'The Great Gatsby',
        ],
        correctOptionIndex: 2,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  Quiz(
    id: 'quiz10',
    title: 'Technology Today',
    categoryId: 'cat4',
    timeLimit: 80,
    questions: [
      Question(
        text: 'What does HTML stand for?',
        options: [
          'Hyper Trainer Marking Language',
          'Hyper Text Markup Language',
          'High Text Markup Language',
          'Hyperlinking Text Management Language',
        ],
        correctOptionIndex: 1,
      ),
      Question(
        text: 'Which company manufactures the iPhone?',
        options: ['Apple', 'Samsung', 'Google', 'Huawei'],
        correctOptionIndex: 0,
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];
