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
    SimpleList();

    bool empty();
    int size();
    Node *head();
    Node *tail();

    int push(Node *node);
    Node *pop();
    int remove(Node *node);
    int append(Node *node);

    int insertSorted(Node *node, Compare);

public:
    virtual void dump();

protected:
    int _insertAfter(Node *target, Node *node);
    int _insertBefore(Node *target, Node *node);

protected:
    Node _ahead;
    int _size;
};

inline bool SimpleList::empty()
{
    return _size == 0 ? true : false;
}

inline int SimpleList::size()
{
    return _size;
}

inline Node *SimpleList::head()
{
    return _ahead.next;
}

inline Node *SimpleList::tail()
{
    return _ahead.prev;
}

} // namespace sloth

#endif // SIMPLELIST_H
