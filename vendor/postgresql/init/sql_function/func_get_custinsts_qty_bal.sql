 drop function public.func_get_custinsts_qty_bal cascade;
CREATE OR REPLACE FUNCTION public.func_get_custinsts_qty_bal(id numeric, OUT qty_bal numeric)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN	
  EXECUTE 'select 	(max(COALESCE(inst.qty,0))  - sum(COALESCE(qty_src,0)))  qty_bal
 from linkcusts
 inner join custinsts inst on inst.id = srctblid
	where  srctblid = $1 and (srctblname != tblname or srctblid != tblid)
	group by srctblname,srctblid '
   INTO qty_bal
   USING  id;
END
$function$
;
