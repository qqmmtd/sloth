#ifndef STANDARDSODUKU_H
#define STANDARDSODUKU_H

#include <cstring>

namespace sloth {

class StandardSoduku
{
    typedef struct Unit_t {
        int values;
    } Unit;

public:
    static const int C_BOX_ROW = 3;
    static const int C_BOX_COLUMN = 3;
    static const int C_ROW = C_BOX_ROW * C_BOX_COLUMN;
    static const int C_COLUMN = C_ROW;
    static const int C_UNIT = C_ROW * C_COLUMN;
    static const int V_ALL = (1 << C_ROW) - 1;

public:
    StandardSoduku() { }
    StandardSoduku(const int data[]) { reset(data); }
    static int row(const int i) { return i / C_COLUMN; }
    static int col(const int i) { return i % C_COLUMN; }
    void reset(const int data[]) { memcpy(this->data, data, sizeof(this->data)); }
    int solve(int solution[]);

private:
    int bitcount(int v);
    int bit2num(int v);
    int num2bit(const int v) { return 1 << (v - 1); }
    int exclude(int v, const int e) { return v & ~(num2bit(e)) & V_ALL; }
    int pos(const int r, const int c) { return r * C_COLUMN + c; }
    int blockHead(const int i) { return pos(row(i) / C_BOX_ROW * C_BOX_ROW, col(i) / C_BOX_ROW * C_BOX_ROW); }
    int toReadableValue(const int v) { return v < 0 ? -v : 0; }
    int countPossibleValues(const int v) { return v <= 0 ? 0 : bitcount(v); }
    int recursiveTryPossibleValues(Unit grid[]);
    int reducePossibleValues(Unit grid[]);
    void dumpGrid(Unit grid[]);

    int excludeCandidates(Unit grid[]);

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

} // namespace sloth

#endif // STANDARDSODUKU_H
