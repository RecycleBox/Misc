#include "libKDays.h"

LPKDAYS_BOOK_INFO WINAPI kdays_get_book_info(
    _In_    HANDLE hKDays,
    _In_    int bid
    )
{
    /*
    http://xs.kdays.cn/api/get_book_info?apikey=hWxE7C1PrB6f4uAiAv&id=400
    {
        "id":"400",
        "fav" : "0",
        "hit" : "64",
        "name" : "我被姨妈整成妹了！",
        "introduce" : "晚熟少年·有马要转入了一所历史悠久的名门大小姐学校！",
        "spec" : "",
        "time" : "1370607945",
        "author" : "水内灯里",
        "keyword" : "校园,恋爱",
        "firstword" : "w",
        "updated" : "1373946951",
        "jpname" : "俺ンタル!!レンタル男子はじめました",
        "status" : "0",
        "words" : "83611",
        "apply" : "0",
        "origin" : "0",
        "illustration" : "へるるん",
        "zt" : "",
        "like_num" : "0",
        "code" : 200
    }
    */
    return NULL;
}

LPKDAYS_BOOK_DIR WINAPI kdays_get_book_dir(
    _In_    HANDLE hKDays,
    _In_    INT bid
    )
{
    /*
    http://xs.kdays.cn/api/get_book_dir?apikey=hWxE7C1PrB6f4uAiAv&id=400
    {
        "code":"200",
        "msg" : "ok",
        "root" :
        {
            "19498":
            {
                "uptime":"1373946649",
                "name" : "第一卷",
                "content" : "",
            }
        },
        "node" :
        {
            "19498":
            {
                "19499":
                {
                    "name":"Prologue",
                    "size" : "4534",
                    "subid" : "19498",
                }
            }
        }
    }
    */
    return NULL;
}

LPKDAYS_BOOK_CONTENT WINAPI kdays_get_book_content(
    _In_    HANDLE hKDays,
    _In_    INT bid,
    _In_    INT cid
    )
{
    /*
    http://xs.kdays.cn/api/get_book_content?apikey=hWxE7C1PrB6f4uAiAv&id=400&cid=19499
    {
        "code":"200",
        "msg" : "ok",
        "prev" : null,
        "next" : "19500",
        "subid" : "19498",
        "content" : " * 九月的第一天。"
    }
    */
    return NULL;
}

LPKDAYS_BOOK_RESULT WINAPI kdays_search_book(
    _In_        HANDLE hKDays,
    _In_        LPCWSTR keyword,
    _In_opt_    INT spec,
    _In_opt_    INT status,
    _In_opt_    INT order
    )
{
    /*
    http://xs.kdays.cn/api/search_book?apikey=hWxE7C1PrB6f4uAiAv&keyword=%E5%8F%AF%E7%88%B1
    {
        "code":"200",
        "msg" : "search ok",
        "length" : 2,
        "result" : 
        [
            {
                "id":"443",
                "fav" : "0",
                "hit" : "12",
                "name" : "我的妈妈变成17岁了(我的妈妈不可能这么可爱)",
                "introduce" : "泽村隆史，高中二年级学生。某一天从学校回家的路上忽然遇到了一个不认识的女高中生！ “隆 ..",
                "spec" : "",
                "time" : "1384486471",
                "author" : "弘前龙",
                "keyword" : "魔幻,电击文库",
                "firstword" : "w",
                "updated" : "2013-11-15",
                "jpname" : "俺のかーちゃんが17歳になった",
                "status" : "1",
                "words" : "110864",
                "apply" : "0",
                "origin" : "0",
                "illustration" : "パセリ",
                "zt" : "",
                "like_num" : "0",
                "newchapter" : "后记",
                "newchapterid" : "21039"
            },
            {
                "id":"69",
                "fav" : "1",
                "hit" : "4640",
                "name" : "我的妹妹不可能那么可爱",
                "introduce" : "哥哥高坂京介（17岁）和妹妹高坂桐乃（14岁）兄妹两人的关系近几年处于冷战状态。从某个时间 ..",
                "spec" : "",
                "time" : "1355501852",
                "author" : "伏见司",
                "keyword" : "御宅族,动画化,恋爱,妹,GAL,电击文库",
                "firstword" : "w",
                "updated" : "2013-01-19",
                "jpname" : "俺の妹がこんなに可愛いわけがない",
                "status" : "1",
                "words" : "1557670",
                "apply" : "0",
                "origin" : "0",
                "illustration" : "かんざきひろ",
                "zt" : "a:1:{s:1:\"c\",a:2:{i:0,s:1:\"1\",i:1,s:1:\"2\",}}",
                "like_num" : "0",
                "newchapter" : "后记",
                "newchapterid" : "15272"
            }
        ]
    }
    */
    return NULL;
}

LPKDAYS_BOOK_RESULT WINAPI kdays_get_top(
    _In_        HANDLE hKDays,
    _In_opt_    INT order
    )
{
    /*
    http://kdays.cn/apidocs/doku.php?id=wkapi:get_top
    {
        "code":"200",
        "msg" : "ok",
        "type" : "hits",
        "result" :
        [
            {
                "name":"坑物语",
                "hit" : "1305",
                "id" : "4",
                "introduce" : "坑之校园刚开学不久就迎来了谜样转校生"
            }
        ]
    }
    */
    return NULL;
}