#ifndef _BUNKO_STRUCT_H_
#define _BUNKO_STRUCT_H_

typedef struct
{
    INT id;
    INT hit;
    LPWSTR name;
    INT name_size;
    LPWSTR INTroduce;
    INT INTroduct_size;
    LPWSTR spec;
    INT spec_size;
    INT time;
    LPWSTR author;
    INT author_size;
    LPWSTR keyword;
    INT keyword_size;
    LPWSTR firstword;
    INT firstword_size;
    INT updated;
    LPWSTR jpname;
    INT jpname_size;
    INT status;
    INT words;
    BOOL apply;
    BOOL origin;
    LPWSTR illustration;
    INT illustration_size;
    INT like_num;
} KDAYS_BOOK_INFO, *LPKDAYS_BOOK_INFO;

typedef struct _KDAYS_BOOK_DIR_NODE KDAYS_BOOK_DIR_NODE, *LPKDAYS_BOOK_DIR_NODE;

typedef struct
{
    INT root_id;
    INT uptime;
    LPWSTR name;
    INT name_size;
    LPWSTR content;
    INT content_size;
    LPKDAYS_BOOK_DIR_NODE node;
} KDAYS_BOOK_DIR_ROOT, *LPKDAYS_BOOK_DIR_ROOT;

struct _KDAYS_BOOK_DIR_NODE
{
    INT node_id;
    LPWSTR name;
    INT name_size;
    INT size;
    INT subid;
    LPKDAYS_BOOK_DIR_ROOT root;
};

typedef struct
{
    LPKDAYS_BOOK_DIR_ROOT root;
    LPKDAYS_BOOK_DIR_NODE node;
} KDAYS_BOOK_DIR, *LPKDAYS_BOOK_DIR;

typedef struct
{
    INT prev;
    INT next;
    INT subid;
    LPWSTR content;
    INT content_size;
} KDAYS_BOOK_CONTENT, *LPKDAYS_BOOK_CONTENT;


#define KDAYS_RESULT_DEFAULT            -1

#define KDAYS_RESULT_SPEC_KEYWORD       0
#define KDAYS_RESULT_SPEC_AUTHOR        1

#define KDAYS_RESULT_STATUS_END         0
#define KDAYS_RESULT_STATUS_CONTINUE    1
#define KDAYS_RESULT_STATUS_STOP        2

#define KDAYS_RESULT_ORDER_UPDATED      0
#define KDAYS_RESULT_ORDER_HIT          1
#define KDAYS_RESULT_ORDER_FAV          2
#define KDAYS_RESULT_ORDER_WORDS        3

#define KDAYS_RESULT_ORDER_UPDATE_BOOK  0
#define KDAYS_RESULT_ORDER_LIKE_NUM     1
//      KDAYS_RESULT_ORDER_FAV          2
#define KDAYS_RESULT_ORDER_ADDTIME      3
typedef struct
{
    INT length;
    LPKDAYS_BOOK_INFO result;
} KDAYS_BOOK_RESULT, *LPKDAYS_BOOK_RESULT;

#endif /* _BUNKO_STRUCT_H_ */