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
static inline int bitcount(int v) {
    int count;
    for (count = 0; v; ++count) {
        v &= v - 1;
    }
    return count;
}

static inline int bit2num(int v) {
    int i;
    for (i = 0; v; ++i) {
        v >>= 1;
    }
    return i;
}

static int countPossibleValues(Unit grid[], int idx) {
    if (grid[idx].values <= 0) {
        return grid[idx].values;
    }
    return bitcount(grid[idx].values);
}

static int toReadableValue(Unit grid[], int idx) {
    if (grid[idx].values < 0) {
        return -(grid[idx].values);
    }
    return bit2num(grid[idx].values);
}

static void dumpGrid(Unit grid[]) {
    int i, j;
    fprintf(stderr, "987654321,987654321,987654321,987654321,987654321,"
            "987654321,987654321,987654321,987654321,\n");
    for (i = 0; i < C_UNIT; ++i) {
        if (grid[i].values < 0) {
            fprintf(stderr, "%9d", toReadableValue(grid, i));
        } else {
            for (j = C_ROW - 1; j >= 0; --j) {
                fprintf(stderr, "%d", grid[i].values & (1 << j) ? 1 : 0);
            }
        }
        fprintf(stderr, ",");
        if (!((i + 1) % C_ROW)) {
            fprintf(stderr, "\n");
        }
    }
    fprintf(stderr, "\n");
}

/**
 * Reduce possible values by confirmed units
 *
 * @param
 *      grid    Sudoku grid
 *
 * @return
 *      index of unit has least multiple possible values
 *      -1 on conflict or error
 *      C_UNIT on all units confirmed
 */
static int reducePossibleValues(Unit grid[]) {
    if (!grid) {
        return -1;
    }

    int i, j, found, c, minc, mini;
    while (1) {
        /* find a confirmed unit */
        found = -1;
        mini = C_UNIT;
        minc = C_ROW + 1;
        for (i = 0; i < C_UNIT; ++i) {
            c = countPossibleValues(grid, i);
            if (c == 1) {
                grid[i].values = -(toReadableValue(grid, i));
                found = i;
                break;
            } else if (c > 1) {
                if (c < minc) {
                    mini = i;
                    minc = c;
                }
            }
        }
        if (found == -1) {
            return mini;
        }
        DBG("FND: %2d (%2d, %2d) = %d\n",
                found, ROW(found), COL(found), grid[found].values);

        /* current row */
        for (i = ROW(found) * C_COL; i < (ROW(found) + 1) * C_COL; ++i) {
            if (i == found) {
                continue;
            }
            if (countPossibleValues(grid, i) > 0) {
                grid[i].values &= DEL(toReadableValue(grid, found));
                if (countPossibleValues(grid, i) == 0) {
                    return -1;
                }
            }
        }
        /* current column */
        for (i = COL(found); i < C_ROW * C_COL; i += C_COL) {
            if (i == found) {
                continue;
            }
            if (countPossibleValues(grid, i) > 0) {
                grid[i].values &= DEL(toReadableValue(grid, found));
                if (countPossibleValues(grid, i) == 0) {
                    return -1;
                }
            }
        }
        /* current block */
        for (i = BLK_HEAD(found); i < BLK_HEAD(found) + C_COL * C_BLK;
                i += C_COL) {
            for (j = 0; j < C_BLK; ++j) {
                if ((i + j) == found) {
                    continue;
                }
                if (countPossibleValues(grid, i + j) > 0) {
                    grid[i + j].values &= DEL(toReadableValue(grid, found));
                    if (countPossibleValues(grid, i + j) == 0) {
                        return -1;
                    }
                }
            }
        }
    }

    return -1;
}

static int recursiveTryPossibleValues(Unit grid[]) {
    if (!grid) {
        return -1;
    }

    Unit ngrid[C_UNIT];
    int i, mini;

    mini = reducePossibleValues(grid);
    if (mini == C_UNIT) {
        /* print one solution */
        dumpGrid(grid);
        return 0;
    }
    if (mini == -1) {
        /* some error */
        return -1;
    }
    DBG("\nTRY: %2d (%2d, %2d) = %d\n",
            mini, ROW(mini), COL(mini), grid[mini].values);

    /* mini >= 0 */
    for (i = 0; i < C_ROW; ++i) {
        if (grid[mini].values & (1 << i)) {
            /* copy grid and set mini in new grid */
            memcpy(ngrid, grid, sizeof(Unit) * C_UNIT);
            ngrid[mini].values = 1 << i;

            /* remove one possible value */
            grid[mini].values &= DEL(i + 1);

            /* new level */
            recursiveTryPossibleValues(ngrid);
        }
    }

    /* all possible values done */
    return -1;
}

int fillGrid(int orig[]) {
    if (!orig) {
        return -1;
    }

    Unit grid[C_UNIT];
    int i;

    /* format values */
    for (i = 0; i < C_UNIT; ++i) {
        if (orig[i] > 0) {
            grid[i].values = 1 << (orig[i] - 1);
        } else {
            grid[i].values = V_ALL;
        }
    }
    dumpGrid(grid);

    /* try */
    recursiveTryPossibleValues(grid);

    return 0;
}
