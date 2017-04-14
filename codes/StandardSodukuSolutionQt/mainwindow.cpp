#include "mainwindow.h"
#include "ui_mainwindow.h"

#include "standardsoduku.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    /* fix window size */
    this->setFixedSize(this->width(), this->height());

    int i;
    for (i = 0; i < C_UNIT; ++i) {
        ui->tableWidget->setItem(StandardSoduku::row(i), StandardSoduku::col(i), new QTableWidgetItem());
        ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setTextAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
    }

#if 1
    int test[C_UNIT] = {
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
    for (i = 0; i < C_UNIT; ++i) {
        if (test[i] > 0) {
            ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setText(QString::number(test[i]));
        }
    }
#endif
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_pushButton_clicked()
{
    int i;
    int data[C_UNIT], solution[C_UNIT];

    for (i = 0; i < C_UNIT; ++i) {
        data[i] = ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->text().toInt();
    }

    StandardSoduku *ss = new StandardSoduku(data);
    if (0 == ss->solve(solution)) {
        for (i = 0; i < C_UNIT; ++i) {
            ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setText(
                        QString::number(solution[i]));
        }
    }
}

void MainWindow::on_pushButton_2_clicked()
{
    int i;
    for (i = 0; i < C_UNIT; ++i) {
        ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setText(NULL);
    }
}
