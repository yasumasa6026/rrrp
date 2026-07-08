-- public.trngantts definition

-- Drop table

-- DROP TABLE public.trngantts;

CREATE TABLE public.trngantts (
	id numeric(38) NOT NULL,
	"key" varchar(250) NULL,
	orgtblname varchar(30) NULL,
	orgtblid numeric(38) NULL,
	paretblname varchar(30) NULL,
	paretblid numeric(38) NULL,
	tblname varchar(30) NULL,
	tblid numeric(38) NULL,
	qty numeric(22, 6) NULL,
	qty_stk numeric(22, 6) NULL,
	qty_alloc numeric(22, 6) NULL,
	mlevel numeric(3) NULL,
	parenum numeric(22, 6) NULL,
	chilnum numeric(22, 6) NULL,
	consumunitqty numeric(22, 6) NULL,
	consumminqty numeric(22, 6) NULL,
	consumchgoverqty numeric(22, 6) NULL,
	remark varchar(4000) NULL,
	created_at timestamp(6) NULL,
	expiredate date NULL,
	update_ip varchar(40) NULL,
	updated_at timestamp(6) NULL,
	persons_id_upd numeric(38) NULL,
	prjnos_id numeric(38) NULL,
	processseq_pare numeric(38) NULL,
	itms_id_pare numeric(38) NULL,
	qty_pare numeric(22, 6) NULL,
	qty_pare_alloc numeric(22, 6) NULL,
	qty_bal numeric(22, 6) NULL,
	qty_pare_bal numeric(22, 6) NULL,
	duedate_org timestamp(6) NULL,
	qty_sch numeric(22, 6) NULL,
	starttime_org timestamp(6) NULL,
	starttime_pare timestamp(6) NULL,
	itms_id_org numeric(38) DEFAULT 0 NOT NULL,
	duedate_trn timestamp(6) NULL,
	duedate_pare timestamp(6) NULL,
	chrgs_id_pare numeric(22) DEFAULT 0 NOT NULL,
	chrgs_id_org numeric(38) DEFAULT 0 NOT NULL,
	chrgs_id_trn numeric(38) DEFAULT 0 NOT NULL,
	processseq_org numeric(22) NULL,
	itms_id_trn numeric(38) DEFAULT 0 NOT NULL,
	processseq_trn numeric(38) NULL,
	starttime_trn timestamp(6) NULL,
	qty_require numeric(22, 6) NULL,
	qty_handover numeric(22, 6) NULL,
	mkprdpurords_id_trngantt numeric(22) DEFAULT 0 NOT NULL,
	toduedate_trn timestamp(6) NULL,
	toduedate_pare timestamp(6) NULL,
	toduedate_org timestamp(6) NULL,
	consumtype varchar(10) NULL,
	shelfnos_id_to_pare numeric(22) DEFAULT 0 NOT NULL,
	shelfnos_id_trn numeric(22) DEFAULT 0 NOT NULL,
	shelfnos_id_pare numeric(22) DEFAULT 0 NOT NULL,
	shelfnos_id_to_trn numeric(22) DEFAULT 0 NOT NULL,
	qty_sch_pare numeric(22, 6) NULL,
	shelfnos_id_org numeric(22) DEFAULT 0 NOT NULL,
	optfixodate date NULL,
	packqty numeric(18, 2) DEFAULT 0 NOT NULL,
	maxqty numeric(22, 6) DEFAULT 0 NOT NULL,
	optfixoterm numeric(5, 2) DEFAULT 0 NOT NULL,
	duration numeric(38, 2) DEFAULT 0 NOT NULL,
	unitofduration bpchar(4) NULL,
	shuffleflg bpchar(1) NULL,
	gather_flg numeric(22) DEFAULT 0 NOT NULL,
	mkordtmpfs_id numeric(22) NULL,
	CONSTRAINT trngantts_id_pk PRIMARY KEY (id),
	CONSTRAINT trngantts_ukyg1 UNIQUE (orgtblname, orgtblid, key, paretblname, paretblid, tblname, tblid)
);


-- public.trngantts foreign keys

ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_chrgs_id_org FOREIGN KEY (chrgs_id_org) REFERENCES public.chrgs(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_chrgs_id_pare FOREIGN KEY (chrgs_id_pare) REFERENCES public.chrgs(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_chrgs_id_trn FOREIGN KEY (chrgs_id_trn) REFERENCES public.chrgs(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_itms_id_org FOREIGN KEY (itms_id_org) REFERENCES public.itms(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_itms_id_pare FOREIGN KEY (itms_id_pare) REFERENCES public.itms(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_itms_id_trn FOREIGN KEY (itms_id_trn) REFERENCES public.itms(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_mkprdpurords_id_trngantt FOREIGN KEY (mkprdpurords_id_trngantt) REFERENCES public.mkprdpurords(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_persons_id_upd FOREIGN KEY (persons_id_upd) REFERENCES public.persons(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_prjnos_id FOREIGN KEY (prjnos_id) REFERENCES public.prjnos(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_shelfnos_id_org FOREIGN KEY (shelfnos_id_org) REFERENCES public.shelfnos(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_shelfnos_id_pare FOREIGN KEY (shelfnos_id_pare) REFERENCES public.shelfnos(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_shelfnos_id_to_pare FOREIGN KEY (shelfnos_id_to_pare) REFERENCES public.shelfnos(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_shelfnos_id_to_trn FOREIGN KEY (shelfnos_id_to_trn) REFERENCES public.shelfnos(id);
ALTER TABLE public.trngantts ADD CONSTRAINT trngantt_shelfnos_id_trn FOREIGN KEY (shelfnos_id_trn) REFERENCES public.shelfnos(id);