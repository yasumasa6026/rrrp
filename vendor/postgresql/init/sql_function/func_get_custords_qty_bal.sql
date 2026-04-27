 drop function public.func_get_custords_qty_bal cascade;
CREATE OR REPLACE FUNCTION public.func_get_custords_qty_bal(id numeric, OUT qty_bal numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN	
  EXECUTE 'select 	(max(ord.qty)  - sum(COALESCE(qty_src,0)))   qty_bal
 from custords ord
 left join linkcusts on ord.id = srctblid and (srctblname != tblname or srctblid != tblid)
	where  ord.id = $1 
	group by ord.id '
   INTO qty_bal
   USING  id;
END
$function$
;
