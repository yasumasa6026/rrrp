
--- file = func_ref_shpdlvs
drop function if exists public.ref_shpdlvs(paretblnameOrg regclass,paretblidOrg numeric);
CREATE OR REPLACE FUNCTION public.ref_shpdlvs(paretblnameOrg regclass,paretblidOrg numeric)
 RETURNS TABLE(id numeric,shpdlv_id numeric,
				shpdlv_paretblname character varying,shpdlv_paretblid numeric,
 				itm_code character varying,itm_name  character varying,shpdlv_processseq numeric,
 				shpdlv_isudate timestamp,shpdlv_depdate timestamp,
 				shpdlv_qty_shortage  numeric,
 				shpdlv_qty_stk numeric,
				loca_code_shelfno_fm character varying,loca_name_shelfno_fm character varying,shelfno_code_fm character varying,shelfno_name_fm character varying,
				loca_code_shelfno_to character varying,loca_name_shelfno_to character varying,shelfno_code_to character varying,shelfno_name_to character varying,
 				shpdlv_created_at timestamp,shpdlv_updated_at timestamp,shpdlv_update_ip character varying,
				person_code_upd character varying,person_name_upd character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
	 EXECUTE '
				select shp.id id,shp.shpdlv_id,
					shp.paretblname shpdlv_paretblname,shp.paretblid shpdlv_paretblid,
					shp.itm_code,shp.itm_name ,shp.shpdlv_processseq,
					shp.shpdlv_isudate,shp.shpdlv_depdate ,
					shp.shpdlv_qty_shortage ,
					shp.shpdlv_qty_stk,
					shp.loca_code_shelfno_fm,shp.loca_name_shelfno_fm,shp.shelfno_code_fm,shp.shelfno_name_fm,
					shp.loca_code_shelfno_to,shp.loca_name_shelfno_to,shp.shelfno_code_to,shp.shelfno_name_to,
					shp.shpdlv_created_at,shp.shpdlv_updated_at,shp.shpdlv_update_ip,
					shp. person_code_upd,shp.person_name_upd
					from '|| paretblnameOrg::regclass ||' p
					inner join (select so.id id,so.id shpdlv_id, so.created_at shpdlv_created_at,so.updated_at shpdlv_updated_at,so.update_ip shpdlv_update_ip,
							so.paretblname,so.paretblid,
							i.code itm_code,i.name itm_name ,so.processseq shpdlv_processseq,
							so.isudate shpdlv_isudate,so.depdate shpdlv_depdate ,
							so.qty_stk shpdlv_qty_stk ,so.qty_shortage shpdlv_qty_shortage ,
							fms.loca_code_shelfno loca_code_shelfno_fm,fms.loca_name_shelfno loca_name_shelfno_fm,fms.shelfno_code shelfno_code_fm,fms.shelfno_name shelfno_name_fm,
							tos.loca_code_shelfno loca_code_shelfno_to,tos.loca_name_shelfno loca_name_shelfno_to,tos.shelfno_code shelfno_code_to,tos.shelfno_name shelfno_name_to,
							person.code person_code_upd,person.name person_name_upd
							from shpdlvs so
							inner join itms i on i.id = so.itms_id
							inner join r_shelfnos fms on fms.id = so.shelfnos_id_fm
							inner join r_shelfnos tos on tos.id = so.shelfnos_id_to
							inner join persons person on person.id = so.persons_id_upd  					
							where so.paretblid  = $1 and so.expiredate > current_date
							and not exists(select 1 from shpacts sa where sa.gno_shpord  = so.gno_shpord and (sa.qty_stk > 0 or sa.qty_shortage > 0  ))
							) shp on shp.paretblid = p.id
					where p.id = $1  
					order by p.id,shp.itm_code '             
using paretblidOrg ;
END
$function$
;

 DROP TABLE IF EXISTS sio.sio_ref_shpdlvs;
 CREATE TABLE sio.sio_ref_shpdlvs (
          sio_id numeric(22,0)  CONSTRAINT sio_ref_shpdlvs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,shpdlv_id  numeric (38,0)
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,shpdlv_isuedate   timestamp(6) 
,shpdlv_qty_stk  numeric (18,4)
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
,shpdlv_update_ip  varchar (40) 
,shpdlv_created_at   timestamp(6) 
,shpdlv_updated_at   timestamp(6) 
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
 CREATE INDEX sio_ref_shpdlvs_uk1 
  ON sio.sio_ref_shpdlvs(id,sio_id); 

 drop sequence  if exists sio.sio_ref_shpdlvs_seq ;
 create sequence sio.sio_ref_shpdlvs_seq ;

