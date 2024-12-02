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

    for (int p=1; p < lines; p++) {
        int q = 0;
        while (q < lineLength-1) {
            char number1[4] = "\0\0\0\0";
            char number2[4] = "\0\0\0\0";
            int num1;
            int num2;
            if (parts[p][q] == '*') {
                int isGear = 0;
                int numcount = 0;
                for (int a=p-1; a<p+2; a++) {
                    int b = q-1;
                    while (b<q+2) {
                        if (isdigit(parts[a][b])) {
                            numcount++;
                            if(numcount > 2) {
                                isGear = 0;
                                break;
                            }
                            while(isdigit(parts[a][b])) {
                                b--;
                            }
                            b++;
                            int k = 0;
                            // printf("%c\n", parts[a][b]);
                            while (isdigit(parts[a][b]))
                            {
                                if (numcount==1) {
                                    number1[k] = parts[a][b];
                                }
                                else
                                    number2[k] = parts[a][b];
                                k++;
                                b++;
                            }

                        }
                        b++;
                    }
                    if (numcount > 2 )
                        break;
                }

                if (numcount < 3) {
                    // printf("num1: %s\n",number1);
                    // printf("num2: %s\n", number2);
                    num1 = atoi(number1);
                    num2 = atoi(number2);
                    sum += num1 * num2;
                }
            }
            q++;
        }

    }

    printf("%d\n", sum);
}