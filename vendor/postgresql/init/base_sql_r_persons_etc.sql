---
- r_persons
---
CREATE OR REPLACE VIEW public.r_persons
AS SELECT person.id,
    person.id AS person_id,
    person.remark AS person_remark,
    person.contents AS person_contents,
    person.expiredate AS person_expiredate,
    person.update_ip AS person_update_ip,
    person.created_at AS person_created_at,
    person.updated_at AS person_updated_at,
    person.persons_id_upd AS person_person_id_upd,
    person_upd.id AS person_id_upd,
    person_upd.code AS person_code_upd,
    person_upd.name AS person_name_upd,
    person.code AS person_code,
    person.name AS person_name,
    person.wage AS person_wage,
    person.sects_id AS person_sect_id,
    sect.sect_id,
    sect.sect_contents,
    sect.sect_loca_id_sect AS sect_loca_id,
    sect.loca_code_sect,
    sect.loca_name_sect,
    sect.sect_loca_id_sect AS loca_id_sect,
    person.email AS person_email,
    person.scrlvs_id AS person_scrlv_id,
    scrlv.scrlv_level1,
    scrlv.scrlv_id,
    scrlv.scrlv_code,
    person.usrgrps_id AS person_usrgrp_id,
    usrgrp.usrgrp_id,
    usrgrp.usrgrp_code,
    usrgrp.usrgrp_name,
    usrgrp.usrgrp_contents
   FROM persons person,
    persons person_upd,
    r_sects sect,
    r_scrlvs scrlv,
    r_usrgrps usrgrp
  WHERE person.persons_id_upd = person_upd.id AND person.sects_id = sect.id AND person.scrlvs_id = scrlv.id AND person.usrgrps_id = usrgrp.id;

;

---
- r_prjnos
---

-- public.r_prjnos source

CREATE OR REPLACE VIEW public.r_prjnos
AS SELECT prjno.id,
    prjno.persons_id_upd AS prjno_person_id_upd,
    prjno.updated_at AS prjno_updated_at,
    prjno.created_at AS prjno_created_at,
    prjno.update_ip AS prjno_update_ip,
    prjno.expiredate AS prjno_expiredate,
    prjno.remark AS prjno_remark,
    person_upd.code AS person_code_upd,
    person_upd.name AS person_name_upd,
    prjno.code AS prjno_code,
    prjno.name AS prjno_name,
    prjno_chil.code AS prjno_code_chil,
    prjno_chil.name AS prjno_name_chil,
    prjno.contents AS prjno_contents,
    prjno.priority AS prjno_priority,
    prjno_chil.priority AS prjno_priority_chil,
    prjno.id AS prjno_id,
    prjno_chil.id AS prjno_id_chil
   FROM prjnos prjno,
    persons person_upd,
    prjnos prjno_chil
  WHERE prjno.persons_id_upd = person_upd.id AND prjno.prjnos_id_chil = prjno_chil.id
;

-- public.r_chrgs source

CREATE OR REPLACE VIEW public.r_chrgs
AS SELECT person_chrg.name AS person_name_chrg,
    person_chrg.code AS person_code_chrg,
    person_chrg.email AS person_email_chrg,
    chrg.id,
    person_chrg.sects_id AS person_sect_id_chrg,
    sect.code AS loca_code_sect,
    sect.name AS loca_name_sect,
    person_upd.code AS person_code_upd,
    person_upd.name AS person_name_upd,
    chrg.id AS chrg_id,
    chrg.expiredate AS chrg_expiredate,
    chrg.contents AS chrg_contents,
    chrg.remark AS chrg_remark,
    chrg.persons_id_upd AS chrg_person_id_upd,
    chrg.persons_id_chrg AS chrg_person_id_chrg,
    chrg.updated_at AS chrg_updated_at,
    chrg.created_at AS chrg_created_at,
    chrg.update_ip AS chrg_update_ip
   FROM chrgs chrg,
    persons person_upd,
    persons person_chrg
     JOIN ( SELECT l.code,
            l.name,
            s.id
           FROM locas l
             JOIN sects s ON l.id = s.locas_id_sect) sect ON person_chrg.sects_id = sect.id
  WHERE chrg.persons_id_upd = person_upd.id AND chrg.persons_id_chrg = person_chrg.id
;


-- public.r_crrs source

CREATE OR REPLACE VIEW public.r_crrs
AS SELECT crr.id,
    person_upd.code AS person_code_upd,
    person_upd.name AS person_name_upd,
    crr.code AS crr_code,
    crr.name AS crr_name,
    crr.contents AS crr_contents,
    crr.id AS crr_id,
    crr.remark AS crr_remark,
    crr.expiredate AS crr_expiredate,
    crr.update_ip AS crr_update_ip,
    crr.created_at AS crr_created_at,
    crr.updated_at AS crr_updated_at,
    crr.persons_id_upd AS crr_person_id_upd,
    crr."decimal" AS crr_decimal
   FROM crrs crr,
    persons person_upd
  WHERE crr.persons_id_upd = person_upd.id
;



-- public.r_shelfnos source

CREATE OR REPLACE VIEW public.r_shelfnos
AS SELECT shelfno.code AS shelfno_code,
    shelfno.name AS shelfno_name,
    loca_shelfno.abbr AS loca_abbr_shelfno,
    loca_shelfno.zip AS loca_zip_shelfno,
    loca_shelfno.country AS loca_country_shelfno,
    loca_shelfno.prfct AS loca_prfct_shelfno,
    loca_shelfno.addr1 AS loca_addr1_shelfno,
    loca_shelfno.addr2 AS loca_addr2_shelfno,
    loca_shelfno.tel AS loca_tel_shelfno,
    loca_shelfno.fax AS loca_fax_shelfno,
    loca_shelfno.mail AS loca_mail_shelfno,
    loca_shelfno.code AS loca_code_shelfno,
    loca_shelfno.name AS loca_name_shelfno,
    shelfno.locas_id_shelfno AS shelfno_loca_id_shelfno,
    shelfno.update_ip AS shelfno_update_ip,
    shelfno.contents AS shelfno_contents,
    shelfno.remark AS shelfno_remark,
    shelfno.expiredate AS shelfno_expiredate,
    shelfno.persons_id_upd AS shelfno_person_id_upd,
    shelfno.created_at AS shelfno_created_at,
    shelfno.updated_at AS shelfno_updated_at,
    shelfno.id AS shelfno_id,
    shelfno.id
   FROM shelfnos shelfno,
    locas loca_shelfno,
    persons person_upd
  WHERE shelfno.locas_id_shelfno = loca_shelfno.id AND shelfno.persons_id_upd = person_upd.id

  ;
  
  
  -- public.r_opeitms source

CREATE OR REPLACE VIEW public.r_opeitms
AS SELECT itm.itm_name,
    itm.itm_std,
    itm.itm_code,
    itm.unit_name,
    itm.unit_code,
    itm.itm_unit_id,
    opeitm.processseq AS opeitm_processseq,
    opeitm.expiredate AS opeitm_expiredate,
    opeitm.persons_id_upd AS opeitm_person_id_upd,
    opeitm.update_ip AS opeitm_update_ip,
    opeitm.updated_at AS opeitm_updated_at,
    opeitm.packqty AS opeitm_packqty,
    opeitm.priority AS opeitm_priority,
    opeitm.created_at AS opeitm_created_at,
    opeitm.itms_id AS opeitm_itm_id,
    opeitm.id AS opeitm_id,
    opeitm.duration AS opeitm_duration,
    opeitm.id,
    opeitm.remark AS opeitm_remark,
    opeitm.operation AS opeitm_operation,
    person_upd.code AS person_code_upd,
    person_upd.name AS person_name_upd,
    opeitm.maxqty AS opeitm_maxqty,
    opeitm.autocreate_inst AS opeitm_autocreate_inst,
    opeitm.prdpur AS opeitm_prdpur,
    opeitm.safestkqty AS opeitm_safestkqty,
    opeitm.contents AS opeitm_contents,
    opeitm.autocreate_act AS opeitm_autocreate_act,
    opeitm.shuffleflg AS opeitm_shuffleflg,
    opeitm.shuffleloca AS opeitm_shuffleloca,
    opeitm.chkord_proc AS opeitm_chkord_proc,
    opeitm.esttosch AS opeitm_esttosch,
    itm.classlist_code,
    itm.classlist_name,
    boxe.boxe_boxtype,
    boxe.boxe_unit_id_box,
    boxe.boxe_code,
    boxe.boxe_name,
    opeitm.boxes_id AS opeitm_boxe_id,
    opeitm.prjalloc_flg AS opeitm_prjalloc_flg,
    opeitm.unitofduration AS opeitm_unitofduration,
    opeitm.consumauto AS opeitm_consumauto,
    opeitm.autoinst_p AS opeitm_autoinst_p,
    opeitm.autoact_p AS opeitm_autoact_p,
    itm.itm_classlist_id,
    opeitm.stktakingproc AS opeitm_stktakingproc,
    opeitm.acceptanceproc AS opeitm_acceptanceproc,
    opeitm.lotnoproc AS opeitm_lotnoproc,
    opeitm.chkinst_proc AS opeitm_chkinst_proc,
    opeitm.packnoproc AS opeitm_packnoproc,
    opeitm.optfixoterm AS opeitm_optfixoterm,
    opeitm.optfixflg AS opeitm_optfixflg,
    opeitm.shelfnos_id_to_opeitm AS opeitm_shelfno_id_to_opeitm,
    shelfno_to_opeitm.shelfno_code AS shelfno_code_to_opeitm,
    shelfno_to_opeitm.shelfno_name AS shelfno_name_to_opeitm,
    shelfno_to_opeitm.shelfno_loca_id_shelfno AS shelfno_loca_id_shelfno_to_opeitm,
    shelfno_to_opeitm.loca_code_shelfno AS loca_code_shelfno_to_opeitm,
    shelfno_to_opeitm.loca_name_shelfno AS loca_name_shelfno_to_opeitm,
    opeitm.units_id_case_shp AS opeitm_unit_id_case_shp,
    unit_case_shp.unit_name AS unit_name_case_shp,
    unit_case_shp.unit_code AS unit_code_case_shp,
    opeitm.units_id_case_prdpur AS opeitm_unit_id_case_prdpur,
    unit_case_prdpur.unit_name AS unit_name_case_prdpur,
    unit_case_prdpur.unit_code AS unit_code_case_prdpur,
    opeitm.shelfnos_id_opeitm AS opeitm_shelfno_id_opeitm,
    shelfno_opeitm.shelfno_code AS shelfno_code_opeitm,
    shelfno_opeitm.shelfno_name AS shelfno_name_opeitm,
    shelfno_opeitm.shelfno_loca_id_shelfno AS shelfno_loca_id_shelfno_opeitm,
    shelfno_opeitm.loca_code_shelfno AS loca_code_shelfno_opeitm,
    shelfno_opeitm.loca_name_shelfno AS loca_name_shelfno_opeitm,
    opeitm.shpordauto AS opeitm_shpordauto,
    opeitm.prdpurordauto AS opeitm_prdpurordauto,
    opeitm.itmtype AS opeitm_itmtype,
    unit_weight.unit_name AS unit_name_weight,
    unit_weight.unit_code AS unit_code_weight,
    itm.itm_taxflg,
    opeitm.utilizationchangeover AS opeitm_utilizationchangeover,
    unit_size.unit_name AS unit_name_size,
    unit_size.unit_code AS unit_code_size,
    opeitm.units_id_weight AS opeitm_unit_id_weight,
    opeitm.units_id_size AS opeitm_unit_id_size,
    opeitm.weight AS opeitm_weight,
    opeitm.length AS opeitm_length,
    opeitm.wide AS opeitm_wide,
    opeitm.deth AS opeitm_deth,
    opeitm.datascale AS opeitm_datascale,
    opeitm.expireterm AS opeitm_expireterm
   FROM opeitms opeitm,
    persons person_upd,
    r_itms itm,
    r_boxes boxe,
    r_shelfnos shelfno_to_opeitm,
    r_units unit_case_shp,
    r_units unit_case_prdpur,
    r_shelfnos shelfno_opeitm,
    r_units unit_weight,
    r_units unit_size
  WHERE opeitm.persons_id_upd = person_upd.id AND opeitm.itms_id = itm.id AND opeitm.boxes_id = boxe.id 
  		AND opeitm.shelfnos_id_to_opeitm = shelfno_to_opeitm.id AND opeitm.units_id_case_shp = unit_case_shp.id 
  		AND opeitm.units_id_case_prdpur = unit_case_prdpur.id AND opeitm.shelfnos_id_opeitm = shelfno_opeitm.id 
		AND opeitm.units_id_weight = unit_weight.id AND opeitm.units_id_size = unit_size.id

		;
		
		
		-- public.r_suppliers source

CREATE OR REPLACE VIEW public.r_suppliers
AS SELECT supplier.id,
    person_upd.code AS person_code_upd,
    person_upd.name AS person_name_upd,
    supplier.remark AS supplier_remark,
    supplier.created_at AS supplier_created_at,
    supplier.update_ip AS supplier_update_ip,
    supplier.expiredate AS supplier_expiredate,
    supplier.updated_at AS supplier_updated_at,
    supplier.id AS supplier_id,
    supplier.persons_id_upd AS supplier_person_id_upd,
    supplier.contents AS supplier_contents,
    supplier.amtround AS supplier_amtround,
    supplier.personname AS supplier_personname,
    supplier.locas_id_supplier AS supplier_loca_id_supplier,
    supplier.chrgs_id_supplier AS supplier_chrg_id_supplier,
    supplier.crrs_id_supplier AS supplier_crr_id_supplier,
    loca_supplier.code AS loca_code_supplier,
    loca_supplier.name AS loca_name_supplier,
    chrg_supplier.person_code_chrg AS person_code_chrg_supplier,
    chrg_supplier.person_name_chrg AS person_name_chrg_supplier,
    crr_supplier.name AS crr_name_supplier,
    crr_supplier.code AS crr_code_supplier,
    chrg_supplier.chrg_person_id_chrg AS chrg_person_id_chrg_supplier,
    chrg_supplier.person_sect_id_chrg AS person_sect_id_chrg_supplier,
    supplier.payments_id_supplier AS supplier_payment_id_supplier,
    payment_supplier.loca_code_payment AS loca_code_payment_supplier,
    payment_supplier.loca_name_payment AS loca_name_payment_supplier,
    payment_supplier.payment_loca_id_payment AS payment_loca_id_payment_supplier,
    payment_supplier.payment_chrg_id_payment AS payment_chrg_id_payment_supplier,
    payment_supplier.person_code_chrg_payment AS person_code_chrg_payment_supplier,
    payment_supplier.person_name_chrg_payment AS person_name_chrg_payment_supplier,
    payment_supplier.crr_code_payment AS crr_code_payment_supplier,
    payment_supplier.crr_name_payment AS crr_name_payment_supplier,
    supplier.contractprice AS supplier_contractprice,
    supplier.locas_id_calendar AS supplier_loca_id_calendar,
    loca_calendar.code AS loca_code_calendar,
    loca_calendar.name AS loca_name_calendar
   FROM suppliers supplier,
    persons person_upd,
    locas loca_supplier,
    r_chrgs chrg_supplier,
    crrs crr_supplier,
    r_payments payment_supplier,
    locas loca_calendar
  WHERE supplier.persons_id_upd = person_upd.id AND supplier.locas_id_supplier = loca_supplier.id 
  AND supplier.chrgs_id_supplier = chrg_supplier.id AND supplier.crrs_id_supplier = crr_supplier.id 
	AND supplier.payments_id_supplier = payment_supplier.id AND supplier.locas_id_calendar = loca_calendar.id
;