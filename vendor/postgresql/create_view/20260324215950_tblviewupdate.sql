
  drop view if  exists r_shpords cascade ; 
 create or replace view r_shpords as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  itm.itm_unit_id  itm_unit_id ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
shpord.qty  shpord_qty,
shpord.sno  shpord_sno,
shpord.update_ip  shpord_update_ip,
shpord.updated_at  shpord_updated_at,
shpord.isudate  shpord_isudate,
shpord.persons_id_upd    shpord_person_id_upd,
shpord.id  shpord_id,
shpord.duedate  shpord_duedate,
shpord.created_at  shpord_created_at,
shpord.id id,
shpord.expiredate  shpord_expiredate,
shpord.depdate  shpord_depdate,
shpord.price  shpord_price,
shpord.itms_id   shpord_itm_id,
shpord.remark  shpord_remark,
shpord.amt  shpord_amt,
shpord.tax  shpord_tax,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
  prjno.prjno_code  prjno_code ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
  crr.code  crr_code ,
  crr.name  crr_name ,
shpord.chrgs_id   shpord_chrg_id,
shpord.gno  shpord_gno,
shpord.processseq  shpord_processseq,
shpord.prjnos_id   shpord_prjno_id,
shpord.qty_case  shpord_qty_case,
shpord.lotno  shpord_lotno,
shpord.packno  shpord_packno,
  prjno.prjno_code_chil  prjno_code_chil ,
shpord.transports_id   shpord_transport_id,
  itm.itm_classlist_id  itm_classlist_id ,
  shelfno_to.shelfno_code  shelfno_code_to ,
  shelfno_to.shelfno_name  shelfno_name_to ,
  shelfno_to.loca_code_shelfno  loca_code_shelfno_to ,
  shelfno_to.loca_name_shelfno  loca_name_shelfno_to ,
  shelfno_to.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_to ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
shpord.crrs_id  shpord_crr_id,
shpord.paretblname  shpord_paretblname,
shpord.paretblid  shpord_paretblid,
shpord.shelfnos_id_fm   shpord_shelfno_id_fm,
  prjno.prjno_name_chil  prjno_name_chil ,
  unit_case_shp.unit_name  unit_name_case_shp ,
  unit_case_shp.unit_code  unit_code_case_shp ,
shpord.qty_shortage  shpord_qty_shortage,
shpord.shelfnos_id_to   shpord_shelfno_id_to,
shpord.units_id_case_shp   shpord_unit_id_case_shp,
shpord.taxrate  shpord_taxrate,
  itm.itm_taxflg  itm_taxflg ,
shpord.masterprice  shpord_masterprice,
  crr.decimal  crr_decimal ,
shpord.contractprice  shpord_contractprice,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport 
 from shpords   shpord,
 persons person_upd ,  r_itms  itm ,  r_chrgs  chrg ,  r_prjnos  prjno ,  r_transports  transport ,crrs  crr ,  r_shelfnos  shelfno_fm ,  r_shelfnos  shelfno_to ,  r_units  unit_case_shp 
  where       shpord.persons_id_upd = person_upd.id      and shpord.itms_id = itm.id      and shpord.chrgs_id = chrg.id      and shpord.prjnos_id = prjno.id      and shpord.transports_id = transport.id      and shpord.crrs_id = crr.id      and shpord.shelfnos_id_fm = shelfno_fm.id      and shpord.shelfnos_id_to = shelfno_to.id      and shpord.units_id_case_shp = unit_case_shp.id     ;
 DROP TABLE IF EXISTS sio.sio_r_shpords;
 CREATE TABLE sio.sio_r_shpords (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_shpords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,shpord_isudate   timestamp(6) 
,shpord_paretblname  varchar (30) 
,shpord_paretblid  numeric (38,0)
,shpord_depdate   timestamp(6) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,shpord_processseq  numeric (38,0)
,shpord_qty  numeric (22,6)
,shpord_qty_shortage  numeric (22,5)
,shpord_qty_case  numeric (22,0)
,shpord_packno  varchar (10) 
,shpord_lotno  varchar (50) 
,shpord_duedate   timestamp(6) 
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_code_fm  varchar (50) 
,shelfno_name_fm  varchar (100) 
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_code_to  varchar (50) 
,shelfno_name_to  varchar (100) 
,shpord_sno  varchar (50) 
,shpord_gno  varchar (40) 
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,transport_code  varchar (50) 
,transport_name  varchar (100) 
,crr_code  varchar (50) 
,shpord_price  numeric (38,4)
,crr_name  varchar (100) 
,shpord_amt  numeric (18,4)
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,prjno_code_chil  varchar (50) 
,prjno_name_chil  varchar (100) 
,unit_code_case_shp  varchar (50) 
,loca_code_transport  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_code_to_transport  varchar (50) 
,person_name_chrg  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,unit_name_case_shp  varchar (100) 
,loca_name_to_transport  varchar (100) 
,loca_name_transport  varchar (100) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,shpord_unit_id_case_shp  numeric (38,0)
,shpord_taxrate  numeric (2,0)
,itm_taxflg  varchar (20) 
,shpord_masterprice  numeric (38,4)
,crr_decimal  numeric (1,0)
,shpord_contractprice  varchar (20) 
,shpord_crr_id  numeric (22,0)
,shpord_tax  numeric (38,4)
,shpord_remark  varchar (4000) 
,shpord_expiredate   date 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,shpord_shelfno_id_fm  numeric (22,0)
,shpord_chrg_id  numeric (38,0)
,shpord_transport_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,shpord_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,id  numeric (38,0)
,shpord_prjno_id  numeric (38,0)
,shpord_created_at   timestamp(6) 
,shpord_id  numeric (38,0)
,shpord_person_id_upd  numeric (38,0)
,shpord_updated_at   timestamp(6) 
,shpord_update_ip  varchar (40) 
,itm_unit_id  numeric (22,0)
,shpord_shelfno_id_to  numeric (38,0)
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
 CREATE INDEX sio_r_shpords_uk1 
  ON sio.sio_r_shpords(id,sio_id); 

 drop sequence  if exists sio.sio_r_shpords_seq ;
 create sequence sio.sio_r_shpords_seq ;

 
 select * from r_shpords;