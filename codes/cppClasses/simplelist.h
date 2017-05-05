#ifndef SIMPLELIST_H
#define SIMPLELIST_H


namespace sloth
{

struct Node
{
    Node *prev;
    Node *next;

    int value;

    inline bool operator==(const Node *node)
    {
        return value == node->value;
    }
};

typedef int (*Compare)(Node *, Node *);

template <typename _T>
bool eq(_T &a, _T &b)
{
    return a == b;
}

class SimpleList
{
public:
    explicit SimpleList();

    static int gt(Node *a, Node *b)
    {
        return a->value - b->value;
    }

    bool empty() const
    {
        return _size == 0 ? true : false;
    }

    int size() const
    {
        return _size;
    }

    Node *head()
    {
        return _ahead.next;
    }

    Node *tail()
    {
        return _ahead.prev;
    }

    SimpleList &push(Node *node);
    Node *pop();
    SimpleList &remove(Node *node);
    SimpleList &append(Node *node);

    SimpleList &insertSorted(Node *node, Compare);

public:
    virtual void dump();

protected:
    SimpleList &_insertAfter(Node *target, Node *node);
    SimpleList &_insertBefore(Node *target, Node *node);

protected:
    Node _ahead;
    int _size;
};

} // namespace sloth

#endif // SIMPLELIST_H
