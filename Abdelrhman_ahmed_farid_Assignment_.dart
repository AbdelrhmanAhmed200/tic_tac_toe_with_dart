import 'dart:io';
import 'dart:math';

bool winner = false;
bool isXturn = true;
List<String> cordinates = [];
List<String> combinations = ['012', '048', '036', '147', '246', '258', '345', '678'];
int movement = 0;

void main() {
  chooseMode();
}

void chooseMode() {
  print("Select mode: \n 1- Two player mode \n 2- One player mode vs computer (easy) \n 3- One player mode vs computer (hard)");

  try {
    int mode = int.parse(stdin.readLineSync()!);

    switch (mode) {
      case 1:
        startGame(3, mode); // Two player mode
        break;
      case 2:
        startGame(3, mode); // Easy computer mode
        break;
      case 3:
        startGame(3, mode); // Hard computer mode
        break;
      default:
        print("Invalid input. Please enter a valid number.");
        chooseMode();
    }
  } catch (e) {
    print("Invalid input. Please enter a valid number.");
    chooseMode();
  }
}

void startGame(int size, int mode) {
  cordinates = List.generate(size * size, (index) => (index + 1).toString());
  movement = 0;
  winner = false;
  drawBoard(size);

  switch (mode) {
    case 1:
      getPlayerMove();
      break;
    case 2:
      getPlayerMoveVsComputer();
      if (movement == 9)
      print("DRAW!");
      playAgain();
      break;
    case 3:
      getPlayerMoveVsComputerHard();
      if (movement == 9)
      print("DRAW!");
      playAgain();
      break;
  }
}

void getPlayerMove() {
  print('Player ${isXturn ? "X" : "O"}, choose a number (1-9):');

  try {
    int number = int.parse(stdin.readLineSync()!);

    if (number >= 1 && number <= 9 && cordinates[number - 1] != "X" && cordinates[number - 1] != "O") {
      cordinates[number - 1] = isXturn ? 'X' : 'O';
      movement++;
      checkWinner(isXturn ? 'X' : 'O');
      isXturn = !isXturn;

      if (!winner && movement < 9) {
        clearScreen();
        drawBoard(3);
        getPlayerMove();
      } else if (movement == 9 && !winner) {
        print("DRAW!");
        playAgain();
      }
    } else {
      print("Invalid move, choose another number.");
      getPlayerMove();
    }
  } catch (e) {
    print("Invalid input, please enter a number.");
    getPlayerMove();
  }
}

void getPlayerMoveVsComputer() {
  print('Player X, choose a number (1-9):');

  try {
    int number = int.parse(stdin.readLineSync()!);

    if (number >= 1 && number <= 9 && cordinates[number - 1] != "X" && cordinates[number - 1] != "O") {
      cordinates[number - 1] = 'X';
      movement++;
      checkWinner('X');

      if (!winner && movement < 9) {
        int computerMove = Random().nextInt(9) + 1;
        while (cordinates[computerMove - 1] == "X" || cordinates[computerMove - 1] == "O") {
          computerMove = Random().nextInt(9) + 1;
        }

        cordinates[computerMove - 1] = 'O';
        movement++;
        checkWinner('O');

        if (!winner && movement < 9) {
          clearScreen();
          drawBoard(3);
          getPlayerMoveVsComputer();
        } else if (movement == 9 && !winner) {
          print("DRAW!");
          playAgain();
        }
      }
    } else {
      print("Invalid move, choose another number.");
      getPlayerMoveVsComputer();
    }
  } catch (e) {
    print("Invalid input, please enter a number.");
    getPlayerMoveVsComputer();
  }
}

void getPlayerMoveVsComputerHard() {
  print('Player X, choose a number (1-9):');

  try {
    int number = int.parse(stdin.readLineSync()!);

    if (number >= 1 && number <= 9 && cordinates[number - 1] != "X" && cordinates[number - 1] != "O") {
      cordinates[number - 1] = 'X';
      movement++;
      checkWinner('X');

      if (!winner && movement < 9) {
        int bestMove = findBestMove();
        cordinates[bestMove] = 'O';
        movement++;
        checkWinner('O');

        if (!winner && movement < 9) {
          clearScreen();
          drawBoard(3);
          getPlayerMoveVsComputerHard();
        } else if (movement == 9 && !winner) {
          print("DRAW!");
          playAgain();
        }
      }
    } else {
      print("Invalid move, choose another number.");
      getPlayerMoveVsComputerHard();
    }
  } catch (e) {
    print("Invalid input, please enter a number.");
    getPlayerMoveVsComputerHard();
  }
}

int findBestMove() {
  int bestScore = -1000;
  int bestMove = -1;

  for (int i = 0; i < 9; i++) {
    if (cordinates[i] != 'X' && cordinates[i] != 'O') {
      String temp = cordinates[i];
      cordinates[i] = 'O';
      movement++;
      int score = minimax(0, false);
      cordinates[i] = temp;
      movement--;

      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
  }
  return bestMove;
}

int minimax(int depth, bool isMaximizing) {
  if (checkWinnerForMinimax('O')) return 10 - depth;
  if (checkWinnerForMinimax('X')) return depth - 10;
  if (movement == 9) return 0;

  if (isMaximizing) {
    int bestScore = -1000;
    for (int i = 0; i < 9; i++) {
      if (cordinates[i] != 'X' && cordinates[i] != 'O') {
        String temp = cordinates[i];
        cordinates[i] = 'O';
        movement++;
        bestScore = max(bestScore, minimax(depth + 1, false));
        cordinates[i] = temp;
        movement--;
      }
    }
    return bestScore;
  } else {
    int bestScore = 1000;
    for (int i = 0; i < 9; i++) {
      if (cordinates[i] != 'X' && cordinates[i] != 'O') {
        String temp = cordinates[i];
        cordinates[i] = 'X';
        movement++;
        bestScore = min(bestScore, minimax(depth + 1, true));
        cordinates[i] = temp;
        movement--;
      }
    }
    return bestScore;
  }
}

bool checkWinnerForMinimax(String player) {
  for (String combination in combinations) {
    if (combination.split('').every((index) => cordinates[int.parse(index)] == player)) {
      return true;
    }
  }
  return false;
}

void checkWinner(String player) {
  for (String combination in combinations) {
    bool hasWon = combination.split('').every((index) => cordinates[int.parse(index)] == player);

    if (hasWon) {
      drawBoard(3);
      print('$player WON!');
      winner = true;
      playAgain();
      break;
    }
  }
}

void playAgain() {
  print("Do you want to play again? (y/n)");
  String? response = stdin.readLineSync();

  if (response == "y" || response == "Y") {
    main();
  } else if (response == "n" || response == "N") {
    print("Game over!");
    exit(0);
  } else {
    print("Invalid response, please enter y or n.");
    playAgain();
  }
}

void drawBoard(int size) {
  int count = 0;
  String row = " ---" * size;

  for (var i = 0; i < size; i++) {
    print(row);
    String column = "";

    for (var j = 0; j < size; j++) {
      column += "| ${cordinates[count]} ";
      count++;
    }
    print(column + "|");
  }
  print(row);
}

void clearScreen() {
  if (Platform.isWindows) {
    print(Process.runSync("cls", [], runInShell: true).stdout);
  } else {
    print(Process.runSync("clear", [], runInShell: true).stdout);
  }
}
