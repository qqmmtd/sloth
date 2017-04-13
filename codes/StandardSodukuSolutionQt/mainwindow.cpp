#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    /* fix window size */
    this->setFixedSize(this->width(), this->height());

    int orig[C_UNIT] = {
#if 0 /* easy */
        5, 3, 0, 0, 7, 0, 0, 0, 0,
        6, 0, 0, 1, 9, 5, 0, 0, 0,
        0, 9, 8, 0, 0, 0, 0, 6, 0,
        8, 0, 0, 0, 6, 0, 0, 0, 3,
        4, 0, 0, 8, 0, 3, 0, 0, 1,
        7, 0, 0, 0, 2, 0, 0, 0, 6,
        0, 6, 0, 0, 0, 0, 2, 8, 0,
        0, 0, 0, 4, 1, 9, 0, 0, 5,
        0, 0, 0, 0, 8, 0, 0, 7, 9,
#else /* hard */
        8, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 3, 6, 0, 0, 0, 0, 0,
        0, 7, 0, 0, 9, 0, 2, 0, 0,
        0, 5, 0, 0, 0, 7, 0, 0, 0,
        0, 0, 0, 0, 4, 5, 7, 0, 0,
        0, 0, 0, 1, 0, 0, 0, 3, 0,
        0, 0, 1, 0, 0, 0, 0, 6, 8,
        0, 0, 8, 5, 0, 0, 0, 1, 0,
        0, 9, 0, 0, 0, 0, 4, 0, 0,
#endif
};
    int i;
    for (i = 0; i < C_UNIT; ++i) {
        ui->tableWidget->setItem(ROW(i), COL(i), new QTableWidgetItem());
        ui->tableWidget->item(ROW(i), COL(i))->setTextAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
        if (orig[i] > 0) {
            ui->tableWidget->item(ROW(i), COL(i))->setText(QString::number(orig[i]));
        }
    }
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_pushButton_clicked()
{
    int i, v;
    /* format values */
    for (i = 0; i < C_UNIT; ++i) {
        v = ui->tableWidget->item(ROW(i), COL(i))->text().toInt();
        if (v > 0) {
            this->grid[i].values = 1 << (v - 1);
        } else {
            this->grid[i].values = V_ALL;
        }
    }
    StandardSodukuSolution::dumpGrid(this->grid);

    /* try */
    if (0 == StandardSodukuSolution::recursiveTryPossibleValues(this->grid)) {
        for (i = 0; i < C_UNIT; ++i) {
            ui->tableWidget->item(ROW(i), COL(i))->setText(
                        QString::number(StandardSodukuSolution::toReadableValue(this->grid, i)));
        }
    }
}

void MainWindow::on_pushButton_2_clicked()
{
    int i;
    for (i = 0; i < C_UNIT; ++i) {
        ui->tableWidget->item(ROW(i), COL(i))->setText(NULL);
    }
}
