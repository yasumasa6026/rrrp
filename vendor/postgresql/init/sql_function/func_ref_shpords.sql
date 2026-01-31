
--- file = func_ref_shpords
drop function if exists public.ref_shpords(paretblnameOrg regclass,paretblidOrg numeric);
CREATE OR REPLACE FUNCTION public.ref_shpords(paretblnameOrg regclass,paretblidOrg numeric)
 RETURNS TABLE(id numeric,shpord_id numeric,
				shpord_paretblname character varying,shpord_paretblid numeric,
 				itm_code character varying,itm_name  character varying,shpord_processseq numeric,
 				shpord_isudate timestamp,shpord_depdate timestamp,shpord_duedate timestamp,
 				shpord_qty  numeric,shpord_qty_shortage  numeric,
 				shpinst_depdate timestamp,shpinst_qty_stk numeric,shpact_rcptdate timestamp,
				loca_code_shelfno_fm character varying,loca_name_shelfno_fm character varying,shelfno_code_fm character varying,shelfno_name_fm character varying,
				loca_code_shelfno_to character varying,loca_name_shelfno_to character varying,shelfno_code_to character varying,shelfno_name_to character varying,
 				shpord_created_at timestamp,shpord_updated_at timestamp,shpord_update_ip character varying,
				person_code_upd character varying,person_name_upd character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
	 EXECUTE '
				select shp.id id,shp.shpord_id,
					shp.paretblname shpord_paretblname,shp.paretblid shpord_paretblid,
					shp.itm_code,shp.itm_name ,shp.shpord_processseq,
					shp.shpord_isudate,shp.shpord_depdate ,shp.shpord_duedate ,
					shp.shpord_qty ,shp.shpord_qty_shortage ,
					shp.shpinst_depdate ,shp.shpinst_qty_stk,shp.shpact_rcptdate ,
					shp.loca_code_shelfno_fm,shp.loca_name_shelfno_fm,shp.shelfno_code_fm,shp.shelfno_name_fm,
					shp.loca_code_shelfno_to,shp.loca_name_shelfno_to,shp.shelfno_code_to,shp.shelfno_name_to,
					shp.shpord_created_at,shp.shpord_updated_at,shp.shpord_update_ip,
					shp. person_code_upd,shp.person_name_upd
					from '|| paretblnameOrg::regclass ||' p
					inner join (select so.id id,so.id shpord_id, so.created_at shpord_created_at,so.updated_at shpord_updated_at,so.update_ip shpord_update_ip,
							so.paretblname,so.paretblid,
							i.code itm_code,i.name itm_name ,so.processseq shpord_processseq,
							so.isudate shpord_isudate,so.depdate shpord_depdate ,so.duedate shpord_duedate ,
							so.qty shpord_qty ,so.qty_shortage shpord_qty_shortage ,
							si.depdate shpinst_depdate ,si.qty_stk shpinst_qty_stk,sa.rcptdate shpact_rcptdate,
							fms.loca_code_shelfno loca_code_shelfno_fm,fms.loca_name_shelfno loca_name_shelfno_fm,fms.shelfno_code shelfno_code_fm,fms.shelfno_name shelfno_name_fm,
							tos.loca_code_shelfno loca_code_shelfno_to,tos.loca_name_shelfno loca_name_shelfno_to,tos.shelfno_code shelfno_code_to,tos.shelfno_name shelfno_name_to,
							person.code person_code_upd,person.name person_name_upd
							from shpords so
							inner join itms i on i.id = so.itms_id
							inner join r_shelfnos fms on fms.id = so.shelfnos_id_fm
							inner join r_shelfnos tos on tos.id = so.shelfnos_id_to
							inner join persons person on person.id = so.persons_id_upd  									
							left join shpinsts si on si.itms_id = so.itms_id and si.processseq = so.processseq and si.paretblname = so.paretblname  and si.paretblid = so.paretblid  
							left join shpinsts sa on sa.itms_id = so.itms_id and sa.processseq = so.processseq and sa.paretblname = so.paretblname  and sa.paretblid = so.paretblid
							where so.paretblid  = $1
							) shp on shp.paretblid = p.id
					where p.id = $1 
					order by p.id,shp.itm_code '             
using paretblidOrg ;
END
$function$
;

 DROP TABLE IF EXISTS sio.sio_ref_shpords;
 CREATE TABLE sio.sio_ref_shpords (
          sio_id numeric(22,0)  CONSTRAINT sio_ref_shpords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
          ,sio_Term_id varchar(30)
          ,sio_session_id numeric(22,0)
          ,sio_Command_Response char(1)
          ,sio_session_counter numeric(22,0)
          ,sio_classname varchar(50)
          ,sio_viewname varchar(30)
          ,sio_code varchar(30)
          ,sio_strsql varchar(4000)
          ,sio_totalcount numeric(22,0)
          ,sio_recordcount numeric(22,0)
          ,sio_start_record numeric(22,0)
          ,sio_end_record numeric(22,0)
          ,sio_sord varchar(256)
          ,sio_search varchar(10)
          ,sio_sidx varchar(256)
,id  numeric (38,0)
,shpord_id  numeric (38,0)
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,shpord_isuedate   timestamp(6) 
,shpord_duedate   timestamp(6) 
,shpord_qty  numeric (18,4)
,shpinst_depdate   timestamp(6) 
,shpinst_qty_stk  numeric (18,4)
,shpact_rcptdate   timestamp(6) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,loca_code_shelfno_fm varchar (50) 
,loca_name_shelfno_fm varchar (100)
,shelfno_code_fm varchar (50) 
,shelfno_name_fm varchar (100)
,loca_code_shelfno_to varchar (50) 
,loca_name_shelfno_to varchar (100)
,shelfno_code_to varchar (50) 
,shelfno_name_to varchar (100)
,shpord_update_ip  varchar (40) 
,shpord_created_at   timestamp(6) 
,shpord_updated_at   timestamp(6) 
          ,sio_errline varchar(4000)
          ,sio_org_tblname varchar(30)
          ,sio_org_tblid numeric(22,0)
          ,sio_add_time date
          ,sio_replay_time date
          ,sio_result_f char(1)
          ,sio_message_code char(10)
          ,sio_message_contents varchar(4000)
          ,sio_chk_done char(1)
);
 CREATE INDEX sio_ref_shpords_uk1 
  ON sio.sio_ref_shpords(id,sio_id); 

 drop sequence  if exists sio.sio_ref_shpords_seq ;
 create sequence sio.sio_ref_shpords_seq ;

