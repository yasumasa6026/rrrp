
 create table shpdlvs (
 shelfnos_id_fm numeric(22,0 )   not null ,
 gno_shpord varchar(40)   ,
 qty_shortage numeric(22,6 )   ,
 masterprice numeric(38,4 )   ,
 id numeric(38,0 )   not null  ,
 remark varchar(4000)   ,
 expiredate date  ,
 update_ip varchar(40)   ,
 created_at timestamp(6)  ,
 updated_at timestamp(6)  ,
 persons_id_upd numeric(38,0 )   not null ,
 itms_id numeric(38,0 )   not null ,
 price numeric(38,4 )   ,
 amt numeric(18,4 )   ,
 sno varchar(50)   ,
 duedate timestamp(6)  ,
 isudate timestamp(6)  ,
 contents varchar(4000)   ,
 depdate timestamp(6)  ,
 tax numeric(38,4 )   ,
 cartonno varchar(50)   ,
 processseq numeric(38,0 )   ,
 prjnos_id numeric(38,0 )   not null ,
 lotno varchar(50)   ,
 qty_stk numeric(22,6 )   ,
 units_id_case_shp numeric(38,0 )   not null ,
 qty_case numeric(22,6 )   ,
 cno varchar(40)   ,
 packno varchar(10)   ,
 rcptdate timestamp(6)  ,
 contractprice char(1)   ,
 gno varchar(40)   ,
 chrgs_id numeric(38,0 )   not null ,
 taxrate numeric(2,0 )   ,
 crrs_id numeric(22,0 )   not null ,
 paretblname varchar(30)   ,
 box varchar(50)   ,
 paretblid numeric(38,0 )   ,
 transports_id numeric(38,0 )   not null ,
 shelfnos_id_to numeric(38,0 )   not null ,
 qty_real numeric(22,6 )   ,
  CONSTRAINT shpdlvs_id_pk PRIMARY KEY (id));
  drop view if  exists r_shpacts cascade ; 
 create or replace view r_shpacts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  itm.itm_name  itm_name ,
  itm.itm_code  itm_code ,
  itm.unit_name  unit_name ,
  itm.unit_code  unit_code ,
  itm.itm_unit_id  itm_unit_id ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
shpact.id id,
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
shpact.sno  shpact_sno,
shpact.depdate  shpact_depdate,
shpact.price  shpact_price,
shpact.remark  shpact_remark,
shpact.created_at  shpact_created_at,
shpact.update_ip  shpact_update_ip,
shpact.amt  shpact_amt,
shpact.id  shpact_id,
shpact.tax  shpact_tax,
shpact.persons_id_upd    shpact_person_id_upd,
shpact.contents  shpact_contents,
shpact.chrgs_id   shpact_chrg_id,
shpact.gno  shpact_gno,
shpact.isudate  shpact_isudate,
shpact.cartonno  shpact_cartonno,
shpact.prjnos_id   shpact_prjno_id,
shpact.expiredate  shpact_expiredate,
shpact.updated_at  shpact_updated_at,
shpact.box  shpact_box,
shpact.duedate  shpact_duedate,
shpact.qty_case  shpact_qty_case,
shpact.cno  shpact_cno,
shpact.lotno  shpact_lotno,
shpact.packno  shpact_packno,
  prjno.prjno_code_chil  prjno_code_chil ,
shpact.transports_id   shpact_transport_id,
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
shpact.shelfnos_id_fm   shpact_shelfno_id_fm,
shpact.processseq  shpact_processseq,
shpact.gno_shpord  shpact_gno_shpord,
shpact.itms_id   shpact_itm_id,
shpact.paretblname  shpact_paretblname,
shpact.paretblid  shpact_paretblid,
shpact.qty_stk  shpact_qty_stk,
shpact.crrs_id  shpact_crr_id,
  prjno.prjno_name_chil  prjno_name_chil ,
  unit_case_shp.unit_name  unit_name_case_shp ,
  unit_case_shp.unit_code  unit_code_case_shp ,
shpact.units_id_case_shp   shpact_unit_id_case_shp,
shpact.shelfnos_id_to   shpact_shelfno_id_to,
shpact.qty_real  shpact_qty_real,
shpact.rcptdate  shpact_rcptdate,
shpact.qty_shortage  shpact_qty_shortage,
shpact.taxrate  shpact_taxrate,
  itm.itm_taxflg  itm_taxflg ,
  crr.decimal  crr_decimal ,
shpact.contractprice  shpact_contractprice,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
shpact.masterprice  shpact_masterprice
 from shpacts   shpact,
 persons person_upd ,  r_chrgs  chrg ,  r_prjnos  prjno ,  r_transports  transport ,  r_shelfnos  shelfno_fm ,  r_itms  itm ,crrs  crr ,  r_units  unit_case_shp ,  r_shelfnos  shelfno_to 
  where       shpact.persons_id_upd = person_upd.id      and shpact.chrgs_id = chrg.id      and shpact.prjnos_id = prjno.id      and shpact.transports_id = transport.id      and shpact.shelfnos_id_fm = shelfno_fm.id      and shpact.itms_id = itm.id      and shpact.crrs_id = crr.id      and shpact.units_id_case_shp = unit_case_shp.id      and shpact.shelfnos_id_to = shelfno_to.id     ;
 DROP TABLE IF EXISTS sio.sio_r_shpacts;
 CREATE TABLE sio.sio_r_shpacts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_shpacts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,itm_code  varchar (50) 
,shpact_processseq  numeric (38,0)
,itm_name  varchar (100) 
,shpact_qty_stk  numeric (22,6)
,shpact_depdate   timestamp(6) 
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_code_fm  varchar (50) 
,shelfno_name_fm  varchar (100) 
,shpact_rcptdate   timestamp(6) 
,loca_code_shelfno_to  varchar (50) 
,loca_name_shelfno_to  varchar (100) 
,shelfno_code_to  varchar (50) 
,shelfno_name_to  varchar (100) 
,shpact_packno  varchar (10) 
,shpact_lotno  varchar (50) 
,shpact_cartonno  varchar (50) 
,transport_code  varchar (50) 
,prjno_code  varchar (50) 
,classlist_code  varchar (50) 
,crr_code  varchar (50) 
,unit_code  varchar (50) 
,shpact_sno  varchar (50) 
,shpact_cno  varchar (40) 
,shpact_gno  varchar (40) 
,prjno_name  varchar (100) 
,unit_name  varchar (100) 
,transport_name  varchar (100) 
,classlist_name  varchar (100) 
,crr_name  varchar (100) 
,shpact_price  numeric (38,4)
,shpact_amt  numeric (18,4)
,shpact_isudate   timestamp(6) 
,shpact_expiredate   date 
,shpact_box  varchar (50) 
,shpact_qty_case  numeric (22,0)
,shpact_paretblname  varchar (30) 
,shpact_paretblid  numeric (38,0)
,prjno_code_chil  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,loca_code_to_transport  varchar (50) 
,person_code_chrg  varchar (50) 
,loca_code_transport  varchar (50) 
,unit_name_case_shp  varchar (100) 
,loca_name_transport  varchar (100) 
,loca_name_to_transport  varchar (100) 
,person_name_chrg  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,prjno_name_chil  varchar (100) 
,shpact_crr_id  numeric (22,0)
,itm_taxflg  varchar (20) 
,crr_decimal  numeric (1,0)
,shpact_gno_shpord  varchar (40) 
,shpact_unit_id_case_shp  numeric (38,0)
,shpact_contractprice  varchar (20) 
,shpact_masterprice  numeric (38,4)
,shpact_taxrate  numeric (2,0)
,shpact_duedate   timestamp(6) 
,shpact_qty_shortage  numeric (22,5)
,shpact_tax  numeric (38,4)
,shpact_qty_real  numeric (38,0)
,person_code_upd  varchar (50) 
,shpact_remark  varchar (4000) 
,shpact_contents  varchar (4000) 
,person_name_upd  varchar (100) 
,shpact_created_at   timestamp(6) 
,itm_unit_id  numeric (22,0)
,shpact_itm_id  numeric (38,0)
,shpact_shelfno_id_to  numeric (38,0)
,id  numeric (38,0)
,shpact_shelfno_id_fm  numeric (22,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,person_sect_id_chrg  numeric (22,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,shpact_update_ip  varchar (40) 
,itm_classlist_id  numeric (38,0)
,shpact_chrg_id  numeric (38,0)
,shpact_transport_id  numeric (38,0)
,shpact_id  numeric (38,0)
,shpact_prjno_id  numeric (38,0)
,shpact_person_id_upd  numeric (38,0)
,shpact_updated_at   timestamp(6) 
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
 CREATE INDEX sio_r_shpacts_uk1 
  ON sio.sio_r_shpacts(id,sio_id); 

 drop sequence  if exists sio.sio_r_shpacts_seq ;
 create sequence sio.sio_r_shpacts_seq ;
  drop view if  exists r_shpdlvs cascade ; 
 create or replace view r_shpdlvs as select  
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
  .shpinst_tax  shpinst_tax ,
  .shpinst_cartonno  shpinst_cartonno ,
  .shpinst_expiredate  shpinst_expiredate ,
  .shpinst_updated_at  shpinst_updated_at ,
  .shpinst_sno  shpinst_sno ,
  .shpinst_depdate  shpinst_depdate ,
  .shpinst_price  shpinst_price ,
  .shpinst_itm_id  shpinst_itm_id ,
  .shpinst_remark  shpinst_remark ,
  .shpinst_created_at  shpinst_created_at ,
  .shpinst_amt  shpinst_amt ,
  .shpinst_update_ip  shpinst_update_ip ,
  .shpinst_id  shpinst_id ,
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
  .shpinst_gno  shpinst_gno ,
  .shpinst_isudate  shpinst_isudate ,
  .shpinst_prjno_id  shpinst_prjno_id ,
  .shpinst_contents  shpinst_contents ,
  .shpinst_chrg_id  shpinst_chrg_id ,
  .shpinst_box  shpinst_box ,
  .shpinst_duedate  shpinst_duedate ,
  .shpinst_cno  shpinst_cno ,
  .shpinst_qty_case  shpinst_qty_case ,
  .shpinst_lotno  shpinst_lotno ,
  .shpinst_packno  shpinst_packno ,
  prjno.prjno_code_chil  prjno_code_chil ,
  .shpinst_transport_id  shpinst_transport_id ,
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
  .shpinst_processseq  shpinst_processseq ,
  .shpinst_paretblname  shpinst_paretblname ,
  .shpinst_paretblid  shpinst_paretblid ,
  .shpinst_qty_shortage  shpinst_qty_shortage ,
  .shpinst_qty_stk  shpinst_qty_stk ,
  .shpinst_shelfno_id_fm  shpinst_shelfno_id_fm ,
  prjno.prjno_name_chil  prjno_name_chil ,
  unit_case_shp.unit_name  unit_name_case_shp ,
  unit_case_shp.unit_code  unit_code_case_shp ,
  .shpinst_unit_id_case_shp  shpinst_unit_id_case_shp ,
  .shpinst_shelfno_id_to  shpinst_shelfno_id_to ,
  .shpinst_qty_real  shpinst_qty_real ,
  .shpinst_crr_id  shpinst_crr_id ,
  .shpinst_rcptdate  shpinst_rcptdate ,
  .shpinst_taxrate  shpinst_taxrate ,
  itm.itm_taxflg  itm_taxflg ,
  crr.decimal  crr_decimal ,
  .shpinst_contractprice  shpinst_contractprice ,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
shpdlv.shelfnos_id_fm   shpdlv_shelfno_id_fm,
shpdlv.gno_shpord  shpdlv_gno_shpord,
shpdlv.qty_shortage  shpdlv_qty_shortage,
shpdlv.masterprice  shpdlv_masterprice,
shpdlv.id  shpdlv_id,
shpdlv.remark  shpdlv_remark,
shpdlv.expiredate  shpdlv_expiredate,
shpdlv.update_ip  shpdlv_update_ip,
shpdlv.created_at  shpdlv_created_at,
shpdlv.updated_at  shpdlv_updated_at,
shpdlv.persons_id_upd    shpdlv_person_id_upd,
shpdlv.itms_id   shpdlv_itm_id,
shpdlv.price  shpdlv_price,
shpdlv.amt  shpdlv_amt,
shpdlv.sno  shpdlv_sno,
shpdlv.duedate  shpdlv_duedate,
shpdlv.isudate  shpdlv_isudate,
shpdlv.contents  shpdlv_contents,
shpdlv.depdate  shpdlv_depdate,
shpdlv.tax  shpdlv_tax,
shpdlv.cartonno  shpdlv_cartonno,
shpdlv.processseq  shpdlv_processseq,
shpdlv.prjnos_id   shpdlv_prjno_id,
shpdlv.lotno  shpdlv_lotno,
shpdlv.qty_stk  shpdlv_qty_stk,
shpdlv.units_id_case_shp   shpdlv_unit_id_case_shp,
shpdlv.qty_case  shpdlv_qty_case,
shpdlv.cno  shpdlv_cno,
shpdlv.packno  shpdlv_packno,
shpdlv.rcptdate  shpdlv_rcptdate,
shpdlv.contractprice  shpdlv_contractprice,
shpdlv.gno  shpdlv_gno,
shpdlv.chrgs_id   shpdlv_chrg_id,
shpdlv.taxrate  shpdlv_taxrate,
shpdlv.crrs_id  shpdlv_crr_id,
shpdlv.paretblname  shpdlv_paretblname,
shpdlv.box  shpdlv_box,
shpdlv.paretblid  shpdlv_paretblid,
shpdlv.transports_id   shpdlv_transport_id,
shpdlv.shelfnos_id_to   shpdlv_shelfno_id_to,
shpdlv.qty_real  shpdlv_qty_real
 from shpdlvs   shpdlv,
  r_shelfnos  shelfno_fm , persons person_upd ,  r_itms  itm ,  r_prjnos  prjno ,  r_units  unit_case_shp ,  r_chrgs  chrg ,crrs  crr ,  r_transports  transport ,  r_shelfnos  shelfno_to 
  where       shpdlv.shelfnos_id_fm = shelfno_fm.id      and shpdlv.persons_id_upd = person_upd.id      and shpdlv.itms_id = itm.id      and shpdlv.prjnos_id = prjno.id      and shpdlv.units_id_case_shp = unit_case_shp.id      and shpdlv.chrgs_id = chrg.id      and shpdlv.crrs_id = crr.id      and shpdlv.transports_id = transport.id      and shpdlv.shelfnos_id_to = shelfno_to.id     ;
 DROP TABLE IF EXISTS sio.sio_r_shpdlvs;
 CREATE TABLE sio.sio_r_shpdlvs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_shpdlvs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,shpinst_packno  varchar (10) 
,shpinst_lotno  varchar (50) 
,shpinst_cartonno  varchar (50) 
,itm_code  varchar (50) 
,crr_code  varchar (50) 
,unit_code  varchar (50) 
,prjno_code  varchar (50) 
,transport_code  varchar (50) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,shpinst_sno  varchar (50) 
,shpinst_cno  varchar (40) 
,shpinst_gno  varchar (40) 
,crr_name  varchar (100) 
,itm_name  varchar (100) 
,unit_name  varchar (100) 
,transport_name  varchar (100) 
,shpinst_expiredate   date 
,shpinst_qty_stk  numeric (22,6)
,shpinst_price  numeric (38,4)
,shpinst_qty_shortage  numeric (22,5)
,shpinst_paretblid  numeric (38,0)
,shpinst_paretblname  varchar (30) 
,shpinst_amt  numeric (18,4)
,shpinst_processseq  numeric (38,0)
,prjno_name  varchar (100) 
,shpinst_isudate   timestamp(6) 
,shpinst_box  varchar (50) 
,shpinst_qty_case  numeric (22,0)
,loca_code_to_transport  varchar (50) 
,loca_code_shelfno_to  varchar (50) 
,shelfno_code_to  varchar (50) 
,prjno_code_chil  varchar (50) 
,person_code_chrg  varchar (50) 
,unit_code_case_shp  varchar (50) 
,loca_code_transport  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,person_name_chrg  varchar (100) 
,shelfno_name_to  varchar (100) 
,loca_name_shelfno_to  varchar (100) 
,prjno_name_chil  varchar (100) 
,unit_name_case_shp  varchar (100) 
,loca_name_transport  varchar (100) 
,loca_name_to_transport  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,shpdlv_prjno_id  numeric (38,0)
,shpdlv_isudate   timestamp(6) 
,shpdlv_contents  varchar (4000) 
,shpdlv_depdate   timestamp(6) 
,shpdlv_tax  numeric (38,4)
,shpdlv_cartonno  varchar (50) 
,shpdlv_processseq  numeric (38,0)
,shpdlv_paretblname  varchar (30) 
,shpdlv_lotno  varchar (50) 
,shpdlv_qty_stk  numeric (22,6)
,shpdlv_unit_id_case_shp  numeric (38,0)
,shpdlv_qty_case  numeric (22,6)
,shpdlv_cno  varchar (40) 
,shpdlv_packno  varchar (10) 
,shpdlv_rcptdate   timestamp(6) 
,shpdlv_contractprice  varchar (1) 
,shpdlv_gno  varchar (40) 
,shpdlv_chrg_id  numeric (38,0)
,shpdlv_taxrate  numeric (2,0)
,shpinst_duedate   timestamp(6) 
,shpdlv_crr_id  numeric (22,0)
,shpinst_depdate   timestamp(6) 
,shpdlv_box  varchar (50) 
,shpdlv_paretblid  numeric (38,0)
,shpinst_unit_id_case_shp  numeric (38,0)
,shpinst_shelfno_id_to  numeric (38,0)
,shpinst_qty_real  numeric (38,0)
,shpinst_crr_id  numeric (22,0)
,shpinst_rcptdate   timestamp(6) 
,shpinst_taxrate  numeric (2,0)
,itm_taxflg  varchar (20) 
,crr_decimal  numeric (1,0)
,shpinst_contractprice  varchar (20) 
,shpinst_tax  numeric (38,4)
,shpdlv_transport_id  numeric (38,0)
,shpdlv_shelfno_id_to  numeric (38,0)
,shpdlv_qty_real  numeric (22,6)
,shpdlv_shelfno_id_fm  numeric (22,0)
,shpdlv_gno_shpord  varchar (40) 
,shpdlv_qty_shortage  numeric (22,6)
,shpdlv_masterprice  numeric (38,4)
,shpdlv_id  numeric (38,0)
,shpdlv_remark  varchar (4000) 
,shpdlv_expiredate   date 
,shpdlv_update_ip  varchar (40) 
,shpdlv_created_at   timestamp(6) 
,shpdlv_updated_at   timestamp(6) 
,shpdlv_itm_id  numeric (38,0)
,shpdlv_price  numeric (38,4)
,shpdlv_amt  numeric (18,4)
,shpdlv_sno  varchar (50) 
,shpdlv_duedate   timestamp(6) 
,shpinst_contents  varchar (4000) 
,shpinst_remark  varchar (4000) 
,shpinst_created_at   timestamp(6) 
,person_sect_id_chrg  numeric (22,0)
,shpinst_id  numeric (38,0)
,shpinst_update_ip  varchar (40) 
,shpinst_itm_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,shpinst_shelfno_id_fm  numeric (22,0)
,shpinst_transport_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,shpinst_updated_at   timestamp(6) 
,shpdlv_person_id_upd  numeric (22,0)
,shpinst_prjno_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,shelfno_loca_id_shelfno_to  numeric (38,0)
,shpinst_person_id_upd  numeric (38,0)
,shpinst_chrg_id  numeric (38,0)
,id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
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
 CREATE INDEX sio_r_shpdlvs_uk1 
  ON sio.sio_r_shpdlvs(id,sio_id); 

 drop sequence  if exists sio.sio_r_shpdlvs_seq ;
 create sequence sio.sio_r_shpdlvs_seq ;
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_shelfnos_id_fm FOREIGN KEY (shelfnos_id_fm)
																		 REFERENCES shelfnos (id);
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_persons_id_upd FOREIGN KEY (persons_id_upd)
																		 REFERENCES persons (id);
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_itms_id FOREIGN KEY (itms_id)
																		 REFERENCES itms (id);
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_prjnos_id FOREIGN KEY (prjnos_id)
																		 REFERENCES prjnos (id);
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_units_id_case_shp FOREIGN KEY (units_id_case_shp)
																		 REFERENCES units (id);
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_chrgs_id FOREIGN KEY (chrgs_id)
																		 REFERENCES chrgs (id);
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_crrs_id FOREIGN KEY (crrs_id)
																		 REFERENCES crrs (id);
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_transports_id FOREIGN KEY (transports_id)
																		 REFERENCES transports (id);
 ALTER TABLE shpdlvs ADD CONSTRAINT shpdlv_shelfnos_id_to FOREIGN KEY (shelfnos_id_to)
																		 REFERENCES shelfnos (id);
 create sequence shpdlvs_seq ;
