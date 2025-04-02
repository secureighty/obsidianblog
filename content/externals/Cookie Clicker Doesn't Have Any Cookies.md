// This is an educational blogpost I wrote in 2022 for a college organization that got dropped with a restructure

I was watching someone play Cookie Clicker and when they reloaded the tab, they still had all their save data. I’d never played Cookie Clicker before so I assumed it must be using cookies to retain that data, but when I loaded a Cookie Clicker tab on my browser, Firefox reported no cookies beyond the consent to store advertising cookies (Thanks for blocking trackers, Firefox).

![](https://web.archive.org/web/20221208201251im_/https://lh3.googleusercontent.com/G_8ohjCJSIxWmzfoDhcbSYFiztabUIwiPyioqq6wB4d4BDPDB_12JIZP-z7cARnMJkOhFfS5S7UEKSIbvzgxAbBunCEg41e-D2cW3wdXMpZdXEvVuE0HhkDVaKRpWcdDeIg_opUeJ_N0M2Xh_IWrdquZww_y8Ggcgt_1XSAM5NNyVDuHw9nwvaRwFgOc0w)

So, what does Cookie Clicker use to store data? Browsers can store data in a few ways.

![](https://web.archive.org/web/20221208201251im_/https://lh3.googleusercontent.com/Y4Y7e2eucLfHrWGndvZ3D122dFrqvX9avG4-9mtyGGzQIfQI7kRsXO14sC6xXxPDQIwQjL0G1oeIkKn8PvogGo82CRfdOYPMJMjK6GXJ0A353-uuNRA9b9onXK5cD9FILruv3KYFwOT-cLdNIWveJOv2AS0bqjkh-bmmL2jIUd7-Qor5deJSoB0aC-n5Bw)

**Cache storage** is for storing responses to network queries. When a query is made, it’s stored as a request/response pair, and when that same query is to be made again, if it matches any cached queries, the browser can save on network usage by taking a cached response. Since Cookie Clicker is pretty much a local app once you load the page, this is probably not how it works.

**Cookies** are values passed and passed back in HTTP requests with the Set-Cookie header. They can either be for the duration of a session (i.e. deleted when the browser is closed) or persistent (expiring at a set time). Cookies must expire as per RFC 2965. Since we don’t want our Cookie Clicker cookie count expiring, this is probably a bad idea.

**Indexed DB** storage is storage of key:value pairs in a browser database. Webapps can interface with a created Indexed DB to retrieve this data. It could work for Cookie Clicker, but it’d be pretty complicated.

**Local Storage** is also storage of key:value pairs but doesn’t require the same code steps of spinning up a database and is generally much less complicated. This could also work for Cookie Clicker.

**Session Storage** is the same as local storage, except it has the same drawback of cookies in that it must eventually expire. This would not work for Cookie Clicker.

Our most likely candidate based on these types of storage is Local Storage. Opening the Local Storage tab shows us 2 values: CookieClickerGame and CookieClickerLang.

![](https://web.archive.org/web/20221208201251im_/https://lh5.googleusercontent.com/0sIUbdk4GWqpQvSQq05vMDtJA6Y2d7JKEUH1lJxQdQcI89AqixuipfhUbZuJ69_2d8k5yi6xAOFI14usEIMM56IqG9dnQNbZiStqQ1-bD6Rv1jtHL8mT_ys1lJ6ikCOFkrCt1MXhugWPpCL1Bi3nRPkQVPrVMlaT62NA_jLwhEoG6TyAD01eLVmarXMb9A)

CookieClickerGame looks interesting. If we didn’t know what that was, we could feed it into Cyberchef magic, but most webapps store this kind of data as base64, so we’ll skip this step and feed it into a decoder directly.

![](https://web.archive.org/web/20221208201251im_/https://lh6.googleusercontent.com/uwRFby6XF52NSYu0c6IC72hwpFa8PVdkURxqoyij4zsCy4kBOAtunrsgVjFzVVLotqVNUsiPY3r96SocM7Gp0M7ixbfwfjjXWiPMDLMPAyQpo9XWn-gY9e_5lFdtzPohXzlCsnLDU5sMdgLf4N8GIwSU-YRnkFuki58Z_Hllm0mtNZgEFtx5o5IcIND8EQ)

And it appears that Cookie Clicker saves data as a base64 encoded semicolon, comma, and pipe delimited list. Probably a little jankier than it could have been if it used an Indexed DB, but it works and I’m not going to take the time to rewrite it. Anyway, now that we have this, if we know that we have exactly 42 cookies, with very little effort, we can change every instance of 42 to a very large number, re-encode the list, and feed it back into Firefox’s Local Storage.

![](https://web.archive.org/web/20221208201251im_/https://lh4.googleusercontent.com/YUPsFAc_QE9psn0Hwzji1GDuRPA0z6u_isIfN1RMhPixrL_7C6QgYKJWjYy4q7QfG-9z2wELceyQ7JfmHfGVuNitT9VwtGhFi4qFwcTvi4O-2yKQw8kogls0T-RftI0YQUz_QZJAIEe7z55rs0rox2zZiMYGk_e0x_50XsoUA8KhFqDwN7Z7B6TuGucCjA)

![](https://web.archive.org/web/20221208201251im_/https://lh6.googleusercontent.com/PZODk_N7FK9mV2VavWv-LtHGD9B0uN6SGSBkYszzYoVsSutvPSmCZJYgzyLO4q4mjlj4u0WXtT7NeFP9Ace_s5875cETnmYMr7SVP-NvZy9XP5ExtFgL7E3IMSOweQbjmqR9fEAFrY8Q35PODRe2m6QPPjGqjELaSgEscryfYLmpnphnUduji7gvHNAgQQ)

![](https://web.archive.org/web/20221208201251im_/https://lh4.googleusercontent.com/xwRWrChVcrVgnhZ97yyHiC6YlN1_2hfZ9E-JACSVUDdc8N9DBSFMXQBGF7ojv3CeixU-ch2tKBpPFtru__ryEu10jn8TcRc1qbe-aCiUf4jl1UNWsZJYu8ROJVNZvywd1YWY5dp2eELDIYeXUpFa65TXqCmVIcgGUV_VOw62G9kxzzT8Mwm69WBJQFdMWA)

PS.  
No XSS on bakery name. The characters are stored in the save file but sanitized in the UI.

_Sources:_

[_https://betterprogramming.pub/the-different-types-of-browser-storage-82b918cb3cf8_](https://web.archive.org/web/20221208201251/https://betterprogramming.pub/the-different-types-of-browser-storage-82b918cb3cf8)

[_https://www.geeksforgeeks.org/how-to-set-up-a-cookie-that-never-expires-in-javascript/_](https://web.archive.org/web/20221208201251/https://www.geeksforgeeks.org/how-to-set-up-a-cookie-that-never-expires-in-javascript/)

[_http://www.faqs.org/rfcs/rfc2965.html_](https://web.archive.org/web/20221208201251/http://www.faqs.org/rfcs/rfc2965.html)

[_https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API/Using_IndexedDB_](https://web.archive.org/web/20221208201251/https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API/Using_IndexedDB)

And of course,

[_https://orteil.dashnet.org/cookieclicker/_](https://web.archive.org/web/20221208201251/https://orteil.dashnet.org/cookieclicker/)