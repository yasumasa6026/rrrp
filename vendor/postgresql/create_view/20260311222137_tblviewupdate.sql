
 alter table  shpests  ADD COLUMN amt numeric(18,4)  DEFAULT 0  not null;

 alter table  shpschs  ADD COLUMN amt numeric(18,4)  DEFAULT 0  not null;


  drop view if  exists r_shpests cascade ; 
 create or replace view r_shpests as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
shpest.id id,
  prjno.prjno_name  prjno_name ,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
  prjno.prjno_code  prjno_code ,
shpest.prjnos_id   shpest_prjno_id,
shpest.id  shpest_id,
shpest.remark  shpest_remark,
shpest.update_ip  shpest_update_ip,
shpest.created_at  shpest_created_at,
shpest.updated_at  shpest_updated_at,
shpest.persons_id_upd    shpest_person_id_upd,
shpest.sno  shpest_sno,
shpest.duedate  shpest_duedate,
shpest.isudate  shpest_isudate,
shpest.contents  shpest_contents,
shpest.depdate  shpest_depdate,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
  prjno.prjno_code_chil  prjno_code_chil ,
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
shpest.chrgs_id   shpest_chrg_id,
  prjno.prjno_name_chil  prjno_name_chil ,
  unit_case_shp.unit_name  unit_name_case_shp ,
  unit_case_shp.unit_code  unit_code_case_shp ,
  itm.itm_taxflg  itm_taxflg ,
shpest.shelfnos_id_fm   shpest_shelfno_id_fm,
shpest.qty_est  shpest_qty_est,
shpest.itms_id   shpest_itm_id,
shpest.processseq  shpest_processseq,
shpest.units_id_case_shp   shpest_unit_id_case_shp,
shpest.paretblname  shpest_paretblname,
shpest.paretblid  shpest_paretblid,
shpest.shelfnos_id_to   shpest_shelfno_id_to,
shpest.lotno  shpest_lotno,
shpest.packno  shpest_packno,
shpest.transports_id   shpest_transport_id,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
shpest.masterprice  shpest_masterprice,
shpest.taxrate  shpest_taxrate
 from shpests   shpest,
  r_prjnos  prjno , persons person_upd ,  r_chrgs  chrg ,  r_shelfnos  shelfno_fm ,  r_itms  itm ,  r_units  unit_case_shp ,  r_shelfnos  shelfno_to ,  r_transports  transport 
  where       shpest.prjnos_id = prjno.id      and shpest.persons_id_upd = person_upd.id      and shpest.chrgs_id = chrg.id      and shpest.shelfnos_id_fm = shelfno_fm.id      and shpest.itms_id = itm.id      and shpest.units_id_case_shp = unit_case_shp.id      and shpest.shelfnos_id_to = shelfno_to.id      and shpest.transports_id = transport.id     ;
 DROP TABLE IF EXISTS sio.sio_r_shpests;
 CREATE TABLE sio.sio_r_shpests (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_shpests_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,shpest_packno  varchar (10) 
,shpest_lotno  varchar (50) 
,classlist_code  varchar (50) 
,itm_code  varchar (50) 
,transport_code  varchar (50) 
,prjno_code  varchar (50) 
,unit_code  varchar (50) 
,shpest_sno  varchar (50) 
,transport_name  varchar (100) 
,prjno_name  varchar (100) 
,classlist_name  varchar (100) 
,unit_name  varchar (100) 
,itm_name  varchar (100) 
,loca_code_shelfno_to  varchar (50) 
,unit_code_case_shp  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_code_to_transport  varchar (50) 
,loca_code_transport  varchar (50) 
,prjno_code_chil  varchar (50) 
,shelfno_code_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,prjno_name_chil  varchar (100) 
,person_name_chrg  varchar (100) 
,unit_name_case_shp  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_name_to  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_transport  varchar (100) 
,loca_name_to_transport  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,shpest_taxrate  numeric (2,0)
,shpest_prjno_id  numeric (38,0)
,shpest_update_ip  varchar (40) 
,shpest_created_at   timestamp(6) 
,shpest_updated_at   timestamp(6) 
,shpest_duedate   timestamp(6) 
,shpest_isudate   timestamp(6) 
,shpest_depdate   timestamp(6) 
,shpest_chrg_id  numeric (38,0)
,itm_taxflg  varchar (20) 
,shpest_shelfno_id_fm  numeric (22,0)
,shpest_qty_est  numeric (22,6)
,shpest_itm_id  numeric (38,0)
,shpest_processseq  numeric (38,0)
,shpest_unit_id_case_shp  numeric (38,0)
,shpest_paretblname  varchar (30) 
,shpest_paretblid  numeric (38,0)
,shpest_shelfno_id_to  numeric (38,0)
,shpest_transport_id  numeric (38,0)
,shpest_masterprice  numeric (38,4)
,shpest_remark  varchar (4000) 
,shpest_contents  varchar (4000) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,shelfno_loca_id_shelfno_to  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,shpest_person_id_upd  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,id  numeric (38,0)
,shpest_id  numeric (38,0)
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
 CREATE INDEX sio_r_shpests_uk1 
  ON sio.sio_r_shpests(id,sio_id); 

 drop sequence  if exists sio.sio_r_shpests_seq ;
 create sequence sio.sio_r_shpests_seq ;
  drop view if  exists r_shpschs cascade ; 
 create or replace view r_shpschs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  itm.itm_unit_id  itm_unit_id ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
shpsch.id id,
shpsch.expiredate  shpsch_expiredate,
shpsch.updated_at  shpsch_updated_at,
shpsch.depdate  shpsch_depdate,
shpsch.remark  shpsch_remark,
shpsch.created_at  shpsch_created_at,
shpsch.amt  shpsch_amt,
shpsch.update_ip  shpsch_update_ip,
shpsch.id  shpsch_id,
shpsch.itms_id   shpsch_itm_id,
shpsch.tax  shpsch_tax,
shpsch.sno  shpsch_sno,
shpsch.price  shpsch_price,
shpsch.persons_id_upd    shpsch_person_id_upd,
  prjno.prjno_name  prjno_name ,
  chrg.person_sect_id_chrg  person_sect_id_chrg ,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
shpsch.isudate  shpsch_isudate,
shpsch.processseq  shpsch_processseq,
shpsch.duedate  shpsch_duedate,
  prjno.prjno_code  prjno_code ,
shpsch.prjnos_id   shpsch_prjno_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  itm.classlist_code  classlist_code ,
  itm.classlist_name  classlist_name ,
  crr.code  crr_code ,
  crr.name  crr_name ,
shpsch.chrgs_id   shpsch_chrg_id,
shpsch.qty_case  shpsch_qty_case,
  prjno.prjno_code_chil  prjno_code_chil ,
shpsch.transports_id   shpsch_transport_id,
  itm.itm_classlist_id  itm_classlist_id ,
shpsch.gno  shpsch_gno,
shpsch.crrs_id  shpsch_crr_id,
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
shpsch.lotno  shpsch_lotno,
shpsch.packno  shpsch_packno,
shpsch.paretblname  shpsch_paretblname,
shpsch.paretblid  shpsch_paretblid,
shpsch.shelfnos_id_fm   shpsch_shelfno_id_fm,
shpsch.qty_sch  shpsch_qty_sch,
shpsch.amt_sch  shpsch_amt_sch,
  prjno.prjno_name_chil  prjno_name_chil ,
  unit_case_shp.unit_name  unit_name_case_shp ,
  unit_case_shp.unit_code  unit_code_case_shp ,
shpsch.shelfnos_id_to   shpsch_shelfno_id_to,
shpsch.units_id_case_shp   shpsch_unit_id_case_shp,
shpsch.taxrate  shpsch_taxrate,
  itm.itm_taxflg  itm_taxflg ,
shpsch.contractprice  shpsch_contractprice,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
shpsch.masterprice  shpsch_masterprice
 from shpschs   shpsch,
  r_itms  itm , persons person_upd ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_transports  transport ,crrs  crr ,  r_shelfnos  shelfno_fm ,  r_shelfnos  shelfno_to ,  r_units  unit_case_shp 
  where       shpsch.itms_id = itm.id      and shpsch.persons_id_upd = person_upd.id      and shpsch.prjnos_id = prjno.id      and shpsch.chrgs_id = chrg.id      and shpsch.transports_id = transport.id      and shpsch.crrs_id = crr.id      and shpsch.shelfnos_id_fm = shelfno_fm.id      and shpsch.shelfnos_id_to = shelfno_to.id      and shpsch.units_id_case_shp = unit_case_shp.id     ;
 DROP TABLE IF EXISTS sio.sio_r_shpschs;
 CREATE TABLE sio.sio_r_shpschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_shpschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,shpsch_isudate   timestamp(6) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,person_code_upd  varchar (50) 
,shpsch_depdate   timestamp(6) 
,person_name_upd  varchar (100) 
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_code_fm  varchar (50) 
,shelfno_name_fm  varchar (100) 
,shpsch_lotno  varchar (50) 
,shpsch_packno  varchar (10) 
,shpsch_price  numeric (38,4)
,transport_code  varchar (50) 
,transport_name  varchar (100) 
,unit_code  varchar (50) 
,unit_name  varchar (100) 
,prjno_code  varchar (50) 
,classlist_code  varchar (50) 
,shpsch_sno  varchar (50) 
,crr_code  varchar (50) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,crr_name  varchar (100) 
,shpsch_expiredate   date 
,prjno_name  varchar (100) 
,shpsch_processseq  numeric (38,0)
,classlist_name  varchar (100) 
,shpsch_paretblid  numeric (38,0)
,shpsch_paretblname  varchar (30) 
,loca_code_transport  varchar (50) 
,shelfno_code_to  varchar (50) 
,loca_code_to_transport  varchar (50) 
,prjno_code_chil  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,unit_code_case_shp  varchar (50) 
,shelfno_name_to  varchar (100) 
,loca_name_to_transport  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,prjno_name_chil  varchar (100) 
,unit_name_case_shp  varchar (100) 
,loca_name_transport  varchar (100) 
,shpsch_qty_case  numeric (38,0)
,shpsch_amt_sch  numeric (38,4)
,shpsch_qty_sch  numeric (22,6)
,shpsch_masterprice  numeric (38,4)
,shpsch_amt  numeric (18,4)
,shpsch_tax  numeric (38,4)
,shpsch_duedate   timestamp(6) 
,shpsch_gno  varchar (40) 
,shpsch_crr_id  numeric (22,0)
,shpsch_shelfno_id_to  numeric (38,0)
,shpsch_unit_id_case_shp  numeric (38,0)
,shpsch_taxrate  numeric (2,0)
,itm_taxflg  varchar (20) 
,shpsch_contractprice  varchar (20) 
,shpsch_remark  varchar (4000) 
,shpsch_prjno_id  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,shpsch_person_id_upd  numeric (38,0)
,shpsch_itm_id  numeric (38,0)
,shpsch_created_at   timestamp(6) 
,shpsch_chrg_id  numeric (38,0)
,shpsch_shelfno_id_fm  numeric (22,0)
,shpsch_updated_at   timestamp(6) 
,id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,shpsch_id  numeric (38,0)
,shpsch_update_ip  varchar (40) 
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,shpsch_transport_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
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
 CREATE INDEX sio_r_shpschs_uk1 
  ON sio.sio_r_shpschs(id,sio_id); 

 drop sequence  if exists sio.sio_r_shpschs_seq ;
 create sequence sio.sio_r_shpschs_seq ;
