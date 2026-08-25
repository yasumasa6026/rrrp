
 --- ----------------------------------------------
 --- please do the below sql
 --- and rerun 'Create table,view,screen'  again
 --- ----------------------------------------------
 --- alter table processreqs DROP COLUMN reqparams CASCADE;

 --- first 
 --- 使用しているview ,fields check
 --- select pobject_code_scr,pobject_code_sfd,
							---   case screenfield_selection when 1 then '選択有' else '' end selection,
							---	case screenfield_hideflg when 1 then '' else '表示有' end display,
							---   case screenfield_indisp when 1 then '必須' else '' end inquire from r_screenfields 
 ---- where  pobject_code_sfd = 'processreq_reqparams'
 --- update screenfields set expiredate = '2000-01-01',remark = 'auto delete because of DROP COLUMN reqparams' 
 ---        ,updated_at = current_date  ,selection = '0'
 ---        where id in  (select id from r_screenfields where  pobject_code_sfd = 'processreq_reqparams' 
 ---        and  pobject_code_scr like '%_processreqs'  and screenfield_selection = '1');
  drop view if  exists r_processreqs cascade ; 
 create or replace view r_processreqs as select  
processreq.remark  processreq_remark,
processreq.created_at  processreq_created_at,
processreq.update_ip  processreq_update_ip,
processreq.updated_at  processreq_updated_at,
processreq.id  processreq_id,
processreq.persons_id_upd    processreq_person_id_upd,
processreq.contents  processreq_contents,
processreq.tblname  processreq_tblname,
processreq.tblid  processreq_tblid,
processreq.result_f  processreq_result_f,
processreq.id id,
 person_upd.code  person_code_upd,
 person_upd.name  person_name_upd,
processreq.reqparams  processreq_reqparams,
processreq.seqno  processreq_seqno,
  mkprdpurord.mkprdpurord_tblname  mkprdpurord_tblname ,
  mkprdpurord.mkprdpurord_message_code  mkprdpurord_message_code ,
  mkprdpurord.mkprdpurord_sno_org  mkprdpurord_sno_org ,
  mkprdpurord.mkprdpurord_itm_code_pare  mkprdpurord_itm_code_pare ,
  mkprdpurord.mkprdpurord_itm_code_trn  mkprdpurord_itm_code_trn ,
  mkprdpurord.mkprdpurord_sno_pare  mkprdpurord_sno_pare ,
  mkprdpurord.mkprdpurord_itm_code_org  mkprdpurord_itm_code_org ,
  mkprdpurord.mkprdpurord_itm_name_org  mkprdpurord_itm_name_org ,
  mkprdpurord.mkprdpurord_itm_name_trn  mkprdpurord_itm_name_trn ,
  mkprdpurord.mkprdpurord_itm_name_pare  mkprdpurord_itm_name_pare ,
  mkprdpurord.mkprdpurord_person_code_chrg_org  mkprdpurord_person_code_chrg_org ,
  mkprdpurord.mkprdpurord_person_code_chrg_pare  mkprdpurord_person_code_chrg_pare ,
  mkprdpurord.mkprdpurord_person_code_chrg_trn  mkprdpurord_person_code_chrg_trn ,
  mkprdpurord.mkprdpurord_person_name_chrg_org  mkprdpurord_person_name_chrg_org ,
  mkprdpurord.mkprdpurord_person_name_chrg_pare  mkprdpurord_person_name_chrg_pare ,
  mkprdpurord.mkprdpurord_person_name_chrg_trn  mkprdpurord_person_name_chrg_trn ,
processreq.loca_code_pare  mkprdpurord_loca_code_pare,
processreq.loca_code_trn  mkprdpurord_loca_code_trn,
processreq.loca_name_trn  mkprdpurord_loca_name_trn,
processreq.loca_name_pare  mkprdpurord_loca_name_pare,
processreq.loca_code_org  mkprdpurord_loca_code_org,
processreq.loca_name_org  mkprdpurord_loca_name_org,
  mkprdpurord.mkprdpurord_sno_trn  mkprdpurord_sno_trn ,
  mkprdpurord.mkprdpurord_shelfno_code_org  mkprdpurord_shelfno_code_org ,
  mkprdpurord.mkprdpurord_shelfno_code_pare  mkprdpurord_shelfno_code_pare ,
  mkprdpurord.mkprdpurord_shelfno_code_trn  mkprdpurord_shelfno_code_trn ,
  mkprdpurord.mkprdpurord_shelfno_name_org  mkprdpurord_shelfno_name_org ,
  mkprdpurord.mkprdpurord_shelfno_name_pare  mkprdpurord_shelfno_name_pare ,
  mkprdpurord.mkprdpurord_shelfno_name_trn  mkprdpurord_shelfno_name_trn ,
processreq.segment  processreq_segment,
processreq.mkprdpurords_id   processreq_mkprdpurord_id,
processreq.tbldata  processreq_tbldata,
processreq.gantt  processreq_gantt,
processreq.child  processreq_child
 from processreqs   processreq,
 persons person_upd ,  r_mkprdpurords  mkprdpurord 
  where       processreq.persons_id_upd = person_upd.id      and processreq.mkprdpurords_id = mkprdpurord.id     ;
 DROP TABLE IF EXISTS sio.sio_r_processreqs;
 CREATE TABLE sio.sio_r_processreqs (
          sio_id numeric(22,0)  CONSTRAINT SIO_r_processreqs_id_pk PRIMARY KEY           ,sio_user_code numeric(22,0)
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
,processreq_id  numeric (38,0)
,processreq_result_f  varchar (1) 
,processreq_tblname  varchar (30) 
,processreq_tblid  numeric (38,0)
,processreq_seqno  numeric (38,0)
,processreq_reqparams  varchar (8192) 
,mkprdpurord_message_code  varchar (256) 
,mkprdpurord_person_code_chrg_trn  varchar (50) 
,mkprdpurord_person_code_chrg_pare  varchar (50) 
,mkprdpurord_person_code_chrg_org  varchar (50) 
,mkprdpurord_itm_code_org  varchar (50) 
,mkprdpurord_itm_code_trn  varchar (50) 
,mkprdpurord_itm_code_pare  varchar (50) 
,mkprdpurord_shelfno_code_trn  varchar (50) 
,mkprdpurord_shelfno_code_pare  varchar (50) 
,mkprdpurord_shelfno_code_org  varchar (50) 
,mkprdpurord_loca_code_org  varchar (50) 
,mkprdpurord_loca_code_trn  varchar (50) 
,mkprdpurord_loca_code_pare  varchar (50) 
,mkprdpurord_loca_name_org  varchar (100) 
,mkprdpurord_itm_name_org  varchar (100) 
,mkprdpurord_itm_name_trn  varchar (100) 
,mkprdpurord_itm_name_pare  varchar (100) 
,mkprdpurord_person_name_chrg_org  varchar (100) 
,mkprdpurord_person_name_chrg_pare  varchar (100) 
,mkprdpurord_person_name_chrg_trn  varchar (100) 
,mkprdpurord_loca_name_trn  varchar (100) 
,mkprdpurord_loca_name_pare  varchar (100) 
,mkprdpurord_shelfno_name_org  varchar (100) 
,mkprdpurord_shelfno_name_pare  varchar (100) 
,mkprdpurord_shelfno_name_trn  varchar (100) 
,mkprdpurord_sno_org  varchar (50) 
,mkprdpurord_sno_pare  varchar (50) 
,mkprdpurord_sno_trn  varchar (50) 
,processreq_child  varchar (4000) 
,mkprdpurord_tblname  varchar (20) 
,processreq_tbldata  varchar (4000) 
,processreq_gantt  varchar (4000) 
,processreq_segment  varchar (10) 
,processreq_mkprdpurord_id  numeric (22,0)
,processreq_contents  varchar (4000) 
,processreq_remark  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,processreq_updated_at   timestamp(6) 
,processreq_person_id_upd  numeric (38,0)
,id  numeric (38,0)
,processreq_update_ip  varchar (40) 
,processreq_created_at   timestamp(6) 
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
 CREATE INDEX sio_r_processreqs_uk1 
  ON sio.sio_r_processreqs(id,sio_id); 

 drop sequence  if exists sio.sio_r_processreqs_seq ;
 create sequence sio.sio_r_processreqs_seq ;
 ALTER TABLE processreqs ADD CONSTRAINT processreq_mkprdpurords_id FOREIGN KEY (mkprdpurords_id)
																		 REFERENCES mkprdpurords (id);
