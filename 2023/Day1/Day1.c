#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <ctype.h>

#define BUF_SIZE 50

int matchword(char * start, char * buf);

int main(int argc, char* argv[]) {
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    int sum = 0;
    char num[2];
    char * path;
    char first;
    char last;
    
    char * digit = malloc(sizeof(char));
    if (digit == NULL) {
        perror("Allocation Error");
    }
    
    

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

    while ((read = getline(&line, &len, fp)) != -1)
    {
        first = '\0';
        last  = '\0';
        int i = 0;
        while(i < strlen(line)) {
            if (isdigit(line[i])) {
                if (first == '\0') {
                    first = line[i];
                }
                last = line[i];
            }
            else {
                int wordLen;
                if ((wordLen = matchword(&line[i], digit)) != 0) {
                    // printf("%c\n",*digit);
                    if (first == '\0') {
                        first = *digit;
                    }
                    last = *digit;
                    // i += wordLen;
                }
            }
            i++;
        }
       
        num[0] = first;
        num[1] = last;
        if (first == '\0')
            continue;
        printf("%s\n", num);
        int number = atoi(num);
        // printf("%d\n", number);
        sum += number;

    }
    
    free(digit);
    
    printf("%d\n",sum);
    
    fclose(fp);
}

int matchword(char * start, char * buf) {
    char * nums[9] = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};
    char digits[9] = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};

    for (int i=0; i<9; i++) {
        if(strncmp(start, nums[i], strlen(nums[i])) == 0) {
            // printf("%s\n", nums[i]);
            *buf = digits[i];
            return strlen(nums[i]);
        }
    }
    return 0;
}