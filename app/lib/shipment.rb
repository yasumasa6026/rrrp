# -*- coding: utf-8 -*-
#shipment
# 2099/12/31を修正する時は　2100/01/01の修正も
module Shipment
	extend self
	def proc_mkShpords params   ###screenCode:r_purords,r_prdords
		clickIndex  = params[:clickIndex].dup
    screenCode = params[:screenCode]
		###shpschsは変更済
		outcnt = 0
		shortcnt = 0
		parent = {}
    last_lotstks = last_lotstks_parts = []
			clickIndex.each do |strselected|  ###-次のフェーズに進んでないこと。
				selected = JSON.parse(strselected)
				next if selected["id"].nil?
				### prd,pur ords,instsでshpordsは自動作成されている。
				strsql = %Q&	select * from #{screenCode.split("_")[1]} where id = #{selected["id"]} 	&
				parent = ActiveRecord::Base.connection.select_one(strsql)
        parent["tblname"] = screenCode.split("_")[1]
				parent["tblid"] = selected["id"]
					shpschs_sql = %Q$
						select link.tblname ord_tblname,link.tblid ord_tblid from linktbls link
									where link.tblname = '#{parent["tblname"]}' and  link.tblid = #{parent["tblid"]}
									and	link.srctblname like '%ords' and link.qty_src > 0
									and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
													---既にshpordsを作成済の時は削除するshpschsはない。
															)				
            union ---/ITool|mold/ by xxxords
						  select link.tblname ord_tblname,link.tblid ord_tblid from linktbls link
									where link.tblname = '#{parent["tblname"]}' and  link.tblid = #{parent["tblid"]}
									and	link.srctblname like '%schs' 	and link.qty_src > 0
									and not exists(select 1 from shpords s where paretblname = '#{parent["tblname"]}' and  paretblid = #{parent["tblid"]}
													---既にshpordsを作成済の時は削除するshpschsはない。
															)		
            union ---/ITool|mold/ by xxxinst
						  select link.tblname ord_tblname,link.tblid ord_tblid from linktbls link
									where link.tblname = '#{parent["tblname"]}' and  link.tblid = #{parent["tblid"]}
									and	link.srctblname like '%ords' 	 	and link.qty_src > 0
									and not exists(select 1 from shpords s where s.paretblname = '#{parent["tblname"]}' and  s.paretblid = #{parent["tblid"]})
									and not exists(select 1 from shpords s where s.paretblname = link.srctblname and  s.paretblid = link.srctblid
													---既にshpordsを作成済の時は削除するshpschsはない。
															)		
						$
					shpord_strsql = %Q&
            select t.itms_id_trn itms_id,t.processseq_trn processseq,max(t.id) trngantts_id,
								t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,
								t.shelfnos_id_pare,   ---親作業場所
								t.shelfnos_id_to_trn shelfnos_id_child,   ---子の保管先
                ope.packqty,'' packno,'' lotno,t.expiredate,
								ope.units_id_case_shp,ope.consumauto,ope.shpordauto,max(i.taxflg) itm_taxflg, 
              	case 
								when  alloc.srctblname like '%schs' then
                  		sum(alloc.qty_linkto_alloctbl) 
              	else 
              		0
                end  qty_sch,
                case 
								when  alloc.srctblname like '%ords' or alloc.srctblname like '%insts' or alloc.srctblname like '%rply%'  then
                		  sum(alloc.qty_linkto_alloctbl) 
              	else 
              		0
                end  qty,
                case 
								when  alloc.srctblname like '%dlvs' or alloc.srctblname like '%acts' then
                		  sum(alloc.qty_linkto_alloctbl) 
              	else 
              		0
                end  qty_stk
							from trngantts t
              inner join (select pare.*,alloc.srctblname,alloc.srctblid	from trngantts pare
							                  inner join alloctbls alloc on alloc.trngantts_id = pare.id 
							                  where alloc.srctblname =  '#{parent["tblname"]}'  and  alloc.srctblid = #{parent["tblid"]} 	
                                and alloc.qty_linkto_alloctbl  > 0) p
                              on p.orgtblname = t.orgtblname and p.orgtblid = t.orgtblid 
                              and p.tblname = t.paretblname and p.tblid = t.paretblid 
                              and (p.paretblname != t.paretblname or  p.paretblid != t.paretblid)   
							inner join opeitms ope on t.itms_id_trn = ope.itms_id and t.processseq_trn = ope.processseq
											and t.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join itms i on i.id = t.itms_id_trn
							inner join alloctbls alloc on alloc.trngantts_id = t.id and alloc.qty_linkto_alloctbl  > 0    
							where t.shelfnos_id_to_trn != p.shelfnos_id_trn 
							and not exists(select 1 from shpords s where s.paretblname = '#{parent["tblname"]}' and  s.paretblid = #{parent["tblid"]}
																			and s.qty > 0
																			and s.itms_id = t.itms_id_trn and s.processseq = t.processseq_trn)
              group by t.itms_id_trn ,t.processseq_trn ,	t.prjnos_id,t.chrgs_id_trn,
								t.consumtype,t.parenum,t.chilnum,t.consumunitqty,t.consumminqty,t.consumchgoverqty,ope.packqty,t.expiredate,
								t.shelfnos_id_pare, t.shelfnos_id_to_trn ,  ope.units_id_case_shp,ope.consumauto,ope.shpordauto	,alloc.srctblname
					&
				delete_shpschs_by_prdpurord = ActiveRecord::Base.connection.select_all(shpschs_sql)	
				###在庫の確認
				outcnt = shortcnt = 0
				gno_shpord = ArelCtl.proc_get_nextval("gno_shpord_seq")
        ActiveRecord::Base.connection.select_all(shpord_strsql).each do |shpord|
          shp = shpord.dup
					if shp["consumtype"] =~ /CON|ITool|mold/  ###出庫 消費と金型・設備の使用
						if shp["shpordauto"] != "M"   ###手動出庫は除く
								shp["persons_id_upd"] = params[:person_id_upd]
								shp["pare_qty"] = parent["qty"]
								shp["pare_starttime"] = parent["starttime"]
                shp["duedate"] = (shp["pare_starttime"].to_time - 1*3600).strftime("%Y/%m/%d %H:%M:%S")  ###稼働日　稼働時間
                shp["depdate"] = (shp["pare_starttime"].to_time - 4*3600).strftime("%Y/%m/%d %H:%M:%S")
								shp["trngantts_id"] = shp["trngantts_id"]
								shp["shelfnos_id_to"] = shp["shelfnos_id_pare"]
								shp["shelfnos_id_fm"] = shp["shelfnos_id_child"]  
								shp["paretblname"] = parent["tblname"]
								shp["paretblid"] = parent["tblid"]
								shp["gno"] = gno_shpord
								shp["qty_case"] = 0
								save_qty_stk = shp["qty_stk"].to_f
								###shp["qty"] = save_qty_stk = shp["qty_stk"].to_f
								shp["qty_shortage"] = shp["qty_sch"].to_f + shp["qty"].to_f
                if shp["qty_shortage"] > 0
                  save_lotno = shp["lotno"]
                  save_packno = shp["packno"]
									if shp["shuffleflg"] == "S"   ###他に在庫があれば引当るケース
                  		shuffle_sql = %Q$
                      		select * from lotstkhists stk
                        		inner join (select itms_id,processseq,shelfnos_id,prjnos_id,lotno,packno,
                                max(starttime) starttime from lotstkhists 
                                where itms_id = #{shp["itms_id"]} and processseq = #{shp["processseq"]} and prjnos_id = #{shp["prjnos_id"]}
                                and shelfnos_id = #{shp["shelfnos_id_fm"]} 
                                group by itms_id,processseq,shelfnos_id,prjnos_id,lotno,packno) lot
                          	on stk.itms_id = lot.itms_id and stk.processseq = lot.processseq and stk.shelfnos_id = lot.shelfnos_id
                            		and stk.prjnos_id = lot.prjnos_id and stk.lotno = lot.lotno and stk.packno = lot.packno and stk.starttime = lot.starttime
                        		where stk.qty_stk > 0
                      		$
                    	ActiveRecord::Base.connection.select_all(shuffle_sql).each do |stk|
                      		if save_lotno == stk["lotno"]  and save_packno == stk["packno"]
                          		stk["qty_stk"] =  stk["qty_stk"].to_f - save_qty_stk
                          		next if stk["qty_stk"] <= 0
                      		end
                      		if shp["packno"] != stk["packno"] or shp["lotno"] != stk["lotno"]
                        		outcnt += 1
                        		last_lotstks_parts = shpord_create_by_shpsch(shp)   ###
                        		shp["packno"] = stk["packno"]
                        		shp["lotno"] = stk["lotno"]
                        		if shp["qty_shortage"] >  stk["qty_stk"].to_f
                          		shp["qty_shortage"] -= stk["qty_stk"].to_f
                          		shp["qty_stk"] = stk["qty_stk"].to_f
                        		else
                          		shp["qty_stk"] =  shp["qty_shortage"] 
                          		shp["qty_shortage"] = 0
                          		outcnt += 1
                          		last_lotstks_parts = shpord_create_by_shpsch(shp)   ###
                          		break
                        		end
                      		else 
                        		if shp["qty_shortage"] > stk["qty_stk"].to_f
								          		shp["qty"] = shp["qty"].to_f + stk["qty_stk"].to_f
                          		shp["qty_shortage"] -= stk["qty_stk"].to_f
                        		else
                          		shp["qty_stk"] +=  shp["qty_shortage"] 
                          		shp["qty_shortage"] = 0
                          		outcnt += 1
                          		last_lotstks_parts = shpord_create_by_shpsch(shp)   ###　  
                          		break
                        		end
                      		end
                  		end
                  else
                    ActiveRecord::Base.connection.select_all(shuffle_sql).each do |stk|
                        shp["qty_stk"] = shp["qty_stk"].to_f + stk["qty_stk"].to_f   ###shp["qty_stk"]  他にある在庫
                    end
								  	last_lotstks_parts = shpord_create_by_shpsch(shp)   ###prd,purordsによる自動作成 
                    outcnt += 1
                    shortcnt += 1 if shp["qty_shortage"]  > 0
                  end
                else
								  last_lotstks_parts = shpord_create_by_shpsch(shp)   ###prd,purordsによる自動作成 
								  outcnt += 1
                  shortcnt += 1 if shp["qty_shortage"]  > 0
                end
								if outcnt > 0 or shortcnt > 0
                	last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ##
                end
								if shp["consumauto"] == "A"   ###使用後自動返却
								 		###shpschs,shpordsでは瓶毎、リール毎に出庫してないので、瓶、リールの自動返却はない。
		                shp["duedate"] = (parent["duedate"].to_time + 4*3600).strftime("%Y/%m/%d %H:%M:%S")  ###稼働日　稼働時間
		                shp["depdate"] = (parent["duedate"].to_time  + 1*3600).strftime("%Y/%m/%d %H:%M:%S")
										shp["shelfnos_id_fm"] = shp["shelfnos_id_pare"]
										shp["shelfnos_id_to"] = shp["shelfnos_id_to"]  
										last_lotstks_parts = shpord_create_by_shpsch(shp)   ###
                    last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
								end
            end
					end
				end
				
				delete_shpschs_by_prdpurord.each do |ord|  ###shpschsの減
					shp_sql = %Q&
							select * from shpschs where  paretblname =  '#{ord["ord_tblname"]}'  and paretblid = #{ord["ord_tblid"]}
					&
					ActiveRecord::Base.connection.select_all(shp_sql).each do |nd|
						strsql = %Q&
									update shpschs set qty_sch = 0,qty_case = 0,
											updated_at = current_timestamp,
											remark = '#{self} line:#{__LINE__}'
										where id = #{nd["id"]}
						&
						ActiveRecord::Base.connection.update(strsql)
            last_lotstks << {"tblname" => "shpschs","tblid" => nd["id"],"qty_src" => nd["qty_sch"].to_f * -1}
					end
				end  ###ord_parents.each 
			end  ###clickIndex.each
		return outcnt,shortcnt,last_lotstks
	end	

	def proc_second_shp params,grid_columns_info
		tmp = []
		err = nil
		pareTblName = "" 
		str_func = %Q&select * from func_get_name('screen','#{params[:screenCode]}','#{params[:email]}')&
		params[:screenName] = ActiveRecord::Base.connection.select_value(str_func)
		if params[:screenName].nil?
			params[:screenName] = params[:screenCode]
		end
		strselect = "("
		(params[:clickIndex]).each do |selected|  ###-次のフェーズに進んでないこと。
			selected = JSON.parse(selected)
			if selected["screenCode"] =~ /prd|pur/ and selected["screenCode"] =~ /ords$|insts$|replyinputs$/
				strselect << selected["id"]+","
				pareTblName = selected["screenCode"].split("_")[1]
			end
		end
		if strselect == "("
			totalCount = 0
		    params[:pageCount] = 0
		    params[:totalCount] = 0
		    params[:parse_linedata] = {}
		    return [],params
		end
		strselect = strselect.chop + ")"
		strsorting = ""
		if params[:sortBy]  and   params[:sortBy] != [] ###: {id: "itm_name", desc: false}
			params[:sortBy].each do |sortKey|
				strsorting = " order by " if strsorting == ""
				strsorting << %Q% #{sortKey["id"]} #{if sortKey["desc"]  == false then " asc " else "desc" end} ,%
			end	
			if strsorting == ""
				strsorting = " order by id desc "
			else
				strsorting << " id desc "
			end
		else
			case params[:screenCode] 
			when "fordlv_shpords"
				strsorting = "  order by shpord_paretblid,id desc "
				# strsql = %Q&
				# 	select id	FROM shpords shp where
				# 		paretblname = '#{pareTblName}'
				# 		and paretblid in #{strselect} 
        #     --- and qty_shortage = 0 
				# 		and not exists(select 1 from shpdlvs inst where
				# 					inst.paretblname = '#{pareTblName}' and	inst.paretblid in #{strselect} and
				# 					inst.itms_id = shp.itms_id and inst.processseq = shp.processseq and 
				# 					inst.lotno = shp.lotno and inst.packno = shp.packno
				# 					)
				# &
				# shpords = ActiveRecord::Base.connection.select_all(strsql)
				# shpords.each do |shpord|
				# 	shpord = ActiveRecord::Base.connection.select_one("select * from r_shpords where id = #{shpord["id"]}")
				# 	blk = RorBlkCtl::BlkClass.new("r_shpords")
				# 	command_c = blk.command_init
				# 	command_c["sio_classname"] = "shpords_delete_"
				# 	shpord.each do |fld,val|
				# 		command_c[fld] = val
				# 	end
				# 	command_c["shpord_qty"] =  0
				# 	command_c["shpord_qty_shortage"] =  0
				# 	command_c["shpord_person_id_upd"] = params[:person_id_upd]
				# 	blk.proc_private_aud_rec({},command_c)
				# end
				
			when "foract_shpdlvs"
				strsorting = "  order by shpdlv_paretblid,id desc "
			when "r_shpacts"
				strsorting = "  order by shpact_paretblid,id desc "
			end
			params[:sortBy] = []
		end
		screenCode = params[:screenCode]
		tblnamechop = screenCode.split("_",2)[1].chop
		pareTblName = params[:gantt]["paretblname"] ###第一画面のテーブル名
		nextTblName = case screenCode
					when /shpords/
						"shpdlvs" 
					when /shpdlvs/
						"shpacts"  
					when /shpacts/
						"shpacts" 
					end
		strqty = case tblnamechop
					when /shpord/
						"shpord_qty" 
					when /shpdlv/
						"shpdlv_qty_stk"  
					when /shpact/
						"shpact_qty_stk" 
					end
		strsql = "select   #{grid_columns_info[:select_fields]} 
								from (SELECT ROW_NUMBER() OVER (#{strsorting}) , #{grid_columns_info[:select_row_fields]} 
													FROM #{params[:view]} shp 
									left join (select paretblname,paretblid,itms_id,processseq,lotno,packno,sum(qty_stk) qty_stk from #{nextTblName}  where
															paretblname = '#{pareTblName}' and
												 			paretblid in #{strselect} 
															group by paretblname,paretblid,itms_id,processseq,lotno,packno) next 
													on	next.paretblname = #{tblnamechop}_paretblname and
															next.paretblid = #{tblnamechop}_paretblid and  
															next.itms_id = shp.#{tblnamechop}_itm_id and 
															next.processseq = shp.#{tblnamechop}_processseq and
															next.lotno = shp.#{tblnamechop}_lotno and 
															next.packno = shp.#{tblnamechop}_packno  
										where	#{tblnamechop}_paretblname = '#{pareTblName}' and
													#{tblnamechop}_paretblid in #{strselect} 
													and shp.#{strqty} > COALESCE(next.qty_stk,0) ) --- 完了済(マイナス出庫分)は除く ) x
								where ROW_NUMBER > #{(params[:pageIndex].to_f)*params[:pageSize].to_f} 
													and ROW_NUMBER <= #{(params[:pageIndex].to_f + 1)*params[:pageSize].to_f} 
															  "
		pagedata = ActiveRecord::Base.connection.select_all(strsql)
		
		strsql = " SELECT count(*) FROM #{params[:view]} shp 
									left join (select paretblname,paretblid,itms_id,processseq,lotno,packno,sum(qty_stk) qty_stk from #{nextTblName}  where
															paretblname = '#{pareTblName}' and
												 			paretblid in #{strselect} 
															group by paretblname,paretblid,itms_id,processseq,lotno,packno) next 
													on	next.paretblname = #{tblnamechop}_paretblname and
															next.paretblid = #{tblnamechop}_paretblid and  
															next.itms_id = shp.#{tblnamechop}_itm_id and 
															next.processseq = shp.#{tblnamechop}_processseq and
															next.lotno = shp.#{tblnamechop}_lotno and 
															next.packno = shp.#{tblnamechop}_packno  
										where	#{tblnamechop}_paretblname = '#{pareTblName}' and
													#{tblnamechop}_paretblid in #{strselect} 
													and shp.#{strqty} > COALESCE(next.qty_stk,0)"
		 ###fillterがあるので、table名は抽出条件に合わず使用できない。
		totalCount = ActiveRecord::Base.connection.select_value(strsql)
		params[:pageCount] = (totalCount.to_f/params[:pageSize].to_f).ceil
		params[:totalCount] = totalCount.to_f
		params[:parse_linedata] = {}
		return pagedata,params 
	end	
	
	###shp用 shpordsは原則使用せず、prdordsの完成後のIToll等の移動に使用。
	def proc_create_shpxxxs(params)  ### shpordsprdordsの完成後の移動に使用
			###自分自身のshpschs を作成   
		###
		#  yield=shpsch --> create
		#  yield=shpord --> 入り出の減
		#  yield=shpdlv -->出の減
		#  yield=shpact --> 入りの減
		###
		parent = params[:parent]  ###親
		child = params[:child]  #
    last_lotstks = []
		blk = RorBlkCtl::BlkClass.new("r_#{yield}s")
		command_c = blk.command_init
		if child["shelfnos_id_to"] != parent["shelfnos_id"]  ###子部品の保管場所!=shelfnos_id_fm親の作業場所
				command_c["sio_classname"] = "shpxxxx_add_"
				command_c["#{yield}_id"] = "" 
				command_c["#{yield}_isudate"] = Time.now
				### child["shelfnos_id_to"]:購入,製造後の保管場所
				command_c["#{yield}_transport_id"] = 0 
				command_c["#{yield}_itm_id"] = child["itms_id"]   ### from shpords
				command_c["#{yield}_processseq"] = child["processseq"]
				command_c["#{yield}_sno"] = ""
				command_c["#{yield}_unit_id_case_shp"] = child["units_id_case_shp"]
				command_c["#{yield}_packno"] = ""  
				command_c["#{yield}_lotno"] = ""
				command_c["#{yield}_person_id_upd"] = params[:person_id_upd]
				command_c["#{yield}_paretblname"] = parent["tblname"] 
				command_c["#{yield}_paretblid"] = parent["tblid"]
				command_c["#{yield}_prjno_id"] = parent["prjnos_id"]
				command_c["#{yield}_chrg_id"] = parent["chrgs_id"]
				if parent["tblname"] =~ /^pur/   ###tblname= 'feepayment'--->有償支給
					paidsupplierprice command_c,child,yield
				else
					command_c["#{yield}_contractprice"] = 'C'
					command_c["#{yield}_crr_id"] = 0
					command_c["#{yield}_price"] = 0
					command_c["#{yield}_tax"] = 0 
					command_c["#{yield}_taxrate"] = 0
					command_c["#{yield}_masterprice"] = 0
					if yield == "shpsch"
						command_c["shpsch_amt_sch"] = 0 		
					else
						command_c["#{yield}_amt"] = 0 		
					end
				end		
				case yield
				when /shpest/  ### mold 
					case child["consumtype"]
					when "mold","ITool"
						command_c["#{yield}_shelfno_id_fm"] = child["shelfnos_id_to"] ###自身の保管先から出庫
						command_c["#{yield}_qty_est"] = qty_src = 1
						###親の作業場所へ納品
						if parent["tblname"] =~ /^pur/
							strsql = %Q&
									select shelf.id from shelfnos shelf
												inner join suppliers supp on shelf.locas_id_shelfno = locas_id_supplier
															and supp.id = #{parent["suppliers_id"]} 	
												where shelf.code = '000'
							&
							command_c["#{yield}_shelfno_id_to"] = ActiveRecord::Base.connection.select_value(strsql)
						else
							command_c["#{yield}_shelfno_id_to"] = parent["shelfnos_id"] 
						end
						command_c["#{yield}_duedate"] = parent["duedate"] 
						command_c["#{yield}_depdate"] = (parent["starttime"].to_time - 1*24*3600).strftime("%Y-%m-%d %H:%M:%S")
					else
						raise" class #{self} ,line:#{__LINE__} logic error not support  consumtype:#{child["consumtype"]} "
					end
				when /shpsch/
					command_c["#{yield}_shelfno_id_fm"] = child["shelfnos_id_to"] ###自身の保管先から出庫
					command_c["#{yield}_gno"] = parent["sno"] 
					case child["consumtype"]
					when "CON"
						qty_sch = CtlFields.proc_cal_qty_sch(parent["qty"].to_f,child["chilnum"].to_f,child["parenum"].to_f)
						command_c["#{yield}_duedate"] = command_c["#{yield}_depdate"] = (parent["starttime"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
					when "mold","ITool"
						qty_sch = 1
						command_c["#{yield}_duedate"] = parent["duedate"]
						command_c["#{yield}_depdate"] = (parent["starttime"].to_time - 1*24*3600).strftime("%Y-%m-%d %H:%M:%S")
          when "run"
						command_c["#{yield}_duedate"] = command_c["#{yield}_depdate"] = parent["duedate"]
					  command_c["#{yield}_shelfno_id_fm"] = 0 ###自身の保管先から出庫
					  command_c["#{yield}_shelfno_id_to"] = child["shelfnos_id_to"] ###自身の保管先から出庫
					  command_c["#{yield}_gno"] = parent["sno"] 
					else
						raise" error class #{self} , line:#{__LINE__} logic error not support  consumtype:#{child["consumtype"]} "
					end
					command_c["#{yield}_qty_sch"] = qty_src = qty_sch
					###親の作業場所へ納品
					if parent["tblname"] =~ /^pur/
						strsql = %Q&
									select shelf.id from shelfnos shelf
												inner join suppliers supp on shelf.locas_id_shelfno = locas_id_supplier
															and supp.id = #{parent["suppliers_id"]} 	
												where shelf.code = '000'
						&
						command_c["#{yield}_shelfno_id_to"] = ActiveRecord::Base.connection.select_value(strsql)
					else
						command_c["#{yield}_shelfno_id_to"] = parent["shelfnos_id"] 
					end
				when /shpord/  ### shpordsはprdordsの完成後の手動移動に使用
					command_c["#{yield}_shelfno_id_fm"] = child["shelfnos_id_fm"] ###自身の保管先から出庫
					command_c["#{yield}_qty"] = qty_src =  child["qty_sch"].to_f * -1
					command_c["#{yield}_shelfno_id_to"] = child["shelfnos_id_to"]  
					command_c["#{yield}_gno_shpord"] =  child["gno"] 
					command_c["#{yield}_duedate"] = child["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
					command_c["#{yield}_depdate"] = child["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
				when /shpdlv|shpact/
					command_c["#{yield}_shelfno_id_fm"] = child["shelfnos_id_fm"] ###自身の保管先から出庫
					command_c["#{yield}_qty"] = qty_src = child["qty"].to_f * -1
					command_c["#{yield}_gno"] = child["gno"] 
					command_c["#{yield}_shelfno_id_to"] = child["shelfnos_id_to"]  
					command_c["#{yield}_masterprice"] = child["masterprice"]  
					command_c["#{yield}_duedate"] = child["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
					if yield =~ /shpact/
							command_c["#{yield}_gno_shpord"] = child["gno_shpord"]
					else
							command_c["#{yield}_gno_shpord"] = child["gno"]
					end
					case child["consumtype"]
					when "CON"
            # nd =  {"duration"=>1,
						# 			"unitofduration"=>if parent["starttime"].to_time.strftime("%H:%M:%S") == "00:00:00" then "Day " else "Hour" end,
            #       "shelnos_id_fm" => child["shelfnos_id_fm"],"shelnos_id_to" => child["shelfnos_id_to"],
            #       "itms_id"=>child["itms_id"],"processseq" => child["processseq"]}
            # command_c["shelfno_loca_id_shelfno_to"] = 
            # command_c ,message = CtlFields.proc_field_starttime(yield,command_c,parent,nd)
						command_c["#{yield}_depdate"] = (parent["starttime"].to_time - 24*3600).strftime("%Y-%m-%d %H:%M:%S")   ###稼働日考慮
						command_c["#{yield}_duedate"] = parent["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S")
					when "mold","ITool"
						command_c["#{yield}_duedate"] = parent["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
						command_c["#{yield}_depdate"] = (parent["starttime"].to_time - 1*24*3600).strftime("%Y-%m-%d %H:%M:%S")
					else
						raise"error class #{self} , line:#{__LINE__} ,logic error not support  consumtype:#{child["consumtype"]} "
					end
				end
	
				
				command_c["id"] = ArelCtl.proc_get_nextval("#{yield}s_seq")
				command_c["#{yield}_created_at"] = Time.now
				blk.proc_private_aud_rec(params,command_c)
				###
				#  mold,ITollのshpxxxxのlinktbls
				###
        last_lotstks << {"tblname" => yield + "s" ,"tblid" => command_c["id"],"qty_src" => qty_src }
				return last_lotstks if yield == "shpest"
				last_lotstks_parts = update_mold_IToll_shp_link(blk.tbldata,"add") do
						yield
				end
        last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
				###
		end ###
    return last_lotstks
	end 

	def proc_confirmShpdlvs(params)
      begin
        ActiveRecord::Base.connection.begin_db_transaction()
			  outcnt = 0
			  err = "please select shpords"
        last_lotstks = []
			  if params[:clickIndex] 
				  params[:clickIndex].each do |selected|  ###-次のフェーズに進んでないこと。
					  selected = JSON.parse(selected)
					  if selected["screenCode"] == "fordlv_shpords"
						  prev_shpord = ActiveRecord::Base.connection.select_one(%Q&select * from r_shpords where id = #{selected["id"]}&)
						  prev_shpord["shpord_person_id_upd"] = params[:person_id_upd]
						  last_lotstks_parts = nextshp_create_by_prevshp(prev_shpord,"shpords","shpdlvs")
						  outcnt += 1
						  err = nil
              last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
					  end
				  end
				  if outcnt == 0
				    err = " no shpords record"
				  end
			  end
		  rescue
			  ActiveRecord::Base.connection.rollback_db_transaction()
			  Rails.logger.debug"error class #{self} : #{Time.now}: #{$@}\n ,$!:#{$!}"
			  err << $!
		  else
			  ActiveRecord::Base.connection.commit_db_transaction()
		  end
		return outcnt,err
	end	

	
	def proc_confirmShpacts(params)
      begin
        ActiveRecord::Base.connection.begin_db_transaction()
			  outcnt = 0
			  err = "please select shpdlvs"
			  if params[:clickIndex]
				  params[:clickIndex].each do |selected|  ###-次のフェーズに進んでないこと。
					  selected = JSON.parse(selected)
					  if selected["screenCode"] == "foract_shpdlvs"
						  prev_shpdlv = ActiveRecord::Base.connection.select_one(%Q&select * from r_shpdlvs where id = #{selected["id"]}&)
						  prev_shpdlv["shpdlv_person_id_upd"] = params[:person_id_upd]
						  nextshp_create_by_prevshp(prev_shpdlv,"shpdlvs","shpacts")
						  outcnt += 1
						  err = nil
					  end
				  end
				  if outcnt == 0
				    err = "  no shpdlvs record"
				  end
			  end
		  rescue
			  ActiveRecord::Base.connection.rollback_db_transaction()
			  Rails.logger.debug"error class #{self} : #{Time.now}: #{$@}\n $!:#{$!}"
			  err << $!
		  else
			  ActiveRecord::Base.connection.commit_db_transaction()
		  end
		  return outcnt,err
	end	

	def nextshp_create_by_prevshp(shp,prevshp,nextshp)  ###
		###自分自身のshpschs を作成   
		blk = RorBlkCtl::BlkClass.new("r_#{nextshp}")
		command_c = blk.command_init
		nextshpchop = nextshp.chop
		prevshpchop = prevshp.chop
		command_c["sio_classname"] = "#{nextshp}_add_"
		rec = {}
    last_lotstks  = []
		shp.each do |k,val|
			tblchop,field = k.to_s.split("_",2)
			rec[field.sub("_id","s_id")] = val if tblchop == prevshpchop
			next if field =~ /^qty|^sno|^gno|^id$|^isudate/
			if tblchop == prevshpchop
				command_c["#{nextshpchop}_#{field}"] = val
			end
		end
		command_c["#{nextshpchop}_isudate"] = Time.now
		command_c["#{nextshpchop}_sno"] = command_c["#{nextshpchop}_id"] = "" 	

		case prevshp
		when "shpords"
			command_c["shpdlv_depdate"] =  (shp["shpord_depdate"]||=Time.now)
			command_c["shpdlv_qty_stk"] =  shp["shpord_qty"]
			command_c["shpdlv_gno_shpord"] =  shp["shpord_gno"]
			command_c["shpdlv_rcptdate"] = shp["shpord_duedate"]
			if shp["shpord_unit_id_case_shp"] == shp["shpord_unit_id_case_shp"]
				command_c["shpdlv_qty_real"] =  shp["shpord_qty"]
			else
				strsql = %Q&
							select qty_stk from lotstkhists where itms_id = #{command_c["#{nextshpchop}_itm_id"] }
														and processseq = #{command_c["#{nextshpchop}_processseq"] }
														and shelfnos_id = #{command_c["#{nextshpchop}_shelfno_id_fm"] }
														and lotno = '#{command_c["#{nextshpchop}_lotno"]}'
														and packno = '#{command_c["#{nextshpchop}_packno"]}'
												order by starttime desc limit 1
				&
				command_c["shpdlv_qty_real"] =  ActiveRecord::Base.connection.select_value(strsql)
			end	
		when "shpdlvs"
			command_c["shpact_qty_stk"] =  shp["shpdlv_qty_stk"]
			command_c["shpact_qty_real"] =  shp["shpdlv_qty_real"]
			command_c["shpact_rcptdate"] =  (shp["shpdlv_rcptdate"]||= Time.now)
			command_c["shpact_gno_shpord"] =  shp["shpdlv_gno_shpord"]
		end
		command_c["#{nextshpchop}_qty_shortage"] = shp["#{prevshpchop}_qty_shortage"]
		command_c["#{nextshpchop}_qty_case"] = shp["#{prevshpchop}_qty_case"]
		command_c["id"] = ArelCtl.proc_get_nextval("#{nextshpchop}s_seq")
		command_c["#{nextshpchop}_created_at"] = Time.now
		blk.proc_private_aud_rec({},command_c)

		last_lotstks << {"tblname" => nextshpchop + "s","tblid" => command_c["id"],"qty_src" => command_c["#{nextshpchop}_qty_stk"] } ###,
                ####    "set_f" => true ,"rec" => blk.tbldata} processreqs.reqparams.length > 8096
		###
		#  mold,ITollのshpxxxxのlinktbls
		###
		last_lotstks_parts = update_mold_IToll_shp_link(blk.tbldata,"add") do
			nextshpchop
		end
		###
    last_lotstks.concat last_lotstks_parts  if last_lotstks_parts.size > 0  ###nilを避ける
		return last_lotstks
	end

	def proc_create_consume(params) ## by child item
		###prdschs,purschsの時は自分自身のconschs を作成   
		command_c = {}
		reqparams = params.dup
		parent = reqparams[:parent] ###親
		child = reqparams[:child]  ###対象
		tblnamechop = params[:screenCode].split("_",2)[1].chop
		blk = RorBlkCtl::BlkClass.new("r_#{tblnamechop}s")
		command_c = blk.command_init
		command_c["sio_code"] =  command_c["sio_viewname"] =  params[:screenCode]  ###viewは関係ない
		command_c["sio_message_contents"] = nil
		command_c["sio_recordcount"] = 1
		command_c["sio_result_f"] =   "0"  
		command_c["sio_classname"] = "#{params[:screenCode]}_add_consume"
		command_c["#{tblnamechop}_id"] = "" 
		command_c["#{tblnamechop}_itm_id"] = child["itms_id"]
		command_c["#{tblnamechop}_processseq"] = child["processseq"]
		command_c["#{tblnamechop}_consumauto"] = (child["consumauto"]||="")
		command_c["#{tblnamechop}_isudate"] = Time.now 
		command_c["#{tblnamechop}_packno"] =  ""  
		command_c["#{tblnamechop}_lotno"] = "" 
		command_c["#{tblnamechop}_gno"] = parent["sno"] 
		command_c["#{tblnamechop}_paretblname"] = parent["tblname"] 
		command_c["#{tblnamechop}_paretblid"] = parent["tblid"]
		command_c["#{tblnamechop}_prjno_id"] = parent["prjnos_id"]
		command_c["#{tblnamechop}_chrg_id"] = parent["chrgs_id"]
		command_c["#{tblnamechop}_expiredate"] = parent["expiredate"]
    ### perfotm　実行のため　.to_json日付が"2024-12-17T20:53:26.000Z"になている
		command_c["#{tblnamechop}_duedate"] = 	case  parent["tblname"] 
													when /schs$|ords$|insts$/
														parent["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													when /reply/
														parent["replydate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													when /purdlvs/
														parent["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													when /puracts/
														parent["rcptdate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													when /prdacts/
														parent["cmpldate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
													end			
		case parent["tblname"]
		when /^pur/
			strsql = %Q&
						select s.id from shelfnos s 
									inner join  suppliers supplier on supplier.locas_id_supplier = s.locas_id_shelfno
																	and supplier.id = #{parent["suppliers_id"]}
									where s.code = '000'	
			&
			command_c["#{tblnamechop}_shelfno_id_fm"] =  child["shelfnos_id_fm"] = ActiveRecord::Base.connection.select_value(strsql)
		else
			command_c["#{tblnamechop}_shelfno_id_fm"] =  child["shelfnos_id_fm"] = parent["shelfnos_id"]  ###親の作業場所
		end
		stkinout = {}
		case parent["tblname"]
		when /schs$/
		 	str_pare_qty = "qty_sch"
			str_con_qty = "qty_sch"
		when /ords$/
		 	str_pare_qty = "qty"
			str_con_qty = "qty"
		when /acts/
		 	str_pare_qty = "qty_stk"
			str_con_qty = "qty_stk"
		when /purdlvs/
		 	str_pare_qty = "qty_stk"
			str_con_qty = "qty_stk"
		else
		 	str_pare_qty = "qty"
			str_con_qty = "qty"
		end

		
		stkinout["qty_sch"] = stkinout["qty"] = stkinout["qty_stk"] =  stkinout["qty_real"] = 0
		command_c["#{tblnamechop}_#{str_con_qty}"] = CtlFields.proc_cal_qty_sch(parent[str_pare_qty].to_f,
										                              child["chilnum"].to_f,child["parenum"].to_f)
		command_c["#{tblnamechop}_person_id_upd"] = reqparams[:person_id_upd]
		command_c["#{tblnamechop}_created_at"] = Time.now
		command_c["id"] = ArelCtl.proc_get_nextval("#{tblnamechop}s_seq")
		blk.proc_private_aud_rec(reqparams,command_c)
    params[:tbldata] = blk.tbldata.dup
		last_lotstk = {"tblname" =>  tblnamechop + "s" ,"tblid" => command_c["id"] ,"qty_src" => command_c["#{tblnamechop}_#{str_con_qty}"]}	
    return last_lotstk
	end	
  
	def proc_update_consume(tblname,tbldata,last_rec,decrease) ##   tblname-->paretblname decrease
		####
		###  decrease :true 消費の取り消し ,:false 消費の復活     all chiid items by parent 
		#### 
    last_lotstks = []
    str_qty = case tblname
              when /schs/
                "qty_sch"
              when /acts$|dlvs$|custinsts$/
                "qty_stk"
              when  /ords|insts|reply/
                "qty"
              else
                raise
              end
    conTblname = tblname.sub(/prd|pur/,"con")
    strsql = %Q&
                select * from #{conTblname} con 
                          where con.paretblid =  #{tbldata["id"]} and paretblname = '#{tblname}' and #{str_qty} > 0
    &
    ActiveRecord::Base.connection.select_all(strsql).each do |consume|
      if decrease 
						Rails.logger.debug" class #{self} ,line:#{__LINE__} consume[str_qty]:#{consume[str_qty]},tbldata[str_qty]:#{tbldata[str_qty]},last_rec[str_qty]:#{last_rec[str_qty]}"
        new_con_qty = consume[str_qty] * (tbldata[str_qty] / last_rec[str_qty])
        last_lotstks << {"tblname" => conTblname,"tblid" => consume["id"],"qty_src" =>  new_con_qty -  consume[str_qty]}  #
      else 
        ndsql = %Q%
                    select itms_id_nditm itms_id,processseq_nditm processseq,chilnum,parenum,consumunitqty,consumminqty,consumchgoverqty
                               from nditms nd 
                               where nd.opeitms_id = #{tbldata["opeitms_id"]}  ---親
                               and nd.itms_id_nditm = #{consume["itms_id"]}  and nd.processseq_nditm = #{consume["processseq"]}
															 order by  nd.priority_nditm desc
                       %
        nd = ActiveRecord::Base.connection.select_one(ndsql)
        new_con_qty = CtlField.proc_cal_qty_sch(tbldata[str_qty].to_f, nd["chilnum"],nd["parenum"])
        last_lotstks << {"tblname" => conTblname,"tblid" => consume["id"],"qty_src" =>  new_con_qty - consume[str_qty].to_f,
                          "paretblname" => tblname,"paretblid" => tbldata["id"]}
      end
      prev = RorBlkCtl::BlkClass.new("r_#{conTblname}")
		  command_prev = prev.command_init
      consume.each do |field,val|
        command_prev[conTblname.chop+ "_" + field.sub("s_id","_id")] = val
      end
      command_prev[conTblname.chop+"_"+str_qty] = new_con_qty
      command_prev[conTblname.chop+"_person_id_upd"] = tbldata["persons_id_upd"]
		  command_prev["sio_classname"] = "r_#{conTblname}_update_"
		  command_prev["sio_code"] =  command_prev["sio_viewname"] =  "r_#{conTblname}"
		  command_prev["sio_message_contents"] = nil
		  command_prev["sio_recordcount"] = 1
		  command_prev["sio_result_f"] =   "0"  
		  command_prev["id"] =   consume["id"]  
      prev.proc_create_tbldata(command_prev) ##
      prev.proc_private_aud_rec({},command_prev)
    end
      ####
    return last_lotstks
	end	
	
	###
	def proc_lotstkhists_in_out(inout,stkinout)   ###,old_alloc,srctblname
		case inout
		when "out" 
			plusminus = -1
		else  ### in update
			plusminus = 1
		end
		new_stkinout = stkinout.dup
		stkinout["qty_sch"] = stkinout["qty_sch"].to_f * plusminus  
		stkinout["qty"] = stkinout["qty"].to_f * plusminus  
		stkinout["qty_stk"] = stkinout["qty_stk"].to_f * plusminus  
		stkinout["qty_real"] = stkinout["qty_real"].to_f * plusminus 
		stkinout["qty_rejection"] = stkinout["qty_rejection"].to_f * plusminus 
		##ActiveRecord::Base.connection.execute("lock table lotstkhists in  SHARE ROW EXCLUSIVE mode")
		###ActiveRecord::Base.connection.select_one("select * from itms where id = #{stkinout["itms_id"]} for update")
		strsql = %Q% select *	from lotstkhists
								where   itms_id = #{stkinout["itms_id"]} and  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime = to_timestamp('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
										for update
										---　一件のみ
				%
		lotstkhists =  ActiveRecord::Base.connection.select_one(strsql)
		if lotstkhists.nil?
			last_strsql = %Q% select *	from lotstkhists
									where   itms_id = #{stkinout["itms_id"]} and  											  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime < to_timestamp('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
									order by starttime desc limit 1 for update
					%
			last_lotstk =  ActiveRecord::Base.connection.select_one(last_strsql)
			if last_lotstk.nil?
				last_lotstk = {"qty_sch" =>0,"qty" => 0,"qty_stk" => 0,"qty_real" => 0,"qty_rejection" => 0,"packno" => "","lotno" => ""}
			end
			new_stkinout["qty_sch"] = stkinout["qty_sch"] + last_lotstk["qty_sch"].to_f 
			new_stkinout["qty"]     = stkinout["qty"] + last_lotstk["qty"].to_f
			new_stkinout["qty_stk"] = stkinout["qty_stk"] +  last_lotstk["qty_stk"].to_f
			new_stkinout["qty_real"] = stkinout["qty_real"] +  last_lotstk["qty_real"].to_f
			new_stkinout["qty_rejection"] = stkinout["qty_rejection"] +  last_lotstk["qty_rejection"].to_f
			new_stkinout["lotstkhists_id"] = stkinout["lotstkhists_id"] = stkinout["srctblid"] = ArelCtl.proc_get_nextval("lotstkhists_seq") 
			ActiveRecord::Base.connection.insert(insert_lotstkhists_sql(new_stkinout)) 
			###
		else
			stkinout["lotstkhists_id"] =  stkinout["srctblid"] = lotstkhists["id"]
			###
			new_stkinout["qty_sch"] = stkinout["qty_sch"] + lotstkhists["qty_sch"]
			new_stkinout["qty"]     = stkinout["qty"]+ lotstkhists["qty"]
			new_stkinout["qty_stk"] = stkinout["qty_stk"] +  lotstkhists["qty_stk"]
			new_stkinout["qty_real"] = stkinout["qty_real"] +  lotstkhists["qty_real"]
			new_stkinout["qty_rejection"] = stkinout["qty_rejection"] +  lotstkhists["qty_rejection"]
			strsql = %Q& update lotstkhists set  
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									persons_id_upd = #{new_stkinout["persons_id_upd"]||=0},
									qty_rejection = #{new_stkinout["qty_rejection"]},
									qty_stk = #{new_stkinout["qty_stk"]},
									qty_real = #{new_stkinout["qty_real"]},
									qty = #{new_stkinout["qty"]} ,
									qty_sch = #{new_stkinout["qty_sch"]}  
									where id = #{lotstkhists["id"]}
						&
			ActiveRecord::Base.connection.update(strsql)
		end
		###
		###未来の推定在庫を変更する。
		###
		strsql = %Q& select *
								from lotstkhists
								where   itms_id = #{stkinout["itms_id"]} and  
										shelfnos_id = #{stkinout["shelfnos_id"]} and 
										processseq = #{stkinout["processseq"]} and
										prjnos_id = #{stkinout["prjnos_id"]} and
										starttime > to_timestamp('#{stkinout["starttime"]}','yyyy-mm-dd hh24:mi:ss') and 
										packno = '#{stkinout["packno"]}' and  lotno = '#{stkinout["lotno"]}'
										order by starttime for update
				&
		ActiveRecord::Base.connection.select_all(strsql).each do |futrec|
			strsql = %Q& update lotstkhists set  
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									persons_id_upd = #{new_stkinout["persons_id_upd"]||=0},
									qty_rejection = #{stkinout["qty_rejection"].to_f * plusminus + futrec["qty_rejection"].to_f},
									qty_stk = #{stkinout["qty_stk"].to_f * plusminus + futrec["qty_stk"].to_f},
									qty = #{stkinout["qty"].to_f * plusminus + futrec["qty"].to_f},
									qty_sch = #{stkinout["qty_sch"].to_f  * plusminus + futrec["qty_sch"].to_f} 
									where id = #{futrec["id"]}					
						&
			ActiveRecord::Base.connection.update(strsql) 
		end
		return stkinout
	end


	def insert_lotstkhists_sql stkinout
		 %Q&insert into lotstkhists(id,
								starttime,
								itms_id,processseq,
								shelfnos_id,stktakingproc,
								qty_sch,qty_stk,qty,qty_real,
                qty_rejection,
								lotno,packno,
								prjnos_id,
								created_at,	updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{stkinout["lotstkhists_id"]},
								'#{stkinout["starttime"]}',
								#{stkinout["itms_id"]} ,#{stkinout["processseq"]},
								#{stkinout["shelfnos_id"]},'#{stkinout["stktakingproc"]}',
								#{stkinout["qty_sch"]} ,#{stkinout["qty_stk"]},#{stkinout["qty"]},#{stkinout["qty_real"]||=stkinout["qty_stk"]},
                #{stkinout["qty_rejection"]},
								'#{stkinout["lotno"]}' ,'#{stkinout["packno"]}',
								#{stkinout["prjnos_id"]},
					current_timestamp,current_timestamp,
								' ',#{stkinout["persons_id_upd"]},'2099/12/31','#{stkinout["remark"]}')
		&
	end

	
	def proc_mk_custwhs_rec inout,stkinout  ###lotstkhistsは棚のみ
		if inout == "in"
			plusminus = 1
		else
			plusminus = -1
		end
		stkinout["qty_sch"] = stkinout["qty_sch"].to_f * plusminus
		stkinout["qty"] = stkinout["qty"].to_f * plusminus
		stkinout["qty_stk"] = stkinout["qty_stk"].to_f * plusminus
		strsql = %Q&
				select * from custwhs where itms_id = #{stkinout["itms_id"]} and processseq = #{stkinout["processseq"]}
					and custrcvplcs_id = #{stkinout["custrcvplcs_id"]} and lotno = '#{stkinout["lotno"]}'
					and starttime = '#{stkinout["starttime"]}'
		&
		rec = ActiveRecord::Base.connection.select_one(strsql)
		if rec.nil?
			custwhs_id = ArelCtl.proc_get_nextval("custwhs_seq")
			strsql = %Q&insert into custwhs(id,custrcvplcs_id,
								starttime,
								qty_sch,qty,qty_stk,
								lotno,itms_id,processseq,
								created_at,
								updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{custwhs_id},#{stkinout["custrcvplcs_id"]},
								'#{stkinout["starttime"]}',
								#{stkinout["qty_sch"]},#{stkinout["qty"]},#{stkinout["qty_stk"]},
								'#{stkinout["lotno"]}',#{stkinout["itms_id"]},#{stkinout["processseq"]},
					      current_timestamp,current_timestamp,
								' ',#{stkinout["persons_id_upd"]},'2099/12/31','#{stkinout["remark"]}')
				&
			ActiveRecord::Base.connection.insert(strsql)
		else
			custwhs_id = rec["id"]
			update_sql = %Q% update custwhs set 
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									qty_sch = qty_sch + #{stkinout["qty_sch"]},
									qty = qty + #{stkinout["qty"]},
									qty_stk = qty_stk + #{stkinout["qty_stk"]},
									remark = '#{stkinout["remark"] }'
									where id = #{custwhs_id} 
				%
			ActiveRecord::Base.connection.update(update_sql) 
		end
		stkinout["srctblid"] =  stkinout["custwhs_id"] =  custwhs_id
		stkinout["srctblname"] =   "custwhs"

		return stkinout
	end

	def proc_mk_supplierwhs_rec inout,stkinout  ###lotstkhistsは棚のみ

		if inout == "in"
			plusminus = 1
		else
			plusminus = -1
		end
		stkinout["qty_sch"] = stkinout["qty_sch"].to_f * plusminus
		stkinout["qty"] = stkinout["qty"].to_f * plusminus
		stkinout["qty_stk"] = stkinout["qty_stk"].to_f * plusminus
		strsql = %Q& ---packnoの管理はしない。
				select * from supplierwhs where itms_id = #{stkinout["itms_id"]} and processseq = #{stkinout["processseq"]}
										and suppliers_id = #{stkinout["suppliers_id"]} and lotno = '#{stkinout["lotno"]}'
										and starttime = to_timestamp('#{stkinout["starttime"]}','yyyy/mm/dd hh24:mi:ss')
		&
		rec = ActiveRecord::Base.connection.select_one(strsql)
		if rec.nil?
			supplierwhs_id = ArelCtl.proc_get_nextval("supplierwhs_seq")
			strsql = %Q&insert into supplierwhs(id,suppliers_id,
								starttime,
								qty_sch,
								qty,
								qty_stk,
								lotno,itms_id,processseq,
								created_at,	updated_at,
								update_ip,persons_id_upd,expiredate,remark)
						values(#{supplierwhs_id},#{stkinout["suppliers_id"]},
								'#{stkinout["starttime"]}',
								#{stkinout["qty_sch"]},
								#{stkinout["qty"]},
								#{stkinout["qty_stk"]},
								'#{stkinout["lotno"]}',#{stkinout["itms_id"]},#{stkinout["processseq"]},
                current_timestamp,current_timestamp,
								' ',#{stkinout["persons_id_upd"]},'2099/12/31','')
				&
			ActiveRecord::Base.connection.insert(strsql)
		else
			update_sql = %Q% update supplierwhs set 
									updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
									qty_sch = qty_sch + #{stkinout["qty_sch"]},
									qty = qty + #{stkinout["qty"]},
									qty_stk = qty_stk + #{stkinout["qty_stk"]}
									where id = #{rec["id"]} 
				%
			ActiveRecord::Base.connection.update(update_sql) 
			supplierwhs_id = rec["id"]
		end
		stkinout["srctblid"] = stkinout["suppliers_id"]
		stkinout["srctblname"] =   "suppliers"
		return stkinout
	end

	def shpord_create_by_shpsch(shp)  ###
		###自分自身のshpschs を作成   
    last_lotstks = []
		blk = RorBlkCtl::BlkClass.new("r_shpords")
		command_c = blk.command_init
		command_c["sio_classname"] = "shpords_add_"
		command_c["shpord_id"] = "" 
		command_c["shpord_isudate"] = Time.now
		command_c["shpord_shelfno_id_to"] = shp["shelfnos_id_to"] ##
		command_c["shpord_shelfno_id_fm"] = shp["shelfnos_id_fm"]  ###
		command_c["shpord_duedate"] = shp["duedate"]
		command_c["shpord_depdate"] = shp["depdate"]
    ###
    #  transports_id not support yet
    #
		command_c["shpord_transport_id"] = 0
    ###
		command_c["shpord_paretblname"] = shp["paretblname"] 
		command_c["shpord_paretblid"] = shp["paretblid"]
		command_c["shpord_itm_id"] = shp["itms_id"]   ### from shpords
		command_c["shpord_processseq"] = shp["processseq"]
		command_c["shpord_prjno_id"] = shp["prjnos_id"]
		command_c["shpord_chrg_id"] = shp["chrgs_id_trn"]
		command_c["shpord_person_id_upd"] = shp["persons_id_upd"]
		command_c["shpord_expiredate"] = shp["expiredate"]

		command_c["shpord_qty"] = shp["qty_stk"]
		command_c["shpord_qty_shortage"] = shp["qty_shortage"].to_f  
		command_c["shpord_qty_case"] =  if shp["packqty"].to_f == 0 
												1
											else
												(shp["qty"].to_f / shp["packqty"].to_f).ceil
											end

		if shp["paretblname"] =~ /^pur/   ###tblname= 'feepayment'--->有償支給
					paidsupplierprice command_c,shp,"shpord"
		else
			command_c["shpord_contractprice"] = 'C'
			command_c["shpord_crr_id"] = 0
			command_c["shpord_price"] = 0
			command_c["shpord_tax"] = 0 
			command_c["shpord_taxrate"] = 0
			command_c["shpord_masterprice"] = 0
		end		
		command_c["shpord_qty_case"] =  shp["qty_case"]
		command_c["shpord_sno"] = "" 	
		command_c["shpord_gno"] = shp["gno"] 	
		command_c["shpord_amt"] = command_c["shpord_qty"] * command_c["shpord_price"].to_f  ###CtlFieldsから求める。
		command_c["shpord_packno"] = shp["packno"]  
		command_c["shpord_lotno"] = shp["lotno"]
		
		command_c["id"] = ArelCtl.proc_get_nextval("shpords_seq")
		command_c["shpord_created_at"] = Time.now
		blk.proc_private_aud_rec({},command_c)
    
		last_lotstks << {"tblname" => "shpords","tblid" => command_c["id"],"qty_src" => command_c["shpord_qty"] }
		###
		#  mold,ITollのshpxxxxのlinktbls
		###
		last_lotstks_parts = update_mold_IToll_shp_link(blk.tbldata,"add") do
			"shpord"
		end
    last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
		###
    return last_lotstks
	end	

	def update_mold_IToll_shp_link(shp,aud)  ###金型の出荷はtrnganttsに含む
    last_lotstks = []
		case yield
		when "shpest"
			if aud == "add"
				return
			else
			end
		when "shpsch"
			prevshp = "shpests"
			currshp = "shpschs"
		when "shpord"
			prevshp = "shpschs"
			currshp = "shpords"
		when "shpdlv"
			prevshp = "shpords"
			currshp = "shpdlvs"
		when "shpact"
			prevshp = "shpdlvs"
			currshp = "shpacts"
		else
			return
		end

		case  yield 
		when /shpsch|shpord/
			strsql = %Q&
					select l.* from #{currshp} s  
								inner join (select i.id itms_id ,c.code from itms i
												inner join classlists c on c.id = i.classlists_id ) ic
								on s.itms_id = ic.itms_id
								inner join linktbls l on l.tblid = s.paretblid and l.tblname = s.paretblname
								where ic.code in('mold','IToll') and s.id = #{shp["id"]} 
								and (l.srctblname != l.tblname or l.srctblid != l.tblid) 
			&
			ActiveRecord::Base.connection.select_all(strsql).each do |link|
				strsql = %Q&
					select shplink.* from linktbls shplink
							inner join #{prevshp} prevshp
							on shplink.tblname = '#{prevshp}' and shplink.tblid = prevshp.id 
							where	  prevshp.paretblname = '#{link["srctblname"]}'  and prevshp.paretblid = #{link["srctblid"]}) shp
					&
				ActiveRecord::Base.connection.select_all(strsql).each do |shplink|
					link_update_sql = %Q&
							update linktbls set qty_src = 0 ,remark = '#{self} #{__LINE__} #{Time.now}'||remark 
								where    id = #{shplink["id"]}
					& 
					ActiveRecord::Base.connection.update(link_update_sql)
          alloc = {trngantts_id => shplink["trngantts_id"] ,srctblname => shplink["srctblname"],srctblid => shplink["srctblname"],
                  "qty_linkto_alloctbl" => 0,
                  "remark" => "#{self} line #{__LINE__} #{Time.now}"}
          alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
          last_lotstks << last_lotstk
          3.times{Rails.logger.debug" class:#{self} , line:#{__LINE__} ,error last_lotstk:#{last_lotstk}"} if  last_lotstk.nil? or last_lotstk["tblname"].nil? or last_lotstk["tblname"] == ""

					src = {"tblname" => prevshp,"tblid" => shplink["tblid"],"trngantts_id" => shplink["trngantts_id"]}
					base = {"tblname" =>currshp,"tblid" => shp["id"],"qty_src" => 1,"amt_src" => 0,
						"remark" => "#{self} line #{__LINE__}", 
						"persons_id_upd" => reqparams[:person_id_upd]}
					alloc = {"srctblname" => currshp,"srctblid" => shp["id"],"trngantts_id" => shplink["trngantts_id"],
						"qty_linkto_alloctbl" => 1,
						"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"],
						"allocfree" => 	"alloc"}
					linktbl_id = ArelCtl.proc_insert_linktbls(src,base)
					alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,nil)
          last_lotstks << last_lotstk
				end
			end 
		when /shpdlv|shpact/  ###paretblname,paretblidはshpordsから引き継ぐ
			strsql = %Q&
					select l.* from #{prevshp} s  
								inner join (select i.id itms_id ,c.code from itms i
													inner join classlists c on c.id = i.classlists_id ) ic
								on s.itms_id = ic.itms_id
								inner join linktbls l on l.tblid = s.id and l.tblname = '#{prevshp}'  ---linktbks shpxxx
								where ic.code in('mold','IToll') and s.paretblid = #{shp["paretblid"]}
								and (l.srctblname != l.tblname or l.srctblid != l.tblid) 
			&
			ActiveRecord::Base.connection.select_all(strsql).each do |shplink|
				link_update_sql = %Q&
						update linktbls set qty_src = 0 ,remark = '#{self} #{__LINE__} #{Time.now}'||remark 
							where    id = #{shplink["id"]}
				& 
				ActiveRecord::Base.connection.update(link_update_sql)
        alloc = {trngantts_id => shplink["trngantts_id"] ,srctblname => shplink["tblname"],srctblid => shplink["tblname"],
                "qty_linkto_alloctbl" => 0, "remark" => "#{self} line #{__LINE__} #{Time.now}"}
        alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
        last_lotstks << last_lotstk

				src = {"tblname" => prevshp,"tblid" => shplink["tblid"],"trngantts_id" => shplink["trngantts_id"]}
				base = {"tblname" =>currshp,"tblid" => shp["id"],"qty_src" => 1,"amt_src" => 0,
					      "remark" => "#{self} line #{__LINE__}"}
				alloc = {"srctblname" => currshp,"srctblid" => shp["id"],"trngantts_id" => shplink["trngantts_id"],
					"qty_linkto_alloctbl" => 1,
					"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => shp["persons_id_upd"],
					"allocfree" => 	"alloc"}
				alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,nil)
        last_lotstks << last_lotstk
				linktbl_id = ArelCtl.proc_insert_linktbls(src,base)
			end
		end
    return last_lotstks
	end 
  def proc_deleteShpxxxsByParent(paretblname,paretblid,shptblname)
    case shptblname
      when "shpschs"
        str_qty = "shpsch_qty_sch"
        str_qty_case = "shpsch_qty_case"
				str_price = "shpsch_price"
				str_amt = "shpsch_amt_sch"
				str_taxrate = "shpsch_taxrate"
				lastshptblname = nil
				str_exists_sql = %Q%
							and not exists (select 1 from  shpords
                        where paretblname ='#{paretblname}'  and paretblid = #{paretblid}
												and qty > 0 )
			% 
      when "shpords"
        str_qty = "shpord_qty"
        str_qty_case = "shpord_qty_case"
				str_price = "shpord_price"
				str_amt = "shpord_amt"
				str_taxrate = "shpord_taxrate"
				lastshptblname = "shpschs"
				str_exists_sql = %Q%
							and not exists (select 1 from  shpdlvs dlv
                        where paretblname ='#{paretblname}' and   paretblid = #{paretblid}
												and (dlv.qty_stk > 0 or dlv.qty_shortage > 0) and shp.shpord_gno = dlv.gno_shpord )
			% 
      when "shpdlvs"
        str_qty = "shpdlv_qty_stk"
        str_qty_case = "shpdlv_qty_case"
				str_price = "shpdlv_price"
				str_amt = "shpdlv_amt"
				str_taxrate = "shpdlv_taxrate"
				lastshptblname = nil
				str_exists_sql = %Q%
							and not exists (select 1 from  shpacts act
                        where paretblname ='#{paretblname}'  and   paretblid = #{paretblid}
												and (act.qty_stk > 0 or act.qty_shortage > 0) and shp.shpdlv_gno_shpord = act.gno_shpord )
			% 
      when "shpacts"
        str_qty = "shpact_qty_stk"
        str_qty_case = "shpact_qty_case"
				str_price = "shpact_price"
				str_amt = "shpact_amt"
				str_taxrate = "shpact_taxrate"
				lastshptblname = nil
				str_exists_sql = ""
    end
    last_lotstks = []
		del_cnt = 0
		parent =   ActiveRecord::Base.connection.select_one("select * from #{paretblname} where id = #{paretblid}")
		parent["tblname"] = paretblname
		parent["tblid"] = paretblid
		if shptblname == "shpschs"
    			strsql = %Q&
                select * from r_shpschs shp
                        where shpsch_paretblname ='#{paretblname}' 
												and #{str_qty} > 0 
                        and   shpsch_paretblid = #{paretblid} #{str_exists_sql}
                            &					
		else
    			strsql = %Q&
                select * from r_#{shptblname} shp
                        where #{shptblname.chop}_paretblname ='#{paretblname}' 
												and (#{str_qty} > 0 or #{shptblname.chop}_qty_shortage > 0)
                        and   #{shptblname.chop}_paretblid = #{paretblid} #{str_exists_sql}
                            &					
		end
    ActiveRecord::Base.connection.select_all(strsql).each do |shp|
      blk = RorBlkCtl::BlkClass.new("r_#{shptblname}")
      command_c = blk.command_init
      command_c["sio_classname"] = "#{shptblname}_update_"
      command_c.merge!(shp)
      command_c[str_qty] =  0
      command_c[str_qty_case] =  0
      command_c[str_price] =  0
      command_c[str_amt] =  0
      command_c[str_taxrate] =  0
      command_c["#{shptblname.chop}_expiredate"] =  Constants::BeginnigDate
			if shptblname != "shpschs"
      		command_c["#{shptblname.chop}_qty_shortage"] =  0
			end
      blk.proc_private_aud_rec({},command_c) 
			if shp[str_qty] > 0
      	last_lotstks << {"tblname" =>shptblname,"tblid" => shp["id"],"qty_src" =>shp[str_qty] * -1 }  ###
			end
			del_cnt += 1
			if lastshptblname
					strsql = %Q&
											select shp.*,nd.consumtype,nd.chilnum,nd.parenum,nd.consumunitqty,nd.consumminqty,nd.consumchgoverqty,
													ope.packqty 
													from #{lastshptblname} shp
													inner join nditms nd on nd.opeitms_id = #{parent["opeitms_id"]}
																							and nd.itms_id_nditm = shp.itms_id and nd.processseq_nditm = shp.processseq 
													inner join opeitms ope on ope.itms_id = shp.itms_id and ope.processseq = shp.processseq and ope.priority = 999
					&
					child =   ActiveRecord::Base.connection.select_one(strsql)
					params = {:parent => parent,:child => child,:person_id_upd => shp["#{shptblname.chop}_person_id_upd"]}
				 	last_lotstks_parts = proc_create_shpxxxs(params) do
														lastshptblname.chop
					end
    			last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
			end
		end
    return last_lotstks,del_cnt
  end

	def paidsupplierprice command_c,shp,shptblnamechop
				strsql = %Q%
								select m.contractprice,m.id from suppliers m
													inner join shelfnos s on s.locas_id_shelfno = m.locas_id_supplier
													where s.id = #{shp["shelfnos_id_to"]}
				%
				supplier = ActiveRecord::Base.connection.select_one(strsql)
				if supplier
						command_c,err = CtlFields.proc_judge_check_paidsupplierprice(command_c,"price",0,"r_#{shptblnamechop}s")
						if err == false
										strsql = %Q%
																select * from taxtbls where taxflg = '#{shp["itm_taxflg"]}' and expiredtae > '#{shp["dcepdate"]}'
																					order by expiredtae desc
										%
								    taxrate = ActiveRecord::Base.connection.select_one(strsql)
										command_c["#{shptblnamechop}_taxrate"] = taxrate["taxrate"].to_f
										command_c["#{shptblnamechop}_tax"] = command_c["#{shptblnamechop}_amt"]  *  taxrate["taxrate"].to_f
						else
										command_c["#{shptblnamechop}_contractprice"] = 'C'
										command_c["#{shptblnamechop}_crr_id"] = 0
										command_c["#{shptblnamechop}_price"] = 0
										command_c["#{shptblnamechop}_tax"] = 0
										command_c["#{shptblnamechop}_taxrate"] = 0
										command_c["#{shptblnamechop}_masterprice"] = 0
						end
				else
					command_c["#{shptblnamechop}_contractprice"] = 'C'
					command_c["#{shptblnamechop}_crr_id"] = 0
					command_c["#{shptblnamechop}_price"] = 0
					command_c["#{shptblnamechop}_tax"] = 0
					command_c["#{shptblnamechop}_taxrate"] = 0
					command_c["#{shptblnamechop}_masterprice"] = 0
				end	
				return command_c,err			
	end
end
