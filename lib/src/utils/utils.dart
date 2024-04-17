import 'dart:math';

int generateRandomNumber(int from, int to) {
    //USE FOR RANDOM CHANGE TO DROP POWER UP
    Random random = Random();
    return random.nextInt(to) + from;
}