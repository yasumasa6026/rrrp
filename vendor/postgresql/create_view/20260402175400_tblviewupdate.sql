
 alter table  custinsts  ADD COLUMN qty_case numeric(22,6)  DEFAULT 0  not null;

 alter table  custschs  ADD COLUMN qty_case numeric(22,6)  DEFAULT 0  not null;

  drop view if  exists r_custacts cascade ; 
 create or replace view r_custacts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
custact.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  prjno.prjno_name  prjno_name ,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
  prjno.prjno_code  prjno_code ,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  cust.cust_amtround  cust_amtround ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  bill.bill_loca_id_bill  bill_loca_id_bill ,
  bill.loca_code_bill  loca_code_bill ,
  bill.loca_name_bill  loca_name_bill ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
custact.custrcvplcs_id   custact_custrcvplc_id,
custact.chrgs_id   custact_chrg_id,
custact.itm_code_client  custact_itm_code_client,
custact.isudate  custact_isudate,
custact.expiredate  custact_expiredate,
custact.updated_at  custact_updated_at,
custact.sno  custact_sno,
custact.price  custact_price,
custact.remark  custact_remark,
custact.created_at  custact_created_at,
custact.update_ip  custact_update_ip,
custact.amt  custact_amt,
custact.id  custact_id,
custact.persons_id_upd    custact_person_id_upd,
custact.custs_id   custact_cust_id,
custact.saledate  custact_saledate,
  prjno.prjno_code_chil  prjno_code_chil ,
  bill.bill_chrg_id_bill  bill_chrg_id_bill ,
  bill.person_code_chrg_bill  person_code_chrg_bill ,
  bill.person_name_chrg_bill  person_name_chrg_bill ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
  bill.bill_crr_id_bill  bill_crr_id_bill ,
  bill.crr_code_bill  crr_code_bill ,
  bill.crr_name_bill  crr_name_bill ,
custact.shelfnos_id_fm   custact_shelfno_id_fm,
custact.opeitms_id   custact_opeitm_id,
  prjno.prjno_name_chil  prjno_name_chil ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custact.sno_custord  custact_sno_custord,
custact.cno_custord  custact_cno_custord,
custact.invoiceno  custact_invoiceno,
custact.cartonno  custact_cartonno,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype ,
  opeitm.unit_name_weight  unit_name_weight ,
  opeitm.unit_code_weight  unit_code_weight ,
custact.lotno  custact_lotno,
custact.packinglistno_custdlv  custact_packinglistno_custdlv,
custact.taxrate  custact_taxrate,
  opeitm.itm_taxflg  itm_taxflg ,
custact.tax  custact_tax,
custact.contractprice  custact_contractprice,
  cust.bill_loca_id_bill_cust  bill_loca_id_bill_cust ,
  cust.loca_code_bill_cust  loca_code_bill_cust ,
  cust.loca_name_bill_cust  loca_name_bill_cust ,
  cust.bill_chrg_id_bill_cust  bill_chrg_id_bill_cust ,
  cust.person_code_chrg_bill_cust  person_code_chrg_bill_cust ,
  cust.person_name_chrg_bill_cust  person_name_chrg_bill_cust ,
  cust.bill_crr_id_bill_cust  bill_crr_id_bill_cust ,
  bill.bill_ratejson  bill_ratejson ,
custact.qty_stk  custact_qty_stk,
custact.bills_id   custact_bill_id,
  transport.transport_duration  transport_duration ,
custact.transports_id   custact_transport_id,
  custrcvplc.transport_code_custrcvplc  transport_code_custrcvplc ,
  custrcvplc.transport_name_custrcvplc  transport_name_custrcvplc ,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
  custrcvplc.loca_code_transport_custrcvplc  loca_code_transport_custrcvplc ,
  custrcvplc.loca_name_transport_custrcvplc  loca_name_transport_custrcvplc ,
  custrcvplc.loca_code_to_transport_custrcvplc  loca_code_to_transport_custrcvplc ,
  custrcvplc.loca_name_to_transport_custrcvplc  loca_name_to_transport_custrcvplc ,
  custrcvplc.loca_code_fm_transport_custrcvplc  loca_code_fm_transport_custrcvplc ,
  custrcvplc.loca_name_fm_transport_custrcvplc  loca_name_fm_transport_custrcvplc ,
custact.duration  custact_duration,
  opeitm.unit_name_size  unit_name_size ,
  opeitm.unit_code_size  unit_code_size ,
  opeitm.opeitm_unit_id_weight  opeitm_unit_id_weight ,
  opeitm.opeitm_unit_id_size  opeitm_unit_id_size ,
  opeitm.opeitm_weight  opeitm_weight ,
  opeitm.opeitm_length  opeitm_length ,
  opeitm.opeitm_wide  opeitm_wide ,
  opeitm.opeitm_deth  opeitm_deth ,
  opeitm.opeitm_datascale  opeitm_datascale ,
  opeitm.opeitm_expireterm  opeitm_expireterm ,
custact.prjnos_id   custact_prjno_id,
custact.qty_case  custact_qty_case
 from custacts   custact,
  r_custrcvplcs  custrcvplc ,  r_chrgs  chrg , persons person_upd ,  r_custs  cust ,  r_shelfnos  shelfno_fm ,  r_opeitms  opeitm ,  r_bills  bill ,  r_transports  transport ,  r_prjnos  prjno 
  where       custact.custrcvplcs_id = custrcvplc.id      and custact.chrgs_id = chrg.id      and custact.persons_id_upd = person_upd.id      and custact.custs_id = cust.id      and custact.shelfnos_id_fm = shelfno_fm.id      and custact.opeitms_id = opeitm.id      and custact.bills_id = bill.id      and custact.transports_id = transport.id      and custact.prjnos_id = prjno.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custacts;
 CREATE TABLE sio.sio_r_custacts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custacts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,custact_isudate   timestamp(6) 
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,custact_sno_custord  varchar (50) 
,custact_saledate   timestamp(6) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,custact_qty_case  numeric (22,6)
,opeitm_packqty  numeric (38,0)
,custact_qty_stk  numeric (22,6)
,loca_code_bill  varchar (50) 
,loca_name_bill  varchar (100) 
,crr_code_bill  varchar (50) 
,crr_name_bill  varchar (100) 
,prjno_code  varchar (50) 
,transport_code  varchar (50) 
,custact_amt  numeric (18,4)
,custact_tax  numeric (38,4)
,itm_taxflg  varchar (20) 
,custact_taxrate  numeric (2,0)
,cust_amtround  varchar (2) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,prjno_name  varchar (100) 
,transport_name  varchar (100) 
,classlist_name  varchar (100) 
,classlist_code  varchar (50) 
,loca_code_fm_transport_custrcvplc  varchar (50) 
,shelfno_code_opeitm  varchar (50) 
,loca_code_shelfno_opeitm  varchar (50) 
,unit_code_size  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,loca_code_to_transport_custrcvplc  varchar (50) 
,loca_code_transport_custrcvplc  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,loca_code_to_transport  varchar (50) 
,loca_code_transport  varchar (50) 
,transport_code_custrcvplc  varchar (50) 
,loca_code_bill_cust  varchar (50) 
,prjno_code_chil  varchar (50) 
,person_code_chrg_bill  varchar (50) 
,shelfno_code_fm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,unit_code_weight  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,unit_name_case_prdpur  varchar (100) 
,person_code_chrg_cust  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,person_code_chrg_bill_cust  varchar (50) 
,person_name_chrg_bill_cust  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_custrcvplc  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,loca_name_shelfno_opeitm  varchar (100) 
,loca_name_fm_transport_custrcvplc  varchar (100) 
,loca_name_bill_cust  varchar (100) 
,prjno_name_chil  varchar (100) 
,unit_name_size  varchar (100) 
,shelfno_name_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,loca_name_transport_custrcvplc  varchar (100) 
,person_name_chrg_bill  varchar (100) 
,loca_name_to_transport_custrcvplc  varchar (100) 
,loca_name_transport  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,transport_name_custrcvplc  varchar (100) 
,unit_name_weight  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,loca_name_to_transport  varchar (100) 
,opeitm_processseq  numeric (3,0)
,custact_opeitm_id  numeric (38,0)
,custact_shelfno_id_fm  numeric (22,0)
,opeitm_priority  numeric (3,0)
,custact_sno  varchar (50) 
,opeitm_shpordauto  varchar (1) 
,custact_chrg_id  numeric (38,0)
,custact_invoiceno  varchar (50) 
,custact_cartonno  varchar (50) 
,opeitm_prdpurordauto  varchar (1) 
,opeitm_itmtype  varchar (1) 
,custact_lotno  varchar (50) 
,custact_packinglistno_custdlv  varchar (20) 
,custact_contractprice  varchar (20) 
,bill_ratejson  varchar (4000) 
,custact_bill_id  numeric (38,0)
,transport_duration  numeric (38,2)
,custact_transport_id  numeric (38,0)
,custact_duration  numeric (38,2)
,opeitm_weight  numeric (7,2)
,opeitm_length  numeric (38,6)
,opeitm_wide  numeric (7,2)
,opeitm_deth  numeric (38,6)
,opeitm_datascale  numeric (38,0)
,opeitm_expireterm  numeric (5,0)
,custact_prjno_id  numeric (38,0)
,custact_cno_custord  varchar (50) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,custact_expiredate   date 
,custact_itm_code_client  varchar (50) 
,custact_remark  varchar (4000) 
,custact_price  numeric (22,4)
,bill_chrg_id_bill_cust  numeric (22,0)
,bill_crr_id_bill_cust  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
,opeitm_unit_id_weight  numeric (22,0)
,opeitm_unit_id_size  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,bill_crr_id_bill  numeric (22,0)
,cust_loca_id_cust  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,bill_chrg_id_bill  numeric (22,0)
,itm_unit_id  numeric (22,0)
,bill_loca_id_bill_cust  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,bill_loca_id_bill  numeric (38,0)
,person_sect_id_chrg_cust  numeric (22,0)
,chrg_person_id_chrg  numeric (38,0)
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,opeitm_shelfno_id_opeitm  numeric (22,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,custact_updated_at   timestamp(6) 
,custact_custrcvplc_id  numeric (22,0)
,custact_created_at   timestamp(6) 
,custact_cust_id  numeric (22,0)
,id  numeric (22,0)
,custact_person_id_upd  numeric (22,0)
,custact_id  numeric (22,0)
,custact_update_ip  varchar (40) 
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
 CREATE INDEX sio_r_custacts_uk1 
  ON sio.sio_r_custacts(id,sio_id); 

 drop sequence  if exists sio.sio_r_custacts_seq ;
 create sequence sio.sio_r_custacts_seq ;
  drop view if  exists r_custdlvs cascade ; 
 create or replace view r_custdlvs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
custdlv.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  prjno.prjno_name  prjno_name ,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
  prjno.prjno_code  prjno_code ,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  cust.cust_amtround  cust_amtround ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  crr.code  crr_code ,
  crr.name  crr_name ,
  opeitm.opeitm_boxe_id  opeitm_boxe_id ,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
custdlv.custs_id   custdlv_cust_id,
custdlv.itm_code_client  custdlv_itm_code_client,
custdlv.custrcvplcs_id   custdlv_custrcvplc_id,
custdlv.id  custdlv_id,
custdlv.gno  custdlv_gno,
custdlv.starttime  custdlv_starttime,
custdlv.price  custdlv_price,
custdlv.expiredate  custdlv_expiredate,
custdlv.amt  custdlv_amt,
custdlv.isudate  custdlv_isudate,
custdlv.sno  custdlv_sno,
custdlv.remark  custdlv_remark,
custdlv.persons_id_upd    custdlv_person_id_upd,
custdlv.update_ip  custdlv_update_ip,
custdlv.created_at  custdlv_created_at,
custdlv.updated_at  custdlv_updated_at,
custdlv.shelfnos_id_fm   custdlv_shelfno_id_fm,
custdlv.opeitms_id   custdlv_opeitm_id,
  prjno.prjno_name_chil  prjno_name_chil ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.opeitm_unit_id_case_shp  opeitm_unit_id_case_shp ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_code_case_shp  unit_code_case_shp ,
  opeitm.opeitm_unit_id_case_prdpur  opeitm_unit_id_case_prdpur ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
custdlv.sno_custinst  custdlv_sno_custinst,
custdlv.cno_custord  custdlv_cno_custord,
custdlv.cno_custinst  custdlv_cno_custinst,
custdlv.depdate  custdlv_depdate,
custdlv.cartonno  custdlv_cartonno,
custdlv.qty_stk  custdlv_qty_stk,
custdlv.qty_case  custdlv_qty_case,
custdlv.invoiceno  custdlv_invoiceno,
custdlv.chrgs_id   custdlv_chrg_id,
custdlv.lotno  custdlv_lotno,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype ,
custdlv.dimension  custdlv_dimension,
custdlv.boxes_id_custdlv   custdlv_boxe_id_custdlv,
  boxe_custdlv.boxe_outdepth  boxe_outdepth_custdlv ,
  boxe_custdlv.boxe_outwide  boxe_outwide_custdlv ,
  boxe_custdlv.boxe_outheight  boxe_outheight_custdlv ,
  boxe_custdlv.boxe_unit_id_box  boxe_unit_id_box_custdlv ,
  boxe_custdlv.unit_code_box  unit_code_box_custdlv ,
  boxe_custdlv.unit_name_box  unit_name_box_custdlv ,
  boxe_custdlv.boxe_code  boxe_code_custdlv ,
  boxe_custdlv.boxe_name  boxe_name_custdlv ,
custdlv.weight  custdlv_weight,
custdlv.packno  custdlv_packno,
custdlv.packinglistno  custdlv_packinglistno,
custdlv.crrs_id  custdlv_crr_id,
custdlv.taxrate  custdlv_taxrate,
  opeitm.itm_taxflg  itm_taxflg ,
  crr.decimal  crr_decimal ,
custdlv.tax  custdlv_tax,
custdlv.contractprice  custdlv_contractprice,
  cust.bill_chrg_id_bill_cust  bill_chrg_id_bill_cust ,
  cust.person_code_chrg_bill_cust  person_code_chrg_bill_cust ,
  cust.person_name_chrg_bill_cust  person_name_chrg_bill_cust ,
  cust.bill_crr_id_bill_cust  bill_crr_id_bill_cust ,
  cust.crr_code_bill_cust  crr_code_bill_cust ,
  cust.crr_name_bill_cust  crr_name_bill_cust ,
custdlv.duedate_custord  custdlv_duedate_custord,
  transport.transport_duration  transport_duration ,
  custrcvplc.transport_code_custrcvplc  transport_code_custrcvplc ,
  custrcvplc.transport_name_custrcvplc  transport_name_custrcvplc ,
custdlv.transports_id   custdlv_transport_id,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
  custrcvplc.loca_code_transport_custrcvplc  loca_code_transport_custrcvplc ,
  custrcvplc.loca_name_transport_custrcvplc  loca_name_transport_custrcvplc ,
  custrcvplc.loca_code_to_transport_custrcvplc  loca_code_to_transport_custrcvplc ,
  custrcvplc.loca_name_to_transport_custrcvplc  loca_name_to_transport_custrcvplc ,
  custrcvplc.loca_code_fm_transport_custrcvplc  loca_code_fm_transport_custrcvplc ,
  custrcvplc.loca_name_fm_transport_custrcvplc  loca_name_fm_transport_custrcvplc ,
custdlv.duration  custdlv_duration,
  opeitm.unit_name_size  unit_name_size ,
  opeitm.unit_code_size  unit_code_size ,
  opeitm.opeitm_unit_id_weight  opeitm_unit_id_weight ,
  opeitm.opeitm_unit_id_size  opeitm_unit_id_size ,
  opeitm.opeitm_weight  opeitm_weight ,
  opeitm.opeitm_length  opeitm_length ,
  opeitm.opeitm_wide  opeitm_wide ,
  opeitm.opeitm_deth  opeitm_deth ,
  opeitm.opeitm_datascale  opeitm_datascale ,
  opeitm.opeitm_expireterm  opeitm_expireterm ,
custdlv.prjnos_id   custdlv_prjno_id
 from custdlvs   custdlv,
  r_custs  cust ,  r_custrcvplcs  custrcvplc , persons person_upd ,  r_shelfnos  shelfno_fm ,  r_opeitms  opeitm ,  r_chrgs  chrg ,  r_boxes  boxe_custdlv ,crrs  crr ,  r_transports  transport ,  r_prjnos  prjno 
  where       custdlv.custs_id = cust.id      and custdlv.custrcvplcs_id = custrcvplc.id      and custdlv.persons_id_upd = person_upd.id      and custdlv.shelfnos_id_fm = shelfno_fm.id      and custdlv.opeitms_id = opeitm.id      and custdlv.chrgs_id = chrg.id      and custdlv.boxes_id_custdlv = boxe_custdlv.id      and custdlv.crrs_id = crr.id      and custdlv.transports_id = transport.id      and custdlv.prjnos_id = prjno.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custdlvs;
 CREATE TABLE sio.sio_r_custdlvs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custdlvs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,custdlv_isudate   timestamp(6) 
,custdlv_packinglistno  varchar (40) 
,loca_code_cust  varchar (50) 
,person_code_upd  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,opeitm_packqty  numeric (38,0)
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,custdlv_depdate   timestamp(6) 
,custdlv_qty_stk  numeric (22,6)
,custdlv_qty_case  numeric (22,0)
,custdlv_lotno  varchar (50) 
,custdlv_packno  varchar (10) 
,custdlv_cartonno  varchar (50) 
,boxe_code_custdlv  varchar (50) 
,boxe_outwide_custdlv  numeric (7,2)
,boxe_name_custdlv  varchar (100) 
,boxe_outdepth_custdlv  numeric (7,2)
,boxe_outheight_custdlv  numeric (7,2)
,custdlv_weight  numeric (7,2)
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_code_fm  varchar (50) 
,shelfno_name_fm  varchar (100) 
,transport_code  varchar (50) 
,crr_code  varchar (50) 
,prjno_code  varchar (50) 
,transport_name  varchar (100) 
,prjno_name  varchar (100) 
,crr_name  varchar (100) 
,custdlv_price  numeric (38,4)
,custdlv_amt  numeric (18,4)
,loca_code_to_transport  varchar (50) 
,crr_code_bill_cust  varchar (50) 
,loca_code_transport_custrcvplc  varchar (50) 
,loca_code_fm_transport_custrcvplc  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,person_code_chrg_bill_cust  varchar (50) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,shelfno_code_opeitm  varchar (50) 
,loca_code_to_transport_custrcvplc  varchar (50) 
,unit_code_case_shp  varchar (50) 
,unit_code_box_custdlv  varchar (50) 
,loca_code_transport  varchar (50) 
,prjno_code_chil  varchar (50) 
,transport_code_custrcvplc  varchar (50) 
,unit_code_size  varchar (50) 
,loca_code_shelfno_opeitm  varchar (50) 
,unit_name_box_custdlv  varchar (100) 
,loca_name_transport  varchar (100) 
,loca_name_to_transport  varchar (100) 
,transport_name_custrcvplc  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,unit_name_size  varchar (100) 
,loca_name_fm_transport_custrcvplc  varchar (100) 
,loca_name_transport_custrcvplc  varchar (100) 
,loca_name_to_transport_custrcvplc  varchar (100) 
,loca_name_shelfno_opeitm  varchar (100) 
,crr_name_bill_cust  varchar (100) 
,shelfno_name_opeitm  varchar (100) 
,person_name_chrg_bill_cust  varchar (100) 
,prjno_name_chil  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,custdlv_updated_at   timestamp(6) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,id  numeric (38,0)
,cust_amtround  varchar (2) 
,custdlv_cust_id  numeric (38,0)
,custdlv_itm_code_client  varchar (50) 
,custdlv_custrcvplc_id  numeric (38,0)
,custdlv_gno  varchar (40) 
,custdlv_starttime   timestamp(6) 
,custdlv_expiredate   date 
,custdlv_sno  varchar (50) 
,custdlv_remark  varchar (4000) 
,custdlv_update_ip  varchar (40) 
,custdlv_created_at   timestamp(6) 
,custdlv_opeitm_id  numeric (38,0)
,person_code_chrg_cust  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,classlist_name  varchar (100) 
,classlist_code  varchar (50) 
,opeitm_expireterm  numeric (5,0)
,opeitm_datascale  numeric (38,0)
,custdlv_chrg_id  numeric (38,0)
,custdlv_invoiceno  varchar (50) 
,custdlv_cno_custinst  varchar (50) 
,custdlv_cno_custord  varchar (50) 
,custdlv_sno_custinst  varchar (50) 
,opeitm_deth  numeric (38,6)
,opeitm_wide  numeric (7,2)
,custdlv_crr_id  numeric (22,0)
,custdlv_taxrate  numeric (2,0)
,itm_taxflg  varchar (20) 
,crr_decimal  numeric (1,0)
,custdlv_tax  numeric (38,4)
,custdlv_contractprice  varchar (20) 
,opeitm_length  numeric (38,6)
,opeitm_weight  numeric (7,2)
,custdlv_prjno_id  numeric (38,0)
,custdlv_duration  numeric (38,2)
,opeitm_shpordauto  varchar (1) 
,opeitm_prdpurordauto  varchar (1) 
,custdlv_duedate_custord   timestamp(6) 
,transport_duration  numeric (38,2)
,custdlv_id  numeric (38,0)
,custdlv_boxe_id_custdlv  numeric (38,0)
,custdlv_transport_id  numeric (38,0)
,custdlv_dimension  varchar (20) 
,opeitm_itmtype  varchar (1) 
,person_name_upd  varchar (100) 
,loca_name_cust  varchar (100) 
,person_sect_id_chrg_cust  numeric (22,0)
,itm_classlist_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,opeitm_shelfno_id_opeitm  numeric (22,0)
,opeitm_boxe_id  numeric (22,0)
,bill_crr_id_bill_cust  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
,opeitm_unit_id_weight  numeric (22,0)
,opeitm_unit_id_size  numeric (22,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,bill_chrg_id_bill_cust  numeric (22,0)
,opeitm_unit_id_case_shp  numeric (38,0)
,opeitm_unit_id_case_prdpur  numeric (38,0)
,boxe_unit_id_box_custdlv  numeric (38,0)
,custdlv_person_id_upd  numeric (22,0)
,custdlv_shelfno_id_fm  numeric (22,0)
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
 CREATE INDEX sio_r_custdlvs_uk1 
  ON sio.sio_r_custdlvs(id,sio_id); 

 drop sequence  if exists sio.sio_r_custdlvs_seq ;
 create sequence sio.sio_r_custdlvs_seq ;
  drop view if  exists r_custinsts cascade ; 
 create or replace view r_custinsts as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
custinst.isudate  custinst_isudate,
custinst.created_at  custinst_created_at,
custinst.sno  custinst_sno,
custinst.amt  custinst_amt,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
custinst.updated_at  custinst_updated_at,
custinst.remark  custinst_remark,
custinst.update_ip  custinst_update_ip,
custinst.price  custinst_price,
custinst.qty  custinst_qty,
custinst.duedate  custinst_duedate,
custinst.persons_id_upd    custinst_person_id_upd,
custinst.id  custinst_id,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
custinst.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  prjno.prjno_name  prjno_name ,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
custinst.expiredate  custinst_expiredate,
  prjno.prjno_code  prjno_code ,
custinst.cno  custinst_cno,
custinst.custs_id   custinst_cust_id,
custinst.gno  custinst_gno,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
custinst.custrcvplcs_id   custinst_custrcvplc_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.cust_amtround  cust_amtround ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  crr.code  crr_code ,
  crr.name  crr_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
custinst.chrgs_id   custinst_chrg_id,
custinst.itm_code_client  custinst_itm_code_client,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
custinst.starttime  custinst_starttime,
custinst.shelfnos_id_fm   custinst_shelfno_id_fm,
custinst.opeitms_id   custinst_opeitm_id,
  prjno.prjno_name_chil  prjno_name_chil ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
custinst.sno_custord  custinst_sno_custord,
custinst.cno_custord  custinst_cno_custord,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
custinst.contents  custinst_contents,
custinst.prjnos_id   custinst_prjno_id,
custinst.crrs_id  custinst_crr_id,
  opeitm.unit_name_weight  unit_name_weight ,
  opeitm.unit_code_weight  unit_code_weight ,
custinst.lotno  custinst_lotno,
custinst.packno  custinst_packno,
custinst.taxrate  custinst_taxrate,
  opeitm.itm_taxflg  itm_taxflg ,
  crr.decimal  crr_decimal ,
custinst.contractprice  custinst_contractprice,
  cust.bill_chrg_id_bill_cust  bill_chrg_id_bill_cust ,
  cust.person_code_chrg_bill_cust  person_code_chrg_bill_cust ,
  cust.person_name_chrg_bill_cust  person_name_chrg_bill_cust ,
  cust.bill_crr_id_bill_cust  bill_crr_id_bill_cust ,
  cust.crr_code_bill_cust  crr_code_bill_cust ,
  cust.crr_name_bill_cust  crr_name_bill_cust ,
custinst.qty_stk  custinst_qty_stk,
custinst.tax  custinst_tax,
  transport.transport_duration  transport_duration ,
custinst.transports_id   custinst_transport_id,
  custrcvplc.transport_code_custrcvplc  transport_code_custrcvplc ,
  custrcvplc.transport_name_custrcvplc  transport_name_custrcvplc ,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
  custrcvplc.loca_code_transport_custrcvplc  loca_code_transport_custrcvplc ,
  custrcvplc.loca_name_transport_custrcvplc  loca_name_transport_custrcvplc ,
  custrcvplc.loca_code_to_transport_custrcvplc  loca_code_to_transport_custrcvplc ,
  custrcvplc.loca_name_to_transport_custrcvplc  loca_name_to_transport_custrcvplc ,
  custrcvplc.loca_code_fm_transport_custrcvplc  loca_code_fm_transport_custrcvplc ,
  custrcvplc.loca_name_fm_transport_custrcvplc  loca_name_fm_transport_custrcvplc ,
custinst.duration  custinst_duration,
  opeitm.unit_name_size  unit_name_size ,
  opeitm.unit_code_size  unit_code_size ,
  opeitm.opeitm_unit_id_weight  opeitm_unit_id_weight ,
  opeitm.opeitm_unit_id_size  opeitm_unit_id_size ,
  opeitm.opeitm_weight  opeitm_weight ,
  opeitm.opeitm_length  opeitm_length ,
  opeitm.opeitm_wide  opeitm_wide ,
  opeitm.opeitm_deth  opeitm_deth ,
  opeitm.opeitm_datascale  opeitm_datascale ,
  opeitm.opeitm_expireterm  opeitm_expireterm ,
custinst.qty_case  custinst_qty_case
 from custinsts   custinst,
 persons person_upd ,  r_custs  cust ,  r_custrcvplcs  custrcvplc ,  r_chrgs  chrg ,  r_shelfnos  shelfno_fm ,  r_opeitms  opeitm ,  r_prjnos  prjno ,crrs  crr ,  r_transports  transport 
  where       custinst.persons_id_upd = person_upd.id      and custinst.custs_id = cust.id      and custinst.custrcvplcs_id = custrcvplc.id      and custinst.chrgs_id = chrg.id      and custinst.shelfnos_id_fm = shelfno_fm.id      and custinst.opeitms_id = opeitm.id      and custinst.prjnos_id = prjno.id      and custinst.crrs_id = crr.id      and custinst.transports_id = transport.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custinsts;
 CREATE TABLE sio.sio_r_custinsts (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custinsts_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,custinst_isudate   timestamp(6) 
,custinst_cno_custord  varchar (50) 
,custinst_duedate   timestamp(6) 
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,loca_code_custrcvplc  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,custinst_qty_stk  numeric (22,6)
,custinst_price  numeric (38,4)
,custinst_amt  numeric (38,4)
,custinst_itm_code_client  varchar (50) 
,custinst_starttime   timestamp(6) 
,custinst_sno_custord  varchar (50) 
,custinst_qty_case  numeric (22,6)
,custinst_qty  numeric (38,4)
,crr_code  varchar (50) 
,prjno_code  varchar (50) 
,classlist_code  varchar (50) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,prjno_name  varchar (100) 
,classlist_name  varchar (100) 
,custinst_cno  varchar (40) 
,crr_name  varchar (100) 
,custinst_gno  varchar (40) 
,prjno_code_chil  varchar (50) 
,person_code_chrg  varchar (50) 
,unit_code_size  varchar (50) 
,loca_code_fm_transport_custrcvplc  varchar (50) 
,loca_code_to_transport_custrcvplc  varchar (50) 
,loca_code_transport_custrcvplc  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,loca_code_to_transport  varchar (50) 
,loca_code_transport  varchar (50) 
,transport_code_custrcvplc  varchar (50) 
,crr_code_bill_cust  varchar (50) 
,person_code_chrg_bill_cust  varchar (50) 
,unit_code_weight  varchar (50) 
,loca_code_shelfno_opeitm  varchar (50) 
,shelfno_code_opeitm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,shelfno_code_fm  varchar (50) 
,transport_code  varchar (50) 
,transport_name  varchar (100) 
,transport_duration  numeric (38,2)
,cust_amtround  varchar (2) 
,loca_name_to_transport_custrcvplc  varchar (100) 
,shelfno_name_fm  varchar (100) 
,loca_name_shelfno_fm  varchar (100) 
,prjno_name_chil  varchar (100) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,shelfno_name_opeitm  varchar (100) 
,loca_name_shelfno_opeitm  varchar (100) 
,unit_name_weight  varchar (100) 
,person_name_chrg_bill_cust  varchar (100) 
,crr_name_bill_cust  varchar (100) 
,transport_name_custrcvplc  varchar (100) 
,loca_name_transport  varchar (100) 
,loca_name_to_transport  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,loca_name_transport_custrcvplc  varchar (100) 
,person_name_chrg  varchar (100) 
,loca_name_fm_transport_custrcvplc  varchar (100) 
,unit_name_size  varchar (100) 
,custinst_crr_id  numeric (22,0)
,custinst_transport_id  numeric (38,0)
,opeitm_weight  numeric (7,2)
,opeitm_datascale  numeric (38,0)
,opeitm_length  numeric (38,6)
,custinst_tax  numeric (38,4)
,opeitm_wide  numeric (7,2)
,opeitm_deth  numeric (38,6)
,custinst_lotno  varchar (50) 
,custinst_packno  varchar (10) 
,custinst_taxrate  numeric (2,0)
,itm_taxflg  varchar (20) 
,crr_decimal  numeric (1,0)
,custinst_contractprice  varchar (20) 
,custinst_duration  numeric (38,2)
,opeitm_expireterm  numeric (5,0)
,custinst_contents  varchar (4000) 
,custinst_prjno_id  numeric (38,0)
,person_code_chrg_cust  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,custinst_remark  varchar (4000) 
,custinst_expiredate   date 
,custinst_sno  varchar (50) 
,opeitm_unit_id_size  numeric (22,0)
,itm_unit_id  numeric (22,0)
,bill_chrg_id_bill_cust  numeric (22,0)
,opeitm_itm_id  numeric (38,0)
,bill_crr_id_bill_cust  numeric (22,0)
,opeitm_unit_id_weight  numeric (22,0)
,cust_loca_id_cust  numeric (38,0)
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,custinst_chrg_id  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,boxe_unit_id_box  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,custinst_shelfno_id_fm  numeric (22,0)
,custinst_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,custinst_cust_id  numeric (22,0)
,id  numeric (22,0)
,custinst_updated_at   timestamp(6) 
,custinst_update_ip  varchar (40) 
,custinst_person_id_upd  numeric (22,0)
,custinst_custrcvplc_id  numeric (22,0)
,custinst_id  numeric (22,0)
,custinst_created_at   timestamp(6) 
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
 CREATE INDEX sio_r_custinsts_uk1 
  ON sio.sio_r_custinsts(id,sio_id); 

 drop sequence  if exists sio.sio_r_custinsts_seq ;
 create sequence sio.sio_r_custinsts_seq ;
  drop view if  exists r_custords cascade ; 
 create or replace view r_custords as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
custord.remark  custord_remark,
custord.update_ip  custord_update_ip,
custord.duedate  custord_duedate,
custord.updated_at  custord_updated_at,
custord.price  custord_price,
custord.id  custord_id,
custord.persons_id_upd    custord_person_id_upd,
custord.created_at  custord_created_at,
custord.toduedate  custord_toduedate,
custord.expiredate  custord_expiredate,
custord.sno  custord_sno,
  cust.loca_name_cust  loca_name_cust ,
custord.amt  custord_amt,
custord.qty  custord_qty,
custord.isudate  custord_isudate,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
custord.id id,
custord.custs_id   custord_cust_id,
custord.sno_custsch  custord_sno_custsch,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  prjno.prjno_name  prjno_name ,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
custord.cno  custord_cno,
  prjno.prjno_code  prjno_code ,
custord.prjnos_id   custord_prjno_id,
custord.gno  custord_gno,
  custrcvplc.custrcvplc_loca_id_custrcvplc  custrcvplc_loca_id_custrcvplc ,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
custord.chrgs_id   custord_chrg_id,
  cust.cust_amtround  cust_amtround ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  crr.code  crr_code ,
  crr.name  crr_name ,
custord.custrcvplcs_id   custord_custrcvplc_id,
custord.itm_code_client  custord_itm_code_client,
custord.contents  custord_contents,
  prjno.prjno_code_chil  prjno_code_chil ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
custord.opeitms_id   custord_opeitm_id,
custord.starttime  custord_starttime,
custord.shelfnos_id_fm   custord_shelfno_id_fm,
  prjno.prjno_name_chil  prjno_name_chil ,
  prjno.prjno_priority  prjno_priority ,
  opeitm.opeitm_shelfno_id_to_opeitm  opeitm_shelfno_id_to_opeitm ,
  opeitm.shelfno_code_to_opeitm  shelfno_code_to_opeitm ,
  opeitm.shelfno_name_to_opeitm  shelfno_name_to_opeitm ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.loca_code_shelfno_to_opeitm  loca_code_shelfno_to_opeitm ,
  opeitm.loca_name_shelfno_to_opeitm  loca_name_shelfno_to_opeitm ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custord.crrs_id  custord_crr_id,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype ,
  opeitm.unit_name_weight  unit_name_weight ,
  opeitm.unit_code_weight  unit_code_weight ,
custord.taxrate  custord_taxrate,
  opeitm.itm_taxflg  itm_taxflg ,
custord.masterprice  custord_masterprice,
  crr.decimal  crr_decimal ,
custord.tax  custord_tax,
custord.contractprice  custord_contractprice,
  cust.loca_code_bill_cust  loca_code_bill_cust ,
  cust.loca_name_bill_cust  loca_name_bill_cust ,
  cust.person_code_chrg_bill_cust  person_code_chrg_bill_cust ,
  cust.person_name_chrg_bill_cust  person_name_chrg_bill_cust ,
  transport.transport_duration  transport_duration ,
custord.transports_id   custord_transport_id,
  custrcvplc.transport_code_custrcvplc  transport_code_custrcvplc ,
  custrcvplc.transport_name_custrcvplc  transport_name_custrcvplc ,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
  custrcvplc.loca_code_transport_custrcvplc  loca_code_transport_custrcvplc ,
  custrcvplc.loca_name_transport_custrcvplc  loca_name_transport_custrcvplc ,
  custrcvplc.loca_code_to_transport_custrcvplc  loca_code_to_transport_custrcvplc ,
  custrcvplc.loca_name_to_transport_custrcvplc  loca_name_to_transport_custrcvplc ,
  custrcvplc.loca_code_fm_transport_custrcvplc  loca_code_fm_transport_custrcvplc ,
  custrcvplc.loca_name_fm_transport_custrcvplc  loca_name_fm_transport_custrcvplc ,
custord.duration  custord_duration,
  opeitm.unit_name_size  unit_name_size ,
  opeitm.unit_code_size  unit_code_size ,
  opeitm.opeitm_unit_id_weight  opeitm_unit_id_weight ,
  opeitm.opeitm_unit_id_size  opeitm_unit_id_size ,
  opeitm.opeitm_weight  opeitm_weight ,
  opeitm.opeitm_length  opeitm_length ,
  opeitm.opeitm_wide  opeitm_wide ,
  opeitm.opeitm_deth  opeitm_deth ,
  opeitm.opeitm_datascale  opeitm_datascale ,
  opeitm.opeitm_expireterm  opeitm_expireterm ,
custord.qty_case  custord_qty_case
 from custords   custord,
 persons person_upd ,  r_custs  cust ,  r_prjnos  prjno ,  r_chrgs  chrg ,  r_custrcvplcs  custrcvplc ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_fm ,crrs  crr ,  r_transports  transport 
  where       custord.persons_id_upd = person_upd.id      and custord.custs_id = cust.id      and custord.prjnos_id = prjno.id      and custord.chrgs_id = chrg.id      and custord.custrcvplcs_id = custrcvplc.id      and custord.opeitms_id = opeitm.id      and custord.shelfnos_id_fm = shelfno_fm.id      and custord.crrs_id = crr.id      and custord.transports_id = transport.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custords;
 CREATE TABLE sio.sio_r_custords (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custords_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,custord_isudate   timestamp(6) 
,custord_cno  varchar (40) 
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,custord_itm_code_client  varchar (50) 
,custord_duedate   timestamp(6) 
,custord_qty_case  numeric (22,6)
,opeitm_packqty  numeric (38,0)
,custord_qty  numeric (18,4)
,crr_code  varchar (50) 
,crr_name  varchar (100) 
,custord_masterprice  numeric (38,4)
,custord_price  numeric (22,4)
,custord_contractprice  varchar (20) 
,custord_amt  numeric (18,4)
,person_code_chrg_cust  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,prjno_priority  numeric (38,0)
,prjno_code_chil  varchar (50) 
,prjno_name_chil  varchar (100) 
,crr_decimal  numeric (1,0)
,custord_starttime   timestamp(6) 
,custord_toduedate   timestamp(6) 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,custord_sno  varchar (50) 
,custord_gno  varchar (40) 
,unit_code_size  varchar (50) 
,unit_code_weight  varchar (50) 
,loca_code_custrcvplc  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,transport_code_custrcvplc  varchar (50) 
,loca_code_shelfno_opeitm  varchar (50) 
,loca_name_shelfno_to_opeitm  varchar (100) 
,loca_name_shelfno_opeitm  varchar (100) 
,shelfno_code_opeitm  varchar (50) 
,shelfno_code_to_opeitm  varchar (50) 
,shelfno_name_opeitm  varchar (100) 
,shelfno_name_to_opeitm  varchar (100) 
,loca_code_shelfno_to_opeitm  varchar (50) 
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,loca_code_transport_custrcvplc  varchar (50) 
,loca_code_to_transport_custrcvplc  varchar (50) 
,loca_name_fm_transport_custrcvplc  varchar (100) 
,transport_code  varchar (50) 
,shelfno_code_fm  varchar (50) 
,shelfno_name_fm  varchar (100) 
,transport_name  varchar (100) 
,transport_duration  numeric (38,2)
,loca_name_to_transport  varchar (100) 
,loca_code_transport  varchar (50) 
,loca_name_transport  varchar (100) 
,loca_code_fm_transport  varchar (50) 
,loca_name_fm_transport  varchar (100) 
,loca_code_to_transport  varchar (50) 
,unit_name_size  varchar (100) 
,unit_name_weight  varchar (100) 
,loca_code_bill_cust  varchar (50) 
,loca_name_bill_cust  varchar (100) 
,person_code_chrg  varchar (50) 
,person_name_chrg  varchar (100) 
,person_code_chrg_bill_cust  varchar (50) 
,person_name_chrg_bill_cust  varchar (100) 
,custord_shelfno_id_fm  numeric (22,0)
,cust_amtround  varchar (2) 
,unit_code_case_prdpur  varchar (50) 
,unit_name_case_prdpur  varchar (100) 
,opeitm_wide  numeric (7,2)
,opeitm_length  numeric (38,6)
,opeitm_datascale  numeric (38,0)
,opeitm_deth  numeric (38,6)
,custord_taxrate  numeric (2,0)
,itm_taxflg  varchar (20) 
,opeitm_shpordauto  varchar (1) 
,custord_chrg_id  numeric (38,0)
,opeitm_prdpurordauto  varchar (1) 
,opeitm_itmtype  varchar (1) 
,custord_crr_id  numeric (22,0)
,custord_transport_id  numeric (38,0)
,custord_sno_custsch  varchar (50) 
,opeitm_expireterm  numeric (5,0)
,opeitm_weight  numeric (7,2)
,custord_duration  numeric (38,2)
,custord_tax  numeric (38,4)
,loca_code_fm_transport_custrcvplc  varchar (50) 
,transport_name_custrcvplc  varchar (100) 
,loca_name_to_transport_custrcvplc  varchar (100) 
,loca_name_transport_custrcvplc  varchar (100) 
,person_code_upd  varchar (50) 
,person_name_upd  varchar (100) 
,custord_expiredate   date 
,custord_contents  varchar (4000) 
,custord_remark  varchar (4000) 
,opeitm_itm_id  numeric (38,0)
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,opeitm_shelfno_id_to_opeitm  numeric (38,0)
,custord_opeitm_id  numeric (38,0)
,shelfno_loca_id_shelfno_fm  numeric (38,0)
,custord_custrcvplc_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,custrcvplc_loca_id_custrcvplc  numeric (38,0)
,custord_prjno_id  numeric (38,0)
,cust_loca_id_cust  numeric (38,0)
,opeitm_unit_id_weight  numeric (22,0)
,opeitm_unit_id_size  numeric (22,0)
,opeitm_shelfno_id_opeitm  numeric (22,0)
,custord_updated_at   timestamp(6) 
,custord_id  numeric (22,0)
,custord_person_id_upd  numeric (22,0)
,custord_created_at   timestamp(6) 
,custord_update_ip  varchar (40) 
,id  numeric (22,0)
,custord_cust_id  numeric (22,0)
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
 CREATE INDEX sio_r_custords_uk1 
  ON sio.sio_r_custords(id,sio_id); 

 drop sequence  if exists sio.sio_r_custords_seq ;
 create sequence sio.sio_r_custords_seq ;
  drop view if  exists r_custschs cascade ; 
 create or replace view r_custschs as select  
  chrg.person_name_chrg  person_name_chrg ,
  chrg.person_code_chrg  person_code_chrg ,
  opeitm.itm_name  itm_name ,
  opeitm.itm_code  itm_code ,
  opeitm.itm_unit_id  itm_unit_id ,
  opeitm.opeitm_processseq  opeitm_processseq ,
  opeitm.opeitm_packqty  opeitm_packqty ,
  opeitm.opeitm_priority  opeitm_priority ,
  opeitm.opeitm_itm_id  opeitm_itm_id ,
  cust.loca_name_cust  loca_name_cust ,
  cust.loca_code_cust  loca_code_cust ,
  custrcvplc.loca_code_custrcvplc  loca_code_custrcvplc ,
  custrcvplc.loca_name_custrcvplc  loca_name_custrcvplc ,
  transport.transport_code  transport_code ,
  transport.transport_name  transport_name ,
custsch.id id,
  cust.cust_loca_id_cust  cust_loca_id_cust ,
  prjno.prjno_name  prjno_name ,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
  prjno.prjno_code  prjno_code ,
custsch.cno  custsch_cno,
custsch.isudate  custsch_isudate,
custsch.prjnos_id   custsch_prjno_id,
custsch.expiredate  custsch_expiredate,
custsch.updated_at  custsch_updated_at,
custsch.sno  custsch_sno,
custsch.price  custsch_price,
custsch.remark  custsch_remark,
custsch.created_at  custsch_created_at,
custsch.update_ip  custsch_update_ip,
custsch.duedate  custsch_duedate,
custsch.id  custsch_id,
custsch.persons_id_upd    custsch_person_id_upd,
custsch.contents  custsch_contents,
custsch.custs_id   custsch_cust_id,
  chrg.chrg_person_id_chrg  chrg_person_id_chrg ,
  cust.person_code_chrg_cust  person_code_chrg_cust ,
  cust.person_name_chrg_cust  person_name_chrg_cust ,
  cust.person_sect_id_chrg_cust  person_sect_id_chrg_cust ,
  cust.cust_amtround  cust_amtround ,
  opeitm.classlist_code  classlist_code ,
  opeitm.classlist_name  classlist_name ,
  crr.code  crr_code ,
  crr.name  crr_name ,
  opeitm.boxe_unit_id_box  boxe_unit_id_box ,
  prjno.prjno_code_chil  prjno_code_chil ,
  opeitm.itm_classlist_id  itm_classlist_id ,
  shelfno_fm.shelfno_code  shelfno_code_fm ,
  shelfno_fm.shelfno_name  shelfno_name_fm ,
  shelfno_fm.loca_code_shelfno  loca_code_shelfno_fm ,
  shelfno_fm.loca_name_shelfno  loca_name_shelfno_fm ,
  shelfno_fm.shelfno_loca_id_shelfno  shelfno_loca_id_shelfno_fm ,
custsch.opeitms_id   custsch_opeitm_id,
custsch.gno  custsch_gno,
custsch.starttime  custsch_starttime,
custsch.qty_sch  custsch_qty_sch,
custsch.shelfnos_id_fm   custsch_shelfno_id_fm,
custsch.amt_sch  custsch_amt_sch,
  prjno.prjno_name_chil  prjno_name_chil ,
  opeitm.shelfno_loca_id_shelfno_to_opeitm  shelfno_loca_id_shelfno_to_opeitm ,
  opeitm.unit_name_case_shp  unit_name_case_shp ,
  opeitm.unit_name_case_prdpur  unit_name_case_prdpur ,
  opeitm.unit_code_case_prdpur  unit_code_case_prdpur ,
custsch.custrcvplcs_id   custsch_custrcvplc_id,
  opeitm.opeitm_shelfno_id_opeitm  opeitm_shelfno_id_opeitm ,
  opeitm.shelfno_code_opeitm  shelfno_code_opeitm ,
  opeitm.shelfno_name_opeitm  shelfno_name_opeitm ,
  opeitm.shelfno_loca_id_shelfno_opeitm  shelfno_loca_id_shelfno_opeitm ,
  opeitm.loca_code_shelfno_opeitm  loca_code_shelfno_opeitm ,
  opeitm.loca_name_shelfno_opeitm  loca_name_shelfno_opeitm ,
  opeitm.opeitm_shpordauto  opeitm_shpordauto ,
  opeitm.opeitm_prdpurordauto  opeitm_prdpurordauto ,
  opeitm.opeitm_itmtype  opeitm_itmtype ,
  opeitm.unit_name_weight  unit_name_weight ,
  opeitm.unit_code_weight  unit_code_weight ,
custsch.chrgs_id   custsch_chrg_id,
custsch.taxrate  custsch_taxrate,
  opeitm.itm_taxflg  itm_taxflg ,
  crr.decimal  crr_decimal ,
custsch.tax  custsch_tax,
custsch.contractprice  custsch_contractprice,
  cust.bill_chrg_id_bill_cust  bill_chrg_id_bill_cust ,
  cust.person_code_chrg_bill_cust  person_code_chrg_bill_cust ,
  cust.person_name_chrg_bill_cust  person_name_chrg_bill_cust ,
  cust.bill_crr_id_bill_cust  bill_crr_id_bill_cust ,
  cust.crr_code_bill_cust  crr_code_bill_cust ,
  cust.crr_name_bill_cust  crr_name_bill_cust ,
custsch.crrs_id  custsch_crr_id,
custsch.masterprice  custsch_masterprice,
  transport.transport_duration  transport_duration ,
  custrcvplc.transport_code_custrcvplc  transport_code_custrcvplc ,
  custrcvplc.transport_name_custrcvplc  transport_name_custrcvplc ,
  custrcvplc.transport_duration_custrcvplc  transport_duration_custrcvplc ,
custsch.transports_id   custsch_transport_id,
  transport.loca_code_transport  loca_code_transport ,
  transport.loca_name_transport  loca_name_transport ,
  transport.loca_code_to_transport  loca_code_to_transport ,
  transport.loca_name_to_transport  loca_name_to_transport ,
  transport.loca_code_fm_transport  loca_code_fm_transport ,
  transport.loca_name_fm_transport  loca_name_fm_transport ,
  custrcvplc.loca_code_transport_custrcvplc  loca_code_transport_custrcvplc ,
  custrcvplc.loca_name_transport_custrcvplc  loca_name_transport_custrcvplc ,
  custrcvplc.loca_code_to_transport_custrcvplc  loca_code_to_transport_custrcvplc ,
  custrcvplc.loca_name_to_transport_custrcvplc  loca_name_to_transport_custrcvplc ,
  custrcvplc.loca_code_fm_transport_custrcvplc  loca_code_fm_transport_custrcvplc ,
  custrcvplc.loca_name_fm_transport_custrcvplc  loca_name_fm_transport_custrcvplc ,
custsch.duration  custsch_duration,
  opeitm.unit_name_size  unit_name_size ,
  opeitm.unit_code_size  unit_code_size ,
  opeitm.opeitm_unit_id_weight  opeitm_unit_id_weight ,
  opeitm.opeitm_unit_id_size  opeitm_unit_id_size ,
  opeitm.opeitm_weight  opeitm_weight ,
  opeitm.opeitm_length  opeitm_length ,
  opeitm.opeitm_wide  opeitm_wide ,
  opeitm.opeitm_deth  opeitm_deth ,
  opeitm.opeitm_datascale  opeitm_datascale ,
  opeitm.opeitm_expireterm  opeitm_expireterm ,
custsch.qty_case  custsch_qty_case
 from custschs   custsch,
  r_prjnos  prjno , persons person_upd ,  r_custs  cust ,  r_opeitms  opeitm ,  r_shelfnos  shelfno_fm ,  r_custrcvplcs  custrcvplc ,  r_chrgs  chrg ,crrs  crr ,  r_transports  transport 
  where       custsch.prjnos_id = prjno.id      and custsch.persons_id_upd = person_upd.id      and custsch.custs_id = cust.id      and custsch.opeitms_id = opeitm.id      and custsch.shelfnos_id_fm = shelfno_fm.id      and custsch.custrcvplcs_id = custrcvplc.id      and custsch.chrgs_id = chrg.id      and custsch.crrs_id = crr.id      and custsch.transports_id = transport.id     ;
 DROP TABLE IF EXISTS sio.sio_r_custschs;
 CREATE TABLE sio.sio_r_custschs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_custschs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,custsch_isudate   timestamp(6) 
,custsch_cno  varchar (40) 
,loca_code_cust  varchar (50) 
,loca_name_cust  varchar (100) 
,custsch_duedate   timestamp(6) 
,itm_code  varchar (50) 
,itm_name  varchar (100) 
,opeitm_processseq  numeric (3,0)
,opeitm_priority  numeric (3,0)
,crr_code  varchar (50) 
,crr_name  varchar (100) 
,custsch_qty_sch  numeric (22,6)
,custsch_masterprice  numeric (38,4)
,custsch_price  numeric (38,4)
,custsch_amt_sch  numeric (38,4)
,itm_taxflg  varchar (20) 
,custsch_taxrate  numeric (2,0)
,custsch_tax  numeric (38,4)
,loca_code_shelfno_opeitm  varchar (50) 
,loca_name_shelfno_opeitm  varchar (100) 
,shelfno_code_opeitm  varchar (50) 
,shelfno_name_opeitm  varchar (100) 
,loca_code_shelfno_fm  varchar (50) 
,loca_name_shelfno_fm  varchar (100) 
,shelfno_code_fm  varchar (50) 
,shelfno_name_fm  varchar (100) 
,loca_code_custrcvplc  varchar (50) 
,loca_name_custrcvplc  varchar (100) 
,person_code_chrg_cust  varchar (50) 
,person_name_chrg_cust  varchar (100) 
,transport_code_custrcvplc  varchar (50) 
,transport_name_custrcvplc  varchar (100) 
,transport_code  varchar (50) 
,transport_name  varchar (100) 
,transport_duration_custrcvplc  numeric (38,2)
,transport_duration  numeric (38,2)
,prjno_code  varchar (50) 
,prjno_name  varchar (100) 
,prjno_code_chil  varchar (50) 
,custsch_expiredate   date 
,classlist_code  varchar (50) 
,classlist_name  varchar (100) 
,person_code_chrg  varchar (50) 
,loca_code_transport  varchar (50) 
,crr_code_bill_cust  varchar (50) 
,person_code_chrg_bill_cust  varchar (50) 
,loca_code_to_transport  varchar (50) 
,loca_code_fm_transport  varchar (50) 
,unit_code_weight  varchar (50) 
,loca_code_transport_custrcvplc  varchar (50) 
,loca_code_to_transport_custrcvplc  varchar (50) 
,loca_code_fm_transport_custrcvplc  varchar (50) 
,opeitm_packqty  numeric (38,0)
,unit_code_size  varchar (50) 
,unit_code_case_prdpur  varchar (50) 
,person_name_chrg  varchar (100) 
,prjno_name_chil  varchar (100) 
,unit_name_case_shp  varchar (100) 
,unit_name_case_prdpur  varchar (100) 
,unit_name_weight  varchar (100) 
,person_name_chrg_bill_cust  varchar (100) 
,crr_name_bill_cust  varchar (100) 
,loca_name_transport  varchar (100) 
,loca_name_to_transport  varchar (100) 
,loca_name_fm_transport  varchar (100) 
,loca_name_transport_custrcvplc  varchar (100) 
,loca_name_to_transport_custrcvplc  varchar (100) 
,loca_name_fm_transport_custrcvplc  varchar (100) 
,unit_name_size  varchar (100) 
,custsch_starttime   timestamp(6) 
,custsch_sno  varchar (50) 
,cust_amtround  varchar (2) 
,opeitm_itmtype  varchar (1) 
,custsch_chrg_id  numeric (38,0)
,custsch_qty_case  numeric (22,6)
,opeitm_shpordauto  varchar (1) 
,opeitm_prdpurordauto  varchar (1) 
,crr_decimal  numeric (1,0)
,custsch_contractprice  varchar (20) 
,custsch_crr_id  numeric (22,0)
,custsch_transport_id  numeric (38,0)
,opeitm_weight  numeric (7,2)
,opeitm_length  numeric (38,6)
,opeitm_wide  numeric (7,2)
,opeitm_deth  numeric (38,6)
,opeitm_datascale  numeric (38,0)
,custsch_gno  varchar (40) 
,opeitm_expireterm  numeric (5,0)
,custsch_duration  numeric (38,2)
,custsch_custrcvplc_id  numeric (38,0)
,custsch_remark  varchar (4000) 
,custsch_contents  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,custsch_prjno_id  numeric (38,0)
,shelfno_loca_id_shelfno_to_opeitm  numeric (38,0)
,itm_classlist_id  numeric (38,0)
,boxe_unit_id_box  numeric (22,0)
,cust_loca_id_cust  numeric (38,0)
,custsch_opeitm_id  numeric (38,0)
,id  numeric (38,0)
,shelfno_loca_id_shelfno_opeitm  numeric (38,0)
,opeitm_itm_id  numeric (38,0)
,chrg_person_id_chrg  numeric (38,0)
,custsch_cust_id  numeric (38,0)
,itm_unit_id  numeric (22,0)
,custsch_shelfno_id_fm  numeric (22,0)
,bill_chrg_id_bill_cust  numeric (22,0)
,custsch_person_id_upd  numeric (38,0)
,opeitm_unit_id_weight  numeric (22,0)
,bill_crr_id_bill_cust  numeric (22,0)
,custsch_id  numeric (38,0)
,opeitm_unit_id_size  numeric (22,0)
,opeitm_shelfno_id_opeitm  numeric (22,0)
,custsch_created_at   timestamp(6) 
,custsch_update_ip  varchar (40) 
,person_sect_id_chrg_cust  numeric (22,0)
,custsch_updated_at   timestamp(6) 
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
 CREATE INDEX sio_r_custschs_uk1 
  ON sio.sio_r_custschs(id,sio_id); 

 drop sequence  if exists sio.sio_r_custschs_seq ;
 create sequence sio.sio_r_custschs_seq ;
