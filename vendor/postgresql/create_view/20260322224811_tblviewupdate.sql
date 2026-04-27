
 alter table shpacts  ADD COLUMN gno_shpord varchar(40);

 alter table  shpacts ALTER COLUMN qty_shortage  TYPE numeric(22,6) ;

 alter table  shpacts  ADD COLUMN masterprice numeric(38,4)  DEFAULT 0  not null;

 alter table  shpacts ALTER COLUMN qty_case  TYPE numeric(22,6) ;
