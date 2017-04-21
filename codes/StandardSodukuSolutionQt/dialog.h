#ifndef DIALOG_H
#define DIALOG_H

#include <QDialog>
#include <QtWidgets/QTableWidgetItem>

namespace Ui {
class Dialog;
}

class Dialog : public QDialog
{
    Q_OBJECT

public:
    explicit Dialog(QWidget *parent = 0);
    ~Dialog();

public slots:
    void show9(QTableWidgetItem *item);

private slots:
    void on_table9_itemClicked(QTableWidgetItem *item);

private:
    Ui::Dialog *ui;
    QTableWidgetItem *item;
};

#endif // DIALOG_H
