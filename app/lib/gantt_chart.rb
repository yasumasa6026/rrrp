# -*- coding: utf-8 -*-
# 2099/12/31を修正する時は　2100/01/01の修正も
module GanttChart
    extend self
	class GanttClass
		def initialize(buttonflg,tbl)
			@bgantts = {}  ###全体のtree構造　keyは階層レベル
      @ngantts = []  ###親直下の子ども処理用
			@level = tbl  ###itm or trn:gantt(reverse)
			@err = false
			@base = @level
      @buttonflg = buttonflg
      @gateOpeitmsId = {}  ##gate,runner用
		end

    def proc_get_ganttchart_data(mst_code,id)   ###opeims_idはある。
      @chkcnt = 0
        	time_now =  Time.now
			case mst_code
			when /itms/
				@max_time = Time.now.strftime("%Y-%m-%d")
				@min_time = Time.now.strftime("%Y-%m-%d")
				@bgantts[@base] = {:itm_code=>"",:itm_name=>"全行程",:processseq=>"",:loca_code=>"",:loca_name=>"",:opeitms_id=>"0",
												:parenum=>"親員数",:chilnum=>"子員数",:type=>"project",
												:depend => [""],:id=>"000"}
        ###
        ### vrec 先頭のレコードを取得する。
        ### その後、vrecの内容を元に、@nganttsに格納する。
        ### @nganttsの内容は、get_ganttchart_recで展開する。
        ### その後、@nganttsの内容を@bganttsに格納する。  
        ### @bganttsの内容は、最終的にganttchart_controllerに渡す。  
        ###
        case mst_code
				  when "opeitms"
		 				vrec = ActiveRecord::Base.connection.select_one("select * from r_opeitms where opeitm_id = #{id} and opeitm_Expiredate > current_date")
		    	when "itms"
						  case @buttonflg
						    when /gantt/
                        vrec = ActiveRecord::Base.connection.select_one("select * from r_opeitms 
                                where opeitm_itm_id = #{id} and opeitm_Expiredate > current_date
																order by opeitm_processseq  desc, opeitm_priority desc")
                when /reverse/
                        vrec = ActiveRecord::Base.connection.select_one("select * from r_opeitms 
                                where opeitm_itm_id = #{id} and opeitm_Expiredate > current_date
																order by opeitm_processseq  , opeitm_priority desc")
              end                                       
            if vrec.nil?
              vrec = ActiveRecord::Base.connection.select_one("select * from r_itms where id = #{id} and itm_Expiredate > current_date")
              if vrec
                vrec["nditm_itm_id_nditm"] = vrec["itm_id"]  
                vrec["nditm_processseq_nditm"] = "999"
              end
            end
				  when "nditms"
					  vrec = ActiveRecord::Base.connection.select_one("select * from r_nditms where id = #{id} and nditm_Expiredate > current_date")
				  else
				end
				if vrec then
					case mst_code
					  when /^opeitms|^itms/
              if vrec["opeitm_id"].nil?
                @ngantts << {
                  :itms_id_pare=>vrec["itm_id"],:processseq_pare=>"999",	
                  :itms_id=>vrec["itm_id"],:locas_id=>"0",:locas_id_to=>"0",:opeitms_id=>"0",
                  :itm_code=>vrec["itm_code"],:itm_name=>vrec["itm_name"],:qty=>1,:depend => [],:type=>"task",
                  :loca_code=>nil,:loca_name=>nil,:parenum=>1,:chilnum=>1,
                  :duration=>0,:unitofduration=>0,
                  :prdpur=>"dym",:shelfnos_id =>"0",
                  :processseq=>"999",:priority=>"999",
                  :start=>@min_time,:duedate=>@max_time,:id=>@level+ format('%03d',id.to_i)}  ###:id=>ganttのkey
              else
						    @ngantts << {	
                    :itms_id_pare=>vrec["opeitm_itm_id"],:processseq_pare=>"#{if mst_code =~ /^itms/ then '999' else  vrec["opeitm_processseq"] end}",	  
                    :itms_id=>vrec["opeitm_itm_id"],:locas_id=>vrec["shelfno_loca_id_shelfno_opeitm"],:opeitms_id=>vrec["opeitm_id"],
										:itm_code=>vrec["itm_code"],:itm_name=>vrec["itm_name"],:qty=>1,:depend => [],:type=>"task",
										:loca_code=>vrec["locas_code_shelfno"],:loca_name=>vrec["locas_name"],:parenum=>1,:chilnum=>1,
                    :locas_id=>vrec["shelfno_loca_id_shelfno_opeitm"],:locas_id_to=>vrec["shelfno_loca_id_to_shelfno_opeitm"],
										:duration=>vrec["opeitm_duration"],:unitofduration=>vrec["opeitm_unitofduration"],
										:prdpur=>vrec["opeitm_prdpur"],:shelfnos_id =>vrec["opeitm_shelfno_id_opeitm"],
										:processseq=>"#{if mst_code =~ /^itms/ then '999' else  vrec["opeitm_processseq"] end}",
										:priority=>"#{if mst_code =~ /^itms/ then '999' else vrec["opeitm_priority"] end}",
										:start=>@min_time,:duedate=>@max_time,:id=>@level+ format('%03d',id.to_i)}  ###:id=>ganttのkey
              end
					  when "nditms"
						  case @buttonflg
						    when /gantt/
								  @ngantts << {	
                    :itms_id_pare=>vrec["opeitm_itm_id"],:processseq_pare=>vrec["opeitm_processseq"],
                    :itms_id=>vrec["opeitm_itm_id"],
                    :locas_id=>vrec["shelfno_loca_id_shelfno_opeitm"],:locas_id_to=>vrec["shelfno_loca_id_to_shelfno_opeitm"],
                    :type=>"task",
										:opeitms_id=>vrec["nditm_opeitm_id"],:itm_code=>vrec["itm_code"],:itm_name=>vrec["itm_name"],:qty=>1,
										:loca_code=>vrec["locas_code_shelfno"],:loca_name=>vrec["locas_name_shelfno"],:depend => [],
										:parenum=>1,:chilnum=>1,:prdpur=>vrec["opeitm_prdpur"],:shelfnos_id =>vrec["opeitm_shelfno_id_opeitm"],
										:duration=>vrec["opeitm_duration"],:unitofduration=>vrec["opeitm_unitofduration"],
										:processseq=>vrec["opeitm_processseq"],:priority=>vrec["opeitm_priority"],
										:start=>@min_time,:duedate=>@max_time,:id=>@level+format('%03d',id.to_i)}  ###:id=>
						    when /reverse/
								  opx = ActiveRecord::Base.connection.select_one("
                              select opx.*,shelf.locas_id_shelfno locas_id
                                  from opxitms opx
																	inner join shelfnos shelf on shelf.id = opx.shelfnos_id_opxitm 
																	where opx.itms_id = #{vrec["nditm_itm_id_nditm"]} 
																	  and opx.processseq = #{vrec["nditm_processseq_nditm"]}
																	  and opx.priority = 999
																	  and opx.Expiredate > current_date")
								  if opx
									  @ngantts << {	
                      :itms_id_pare=>opx["itms_id"],	:processseq_pare=>opx["processseq"],
                      :itms_id=>opx["itms_id"],:locas_id=>opx["locas_id"],:type=>"task",
										  :opxitms_id=>opx["id"],:qty=>1,:depend => [],:parenum=>1,:chilnum=>1,
										  :duration=>opx["duration"],:unitofduration=>opx["unitofduration"],
										  :prdpur=>opx["prdpur"],:shelfnos_id =>opx["shelfnos_id_opxitm"],
										  :processseq=>opx["processseq"],:priority=>opx["priority"],
										  :start=>@max_time,:duedate=>@min_time,:id=>@level+format('%03d',opx["id"].to_i)}  ###:
								  else
									  @ngantts << {
                      :itms_id_pare=>vrec["nditm_itm_id_nditm"],:processseq_pare=>"999",
                      :itms_id=>vrec["nditm_itm_id_nditm"],:locas_id=>"0",:type=>"task",
										  :opxitms_id=>"0",:qty=>1,:depend => [],:parenum=>1,:chilnum=>1,:shelfnos_id =>"0",
										  :duration=>1,:unitofduration=>"DAY ",
										  :prdpur=>"dym",
										  :processseq=>999,:priority=>999,
										  :start=>@max_time,:duedate=>@min_time,:id=>@level+format('%03d',0)}  ###:
								  end
						  end
					end
					cnt = 0
					@bgantts[@ngantts[0][:id]] = @ngantts[0]
          nd =  {"duration"=> @ngantts[0][:duration].to_f,"unitofduration"=> @ngantts[0][:unitofdvs],
                  "itms_id"=> @ngantts[0][:itms_id],"processseq" =>@ngantts[0][:processseq]}
          parent = {"starttime" =>@ngantts[0][:start],"duedate" =>@ngantts[0][:duedate]} 
          tblnamechop = @ngantts[0][:prdpur] + "sch"
          case tblnamechop 
            when "pursch"
              suppliers_id = ActiveRecord::Base.connection.select_value(%Q&select id from suppliers where locas_id_supplier = #{@ngantts[0][:locas_id]}&)
              tmp_com = {"#{tblnamechop}_duedate" => @max_time,"#{tblnamechop}_supplier_id" => suppliers_id,
                          "shelfno_loca_id_shelfno" => @ngantts[0][:locas_id]}
            when "prdsch"
              tmp_com = {"#{tblnamechop}_duedate" => @max_time,
                          "#{tblnamechop}_shelfno_id" => @ngantts[0][:shelfnos_id],"shelfno_loca_id_shelfno" => @ngantts[0][:locas_id]}
            else
              tmp_com = {"#{tblnamechop}_duedate" => @max_time,"#{tblnamechop}_shelfno_id" =>@ngantts[0][:shelfnos_id],
                          "shelfno_loca_id_shelfno" => @ngantts[0][:locas_id]}
          end
          ###Rails.logger.debug("class:#{self},line:#{__LINE__},\n tmp_com:#{tmp_com}")
          tmp_com,message = CtlFields.proc_field_starttime(tblnamechop,tmp_com,parent,nd)
          ###Rails.logger.debug("class:#{self},line:#{__LINE__},\n tmp_com:#{tmp_com}")
          @ngantts[0][:start] = tmp_com["#{tblnamechop}_starttime"]
          case @buttonflg
          when /gantt/
					  until @ngantts.size == 0
						  cnt += 1
						  n0 = @ngantts.shift
						  @level = n0[:id] and n0[:opeitms_id] != "0" and n0[:opeitms_id] != Constants::NilOpeitmsId 
              if n0.size > 0  ###子部品がいなかったとき{}になる。
							    get_ganttchart_rec(n0)
						  end
						  break if cnt >= 1000
					  end
          else  ##get_reverse_chart_rec
            until @ngantts.size == 0
              cnt += 1
              n0 = @ngantts.shift
              @level = n0[:id]
              if n0.size > 0  ###子部品がいなかったとき{}になる。
                  get_reverse_chart_rec(n0)
              end
              break if cnt >= 1000
            end
          end
				else
					raise "#{Time.now} #{__LINE__} logic err #{mst_code},#{id},#{@buttonflg}"
				end
			when /prd|pur|cust/
				@bgantts[@base] = {:itm_code=>"",:itm_name=>"全行程",:loca_code=>"",:loca_name=>"",:opeitms_id=>"0",
												:start =>  Constants::EndDate,:duedate => Constants::BeginnigDate,
												:type=>"project",:depend => [""],:id=>@level}
				trget = ActiveRecord::Base.connection.select_one(%Q&select * from #{mst_code} where id = #{id}&)
				@bgantts[@base][:tblname] = mst_code
				@bgantts[@base][:sno] = trget["sno"]
					###一度登録した trnganttsのtblname,tblidに変更はない。
				@max_time = trget["duedate"]
				@min_time = trget["starttime"]
				case mst_code
				  when /purords|prdords|purschs|prdschs/
					  strsql =	%Q&
									select  max(trn.itms_id_trn) itms_id_trn,max(s.locas_id_shelfno) locas_id_trn,max(trn.orgtblname) orgtblname,
											max(trn.orgtblid) orgtblid,max(trn.paretblname) paretblname,max(trn.paretblid) paretblid,
											a.srctblname linktblname,a.srctblid linktblid,
											a.srctblname tblname,a.srctblid tblid,
											max(trn.parenum) parenum,max(trn.chilnum) chilnum,max(trn.processseq_trn) processseq_trn,
											min(trn.starttime_trn) starttime_trn,max(trn.duedate_trn) duedate_trn,
											sum(a.qty_linkto_alloctbl) qty_src,max(trn.id) trngantts_id ,max(trn.key) "key"
										from trngantts trn
										inner join alloctbls a  on a.trngantts_id = trn.id  and a.qty_linkto_alloctbl > 0 
										inner join shelfnos s on s.id = trn.shelfnos_id_trn 
										inner join opeitms ope  on trn.itms_id_trn = ope.itms_id and trn.processseq_trn = ope.processseq
																	and ope.priority = 999
									where a.srctblname = '#{mst_code}' and a.srctblid = #{id}
									group by a.srctblname ,a.srctblid 
								& 
					  if trget["remark"] =~ /create by mkord/  and @buttonflg =~ /gantt/ ###mkprdpurordsで作成
					    ###
              #
              ###
					  else
						  ActiveRecord::Base.connection.select_all(strsql).each_with_index do |trn,idx|
							  n0 = {:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
									:depend => [],
									:linktblname=>trn["linktblname"],:linktblid=>trn["linktblid"],
									:tblname=>trn["tblname"],:tblid=>trn["tblid"],:trngantts_id=>trn["trngantts_id"],
									:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
									:paretblname=>trn["paretblname"],:paretblid=>trn["paretblid"],
									:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],
									:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],									
									:qty =>case  trn["tblname"]
										when  /acts|dlvs|schs|shpests/
											0
										else	 
								 			trn["qty_src"].to_f
										end,
									:qty_sch =>case  trn["tblname"]
										when  /schs|ests/
											trn["qty_src"].to_f
										else	 
											0
										end,
									:qty_stk =>case  trn["tblname"]
										when  /acts|dlvs/
											trn["qty_src"].to_f
										else	 
											0
										end,
									:id=> @level + trn["key"]  }
							  n0 = get_item_loca_contents(n0) 
							  @ngantts << n0
							  if @max_time < n0[:duedate]
								  @max_time = n0[:duedate]
							  end
							  if @min_time > n0[:start]
								  @min_time = n0[:start]
							  end
						  end
            end
				  when /custschs|custords/  ###custords,custschs単独の時　custordsがcustschsを引き当てた時
					  strsql = %Q&
									select trn.itms_id_trn,s.locas_id_shelfno locas_id_trn,
											trn.orgtblname,trn.orgtblid,trn.paretblname,trn.paretblid,
											trn.tblname,trn.tblid,
											trn.parenum,trn.chilnum,trn.processseq_trn,trn.starttime_trn,trn.duedate_trn,
											trn.id trngantts_id ,trn.qty_sch,trn.qty,trn.qty_stk
										from trngantts trn 
										inner join shelfnos s on s.id = trn.shelfnos_id_trn  
										where  trn.tblid = #{id} and trn.tblname = '#{mst_code}' --- -->画面でclickされたtableのid
							&
					  trn = ActiveRecord::Base.connection.select_one(strsql)
            if  mst_code =~ /custords$/   ### #{parse_linedata["custord_id"]} 
              strsql = %Q&
                      select ord.qty_src ord_qty,0 inst_qty,0 dlv_qty,0 act_qty ,'custords' targettbl,ord.tblid targetid from linkcusts ord
                        where ord.tblname = 'custords' and  ord.srctblname = 'custords'
                       and ord.tblid = #{id}  
                    union
                      select 0 ord_qty,inst.qty_src inst_qty,0 dlv_qty,0 act_qtyv,'custinsts' targettbl,inst.tblid targetid from linkcusts ord
                        inner join linkcusts inst on ord.tblid = inst.srctblid and ord.tblname = inst.srctblname 
                        where ord.tblname = 'custords' and inst.tblname = 'custinsts' and inst.srctblname = 'custords'
                       and ord.tblid = #{id}  
                    union --- custords =>custdlvs custinsts 無
                      select 0 ord_qty,0 inst_qty,dlv.qty_src dlv_qty,0 act_qty,'custdlvs' targettbl,dlv.tblid targetid from linkcusts ord
                        inner join linkcusts dlv on ord.tblid = dlv.srctblid and ord.tblname = dlv.srctblname 
                        where ord.tblname = 'custords' and dlv.tblname = 'custdlvs' and dlv.srctblname = 'custords'
                       and ord.tblid = #{id} 
                    union --- custords =>custacts 　custinsts,custdlvs 無
                      select 0 ord_qty,0 inst_qty,0 dlv_qty,act.qty_src act_qty,'custacts' targettbl,act.tblid targetid from linkcusts ord
                        inner join linkcusts act on ord.tblid = act.srctblid and ord.tblname = act.srctblname 
                        where ord.tblname = 'custords' and act.tblname = 'custacts' and act.srctblname = 'custords'
                       and ord.tblid = #{id}  
                    union
                      select 0 ord_qty,0 inst_qty,dlv.qty_src dlv_qty,0 act_qty,'custdlvs' targettbl,dlv.tblid targetid from linkcusts ord
                        inner join linkcusts dlv on ord.tblid = dlv.srctblid and ord.tblname = dlv.srctblname 
                        where ord.srctblname = 'custords' and ord.tblname = 'custinsts' 
                         and dlv.srctblname = 'custinsts' and dlv.tblname = 'custdlvs'  
                         and ord.srctblid = #{id} 
                    union --- custords=>custinsts=>custacts   custdlvs 無
                      select 0 ord_qty,0 inst_qty,0 dlv_qty,act.qty_src act_qty,'custacts' ,act.tblid targetid from linkcusts ord
                        inner join linkcusts act on ord.tblid = act.srctblid and  ord.tblname = act.srctblname
                        where ord.srctblname = 'custords'and ord.tblname = 'custinsts' 
                            and act.tblname = 'custacts'  and act.srctblname = 'custinsts' 
                            and ord.srctblid = #{id} 
                    union
                      select 0 ord_qty,0 inst_qty,0 dlv_qty,dlv.act_qty_src act_qty,'custacts' targettbl,dlv.tblid targetid from linkcusts ord
                            inner join (select dlv.srctblname,dlv.srctblid,act.qty_src act_qty_src,dlv.qty_src ,act.tblid from  linkcusts dlv 
                                              inner  join linkcusts act on dlv.tblid = act.srctblid and act.srctblname = 'custdlvs' and act.tblname = 'custacts' ) 
                                        dlv on dlv.srctblid = ord.tblid and ord.tblname =  dlv.srctblname
                        where ord.srctblname = 'custords' and ord.tblname = 'custinsts'
                         and ord.srctblid = #{id}
              &
              ord_qty = inst_qty = dlv_qty = act_qty = 0
              target = {}
              recs = ActiveRecord::Base.connection.select_all(strsql)
              recs.each do |rec|
                ord_qty += rec["ord_qty"].to_f
                inst_qty += rec["inst_qty"].to_f 
                dlv_qty += rec["dlv_qty"].to_f
                act_qty += rec["act_qty"].to_f  
                target[rec["targettbl"]] = rec["targetid"]                          
              end
              if act_qty >= ord_qty
                top = {"tblname" => "custacts","tblid" => target["custacts"]}
              else
                if dlv_qty >= ord_qty
                  top = {"tblname" => "custdlvs","tblid" => target["custdlvs"]}
                else
                  if inst_qty >= ord_qty
                    top = {"tblname" => "custinsts","tblid" => target["custinsts"]}
                  else
                    top = {"tblname" => "custords","tblid" => target["custords"]}
                  end
                end
              end
              ###custords
              n0 = 	{:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
                  :depend => [],
                  :tblname=>top["tblname"],:tblid=>top["tblid"],:trngantts_id=>trn["id"],
                  :linktblname=>trn["tblname"],:linktblid=>trn["tblid"],
                  :orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
                  :paretblname=>trn["paretblname"],:paretblid=>trn["paretblid"],
                  :parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],
                  :start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],
                  :qty_sch =>trn["qty_sch"].to_f ,:qty =>ord_qty + inst_qty ,:qty_stk=>dlv_qty + act_qty,
                  :id=>@level + "000" } 
            else
              n0 = 	{:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
                  :depend => [],
                  :tblname=>trn["tblname"],:tblid=>trn["tblid"],:trngantts_id=>trn["id"],
                  :linktblname=>trn["tblname"],:linktblid=>trn["tblid"],
                  :orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
                  :paretblname=>trn["paretblname"],:paretblid=>trn["paretblid"],
                  :parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],
                  :start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],
                  :qty_sch =>trn["qty_sch"].to_f ,:qty =>trn["qty"].to_f ,:qty_stk=>trn["qty_stk"].to_f,
                  :id=>@level + "000" } 
            end   					
					  strsql =	%Q&
							  	---  custordsがcustschsを引き当てた時
								--- org=pare=tblの子供org=pareの時　pare:tblは1:1
								select trn.mlevel ,trn.itms_id_trn,s.locas_id_shelfno locas_id_trn,
										trn.orgtblname,trn.orgtblid,trn.paretblname,trn.paretblid,
										trn.parenum,trn.chilnum,trn.processseq_trn,trn.starttime_trn,trn.duedate_trn,
										l.tblname tblname,l.tblid tblid, trn.alloc_tblname,trn.alloc_tblid, 
										custsch.srctblname linktblname,custsch.srctblid linktblid,---次への引継ぎ
										l.qty_src,trn.id trngantts_id
									from (select t.*,a.srctblname alloc_tblname,a.srctblid alloc_tblid from trngantts t
														inner join alloctbls a 
														on t.id = a.trngantts_id )   trn  ---  custschs
										inner join linkcusts l on l.srctblid = trn.paretblid
										inner join shelfnos s on s.id = trn.shelfnos_id_trn  
										inner join (select a.srctblname,srctblid  from trngantts t 
													inner join alloctbls a on t.id = a.trngantts_id
														and a.qty_linkto_alloctbl > 0 
														and t.mlevel = '1' and t.paretblname = 'custschs') custsch
													on trn.alloc_tblname = custsch.srctblname and  trn.alloc_tblid = custsch.srctblid  
									where l.tblname = 'custords' and l.tblid =  #{n0[:linktblid]} 
										and l.qty_src > 0 and ( l.tblname != l.srctblname or l.tblid !=  l.srctblid)
										and trn.paretblname = 'custschs' and l.tblname = 'custords'
										and trn.mlevel = 1
									& 	
					  custschs = ActiveRecord::Base.connection.select_all(strsql)
					  n1 =[]
					  custschs.each_with_index do |custsch,idx|
						  ###gantt_id = n0[:id] + "1" + format('%02d',idx)
						  n1[idx] =   {:itms_id=>custsch["itms_id_trn"],:locas_id=>custsch["locas_id_trn"],:type=>"task",
									:depend => [],
									:qty_sch =>0 ,:qty =>custsch["qty_src"].to_f ,:qty_stk =>0 ,
									:orgtblname=>custsch["orgtblname"],:orgtblid=>custsch["orgtblid"],
									:paretblname => custsch["paretblname"],:paretblid => custsch["paretblid"],
									:tblname=>custsch["linktblname"],:tblid=>custsch["linktblid"],
									:linktblname=>custsch["linktblname"],:linktblid=>custsch["linktblid"],
									:trngantts_id=>custsch["trngantts_id"],  ###trngantts.tblnameは変化している。
									:parenum=>custsch["parenum"],:chilnum=>custsch["chilnum"],:processseq=>custsch["processseq_trn"],
									:start=>custsch["starttime_trn"],:duedate=>custsch["duedate_trn"],:id=>n0[:id].to_s + "1" + format('%02d',idx)}  
						  n0[:depend] << n0[:id].to_s + "1" + format('%02d',idx)
						  if @max_time < n1[idx][:duedate]
								@max_time = n1[idx][:duedate]
						  end
						  if @min_time > n1[idx][:start]
								@min_time = n1[idx][:start]
						  end
					  end
					  n0 = get_item_loca_contents(n0)
					  if n1.size > 0 
						  @bgantts[n0[:id]] = n0
						  n1.each do |nx|
							  @ngantts << nx
						  end
					  else 
						  n0[:depend]  << (n0[:id].to_s + "001")
						  @bgantts[n0[:id]] = n0
						  strsql = %Q&
										select trn.itms_id_trn,s.locas_id_shelfno locas_id_trn,
												trn.orgtblname,trn.orgtblid,trn.paretblname,trn.paretblid,
												a.srctblname tblname,a.srctblid tblid,
												trn.parenum,trn.chilnum,trn.processseq_trn,trn.starttime_trn,trn.duedate_trn,
												trn.id trngantts_id ,trn.qty_sch,trn.qty,trn.qty_stk,(a.qty_linkto_alloctbl) qty_src
												from trngantts trn 
											inner join alloctbls a on a.trngantts_id = trn.id
											inner join shelfnos s on s.id = trn.shelfnos_id_trn  
											where  trn.paretblid = #{id} and trn.paretblname = '#{mst_code}' --- -->画面でclickされたtableのid
											and a.qty_linkto_alloctbl > 0
											and (trn.paretblname != trn.tblname or trn.paretblid != trn.tblid)
								&
						  trn = ActiveRecord::Base.connection.select_one(strsql)
						  n0 = 	{:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
									:depend => [],
									:linktblname=>trn["tblname"],:linktblid=>trn["tblid"],
									:tblname=>trn["tblname"],:tblid=>trn["tblid"],:trngantts_id=>trn["id"],
									:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
									:paretblname=>trn["paretblname"],:paretblid=>trn["paretblid"],
									:parenum=>1,:chilnum=>1,:processseq=>trn["processseq_trn"],
									:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],									
									:qty =>case  trn["tblname"]
										when  /acts|dlvs|schs|ests/
											0
										else	 
								 			trn["qty_src"].to_f
										end,
									:qty_sch =>case  trn["tblname"]
										when  /schs|ests/
											trn["qty_src"].to_f
										else	 
											0
										end,
									:qty_stk =>case  trn["tblname"]
										when  /acts|dlvs/
											trn["qty_src"].to_f
										else	 
											0
										end,
									:id=>@level + "001" } 
									
						  n0 = get_item_loca_contents(n0) 
						  @ngantts << n0
					  end
				end
				reverse_linkid = {}
				### pur,pur,custxxxの時　　itms,opitms,nditmsはget_ganttchart_recで展開
				until @ngantts.size == 0   ###子部品の展開
					ngantt = @ngantts.shift
					@bgantts[ngantt[:id]] = ngantt
					case @buttonflg
					  when /gantt/  ###custschs,custordsは対象済
						  strsql =	%Q&
								select  max(trn.itms_id_trn) itms_id_trn,max(s.locas_id_shelfno) locas_id_trn,max(trn.orgtblname) orgtblname,
										max(trn.orgtblid) orgtblid,max(trn.paretblname) paretblname,max(trn.paretblid) paretblid,
										alloc.srctblname linktblname,alloc.srctblid linktblid,
										alloc.srctblname tblname,alloc.srctblid tblid,max(trn.itms_id_pare) itms_id_pare,
										max(trn.parenum) parenum,max(trn.chilnum) chilnum,max(trn.processseq_trn) processseq_trn,
										min(trn.starttime_trn) starttime_trn,max(trn.duedate_trn) duedate_trn,
										sum(alloc.qty_linkto_alloctbl) qty_src,max(trn.id) trngantts_id ,max(trn.key) "key"
									from trngantts trn
									inner join (select orgtblname ,tblname,orgtblid,tblid,t.id,
														a.srctblname ,a.srctblid ,a.qty_linkto_alloctbl 
														from trngantts t 
													inner join alloctbls a on a.trngantts_id  = t.id  
													where  a.srctblname = '#{ngantt[:linktblname]}' and a.srctblid = #{ngantt[:linktblid]}
															and a.qty_linkto_alloctbl > 0 
                              and t.orgtblname = '#{mst_code}' and t.orgtblid = #{id}) pare 
										on trn.orgtblname = pare.orgtblname and trn.paretblname = pare.tblname
																and trn.orgtblid = pare.orgtblid and trn.paretblid = pare.tblid
									inner join alloctbls alloc on alloc.trngantts_id = trn.id
																and alloc.qty_linkto_alloctbl > 0
									inner join shelfnos s on s.id = trn.shelfnos_id_trn
								where (trn.tblname != trn.paretblname or trn.tblid != trn.paretblid) 
                and trn.orgtblname = '#{mst_code}' and trn.orgtblid = #{id} 
								group by alloc.srctblname ,alloc.srctblid 
									& 
					  else  ###custschs,custordsはganttのみ
						  strsql = %Q&
								select  max(trn.itms_id_pare) itms_id_trn,max(s.locas_id_shelfno) locas_id_trn,max(trn.orgtblname) orgtblname,
										max(trn.orgtblid) orgtblid,max(trn.paretblname) paretblname,max(trn.paretblid) paretblid,
										pare.srctblname tblname,pare.srctblid tblid,max(trn.itms_id_pare) itms_id_pare,
										pare.srctblname linktblname,pare.srctblid linktblid,
										max(trn.parenum) parenum,max(trn.chilnum) chilnum,max(trn.processseq_pare) processseq_trn,
										min(trn.starttime_pare) starttime_trn,max(trn.duedate_pare) duedate_trn,
										sum(pare.qty_linkto_alloctbl) qty_src,max(pare.id) trngantts_id ,max(trn.key) "key"
											from trngantts trn
											inner join (select orgtblname ,tblname,orgtblid,tblid,t.id,
																a.srctblname ,a.srctblid ,a.qty_linkto_alloctbl 
																from trngantts t 
															inner join alloctbls a on a.trngantts_id  = t.id  and a.qty_linkto_alloctbl > 0 ) pare 
												on trn.orgtblname = pare.orgtblname and trn.paretblname = pare.tblname
																		and trn.orgtblid = pare.orgtblid and trn.paretblid = pare.tblid
											inner join alloctbls alloc on alloc.trngantts_id = trn.id
											inner join shelfnos s on s.id = trn.shelfnos_id_trn
										where alloc.srctblname = '#{ngantt[:linktblname]}' and alloc.srctblid = #{ngantt[:linktblid]}
											and (trn.tblname != trn.paretblname or trn.tblid != trn.paretblid)
											and alloc.qty_linkto_alloctbl > 0 
										group by pare.srctblname ,pare.srctblid 
							union	---  custords										
								select  (trn.itms_id_pare) itms_id_trn,max(s.locas_id_shelfno) locas_id_trn,(trn.orgtblname) orgtblname,
										(trn.orgtblid) orgtblid,(trn.paretblname) paretblname,(trn.paretblid) paretblid,
										trn.paretblname tblname,trn.paretblid tblid,max(trn.itms_id_pare) itms_id_pare,
										pare.srctblname linktblname,pare.srctblid linktblid,
										(trn.parenum) parenum,(trn.chilnum) chilnum,(trn.processseq_pare) processseq_trn,
										min(trn.starttime_pare) starttime_trn,max(trn.duedate_pare) duedate_trn,
										sum(pare.qty_src) qty_src,(pare.id) trngantts_id ,max(trn.key) "key"
											from trngantts trn
											inner join (select t.orgtblname ,t.tblname,orgtblid,t.tblid,t.id,
																l.srctblname ,l.srctblid ,l.qty_src 
																from trngantts t 
															inner join linkcusts l  on l.trngantts_id  = t.id  and l.srctblid = t.tblid  
															and l.qty_src > 0) pare 
												on trn.orgtblname = pare.orgtblname and trn.paretblname = pare.tblname
																		and trn.orgtblid = pare.orgtblid and trn.paretblid = pare.tblid		
										
										inner join alloctbls alloc on alloc.trngantts_id = trn.id
										inner join shelfnos s on s.id = trn.shelfnos_id_trn
										where alloc.srctblname = '#{ngantt[:linktblname]}' and alloc.srctblid = #{ngantt[:linktblid]}
											and (trn.tblname != trn.paretblname or trn.tblid != trn.paretblid) 
										group by  (trn.itms_id_pare) ,(trn.orgtblname) ,
										(trn.orgtblid) ,(trn.paretblname) ,(trn.paretblid) ,
										trn.paretblname ,trn.paretblid ,
										pare.srctblname ,pare.srctblid ,
										(trn.parenum) ,(trn.chilnum) ,(trn.processseq_pare) ,(pare.id)  
							union  ---  custordsがcustschsを引き当てた時
									--- org=pare=tblの子供org=pareの時　pare:tblは1:1
								select trn.itms_id_trn, s.locas_id_shelfno locas_id_trn,
										trn.orgtblname,	trn.orgtblid,trn.paretblname,trn.paretblid,
										trn.tblname ,trn.tblid,max(trn.itms_id_pare) itms_id_pare,
										'' linktblname ,0 linktblid,
										trn.parenum,trn.chilnum,trn.processseq_trn,
										trn.starttime_trn,trn.duedate_trn,
										l.qty_src,trn.id trngantts_id,max(trn.key) "key"
									from trngantts trn
									inner join shelfnos s on s.id = trn.shelfnos_id_trn 
									inner join linkcusts l on l.tblname = trn.tblname and  l.tblid = trn.tblid
										where l.srctblname = '#{ngantt[:linktblname]}' and l.srctblid = #{ngantt[:linktblid]} 
											and l.qty_src > 0 and ( l.tblname != l.srctblname or l.tblid !=  l.srctblid)
						    & 
					end
					n0 = {}
					ActiveRecord::Base.connection.select_all(strsql).each_with_index do |trn,idx|
						###gantt_id = @level + trn["key"] ### format('%03d',idx)
						n0 =   {:itms_id=>trn["itms_id_trn"],:locas_id=>trn["locas_id_trn"],:type=>"task",
								:depend => [],
								:qty =>case  trn["tblname"]
										when  /acts|dlvs|schs|ests/
											0
										else	 
											 trn["qty_src"].to_f
										end,
								:qty_sch =>case  trn["tblname"]
											when  /schs|ests/
												trn["qty_src"].to_f
											else	 
												0
											end,
								:qty_stk =>case  trn["tblname"]
											when  /acts|dlvs/
												trn["qty_src"].to_f
											else	 
												0
											end,
								:orgtblname=>trn["orgtblname"],:orgtblid=>trn["orgtblid"],
								:paretblname => trn["paretblname"],:paretblid => trn["paretblid"],
								:tblname=>trn["tblname"],:tblid=>trn["tblid"],
								:linktblname=>trn["linktblname"],:linktblid=>trn["linktblid"],
								:trngantts_id=>trn["trngantts_id"],  ###trngantts.tblnameは変化している。
								:parenum=>trn["parenum"],:chilnum=>trn["chilnum"],:processseq=>trn["processseq_trn"],
								:start=>trn["starttime_trn"],:duedate=>trn["duedate_trn"],
                :id=>@level + "002" + trn["key"] + idx.to_s} 
						if @buttonflg =~ /gantt/
							if trn["tblname"] =~ /^prd|^pur|^cust/
								@bgantts[ngantt[:id]][:depend] << n0[:id]  ###親のgantt_idを依存に追加
              else
              	if trn["tblname"] =~ /^con/  ###trngantts.tblname="conschs"になるのはgate runnerの時のみ
								  @bgantts[ngantt[:id]][:depend] << @level + "002" + trn["key"]
                   ###gateの所要量はkey= 'xxxx00000'に集約されている
                  strsql = %Q&
                          select t.key from trngantts t
                                  inner join (select gate.* from trngantts gate
							                         inner join trngantts run on run.tblname = gate.paretblname  and run.tblid = gate.paretblid   
									 				                                        and run.orgtblname = gate.orgtblname  and run.orgtblid = gate.orgtblid   
                                     where run.orgtblid = #{trn["orgtblid"]} and run.itms_id_trn = #{trn["itms_id_trn"]}
                                       and run.processseq_trn = #{trn["processseq_trn"]}) g 
                                    on  g.orgtblid = t.orgtblid and g.itms_id_trn = t.itms_id_trn
                                       and g.processseq_trn = t.processseq_trn
                                  where t.qty_sch > 0 or t.qty > 0 &
                  gatekey = ActiveRecord::Base.connection.select_value(strsql)
                  n0[:depend] << (@level + "002" + gatekey + "0")
                end
              end
						else
							n0[:depend] << ngantt[:id]
						end
						n0 = get_item_loca_contents(n0) 
						@ngantts << n0
						if @max_time < n0[:duedate]
							@max_time = n0[:duedate]
						end
						if @min_time > n0[:start]
							@min_time = n0[:start]
						end
					end
				end
			end
      @bgantts[@base][:duedate] = @max_time
    	@bgantts[@base][:start] = @min_time
     	## opeitmのsubtblidのopeitmは子のinsert用
				###	 Rails.logger.debug  "line,#{__LINE__} ,@bgantts:#{@bgantts} "
			return @bgantts
    end

		def get_item_loca_contents(n0)   ##n0[:itms_id] r0[:itms_id]
			  ###:autocreate_instは画面にはセットしない。
				if n0[:itm_code].nil? 
				  		itm = ActiveRecord::Base.connection.select_one("select * from itms where id = #{n0[:itms_id]}  ")
						n0[:itm_code] = itm["code"]
						n0[:itm_name] = itm["name"]
				end
				case n0[:tblname] 
				when /^prd/  
					strsql = %Q&
						select * from #{n0[:tblname]} tbl
							inner join shelfnos shelf on shelf.id = tbl.shelfnos_id
							where tbl.id = #{n0[:tblid]}
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					if tbl["code"] !=  "000"  ### 000-->same as locas
						n0[:loca_code] = tbl["code"]
						n0[:loca_name] = tbl["name"]
					else
						loca = ActiveRecord::Base.connection.select_one("select * from locas where id = #{tbl["locas_id_shelfno"]}")
						n0[:loca_code] = loca["code"]
						n0[:loca_name] = loca["name"]
					end 
				when /^con/  
					strsql = %Q&
						select * from #{n0[:tblname]} tbl
							inner join shelfnos shelf on shelf.id = tbl.shelfnos_id_fm
							where tbl.id = #{n0[:tblid]}
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					if tbl["code"] !=  "000"  ### 000-->same as locas
						n0[:loca_code] = tbl["code"]
						n0[:loca_name] = tbl["name"]
					else
						loca = ActiveRecord::Base.connection.select_one("select * from locas where id = #{tbl["locas_id_shelfno"]}")
						n0[:loca_code] = loca["code"]
						n0[:loca_name] = loca["name"]
					end 
				when /^dvs/  
					strsql = %Q&
						select tbl.code fcode,tbl.name fname,s.code scode,s.name sname from facilities tbl
									inner join shelfnos s on s.id = tbl.shelfnos_id 	
									inner join  #{n0[:tblname]} dvs on tbl.id = dvs.facilities_id where dvs.id = #{n0[:tblid]} 
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					n0[:loca_code] = tbl["scode"]
					n0[:loca_name] = tbl["sname"]
					n0[:itm_code] = tbl["fcode"]
					n0[:itm_name] = tbl["sname"]
					n0[:processseq] = ""
				when /^erc/  
					strsql = %Q&
						select erc.processname,c.code,c.name from fcoperators f
									inner join (select ch.id,code,name from chrgs ch
															inner join persons p on p.id = ch.persons_id_chrg)   
												c on c.id = f.chrgs_id_fcoperator 	
									inner join  #{n0[:tblname]} erc on f.id = erc.fcoperators_id where erc.id = #{n0[:tblid]} 
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					n0[:loca_code] = tbl["code"]
					n0[:loca_name] = tbl["name"]
					n0[:itm_code] = tbl["processname"]
					n0[:itm_name] = ""
					n0[:processseq] = ""
				when /^pur/ 
					strsql = %Q&
						select * from #{n0[:tblname]} tbl
							inner join (select l.code ,l.name,s.id supp_id from locas l 
												inner join suppliers s on s.locas_id_supplier = l.id) supp on tbl.suppliers_id = supp.supp_id 
							where tbl.id = #{n0[:tblid]}
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					n0[:loca_code] = tbl["code"]
					n0[:loca_name] = tbl["name"]
				when /^cust/ 
					strsql = %Q&
						select * from #{n0[:linktblname]} tbl
							inner join (select l.code ,l.name,c.id custs_id from locas l 
												inner join custs c on c.locas_id_cust = l.id) cust on tbl.custs_id = cust.custs_id 
							where tbl.id = #{n0[:linktblid]}
					&
					tbl =  ActiveRecord::Base.connection.select_one(strsql)
					n0[:loca_code] = tbl["code"]
					n0[:loca_name] = tbl["name"]
				else
					if n0[:loca_code].nil?
					  	loca = ActiveRecord::Base.connection.select_one("select * from locas where id = #{n0[:locas_id]}  ")
						n0[:loca_code] = loca["code"]
						n0[:loca_name] = loca["name"]
					end
				end
				if @level =~ /trn/
            case n0[:tblname]
            when /puracts/
              strsql = %Q& select link.srctblname,link.srctblid from linktbls link
                                  inner join alloctbls alloc on alloc.srctblname = link.tblname and alloc.srctblid = link.tblid
                                              and alloc.trngantts_id = link.trngantts_id 
                                  where link.tblname = '#{n0[:tblname]}' and link.tblid = #{n0[:tblid]}
                                  and alloc.qty_linkto_alloctbl > 0 &
              prevtbl = ActiveRecord::Base.connection.select_one(strsql)
              strsql =  %Q& select * from #{prevtbl["srctblname"]} where id = #{prevtbl["srctblid"]} &
              prevtbldata = ActiveRecord::Base.connection.select_one(strsql)
							rec = ActiveRecord::Base.connection.select_one("select * from #{n0[:tblname]} where id = #{n0[:tblid]}")
              dvstbl = ActiveRecord::Base.connection.select_one(strsql)
            when /prdacts/
							rec = ActiveRecord::Base.connection.select_one("select * from #{n0[:tblname]} where id = #{n0[:tblid]}")
						when  /^custdlvs|^custacts|^dym|^dvs|^shp|^erc/ 
							rec = ActiveRecord::Base.connection.select_one("select * from #{n0[:tblname]} where id = #{n0[:tblid]}")
						else
							rec = tbl.dup  ###prd/purの時
						end
						n0[:sno] = rec["sno"]
						case n0[:tblname] 
						when /^shpinsts|^shpacts/  
							n0[:duedate] = rec["rcptdate"]
							n0[:start] = rec["depdate"] 
						when /^shpests/  
							n0[:duedate] = rec["duedate"]
							n0[:start] = rec["depdate"] 
						when /^shp/  
							n0[:duedate] = rec["depdate"]
							n0[:start] = rec["depdate"] 
            when /purdlvs$/
							n0[:duedate] = rec["depdate"]
							n0[:start] = prevtbldata["isudate"] 
            when /^puracts/
							n0[:duedate] = rec["rcptdate"]
							n0[:start] = prevtbldata["isudate"] 
            when /^custacts/
							n0[:duedate] = rec["saledate"]
							n0[:start] = tbl["isudate"] 
            when /^custdlvs/
							n0[:duedate] = rec["depdate"]
							n0[:start] = tbl["isudate"] 
						when /^prdacts/
							n0[:duedate] = rec["cmpldate"]
							n0[:start] = rec["starttime"]
            when /^ercacts|^dvsacts/
							n0[:duedate] = (rec["cmpldate"]||=rec["duedate"])  ###duedate? rcptdate? cmpldate?
							n0[:start] = (rec["commencementdate"]||=rec["starttime"])
            when /^ercords|^dvsords|^ercinsts|^dvsinsts/
							n0[:duedate] = rec["duedate"]  ###duedate? rcptdate? cmpldate?
							n0[:start] = (rec["commencementdate"]||=rec["starttime"])
            when /^con/
							n0[:duedate] = rec["duedate"]  ###duedate? rcptdate? cmpldate?
							n0[:start] = (rec["duedate"].to_date - 1).strftime("%Y-%m-%d %H:%M:%S")  ###conは前日開始
						else
							n0[:duedate] = rec["duedate"]  ###duedate? rcptdate? cmpldate?
							n0[:start] = rec["starttime"]
						end
						if n0[:start] < n0[:duedate]
								n0[:delay] = false
                n0[:depend].split(",").each do |dep|
                  if @bgantts[dep] && @bgantts[dep][:duedate] > n0[:start]
                    @bgantts[dep][:delay] = true
                  end
                end
						else
								n0[:delay] = true
						end
				else
				end
			  	@min_time = n0[:start] if (@min_time||=n0[:start]) > n0[:start]
			  	@max_time = n0[:duedate] if (@max_time||= n0[:duedate])  < n0[:duedate]
				###n0 = n0
			return n0
		end
		
		def get_ganttchart_rec(n0)  ###工程の始まり=前工程の終わり nditms,opeitms,itms用
			##strsql = "select * from r_nditms where nditm_opeitm_id = #{n0[:opeitms_id]} 
			###			and nditm_Expiredate > current_date order by itm_code_nditm "
			###rnditms = ActiveRecord::Base.connection.select_all(strsql)
      ##n0:親の情報
      ###   {:itms_id=>,:locas_id=>,:type=>"task",
			### 	:opeitms_id=>,:qty=>,:depend => [],:parenum=>,:chilnum=>,:duration=>,:unitofduration=>,:prdpur=>,
			###							:processseq=>999,:priority=>999,
			###		:start=>,:duedate=>,:id=>@level+format('%03d',0)} 
			depend = []
			###duedate = n0[:start]   ###親のduedateは子のstarttime
			###ActiveRecord::Base.connection.select_all(strsql).each_with_index  do |rec,idx|  ###子部品
			ActiveRecord::Base.connection.select_all(ArelCtl.proc_nditmSql(n0[:opeitms_id])).each_with_index  do |rec,idx|  ###子部品
        nditms_contents_set(n0,rec,idx,depend)
			end
				###depend = get_prev_process(n0,duedate,depend)  ###前工程 nditmsに含まれる。
			@bgantts[n0[:id]][:depend].concat(depend.dup)   ###親の依存を調べる。
		end
		
		def get_reverse_chart_rec(n0)  ###工程の始まり=前工程の終わり nditms,opeitms,itms用
			##strsql = "select * from r_nditms where nditm_opeitm_id = #{n0[:opeitms_id]} 
			###			and nditm_Expiredate > current_date order by itm_code_nditm "
			###rnditms = ActiveRecord::Base.connection.select_all(strsql)
			###ActiveRecord::Base.connection.select_all(strsql).each_with_index  do |rec,idx|  ###子部品
      if n0[:prdpur] =~ /pur|prd/
			  ActiveRecord::Base.connection.select_all(ArelCtl.proc_reverse_nditmSql(n0[:itms_id_pare],n0[:processseq_pare])).each_with_index  do |rec,idx|  ###子部品
          nditms_contents_set(n0,rec,idx,[])
			  end
      end
		end
			
    def nditms_contents_set(n0,rec,idx,depend)
				###ope = get_opeitms_id_from_itm_by_processseq(rec["itms_id"],rec["processseq"])
        ###new_start = (duedate.to_time - (rec["opeitm_duration"].to_i) * 24 * 60 * 60).strftime("%Y-%m-%d %H:%M:%S") 
      if  @buttonflg =~ /reverse/  
        rec["chilnum"].to_f == 0 ? rec["chilnum"] = 1 : rec["chilnum"] = rec["chilnum"].to_f
        new_qty = n0[:qty].to_f / rec["chilnum"].to_f * rec["parenum"].to_f
      else
        rec["parenum"].to_f == 0 ? rec["parenum"] = 1 : rec["parenum"] = rec["parenum"].to_f
        new_qty = n0[:qty].to_f * rec["chilnum"].to_f / rec["parenum"]
      end
      nlevel = @level +  format('%03d',idx)
      contents = {:opeitms_id=>rec["opeitms_id"],:processseq=>rec["processseq"],
          ###:start=>start,:duedate=>duedate,  ###startはget_item_loca_contentsでset
          :duration=>rec["duration"],:unitofduration=>rec["unitofduration"],:id=>nlevel,:type=>"task",
          :parenum=>rec["parenum"],:chilnum=>rec["chilnum"],:qty=>new_qty,
          :itms_id=>rec["itms_id"],:itm_code=>rec["itm_code_nditm"],:itm_name=>rec["itm_name_nditm"],
          :itms_id_pare=>rec["itms_id_pare"],:processseq_pare=>rec["processseq_pare"],
          :classlist_code=>rec["classlist_code"],:prdpur=>rec["prdpur"],
          :shelfnos_id_pare =>rec["shelfnos_id_pare"],:shelfnos_id_to_pare =>rec["shelfnos_id_to_pare"],
          :locas_id=>rec["locas_id"],:loca_code=>rec["locas_code"],:loca_name=>rec["locas_name"],:shelfnos_id=>rec["shelfnos_id"],:depend=>[],
          :locas_id_to=>rec["locas_id_to"],:loca_code_to=>rec["locas_code_to"],:loca_name_to=>rec["locas_name_to"],:shelfnos_id_to=>rec["shelfnos_id_to"]}
      case rec["prdpur"]
        when /pur|prd/
              tblnamechop = rec["prdpur"] + "sch"
              nd =  {"duration"=>rec["duration"].to_f,"unitofduration"=>rec["unitofdvs"],
                      "shelfnos_id" => rec["shelfnos_id"],
                      "itms_id"=>rec["itms_id"],"processseq" => rec["processseq"]}
              if @buttonflg =~ /reverse/  ##
                parent = {"duedate" => n0[:duedate],"starttime" => n0[:start],"shelfnos_id" =>n0[:shelfnos_id_pare]}  ###dvs,ercの時利用 必須
                case tblnamechop 
                  when "pursch"  ###カレンダーのlocas_idは専用のloca_idを使用する。
                    suppliers_id = ActiveRecord::Base.connection.select_value(%Q&select id from suppliers where locas_id_supplier = #{contents[:locas_id]}&)
                    tmp_com = {"#{tblnamechop}_supplier_id" => suppliers_id,"#{tblnamechop}_duedate" =>n0[:duedate],
                                  "#{tblnamechop}_shelfno_id_to" => rec["shelfnos_id_to"],"shelfno_loca_id_shelfno_to"=> rec["locas_id_to"]}
                  when "prdsch"
                    tmp_com = {"shelfno_loca_id_shelfno" => contents[:locas_id],"#{tblnamechop}_duedate" =>n0[:duedate],
                                "#{tblnamechop}_shelfno_id" => rec["shelfnos_id"],"shelfno_loca_id_shelfno_to"=> rec["locas_id_to"]}
                  else
                    tmp_com = {"#{tblnamechop}_shelfno_id_to" => rec["shelfnos_id_to"],"#{tblnamechop}_duedate" =>n0[:duedate],
                                 "#{tblnamechop}_loca_id" => rec["locas_id"], "shelfno_loca_id_shelfno_to"=> rec["locas_id_to"]}   
                end 
                nd["duration"] = nd["duration"]  * -1 ###逆転開示の時、durationはマイナス proc_field_duedateは親のstarttimeから求めるので使用
                CtlFields.proc_field_starttime(tblnamechop,tmp_com,parent,nd)  
                contents[:duedate] = tmp_com["#{tblnamechop}_starttime"]
                contents[:start] =  n0[:duedate]
                contents[:depend] << n0[:id]
                @bgantts[nlevel] = contents.dup	
                @ngantts << contents
                if tblnamechop =="prdsch"  ###逆転開示の時、装置、金型、工具、人員対応
                  ActiveRecord::Base.connection.select_all(ArelCtl.proc_nditmSql(rec["opeitms_id"])).each_with_index  do |children,idx|  ###子部品
                      next if children["prdpur"] =~ /pur|prd|dym/
                      nditms_contents_set(contents,children,idx,depend)       
                  end
                end
              else  ###通常の時 ganttの時
                parent = {"duedate" => n0[:duedate],"starttime" => n0[:start],"shelfnos_id" =>rec["shelfnos_id_pare"]}
                case tblnamechop 
                  when "pursch"  ###カレンダーのlocas_idは専用のloca_idを使用する。
                    suppliers_id = ActiveRecord::Base.connection.select_value(%Q&select id from suppliers where locas_id_supplier = #{contents[:locas_id]}&)
                    tmp_com = {"#{tblnamechop}_supplier_id" => suppliers_id,"#{tblnamechop}_duedate" =>n0[:start],
                                  "#{tblnamechop}_shelfno_id_to" => rec["shelfnos_id_to"],"shelfno_loca_id_shelfno_to"=> rec["locas_id_to"]}
                  when "prdsch"
                    tmp_com = {"shelfno_loca_id_shelfno" => contents[:locas_id],"#{tblnamechop}_duedate" =>n0[:start],
                                "#{tblnamechop}_shelfno_id" => rec["shelfnos_id"],"shelfno_loca_id_shelfno_to"=> rec["locas_id_to"]}
                  else
                    tmp_com = {"#{tblnamechop}_shelfno_id_to" => rec["shelfnos_id_to"],"#{tblnamechop}_duedate" =>n0[:start],
                                 "#{tblnamechop}_loca_id" => rec["locas_id"], "shelfno_loca_id_shelfno_to"=> rec["locas_id_to"]}   
                end 
                ###nd["duration"] = nd["duration"]  * -1 ###逆転開示の時、durationはマイナス proc_field_duedateは親のstarttimeから求めるので使用
                tmp_com,message = CtlFields.proc_field_starttime(tblnamechop,tmp_com,parent,nd)
                contents[:start] = tmp_com["#{tblnamechop}_starttime"]
                contents[:duedate] =  n0[:start]
                depend << nlevel
                @bgantts[nlevel] = contents.dup	
                @ngantts << contents
              end
        when /BYP|run/  ###副産物、runner
          ### reverse の時は考慮できない
          contents[:start] = n0[:start]
          contents[:duedate] = n0[:start]
          strsql = %Q%select op.* from nditms nd 
                                 inner join (select o.*,
                                                      s.locas_id,s.locas_code,s.locas_name,s.shelfnos_id,
                                                      xto.locas_id_to,xto.locas_code_to,xto.locas_name_to,xto.shelfnos_id_to,
                                                      i.code itm_code,i.name itm_name
                                                    from opeitms o 
                                                    inner join (select l1.id locas_id,l1.code locas_code,l1.name locas_name,s1.id shelfnos_id
                                                                    from shelfnos s1
                                                                    inner join locas l1  on s1.locas_id_shelfno = l1.id)s on o.shelfnos_id_opeitm = s.shelfnos_id
                                                    inner join  (select l2.id locas_id_to,l2.code locas_code_to,l2.name locas_name_to,s2.id shelfnos_id_to
                                                                    from shelfnos s2
                                                                    inner join locas l2  on s2.locas_id_shelfno = l2.id)xto on o.shelfnos_id_to_opeitm = xto.shelfnos_id_to
                                                    inner join itms i on i.id = o.itms_id) op on op.id = nd.opeitms_id
                                  where nd.itms_id_nditm = #{rec["itms_id"]} and nd.processseq_nditm = #{rec["processseq"]}
                                      and nd.consumtype in('BYP','run') and op.priority = 999%
          opeitm = ActiveRecord::Base.connection.select_one(strsql)
          if opeitm
              gate_contents = {:opeitms_id=>opeitm["id"],:processseq=>opeitm["processseq"],
                          :duration=>opeitm["duration"],:unitofduration=>opeitm["unitofduration"],:type=>"task",  ###id 存在check
                          :parenum=>"1",:chilnum=>"1",:qty=>new_qty,:cnt => 0,
                          :itms_id=>opeitm["itms_id"],:itm_code=>opeitm["itm_code"],:itm_name=>opeitm["itm_name"],
                          :itms_id_pare=>rec["itms_id_nditm"],:processseq_pare=>rec["processseq_nditm"],
                          :classlist_code=>rec["classlist_code"],:prdpur=>opeitm["prdpur"],
                          :shelfnos_id_pare =>rec["shelfnos_id_pare"],:shelfnos_id_to_pare =>rec["shelfnos_id_to_pare"],
                          :locas_id=>opeitm["locas_id"],:loca_code=>opeitm["locas_code"],:loca_name=>opeitm["locas_name"],:shelfnos_id=>opeitm["shelfnos_id"],:depend=>[],
                          :locas_id_to=>rec["locas_id"],:loca_code_to=>rec["locas_code"],:loca_name_to=>rec["locas_name"],:shelfnos_id_to=>rec["shelfnos_id"]}
            if @gateOpeitmsId[opeitm["id"]]  ###gateは登録済
              base_nlevel = @gateOpeitmsId[opeitm["id"]][:base_nlevel] ###gate用id
              cnt = @gateOpeitmsId[opeitm["id"]][:cnt] + 1 
              @gateOpeitmsId[opeitm["id"]][:cnt] = cnt
              runner_nlevel =  base_nlevel + "run" + format('%03d',cnt)
              contents.merge!({:id=>runner_nlevel})
              depend << runner_nlevel
              contents[:depend] <<  @gateOpeitmsId[opeitm["id"]][:id]
              @ngantts << contents
              @bgantts[runner_nlevel] = contents.dup
            else
              gate_nlevel = @level + opeitm["id"].to_s + "run999" ###gate用id
              gate_contents.merge!({:id=> gate_nlevel,:base_nlevel=>@level + opeitm["id"]})
              @gateOpeitmsId[opeitm["id"]] = gate_contents
              contents[:id] = @level  + opeitm["id"].to_s + "run000" ###gate用id
              contents[:depend] << gate_nlevel
              depend << contents[:id]
              @ngantts << contents
              @bgantts[contents[:id]] = contents
              nd =  {"duration"=>opeitm["duration"].to_f,"unitofduration"=>opeitm["unitofdvs"],
                      "shelfnos_id" => opeitm["shelfnos_id"],
                      "itms_id"=>opeitm["itms_id"],"processseq" => opeitm["processseq"]}
              parent = {"duedate" => n0[:duedate],"starttime" => n0[:start],"shelfnos_id" =>rec["shelfnos_id"]}
              tmp_com = {"shelfno_loca_id_shelfno" =>gate_contents[:locas_id],"prdsch_duedate" =>n0[:start],
                                "prdsch_shelfno_id" => opeitm["shelfnos_id"],"shelfno_loca_id_shelfno_to"=> opeitm["locas_id_to"]}
              tmp_com,message = CtlFields.proc_field_starttime("prdsch",tmp_com,parent,nd)
              gate_contents[:start] = tmp_com["prdsch_starttime"]
              gate_contents[:duedate] = n0[:start]
              @ngantts << gate_contents
              @bgantts[gate_contents[:id]] = gate_contents.dup
            end
          else
						 raise" calss:#{self},line:#{__LINE__},gate runner error strsql:#{strsql}"
          end
      else
        rec["opeitms_id"] ||= Constants::NilOpeitmsId
        rec["processseq"] ||= ""
        case rec["classlist_code"]
        when "ITool","mold" ###工具、金型
            contents[:start] = n0[:start]
            contents[:duedate] = n0[:duedate]
            strsql = %Q&
              select s.code loca_code_shelfno,s.name loca_name_shelfno,l.shelfnos_id
                from lotstkhists l
                inner join shelfnos s on s.id = l.shelfnos_id
                where l.itms_id = #{rec["itms_id"]} and processseq = #{rec["processseq"]}
                and l.qty_stk > 0
                and not exists(select 1 from lotstkhists xx where l.itms_id = xx.itms_id and l.processseq = xx.processseq
                          and xx.qty_stk <= 0 and xx.starttime > l.starttime)
                order by l.starttime
              &
            sh = ActiveRecord::Base.connection.select_one(strsql)
            if sh 
              child = {"shelfno_loca_id_shelfno"=>sh["shelfno_loca_id_shelfno"],"shelfnos_id" => sh["shelfnos_id"],
                        "loca_code_shelfno"=>sh["loca_code_shelfno"],"loca_name_shelfno"=>sh["loca_name_shelfno"]}
            else
              child = {"shelfno_loca_id_shelfno"=>0,"loca_code_shelfno"=>"dummy","loca_name_shelfno"=>"dummy","shelfnos_id" => 0} 
            end
            nlevel = @level +  format('%03d',idx)
            contents.merge!({:id=>nlevel,:locas_id=>child["shelfno_loca_id_shelfno"],:loca_code=>child["loca_code_shelfno"],
                            :loca_name=>child["loca_name_shelfno"]})
            if  (rec["changeoverlt"].to_f > 0)
                nd =  {"duration"=>(rec["changeoverlt"]).to_f,"unitofduration"=>rec["unitofdvs"],
                        "shelnos_id_fm" => child["shelfnos_id"],"shelfnod_id_to" => n0[:shelfnos_id],
                        "itms_id"=>rec["itms_id"],"processseq" => rec["processseq"]}
                  tmp_com = {"shpsch_duedate" =>  n0[:start],
                              "shpsch_shelfno_id_fm" => child["shelfnos_id"],"shelfno_loca_id_shelfno_to" => n0[:locas_id_to]}
                  parent = {"duedate" => n0[:start],"starttime" => n0[:start],"shelfnos_id" =>n0[:shelfnos_id_pare]}
                  tmp_com ,message = CtlFields.proc_field_starttime("shpsch",tmp_com,parent,nd)
                  contents[:start] = tmp_com["shpsch_depdate"]
            end
            if  (rec["postprocessinglt"].to_f > 0 )
                nd =  {"duration"=>(rec["postprocessinglt"]||=0).to_f,"unitofduration"=>rec["unitofdvs"],
                        "shelnos_id_fm" => child["shelfnos_id"],"shelnos_id_to" => n0[:shelfnos_id],
                        "itms_id"=>rec["itms_id"],"processseq" => rec["processseq"]}
                  tmp_com = {"shpsch_duedate" =>  n0[:start],
                                "shpsch_shelfno_id_fm" => child["shelfnos_id"],"shelfno_loca_id_shelfno_to" => n0[:loca_id_to]}
                  parent = {"duedate" => n0[:duedate],"starttime" => n0[:duedate],"shelfnos_id" =>n0[:shelfnos_id_pare]}
                  tmp_com ,message = CtlFields.proc_field_duedate("shpsch",tmp_com,parent,nd)
                  contents[:duedate] = tmp_com["shpsch_duedate"]
            end
            # if  @buttonflg =~ /reverse/
            #   contents[:depend] << n0[:id]
            # else
            #   depend << nlevel
            # end
            @bgantts[nlevel] = contents.dup	
        when "apparatus"   ###装置
            contents[:start] = n0[:start]
            contents[:duedate] = n0[:duedate]
            nlevel = @level +  format('%03d',idx)
            parent = {"duedate" => n0[:duedate],"starttime" => n0[:start],"shelfnos_id" =>n0[:shelfnos_id_pare]}
            contents.merge!({:id=>nlevel,:locas_id=>"",:loca_code=>"",:loca_name=>""})
            facilities_id = ActiveRecord::Base.connection.select_value(%Q& select id from facilities where itms_id = #{rec["itms_id"]} &)
            nd =  {"duration"=>(rec["changeoverlt"]).to_f,"unitofduration"=>rec["unitofdvs"],
                    "itms_id"=>rec["itms_id"],"processseq" => rec["processseq"]}
            if  (rec["changeoverlt"].to_f > 0)  ###事前処理
                tmp_com = {"dvssch_duedate" => n0[:start],"dvssch_starttime" => n0[:start],"shelfno_loca_id_shelfno_to" => n0[:locas_id_to],
                          "dvssch_shelfno_id_fm" => rec["shelfnos_id"],"dvssch_facilitie_id" => facilities_id}
                tmp_com ,message = CtlFields.proc_field_starttime("dvssch",tmp_com,parent,nd)
                contents[:start] = tmp_com["dvssch_starttime"]
            end
            if  (rec["postprocessinglt"].to_f > 0 )
                nd =  {"duration"=>(rec["postprocessinglt"]).to_f,"unitofduration"=>rec["unitofdvs"]}
                tmp_com = {"dvssch_duedate" => n0[:duedate],"dvssch_starttime" => n0[:duedate],
                          "dvssch_shelfno_id_fm" => rec["shelfnos_id"],"dvssch_facilitie_id" => facilities_id,
                          "dvssch_shelfno_id_to" => n0[:shelfnos_id],"shelfno_loca_id_shelfno_to" => n0[:locas_id_to]}
                tmp_com ,message  = CtlFields.proc_field_duedate("dvssch",tmp_com,parent,nd)
                contents[:duedate] = tmp_com["dvssch_duedate"]
            end
            # if  @buttonflg =~ /reverse/
            #   contents[:depend] << n0[:id]
            # else
            #   depend << nlevel
            # end
            @bgantts[nlevel] = contents.dup	
            ###
            # 装置処理　終わり
            #
            # 作業者処理　始まり
            # 作業者は構成にない ので、親の開始時間を引き継ぐ。
            save_nlevel = nlevel
            strsql = %Q&  --- from master when ercxxxs
                select f.id,itm_code_fcoperator,f.itm_name_fcoperator,f.person_code_chrg_fcoperator,f.person_name_chrg_fcoperator,
                    p.persons_id_chrg persons_id_chrg
                    from  r_fcoperators f 
                    inner join chrgs p on p.id = f.fcoperator_chrg_id_fcoperator
                    where f.fcoperator_itm_id_fcoperator = #{rec["itms_id"]}
                    order by f.fcoperator_priority desc
                &
            fcops = ActiveRecord::Base.connection.select_all(strsql) ###作業者は構成にない
            ["changeover","require","postprocess"].each do |processname|   ###前処理、処理、後処理 erc
                case processname
                when  "changeover" 
                  next if  (rec["changeoverlt"].to_f == 0 or rec["changeoverop"].to_f == 0)
                  contents[:start] = n0[:start]
                  contents[:duedate] = n0[:duedate]
                  fcops.each_with_index do |op,ii|
                      next if rec["changeoverop"].to_i <= ii
                      nlevel = (save_nlevel + "a" +  format('%02d',ii))
                      contents.merge!({:id=>nlevel,:loca_code=>op["person_code_chrg_fcoperator"],:classlist_code=>"changeover",
                                        :locas_id=>"",:loca_name=>op["person_name_chrg_fcoperator"]})
                      nd =  {"duration"=>(rec["changeoverlt"].to_f),"unitofduration"=>rec["unitofdvs"],
                            "itms_id"=>rec["itms_id"],"processseq" => rec["processseq"]}
                      parent = {"duedate" => n0[:start],"starttime" => n0[:start]}
                      tmp_com = {"ercsch_duedate" =>  n0[:start],"ercsch_shelfno_id_fm" => rec["shelfnos_id"],
                                  "shelfno_loca_id_shelfno_to" => n0[:locas_id],
                                "ercsch_processname" => processname,
                                "ercsch_person_id_chrg" => op["persons_id_chrg"],"ercsch_fcoperator_id" => op["persons_id_chrg"]}
                      tmp_com,message = CtlFields.proc_field_starttime("ercsch",tmp_com,parent,nd)
                      contents[:start] = tmp_com["ercsch_starttime"]
                      contents[:duedate] = n0[:start]
                      # if  @buttonflg =~ /reverse/
                      #   contents[:depend] << n0[:id]
                      # else
                      #   depend << nlevel
                      # end
                    @bgantts[nlevel] = contents.dup	
                  end
                when "require" 
                  contents[:start] = n0[:start]
                  contents[:duedate] = n0[:duedate]
                  fcops.each_with_index do |op,ii|
                    next if rec["requireop"].to_i <= ii
                    nlevel = (save_nlevel + "b" +  format('%02d',ii))
                    contents.merge!({:id=>nlevel,:loca_code=>op["person_code_chrg_fcoperator"],:classlist_code=>"require",
                                      :locas_id=>"",:loca_name=>op["person_name_chrg_fcoperator"]})
                    # if  @buttonflg =~ /reverse/
                    #   contents[:depend] << n0[:id]
                    # else
                    #   depend << nlevel
                    # end
                    @bgantts[nlevel] = contents.dup	
                  end
                when  "postprocess" 
                  next if  (rec["postprocessingop"].to_f == 0 or rec["postprocessinglt"].to_f == 0)
                  contents[:start] = n0[:start]
                  contents[:duedate] = n0[:duedate]
                  fcops.each_with_index do |op,ii|
                    nlevel = (save_nlevel + "c" +  format('%02d',ii))
                    contents.merge!({:id=>nlevel,:loca_code=>op["person_code_chrg_fcoperator"],:classlist_code=>"postprocess",
                                      :locas_id=>"",:loca_name=>op["person_name_chrg_fcoperator"]})
                    nd =  {"duration"=>(rec["postprocessinglt"].to_f),"unitofduration"=>rec["unitofdvs"]}
                    parent = {"duedate" => n0[:duedate],"starttime" => n0[:duedate],"shelfnos_id" =>n0[:shelfnos_id_pare]}
                    tmp_com = {"ercsch_starttime" => n0[:duedate],"ercsch_duedate" => n0[:duedate],
                                "ercsch_person_id_chrg" => op["persons_id_chrg"],"ercsch_fcoperator_id" => op["persons_id_chrg"],
                                "ercsch_processname" => processname,"ercsch_shelfno_id_fm" => rec["shelfnos_id"],
                                "ercsch_shelfno_id_to" => n0[:shelfnos_id],"shelfno_loca_id_shelfno_to" => n0[:locas_id]}  ###動かないので、親のlocas_idを使用
                    tmp_com ,message= CtlFields.proc_field_duedate("ercsch",tmp_com,parent,nd)
                    contents[:duedate] = tmp_com["ercsch_duedate"]
                    contents[:start] = n0[:duedate]
                    # if  @buttonflg =~ /reverse/
                    #   contents[:depend] << n0[:id]
                    # else
                    #   depend << nlevel
                    # end
                    @bgantts[nlevel] = contents.dup	
                  end
                end
                nlevel = save_nlevel
            end
        else
            nlevel = @level +  format('%03d',idx)
            contents.merge({:id=>nlevel,:locas_id=>"",:loca_code=>"dummy",:loca_name=>"dummy"})
            if @buttonflg =~ /reverse/
                contents[:depend] << n0[:id]
            else
              depend << nlevel
            end
            tblnamechop = "dymsch"
            nd =  {"duration"=>contents[:duration].to_f,"unitofduration"=>contents[:unitofduration],
                    "itms_id"=>rec["itms_id"],"processseq" => rec["processseq"]}
            parent = {"duedate" => n0[:duedate],"starttime" => n0[:start],"shelfnos_id" =>0}
            if  @buttonflg =~ /reverse/
              tmp_com = {"#{tblnamechop}_starttime" => n0[:duedate],"#{tblnamechop}_duedate" => n0[:duedate],
                            "#{tblnamechop}_shelfno_id_to" => 0,"shelfno_loca_id_shelfno_to" => 0}
              tmp_com ,message = CtlFields.proc_field_duedate("dymsch",tmp_com,parent,nd)
              contents[:duedate] = tmp_com["dymsch_duedate"]
              contents[:start] =n0[:duedate]
            else
              tmp_com = {"#{tblnamechop}_starttime" => n0[:start],"#{tblnamechop}_duedate" => n0[:start],
                        "#{tblnamechop}_loca_id" => 0,"#{tblnamechop}_shelfno_loca_id_shelfno_to" => 0}
              tmp_com,_message = CtlFields.proc_field_starttime("dymsch",tmp_com,parent,nd)
              contents[:start] = tmp_com["dymsch_starttime"]
              contents[:duedate] = n0[:start]
              @ngantts << contents
            end
            @bgantts[nlevel] = contents.dup	
        end
      end
      if @max_time < contents[:duedate]
        @max_time = contents[:duedate]
      end
      if @min_time > contents[:start]
        @min_time = contents[:start]
      end
    end
  
	  def get_opeitms_id_from_itm_by_processseq itms_id,processseq  ###
      strsql = %Q& select * from r_opeitms where opeitm_itm_id = #{itms_id} 
             and opeitm_processseq = #{processseq} and opeitm_priority = 999 and opeitm_expiredate > current_date &
      ope = ActiveRecord::Base.connection.select_one(strsql)
      return ope
    end

    def get_ordtbl_ordid tblname,tblid
      if tblname =~ /ords$/
        strsql %Q&select srctblname,srctblid from linktbls 
                  where tblname = '#{tblname} and tblid = #{tblid}		
        &
        ord = ActiveRecord::Base.connection.select_one(strsql)
        tblid = ord["srctblid"]
        tblname = ord["srctblname"]
      end	
      return tblname,tblid
    end
     
    def update_opeitm_from_gantt(copy_opeitm,value ,command_r)
      if copy_opeitm
        copy_opeitm.each do |k,v|
          command_r["#{k}"] = v if k =~ /^opeitm_/
        end
      end
      command_r["opeitm_itm_id"] = value[:itm_id]
      command_r["opeitm_loca_id_opeitm"] = value[:loca_id]
      command_r["sio_viewname"]  = command_r["sio_code"] = "r_opeitms"
      command_r["opeitm_priority"] = value[:priority]
      command_r["opeitm_processseq"] = value[:processseq]
      command_r["opeitm_prdpur"] = value[:prdpur]
      command_r["opeitm_parenum"] = value[:parenum]
      command_r["opeitm_chilnum"] = value[:chilnum]
      command_r["opeitm_duration"] = value[:duration]
      ### command_r["opeitm_person_id_upd"] = command_r["sio_user_code"]
      command_r["opeitm_expiredate"] = Time.parse( Constants::EndDate )
      yield
      proc_simple_sio_insert command_r  ###重複チェックは　params[:tasks][@tree[key]][:processseq] > value[:processseq]　が確定済なので不要
    end

	def update_nditm_from_gantt(key,value ,command_r)
		strsql = "select id from opeitms  
					where itms_id = #{params[:tasks][@tree[key]][:itm_id]} and 
					locas_id_shelfno = #{params[:tasks][@tree[key]][:shelfno_loca_id_shelfno_opeitm]} and
					processseq = #{params[:tasks][@tree[key]][:processseq]} and priority = #{params[:tasks][@tree[key]][:priority]}"
		pare_opeitm_id = ActiveRecord::Base.connection.select_value(strsql)
		if pare_opeitm_id
			###削除されてないか、再度確認
			yield
			update_nditm_rec(pare_opeitm_id,value ,command_r)
			##else
			##end
		else
			@ganttdata[key][:itm_name] = "opeitms is null line #{__LINE__} ,opeitm_id = #{pare_opeitm_id} "
			@err = true
		end
	end

	def chk_alreadt_exists_nditm(command_r)
		strsql = "select 1 from nditms where  opeitms_id = #{command_r["nditm_opeitm_id"]} and  itm_id_nditm = #{command_r["nditm_itm_id_nditm"]} and
					processseq_nditm = #{command_r["nditm_processseq_nditm"]} and   locas_id_nditm  = #{command_r["nditm_loca_id_nditm"]} "
		if ActiveRecord::Base.connection.select_one (strsql)
			@ganttdata[key][:itm_name] = " ??? !!! already exists !!!"
			@err= true
		end
	end
	def update_nditm_rec(pare_opeitm_id,value ,command_r)
		command_r["sio_viewname"]  = command_r["sio_code"] = "r_nditms"
		if value[:itm_id]
			command_r["nditm_itm_id_nditm"] = value[:itm_id]
			command_r["nditm_opeitm_id"] = pare_opeitm_id
			if value[:loca_id]
				command_r["nditm_loca_id_nditm"] = value[:loca_id]
				command_r["nditm_processseq_nditm"] = value[:processseq]
				command_r["nditm_expiredate"] = Constants::EndDate
				command_r["nditm_parenum"] = value[:parenum]
				command_r["nditm_chilnum"] = value[:chilnum]
				command_r["nditm_duration"] = value[:duration]
				command_r["nditm_expiredate"] = Time.parse( Constants::EndDate )
				chk_alreadt_exists_nditm(command_r) if command_r["sio_classname"] =~ /_add_/
				proc_simple_sio_insert command_r  if @err == false
			else
				@ganttdata[key][:loca_code] = "???" 
				@err = true
			end
		else
			@ganttdata[key][:itm_code] = "???"
			@err = true
		end
	end

  def exits_opeitm_from_gantt(key,value ,command_r) ###画面の内容をcommand_r from gantt screen
		###itm_codeでユニークにならない時内容が保証されない。  processseq,priorityは必須
		strsql = "select * from r_opeitms where itm_code = '#{value["copy_itemcode"]}' and opeitm_processseq = 999 and opeitm_priority = 999 "
		copy_opeitm = ActiveRecord::Base.connection.select_one(strsql)
		if value[:opeitms_id]
			opeitm = ActiveRecord::Base.connection.select_one("select * from opeitms where id = #{value[:opeitms_id]} ")
			if opeitm
				if opeitm["itms_id"].to_s == value[:itm_id] and opeitm["processseq"].to_s == value[:processseq] and opeitm["priority"].to_s == value[:priority]
					update_opeitm_from_gantt(copy_opeitm,value ,command_r) do
						command_r["sio_classname"] = "_edit_opeitms_rec"
						command_r["opeitm_id"] = command_r["id"] = opeitm["id"]
					end
				else
					strsql = "select * from r_opeitms where itm_code = '#{value["copy_itemcode"]}' and
										 loca_code_opeitm = '#{value["loca_code"]}' and opeitm_processseq = #{value[:processseq]} "
					if ActiveRecord::Base.connection.select_one(strsql)
						@ganttdata[key][:priority] = "???"  ###priority違いで同じものがいる。
					else
						update_opeitm_from_gantt(copy_opeitm,value ,command_r) do
							command_r["sio_classname"] = "_edit_opeitms_rec"
							command_r["opeitm_id"] = command_r["id"] = opeitm["id"]
						end
					end
				end
			else
				@ganttdata[key][:itm_name] = "logic error LINE : #{__LINE__}"
				@err = true
			end
		else
			if copy_opeitm
				update_opeitm_from_gantt(copy_opeitm,value ,command_r)do
					command_r["sio_classname"] = "_add_opeitm_rec"
					command_r["opeitm_id"] = command_r["id"] = ArelCtl.proc_get_nextval("opeitms_seq")
				end
				params[:tasks][key][:opeitms_id] = command_r["opeitm_id"]
			else
				@ganttdata[key][:copy_itemcode] = "???"
				@err = true
			end
		end
	end

  def exits_nditm_from_gantt(key,value ,command_r) ###画面の内容をcommand_r from gantt screen
		if value[:nditms_id]
			r_nditm = ActiveRecord::Base.connection.select_one("select * from r_nditms where id = #{value[:nditms_id]} ")
			if r_nditm
				update_nditm_from_gantt(key,value ,command_r) do
					command_r["sio_classname"] = "_edit_nditm_rec"
					command_r["nditm_id"] = command_r["id"] = value[:nditms_id]
				end
			else ###
				@ganttdata[key][:itm_name] = "logic error  line #{__LINE__} "
				@err = true
			end
		else
			update_nditm_from_gantt(key,value ,command_r) do
				command_r["sio_classname"] = "_add_nditm_rec"
				command_r["nditm_id"] = command_r["id"] = ArelCtl.proc_get_nextval("nditms_seq")
			end
		end
	end

	def chk_opeitm_nditm_from_gantt(key,value ,command_r)
		if @tree[key]
			if  params[:tasks][@tree[key]][:itm_code] == value[:itm_code]
				if params[:tasks][@tree[key]][:processseq] > value[:processseq]
					if (params[:tasks][@tree[key]][:priority] > value[:priority] and params[:tasks][@tree[key]][:priority] == 999) or params[:tasks][@tree[key]][:priority] == value[:priority]
						if value[:prdpur] =~ /^prd|^pur/  ### prd,pur,shp以外に増えたときの対応
							exits_opeitm_from_gantt(key,value ,command_r)
						else
							@ganttdata[key][:prdpur] = "???"
							@err = true
						end
					else ###作業の一貫性
						@ganttdata[key][:priority] = "???"
						@err = true
					end
				else  ###seq error
					@ganttdata[key][:processseq] = "???"
					@err = true
				end
			else   ###nditms追加
				if  value[:processseq] =~ /999|1000/  ###品目違いの時はprocessseq == 999
					value[:processseq] = "999"
					if (params[:tasks][@tree[key]][:priority] > value[:priority] and params[:tasks][@tree[key]][:priority] == 999) or params[:tasks][@tree[key]][:priority] == value[:priority]
						if value[:itm_id] != "" and value[:shelfno_loca_id_shelfno_opeitm] != ""
							strsql = "select id from opeitms where itms_id = #{value[:itm_id]} and 
																processseq = #{value[:processseq]} and priority = #{value[:priority]} "
							ope = ActiveRecord::Base.connection.select_one(strsql)
							if value[:prdpur] =~ /^prd|^pur/  ### prd,pur,shp以外に増えたときの対応
								if  ope.nil?
									strsql = "select * from r_opeitms where itm_code = '#{value["copy_itemcode"]}' and opeitm_processseq = 999 and
																			 opeitm_priority = 999 "
									copy_opeitm = ActiveRecord::Base.connection.select_one(strsql)
									if copy_opeitm
										update_opeitm_from_gantt(copy_opeitm,value ,command_r)do
											command_r["sio_classname"] = "_add_opeitm_rec"
											command_r["opeitm_id"] = command_r["id"] = ArelCtl.proc_get_nextval("opeitms_seq")
										end
										params[:tasks][key][:opeitms_id] = command_r["opeitm_id"]
										blk =  RorBlkCtl::BlkClass.new("r_nditms")
										command_r = blk.command_init
										command_r["sio_session_counter"] =   @sio_session_counter
										exits_nditm_from_gantt(key,value ,command_r)
									else
										@ganttdata[key][:copy_itemcode] = "???"
										@err = true
									end
								else
									exits_nditm_from_gantt(key,value ,command_r)
								end
							else
								@ganttdata[key][:prdpur] = "???"
								@err = true
							end
						else
							@ganttdata[key][:itm_code] = @ganttdata[key][:loca_code] = "???"
							@err = true
						end
					else ###作業の一貫性
						@ganttdata[key][:priority] = "???"
						@err = true 
					end
				else  ###seq error
					@ganttdata[key][:processseq] = "???"
					@err = true
				end
			end
		else
			### topの時
			if value[:processseq]  == "999"
				if  value[:priority]
					if value[:prdpur] =~ /^prd|^pur/  ### prd,pur,shp以外に増えたときの対応
						exits_opeitm_from_gantt(key,value ,command_r)
					else
						@ganttdata[key][:prdpur] = "???"
						@err = true
					end
				else ###作業の一貫性
					@ganttdata[key][:priority] = "???"
					@err = true
				end
			else  ###seq error
				@ganttdata[key][:processseq] = "???"
				@err = true
			end
		end
	end

	###
	###  nditmsのチェックができれば不要では？
	###
	def uploadgantt params  ### trnは別
		ActiveRecord::Base.connection.begin_db_transaction()
        params[:person_id_upd] =  ActiveRecord::Base.connection.select_value("select id from persons where email = '#{reqparams[:email]}'")   ###########   LOGIN USER
		@sio_session_counter = user_seq_nextval
		@ganttdata = params[:tasks]
		@err = false
		@tree = {}   ###親のid
        params[:tasks].each do |key,value|
			value[:depend].split(",").each do |i|  ###子の親は必ず1つ　副産物も子として扱う
				@tree[i] = key
			end
			case value[:id]
                when  "000" then
                ##top record
                   next
                when /gantttmp/  then ### レコード追加
					if value[:itm_id] and  value[:processseq] =~ /[000-1000]/ and value[:priority] =~ /[000-999]/
						blk =  RorBlkCtl::BlkClass.new("r_opeitms")
						command_r = blk.command_init
						chk_opeitm_nditm_from_gantt(key,value ,command_r)
					else
						if value[:itm_id].nil? then 
							@ganttdata[key][:itm_code] = "???"
							@err = true 
						end
						if value[:processseq] !~ /[000-1000]/  then 
							@ganttdata[key][:processseq]  = "???"
							@err = true
						end
						if value[:priority] !~ /[000-999]/ then 
							@ganttdata[key][:priority] = "???"
							@err = true 
						end
					end
                when /opeitms/   ###追加更新もある?\
					params[:tasks][key][:opeitms_id] = value[:id].split("_")[1].to_i
					blk =  RorBlkCtl::BlkClass.new("r_opeitms")
					command_r = blk.command_init
					chk_opeitm_nditm_from_gantt(key,value ,command_r)
				when /nditms/
					params[:tasks][key][:nditms_id] = value[:id].split("_")[1].to_i
					blk =  RorBlkCtl::BlkClass.new("r_nditms")
					command_r = blk.command_init
					chk_opeitm_nditm_from_gantt(key,value ,command_r)  ### 子品目から前工程に変更されることもある。
				else
				    logger.debug "#{Time.now} #{__LINE__} new option????? not support   value #{value}"
            end
        end
		###画面のラインを削除された時
		if params[:deletedTaskIds] and @err == false
			params[:deletedTaskIds].each do |del_rec|
				tbl,id = del_rec.split("_")
				case tbl
					when "nditms"
						command_r["sio_classname"] = "_delete_nditm_rec"
						screencode = "r_nditms"
					when "opeitms"
						command_r["sio_classname"] = "_delete_opeitm_rec"
						screencode = "r_opeitms"
				end
				blk =  RorBlkCtl::BlkClass.new(screenCode)
				command_c = blk.command_init
				case tbl
					when "nditms"
						command_r["nditm_id"] = command_r["id"] = id.to_i
					when "opeitms"
						command_r["sio_classname"] = "_delete_opeitm_rec"
				end
				blk.proc_insert_sio_r(command_r)
			end
		end
		if @err == false
			ActiveRecord::Base.connection.commit_db_transaction()
			render :json=>'{"result":"ok"}'
		else
			## logger.debug  "#{Time.now} #{__LINE__} :#{@ganttdata} "
			ActiveRecord::Base.connection.rollback_db_transaction()
			strgantt = '{"tasks":['
			@ganttdata.each  do|key,value|
				strgantt << %Q&{"id":"#{value[:id]}","itm_code":"#{value[:itm_code]}","itm_name":"#{value[:itm_name]}",
				"loca_code":"#{value[:loca_code]}","loca_name":"#{value[:loca_name]}",
				"loca_id":"#{value[:loca_id]}","itm_id":"#{value[:itm_id]}",
				"parenum":"#{value[:parenum]}","chilnum":"#{value[:chilnum]}","start":#{value[:start]},"duration":"#{value[:duration]}",
				"end":#{value[:duedate]},"assigs":[],"depends":"#{value[:depend]}",
				"processseq":"#{value[:processseq]}","priority":"#{value[:priority]}","prdpur":"#{value[:prdpur]}",
				"subtblid":"#{value[:subtblid]}","paretblcode":""},&
			end
        ## opeitmのsubtblidのopeitmは子のinsert用
			@ganttdata = strgantt.chop + %Q|],"selectedRow":11,"deletedTaskIds":[],"canWrite":true,"canWriteOnParent":true }|
			render :json=>@ganttdata
		end
	end

		def prv_resch   ##本日を起点に再計算

			today = Time.now
			@bgantts.sort.reverse.each  do|key,value|  ###計算
				if key.size > 3  ###master は分割はない
					if  value[:depend] == ""
						if @bgantts[key][:start]  <  today
							@bgantts[key][:start]  =  today
							@bgantts[key][:duedate]  =   @bgantts[key][:start] + value[:duration]*24*60*60    ###稼働日考慮今なし
						end
					end
					 Rails.logger.debug  "### "
					 Rails.logger.debug  "### #{Time.now} #{__LINE__} :#{@ganttdata} "
					 Rails.logger.debug  "###"
					raise if @bgantts[key][:duedate].nil? or @bgantts[key[0..-4]][:start].nil?
					if  (@bgantts[key[0..-4]][:start] ) < @bgantts[key][:duedate]
						@bgantts[key[0..-4]][:start]  =   @bgantts[key][:duedate]   ###稼働日考慮今なし
						@bgantts[key[0..-4]][:duedate] =  @bgantts[key[0..-4]][:start]  + @bgantts[key[0..-4]][:duration] *24*60*60
					end
				end
			end

			@bgantts.sort.each  do|key,value|  ###topから再計算
				if key.size > 3
					if  (@bgantts[key[0..-4]][:start]  ) > @bgantts[key][:duedate]
						@bgantts[key][:duedate]  =   @bgantts[key[0..-4]][:start]    ###稼働日考慮今なし
						@bgantts[key][:start] =  @bgantts[key][:duedate]  - value[:duration] *24*60*60
					end
				end
			end
      return
    end   

    def get_duration_by_loca(loca_id_fm,loca_id_to,priority)
        {:duration=>1,:transport_id =>ActiveRecord::Base.connection.select_value("select id from transports where code = 'dummy' ")}
    end
   	def proc_get_opeitms_id_from_itm itms_id ###
			strsql = %Q& select max(processseq) from opeitms where itms_id = #{itms_id} 
					 and expiredate > current_date group by itms_id &
			max_processseq = ActiveRecord::Base.connection.select_value(strsql)
			if max_processseq 
				strsql = %Q& select max(priority) from opeitms where itms_id = #{itms_id} 
					 and processseq =#{max_processseq} and expiredate > current_date group by itms_id &
				max_priority = ActiveRecord::Base.connection.select_value(strsql)
				if max_priority
					strsql = %Q& select id from opeitms where itms_id = #{itms_id} 
						 and processseq =#{max_processseq} and priority =#{max_priority} and expiredate > current_date &
					opeitms_id = ActiveRecord::Base.connection.select_value(strsql)
				else 
					opeitms_id = nil	
				end		
			else
				opeitms_id = nil
			end		
			return opeitms_id
		end
	end
end 
