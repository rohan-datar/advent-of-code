#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <ctype.h>

#define DELIMITERS ":,;"
#define MAX_DIGITS 2
#define CODE_RED 1
#define CODE_GREEN 2
#define CODE_BLUE 3

const char *RED = "red";
const char *GREEN = "green";
const char *BLUE = "blue";
const char *GAME = "Game ";
const int MAX_RED = 12;
const int MAX_GREEN = 13;
const int MAX_BLUE = 14;

int checkPossiblity(char * game);
int getID(char * id);
int isPossible(char * cubes);
int getPower(char * game);
int color(char * cubes);
int numCubes(char *cubes);

int main(int argc, char* argv[]) {
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    char * path;
    int sum = 0;
    int possible;
    int sumPow = 0;

    //get file from command line
    if (argc == 1) {
        printf("Provide a file path!");
        exit(EXIT_FAILURE);
    }
    else if (argc > 2) {
        printf("Too many arguments!");
        exit(EXIT_FAILURE);
    }

    path = argv[1];

    fp = fopen(path, "r");
    if (fp == NULL)
    {
        exit(EXIT_FAILURE);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        // printf("%s", line);

        // sum += checkPossiblity(line);
        // int powr = getPower(line);
        // printf("%d\n", powr);
        sumPow += getPower(line);
    }

    // printf("%d\n", sum);
    printf("power: %d\n", sumPow);
}

int checkPossiblity(char * game) {
    char * word = NULL;
    int id = 0;

    word = strtok(game, DELIMITERS);
    if (strncmp(word, GAME, strlen(GAME)) != 0) {
        printf("can't find game ID!");
        return 0;
    }
    char * idPos = word + strlen(GAME);
    id = atoi(idPos);
    word = strtok(NULL, DELIMITERS);
    while (word != NULL) {

        // printf("%s\n", word);
        // int pos = isPossible(word);
        // printf("%d\n", pos);
        char * cubes = word;
        if (cubes[0] == ' ')
            cubes++;
        if (isPossible(cubes) == 0) {
            // printf("not possible");
            return 0;
        }
        word = strtok(NULL, DELIMITERS);
    }

    return id;
}


int isPossible(char * cubes) {
    // printf("%s\n", cubes);
    char number[MAX_DIGITS];
    int num;
    char * color;
    int i = 0;
    for(;;) {
        // printf("%c\n", cubes[i]);
        if (isdigit(cubes[i])) {
            // printf("got here!");
            if (i > (MAX_DIGITS-1))
                return 0;
            
            number[i] = cubes[i];
        }
        if (cubes[i] == ' ')
            break;
        i++;
    }
    // printf("%s\n", number);
    num = atoi(number);
    if (num > MAX_BLUE) 
        return 0;
    
    color = cubes + i; 
    while(color[0] == ' '){
        color++;
    }
    if (strncmp(color, RED, strlen(RED)) == 0) {
        if (num > MAX_RED) {
            return 0;
        }
    }
    if (strncmp(color, BLUE, strlen(BLUE)) == 0) {
        if (num > MAX_BLUE) {
            return 0;
        }
    }
    if (strncmp(color, GREEN, strlen(GREEN)) == 0) {
        if (num > MAX_GREEN) {
            return 0;
        }
    }

    return 1;
}

int getPower(char * game) {
    char * word = NULL;
    int maxRed = 0;
    int maxGreen = 0;
    int maxBlue = 0;
    // printf("%s\n", game);

    word = strtok(game, DELIMITERS);
    word = strtok(NULL, DELIMITERS);

    while (word != NULL) {
        int colorCode;
        int numCube;
        // printf("here%s\n", word);
        char * cubes = word;
        if (cubes[0] == ' ')
            cubes++;
        numCube = numCubes(cubes);
        // printf("%d\n", numCube);
        colorCode = color(cubes);

        switch (colorCode)
        {
        case CODE_RED:
            if (maxRed < numCube)
                maxRed = numCube;
            break;
        case CODE_BLUE:
            if (maxBlue < numCube)
                maxBlue = numCube;
            break;
        case CODE_GREEN:
            if (maxGreen < numCube)
                maxGreen = numCube;
            break;
        default:
            break;
        }
        word = strtok(NULL, DELIMITERS);
    }
    // printf("%d\n", maxRed);
    // printf("%d\n", maxGreen);
    // printf("%d\n", maxBlue);

    if (maxRed == 0)
        maxRed = 1;
    if (maxGreen == 0)
        maxGreen = 1;
    if (maxBlue == 0)
        maxBlue = 1;

    return maxRed * maxGreen * maxBlue;
}

int numCubes(char *cubes) {
    char number[2];
    int num;
    int i = 0;

    for(;;) {
        // printf("%c\n" , cubes[i]);
        if (isdigit(cubes[i])) {
            number[i] = cubes[i];
        }
        if (cubes[i] == ' ')
            break;
        i++;
    }
    // printf("%s\n", number);
    num = atoi(number);
    // printf("%d\n", num);
    return num;
}

int color(char * cubes) {
    int i = 0;
    char * color;
    while(cubes[i] !=' ') {
        i++;
    }
    
    color = cubes + i + 1;
    if (strncmp(color, RED, strlen(RED)) == 0) {
        return CODE_RED;
    }
    if (strncmp(color, BLUE, strlen(BLUE)) == 0) {
        return CODE_BLUE;
    }
    if (strncmp(color, GREEN, strlen(GREEN)) == 0) {
        return CODE_GREEN;
    } 

    return -1;
}