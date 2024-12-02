#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <errno.h>
#include <ctype.h>


int main(int argc, char* argv[]) {
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    char c;
    int lines = 2;
    int lineLength;
    char * path;
    int sum = 0;

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
    if (fp == NULL) {
        perror("file read");
        exit(EXIT_FAILURE);
    }

    read = getline(&line, &len, fp);
    if (read == -1) {
        printf("getline fail");
        exit(EXIT_FAILURE);
    }
    lineLength = strlen(line) + 1;
    // printf("%d\n", lineLength);
    rewind(fp);
    for (c = getc(fp); c != EOF; c = getc(fp))
        if (c == '\n') // Increment count if this character is newline
            lines++;
    // printf("%d\n", lines);
    rewind(fp);

    char parts[lines + 1][lineLength];

    for (int x=0; x<lines+1; x++) {
        for (int y=0; y<lineLength; y++) {
            parts[x][y] = '.';
            // printf("%c", parts[x][y]);
        }
        // printf("\n");
    }

    int i = 1;
    int j = 1;
    for (c = getc(fp); c != EOF; c = getc(fp)) {
        // printf("%c", c);
        if (c == '\n') { // skip if this character is newline
            j=1;
            i++;
            continue;
        }
        parts[i][j] = c;
        j++;
    }

    // for (int x=0; x<lines+1; x++) {
    //     for (int y=0; y<lineLength; y++) {
    //         printf("%c", parts[x][y]);
    //     }
    //     printf("\n");
    // }

    
    for (int p=1; p < lines; p++) {
        int q = 0;
        while (q < lineLength-1) {
            int isPart = 0;
            int k = 0;
            char number[3] = "\0\0\0";
            int num;
            while (isdigit(parts[p][q])) {
                if ((parts[p-1][q-1] != '.' && !isdigit(parts[p-1][q-1])) ||
                    (parts[p][q-1] != '.' && !isdigit(parts[p][q-1])) ||
                    (parts[p+1][q-1] != '.' && !isdigit(parts[p+1][q-1])) ||
                    (parts[p+1][q] != '.' && !isdigit(parts[p+1][q])) ||
                    (parts[p-1][q] != '.' && !isdigit(parts[p-1][q])) ||
                    (parts[p+1][q+1] != '.' && !isdigit(parts[p+1][q+1])) ||
                    (parts[p][q+1] != '.' && !isdigit(parts[p][q+1])) ||
                    (parts[p-1][q+1] != '.' && !isdigit(parts[p-1][q+1]))) {
                        isPart = 1;
                    }
                number[k] = parts[p][q];
                k++;
                q++;
            }
            if (isPart) {
                // printf("%s\n", number);
                num = atoi(number);
                sum += num;
            }
            q++;

        }
    }

    printf("%d\n", sum);
}