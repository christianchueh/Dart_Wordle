import 'package:flutter/material.dart';

Widget buildTile(String letter, String result) {
  Color tileColor = Colors.white;
  if (result == 'G') tileColor = Colors.green;
  if (result == 'Y') tileColor = Colors.amber;
  if (result == 'B') tileColor = Colors.blueGrey;

  final borderColor = result == '' ? Colors.grey : tileColor;
  final textColor = result == '' ? Colors.black : Colors.white;

  return Container(
    width: 48,
    height: 48,
    margin: const EdgeInsets.all(4),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: tileColor,
      border: Border.all(color: borderColor),
    ),
    child: Text(
      letter,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ),
  );
}

Widget buildKey(String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 44,
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    ),
  );
}

Widget buildKeyboardRow(String letters, void Function(String) onLetterTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: letters.split('').map((letter) {
      return buildKey(letter, () => onLetterTap(letter));
    }).toList(),
  );
}

Widget buildGame() {
  var currentGuess = '';
  var gameOver = false;
  const answer = 'APPLE';
  final guesses = <String>[];
  var message = '輸入五個字母後按送出';
  return StatefulBuilder(
    builder: (context, setState) {
      void submitGuess() {
        if (gameOver) return;
        if (currentGuess.length != 5) {
          setState(() {
            message = '請先輸入剛好五個字母';
          });
          return;
        }

        setState(() {
          final submittedWord = currentGuess;
          guesses.add(submittedWord);
          currentGuess = '';

          if (submittedWord == answer) {
            gameOver = true;
            message = '答對了！';
          } else if (guesses.length == 6) {
            gameOver = true;
            message = '機會用完，答案是 $answer';
          } else {
            message = '已猜 ${guesses.length} 次';
          }
        });
      }

      void deleteLetter() {
        if (currentGuess.isEmpty) return;

        setState(() {
          currentGuess = currentGuess.substring(0, currentGuess.length - 1);
        });
      }

      void addLetter(String letter) {
        setState(() {
          if (!gameOver && currentGuess.length < 5) {
            currentGuess += letter;
          }
        });
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(6, (row) {
            final submitted = row < guesses.length;
            final word = submitted
                ? guesses[row]
                : row == guesses.length
                ? currentGuess
                : '';
            final results = submitted
                ? evaluateGuess(answer, word)
                : List<String>.filled(5, '');

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (column) {
                final letter = column < word.length ? word[column] : '';
                return buildTile(letter, results[column]);
              }),
            );
          }),
          buildKeyboardRow('QWERTYUIOP', addLetter),
          buildKeyboardRow('ASDFGHJKL', addLetter),
          buildKeyboardRow('ZXCVBNM', addLetter),
          Text('目前輸入：$currentGuess'),
          Text(message),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: deleteLetter, child: const Text('刪除')),
              ElevatedButton(onPressed: submitGuess, child: const Text('送出')),
            ],
          ),
          ...guesses.map(
            (word) => Text('$word   ${evaluateGuess(answer, word).join(" ")}'),
          ),
          if (gameOver)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  guesses.clear();
                  currentGuess = '';
                  gameOver = false;
                  message = '新的一局開始';
                });
              },
              child: const Text('重新開始'),
            ),
        ],
      );
    },
  );
}

List<String> evaluateGuess(String answer, String guess) {
  final result = List<String>.filled(5, 'B');
  final remaining = answer.toUpperCase().split('');
  final letters = guess.toUpperCase();

  // 第一輪：先標記位置正確的字母。
  for (var i = 0; i < 5; i++) {
    if (letters[i] == remaining[i]) {
      result[i] = 'G';
      remaining[i] = '';
    }
  }

  // 第二輪：只從尚未使用的答案字母找黃色。
  for (var i = 0; i < 5; i++) {
    if (result[i] == 'G') continue;
    final foundAt = remaining.indexOf(letters[i]);
    if (foundAt != -1) {
      result[i] = 'Y';
      remaining[foundAt] = '';
    }
  }
  return result;
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(body: Center(child: buildGame())),
    ),
  );
}
