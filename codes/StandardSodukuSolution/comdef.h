/*
 * comdef.h
 *
 *  Created on: Apr 10, 2017
 *      Author: zhanghe
 */

#ifndef COMDEF_H_
#define COMDEF_H_


#define N_BLK           3
#define N_ROW           (N_BLK * N_BLK)             /* 9 */
#define N_COL           N_ROW
#define V_ALL           ((1 << N_ROW) - 1)          /* 0x1FF, 111111111 */
#define DEL(_v)         (~(1 << (-1 - (_v))) & V_ALL)
#define ROW(_i)         ((_i) / N_COL)
#define COL(_i)         ((_i) % N_COL)
#define POS(_r, _c)     ((_r) * N_COL + (_c))


int fillGrid(int grid[]);


#endif /* COMDEF_H_ */
