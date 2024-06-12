#include "lambdalib.h"

/* program */

const int N = 100;

int a[100];

int main()
{
    for (int i = 0; i < N; i++)
    {
        a[i] = i;
    }
    double *half = (double *)malloc(100 * sizeof(double));
    for (int a_i = 0; a_i < 100; ++a_i)
    {
        half[a_i] = a[a_i] / 2;
    };
}
