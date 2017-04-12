#ifndef STANDARDSODUKUSOLUTION_H
#define STANDARDSODUKUSOLUTION_H

#define C_BLK           3
#define C_ROW           (C_BLK * C_BLK)             /* 9 */
#define C_COL           C_ROW
#define C_UNIT          (C_ROW * C_COL)             /* 81 */
#define V_ALL           ((1 << C_ROW) - 1)          /* 0x1FF, 111111111 */
#define DEL(_v)         (~(1 << ((_v) - 1)) & V_ALL)
#define ROW(_i)         ((_i) / C_COL)
#define COL(_i)         ((_i) % C_COL)
#define POS(_r, _c)     ((_r) * C_COL + (_c))
#define BLK_HEAD(_i)    (POS(ROW((_i)) / C_BLK * C_BLK, COL((_i)) / C_BLK * C_BLK))

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

struct Unit_t;
typedef struct Unit_t {
    int values;
    struct Unit_t *next;
} Unit;


class StandardSodukuSolution
{
public:
    StandardSodukuSolution();
    static int recursiveTryPossibleValues(Unit grid[]);
    static void dumpGrid(Unit grid[]);
    static int toReadableValue(Unit grid[], int idx);

private:
    static inline int bitcount(int v);
    static inline int bit2num(int v);
    static int countPossibleValues(Unit grid[], int idx);
    static int reducePossibleValues(Unit grid[]);
};

#endif // STANDARDSODUKUSOLUTION_H
