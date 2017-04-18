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
    StandardSoduku() { }
    StandardSoduku(const int data[]) { reset(data); }
    static int row(const int i) { return i / C_COL; }
    static int col(const int i) { return i % C_COL; }
    void reset(const int data[]) { memcpy(this->data, data, sizeof(this->data)); }
    int solve(int solution[]);

private:
    int bitcount(int v);
    int bit2num(int v);
    int num2bit(const int v) { return 1 << (v - 1); }
    int exclude(int v, const int e) { return v & ~(num2bit(e)) & V_ALL; }
    int pos(const int r, const int c) { return r * C_COL + c; }
    int blockHead(const int i) { return pos(row(i) / C_BLK * C_BLK, col(i) / C_BLK * C_BLK); }
    int toReadableValue(const int v) { return v < 0 ? -v : 0; }
    int countPossibleValues(const int v) { return v <= 0 ? 0 : bitcount(v); }
    int recursiveTryPossibleValues(Unit grid[]);
    int reducePossibleValues(Unit grid[]);
    void dumpGrid(Unit grid[]);

private:
    int data[C_UNIT];
};

/* bit count */
inline int StandardSoduku::bitcount(int v)
{
    int count;
    for (count = 0; v; ++count) {
        v &= v - 1;
    }
    return count;
}

inline int StandardSoduku::bit2num(int v)
{
    int i;
    for (i = 0; v; ++i) {
        v >>= 1;
    }
    return i;
}

#endif // STANDARDSODUKU_H
