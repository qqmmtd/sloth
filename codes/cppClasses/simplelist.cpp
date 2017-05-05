#include <iostream>
#include <iomanip>

#include "simplelist.h"

using namespace std;

namespace sloth
{

SimpleList::SimpleList()
{
    _ahead.prev = &_ahead;
    _ahead.next = &_ahead;
    _size = 0;
}

void SimpleList::dump()
{
    cerr << _size << endl;
    cerr << "            this            prev            next" << endl;
    Node *h = head();
    while (h != &_ahead) {
        cerr << setw(16) << h
             << setw(16) << h->prev
             << setw(16) << h->next
             << setw(16) << h->value
             << endl;
        h = h->next;
    }
    cerr << endl;
}

SimpleList &SimpleList::_insertAfter(Node *target, Node *node)
{
    node->prev = target;
    node->next = target->next;
    target->next->prev = node;
    target->next = node;
    ++_size;
    return *this;
}

SimpleList &SimpleList::_insertBefore(Node *target, Node *node)
{
    return _insertAfter(target->prev, node);
}

SimpleList &SimpleList::push(Node *node)
{
    return _insertBefore(head(), node);
}

Node *SimpleList::pop()
{
    Node *h = head();
    if (h != &_ahead) {
        _ahead.next = h->next;
        h->next->prev = h->prev;
        h->prev = nullptr;
        h->next = nullptr;
        --_size;
    }
    return nullptr;
}

SimpleList &SimpleList::remove(Node *node)
{
    node->prev->next = node->next;
    node->next->prev = node->prev;
    node->prev = nullptr;
    node->next = nullptr;
    --_size;
    return *this;
}

SimpleList &SimpleList::append(Node *node)
{
    return _insertAfter(tail(), node);
}

SimpleList &SimpleList::insertSorted(Node *node, Compare compare)
{
    if (!compare) {
        compare = SimpleList::gt;
    }
    Node *h = head();
    if (h != &_ahead) {
        if (compare(h, node) >= 0) {
            return _insertBefore(h, node);
        }
        h = h->next;
    }
    return append(node);
}

} // namespace sloth
