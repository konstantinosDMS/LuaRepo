#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void my(void *data, size_t size) {
    double *datum = (double *)data;
    printf("Size: %zu\n", size);

    for (size_t i = 0; i < size; i++) {
        printf("%f\n", datum[i]);
    }
}

int main(void) {
    double my_data[2] = {1.0, 2.0};
    size_t array_size = sizeof(my_data) / sizeof(my_data[0]);
    my(my_data, array_size);
    return 0;
}

