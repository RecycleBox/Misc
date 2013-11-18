#ifndef _BUNKO_H_
#define _BUNKO_H_

#include "src\bunko_struct.h"

LPKDAYS_BOOK_INFO WINAPI kdays_get_book_info(
    _In_    HANDLE hKDays,
    _In_    INT bid
    );

LPKDAYS_BOOK_DIR WINAPI kdays_get_book_dir(
    _In_    HANDLE hKDays,
    _In_    INT bid
    );

LPKDAYS_BOOK_CONTENT WINAPI kdays_get_book_content(
    _In_    HANDLE hKDays,
    _In_    INT bid,
    _In_    INT cid
    );

LPKDAYS_BOOK_RESULT WINAPI kdays_search_book(
    _In_        HANDLE hKDays,
    _In_        LPCWSTR keyword,
    _In_opt_    INT spec,
    _In_opt_    INT status,
    _In_opt_    INT order
    );

LPKDAYS_BOOK_RESULT WINAPI kdays_get_top(
    _In_        HANDLE hKDays,
    _In_opt_    INT order
    );

#endif /* _BUNKO_H_ */