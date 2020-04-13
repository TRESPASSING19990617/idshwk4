type idRecord :record{
     num :double;
     sum :double;
     all :double;
     url :set[string];
};
global tim1 :time=network_time();
global idTable :table[addr] of idRecord = table();
event http_reply (c: connection, version: string, code: count, reason: string)
{
local tim2 :time=network_time();
local a:addr=c$id$orig_h;
if(code==404)
{
    if(a in idTable)
    {
        idTable[a]$sum += 1;
        idTable[a]$all += 1;
        if(to_lower(c$http$uri) in idTable[a]$url)
        {}
        else
        {
           add idTable[a]$url[to_lower(c$http$uri)];
           idTable[a]$num += 1;
        }
    }
    else
    {
        idTable[a]=record($num=1,$sum=1,$all=1,$url=set(to_lower(c$http$uri)));
    }
}
else
{
    if(a in idTable)
    {
        idTable[a]$all += 1;
    }
    else
    {
        idTable[a]=record($num=0,$sum=0,$all=1,$url=set(" "));
    }
}
if((tim2-tim1)>=10 min)
{
   tim1=tim2;
   for(key in idTable)
   {
      if(idTable[key]$sum>2)
      {
         if((idTable[key]$sum/idTable[key]$all)>0.2)
         {
            if((idTable[key]$num/idTable[key]$sum)>0.5)
            {
               print fmt("%s is a scanner with %d scan attempts on %d urls",key,idTable[key]$sum,idTable[key]$num);
            }
         }  
      }
   }  
}
}
