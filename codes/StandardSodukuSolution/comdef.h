/*
 * comdef.h
 *
 *  Created on: Apr 10, 2017
 *      Author: zhanghe
 */

#ifndef COMDEF_H_
#define COMDEF_H_


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

/**
 * Recursive to try possible values until all confirmed or error
 *
 * @param
 *      grid    Sudoku grid
 *
 * @return
 *      0 on all units confirmed
 *      -1 on error
 */
int fillGrid(int orig[]);


#endif /* COMDEF_H_ */
