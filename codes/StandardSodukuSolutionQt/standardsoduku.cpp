#include <iostream>
#include <iomanip>

#include "standardsoduku.h"

using namespace std;

namespace sloth {

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
//    cerr << "\nTRY: " << setw(2) << mini << " (" << this->row(mini) << ", "
//         << this->col(mini) << ") = " << grid[mini].values << endl;

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
//        cerr << "FND: " << setw(2) << found << " (" << this->row(found) << ", "
//             << this->col(found) << ") = " << grid[found].values << endl;

        /* current row */
        for (i = row(found) * C_COLUMN; i < (row(found) + 1) * C_COLUMN; ++i) {
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
        for (i = col(found); i < C_ROW * C_COLUMN; i += C_COLUMN) {
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
        for (i = blockHead(found); i < blockHead(found) + C_COLUMN * C_BOX_ROW;
                i += C_COLUMN) {
            for (j = 0; j < C_BOX_ROW; ++j) {
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
    cerr << "987654321,987654321,987654321,987654321,987654321,"
            "987654321,987654321,987654321,987654321," << endl;
    for (i = 0; i < C_UNIT; ++i) {
        if (grid[i].values < 0) {
            cerr << setw(9) << toReadableValue(grid[i].values);
        } else {
            for (j = C_ROW - 1; j >= 0; --j) {
                cerr << setw(1) << (grid[i].values & (1 << j) ? 1 : 0);
            }
        }
        cerr << ",";
        if (!((i + 1) % C_ROW)) {
            cerr << endl;
        }
    }
    cerr << endl;
}


int StandardSoduku::excludeCandidates(Unit grid[])
{
    if (!grid) {
        cerr << "error: grid is null" << endl;
        return -1;
    }

    int i, j, found, c, minc, mini;
    while (1) {
        /* find a confirmed unit */
        found = this->C_UNIT;
        mini = this->C_UNIT;
        minc = this->C_ROW + 1;
        for (i = 0; i < this->C_UNIT; ++i) {
            c = countPossibleValues(grid[i].values);
            if (c == 0) {
                cerr << "warning: conflict in ("
                     << this->row(i) << ", " << this->col(i)
                     << ")"
                     << endl;
//                this->dumpGrid(grid);
                return -1;
            } else if (c == 1) {
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
        if (found == this->C_UNIT) {
            return mini;
        }
    }
}


} // namespace sloth
