
 alter table processreqs  ADD COLUMN seqnos varchar(4000);

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
processreq.seqno  processreq_seqno,
processreq.segment  processreq_segment,
processreq.tbldata  processreq_tbldata,
processreq.gantt  processreq_gantt,
processreq.child  processreq_child,
processreq.mkprdpurordsidparam  processreq_mkprdpurordsidparam,
processreq.seqnos  processreq_seqnos
 from processreqs   processreq,
 persons person_upd 
  where       processreq.persons_id_upd = person_upd.id     ;
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
,processreq_segment  varchar (10) 
,processreq_tbldata  varchar (4000) 
,processreq_mkprdpurordsidparam  numeric (22,0)
,processreq_child  varchar (4000) 
,processreq_gantt  varchar (4000) 
,processreq_seqnos  varchar (4000) 
,processreq_remark  varchar (4000) 
,processreq_contents  varchar (4000) 
,person_name_upd  varchar (100) 
,person_code_upd  varchar (50) 
,id  numeric (38,0)
,processreq_person_id_upd  numeric (38,0)
,processreq_updated_at   timestamp(6) 
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
