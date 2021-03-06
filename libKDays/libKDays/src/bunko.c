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
        "name" : "厘瓜厂第屁撹鍛阻��",
        "introduce" : "絡母富定，嗤瀧勣廬秘阻匯侭煽雰啼消議兆壇寄弌純僥丕��",
        "spec" : "",
        "time" : "1370607945",
        "author" : "邦坪菊戦",
        "keyword" : "丕坩,禅握",
        "firstword" : "w",
        "updated" : "1373946951",
        "jpname" : "鯵ンタル!!レンタル槻徨はじめました",
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
                "name" : "及匯壌",
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
        "content" : " * 湘埖議及匯爺。"
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
                "name" : "厘議第第延撹17槙阻(厘議第第音辛嬬宸担辛握)",
                "introduce" : "夾翫臓雰��互嶄屈定雫僥伏。蝶匯爺貫僥丕指社議揃貧策隼囑欺阻匯倖音範紛議溺互嶄伏�� ＾臓 ..",
                "spec" : "",
                "time" : "1384486471",
                "author" : "埼念霜",
                "keyword" : "徴暫,窮似猟垂",
                "firstword" : "w",
                "updated" : "2013-11-15",
                "jpname" : "鯵のか�`ちゃんが17�rになった",
                "status" : "1",
                "words" : "110864",
                "apply" : "0",
                "origin" : "0",
                "illustration" : "パセリ",
                "zt" : "",
                "like_num" : "0",
                "newchapter" : "朔芝",
                "newchapterid" : "21039"
            },
            {
                "id":"69",
                "fav" : "1",
                "hit" : "4640",
                "name" : "厘議鍛鍛音辛嬬椎担辛握",
                "introduce" : "悟悟互梳奨初��17槙��才鍛鍛互梳幽痛��14槙��儘鍛曾繁議購狼除叱定侃噐絶媾彜蓑。貫蝶倖扮寂 ..",
                "spec" : "",
                "time" : "1355501852",
                "author" : "懸需望",
                "keyword" : "囮姙怛,強鮫晒,禅握,鍛,GAL,窮似猟垂",
                "firstword" : "w",
                "updated" : "2013-01-19",
                "jpname" : "鯵の鍛がこんなに辛�曚い錣韻�ない",
                "status" : "1",
                "words" : "1557670",
                "apply" : "0",
                "origin" : "0",
                "illustration" : "かんざきひろ",
                "zt" : "a:1:{s:1:\"c\",a:2:{i:0,s:1:\"1\",i:1,s:1:\"2\",}}",
                "like_num" : "0",
                "newchapter" : "朔芝",
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
                "name":"甚麗囂",
                "hit" : "1305",
                "id" : "4",
                "introduce" : "甚岻丕坩胡蝕僥音消祥哭栖阻稚劔廬丕伏"
            }
        ]
    }
    */
    return NULL;
}