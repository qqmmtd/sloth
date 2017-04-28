#include <QtDebug>

#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "dialog.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow), ss(new StandardSoduku())
{
    ui->setupUi(this);

    this->d = new Dialog(this);
    connect(ui->tableWidget, &QTableWidget::itemClicked, this->d, &Dialog::show9);

    int i;
    for (i = 0; i < StandardSoduku::C_UNIT; ++i) {
        ui->tableWidget->setItem(StandardSoduku::row(i), StandardSoduku::col(i), new QTableWidgetItem());
        ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setTextAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
        ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setFlags(Qt::ItemIsEnabled);
    }

#if 1
    int test[StandardSoduku::C_UNIT] = {
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
    for (i = 0; i < StandardSoduku::C_UNIT; ++i) {
        if (test[i] > 0) {
            ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setText(QString::number(test[i]));
            ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setFlags(Qt::NoItemFlags);
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
    int data[StandardSoduku::C_UNIT], solution[StandardSoduku::C_UNIT];

    for (i = 0; i < StandardSoduku::C_UNIT; ++i) {
        data[i] = ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->text().toInt();
    }

    this->ss->reset(data);
    if (0 == this->ss->solve(solution)) {
        for (i = 0; i < StandardSoduku::C_UNIT; ++i) {
            ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setText(
                        QString::number(solution[i]));
        }
    }
}

void MainWindow::on_pushButton_2_clicked()
{
    int i;
    for (i = 0; i < StandardSoduku::C_UNIT; ++i) {
        ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setFlags(Qt::ItemIsEnabled);
        ui->tableWidget->item(StandardSoduku::row(i), StandardSoduku::col(i))->setText(NULL);
    }
}
