/*
 * sss.c
 *
 *  Created on: Apr 10, 2017
 *      Author: zhanghe
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "comdef.h"

/* bit count */
static int bitcount(int v) {
    int count;
    for (count = 0; v; ++count) {
        v &= v - 1;
    }
    return count;
}

static int bit2num(int v) {
    int i;
    for (i = 0; v; ++i) {
        v >>= 1;
    }
    return i;
}

static int countPossibleValues(int grid[], int idx) {
    if (grid[idx] < 0) {
        return -1;
    }
    if (grid[idx] == 0) {
        return 0;
    }
    return bitcount(grid[idx]);
}

static int transConfirmedValue(int grid[], int idx) {
    if (grid[idx] < 0) {
        return -grid[idx];
    }
    if (grid[idx] == 0) {
        return 0;
    }
    return bit2num(grid[idx]);
}

static void dumpValues(int grid[]) {
    int ri, ci, i;
    fprintf(stderr, "\n987654321,987654321,987654321,987654321,987654321,"
            "987654321,987654321,987654321,987654321,\n");
    for (ri = 0; ri < N_ROW; ++ri) {
        for (ci = 0; ci < N_COL; ++ci) {
            if (countPossibleValues(grid, POS(ri, ci)) > 1) {
                for (i = N_ROW - 1; i >= 0; --i) {
                    fprintf(stderr, "%d",
                            grid[POS(ri, ci)] & (1 << i) ? 1 : 0);
                }
            } else {
                fprintf(stderr, "%9d", transConfirmedValue(grid, POS(ri, ci)));
            }
            fprintf(stderr, ",");
        }
        fprintf(stderr, "\n");
    }
}

static int applyConfirmedOne(int grid[], int idx) {
    if (grid[idx] > 0) {
        return 0;
    }
    if (grid[idx] == 0) {
        return -1;
    }

    int i, j, c;
    do {
        /* current row */
        for (i = ROW(idx) * N_COL; i < (ROW(idx) + 1) * N_COL; ++i) {
            if (i == idx) {
                continue;
            }
            if (grid[i] > 0) {
                grid[i] &= DEL(grid[idx]);
                if (grid[i] == 0) {
                    return -1;
                }
            }
        }
        /* current column */
        for (i = COL(idx); i < N_ROW * N_COL; i += N_COL) {
            if (i == idx) {
                continue;
            }
            if (grid[i] > 0) {
                grid[i] &= DEL(grid[idx]);
                if (grid[i] == 0) {
                    return -1;
                }
            }
        }
        /* current block */
        for (i = POS(ROW(idx) / N_BLK * N_BLK, COL(idx) / N_BLK * N_BLK);
                i < POS(ROW(idx) / N_BLK * N_BLK, COL(idx) / N_BLK * N_BLK) + N_COL * N_BLK;
                i += N_COL) {
            for (j = 0; j < N_BLK; ++j) {
                //fprintf(stderr, "idx=%2d, i+j=%2d\n", idx, i + j);
                if ((i + j) == idx) {
                    continue;
                }
                if (grid[i + j] > 0) {
                    grid[i + j] &= DEL(grid[idx]);
                    if (grid[i + j] == 0) {
                        return -1;
                    }
                }
            }
        }

        /* find new confirmed one */
        for (i = 0; i < N_ROW * N_COL; ++i) {
            c = countPossibleValues(grid, i);
            if (c == 1) {
                //fprintf(stderr, "new: %d, %d\n", ROW(i), COL(i));
                grid[i] = 0 - transConfirmedValue(grid, i);
                idx = i;
                break;
            }
        }
    } while (c == 1);

    return 0;
}

static int recursiveTryPossibleValues(int grid[]) {
    int i, c, minc, mini, rc = 0;
    int ngrid[N_ROW * N_COL];

    do {
        minc = N_ROW + 1;
        mini = -1;
        for (i = 0; i < N_ROW * N_COL; ++i) {
            c = countPossibleValues(grid, i);
            if (c > 1 && c < minc) {
                minc = c;
                mini = i;
            }
        }
        if (mini > -1) {
            for (i = 0; i < N_ROW; ++i) {
                if (grid[mini] & (1 << i)) {
                    //fprintf(stderr, "\ntry: %d, %d, %d\n", ROW(mini), COL(mini), grid[mini]);
                    memcpy(ngrid, grid, sizeof(int) * N_ROW * N_COL);
                    ngrid[mini] = 0 - (i + 1);
                    rc = applyConfirmedOne(ngrid, mini);
                    //dumpValues(ngrid);
                    if (rc == 0) {
                        rc = recursiveTryPossibleValues(ngrid);
                        if (rc == 0) {
                            memcpy(grid, ngrid, sizeof(int) * N_ROW * N_COL);
                            break;
                        }
                    }
                    if (rc == -1) {
                        grid[mini] &= DEL(ngrid[mini]);
                    }
                    //fprintf(stderr, "end: %d, %d, %d\n", ROW(mini), COL(mini), grid[mini]);
                }
            }
            if (grid[mini] == 0) {
                return -1;
            }
        }
    } while (mini > -1);

    return 0;
}

int fillGrid(int grid[]) {
    int i;
    /* change values */
    for (i = 0; i < N_ROW * N_COL; ++i) {
        if (grid[i] > 0) {
            grid[i] = -grid[i];
        } else {
            grid[i] = V_ALL;
        }
    }
    //dumpValues(grid);

    /* apply known values */
    for (i = 0; i < N_ROW * N_COL; ++i) {
        applyConfirmedOne(grid, i);
    }
    //dumpValues(grid);

    /* try */
    recursiveTryPossibleValues(grid);
    dumpValues(grid);

    return 0;
}
