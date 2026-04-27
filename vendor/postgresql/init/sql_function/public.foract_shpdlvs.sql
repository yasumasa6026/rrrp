
  drop view if  exists foract_shpdlvs cascade ; 
 create or replace view foract_shpdlvs as select  
shpdlv.packno  shpdlv_packno,
case when shpdlv.rcptdate is null then current_date else shpdlv.rcptdate end  shpdlv_rcptdate, 
shpdlv.lotno shpdlv_lotno, 
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  itm.itm_unit_id  itm_unit_id ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
shpdlv.id id,
shpdlv.tax  shpdlv_tax,
shpdlv.cartonno  shpdlv_cartonno,
shpdlv.expiredate  shpdlv_expiredate,
shpdlv.updated_at  shpdlv_updated_at,
shpdlv.sno  shpdlv_sno,
shpdlv.price  shpdlv_price,
shpdlv.itms_id   shpdlv_itm_id,
shpdlv.remark  shpdlv_remark,
shpdlv.created_at  shpdlv_created_at,
shpdlv.amt  shpdlv_amt,
shpdlv.update_ip  shpdlv_update_ip,
shpdlv.id  shpdlv_id,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
  person_upd.code  person_code_upd ,
  person_upd.name  person_name_upd ,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
shpdlv.gno  shpdlv_gno,
shpdlv.isudate  shpdlv_isudate,
shpdlv.prjnos_id   shpdlv_prjno_id,
shpdlv.persons_id_upd   shpdlv_person_id_upd,
shpdlv.contents  shpdlv_contents,
shpdlv.contractprice  shpdlv_contractprice,
shpdlv.chrgs_id   shpdlv_chrg_id,
shpdlv.crrs_id   shpdlv_crr_id,
shpdlv.box  shpdlv_box,
shpdlv.cno  shpdlv_cno,
shpdlv.qty_case  shpdlv_qty_case,
  prjno.prjno_code_chil  prjno_code_chil ,
shpdlv.transports_id   shpdlv_transport_id,
  itm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
shpdlv.processseq  shpdlv_processseq,
shpdlv.depdate  shpdlv_depdate,
shpdlv.paretblname  shpdlv_paretblname,
shpdlv.paretblid  shpdlv_paretblid,
shpdlv.qty_shortage  shpdlv_qty_shortage,
shpdlv.qty_stk  shpdlv_qty_stk,
  prjno.prjno_name_chil  prjno_name_chil ,
  unit_case_shp.unit_name  unit_name_case_shp ,
  unit_case_shp.unit_code  unit_code_case_shp ,
shpdlv.units_id_case_shp   shpdlv_unit_id_case_shp,
shpdlv.shelfnos_id_to   shpdlv_shelfno_id_to,
shpdlv.qty_real  shpdlv_qty_real
 from shpdlvs   shpdlv,
  r_itms  itm ,  r_prjnos  prjno ,  persons  person_upd ,  r_chrgs  chrg ,  r_transports  transport ,  r_units  unit_case_shp ,  r_shelfnos  shelfno_to 
  where       shpdlv.itms_id = itm.id      and shpdlv.prjnos_id = prjno.id      and shpdlv.persons_id_upd = person_upd.id      and shpdlv.chrgs_id = chrg.id      and shpdlv.transports_id = transport.id      and shpdlv.units_id_case_shp = unit_case_shp.id      and shpdlv.shelfnos_id_to = shelfno_to.id     ;
 DROP TABLE IF EXISTS sio.sio_foract_shpdlvs;
 CREATE TABLE sio.sio_foract_shpdlvs (
          sio_id numeric(22,0)  CONSTRAINT SIO_foract_shpdlvs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,shpdlv_packno  varchar (50)
,shpdlv_rcptdate  varchar (10)
,shpdlv_lotno  varchar (50)
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,shpdlv_sno  varchar (40) 
,prjno_code  varchar (50) 
,transport_code  varchar (50) 
,shpdlv_cno  varchar (40) 
,shpdlv_gno  varchar (40) 
,itm_code  varchar (50) 
,unit_code  varchar (50) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,shpdlv_box  varchar (50) 
,itm_name  varchar (100) 
,unit_name  varchar (100) 
,transport_name  varchar (100) 
,shpdlv_tax  numeric (38,4)
,shpdlv_cartonno  varchar (50) 
,shpdlv_expiredate   date 
,shpdlv_price  numeric (38,4)
,shpdlv_amt  numeric (18,4)
,prjno_name  varchar (100) 
,shpdlv_isudate   timestamp(6) 
,shpdlv_contractprice  varchar (1) 
,shpdlv_qty_case  numeric (22,0)
,shpdlv_processseq  numeric (38,0)
,shpdlv_starttime   timestamp(6) 
,shpdlv_paretblname  varchar (30) 
,shpdlv_paretblid  numeric (38,0)
,shpdlv_qty_shortage  numeric (22,5)
,shpdlv_qty_stk  numeric (22,6)
,prjno_code_chil  varchar (50) 
,shelfno_code_to  varchar (50) 
,person_code_chrg  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,person_name_chrg  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_name_to  varchar (100) 
,unit_name_case_shp  varchar (100) 
,prjno_name_chil  varchar (100) 
,shpdlv_shelfno_id_to  numeric (38,0)
,shpdlv_unit_id_case_shp  numeric (38,0)
,shpdlv_depdate   timestamp(6) 
,shpdlv_qty_real  numeric (38,0)
,shpdlv_contents  varchar (4000) 
,shpdlv_remark  varchar (4000) 
,shpdlv_created_at   timestamp(6) 
,shpdlv_updated_at   timestamp(6) 
,itm_unit_id  numeric (22,0)
,shpdlv_crr_id  numeric (22,0)
,shpdlv_prjno_id  numeric (38,0)
,shpdlv_person_id_upd  numeric (38,0)
,shpdlv_chrg_id  numeric (38,0)
,shpdlv_transport_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shpdlv_update_ip  varchar (40) 
,shpdlv_id  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,shpdlv_itm_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,id  numeric (38,0)
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
 CREATE INDEX sio_foract_shpdlvs_uk1 
  ON sio.sio_foract_shpdlvs(id,sio_id); 

 drop sequence  if exists sio.sio_foract_shpdlvs_seq ;
 create sequence sio.sio_foract_shpdlvs_seq ;
