#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <ctype.h>

#define DELIMITERS ":|\0"

int scoreCard(char * card);
int * extractNums(char * nums);

int main(int argc, char* argv[]) {
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    char * path;
    int sum = 0;
    int lines = 1;
    char c;

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
    for (c = getc(fp); c != EOF; c = getc(fp))
        if (c == '\n') // Increment count if this character is newline
            lines++;
    printf("%d\n", lines);
    rewind(fp);
    int numcards[lines];
    
    for (int x=0; x<lines; x++) {
        numcards[x] = 1;
        // printf("%d: %d\n", x, numcards[x]);
    }
    int i = 0;
    while ((read = getline(&line, &len, fp)) != -1) {
        int score = 0;
        score += scoreCard(line);
        printf("card %d: score: %d, copies: %d\n", i, score, numcards[i]);
        for (int j=i+1; j < i+score+1; j++) {
            numcards[j] += numcards[i];
        }
        sum += numcards[i];
        i++;

    }

    printf("total score: %d\n", sum);
}

int scoreCard(char * card) {

    char * nums;
    char * winNums;
    char * my_nums;
    int * winning;
    int lenWin = 10; //5 10
    int * myNums;
    int lenMine = 25; //8 25
    int score = 0;

    nums = strtok(card, DELIMITERS);
    nums = strtok(NULL, DELIMITERS);
    winNums = malloc(strlen(nums));
    strcpy(winNums, nums);
    winning = extractNums(winNums);


    nums += strlen(nums) + 1;
    my_nums = malloc(strlen(nums));
    strcpy(my_nums, nums);
    myNums = extractNums(my_nums);


    // printf("%d %d\n", lenWin, lenMine);
    // for (int x=0; x<lenWin; x++) {
    //     printf("%d ", winning[x]);
    // }
    // printf("| ");
    // for (int x=0; x<lenMine; x++) {
    //     printf("%d ", myNums[x]);
    // }
    // printf("\n");

    for (int i=0; i < lenMine; i++) {
        for (int j=0; j < lenWin; j++) {
            if (myNums[i] == winning[j]) {
                score++;
            }
        }
    }
    return score;
}

int * extractNums(char * nums) {
    // printf("here\n");
    int * num;
    //get the number of numbers
    char * numscpy = malloc(strlen(nums));
    char * x;
    strcpy(numscpy, nums);
    int len = 1;
    x = strtok(numscpy, " ");
    while(x != NULL) {
        len ++;
        x = strtok(NULL, " ");
    }
    

    num = malloc(sizeof(int)*(len - 1));
    int i = 0;
    char * n;
    n = strtok(nums, " ");
    // printf("%s ", n);
    while(n != NULL) {
        num[i] = atoi(n);
        i++;
        n = strtok(NULL, " ");
        // printf("%s ", n);
    }
    // for (int i=0; i<len-1; i++) {
    //     printf("%d ", num[i]);
    // }
    // printf("\n");
    // printf("%p", num);
    return num;
}

