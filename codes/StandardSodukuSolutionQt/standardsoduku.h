#ifndef STANDARDSODUKU_H
#define STANDARDSODUKU_H

#define C_BLK           3
#define C_ROW           (C_BLK * C_BLK)             /* 9 */
#define C_COL           C_ROW
#define C_UNIT          (C_ROW * C_COL)             /* 81 */
#define V_ALL           ((1 << C_ROW) - 1)          /* 0x1FF, 111111111 */

struct Unit_t;
typedef struct Unit_t {
    int values;
    struct Unit_t *next;    /* now unused */
} Unit;

class StandardSoduku
{
public:
    StandardSoduku();
    StandardSoduku(const int data[]);
    static inline int bitcount(int v);
    static inline int bit2num(int v);
    static inline int num2bit(const int v) { return 1 << (v - 1); }
    static inline int exclude(int v, const int e) { return v & ~(num2bit(e)) & V_ALL; }
    static inline int row(const int i) { return i / C_COL; }
    static inline int col(const int i) { return i % C_COL; }
    static inline int pos(const int r, const int c) { return r * C_COL + c; }
    static inline int blockHead(const int i) { return pos(row(i) / C_BLK * C_BLK, col(i) / C_BLK * C_BLK); }
    void reset(const int data[]);
    int solve(int solution[]);

private:
    static inline int toReadableValue(const int v) { return v < 0 ? -v : 0; }
    static inline int countPossibleValues(const int v) { return v <= 0 ? 0 : bitcount(v); }
    int recursiveTryPossibleValues(Unit grid[]);
    int reducePossibleValues(Unit grid[]);
    void dumpGrid(Unit grid[]);

private:
    int data[C_UNIT];
};

#endif // STANDARDSODUKU_H
