#!/bin/bash
#Обрабатывает все лежащие пиьсма в определнном ящике и создает таблицу полученных писем для учета посещаемости
dir=/home/otowt/Maildir/cur/
out=/var/www/vhost/dir.vesy.com.ua/check.html
DATE=`date "+%F %H:%M:%S"`
> $out
echo "<HTML> <head><META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=utf-8\">
<META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\">
<META HTTP-EQUIV=\"Cache-Control\" content=\"no-cache\">
<META HTTP-EQUIV=\"Expires\" CONTENT=\"Wed, 20 Feb 2000 08:00:18 GMT\">
<META HTTP-EQUIV=\"Date\" CONTENT=\"Wed, 20 Feb 2000 08:00:18 GMT\">

<TITLE>Checklist</TITLE>
</head>
Generated at $DATE <br>
" >> $out
for i in $(ls $dir)
    do    
    cat $dir/$i | awk '/Date: /{print $3" " $4" " $5" " $6}' | tr -d ,|tr '\n' , >> $out # Печать даты письма без лишних запятых и с пробелами
    cat $dir/$i | awk '/Return-Path: /{print $2}'| tr '\n' , | tr -d "<" | tr -d ">" >> $out #Имя отправителя
    cat $dir/$i | awk '/Subject: /{print $0}'| awk '/Subject: /{print $0}'| sed s/.*B?//g | sed s/?=//g | base64 -d  >> $out #Выделение темы письма и декодирование русских тем из bas64
    echo "<br>" >> $out
    echo -e  >> $out
done
echo "</HTML>" >> $out

