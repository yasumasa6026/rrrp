# -*- coding: utf-8 -*-
# mkordlib
# 2099/12/31を修正する時は　2100/01/01の修正も
module MkordinstLib
	extend self
	###mkordparams-->schsからordsを作成した結果
	
	def proc_mkprdpurordv1 params,mkordparams  ###xxxschsからxxxordsを作成する。 trngantts:xxxschs= 1:1
		### mkprdpurordsではxno_xxxschはセットしない。schsをまとめたり分割したりする機能のため
    @mkordparams = mkordparams.dup
    @mkordparams[:message_code] = ""
		tbldata = params[:tbldata].dup  ###tbldata -->テーブル項目　　viewではない。
		mkprdpurords_id = params[:mkprdpurords_id]   
		add_tbl = "" 
		@add_tbl_org = ""   ###topから必要数を計算するときの必要数抽出用
		@add_tbl_pare = ""    ###topから必要数を計算するときの必要数抽出用
		@add_tbl_trn = ""
		@strwhere = {"org"=>"","pare"=>"","trn"=>""} 
    @last_lotstks = []
		tblxxx = ""
		@incnt = @inqty = @inamt = @outcnt = @outqty = @outamt = 0		 
		# command_c = nil
		["org","pare","trn"].each do |sel|  ###抽出条件のsql作成
			case sel
				when "org"
					next if tbldata["orgtblname"] == "" or tbldata["orgtblname"].nil? or tbldata["orgtblname"] == "dummy"
					@add_tbl_org = %Q%	inner join  #{tbldata["orgtblname"]} org  on  gantt.orgtblid = org.id 	
										          inner join  itms itm_org  on  gantt.itms_id_org = itm_org.id 
										          inner join  shelfnos  shelfno_org  on  gantt.shelfnos_id_org = shelfno_org.id 	 
										          inner join  (select loca.*,s.id shelfno_id from locas loca
															            		inner join shelfnos s on s.locas_id_shelfno = loca.id )  loca_org
                                        on  gantt.shelfnos_id_pare = loca_org.shelfno_id
										          inner join  r_chrgs person_org  on  gantt.chrgs_id_org = person_org.id 	%   
					add_tbl << @add_tbl_org
					@strwhere[sel] << "and orgtblname = '#{tbldata["orgtblname"]}'     "
				when "pare"
				 	next if tbldata["paretblname"] == "" or tbldata["paretblname"].nil? or tbldata["paretblname"] == "dummy"
					tblxxx = tbldata["paretblname"]
				 	case tbldata["paretblname"]  
				 	  when /schs$/		
						  @add_tbl_pare = %Q%	inner join  #{tblxxx} pare  on  gantt.paretblid = pare.id 	
										              inner join  itms itm_pare  on  gantt.itms_id_pare = itm_pare.id 
										              inner join  shelfnos shelfno_pare  on  gantt.shelfnos_id_pare = shelfno_pare.id 
										              inner join  (select loca.*,s.id shelfno_id from locas loca
																	              inner join shelfnos s on s.locas_id_shelfno = loca.id )
												                                    loca_pare  on  gantt.shelfnos_id_pare = loca_pare.shelfno_id 	
										              inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	%   
						  add_tbl << @add_tbl_pare
					  when /ords$/
						  @add_tbl_pare = %Q$ inner join (select link.srctblid,link.trngantts_id from linktbls link
															                                      inner join #{tblxxx} p   	
																                                        on p.id = link.tblid and link.tblname = '#{tblxxx}' 
                                                                            and  link.srctblname like '%schs') sch
												                 on gantt.paretblid = sch.srctblid and gantt.id = sch.trngantts_id
											            inner join  r_chrgs person_pare  on  gantt.chrgs_id_pare = person_pare.id 	
											            inner join  itms itm_pare  on  gantt.itms_id_pare = itm_pare.id 
											            inner join  shelfnos shelfno_pare  on gantt.shelfnos_id_pare = shelfno_pare.id 
											            inner join  (select loca.*,s.id shelfno_id from locas loca
																		              inner join shelfnos s on s.locas_id_shelfno = loca.id )
													                                  loca_pare  on  gantt.shelfnos_id_pare = loca_pare.shelfno_id $   
						  add_tbl << @add_tbl_pare
				###	else
				###		next
					end	
					@strwhere[sel] << "and paretblname = '#{tblxxx}'    "

				when "trn"   ###必須項目	
					@add_tbl_trn = %Q%	inner join  itms itm_trn  on  gantt.itms_id_trn = itm_trn.id 
									inner join  shelfnos shelfno_trn  on  gantt.shelfnos_id_trn = shelfno_trn.id 	
									inner join  r_chrgs person_trn  on  gantt.chrgs_id_trn = person_trn.id 	
									inner join  (select loca.*,s.id shelfno_id from locas loca
																inner join shelfnos s on s.locas_id_shelfno = loca.id )
											loca_trn  on  gantt.shelfnos_id_trn = loca_trn.shelfno_id %   
					case tbldata["tblname"] 
					when 	"all"	  ###pur,prd両方抽出
						@strwhere[sel] << " and gantt.tblname in ('purschs','prdschs')      "
						@add_tbl_trn << " left join  prdschs prd  on  gantt.tblid = prd.id "
						@add_tbl_trn << " left join purschs pur  on  gantt.tblid = pur.id "
					when "prdords"		
						@strwhere[sel] << "and  gantt.tblname = 'prdschs'      "
						@add_tbl_trn << " inner join  prdschs prd  on  gantt.tblid = prd.id "
					when "purords"
						@strwhere[sel] << "and  gantt.tblname = 'purschs'      "
						@add_tbl_trn << " inner join  purschs pur  on  gantt.tblid = pur.id "
					end
					add_tbl << @add_tbl_trn
				else
					next	
			end

			tbldata.each do |field_delm,val|  ###field-->r_purxxxs,r_prdxxxsのfield  delm-->org,pare,trn
				next if field_delm =~ /_id/ ###画面から入力された項目のみが対象
				next if val == "" or val.nil? or val == "dummy"
				if field_delm.to_s =~ /_#{sel}/  ###sel:[org,pare,trn]のどれか
					field = field_delm.sub(/_#{sel}/,"")
					tag = field_delm.split("_")[0] + "_" + sel  ###field.split("_")[0]  --> [itm,loca,person,sno]のどれか
					case  field
					when /itm_code|loca_code/  ###itms
						@strwhere[sel] << %Q% and #{tag}.code  = '#{val}' 
							%
					when /person_code_chrg/  ###r_chrgs
						@strwhere[sel] << %Q% and #{tag}.person_code_chrg  = '#{val}'  
							%
					when /processseq/  ###
						if val > "0"
						    @strwhere[sel] << %Q% and gantt.processseq_#{sel} = '#{val}'   
								%
						end		
					when /duedate/						
						@strwhere[sel] << %Q% and gantt.#{field}_#{sel} <= cast('#{val}' as date)  
								%
					when /starttime/						
						@strwhere[sel] << %Q% and gantt.#{field}_#{sel} >= cast('#{val}' as date)   
								%
					when /sno/			###snoが	
						case sel
						when /org|pare/	
							@strwhere[sel] << %Q% and #{sel}.sno = '#{val}'   %
						when /trn/
							case params[:tblname] 
							when 	"all"	  ###pur,prd両方抽出
								@strwhere[sel] << %Q% and (prd.sno = '#{val}'  or pur.sno = '#{val}' ) %
							when "prdords"		
								@strwhere[sel] << %Q% and prd.sno = '#{val}'   %
							when "purords"
								@strwhere[sel] << %Q% and pur.sno = '#{val}'   %
							end
						end
					else
						### itms.name not support
						### p"MkordinstLib line #{__LINE__} field:#{field_delm} not support"
					end
				end	  ### case
			end  ###fields.each
		end   ### ["_org","_pare","_trn"].each do |tbl|

		###ordsは prjnos_id,itms_id,processseq,locas_id(作業場所、発注先),shelfnos_id_to(完成後、受入後)の保管場所毎に作成
		###対象データの特定 trnganttsにmkprdpurords_idをセット
		ActiveRecord::Base.connection.execute("lock table trngantts in  SHARE ROW EXCLUSIVE mode")
		set_mkprdpurords_id_in_trngantts(add_tbl,mkprdpurords_id)
		shsAllocToStk(mkprdpurords_id).each do |sumSchs|   ### free_qty alloc to qty_sch
        sch_trn_alloc_to_freetrnv1(sumSchs)  
    end
		###員数に従って必要数を計算
    ### max_mlevel 階層の最大値
    ### "itms_id_trn" + "processseq_trn" +"shelfnos_id_trn" + "prjnos_id":製造、発注単位
    ### parenum,chilnum:親員数、子員数
    ### packqty : 発注単位、製造梱包単位
    strsql = "select max(mlevel) from trngantts where mkprdpurords_id_trngantt = #{mkprdpurords_id}"
    max_mlevel = ActiveRecord::Base.connection.select_value(strsql)
		### topの親を設定 
		init_sum_ord_insert(mkprdpurords_id)  ###  mkordtmpfs:親子関係あるtable
    sel_recs = []
    history = 0
    seltbl = "trngantts"
    @re_cal_flg = true   ### over maxqtyのため分割された？
    while @re_cal_flg == true do
        mlevel = 0
        until mlevel > max_mlevel.to_i do   ###group byはmaxqty対応のため使用しない。
            strsql = "select #{mkprdpurords_id} mkprdpurords_id,#{mlevel} mlevel,#{history}  history,
                        prjnos_id,
                        itms_id_trn,processseq_trn ,shelfnos_id_trn,shelfnos_id_to_trn
                      from mkordtmpfs 
                        where mkprdpurords_id = #{mkprdpurords_id} and mlevel = #{mlevel} and history = #{history} 
                        group by  prjnos_id,itms_id_trn,processseq_trn,shelfnos_id_trn,shelfnos_id_to_trn
                        order by  prjnos_id,itms_id_trn,processseq_trn,shelfnos_id_trn,shelfnos_id_to_trn
						  		"
            sel_recs = ActiveRecord::Base.connection.select_all(strsql)
            @re_cal_flg = false
            sel_recs.each do |sel_rec|
                cal_recs = ActiveRecord::Base.connection.select_all(cal_rec_sql(mkprdpurords_id,sel_rec,seltbl,history)) 
                qtySumMaxqtySplit(cal_recs,history) do  ###history = 0
                    seltbl
                end
            end
            mlevel += 1
            ######   return @mkordparams,[] if mlevel > 2
        end
        if history == 0  
          if seltbl == "trngantts"
            strsql = %Q&   ---itms_id等のmlevelを同一にする
              update  mkordtmpfs  set mlevel = tg.mlevel 
			                from (select max(mlevel) mlevel,prjnos_id,itms_id_trn,processseq_trn,shelfnos_id_trn,shelfnos_id_to_trn
                              from  mkordtmpfs 
											        where mkprdpurords_id = #{mkprdpurords_id} and history = 0
                              group by   prjnos_id,itms_id_trn,processseq_trn,shelfnos_id_trn,shelfnos_id_to_trn) tg
			        where 	mkordtmpfs.prjnos_id = tg.prjnos_id and mkordtmpfs.itms_id_trn = tg.itms_id_trn and mkordtmpfs.processseq_trn =  tg.processseq_trn   
				          and	mkordtmpfs.shelfnos_id_trn  =  tg.shelfnos_id_trn and	mkordtmpfs.shelfnos_id_to_trn  =  tg.shelfnos_id_to_trn 
                  and  mkordtmpfs.mkprdpurords_id = #{mkprdpurords_id} and mkordtmpfs.history = 0
               &
            ActiveRecord::Base.connection.update(strsql)
            seltbl =  "mkordtmpfs" 
            @re_cal_flg = true
          else
            history += 1
          end
        else  
            history += 1
        end
        raise " calss:#{self},line:#{__LINE__},loop cnt error history:#{history}" if history > Constants::MaxSplitCnt
    end
    strsql = %Q&
                select mk.*,i.taxflg from mkordtmpfs mk 
                        inner join trngantts t on t.tblname = mk.tblname and  t.tblid = mk.tblid and mk.mkprdpurords_id = t.mkprdpurords_id_trngantt
                        inner join itms i on i.id = mk.itms_id_trn      
                        where mk.mkprdpurords_id = #{mkprdpurords_id} and mk.history = #{history}
                        and t.gather_flg =  #{mkprdpurords_id}
    &
    ActiveRecord::Base.connection.select_all(strsql).each do |choice_rec|
           insertOrdPrdPur(params,choice_rec)        
    end
    
		@mkordparams[:incnt] = @incnt
		@mkordparams[:inqty] = @inqty
		@mkordparams[:inamt] = 0   ###未設定
		@mkordparams[:outcnt] = @outcnt
		@mkordparams[:outqty] = @outqty
		@mkordparams[:outamy] = @outamt
		return @mkordparams,@last_lotstks
  end

  def getStarttimeDuedate(prev_cal_rec)
      starttime = prev_cal_rec["starttime_trn"]
      duedate = prev_cal_rec["duedate_trn"]
      message = ""
      case prev_cal_rec["tblname"]
        when /^prd/   
          strsql = %Q&
                  select ope.duration,ope.unitofduration,s.locas_id_shelfno locas_id_to from opeitms ope
                        inner join shelfnos s on s.id = ope.shelfnos_id_to_opeitm
                        where ope.itms_id = #{prev_cal_rec["itms_id_trn"]} and ope.processseq = #{prev_cal_rec["processseq_trn"]}
                              and ope.shelfnos_id_opeitm = #{prev_cal_rec["shelfnos_id_trn"]} and ope.shelfnos_id_to_opeitm = #{prev_cal_rec["shelfnos_id_to_trn"]}
          &
          opeitm = ActiveRecord::Base.connection.select_one(strsql)
          if opeitm.nil?
              opeitm = {"duration" => 1 ,"unitofduration" => "Day","locas_id_to" => 0}
          end
          case opeitm["unitofduration"]
            when "Day "
                duedate,message = CtlFields.proc_calculate_working_day(prev_cal_rec["tblname"].chop,prev_cal_rec["starttime_trn"],1,"-",opeitm["locas_id_to"])
                starttime,message = CtlFields.proc_calculate_working_day(prev_cal_rec["tblname"].chop,duedate,opeitm["duration"],"-",opeitm["locas_id_to"])
            else   
                duedate,message = CtlFields.proc_calculate_working_time(prev_cal_rec["tblname"].chop,prev_cal_rec["starttime_trn"],3600,"-",opeitm["locas_id_to"])
                starttime,message = CtlFields.proc_calculate_working_time(prev_cal_rec["tblname"].chop,duedate,opeitm["duration"],"-",opeitm["locas_id_to"])         
          end
        when /^pur/  
          strsql = %Q&
                  select ope.duration,ope.unitofduration,s.suppliers_id from opeitms ope
                        inner join (select s2.id suppliers_id,s1.id shelfnos_id  from shelfnos s1
                                              inner join suppliers s2 on s2.locas_id_supplier = s1.locas_id_shelfno 
                                    ) s on s.shelfnos_id = ope.shelfnos_id_opeitm
                        where ope.itms_id = #{prev_cal_rec["itms_id_trn"]} and ope.processseq = #{prev_cal_rec["processseq_trn"]}
                              and ope.shelfnos_id_opeitm = #{prev_cal_rec["shelfnos_id_trn"]} and ope.shelfnos_id_to_opeitm = #{prev_cal_rec["shelfnos_id_to_trn"]}
          &
          opeitm = ActiveRecord::Base.connection.select_one(strsql)
          if opeitm.nil?
              opeitm = {"duration" => 1 ,"unitofduration" => "Day","suppliers_id" => 0}
          end    
          case opeitm["unitofduration"]
            when "Day "
                duedate,message = CtlFields.proc_calculate_working_day(prev_cal_rec["tblname"].chop,prev_cal_rec["starttime_trn"],1,"-",opeitm["suppliers_id"])
                starttime,message = CtlFields.proc_calculate_working_day(prev_cal_rec["tblname"].chop,duedate,opeitm["duration"],"-",opeitm["suppliers_id"])
            else   
                duedate,message = CtlFields.proc_calculate_working_time(prev_cal_rec["tblname"].chop,prev_cal_rec["starttime_trn"],3600,"-",opeitm["suppliers_id"])
                starttime,message = CtlFields.proc_calculate_working_time(prev_cal_rec["tblname"].chop,duedate,opeitm["duration"],"-",opeitm["suppliers_id"])         
          end
        else
          return prev_cal_rec            
      end
      if message == ""
          prev_cal_rec["starttime_trn"] = starttime
          prev_cal_rec["duedate_trn"] = duedate    
      else
        @mkordparams[:message]  = message 
      end
      return prev_cal_rec
  end

  def qtySumMaxqtySplit(cal_recs,history)  ###子部品の移動先ごとの処理　親部品による所要量は計算済
      @re_cal_flg = false
      sum_cal_rec = {"itms_id_trn" => -1}
      sum_cal_rec["processseq_trn"] = sum_cal_rec["shelfnos_id_trn"]  = sum_cal_rec["shelfnos_id_to_trn"] = -1
      sum_cal_rec["qty"] = sum_cal_rec["qty_stk"] = sum_cal_rec["qty_handover"] =  sum_cal_rec["qty_require"] = tmp_qty_handover = 0
      ###   base_starttime , base_duedate  :maxqtyで分割した時の納期。ｌｔで分割分のの納期を決める
      ### base_optfixodateまとめれる納期範囲　maxqtyでの分割納期のほうが優先される
      base_starttime = base_duedate =  base_optfixodate = Constants::EndDate.to_date
      cal_recs.each do |cal_rec|  
        tmp_qty_handover = 0
        if history == 0 and cal_rec["qty_sch"] > 0
            @incnt += cal_rec["incnt"]
            @inqty += cal_rec["qty_sch"]
        end         ### 一つ一つのpurschs.qty_sch,prdschs.qty_schがmaxqty以下か？
        if  sum_cal_rec["prjnos_id"] == cal_rec["prjnos_id"] and
            sum_cal_rec["itms_id_trn"] == cal_rec["itms_id_trn"] and
            sum_cal_rec["processseq_trn"] == cal_rec["processseq_trn"] and 
            sum_cal_rec["shelfnos_id_trn"] == cal_rec["shelfnos_id_trn"]  and
            sum_cal_rec["shelfnos_id_to_trn"] == cal_rec["shelfnos_id_to_trn"]
            if sum_cal_rec["optfixodate"] >= cal_rec["duedate_trn"]   ###まとめ範囲外
                  sum_cal_rec["qty_handover"] = (sum_cal_rec["qty_handover"] / sum_cal_rec["consumunitqty"]).ceil * sum_cal_rec["consumunitqty"]
                  sum_cal_rec["qty_handover"] += sum_cal_rec["consumchgoverqty"]            
                  sum_cal_rec["qty_handover"] = (sum_cal_rec["qty_handover"] / sum_cal_rec["packqty"]).ceil * sum_cal_rec["packqty"]
                  if  sum_cal_rec["qty_handover"]  < sum_cal_rec["consumminqty"]
                      sum_cal_rec["qty_handover"]  = sum_cal_rec["consumminqty"]                      
                  end
                  insert_mkordtmpfs_sqlv1(sum_cal_rec,history) do
                      yield
                  end
                  sum_cal_rec = cal_rec.dup
            else
              tmp_qty_handover = ((sum_cal_rec["qty_handover"] + cal_rec["qty_handover"]) / cal_rec["consumunitqty"]).ceil * cal_rec["consumunitqty"]
              tmp_qty_handover = ((tmp_qty_handover + cal_rec["consumchgoverqty"]) / cal_rec["packqty"]).ceil * cal_rec["packqty"]
              if tmp_qty_handover > cal_rec["maxqty"] and cal_rec["tblname"] =~ /prdschs|purschs/  ###今回のデータを足すとoverしてしまう
                  tmp_qty_handover = ((cal_rec["qty_handover"]) / cal_rec["consumunitqty"]).ceil * cal_rec["consumunitqty"]
                  tmp_qty_handover = ((tmp_qty_handover + cal_rec["consumchgoverqty"]) / cal_rec["packqty"]).ceil * cal_rec["packqty"]
                  if tmp_qty_handover > cal_rec["maxqty"] and cal_rec["tblname"] =~ /prdschs|purschs/  ### cal_rec.qty_handover > maxqty
                      ### 残っているレコードのinsert                  
                      sum_cal_rec["qty_handover"] = (sum_cal_rec["qty_handover"] / sum_cal_rec["consumunitqty"]).ceil * sum_cal_rec["consumunitqty"]
                      sum_cal_rec["qty_handover"] += sum_cal_rec["consumchgoverqty"]            
                      sum_cal_rec["qty_handover"] = (sum_cal_rec["qty_handover"] / sum_cal_rec["packqty"]).ceil * sum_cal_rec["packqty"]
                      if  sum_cal_rec["qty_handover"]  < sum_cal_rec["consumminqty"]
                          sum_cal_rec["qty_handover"]  = sum_cal_rec["consumminqty"]                      
                      end
                      insert_mkordtmpfs_sqlv1(sum_cal_rec,history) do
                          yield
                      end
                      getStarttimeDuedate(sum_cal_rec)  ### システム上可能な納期　LT
                      base_starttime = sum_cal_rec["starttime_trn"]
                      base_duedate = sum_cal_rec["duedate_trn"]     
                      ####
                      ### qty_handover の分解
                      cal_rec["optfixodate"] =  sum_cal_rec["optfixodate"]
                      @re_cal_flg = true
                      maxcnt = 0
                      until tmp_qty_handover < cal_rec["maxqty"]
                          cal_rec["qty_handover"] = cal_rec["maxqty"]   
                          cal_rec["starttime_trn"] = base_starttime
                          cal_rec["duedate_trn"] = base_duedate
                          insert_mkordtmpfs_sqlv1(cal_rec,history) do
                                yield
                          end   ###新しいorderのもと作成              
                          tmp_qty_handover -= cal_rec["maxqty"]    
                          getStarttimeDuedate(cal_rec)
                          base_starttime = cal_rec["starttime_trn"]
                          base_duedate = cal_rec["duedate_trn"]      
                          raise " maxcnt(#{maxcnt}) over MaxSplitCnt,\n cal_rec:#{cal_rec}"    if maxcnt > Constants::MaxSplitCnt
                          maxcnt += 1                  
                      end
                      if tmp_qty_handover <= 0  
                        sum_cal_rec = {"itms_id_trn" => -1}
                        sum_cal_rec["processseq_trn"] = sum_cal_rec["shelfnos_id_trn"]  = sum_cal_rec["shelfnos_id_to_trn"] = -1
                        sum_cal_rec["qty"] = sum_cal_rec["qty_stk"] = sum_cal_rec["qty_handover"] =  sum_cal_rec["qty_require"] = tmp_qty_handover = 0
                      else
                        cal_rec["optfixodate"] =  sum_cal_rec["optfixodate"]
                        sum_cal_rec = cal_rec.dup
                      end
                  else
                      sum_cal_rec["qty_sch"] += cal_rec["qty_sch"] 
                      sum_cal_rec["qty"] += cal_rec["qty"]
                      sum_cal_rec["qty_stk"] += cal_rec["qty_stk"]
                      sum_cal_rec["qty_handover"] += cal_rec["qty_handover"]
                      sum_cal_rec["duedate_trn"] = cal_rec["duedate_trn"]
                      if sum_cal_rec["itms_id_pare"] != cal_rec["itms_id_pare"] or sum_cal_rec["processseq_pare"] != cal_rec["processseq_pare"] 
                        sum_cal_rec["qty_handover"] += cal_rec["consumchgoverqty"]
                      end
                      @re_cal_flg = true
                  end
              else   ###今回のrecordを足してもmaxqty以下
                sum_cal_rec["qty_sch"] += cal_rec["qty_sch"] 
                sum_cal_rec["qty"] += cal_rec["qty"]
                sum_cal_rec["qty_stk"] += cal_rec["qty_stk"]
                sum_cal_rec["qty_handover"] += cal_rec["qty_handover"]
                sum_cal_rec["duedate_trn"] = cal_rec["duedate_trn"]
                if sum_cal_rec["itms_id_pare"] != cal_rec["itms_id_pare"] or sum_cal_rec["processseq_pare"] != cal_rec["processseq_pare"] 
                      sum_cal_rec["qty_handover"] += cal_rec["consumchgoverqty"]
                end
                @re_cal_flg = true
              end
            end
        else 
          ### 今までのrecords  
          if sum_cal_rec["qty_handover"] > 0          
              sum_cal_rec["qty_handover"] = (sum_cal_rec["qty_handover"] / sum_cal_rec["consumunitqty"]).ceil * sum_cal_rec["consumunitqty"]
              sum_cal_rec["qty_handover"] += sum_cal_rec["consumchgoverqty"]            
              sum_cal_rec["qty_handover"] = (sum_cal_rec["qty_handover"] / sum_cal_rec["packqty"]).ceil * sum_cal_rec["packqty"]
              if  sum_cal_rec["qty_handover"]  < sum_cal_rec["consumminqty"]
                sum_cal_rec["qty_handover"]  = sum_cal_rec["consumminqty"]                      
              end
              insert_mkordtmpfs_sqlv1(sum_cal_rec,history) do
                  yield
              end
          end
          ### 今回のレコ＾ド
          cal_rec["optfixodate"] = cal_rec["duedate_trn"].to_date - cal_rec["optfixoterm"]
          tmp_qty_handover = ((cal_rec["qty_handover"]) / cal_rec["consumunitqty"]).ceil * cal_rec["consumunitqty"]
          tmp_qty_handover = ((tmp_qty_handover + cal_rec["consumchgoverqty"]) / cal_rec["packqty"]).ceil * cal_rec["packqty"]
          if tmp_qty_handover > cal_rec["maxqty"] and cal_rec["tblname"] =~ /prdschs|purschs/  ### cal_rec.qty_handover > maxqty
              ### qty_handover の分解
              @re_cal_flg = true
              maxcnt = 0
              until tmp_qty_handover < cal_rec["maxqty"]
                    if tmp_qty_handover >= cal_rec["maxqty"] and cal_rec["tblname"] =~ /prdschs|purschs/
                      cal_rec["qty_handover"] = cal_rec["maxqty"]    
                    else     
                      cal_rec["qty_handover"] = tmp_qty_handover                        
                    end
                    if base_starttime.to_date < Constants::EndDate.to_date 
                        cal_rec["starttime_trn"] = base_starttime
                        cal_rec["duedate_trn"] = base_duedate
                    end     
                    insert_mkordtmpfs_sqlv1(cal_rec,history) do
                        yield
                    end   ###新しいorderのもと作成              
                    tmp_qty_handover -= cal_rec["maxqty"]    
                    getStarttimeDuedate(cal_rec)
                    base_starttime = cal_rec["starttime_trn"]
                    base_duedate = cal_rec["duedate_trn"]     
                    raise " maxcnt(#{maxcnt}) over MaxSplitCnt,\n cal_rec:#{cal_rec}"    if maxcnt > Constants::MaxSplitCnt
                    maxcnt += 1                  
              end 
              if tmp_qty_handover <= 0
                sum_cal_rec = {"itms_id_trn" => -1}
                sum_cal_rec["processseq_trn"] = sum_cal_rec["shelfnos_id_trn"]  = sum_cal_rec["shelfnos_id_to_trn"] = -1
                sum_cal_rec["qty"] = sum_cal_rec["qty_stk"] = sum_cal_rec["qty_handover"] =  sum_cal_rec["qty_require"] = tmp_qty_handover = 0
              else
                cal_rec["starttime_trn"] = base_starttime
                cal_rec["duedate_trn"] = base_duedate
                cal_rec["qty_handover"] = tmp_qty_handover
                sum_cal_rec = cal_rec.dup
              end
              ###
          else
            sum_cal_rec = cal_rec.dup
          end
        end
      end       
      if sum_cal_rec["itms_id_trn"] != -1
          sum_cal_rec["qty_handover"] = ((sum_cal_rec["qty_handover"]) / sum_cal_rec["packqty"]).ceil * sum_cal_rec["packqty"]  
          insert_mkordtmpfs_sqlv1(sum_cal_rec,history) do
              yield
          end
      end
  end

  def insertOrdPrdPur(params,choice_rec)
    setParams = params.dup
    setParams[:gantt] = nil
		tblord = choice_rec["tblname"].sub("schs","ord")
		# qty_handover = choice_rec["qty_require"].to_f + choice_rec["qty"].to_f 
		blk =  RorBlkCtl::BlkClass.new("r_#{tblord}s")
		command_c = blk.command_init
		symqty = tblord + "_qty"
		symqtyCase = tblord + "_qty_case"
    ###親の消費単位にあわせ自身の作業単位に変換する。
		command_c[symqty] = choice_rec["qty_handover"]  ###端数切り上げ
		command_c[symqtyCase] =  (choice_rec["qty_handover"] / choice_rec["packqty"]).ceil 
		command_c["#{tblord}_duedate"] = choice_rec["duedate_trn"]
		command_c["#{tblord}_starttime"] = choice_rec["starttime_trn"]
		command_c["#{tblord}_person_id_upd"] = setParams[:person_id_upd]
    prdpurschData = ActiveRecord::Base.connection.select_one(%Q& select * from #{choice_rec["tblname"]} where id = #{choice_rec["tblid"]}&)
    command_c["#{tblord}_opeitm_id"] = prdpurschData["opeitms_id"]
    command_c["#{tblord}_chrg_id"] = prdpurschData["chrgs_id"]
		command_c["#{tblord}_expiredate"] = choice_rec["expiredate"]		
		command_c["#{tblord}_created_at"] = command_c["#{tblord}_isudate"] = Time.now
    ###親の消費単位にあわせ自身の作業単位に変換する。
		command_c["sio_classname"] = "_add_ord_by_mkordinst"
		command_c["sio_viewname"] = "r_#{tblord}s"
		command_c["#{tblord}_id"] = command_c["id"] = ArelCtl.proc_get_nextval("#{tblord}s_seq")
    command_c["#{tblord}_sno"] = CtlFields.proc_field_sno("#{tblord}s",Time.now,command_c["id"])
		command_c["#{tblord}_gno"] = params[:mkprdpurords_id] ### 	
		command_c["#{tblord}_prjno_id"] = choice_rec["prjnos_id"] ### 	
		command_c["#{tblord}_confirm"] = Constants::OderConfirmDefult ###
    command_c["#{tblord}_toduedate"] = command_c["#{tblord}_duedate"]  
    blk.proc_create_tbldata(command_c)
		###
		###  xxxords作成
		###
    @outcnt += 1 
		# ###
		symqty = tblord + "_qty"
    # 
    ## 代替品　存在チェック remarkにセット
    #
    strsql = %Q&
          select 1 from opeitms o
                    inner join opeitms alter on o.itms_id = alter.itms_id and o.processseq = alter.processseq
                where o.id = #{prdpurschData["opeitms_id"]} and alter.priority != o.priority 
    &
    alter =  ActiveRecord::Base.connection.select_one(strsql)
    if alter
      command_c["#{tblord}_remark"]  = "alter opeitms exists"
    end
		case tblord 
       when "purord"  ###購入
            command_c.merge!({"purord_shelfno_id_to" => choice_rec["shelfnos_id_to_trn"],
                                "purord_contractprice" => prdpurschData["contractprice"],
                                "itm_taxflg" => choice_rec["taxflg"],
                                "shelfno_loca_id_shelfno_to" => choice_rec["locas_id_to_trn"],
                                "purord_supplier_id" => prdpurschData["suppliers_id"]})
				  command_c,err = CtlFields.proc_judge_check_taxrate(command_c,"purord_taxrate",0,"r_purords")
					strsql = %Q&
									select * from suppliers where id = #{prdpurschData["suppliers_id"]}
						&
					supplier = ActiveRecord::Base.connection.select_one(strsql)
					command_c["supplier_amtround"] = supplier["amtround"]			
          if command_c["purord_contractprice"]  == "C"
            command_c["purord_contractprice"] = supplier["contractprice"]
          end
					command_c,err = CtlFields.proc_judge_check_supplierprice(command_c,"purord_price",0,"r_purords")
          command_c["purord_remark"] = "create by mkord" ###
          if err != ""
            command_c["purord_remark"] += ",#{err}"
          end
          command_c["purord_supplier_id"] = prdpurschData["suppliers_id"]
		      setParams = blk.proc_private_aud_rec(setParams,command_c)
          @outamt +=  command_c["purord_amt"]   ###prdord_amtは0
          @outqty +=  command_c["purord_qty"]   
       when "prdord"  ###製造
            command_c.merge!({"prdord_shelfno_id" => choice_rec["shelfnos_id_trn"],
                                "prdord_shelfno_id_to" => choice_rec["shelfnos_id_to_trn"],
                                "shelfno_loca_id_shelfno_to" => choice_rec["locas_id_to_trn"],
                                "shelfno_loca_id_shelfno" => choice_rec["locas_id_trn"],
                               "prdord_remark" => choice_rec["remark"]})   ###納入先毎の納期、数量 
          shpParams = {:parent => setParams[:tbldata],:child => setParams[:tbldata],:person_id_upd => "0"}
          shpParams[:parent]["tblname"] = "prdords"
          shpParams[:child]["units_id_case_shp"] = "0"
          shpParams[:child]["depdate"] = choice_rec["duedate_trn"]
          shpParams[:child]["shelfnos_id_fm"] = choice_rec["shelfnos_id_trn"]
          shpParams[:child]["itms_id"] = choice_rec["itms_id_trn"]
          shpParams[:child]["processseq"] = choice_rec["processseq_trn"]
		      setParams = blk.proc_private_aud_rec(setParams,command_c)
          @outqty +=  command_c["prdord_qty"]   
          shpParams[:parent]["tblid"] = command_c["id"].to_i
          last_lotstks_parts = Shipment.proc_create_shpxxxs(shpParams) do 
            "shpord"
          end
          @last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
      when "conord"  ###
          pareData = ActiveRecord::Base.connection.select_one(%Q& select * from #{choice_rec["paretblname"]} where id = #{choice_rec["paretblid"]}&)
          case choice_rec["paretblname"]
              when "prdord"
                command_c.merge!({"prdord_shelfno_id_to" => choice_rec["shelfnos_id_to_trn"],
                                "shelfno_loca_id_shelfno_to" => choice_rec["locas_id_to_trn"],
                                "shelfno_loca_id_shelfno" => choice_rec["locas_id_trn"],
                               "prdord_remark" => choice_rec["remark"]})   ###納入先毎の納期、数量 
              when "purord"
                command_c.merge!({"purord_shelfno_id_to" => choice_rec["shelfnos_id_to_trn"],
                                "shelfno_loca_id_shelfno_to" => choice_rec["locas_id_to_trn"],
                                "purord_supplier_id" => pareData["suppliers_id"]} ) 
                choice_rec["suppliers_id"] = pareData["suppliers_id"]
          end
          command_c["conord_duedate"] = pareData["duedate"]
          command_c["conord_starttime"] = pareData["starttime"]
          return
      else
		end
    
		stkinout = {"tblname"=> tblord + "s" ,"tblid" => command_c["id"],
							"itms_id"=>choice_rec["itms_id"],"processseq" => choice_rec["processseq"],
							"prjnos_id" => choice_rec["prjnos_id"],"starttime" => command_c["#{tblord}_duedate"] ,
							"shelfnos_id" => command_c["#{tblord}_shelfno_id_to"],"trngantts_id" => setParams[:gantt]["trngantts_id"],
							"persons_id_upd" => setParams[:person_id_upd],
							"qty_sch" => 0,"qty" => command_c[symqty] ,"qty_stk" => 0,
							"lotno" => "","packno" => "","qty_src" => command_c[symqty].to_f , "amt_src"=> 0}
    @last_lotstks  << {"tblname"=> tblord + "s" ,"tblid" => command_c["id"],"qty_src" => command_c[symqty]}
    ###
    #  ###stkinout["qty_src"] :free_qty
    ###
		ActiveRecord::Base.connection.select_all(reverse_sch_trn_strsql(choice_rec)).each do |sch_trn|   ###trngantts.qty_schの変更
		 		if		stkinout["qty_src"] > 0  ###stkinout["qty_src"] :free_qty  
            save_sch_qty = sch_trn["qty_linkto_alloctbl"]
            @inqty += sch_trn["qty_linkto_alloctbl"]
		 				stkinout["remark"] = " #{self} line:(#{__LINE__}) "
            last_lotstks_parts = ArelCtl.proc_add_linktbls_update_alloctbls(sch_trn,stkinout)  ###schs_qtyをfree_qtyに自動で引き当ててくれる。
            @last_lotstks.concat last_lotstks_parts  if last_lotstks_parts.size > 0  ###nilを避ける
		 				###Shipment.proc_alloc_change_inoutlotstk(stkinout) ### xxxordsの在庫明細変更
            ###schsの消費の取り消し
            prev = {"id" => sch_trn["tblid"],"qty_src" => save_sch_qty}
            new_prev = {"id" => sch_trn["tblid"],"qty_src" => last_lotstks_parts[0]["qty_src"],"persons_id_upd" => setParams[:person_id_upd]}
            last_lotstks_parts = Shipment.proc_update_consume(sch_trn["tblname"],new_prev,prev,true)  ###:true 消費の取り消し
            @last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size 
		 		else
		 						break
		 		end
		end
  end

  
  def insert_mkordtmpfs_sqlv1(cal_rec,history)
    ActiveRecord::Base.connection.insert(
		        %Q&
	 	          insert into mkordtmpfs(id,persons_id_upd,
                mkprdpurords_id,mlevel,
                history,
                tblname,tblid,
                paretblname,paretblid,
                itms_id_trn,itms_id_pare,
								processseq_trn,processseq_pare,locas_id_trn,
								prjnos_id,
								shelfnos_id_to_trn,shelfnos_id_trn,
								shelfnos_id_to_pare,shelfnos_id_pare,  --- shelfnos_id_to_pareは使用しない。0:固定
								qty_sch,qty,qty_stk,
								duedate,toduedate,starttime,
                optfixodate,optfixoterm,
								duedate_trn,starttime_trn,toduedate_trn,
								duedate_pare,starttime_pare,
								packqty,consumchgoverqty,
                consumminqty,consumunitqty,maxqty,
								parenum,chilnum,
								qty_handover,qty_require,   --- 
                chrgs_id_trn,chrgs_id_pare,chrgs_id_org,
								incnt,expiredate,created_at,updated_at)
				      values (nextval('mkordtmpfs_seq'),#{cal_rec["persons_id_upd"]}, 
                #{cal_rec["mkprdpurords_id"]},#{cal_rec["mlevel"]},
                #{if yield == "trngantts" then 0 else history + 1 end} ,
                '#{cal_rec["tblname"]}',#{cal_rec["tblid"]},
                '#{cal_rec["paretblname"]}',#{cal_rec["paretblid"]},
                #{cal_rec["itms_id_trn"]},#{cal_rec["itms_id_pare"]},  ---xxx_trn=xxx_pare
                #{cal_rec["processseq_trn"]},#{cal_rec["processseq_pare"]}, 0,
								#{cal_rec["prjnos_id"]},
								#{cal_rec["shelfnos_id_to_trn"]},#{cal_rec["shelfnos_id_trn"]},
								0,#{cal_rec["shelfnos_id_pare"]},
                #{cal_rec["qty_sch"]},#{cal_rec["qty"]},#{cal_rec["qty_stk"]},
                '#{cal_rec["duedate"]}','#{cal_rec["duedate"]}','#{cal_rec["starttime"]}',
                '#{cal_rec["optfixodate"]}','#{cal_rec["optfixoterm"]}',
                '#{cal_rec["duedate_trn"]}','#{cal_rec["starttime_trn"]}','#{cal_rec["toduedate_trn"]}',
                '#{cal_rec["duedate_pare"]}','#{cal_rec["starttime_pare"]}',
                #{cal_rec["packqty"]},#{cal_rec["consumchgoverqty"]},
                #{cal_rec["consumminqty"]},#{cal_rec["consumunitqty"]},#{cal_rec["maxqty"]},
                #{cal_rec["parenum"]},#{cal_rec["chilnum"]},
                #{cal_rec["qty_handover"]},#{cal_rec["qty_require"]},   --- 
                #{cal_rec["chrgs_id_trn"]},#{cal_rec["chrgs_id_pare"]},#{cal_rec["chrgs_id_org"]},   --- 
                #{cal_rec["incnt"]},'#{Constants::EndDate}',current_timestamp,current_timestamp )
              &)
  end

	def proc_mkbillinsts params,mkbillinstparams   
		tbldata = params[:tbldata].dup  ###tbldata -->
    str_cust_join = str_bill_join = str_chrg_join = ""
		tbldata.each do |field,val|  ### mkbillinsts
			next if val == "" or val.nil?
			case field
			when /loca_code_cust/
        str_cust_join = %Q& where l.code = '#{val}' &     
			when /loca_code_bill/
        str_bill_join = %Q& where l.code = '#{val}'&
			when /person_code_chrg/
        str_chrg_join = %Q& where per.code = '#{val}'&
			end
		end  ###fields.each
    str_joinsql = %Q& inner join (select s.id custs_id,bill.termof,bill.bills_id,bill.ratejson,chrgs_id_bill
                                             from custs s 
                                              inner join ( select p.id bills_id ,p.termof,p.ratejson,p.chrgs_id_bill from bills p 
                                                            inner join  (select c.id from chrgs c 
                                                                          inner join persons per on per.id = c.persons_id_chrg
                                                                            #{str_chrg_join} ) chrg
                                                                on chrg.id = p.chrgs_id_bill
                                                            inner join locas lp on lp.id = p.locas_id_bill     
                                                                #{str_bill_join}
                                                                ) bill                                                                           
                                                on bills_id = s.bills_id_bill
                                              inner join locas ls on ls.id = s.locas_id_cust
                                                    #{str_cust_join}
                                              ) billcust
                       on act.custs_id = billcust.custs_id &

    strsql = %Q&
                select act.id custacts_id,act.amt amt_src,act.saledate,act.crrs_id,billcust.* from custacts act
                      #{str_joinsql}
                      where not exists(select 1 from  srctbllinks link where act.id = link.srctblid
                                        and link.srctblname = 'custacts' and link.tblname = 'billinsts')
                      order by bills_id,act.saledate
              &  
      ActiveRecord::Base.connection.select_all(strsql).each do |inst|
        mkbillinstparams[:incnt] += 1
        billinst_tbldata = {"isudate"=>payinst_isudate,"pays_id" => inst["pays_id"],
                      "last_amt" => nil,"last_duedate" => nil,
                      "termofs" => inst["termof"],"payment" => inst["ratejson"],
                      "persons_id_upd" => params[:person_id_upd] ,"trngantts_id" => nil,
                      "chrgs_id" => inst["chrgs_id_pay"],"crrs_id" => inst["crrs_id"],
                      "tblname" => "payinsts",
                      "srctblname" => "custacts","srctblid" => inst["custacts_id"]}
        
        mkbillinstparams = paybillinsts(inst,mkbillinstparams,billinst_tbldata)
		  end
		return mkbillinstparams  
	end	
	###
	def proc_mkpayinsts params,mkpayinstparams  
		tbldata = params[:tbldata].dup  ###tbldata -->
    str_supplier_join = str_payment_join = str_chrg_join = ""
		tbldata.each do |field,val|  ### mkpayinsts
			next if val == "" or val.nil?
			case field
			when /loca_code_supplier/
        str_supplier_join = %Q& where l.code = '#{val}' &     
			when /loca_code_payment/
        str_payment_join = %Q& where l.code = '#{val}'&
			when /person_code_chrg/
        str_chrg_join = %Q& where per.code = '#{val}'&
			end
		end  ###fields.each
    str_joinsql = %Q& inner join (select s.id suppliers_id,payment.termof,payment.payments_id,payment.ratejson,chrgs_id_payment
                                             from suppliers s 
                                              inner join ( select p.id payments_id ,p.termof,p.ratejson,p.chrgs_id_payment from payments p 
                                                            inner join  (select c.id from chrgs c 
                                                                          inner join persons per on per.id = c.persons_id_chrg
                                                                            #{str_chrg_join} ) chrg
                                                                on chrg.id = p.chrgs_id_payment
                                                            inner join locas lp on lp.id = p.locas_id_payment      
                                                                #{str_payment_join}
                                                                ) payment                                                                             
                                                on payments_id = s.payments_id_supplier
                                              inner join locas ls on ls.id = s.locas_id_supplier
                                                    #{str_supplier_join}
                                              ) paysupp
                       on act.suppliers_id = paysupp.suppliers_id &

    strsql = %Q&
                select act.id puracts_id,act.amt amt_src,act.rcptdate,act.crrs_id,paysupp.* from puracts act
                      #{str_joinsql}
                      where not exists(select 1 from  srctbllinks link where act.id = link.srctblid
                                        and link.srctblname = 'puracts' and link.tblname = 'payinsts')
                      order by payments_id,act.rcptdate
              &
      payinst_isudate = Time.now
      last_manth = (Time.now.strftime("%Y") + "-" +Time.now.strftime("%m") + "-" + "01").to_date.since(-1.day)  
      ActiveRecord::Base.connection.select_all(strsql).each do |inst|
        mkpayinstparams[:incnt] += 1
        payinst_tbldata = {"isudate"=>payinst_isudate,"pays_id" => inst["pays_id"],
                      "last_amt" => nil,"last_duedate" => nil,
                      "termofs" => inst["termof"],"payment" => inst["ratejson"],
                      "persons_id_upd" => params[:person_id_upd] ,"trngantts_id" => nil,
                      "chrgs_id" => inst["chrgs_id_pay"],"crrs_id" => inst["crrs_id"],
                      "tblname" => "payinsts",
                      "srctblname" => "custacts","srctblid" => inst["custacts_id"]}
        mkpayinstparams = paybillinsts(inst,mkpayinstparams,payinst_tbldata)
		  end
		return mkpayinstparams  
	end	

  def paybillinsts(inst,paybillParams,paybill_tbldata)
    inst["termof"].split(",").each do |termof|
      case termof
      when "0","00"   ###随時
        JSON.parse(inst["ratejson"]).each do |rate|   ###rate["duration"] 0:同月　1:翌月
            duedate =  inst["saledate"].to_date.since(rate["duration"].to_i.month)
            if rate["day"].to_i >= 28
              duedate =  duedate.since(1.month)
              duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
              duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
            else
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
            end
            paybill_tbldata.merge!({"amt_src" => inst["amt_src"].to_f * rate["rate"].to_i / 100 ,
                        "tax" =>  params[:tax].to_f * rate["rate"].to_i / 100,
                        "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
            proc_create_paybilltbl("payinsts",paybill_tbldata)
            paybillParams[:outcnt] += 1
            paybillParams[:inamt] += paybill_tbldata["amt_src"]
            paybillParams[:outamt] += paybill_tbldata["amt_src"]
        end
        break
      when "28","29","30","31"
        if inst["saledate"].to_date > last_month
          break
        else
          JSON.parse(inst["ratejson"]).each do |rate|
              duedate =  inst["saledate"].to_date.since(rate["duration"].to_i.month)
              if rate["day"].to_i >= 28
                duedate =  duedate.since(1.month)
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
              else
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
              end
              paybill_tbldata.merge!({"amt_src" => inst["amt_src"].to_f * rate["rate"].to_i / 100 ,
                          "tax" =>  params[:tax].to_f * rate["rate"].to_i / 100,
                          "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
              proc_create_paybilltbl("billinsts",paybill_tbldata)
              paybillParams[:outcnt] += 1
              paybillParams[:inamt] += paybill_tbldata["amt_src"]
              paybillParams[:outamt] += paybill_tbldata["amt_src"]
          end
          break
        end
      else
        if inst["saledate"].to_date > (Time.now.strftime("%Y") + "-" + Time.now.strftime("%m") + "-" + termof).to_date
          next
        else
          JSON.parse(inst["ratejson"]).each do |rate|
              duedate =  inst["saledate"].to_date.since(rate["duration"].to_i.month)
              if rate["day"].to_i >= 28
                duedate =  duedate.since(1.month)
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
              else
                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
              end
              paybill_tbldata.merge!({"amt_src" => inst["amt_src"].to_f * rate["rate"].to_i / 100 ,
                          "tax" =>  params[:tax].to_f * rate["rate"].to_i / 100,
                          "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
              proc_create_paybilltbl(paybill_tbldat["tblname"],paybill_tbldata)
              paybillParams[:outcnt] += 1
              paybillParams[:inamt] += paybill_tbldata["amt_src"]
              paybillParams[:outamt] += paybill_tbldata["amt_src"]
          end
          break ### 重複しないように
        end
      end
    end
  end

	def sch_trn_alloc_to_freetrnv1(sumSchs)   ###xxxschsをまとめて消費量を決めているので
    ###freeを探す　
    sumSchs["qty_require"] = qty_require = sumSchs["qty_require"].to_f
    ###freeのxxxordsは子部品を既に手配済が条件
    free_qty =  sch_qty = 0
    base = {"qty_src" => 0 }
     ####
     ###	個別にひきあてるのでfreeは過剰に消費される
     ####
    ActiveRecord::Base.connection.select_all(sch_trn_strsqlv1(sumSchs)).each do |sch_trn|
      sch_qty = sch_trn["qty_linkto_alloctbl"].to_f + sch_qty
      if free_qty <= 0
        strsql = %Q&select * from func_get_free_ord_stk_v1('#{sumSchs["duedate"]}',#{sumSchs["prjnos_id"] },
                                                          #{sumSchs["itms_id"]},#{sumSchs["processseq"]},#{sumSchs["shelfnos_id_to"]})&
        ActiveRecord::Base.connection.select_all(strsql).each do |free|   ### 
          free.each do |k,v|
           base[k] = v
          end
          base["persons_id_upd"] = sumSchs["persons_id_upd"]
          base["amt_src"] = 0
          base["qty_src"] = free_qty = free["qty_linkto_alloctbl"].to_f   ###free_qty
          if sch_qty > base["qty_src"]
           sch_qty  -= base["qty_src"]
           free_qty = 0
          else
           sch_qty = 0
           free_qty = base["qty_src"] - sch_qty 
          end
          base["remark"] = "#{self} line:(#{__LINE__})"
          last_lotstks_parts =  ArelCtl.proc_add_linktbls_update_alloctbls(sch_trn,base)  ###freeの引当
          @last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
          ###schsの消費の取り消し
          prev = {"id" => sch_trn["tblid"],"qty_src" => sch_trn["qty_linkto_alloctbl"]}
          new_prev = {"id" => sch_trn["tblid"],"qty_src" => sch_qty,"persons_id_upd" => 0}
          last_lotstks_parts = Shipment.proc_update_consume(sch_trn["tblname"],new_prev,prev,true)  ###:true 消費の取り消し
          @last_lotstks.concat last_lotstks_parts  if last_lotstks_parts.size > 0
          ###
          base["qty_src"] = free_qty
          sch_trn["qty_linkto_alloctbl"] = sch_qty
          break if free_qty <= 0
          break if sch_qty <=0
        end
     end
    end
    return 
  end	 

	def set_mkprdpurords_id_in_trngantts(add_tbl,mkprdpurords_id)   ##alocctblのxxxschsは一件のみ
    ActiveRecord::Base.connection.update(
		  %Q&
		      update trngantts set mkprdpurords_id_trngantt = #{mkprdpurords_id},
                  packqty = case packqty when null then 1
                                          when 0 then 1
                                          else packqty    
                            end,
                  parenum = case parenum when null then 1
                                          when 0 then 1
                                          else parenum  
                            end,
                  chilnum = case chilnum when null then 1
                                          when 0 then 1
                                          else chilnum  
                            end,
                  consumunitqty = case consumunitqty when null then 1
                                                      when 0 then 1
                                                      else consumunitqty 
                            end,
                  maxqty = case maxqty when null then 999999999
                                                      when 0 then 999999999
                                                      else maxqty 
                            end,
                  consumminqty = case consumminqty when null then 1
                                                      when 0 then 1
                                                      else consumminqty 
                            end,
                  optfixoterm = case optfixoterm when null then 365
                                                      when 0 then 365
                                                      else optfixoterm 
                            end,
				          remark = ' #{self} line:#{__LINE__}'||left(remark,3000),
				          updated_at = current_timestamp  
				        where orgtblid in (select gantt.orgtblid 
										        from trngantts gantt #{add_tbl}
										        where	gantt.qty_sch > 0 
											          #{@strwhere["org"]} #{@strwhere["pare"]} #{@strwhere["trn"]}
										        group by gantt.orgtblid
					                )  
			  &)
    ActiveRecord::Base.connection.update(
		  %Q& ---@incnt,@inqty用
		      update trngantts set gather_flg = #{mkprdpurords_id}
				        from (select gantt.id
										        from trngantts gantt #{add_tbl}
										        where	gantt.qty_sch > 0 
											          #{@strwhere["org"]} #{@strwhere["pare"]} #{@strwhere["trn"]}
					                )  tg
              where trngantts.id = tg.id 
			  &)
	end
  
	def init_sum_ord_insert mkprdpurords_id
        base_optfixodate = Constants::EndDate.to_date
        prev_init_rec = {}
        init_recs = ActiveRecord::Base.connection.select_all(%Q&
                      select * from trngantts gantt
						                  where  gantt.orgtblname = gantt.paretblname and gantt.orgtblid = gantt.paretblid  
                                and gantt.tblname in ('prdschs','purschs','custords','custschs')  ---手入力でprdschs,purschsを取り込んだ
                                and gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id} and mlevel = 0
							                order by gantt.prjnos_id,gantt.itms_id_trn,gantt.processseq_trn , gantt.shelfnos_id_trn,gantt.shelfnos_id_to_trn,
                                      gantt.duedate_trn desc
                          &)
        init_recs.each do |init_rec|
            if init_rec["duedate_trn"].to_date < base_optfixodate or
                (prev_init_rec["prjnos_id"] != init_rec["prjnos_id"] or prev_init_rec["itms_id_trn"] != init_rec["itms_id_trn"] or 
                  prev_init_rec["processseq_trn"] != init_rec["processseq_trn"] or prev_init_rec["shelfnos_id_trn"] != init_rec["shelfnos_id_trn"] or
                     prev_init_rec["shelfnos_id_to_trn"] != init_rec["shelfnos_id_to_trn"])
                      base_optfixodate = init_rec["duedate_trn"].to_date - init_rec["optfixoterm"]
            end  
            prev_init_rec = init_rec.dup 
            str_optfixodate = base_optfixodate.strftime("%Y") + "-" + base_optfixodate.strftime("%m") + "-" + base_optfixodate.strftime("%d")
            ActiveRecord::Base.connection.update(%Q&
                      update trngantts gantt set optfixodate = '#{str_optfixodate}'
						                  where  id = #{init_rec["id"]}
                          &)     
        end
        ActiveRecord::Base.connection.insert(
		      %Q&
              insert into mkordtmpfs(id,persons_id_upd,mkprdpurords_id,mlevel,history,
                 itms_id_pare,itms_id_trn,
								  processseq_pare,processseq_trn,
								  locas_id_trn,prjnos_id,
								  shelfnos_id_to_pare,shelfnos_id_to_trn,
								  shelfnos_id_pare,shelfnos_id_trn,
                  qty_sch,qty,qty_stk,
                  duedate,toduedate,starttime,
                  duedate_trn,starttime_trn,
                  duedate_pare,starttime_pare,
								  packqty,consumchgoverqty,
                  consumminqty,	consumunitqty,maxqty,
								  parenum,chilnum,
								  qty_handover,qty_require,   --- qty_handover key='00001'の時のみ有効
								  tblname,tblid,incnt,
                  paretblname,paretblid,toduedate_trn,
                  optfixodate,optfixoterm,
                  chrgs_id_trn,chrgs_id_pare,chrgs_id_org,
								  expiredate,created_at,updated_at)
				        select nextval('mkordtmpfs_seq'),0 persons_id_upd,gantt.mkprdpurords_id_trngantt ,0 mlevel,0 history,
                  gantt.itms_id_trn itms_id_pare, gantt.itms_id_trn itms_id_trn,
						      gantt.processseq_trn processseq_pare,gantt.processseq_trn processseq_trn ,
                  max(s.locas_id_shelfno) locas_id_trn,	gantt.prjnos_id ,
                  max(gantt.shelfnos_id_to_pare) shelfnos_id_to_pare,gantt.shelfnos_id_to_trn,
                    ---作業指示,注を納入先毎に分ける
                  max(gantt.shelfnos_id_pare)  shelfnos_id_pare,gantt.shelfnos_id_trn,
						      sum(gantt.qty_sch) qty_sch,sum(gantt.qty) qty,sum(gantt.qty_stk) qty_stk,
						      min(gantt.duedate_trn),	min(gantt.toduedate_trn),	min(gantt.starttime_trn),
						      min(gantt.duedate_trn) duedate_trn,	min(gantt.starttime_trn),
						      min(gantt.duedate_pare),	min(gantt.starttime_pare),  ---duedate_trn=duedate_pare
						      max(gantt.packqty) packqty,max(gantt.consumchgoverqty) consumchgoverqty,
                  max(gantt.consumminqty) consumminqty,max(gantt.consumunitqty) consumunitqty,max(gantt.maxqty) maxqty,
						      1 parenum,1 chilnum,
						      sum(gantt.qty + gantt.qty_sch) qty_handover,sum(gantt.qty + gantt.qty_sch) qty_require,
						      max(gantt.tblname) tblname,min(gantt.tblid) tblid,count(tblid) incnt,
                  max(paretblname) paretblname,max(paretblid) paretblid,min(toduedate_trn) toduedate_trn,
                  gantt.optfixodate,max(optfixoterm) optfixoterm,
                  max(gantt.chrgs_id_trn),max(gantt.chrgs_id_pare),max(gantt.chrgs_id_org),
						      '#{Constants::EndDate}',current_timestamp,current_timestamp 
						    from trngantts gantt 
						    inner join shelfnos s on s.id = gantt.shelfnos_id_trn
						    where  gantt.orgtblname = gantt.paretblname and gantt.orgtblid = gantt.paretblid  
                  and gantt.tblname in ('prdschs','purschs','custords','custschs')  ---手入力でprdschs,purschsを取り込んだ
                  and gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id} and mlevel = 0
						    group by gantt.mkprdpurords_id_trngantt ,gantt.prjnos_id,
							        gantt.itms_id_trn,gantt.processseq_trn , gantt.shelfnos_id_trn,gantt.shelfnos_id_to_trn,
                      gantt.optfixodate
							  order by gantt.prjnos_id,gantt.itms_id_trn,gantt.processseq_trn , gantt.shelfnos_id_trn,gantt.shelfnos_id_to_trn,
                      gantt.optfixodate
				&)
	end	


	def cal_rec_sql(mkprdpurords_id,sel_rec,basetbl,history)
		      %Q&  
              select nextval('mkordtmpfs_seq'),0 persons_id_upd,
                #{mkprdpurords_id} mkprdpurords_id ,#{sel_rec["mlevel"] + 1} mlevel,
                gantt.itms_id_pare ,gantt.itms_id_trn ,
                gantt.processseq_pare  ,gantt.processseq_trn,	
                s.locas_id_shelfno locas_id_trn,gantt.prjnos_id ,
						    shelfnos_id_to_pare shelfnos_id_to_pare,gantt.shelfnos_id_to_trn ,
                gantt.shelfnos_id_pare shelfnos_id_pare,gantt.shelfnos_id_trn,
						    gantt.qty_sch, gantt.qty, gantt.qty_stk,
                gantt.duedate_trn ,	gantt.toduedate_trn ,starttime_trn ,
                gantt.duedate_trn duedate,	gantt.starttime_trn starttime,
                pare.duedate duedate_pare,	pare.starttime starttime_pare,
                gantt.packqty,gantt.consumchgoverqty,
                gantt.consumminqty,gantt.consumunitqty,gantt.maxqty,
                gantt.parenum,gantt.chilnum,
                gantt.chrgs_id_trn,gantt.chrgs_id_pare,gantt.chrgs_id_org,
								(pare.qty_handover / gantt.parenum * gantt.chilnum)   qty_handover,
                (pare.qty_handover) qty_require,
                gantt.tblname,gantt.tblid tblid,gantt.paretblname,gantt.paretblid, 
                #{case basetbl when "trngantts" then "1" else " incnt" end} incnt, 
                pare.optfixodate optfixodate_pare,gantt.optfixoterm,
                gantt.optfixodate,gantt.expiredate,current_timestamp created_at,current_timestamp updated_at
					    from #{basetbl} gantt
              inner join shelfnos s on s.id = gantt.shelfnos_id_trn
					    inner join (select tblname,tblid,itms_id_trn,processseq_trn,mkprdpurords_id,prjnos_id,shelfnos_id_trn,shelfnos_id_to_trn,
                                  qty_handover,optfixodate,duedate_trn duedate,starttime_trn starttime
                                  from mkordtmpfs
                                  where mkprdpurords_id = #{sel_rec["mkprdpurords_id"]}  ---xxx
                                        and prjnos_id = #{sel_rec["prjnos_id"]} 
                                        and itms_id_trn =  #{sel_rec["itms_id_trn"]}  and processseq_trn = #{sel_rec["processseq_trn"]}
                                        and shelfnos_id_trn =  #{sel_rec["shelfnos_id_trn"]} and  shelfnos_id_to_trn =  #{sel_rec["shelfnos_id_to_trn"]}  
                                        and   mlevel = #{sel_rec["mlevel"]} and tblname != 'conschs'  
                                        and history = #{history} 
                              )	pare on pare.tblname = gantt.paretblname and pare.tblid = gantt.paretblid   
				        where  #{case basetbl when "trngantts" then "gantt.mkprdpurords_id_trngantt" else "gantt.mkprdpurords_id" end} = #{sel_rec["mkprdpurords_id"]} ---xxx
                    and gantt.prjnos_id = #{sel_rec["prjnos_id"]} 
                    and (gantt.paretblname != gantt.tblname or gantt.paretblid != gantt.tblid)
                    and gantt.expiredate > current_date and (gantt.qty_sch > 0 or gantt.qty > 0)
                    and gantt.tblname in ('prdschs','purschs','conschs') --- custxxxs,ercschs,dcsschsは除く
        union   ---金型のとき
            select nextval('mkordtmpfs_seq'),0 persons_id_upd,
                #{mkprdpurords_id} mkprdpurords_id ,#{sel_rec["mlevel"] + 1} mlevel,
                gantt.itms_id_pare ,gantt.itms_id_trn ,
                gantt.processseq_pare  ,gantt.processseq_trn,	
                s.locas_id_shelfno locas_id_trn,gantt.prjnos_id ,
						    shelfnos_id_to_pare shelfnos_id_to_pare,gantt.shelfnos_id_to_trn ,
                gantt.shelfnos_id_pare shelfnos_id_pare,gantt.shelfnos_id_trn,
						    gantt.qty_sch, gantt.qty, gantt.qty_stk,
                gantt.duedate_trn ,	gantt.toduedate_trn ,starttime_trn ,
                gantt.duedate_trn duedate,	gantt.starttime_trn starttime,
                pare.duedate duedate_pare,	pare.starttime starttime_pare,
                gantt.packqty,gantt.consumchgoverqty,
                gantt.consumminqty,gantt.consumunitqty,gantt.maxqty,
                gantt.parenum,gantt.chilnum,
                gantt.chrgs_id_trn,gantt.chrgs_id_pare,gantt.chrgs_id_org,
								(pare.qty_handover / gantt.parenum * gantt.chilnum)    qty_handover,
                (pare.qty_handover) qty_require,
                gantt.tblname,gantt.tblid tblid,gantt.paretblname,gantt.paretblid, 
                #{case basetbl when "trngantts" then "1" else " incnt" end} incnt,  
                pare.optfixodate optfixodate_pare,gantt.optfixoterm,
                gantt.optfixodate,gantt.expiredate,current_timestamp created_at,current_timestamp updated_at
					    from #{basetbl} gantt
              inner join shelfnos s on s.id = gantt.shelfnos_id_trn
					    inner join (select tblname,tblid,mkprdpurords_id,prjnos_id,qty_handover,duedate,starttime ,
                                  shelfnos_id_trn,shelfnos_id_to_trn,optfixodate
                                  from mkordtmpfs
                                  where mkprdpurords_id = #{sel_rec["mkprdpurords_id"]} ---  
                                     and prjnos_id = #{sel_rec["prjnos_id"]} 
                                     and   mlevel =  #{sel_rec["mlevel"]} and qty_sch > 0
                                     and history = #{history} 
                                     and tblname = 'conschs')  pare on pare.tblname = gantt.paretblname and pare.tblid = gantt.paretblid     
				      where #{case basetbl when "trngantts" then "gantt.mkprdpurords_id_trngantt" else "gantt.mkprdpurords_id" end} = #{sel_rec["mkprdpurords_id"]} ---xxx
                    and (gantt.paretblname != gantt.tblname or gantt.paretblid != gantt.tblid)
                    and gantt.prjnos_id = #{sel_rec["prjnos_id"]} 
                    and gantt.expiredate > current_date  
                    and gantt.tblname = 'prdschs'  --- gate custxxxsは除く
                    and (gantt.qty_sch > 0 or gantt.qty > 0)
          order by prjnos_id ,itms_id_trn,processseq_trn,shelfnos_id_trn,shelfnos_id_to_trn,duedate_trn desc,
                    itms_id_pare,processseq_pare,shelfnos_id_pare,   --- consumchgoverqty加算のため
                   packqty,consumchgoverqty,shelfnos_id_pare
				&
	end		

	def	sch_trn_strsqlv1(sumSchs) 
		 %Q&   ---sumSchsから個別のqty_schをもとめる。
		  		select gantt.id trngantts_id,gantt.*,a.id alloctbls_id,a.qty_linkto_alloctbl 
          from trngantts gantt
					  inner join shelfnos s on s.id = gantt.shelfnos_id_to_trn
					  inner join alloctbls a on a.trngantts_id = gantt.id
					where gantt.mkprdpurords_id_trngantt = #{sumSchs["mkprdpurords_id"]}
					  and gantt.itms_id_trn = #{sumSchs["itms_id"]} 
					  and gantt.processseq_trn = #{sumSchs["processseq"]} 
					  and s.locas_id_shelfno = #{sumSchs["locas_id"]}  ---引当はlocas_id
					  and gantt.prjnos_id = #{sumSchs["prjnos_id"]} 
					  and a.qty_linkto_alloctbl > 0 and a.srctblname like '%schs'
          order by  (gantt.duedate_trn)
			&	
	end

  
	def	reverse_sch_trn_strsql(cal_rec) 
        %Q&   ---cal_recから個別のqty_schをもとめる。
          select gantt.id trngantts_id,gantt.*,a.id alloctbls_id,a.qty_linkto_alloctbl from trngantts gantt
                inner join alloctbls a on a.trngantts_id = gantt.id
                where gantt.mkprdpurords_id_trngantt = #{cal_rec["mkprdpurords_id"]}
                  and gantt.itms_id_trn = #{cal_rec["itms_id_trn"]} 
                  and gantt.shelfnos_id_trn = #{cal_rec["shelfnos_id_trn"]} 
                  and gantt.processseq_trn = #{cal_rec["processseq_trn"]} and gantt.shelfnos_id_to_trn = #{cal_rec["shelfnos_id_to_trn"]}
                  and (a.qty_linkto_alloctbl > 0 and a.srctblname like '%schs') 
                order by gantt.duedate_trn
        &	
  end

  def shsAllocToStk(mkprdpurords_id)###free ords,stkの引当
    ActiveRecord::Base.connection.select_all(
        %Q&
          select gantt.itms_id_trn itms_id ,gantt.processseq_trn  processseq,gantt.prjnos_id,
              sum(gantt.qty_sch) qty_require,s.locas_id_shelfno locas_id,gantt.duedate_trn duedate,
              gantt.shelfnos_id_trn shelfnos_id,gantt.shelfnos_id_to_trn shelfnos_id_to,
              gantt.mkprdpurords_id_trngantt mkprdpurords_id
            from trngantts	gantt
            inner join shelfnos s on s.id = gantt.shelfnos_id_to_trn
            where gantt.mkprdpurords_id_trngantt = #{mkprdpurords_id} and gantt.qty_sch  > 0
            group by gantt.itms_id_trn,gantt.processseq_trn,gantt.prjnos_id,
                        s.locas_id_shelfno, gantt.shelfnos_id_trn, gantt.shelfnos_id_to_trn ,
                        gantt.mkprdpurords_id_trngantt,gantt.duedate_trn
            order by gantt.itms_id_trn,gantt.processseq_trn,gantt.shelfnos_id_trn,gantt.duedate_trn
          &)
  end

  ###前払い　前受け金を含む
  def proc_create_paybilltbl(tblname,tbldata)  ###src:puracts puracts_id
        blk = RorBlkCtl::BlkClass.new("r_#{tblname}")
        command_c = blk.command_init
        command_c["#{tblname.chop}_person_id_upd"] = tbldata["persons_id_upd"]
        command_c["#{tblname.chop}_chrg_id"] = tbldata["chrgs_id"]
        command_c["#{tblname.chop}_duedate"] = tbldata["duedate"]
        command_c["#{tblname.chop}_isudate"] = tbldata["isudate"]
        command_c["#{tblname.chop}_expiredate"] =  Constants::EndDate 
        command_c["#{tblname.chop}_updated_at"] = Time.now
        case tblname
        when /^pay/
          command_c["#{tblname.chop}_payment_id"] = tbldata["payments_id"]
          command_c["#{tblname.chop}_accounttitle"] = "1"  ###仕入
        when /^bill/
          command_c["#{tblname.chop}_bill_id"] = tbldata["bills_id"]
        end
        command_c["#{tblname.chop}_denomination"] = tbldata["denomination"]   ###  CASH,DEPOSIT,DRAFT
        command_c["#{tblname.chop}_remark"] = "class:#{self},line:#{__LINE__},srctblname:#{tbldata["srctblname"]},srctblid:#{tbldata["srctblid"]}"
        case tblname 
        when /acts$/
          str_amt = "cash"
        when /schs$/
          str_amt = 'amt_sch'
        else
          str_amt = "amt"
        end  ###payments_id_supplier
        command_c["#{tblname.chop}_#{str_amt}"] = tbldata["amt_src"]
        command_c["#{tblname.chop}_tax"] = tbldata["amt_src"].to_f * tbldata["taxrate"].to_f / 100 
        case tblname
          when /pay/
              strsql = %Q&
                    select trnpay.* from #{tblname} trnpay
                              inner join suppliers supp
                              on supp.payments_id_supplier = trnpay.payments_id
                            where supp.payments_id_supplier = #{tbldata["payments_id"].to_s}
                            and trnpay.duedate = '#{tbldata["duedate"].to_date}'
                            for update
                        &
          when /bill/
              strsql = %Q&
                    select trnbill.* from #{tblname} trnbill
                              inner join custs cust
                              on cust.bills_id_cust = trnbill.bills_id
                            where cust.bills_id_cust = #{tbldata["bills_id"].to_s}
                              and trnbill.duedate = '#{tbldata["duedate"].to_date}' 
                            for update
                &
        end
        actrec = ActiveRecord::Base.connection.select_one(strsql)
        if actrec
                command_c["sio_classname"] = "_update_from_#{tbldata["srctblname"]}"
                command_c["id"] = command_c["#{tblname.chop}_id"] = actrec["id"]
                command_c["#{tblname.chop}_#{str_amt}"] = actrec[str_amt].to_f + tbldata["amt_src"].to_f
                command_c["#{tblname.chop}_tax"] = command_c["#{tblname.chop}_#{str_amt}"].to_f * tbldata["taxrate"].to_f / 100
                blk.proc_private_aud_rec({},command_c)
        else
                command_c["sio_classname"] = "_add_from_#{tbldata["srctblname"]}"
                command_c["id"] = command_c["#{tblname.chop}_id"] = ArelCtl.proc_get_nextval("#{tblname}_seq")
                command_c["#{tblname.chop}_created_at"] = Time.now
                command_c["#{tblname.chop}_sno"] = CtlFields.proc_field_sno("#{tblname.chop}",tbldata["isudate"],command_c["id"])
                command_c["#{tblname.chop}_#{str_amt}"] = tbldata["amt_src"]
                command_c["#{tblname.chop}_tax"] = command_c["#{tblname.chop}_#{str_amt}"].to_f * tbldata["taxrate"].to_f / 100
                command_c["#{tblname.chop}_sno"] = CtlFields.proc_field_sno(tblname.chop,tbldata["isudate"],command_c["id"])
                blk.proc_private_aud_rec({},command_c)
        end
        src = {"tblname" => tbldata["srctblname"],"tblid" => tbldata["srctblid"]}
        base = {"tblname" => "#{tblname}","tblid" => command_c["id"],"amt_src" => command_c["#{tblname.chop}_#{str_amt}"]}
        ArelCtl.proc_insert_srctbllinks(src,base)
            ###
            # 前の状態の削除
            ##
        case tblname
        when /acts$/  ##payinsts,billinsts からｓｎｏでの消込
              strsql = %Q&
                        select * from #{src["srctblname"]} where id = #{tbldata["srctblid"]}             
              &
              prevtbldata = ActiveRecord::Base.connection.select_one(strsql)
              blk = RorBlkCtl::BlkClass.new("r_#{prevtblname}")
              command_c = blk.command_init
              command_c["sio_classname"] = "_update_from_#{tblname}"
              command_c["#{prevtblname.chop}_person_id_upd"] = tbldata["persons_id_upd"]
              command_c["id"] = command_c["#{prevtblname.chop}_id"]= tbldata["srctblid"]
              command_c["#{prevtblname.chop}_amt"] = prevtbldata["amt"].to_f 
              command_c["#{prevtblname.chop}_tax"] = prevtbldata["amt"].to_f * prevtbldata["taxrate"].to_f / 100   
              blk.proc_private_aud_rec({},command_c)
        when /insts$/
              prevtblname = tblname.sub("inst","ord")  ###tbldata["srctblname"]--> puracts custacts
              strsql = %Q&
                    select * from #{prevtblname} where id = (
                        select tblid from srctbllinks 
                         where srctblid = #{tbldata["srctblid"]}  and srctblname = '#{tbldata["srctblname"]}'
                         and tblname = '#{prevtblname}' )       
              &
              prevtbldata = ActiveRecord::Base.connection.select_one(strsql)
              blk = RorBlkCtl::BlkClass.new("r_#{prevtblname}")
              command_c = blk.command_init
              command_c["sio_classname"] = "_update_from_#{tblname}"
              command_c["#{prevtblname.chop}_person_id_upd"] = tbldata["persons_id_upd"]
              command_c["id"] = command_c["#{prevtblname.chop}_id"]= prevtbldata["id"]
              command_c["#{prevtblname.chop}_amt"] = prevtbldata["amt"].to_f - tbldata["amt_src"].to_f
              command_c["#{prevtblname.chop}_tax"] = command_c["#{prevtblname.chop}_amt"] * tbldata["taxrate"].to_f / 100
              blk.proc_private_aud_rec({},command_c)
        when /ords$/
              case tbldata["srctblname"] 
              when  /puracts/ #
                    strsql = %Q&
                        select ord.srctblname,ord.srctblid from linktbls ord 
                              where ord.tblname = 'puracts' and ord.tblid =  #{tbldata["srctblid"]}
                              and ord.srctblname = 'purords'
                              group by ord.srctblname,ord.srctblid 
                      union
                        select ord.srctblname,ord.srctblid from linktbls ord 
                              inner join linktbls inst on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                              where inst.tblname = 'puracts' and inst.tblid =  #{tbldata["srctblid"]}
                              and (ord.tblname = 'purinsts' or ord.tblname = 'purreplyinputs' or ord.tblname = 'purdlvs') 
                              and ord.srctblname = 'purords'
                              group by ord.srctblname,ord.srctblid 
                      union
                        select ord.srctblname,ord.srctblid from linktbls ord 
                              inner join (select i.* from linktbls i 
                                                inner join linktbls j on i.tblname = j.srctblname and i.tblid = j.srctblid
                                                where j.tblname = 'puracts' and j.tblid =  #{tbldata["srctblid"]}
                                                and (i.tblname != j.srctblname or i.tblid != j.srctblid)
                                                and ( j.srctblname = 'purreplyinputs' or j.srctblname = 'purdlvs') ) inst
                                on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                              where (ord.tblname = 'purinsts' or ord.tblname = 'purreplyinputs') 
                              and ord.srctblname = 'purords'
                              group by ord.srctblname,ord.srctblid 
                      union
                        select ord.srctblname,ord.srctblid from linktbls ord 
                              inner join (select i.* from linktbls i 
                                                inner join (select x.* from linktbls x
                                                                  inner join linktbls y  on x.tblname = y.srctblname and x.tblid = y.srctblid
                                                              where x.tblname = 'puracts' and x.tblid =  #{tbldata["srctblid"]}
                                                              and  y.srctblname = 'purdlvs') j
                                                on i.tblname = j.srctblname and i.tblid = j.srctblid
                                                where   j.srctblname = 'purreplyinputs' or j.srctblname = 'purinsts' ) inst
                                on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                              where (ord.tblname = 'purinsts' or ord.tblname = 'purreplyinputs') 
                              and ord.srctblname = 'purords'
                              group by ord.srctblname,ord.srctblid 
                          &
              when /custacts/
                        strsql = %Q&
                            select ord.srctblname,ord.srctblid from linkcusts ord 
                                where ord.tblname = 'custacts' and ord.tblid =  #{tbldata["srctblid"]}
                                and ord.srctblname = 'custords'
                              group by ord.srctblname,ord.srctblid 
                          union
                            select ord.srctblname,ord.srctblid from linkcusts ord 
                                inner join linkcusts inst on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                                where inst.tblname = 'custacts' and inst.tblid =  #{tbldata["srctblid"]}
                                and (ord.tblname = 'custinsts' or ord.tblname = 'custdlvs') 
                                and ord.srctblname = 'custords'
                              group by ord.srctblname,ord.srctblid 
                          union
                            select ord.srctblname,ord.srctblid from linkcusts ord 
                                inner join (select i.* from linkcusts i 
                                                inner join linkcusts j on i.tblname = j.srctblname and i.tblid = j.srctblid
                                                where j.tblname = 'custacts' and j.tblid =  #{tbldata["srctblid"]}
                                                and j.srctblname = 'custdlvs') inst
                                  on ord.tblname = inst.srctblname and ord.tblid = inst.srctblid
                                where ord.tblname = 'custinsts'   and ord.srctblname = 'custords'
                              group by ord.srctblname,ord.srctblid 
                            &
              end
              prevtblname = tblname.sub("ord","sch")  ###tbldata["srctblname"]--> puracts custacts
              tmp_amt =  tbldata["amt_src"].to_f
              ActiveRecord::Base.connection.select_all(strsql).each do |trnord|
                strsql = %Q&
                      select * from #{prevtblname} where id in(
                                      select tblid from srctbllinks where srctblid = #{trnord["srctblid"]}
                                                  and srctblname = '#{case tblname 
                                                                        when /payords/
                                                                              "purords"
                                                                        when  /billords/
                                                                              "custords"
                                                                        end}' and tblname = '#{prevtblname}'
                                    )
                &
                blk = RorBlkCtl::BlkClass.new("r_#{prevtblname}")
                command_c = blk.command_init
                command_c["sio_classname"] = "_update_from_#{tblname}"
                command_c["#{prevtblname.chop}_person_id_upd"] = tbldata["persons_id_upd"]
                ActiveRecord::Base.connection.select_all(strsql).each do |prevtbldata|
                  command_c["id"] = command_c["#{prevtblname.chop}_id"]= prevtbldata["id"]
                  if tmp_amt <= prevtbldata["amt_sch"].to_f 
                    command_c["#{prevtblname.chop}_amt_sch"] = prevtbldata["amt_sch"].to_f - tmp_amt
                    command_c["#{prevtblname.chop}_tax"] = command_c["#{prevtblname.chop}_amt_sch"] * prevtbldata["taxrate"].to_f / 100
                    tmp_amt -= prevtbldata["amt_sch"].to_f
                  else
                    next
                  end
                  blk.proc_private_aud_rec({},command_c)
                end
              end
        end
        return  
  end
end
