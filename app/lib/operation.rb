# -*- coding: utf-8 -*-
# operation
# 2099/12/31を修正する時は　2100/01/01の修正も
# Operationではamtは扱わない
module Operation
	extend self
  class OpeClass
	  def initialize(params)
		  @reqparams = params.dup
		  @gantt = params[:gantt].dup ###reqparamsのtblの情報もここでセットしている。
		  @tblname = @gantt["tblname"] ###
		  @tblid = @gantt["tblid"]
		  @paretblname = @gantt["paretblname"]
		  @paretblid = @gantt["paretblid"]
		  @orgtblname = @gantt["orgtblname"]
		  @orgtblid = @gantt["orgtblid"]

		  @tbldata = params[:tbldata].dup
		  @tbldata["trngantts_id"] = @gantt["trngantts_id"]
		  @tbldata["itms_id"] = @gantt["itms_id_trn"]
		  @tbldata["processseq"] = @gantt["processseq_trn"]  
		  @mkprdpurords_id = (params[:mkprdpurords_id]||=0)
		
		  @opeitm = params[:opeitm].dup  ###tbldataのopeitmsの情報
		  @str_qty = case @tblname
			  when /acts$|rets$|purdlvs$|custdlvs$|custinsts$/
				  "qty_stk"
			  when /schs$/
				  "qty_sch"
			  else
				  "qty"
			  end
      
		  @str_duedate = case @tblname
      when /purdlvs|custdlvs/
        "depdate"
      when /^puracts|^shpacts|^shpinsts/
        "rcptdate"
      when /^prdacts|^dvsacts|^ercacts/
        "cmpldate"
      when /^custacts/
        "saledate"
      when /rets/
        "retdate"
      when /reply/
        "replydate"
      else
        "duedate"
      end  
    @str_starttime = case @tblname
        when /purdlvs|custdlvs|^shp/
          "depdate"
        when /^puracts/
          "rcptdate"
        when /^custacts/
          "saledate"
        when /rets/
          "retdate"
        when /reply/
          "replydate"
        when /^dvsacts|^ercacts|^dvsinsts|^ercinsts|^dvsords|^ercords/
          "commencementdate"
        else
          "starttime"
        end  
	  end

    def proc_opeParams
        @reqparams
    end

	  ###------------------------------------------------------
	  def proc_trngantts_insert()  ###schs,ords専用
        last_lotstks = []
		    ###schs,ordsの新規
			  if (@tblid == @paretblid and @tblname == @paretblname and @tblid == @orgtblid and @tblname == @orgtblname) 
				  ###schs$,ords$--->新規本体を作成  ^pur,^prd 
				  last_lotstks = init_trngantts_add_detail()
			  else ###構成の一部になっているとき(本体を作成後確認)
				  last_lotstks =  child_trngantts()  
			  end
        return last_lotstks
    end
    def proc_trngantts_update(last_rec,chng_flg)  ###schs,ords専用
      ### qty,qty_stkはqty_linkto_alloctbl以下にはできない。
      ###出庫指示数以下にはできない。
      ###locas_idの変更は不可(オンライン、入り口でチェック) 
      ###前の在庫　をzeroに
      ###  xxxschsはtop以外修正できない trnganttsの値を修正

      ###新shelfnos_id_fmで出庫・消費を作成(数量増の変更で対応)
      ###数量又は納期の変更があった時   xxxsxhs,xxxordsの時のみ
      ###
      ### 
		   ###変更　(削除 qty_sch=qty=qty_stk=0 　を含む) purschs,purords,prdschs,prdords
        last_lotstks = []
			  ###check_shelfnos_duedate_qty()  ###
			  return  last_lotstks if chng_flg == ""  ###  last_lotstks = []
			  ###数量・納期・場所の変更があった時
			 
				strsql = %Q% 
						select t.* from trngantts t  ---有効なtrnganttsを取得する。
                  inner join alloctbls a on t.tblname = a.srctblname and t.tblid = a.srctblid
                                        and a.qty_linkto_alloctbl > 0
                  where t.tblname = '#{@tblname}' and t.tblid = #{@tblid}
						%
			  target_trngantt = ActiveRecord::Base.connection.select_one(strsql)
			  return last_lotstks   if target_trngantt.nil? ###  last_lotstks = []
			  @trngantts_id =  @gantt["trngantts_id"]  = last_rec["trngantts_id"] = target_trngantt["id"]
        update_strsql = %Q&   ---ここでは在庫、引き当ての変更はしない。
                        update trngantts set   --- xxschs,xxxordsが変更された時のみ
                              updated_at = cast('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp),
                              remark = '#{self}  line:#{__LINE__}'||left(remark,3000),
                              #{@str_qty.to_s} = #{case @tblname
                                when /^erc|^dvs/
                                  1
                                else
                                  @tbldata[@str_qty]
                                end},
                              prjnos_id = #{@tbldata["prjnos_id"]},
                              duedate_trn = '#{@tbldata[@str_duedate]}',starttime_trn = '#{@tbldata[@str_starttime]}',
                              shelfnos_id_to_trn = #{case @tblname
                                  when /^cust|^erc|^dvs/
                                    0
                                  else
                                    @tbldata["shelfnos_id_to"]
                                  end}
                            where  id = #{@trngantts_id} &
        ActiveRecord::Base.connection.update(update_strsql) 
        case @tblname 
          when  /^prd/ 
              if @tblname =~ /^prdords$/ and  chng_flg != ""
                last_lotstks = update_prdpurord(chng_flg,last_lotstks,last_rec)
              end
              if (@tbldata["qty_sch"].to_f  == 0 or chng_flg =~ /due/)   ###数量が減っても装置の変更はない。
                  ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each do |apparatus|
                    @reqparams[:apparatus] = apparatus
                    ope = Operation::OpeClass.new(@reqparams)  ###prdinsts,prdacts
                    ope.proc_delete_dvs_data
                    ope.proc_delete_erc_data
                  end
              end
              if @tbldata["qty_sch"].to_f  > 0   and  chng_flg =~ /due/ 
                ActiveRecord::Base.connection.select_all(ArelCtl.proc_apparatus_sql(@tbldata["opeitms_id"])).each_with_index do |apparatus,idx|
                  if idx == 0
                    schsParams = @reqparams.dup
                    schsParams[:gantt] =  ActiveRecord::Base.connection.select_one(%Q&
                                            select key ,
						                                      orgtblname,orgtblid,tblname paretblname,tblid paretblid,
						                                      tblname,tblid,mlevel,shuffleflg,parenum,chilnum,qty_sch,qty,qty_stk,
                                                  qty_require,qty_pare,qty_sch_pare,qty_handover,prjnos_id,shelfnos_id_to_trn,
                                                  shelfnos_id_to_pare,itms_id_trn,processseq_trn,shelfnos_id_trn,
                                                  itms_id_pare,processseq_pare,shelfnos_id_pare,
                                                  itms_id_org,processseq_org,shelfnos_id_org,consumunitqty,consumminqty,
                                                  consumchgoverqty,starttime_trn,starttime_pare,starttime_org,duedate_trn,
                                                  duedate_pare,duedate_org,toduedate_trn,toduedate_pare,toduedate_org,consumtype,
                                                  chrgs_id_trn,chrgs_id_pare,chrgs_id_org 
                                                  from trngantts 
                                                  where tblname = '#{@tblname}' and tblid = #{@tbldata["id"]}
                                          &)
                    schsParams[:tbldata] =  ActiveRecord::Base.connection.select_one(%Q&
                                    select * from #{@tblname} where id = #{@tbldata["id"]}
                                &)
                  end
                  schsParams[:gantt]["key"] = schsParams[:gantt]["key"] + format('%05d', idx)
                  schsParams[:apparatus] = apparatus
                  ope = Operation::OpeClass.new(schsParams)  ###prdinsts,prdacts
                  ope.proc_add_dvs_data apparatus  ###target:current table
                  ope.proc_add_erc_data apparatus
                end
              end
          when /purords$/ 
              last_lotstks = update_prdpurord(chng_flg,last_lotstks,last_rec)
					when /purschs|prdschs/   ###xxxordsに引き合ったschsは対象外
								strsql = %Q%
														select l.id link_id,a.id alloc_id,l.trngantts_id from linktbls l
																				inner join alloctbls a on l.trngantts_id = a.trngantts_id and l.tblname = a.srctblname
																															and l.tblid = a.srctblid
																				where a.srctblname = '#{@tblname}' and a.srctblid = #{tbldata["id"]}
																				and a.qty_linkto_alloctbl > 0 and  l.srctblname = l.tblname and l.srctblid = l.tblid
								%
								sch_link_alloc = ActiveRecord::Base.connection.select_one(strsql)
								if sch_link_alloc
										strsql = %Q&
															update linktbls set qty_src = #{@tbldata["qty_ach"]},amt_src = #{@tbldata["amt_ach"]},
																			remark = 'class:#{self}, line:#{__LINE__} #{Time.now}'||left(remark,100)
																			where id = #{sch_link_alloc["link_id"]}
										&
										ActiveRecord::Base.connection.update(strsql)
										alloc = {"srctblname" => @tblname,"srctblid" => @tbldata["id"],"qty_linkto_alloctbl" => @tbldata["qty_sch"],
															"id" => sch_link_alloc["alloc_id"],"trngantts_id" => sch_link_alloc["trngantts_id"]}
										alloctbl_id,last_lotstk = ArelCtl.proc_aud_alloctbls(alloc,"update")
										last_lotstks << last_lotstk
								end
          when  /^dvs|^erc/
              if @reqparams[:classname] =~ /_purge_|_delete_/
                strsql = %Q&
                            select * from linktbls where tblname = '#{@tblname}' and tblid = #{@tblid}
                &
                ActiveRecord::Base.connection.select_all(strsql).each do |link|
                  strdelsql = %Q&
                            delete from alloctbls where trngantts_id = #{link["trngantts_id"]}
                  &
                  ActiveRecord::Base.connection.delete(strdelsql)
                  strdelsql = %Q&
                            delete from linktbls where trngantts_id = #{link["trngantts_id"]}
                  &
                  ActiveRecord::Base.connection.delete(strdelsql)
                  strdelsql = %Q&
                            delete from trngantts where id = #{link["trngantts_id"]}
                  &
                  ActiveRecord::Base.connection.delete(strdelsql)
                end
              end
          when    /^custords/
				 	    qty =  @tbldata[@str_qty].to_f
				 	    strsql = %Q&
				 			        select * from linkcusts where tblname = 'custords' and tblid = #{@tblid}
													                    and srctblname = 'custschs' 
				 	      &
				 	    links = ActiveRecord::Base.connection.select_all(strsql)
					    if links.to_ary.size > 0    ###custschs引当
				 		    if qty < link["qty_src"].to_f
				 			    update_sql = %Q&
				 				                update linkcusts 
				 					                    set qty_src = #{qty},remark = ' #{self} line:#{__LINE__} '||remark
				 					                  where id = #{link["id"]}
				 			                &
				 			    ActiveRecord::Base.connection.update(update_sql)
							    rcv_qty = qty
							    qty = 0
				 		    else
							    rcv_qty = link["qty_src"]
				 			    qty -= link["qty_src"].to_f
				 		    end
						    custschs_rcv_sql = %Q&
							    update linkcusts  set qty_src = qty_src + #{rcv_qty},remark = ' #{self} line:#{__LINE__} '||remark
								          where tblname = 'custschs' and srctblname = 'custschs'
								        and tblid = #{link["srctblid"]} and srctblid = #{link["srctblid"]}
						 	    &
						    ActiveRecord::Base.connection.update(custschs_rcv_sql)
              end
              #
						  ###return 
              #
					else  ###paretblname=custords,tblname=prd,pur
						  # strsql = %Q% 
							# 		select * from trngantts where paretblname = '#{@tblname}' and paretblid = #{@tblid}
					  	# 						and orgtblname = paretblname and paretblname != tblname
					  	# 						and orgtblid = paretblid 
              #             and tblname in ('prdschs','purschs') 
							# 	%
						  # target_trngantt = ActiveRecord::Base.connection.select_one(strsql)
						  # strsql = %Q&
							# 		 update trngantts set   --- 
							# 			 updated_at = to_timestamp('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}','yyyy/mm/dd hh24:mi:ss'),
							# 			 qty_pare = #{@tbldata[@str_qty]},
							# 			 remark = '#{self}  line:#{__LINE__}'||remark
							# 			 where  id = #{target_trngantt["id"]} &
						  # ActiveRecord::Base.connection.update(strsql) 
						  # ### custordsの直下prdschs,purschsの修正
						  # trn = {"tblname" => target_trngantt["tblname"],"tblid" => target_trngantt["tblid"],
							# 	"pare_qty" =>  @tbldata[@str_qty],"qty" => 0,"qty_stk" => 0,
							# 	"chilnum" => 1,"parenum" => 1,"consumunitqty" => 0,
							# 	"consumminqty" => 0,"consumchgoverqty" => 0,
							# 	"itms_id" => target_trngantt["itms_id_trn"],"processseq" => target_trngantt["processseq_trn"],
							# 	"duration" => 0,"durationfacility" => 0,"packqtyfacility" => 0}
						  # update_prdpur_child(trn)
        end
			  ###下位の構成変更  
			  if target_trngantt["mlevel"].to_i  == 0
				  lowlevel_gantts = []
				  lowlevel_gantts[0] = target_trngantt
				  until lowlevel_gantts.empty?
					  lgantt = lowlevel_gantts.shift
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_pareChildTrnsSql(lgantt)).each do |trn|
						  update_prdpur_child(trn) ###custxxxs,prdxxxxs,purxxxsが対象
						  lowlevel_gantts << trn 
					  end
          end
				end
		  return last_lotstks
	  end
	  ###--------------------------------------------------------------------------------------------
  	###linktblsの追加はRorBlkctlで完了済のこと。
    # consume schs,ords,insts,acts
    #### 
	  def proc_consume_by_parent()  ### target ==> all children 
      last_lotstks = []
		  return  last_lotstks if @gantt["stktakingproc"] != "1"
		  ###if @reqparams[:classname] =~ /_insert_|_add_/  ###trngantts 追加
			  base = {}
        base["shelfnos_id"] =  @tbldata["shelfnos_id"]
        case @tblname
			  when /^purdlvs/  ###packnoはない
				  base["starttime"] = (@tbldata["depdate"].to_time + 24*3600).strftime("%Y-%m-%d %H:%M:%S")  ###カレンダー考慮要
				  base["qty"] = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__}"
			  when /^prdords|^purords/
					base["starttime"] = @tbldata["duedate"]
					base["qty"]  = @tbldata["qty"]
				  base["remark"] = "#{self}  line #{__LINE__} purords,prdords"
			  when /^prdacts/
				  ### trngantts.qty_stkの変更
				  ### qtyはxxxords作成時又は引当時に変更済
				  ### insts,replyints,instsではtrngantts.qtyは変化しない。
				  base["starttime"] = @tbldata["cmpldate"]
				  base["qty_stk"]  = base["qty_real"]  = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__} prdacts"
			  when /^puracts/
				  base["shelfnos_id"] =  @tbldata["shelfnos_id_to"]
				  base["starttime"] = @tbldata["rcptdate"]
				  base["qty_stk"]  = base["qty_real"]  = @tbldata["qty_stk"]
				  base["remark"] = "#{self}  line #{__LINE__} puracts"
			  when /insts|replyinputs/
				  base["starttime"] = @tbldata["duedate"]
				  base["qty"]  = @tbldata["qty"]
				  base["remark"] = "Operation line #{__LINE__}   xxxinsts"
			  when /schs/
				  base["starttime"] = @tbldata["duedate"]
				  base["qty_sch"]  = @tbldata["qty_sch"]
				  base["remark"] = "#{self}  line #{__LINE__}  xxxschs"
			  end	
				case @tblname
				  when /^prdacts|^purdlvs/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conact|
						  next if conact["consumauto"] == "M"  ### qty_stk確定時の消費手動は除く
						  dupParams = @reqparams.dup
						  dupParams[:child] = conact.dup
						  dupParams[:parent] = @tbldata.dup
						  dupParams[:parent]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
              dupParams[:screenCode] = "r_conacts"
						  last_lotstks << Shipment.proc_create_consume(dupParams)
					  end
				  when /^puracts/
					  strsql = %Q&
								select * from linktbls link where tblname = '#{@gantt["tblname"]}' and tblid = #{@gantt["tblid"]}
															and srctblname != 'purdlvs' and qty_src > 0
					  & 
					  ActiveRecord::Base.connection.select_all(strsql).each do |notdlv| 
						  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
							  next if conord["consumauto"] == "M"  ### qty_stk確定時の消費手動は除く
							  dupParams = @reqparams.dup
							  dupParams[:child] = conord.dup
							  dupParams[:parent] = @tbldata.dup
							  dupParams[:parent]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                dupParams[:screenCode] = "r_conacts"
							  last_lotstks << Shipment.proc_create_consume(dupParams)  ###one child
						  end
					  end
				  when /purinsts$|purreplyinputs$|prdinsts$/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
						  dupParams = @reqparams.dup
						  dupParams[:child] = conord.dup
						  dupParams[:parent] = @tbldata.dup
						  dupParams[:parent]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
              dupParams[:screenCode] = "r_conords"
						  last_lotstks << Shipment.proc_create_consume(dupParams)
					  end
					  strsql = %Q%
						  select srctblname,srctblid,qty_src from linktbls where tblname = '#{@tblname}' and tblid = #{@tblid}
					    %
					  ActiveRecord::Base.connection.select_all(strsql).each do |srctbl|
						  prevparetbl = ActiveRecord::Base.connection.select_one(%Q%select * from #{srctbl["srctblname"]} where id = #{srctbl["srctblid"]} %)
						  prevparetbl["tblname"] = srctbl["srctblname"]
						  prevparetbl["tblid"] = srctbl["srctblid"]
						  prevparetbl["qty"] = srctbl["qty_src"] * -1
						  prevchildsql = %Q%
									select nd.* from nditms nd 
											inner join opeitms ope on ope.id = nd.opeitms_id
										where ope.itms_id = #{prevparetbl["opeitms_id"]}
                %
						  ActiveRecord::Base.connection.select_all(prevchildsql).each do |prevchildtbl|
							  prevParams = @reqparams.dup
							  prevParams[:parent] = prevparetbl.dup
							  prevParams[:child] = prevchildtbl.dup
							  dupParams[:parent]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                dupParams[:screenCode] = "r_conords"
							  last_lotstks << Shipment.proc_create_consume(prevParams)
						  end
					  end
				  when /purords$|prdords$/
					  ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
						  dupParams = @reqparams.dup
						  dupParams[:child] = conord.dup
						  dupParams[:parent] = @tbldata.dup
						  dupParams[:parent]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
              dupParams[:screenCode] = "r_conords"
						  last_lotstks <<  Shipment.proc_create_consume(dupParams)
					  end
        end

		  return 	last_lotstks
	  end

    def update_prdpurord(chng_flg,last_lotstks,last_rec)  ###schs,ords専用
      case chng_flg 
          ###既に引き当てられている数以下にはできない。画面でチェック済
        when  /qty/
              src = {"tblname" => @tblname,"tblid" => @tbldata["id"],"qty_src" => last_rec["qty"],
                            "trngantts_id" => @trngantts_id,
                            "remark" => "#{self} line #{__LINE__}", "persons_id_upd" => @tbldata[:persons_id_upd]}
              base = {"tblname" => @tblname,"tblid" => @tbldata["id"],"qty_src" => @tbldata["qty"],
                            "trngantts_id" => @trngantts_id,
                            "remark" => "#{self} line #{__LINE__}", "persons_id_upd" => @tbldata[:persons_id_upd]}
              last_lotstks_parts = ArelCtl.proc_linktbls_alloctbls_lotstkhists(src,base) 			  ###linktblsとlink先のalloctblの変更
              last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
              ###消費、出庫の取り消し
              last_lotstks_parts = Shipment.proc_update_consume(@tblname,@tbldata,last_rec,true)
              last_lotstks.concat last_lotstks_parts  if last_lotstks_parts.size > 0
              last_lotstks_parts,del_cnt = Shipment.proc_deleteShpxxxsByParent @tblname,@tblid,"shpschs"
              last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
              if @tbldata[@str_qty].to_f > 0  ### 消費、出庫の再登録
                ActiveRecord::Base.connection.select_all(ArelCtl.proc_ChildConSql(@tbldata)).each do |conord|
                  dupParams = @reqparams.dup
                  dupParams[:child] = conord.dup
                  dupParams[:parent] = @tbldata.dup
                  dupParams[:parent]["trngantts_id"] = @gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                  dupParams[:screenCode] = "r_conords"
                  last_lotstks <<  Shipment.proc_create_consume(dupParams)
                  ###
                  last_lotstks_parts = Shipment.proc_create_shpxxxs(dupParams) do
                    "shpsch"
                  end
                  last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
                end 
              end
        when  /due|shelfno/
          ###shp,conの変更 callされるのはschs,ordsの時のみ
          last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" => - last_rec[@str_qty],"set_f" => true,"rec" => last_rec}
          last_lotstks << {"tblname" => @tblname,"tblid" => @tblid,"qty_src" =>  @tbldata[@str_qty]}  ###詳細はproc_add_update_lotstkhistsで
      end
      return last_lotstks
    end
      
	  def update_prdpur_child(trn)
		  params = @reqparams.dup
		  params[:screenCode] = "r_" + trn["tblname"]
		  strsql = %Q&
				select * from r_#{trn["tblname"]} where id = #{trn["tblid"]}
		    &
		  rec = ActiveRecord::Base.connection.select_one(strsql)
		  child_blk = RorBlkCtl::BlkClass.new(params[:screenCode])
		  command_c = child_blk.command_init
		  command_c.merge!rec 
		  command_c["sio_classname"] = "_update_#{trn["tblname"]}_update_prdpur_child"
		  command_c["#{trn["tblname"].chop}_remark"] = " #{self} line:(#{__LINE__}) "
		  if trn["pare_qty_alloc"].to_f == 0   ###qty,qty_schの合計
			  command_c["#{trn["tblname"].chop}_qty_sch"] = 0  ###update_prdpur_childではqty_schのみ
		  else
			  qty_require = CtlFields.proc_cal_qty_sch(trn["pare_qty_alloc"].to_f ,trn["chilnum"].to_f,trn["parenum"].to_f,trn["packqty"],
                                                trn["consumunitqty"].to_f,trn["consumminqty"].to_f,trn["consumchgoverqty"].to_f)
			  if qty_require > (trn["qty"].to_f + trn["qty_stk"].to_f)
				  command_c["#{trn["tblname"].chop}_qty_sch"]  = qty_require - (trn["qty"].to_f + trn["qty_stk"].to_f)
			  else
				  command_c["#{trn["tblname"].chop}_qty_sch"]  = 0
			  end
		  end
      
		  if trn["tblname"] =~ /^pur/
			  command_c,err = CtlFields.proc_judge_check_supplierprice(command_c,"",0,"r_purschs") 
			  command_c = command_c
		  end
      #
      parent = {"starttime" => trn["starttime_pare"],"duedate" => trn["duedate_pare"],"shelfnos_id" => trn["shelfnos_id_pare"]}
			command_c = CtlFields.proc_field_duedate(trn["tblname"].chop,command_c,parent,trn)
			command_c = CtlFields.proc_field_starttime(trn["tblname"].chop,command_c,parent,trn)
      #
		  child_blk.proc_private_aud_rec(params,command_c)  ###trnganttsの更新も含む
	  end
	
	  

	  def init_trngantts_add_detail()
		###@src_no = ""
		###トップ登録時org=pare=tbl

		  @trngantts_id = @gantt["id"] = @gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
		
		  ###insts,replyinputs,dlvs,replyinputs,acts,retsはtrnganttsは作成しない。
		  last_lotstks = ArelCtl.proc_insert_trngantts(@gantt,@tbldata)  ###@ganttの内容をセット
		  @reqparams[:gantt] = @gantt.dup
		  case @tblname	
		  when /^purords|^prdords/  ### 単独でxxxordsを画面又はexcelで登録-->mkordinstsを利用してないとき
			  ###free_ordtbl_alloc_to_sch(stkinout)
			  if @mkprdpurords_id == 0 ###mkordinstsの時は子部品展開は対象外
					@reqparams[:segment]  = "mkschs"   ###構成展開
					@reqparams[:remark]  = "#{self}   構成展開"  ###構成展開
          @reqparams[:tblname] = @tblname
          @reqparams[:tblid] = @tblid
					processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
			  end
		  when /^custschs|^custords/
			  @reqparams[:segment]  = "mkprdpurchildFromCustxxxs"   ###構成展開		
			  @reqparams[:remark]  = "#{self}   pur,prd by custschs,ords"  
        @reqparams[:tblname] = @tblname
        @reqparams[:tblid] = @tblid
			  processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		  end
		  return last_lotstks
	  end

	  def child_trngantts   ###データはxxxschsのデータで追加のみ
		  @gantt["qty"] = @gantt["qty_stk"] = 0   ###schsのみテーブルしかありえないため
		  @gantt["qty_stk"] = 0
		  @gantt["consumunitqty"] = ( @gantt["consumunitqty"]  == 0 ? 1 : @gantt["consumunitqty"])
		  ###@gantt["qty_require"] create_other_table_record_job.mkschで対応済
		  ### parenum chilnum
		  @gantt["id"] = @gantt["trngantts_id"]  = @trngantts_id = ArelCtl.proc_get_nextval("trngantts_seq")
		  @gantt["remark"] =  "class:#{self},line:#{__LINE__} " + (@gantt["remark"]||="")
		  @reqparams[:gantt] = @gantt
		  last_lotstks = ArelCtl.proc_insert_trngantts(@gantt,@tbldata)  ###@ganttの内容をセット

	 	  ###proc_mk_instks_rec stkinout,"add"
		  if @gantt["qty_handover"].to_f  > 0  ### and  @gantt["itms_id_trn"] != "0"  ### dummy @gantt["tblname"] != "dymschs"
			  @reqparams[:segment]  = "mkschs"   ###構成展開
			  @reqparams[:remark]  = "#{self}  line:#{__LINE__}  構成展開 level > 1" 
        @reqparams[:tblname] = @gantt["tblname"]
        @reqparams[:tblid] = @gantt["tblid"] 
			  processreqs_id ,@reqparams = ArelCtl.proc_processreqs_add @reqparams
		  end
		  return  last_lotstks
	  end

	  def proc_add_dvs_data(apparatus)   ###前の状態のalloc解除と現在のalloc作成
		  ### prdschsは作成のみ　trnganttsと連動
		  case @tblname  ###親 prdxxxs
		  when "prdschs"
			  currdvstbl = "dvsschs"
			  strduedate = "duedate"
			  val_qty_sch = 1
			  val_qty = 0
			  val_qty_stk = 0
		  when "prdords"
			  currdvstbl = "dvsords"
			  strduedate = "duedate"
			  val_qty_sch = 0
			  val_qty = 1
			  val_qty_stk = 0
		  when "prdinsts"
			  currdvstbl = "dvsinsts"
			  strduedate = "duedate"
			  val_qty_sch = 0
			  val_qty = 1
			  val_qty_stk = 0
		  when "prdacts"
			  currdvstbl = "dvsacts"
			  strduedate = "cmpldate"
			  val_qty_sch = 0
			  val_qty = 0
			  val_qty_stk = 1
		  else
			  raise 
		  end 

		  gantt = @reqparams[:gantt].dup
		  dvs = RorBlkCtl::BlkClass.new("r_#{currdvstbl}")
		  command_dvs = dvs.command_init
      command_dvs["#{currdvstbl.chop}_prjno_id"] = @tbldata["prjnos_id"]
      command_dvs["#{currdvstbl.chop}_expiredate"] =  Constants::EndDate 
      command_dvs["sio_classname"] = "_add_dvs_data"
			command_dvs["#{currdvstbl.chop}_created_at"] = Time.now
			command_dvs["#{currdvstbl.chop}_updated_at"] = Time.now
			command_dvs["id"]  = command_dvs["#{currdvstbl.chop}_id"]  = ArelCtl.proc_get_nextval("#{currdvstbl}_seq")
      @reqparams[:mkprdpurords_id] = 0
      @reqparams[:child] = {}
      command_dvs["#{currdvstbl.chop}_#{@tblname.chop}_id_#{currdvstbl.chop}"] = @tbldata["id"] ###@tbldata=prdschs or prdords
      command_dvs["#{currdvstbl.chop}_person_id_upd"] = @reqparams[:person_id_upd] = @tbldata["persons_id_upd"]
		  prevdvs = {}
		   
			command_dvs = CtlFields.proc_field_facilities_id(currdvstbl.chop,command_dvs,@tbldata,apparatus)
      case currdvstbl 
        when "dvsacts","dvsinsts"
              strsql = %Q&
                          select link.* from linktbls link 
                                inner join alloctbls alloc on alloc.srctblname = 'prdacts' and alloc.srctblid = #{@tbldata["id"]}
                                        and link.trngantts_id = alloc.trngantts_id
                                where link.tblname = '#{@tblname}' and link.tblid = #{@tbldata["id"]}
              &
              prev_prd = ActiveRecord::Base.connection.select_one(strsql)
              strsql = %Q&
                          select * from #{prev_prd["srctblname"].sub("prd","dvs")} dvs
                                where  #{prev_prd["srctblname"]}_id_#{prev_prd["srctblname"].sub("prd","dvs").chop} = #{prev_prd["srctblid"]}
              &
              prev_dvs = ActiveRecord::Base.connection.select_one(strsql)
              if prev_dvs
            			###    acttbldata["starttime"] = prev_dvs["starttime"]
                	command_dvs["#{currdvstbl.chop}_commencementdate"] = prev_dvs["commencementdate"]
            			###    command_dvs = CtlFields.proc_field_duedate(currdvstbl.chop,command_dvs,acttbldata,apparatus)
            			###    command_dvs = CtlFields.proc_field_starttime(currdvstbl.chop,command_dvs,acttbldata,apparatus)
							else
									command_dvs["#{currdvstbl.chop}_commencementdate"] = @tbldata["starttime"]
              end
              if currdvstbl == "dvsacts"
                  command_dvs["#{currdvstbl.chop}_cmpldate"] = @tbldata["cmpldate"]
              else
                  command_dvs["#{currdvstbl.chop}_duedate"] = @tbldata["duedate"]
              end
        when "dvsschs"
              command_dvs = CtlFields.proc_field_duedate(currdvstbl.chop,command_dvs,@tbldata,apparatus)
            ###  command_dvs,err = CtlFields.proc_field_starttime(currdvstbl.chop,command_dvs,@tbldata,apparatus)
        else
              command_dvs = CtlFields.proc_field_duedate(currdvstbl.chop,command_dvs,@tbldata,apparatus)
							command_dvs_tmp = command_dvs.dup
              command_dvs_tmp = CtlFields.proc_field_starttime(currdvstbl.chop,command_dvs_tmp,@tbldata,apparatus)
              command_dvs["dvsord_commencementdate"] = command_dvs_tmp["dvsord_starttime"]
      end
      command_dvs["#{currdvstbl.chop}_sno"] = CtlFields.proc_field_sno(currdvstbl.chop,Time.now,command_dvs["id"])
      command_dvs = dvs.proc_create_tbldata(command_dvs)
      dvs.proc_private_aud_rec(@reqparams,command_dvs) ###create pur,prdschs
      ###paretblname:prdxxxxs,tblname:erc,dvsxxxs paretblid paretblname.id,tblid tblname.id
      # src = {"paretblname" => @tblname,"paretblid" => @tbldata["id"],"tblname" => currdvstbl,"tblid" => command_dvs["id"]}
      # add_dvserc_link(src)
	  end 
    ###
    ##  ercxxxs
    ###
	  def proc_add_erc_data(apparatus)   ###前の状態のalloc解除と現在のalloc作成
		  ### prdschsは作成のみ　trnganttsと連動
		  case @tblname  ###親 prdxxxs
		  when "prdschs"
			  currerctbl = "ercschs"
			  preverctbl = "ercschs"
			  strduedate = "duedate"
			  val_qty_sch = 1
			  val_qty = 0
			  val_qty_stk = 0
		  when "prdords"
        currerctbl = "ercords"
			  preverctbl = "ercschs"
			  strduedate = "duedate"
			  val_qty_sch = 0
			  val_qty = 1
			  val_qty_stk = 0
		  when "prdinsts"
			  currerctbl = "ercinsts"
			  preverctbl = "ercords"
			  strduedate = "duedate"
			  val_qty_sch = 0
			  val_qty = 1
			  val_qty_stk = 0
		  when "prdacts"
			  currerctbl = "ercacts"
			  preverctbl = "ercords"
			  strduedate = "cmpldate"
			  val_qty_sch = 0
			  val_qty = 0
			  val_qty_stk = 1
		  else
			  return 
		  end 

		  gantt = @reqparams[:gantt].dup
      erc = RorBlkCtl::BlkClass.new("r_#{currerctbl}")
      command_erc = erc.command_init
      command_erc["#{currerctbl.chop}_prjno_id"] = @tbldata["prjnos_id"]
      command_erc["#{currerctbl.chop}_expiredate"] =  Constants::EndDate 
      command_erc["sio_classname"] = "_add_erc_data"
			command_erc["id"]  = command_erc["#{currerctbl.chop}_id"]  = ArelCtl.proc_get_nextval("#{currerctbl}_seq")
      @reqparams[:mkprdpurords_id] = 0
      @reqparams[:child] = {}
      command_erc["#{currerctbl.chop}_person_id_upd"] = @reqparams[:person_id_upd] = @tbldata["persons_id_upd"]
		  prev_erc = {}
		   
	    command_erc["sio_classname"] = "_add_erc_link"
			command_erc["#{currerctbl.chop}_created_at"] = Time.now
			command_erc["#{currerctbl.chop}_updated_at"] = Time.now
      command_erc["#{currerctbl.chop}_#{@tblname.chop}_id_#{currerctbl.chop}"] = @tbldata["id"]
      cnt = 0
      gantt_key = gantt["key"]
      ["changeover","require","postprocess"].each do |processname|   ###前処理、処理、後処理
          next if processname == "changeover" and (apparatus["changeoverlt"].to_f == 0 or apparatus["changeoverop"].to_f == 0)
          next if processname == "require" and apparatus["requireop"].to_f == 0
          next if processname == "postprocess" and (apparatus["postprocessingop"].to_f == 0 or apparatus["postprocessinglt"].to_f == 0)
          command_erc["id"] = ArelCtl.proc_get_nextval("#{currerctbl}_seq")
          command_erc["#{currerctbl.chop}_sno"] = CtlFields.proc_field_sno(currerctbl.chop,Time.now,command_erc["id"])
          command_erc["#{currerctbl.chop}_processname"] = processname
          case currerctbl
            when "ercacts","ercinsts"  
              strsql = %Q&
                  select link.* from linktbls link 
                    inner join alloctbls alloc on alloc.srctblid = #{@tbldata["id"]} and link.trngantts_id = alloc.trngantts_id
                    where link.tblname = '#{@tblname}' and link.tblid = #{@tbldata["id"]}
                    and (alloc.srctblname = 'prdacts' or alloc.srctblname = 'prdinsts')
                    &
               prev_prd = ActiveRecord::Base.connection.select_one(strsql)
		          strsql = %Q&  ---前の状態を引き継ぐ
							    select erc.* from #{preverctbl} erc
                      inner join fcoperators f on f.id = erc.fcoperators_id 
                      where  #{prev_prd["srctblname"]}_id_#{preverctbl.chop} = #{prev_prd["srctblid"]}
                      and f.itms_id_fcoperator = #{apparatus["itms_id"]}
                      and erc.processname = '#{processname}'
					  	    &
              prev_erc = ActiveRecord::Base.connection.select_one(strsql)
              if prev_erc
                command_erc["#{currerctbl.chop}_duedate"] = prev_erc["duedate"]
                ###command_erc["#{currerctbl.chop}_starttime"] = prev_erc["starttime"]
                command_erc["#{currerctbl.chop}_commencementdate"] = prev_erc["commencementdate"]
                command_erc["#{currerctbl.chop}_fcoperator_id"] = prev_erc["fcoperators_id"]
              else
                return
              end
							if currerctbl == "ercacts"
              		command_erc["#{currerctbl.chop}_cmpldate"] = @tbldata["cmpldate"]
							else
								  command_erc["#{currerctbl.chop}_duedate"] = @tbldata["duedate"]
							end
            when "ercschs","ercords"
              strsql = %Q&  --- from master when ercords
                select f.id from  fcoperators f 
                    where f.itms_id_fcoperator = #{apparatus["itms_id"]}
                    order by f.priority desc
                &
              fcop = ActiveRecord::Base.connection.select_one(strsql)
              command_erc = CtlFields.proc_field_fcoperators_id(currerctbl.chop,command_erc,nil,apparatus)
              command_erc["#{currerctbl.chop}_fcoperator_id"] = fcop["id"]
              command_erc["#{currerctbl.chop}_duedate"] = @tbldata["duedate"]
              command_erc["#{currerctbl.chop}_commencementdate"] = @tbldata["starttime"]
            ###  command_erc,err = CtlFields.proc_field_starttime(currerctbl.chop,command_erc,@tbldata,apparatus)
              command_erc = CtlFields.proc_field_duedate(currerctbl.chop,command_erc,@tbldata,apparatus)
            else
          end
		      command_erc = erc.proc_create_tbldata(command_erc)
          gantt["key"] = gantt_key +  format('%04d', cnt) 
          @reqparams[:gantt] = gantt.dup
		      erc.proc_private_aud_rec(@reqparams,command_erc) ###create pur,prdschs
          cnt += 1
          # ###paretblname:prdxxxxs,tblname:erc,dvsxxxs paretblid paretblname.id,tblid tblname.id
          # src = {"paretblname" => @tblname,"paretblid" => @tbldata["id"],"tblname" => currerctbl,"tblid" => command_erc["id"]}
          # add_dvserc_link(src)
      end
	  end 

	  def proc_delete_dvs_data
		
		  ### prdschsは作成のみ　trnganttsと連動
		  case @tblname  ###親 prdxxxs
		  when "prdschs"
			  currdvstbl = "dvsschs"
			  strduedate = "duedate"
		  when "prdords"
			  currdvstbl = "dvsords"
			  strduedate = "duedate"
		  when "prdinsts"
			  currdvstbl = "dvsinsts"
			  strduedate = "duedate"
		  when "prdacts"
			  currdvstbl = "dvsacts"
			  strduedate = "cmpldate"
		  else
			  return 
		  end 

		  dvs = RorBlkCtl::BlkClass.new("r_#{currdvstbl}")
		  command_dvs = dvs.command_init
      command_dvs["#{currdvstbl.chop}_prjno_id"] =  @tbldata["prjnos_id"]
      command_dvs["#{currdvstbl.chop}_person_id_upd"] = @reqparams[:person_id_upd]
      command_dvs["sio_classname"] = "_delete_dvs_link"
		
			strsql = %Q&
						select * from #{currdvstbl} dvs
                where #{@tblname}_id_#{currdvstbl.chop} = #{@tbldata["id"]}
				  &
		  ActiveRecord::Base.connection.select_all(strsql).each do |currdvs|
          command_dvs["#{currdvstbl.chop}_facilitie_id"] = currdvs["facilities_id"]
          command_dvs["id"] = command_dvs["#{currdvstbl.chop}_id"] = currdvs["id"]
		      command_dvs = dvs.proc_create_tbldata(command_dvs)
		      dvs.proc_private_aud_rec(@reqparams,command_dvs) ###create pur,prdschs
          src = {"tblname" => currdvstbl,"tblid" => currdvs["id"]} 
          delete_dvserc_link(src)
      end
    end
    ###
    #  erc
    ###
	  def proc_delete_erc_data
		
		  ### prdschsは作成のみ　trnganttsと連動
		  case @tblname  ###親 prdxxxs
		  when "prdschs"
			  preverctbl = "ercschs"
			  currerctbl = "ercschs"
			  strduedate = "duedate"
		  when "prdords"
			  preverctbl = "ercschs"
			  currerctbl = "ercords"
			  strduedate = "duedate"
		  when "prdinsts"
			  preverctbl = "ercords"
			  currerctbl = "ercinsts"
			  strduedate = "duedate"
		  when "prdacts"
			  currerctbl = "ercacts"
			  strduedate = "cmpldate"
		  else
			  return 
		  end 

		  erc = RorBlkCtl::BlkClass.new("r_#{currerctbl}")
		  command_erc = erc.command_init
      command_erc["#{currerctbl.chop}_prjno_id"] =  @tbldata["prjnos_id"]
      command_erc["#{currerctbl.chop}_person_id_upd"] = @reqparams[:person_id_upd]
      command_erc["sio_classname"] = "_delete_erc_link"		
			strsql = %Q&
						select * from #{currerctbl} dvs
                where #{@tblname}_id_#{currerctbl.chop} = #{@tbldata["id"]}
				  &
		  ActiveRecord::Base.connection.select_all(strsql).each do |currdvs|
        ["changeover","require","ostprocess"].each do |processname|
		      strsql = %Q&
							select erc.* from #{currerctbl} erc
                    where #{@tblname}_id_#{currerctbl.chop} = #{@tbldata["id"]}
                    and erc.processname = '#{processname}'
					  	&
		      ActiveRecord::Base.connection.select_all(strsql).each do |currerc|
            command_erc["#{currerctbl.chop}_fcoperator_id"] = currerc["fcoperators_id"]
            command_erc["id"] = command_erc["#{currerctbl.chop}_id"] = currerc["id"]
		        command_erc = erc.proc_create_tbldata(command_erc)
		        erc.proc_private_aud_rec(@reqparams,command_erc) ###create pur,prdschs
            src = {"tblname" => currerctbl,"tblid" => currerc["id"]} 
            delete_dvserc_link(src)
          end
        end
      end
	  end 
    def delete_dvserc_link src  ###tblname--> dvsxxxs OR ercxxxS ,tblid--> dvsxxxs_id OR ercxxxs_id
       strsql = %Q&
                   select * from linktbls where tblname = '#{src["tblname"]}' and tblid = #{src["tblid"]}
       &
       ActiveRecord::Base.connection.select_all(strsql).each do |link|
         ActiveRecord::Base.connection.delete(%Q&delete from linktbls where id = #{link["id"]}&)
         strsql = %Q&
                 select * from alloctbls where srctblname = '#{src["tblname"]}' and srctblid = #{src["tblid"]}
                                         and trngantts_id = #{link["trngantts_id"]}
         &
         ActiveRecord::Base.connection.select_all(strsql).each do |alloc|
           ActiveRecord::Base.connection.delete(%Q&delete from alloctbls where id = #{alloc["id"]}&)
           ### dvsschs,ercschsのtrnganttsは残す
         end
         ActiveRecord::Base.connection.delete(%Q&delete from trngantts where id = #{link["trngantts_id"]}&)
       end
     end
  end   #class	
end   #module