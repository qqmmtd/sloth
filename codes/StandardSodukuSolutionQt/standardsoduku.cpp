#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "standardsoduku.h"

#define DEBUG 0
#if DEBUG == 2
#define DBG(...) \
{ \
    fprintf(stderr, "%s/%d: ", __FUNCTION__, __LINE__); \
    fprintf(stderr, __VA_ARGS__); \
}
#elif DEBUG == 1
#define DBG(...) \
{ \
    fprintf(stderr, __VA_ARGS__); \
}
#elif DEBUG == 0
#define DBG(...) \
    do { } while (0)
#endif

#define ERR(...) \
{ \
    fprintf(stderr, __VA_ARGS__); \
}

StandardSoduku::StandardSoduku()
{
}

StandardSoduku::StandardSoduku(const int data[])
{
    reset(data);
}

void StandardSoduku::reset(const int data[])
{
    memcpy(this->data, data, sizeof(this->data));
}

/* bit count */
int StandardSoduku::bitcount(int v)
{
    int count;
    for (count = 0; v; ++count) {
        v &= v - 1;
    }
    return count;
}

int StandardSoduku::bit2num(int v)
{
    int i;
    for (i = 0; v; ++i) {
        v >>= 1;
    }
    return i;
}

int StandardSoduku::solve(int solution[])
{
    int rc, i;
    Unit grid[C_UNIT];

    for (i = 0; i < C_UNIT; ++i) {
        if (this->data[i] > 0) {
            grid[i].values = num2bit(this->data[i]);
        } else {
            grid[i].values = V_ALL;
        }
    }
    dumpGrid(grid);

    rc = recursiveTryPossibleValues(grid);
    if (0 == rc) {
        for (i = 0; i < C_UNIT; ++i) {
            solution[i] = toReadableValue(grid[i].values);
        }
    }

    return rc;
}

int StandardSoduku::recursiveTryPossibleValues(Unit grid[])
{
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
            memcpy(ngrid, grid, sizeof(ngrid));
            ngrid[mini].values = 1 << i;

            /* exclude one possible value */
            grid[mini].values = exclude(grid[mini].values, i + 1);

            /* new level */
            if (recursiveTryPossibleValues(ngrid) == 0) {
                /* if want all solutions, do nothing here */
                memcpy(grid, ngrid, sizeof(ngrid));
                return 0;
            }
        }
    }

    /* all possible values done */
    return -1;
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
int StandardSoduku::reducePossibleValues(Unit grid[])
{
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
            c = countPossibleValues(grid[i].values);
            if (c == 1) {
                grid[i].values = -(bit2num(grid[i].values));
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
        for (i = row(found) * C_COL; i < (row(found) + 1) * C_COL; ++i) {
            if (i == found) {
                continue;
            }
            if (countPossibleValues(grid[i].values) > 0) {
                grid[i].values = exclude(grid[i].values, toReadableValue(grid[found].values));
                if (countPossibleValues(grid[i].values) == 0) {
                    return -1;
                }
            }
        }
        /* current column */
        for (i = col(found); i < C_ROW * C_COL; i += C_COL) {
            if (i == found) {
                continue;
            }
            if (countPossibleValues(grid[i].values) > 0) {
                grid[i].values = exclude(grid[i].values, toReadableValue(grid[found].values));
                if (countPossibleValues(grid[i].values) == 0) {
                    return -1;
                }
            }
        }
        /* current block */
        for (i = blockHead(found); i < blockHead(found) + C_COL * C_BLK;
                i += C_COL) {
            for (j = 0; j < C_BLK; ++j) {
                if ((i + j) == found) {
                    continue;
                }
                if (countPossibleValues(grid[i + j].values) > 0) {
                    grid[i + j].values = exclude(grid[i + j].values, toReadableValue(grid[found].values));
                    if (countPossibleValues(grid[i + j].values) == 0) {
                        return -1;
                    }
                }
            }
        }
    }

    return -1;
}

void StandardSoduku::dumpGrid(Unit grid[])
{
    int i, j;
    fprintf(stderr, "987654321,987654321,987654321,987654321,987654321,"
            "987654321,987654321,987654321,987654321,\n");
    for (i = 0; i < C_UNIT; ++i) {
        if (grid[i].values < 0) {
            fprintf(stderr, "%9d", toReadableValue(grid[i].values));
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
