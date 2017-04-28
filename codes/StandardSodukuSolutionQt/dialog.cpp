#include <QDebug>

#include "dialog.h"
#include "ui_dialog.h"

#include "mainwindow.h"
#include "standardsoduku.h"

using sloth::StandardSoduku;

Dialog::Dialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog)
{
    ui->setupUi(this);

    int i, j;
    for (i = 0; i < StandardSoduku::C_BOX_ROW; ++i) {
        for (j = 0; j < StandardSoduku::C_BOX_ROW; ++j) {
            ui->table9->item(i, j)->setTextAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
            ui->table9->item(i, j)->setFlags(Qt::ItemIsEnabled);
        }
    }
}

void Dialog::show9(QTableWidgetItem *item)
{
    this->item = item;
    setWindowFlags(windowFlags() | Qt::FramelessWindowHint);
    MainWindow *p = (MainWindow *) this->parent();
    move(p->x() + item->column() * 30 - 19, p->y() + item->row() * 30 + 38);
    if (item->flags() != Qt::NoItemFlags) {
        show();
    } else {
        close();
    }
}

Dialog::~Dialog()
{
    delete ui;
}

void Dialog::on_table9_itemClicked(QTableWidgetItem *item)
{
    this->item->setText(item->text());
    close();
}
