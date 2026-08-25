module ArelCtl
	extend self
	# def proc_get_opeitms_rec itms_id,locas_id,processseq = nil,priority = nil  ###
	# 	strsql = %Q& select * from opeitms where itms_id = #{itms_id} 
	# 				#{if locas_id then " and locas_id = " + locas_id.to_s else "" end}
	# 			   #{if processseq then " and processseq = " + processseq.to_s else "" end}
	# 			   #{if priority then " and priority = " + priority.to_s else "" end}
	# 			   and expiredate > current_date  order by  priority desc &
	# 	newrec = ActiveRecord::Base.connection.select_one(strsql)
	# 	if newrec
	# 		return newrec
	# 	else
	# 		return nil
  #   end
	# end

  def proc_materiallized tblname
		if  Constants::Materiallized[tblname]
        Constants::Materiallized[tblname].each do |view|
				  strsql = %Q%select 1 from pg_catalog.pg_matviews pm 
				              where matviewname = '#{view}' %
				  if ActiveRecord::Base.connection.select_one(strsql)			
				    strsql = %Q%REFRESH MATERIALIZED VIEW #{view} %
				    ActiveRecord::Base.connection.execute(strsql)
				  else
				    3.times{p "materiallized error :#{view}"}
				  end
        end
		end
	end

    
	def proc_get_nextval tbl_seq
		ActiveRecord::Base.uncached() do
			case ActiveRecord::Base.connection_db_config.configuration_hash[:adapter]
				when /post/
					ActiveRecord::Base.connection.select_value("SELECT nextval('#{tbl_seq}')")  ##post
				# when /oracle/  ###oracle対応中止
				# 	ActiveRecord::Base.connection.select_value("select #{tbl_seq}.nextval from dual")  ##oracle
			end
		end
	end
	
	def proc_processreqs_add params
		processreqs_id = proc_get_nextval("processreqs_seq")
		if params[:seqno].nil? or params[:seqno] == 0 ###
				params[:seqno] = processreqs_id 
				params[:seqnos] = [] 
		else
				params[:seqnos] << processreqs_id 
		end
		if params[:billpayparams] 
			 	strParams = params.to_json
		else 
				strParams = "{}"
		end
		strsql = %Q&
			insert into processreqs(
						contents,remark,
						created_at,updated_at,
						update_ip,persons_id_upd,
						id,seqno,seqnos,
						segment,mkprdpurordsidparam,result_f,
						tblname,tblid,tbldata,
						billpayparams,
						gantt,child)
					values(
						'','#{params[:remark]}',
						current_timestamp,current_timestamp,
						'',#{params[:person_id_upd]},
						#{processreqs_id},'#{params[:seqno]}','#{params[:seqnos].to_json}',
						'#{params[:segment]}',#{(params[:mkprdpurords_id]||=0)},'0',
						'#{params[:tblname]||=""}',#{params[:tblid]||=0},'#{params[:tbldata].to_json}',
						'#{strParams}',
						'#{(params[:gantt]||={}).to_json}','#{(params[:child]||={}).to_json}')
		&
		ActiveRecord::Base.connection.insert(strsql) 
		return processreqs_id,params
	end

	def proc_createtable fmtbl,totbl,fmcommand_c,params  ### fmtbl:元のテーブル totbl:fmtblから自動作成するテーブル
		strsql = %Q% select pobject_code_sfd from  func_get_screenfield_grpname('#{params[:email]}','r_#{totbl}')
		%
		toFields = ActiveRecord::Base.connection.select_values(strsql) 
		blk = RorBlkCtl::BlkClass.new("r_#{totbl}")
		command_c = blk.command_init
		toFields.each do |key|
			prevkey = key.gsub(totbl.chop,fmtbl.chop)
			case key.to_s
			when /^id$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c["id"] = ""
				end
			when /_sno$|_cno$|_gno$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c[key] = ""
				end
			when /_amt|_qty/   ###例：qty_schとqtyは同一項目とみなす
				if fmcommand_c[prevkey]
					if key.split(/_amt|_qty/)[0] == prevkey.to_s.split(/_amt|_qty/)[0]
						command_c[key] = fmcommand_c[prevkey]
					end
				end
			else
				if toFields.index(prevkey)  ###配列に該当のkeyがあった時
					command_c[key] = fmcommand_c[prevkey]
				end	
			end
		end
		case fmtbl   ###元のテーブル
			when /^custs$/	
				case totbl
				when "custrcvplcs"
						command_c["custrcvplc_cust_id"] = command["id"]  
						command_c["custrcvplc_code"] = "000"  
						command_c["custrcvplc_name"] = "same as customer"  
						command_c["id"] = nil
				else
						 raise" calss:#{self},line:#{__LINE__},create table not support table:#{fmtbl}"
				end
			when /^suppliers$/
				case totbl
				when "shelfnos"
						strsql = %Q&
								select id from shelfnos where code = '000' and locas_id_shelfno = #{fmcommand_c["supplier_loca_id_supplier"]}
						& 
						if ActiveRecord::Base.connection.select_value(strsql)
						else
							command_c["shelfno_code"] = "000"
							command_c["shelfno_name"] = "same as loca name"
							command_c["shelfno_loca_id_shelfno"] = fmcommand_c["supplier_loca_id_supplier"]
							command_c["id"] = nil
						end
				else
					 raise " calss:#{self},line:#{__LINE__},create table not support table:#{fmtbl}"
				end
			when /^workplaces$/
				case totbl
				when "shelfnos"  
					strsql = %Q&
								select id from shelfnos where code = '000' and locas_id_shelfno = #{fmcommand_c["workplace_loca_id_workplace"]}
					& 
					if ActiveRecord::Base.connection.select_value(strsql)
					else
						command_c["shelfno_code"] =  "000"
						command_c["shelfno_name"] = "same as loca name"  
						command_c["shelfno_loca_id_shelfno"] = fmcommand_c["workplace_loca_id_workplace"]
						command_c["id"] = nil
					end
				else
					 raise " calss:#{self},line:#{__LINE__},\n create table not support table:#{fmtbl} \n table:#{totbl}"
				end
			when /rlstinputs/
				case totbl 
				when /^puracts/
						qty_stk = fmcommand_c["purrsltinput_qty"].to_f
						sym_qty_stk = "purrsltinput_qty_stk"
						sym_packno = "purrsltinput_packno"
				when /^prdacts/
						qty_stk = fmcommand_c["prdsltinput_qty"].to_f
						sym_qty_stk = "prdrsltinput_qty_stk"
						sym_packno = "prdrsltinput_packno"
				else
					 Rails.logger.debug " calss:#{self},line:#{__LINE__},create table not support table:#{fmtbl}"
					 raise " calss:#{self},line:#{__LINE__},create table not support table:#{totbl}"
				end
				packqty = fmcommand_c["opeitm_packqty"].to_f
				fmcommand_c["opeitm_packnoproc"] = 0 if packqty <= 0  ###保険　画面でチェック済
				case parent["opeitm_packnoproc"]
				when "1"
						idx = 0
						 packqty = fmcommand_c["opeitm_packqty"].to_f
						 until qty_stk <= 0 do
							fmcommand_c[sym_packno] = format('%03d', idx)
							fmcommand_c[sym_qty_stk] = packqty
						   proc_createtable fmtbl,totbl,fmcommand_c,params[:classname] 
						   qty_stk -=  packqty 
						   idx += 1
						 end
				else
					fmcommand_c[sym_qty_stk] = qty_stk
					proc_createtable fmtbl,totbl,fmcommand_c,params[:classname]
				end
      when /facilities/
        case totbl
        when "fcoperators"
          command_c["fcoperator_itm_id_fcoperator"] =  fmcommand_c["facilitie_itm_id"]
          command_c["fcoperator_chrg_id_fcoperator"] =  fmcommand_c["facilitie_chrg_id_facilitie"]
        end
		else
        raise " calss:#{self},line:#{__LINE__},create table not support fmtable:#{fmtbl},\n totable:#{totbl} "
        return
		end
		if params[:classname] =~ /_add_|_insert_/
				command_c["sio_classname"] ="_add_proc_createtable_data"
				command_c["#{totbl.chop}_created_at"] = Time.now
				command_c["#{totbl.chop}_expiredate"] =  Constants::EndDate 
				command_c["#{totbl.chop}_remark"] = " auto add  by table #{fmtbl} "
		else
				command_c["sio_classname"] ="_update_proc_createtable_data"
		end
		command_c["#{totbl.chop}_person_id_upd"] = params[:person_id_upd]
		command_c["id"] = ArelCtl.proc_get_nextval("#{totbl}_seq")
		blk.proc_private_aud_rec({},command_c)
	end	

	def proc_createDetailTableFmHead  headTbl,baseTbl,headCommand,fmcommand_c,params
		detailTbl = headTbl.sub(/heads$/,"s") 
		strsql = %Q% select pobject_code_sfd from  func_get_screenfield_grpname('#{params[:email]}','r_#{detailTbl}')
		%
		toFields = ActiveRecord::Base.connection.select_values(strsql) 
		blk = RorBlkCtl::BlkClass.new("r_#{detailTbl}")
		command_c = blk.command_init
		toFields.each do |key|
			prevkey = key.gsub(detailTbl.chop,baseTbl.chop)
			case key
			when /updated_at|created_at|remark|contents|_upd/
				next
			when /^id$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c["id"] = ""
				else
					command_c["id"] = fmcommand_c["id"]
				end
			when /_sno$|_cno$|_gno$/ 
				if params[:classname] =~ /_add_|_insert_/
					command_c[key] = ""
				else
					command_c[key] = fmcommand_c[prevkey]
				end
			when /_amt|_qty/   ###例：qty_sch,qty,qty_stkは同一項目とみなす
				if fmcommand_c[prevkey]
					if key.to_s.split(/_amt|_qty/)[0] == prevkey.split(/_amt|_qty/)[0]
						command_c[key] = fmcommand_c[prevkey]
					end
				end
			else
				if toFields.index(prevkey)  ###配列に該当のkeyがあった時
					command_c[key] = fmcommand_c[prevkey]
				end	
			end
		end
		case headTbl
		when "custactheads"
			command_c["custact_invoiceno"] = headCommand["custacthead_invoiceno"]
			command_c["custact_packinglistno"] = headCommand["custacthead_packinglistno"]  
			amt = command_c["custact_amt"]
			taxrate = command_c["custact_taxrate"] 
		end
		command_c["sio_classname"] =
			if params[:classname] =~ /_add_|_insert_/
				"_add_proc_createtable_data"
				command_c["#{headTbl.chop}_created_at"] = Time.now
			else
				"_update_proc_createtable_data"
			end
		command_c["#{headTbl.chop}_person_id_upd"] = params[:person_id_upd]
		command_c["id"] = ArelCtl.proc_get_nextval("#{headTbl}_seq")
		blk.proc_private_aud_rec({},command_c)
		head = {"amt" => amt,"taxrate" => taxrate,"#{headTbl.chop}_id" => command_c["id"]}
		return head
	end	


	def proc_insert_linktbls(src,newsrc)
		strsql = %Q&
							select id from linktbls where srctblname = '#{src["tblname"]}' and srctblid = #{src["tblid"]}
																			and   tblname = '#{newsrc["tblname"]}' and tblid = #{newsrc["tblid"]}
																			and trngantts_id = 	#{src["trngantts_id"]}
		&
		link_id = 	ActiveRecord::Base.connection.select_value(strsql)
		if link_id   ### xxxordsの数量が減ざれ引き当てが外れ、その後xxxordsがfreeになり再度引き合ったとき
				strsql = %Q&
									update linktbls set qty_src = qty_src + #{newsrc["qty_src"]} ,amt_src = amt_src + #{newsrc["amt_src"]} ,
																			remark = '#{newsrc["remark"]}'||left(remark,1000)
																			where id = #{link_id}
				&
			ActiveRecord::Base.connection.update(strsql)
		else
			linktbl_id = proc_get_nextval("linktbls_seq")
			strsql = %Q&
				insert into linktbls(id,trngantts_id,
					srctblname,srctblid,
					tblname,tblid,qty_src,amt_src,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linktbl_id},#{src["trngantts_id"]},
					'#{src["tblname"]}',#{src["tblid"]}, 
					'#{newsrc["tblname"]}',#{newsrc["tblid"]},#{newsrc["qty_src"]} ,#{newsrc["amt_src"]} , 
					current_timestamp,current_timestamp,
					' ',0,'2099/12/31','#{newsrc["remark"]}')  ---persons.id=0はテーブルに必須
				&
			ActiveRecord::Base.connection.insert(strsql)
		end
    if src["tblname"] =~ /^prd/ and newsrc["tblname"] =~ /^prd/  and src["tblname"] != newsrc["tblname"] and newsrc["qty_src"].to_f > 0
       link = {"prevtblname" => src["tblname"],"prevtblid" => src["tblid"],"tblname" => newsrc["tblname"],"tblid" => newsrc["tblid"]}
       add_dvserc_link(link)
    end  
	end

	
	def proc_insert_srctbllinks(src,base)
		linktbl_id = proc_get_nextval("srctbllinks_seq")
		strsql = %Q&
				insert into srctbllinks(id,
					srctblname,srctblid,
					tblname,tblid,amt_src,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linktbl_id},
					'#{src["tblname"]}',#{src["tblid"]}, 
					'#{base["tblname"]}',#{base["tblid"]},#{base["amt_src"]} , 
					current_timestamp,current_timestamp,
					' ',0,'2099/12/31','#{base["remark"]}')  ---persons.id=0ははテーブルに必須
				&
		ActiveRecord::Base.connection.insert(strsql)
	end

	def proc_insert_linkheads(head,detail)
		linkhead_id = proc_get_nextval("linkheads_seq")
		strsql = %Q&
				insert into linkheads(id,
					paretblname,paretblid,
					tblname,tblid,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linkhead_id},
					'#{head["paretblname"]}',#{head["paretblid"]}, 
					'#{detail["tblname"]}',#{detail["tblid"]}, 
					current_timestamp,current_timestamp,
					' ',#{detail["persons_id_upd"]},'2099/12/31','#{detail["remark"]}')
				&
		ActiveRecord::Base.connection.insert(strsql)
		return linkhead_id
	end

  
  def add_dvserc_link src  ###prevtblname:prdxxxxs,tblname:prdxxxs,prevtblid,tblid
    ["dvs","erc"].each do |dvserc|
      strsql = %Q&
        select '#{dvserc}#{src["prevtblname"][3..-1]}' prevdvserctblname,id prevdvserctblid
                             from #{dvserc}#{src["prevtblname"][3..-1]}
                                where #{src["prevtblname"]}_id_#{dvserc}#{src["prevtblname"][3..-2]} = #{src["prevtblid"]}
                &
        ActiveRecord::Base.connection.select_all(strsql).each do |prevdvserc| 
          prev = {"tblname" => prevdvserc["prevdvserctblname"],"tblid" => prevdvserc["prevdvserctblid"]}
          strsql =%Q&                 
            select '#{prevdvserc["prevdvserctblname"].sub(src["prevtblname"][3..-1],src["tblname"][3..-1])}' currdvserctblname,id currdvserctblid
                             from #{prevdvserc["prevdvserctblname"].sub(src["prevtblname"][3..-1],src["tblname"][3..-1])}
                                where #{src["tblname"]}_id_#{dvserc}#{src["tblname"][3..-2]} = #{src["tblid"]}
                &
            ActiveRecord::Base.connection.select_all(strsql).each do |currdvserc| 
              curr = {"tblname" => currdvserc["currdvserctblname"],"tblid" => currdvserc["currdvserctblid"],"qty_src" => 1,"amt_src" => 0}
              strsql = %Q&
                      select l.id link_id,a.id alloc_id,l.trngantts_id from linktbls l
                                    inner join alloctbls a on a.srctblname = l.tblname and a.srctblid = l.tblid and a.trngantts_id = l.trngantts_id    
                                    where l.tblname = '#{prevdvserc["prevdvserctblname"]}' and l.tblid = #{prevdvserc["prevdvserctblid"]} 
                                    and l.qty_src > 0 and a.qty_linkto_alloctbl > 0
                  &
              ActiveRecord::Base.connection.select_all(strsql).each do |link|  ###trngantts_idを求める
                prev["trngantts_id"] = link["trngantts_id"] 
                curr["remark"] = "class:#{self},line #{__LINE__}"
                proc_insert_linktbls(prev,curr)
                alloc = {"srctblname" => curr["tblname"],"srctblid" => curr["tblid"],"trngantts_id" => link["trngantts_id"],
                      "qty_linkto_alloctbl" => 1,
                      "remark" => "class:#{self}, line:#{__LINE__} #{Time.now}","persons_id_upd" => 0,"allocfree" =>"alloc"}  ##persons_id_upd=0;未定
                proc_aud_alloctbls(alloc,"add")
                strsql = %Q& update linktbls set qty_src = 0,remark = 'class:#{self}, line:#{__LINE__} #{Time.now}'||left(remark,100)
                                     where id = #{link["link_id"]}&
                ActiveRecord::Base.connection.update(strsql)
                strsql = %Q& update alloctbls set qty_linkto_alloctbl = 0,remark = 'class:#{self}, line:#{__LINE__} #{Time.now}'||left(remark,100)
                                     where id = #{link["alloc_id"]}&
                ActiveRecord::Base.connection.update(strsql)
              end
            end                 
        end
    end
  end

	def proc_insert_linkcusts(src,base)
		linkcust_id = proc_get_nextval("linkcusts_seq")
		strsql = %Q&
				insert into linkcusts(id,trngantts_id,
					srctblname,srctblid,
					tblname,tblid,qty_src,amt_src,
					created_at,
					updated_at,
					update_ip,persons_id_upd,expiredate,remark)
				values(#{linkcust_id},#{src["trngantts_id"]},
					'#{src["tblname"]}',#{src["tblid"]}, 
					'#{base["tblname"]}',#{base["tblid"]},#{base["qty_src"]} ,#{base["amt_src"]} , 
					current_timestamp,current_timestamp,
					' ',#{base["persons_id_upd"]},'2099/12/31','#{base["remark"]}')
				&
		ActiveRecord::Base.connection.insert(strsql)
		return linkcust_id
	end

	def proc_aud_alloctbls(rec_alloc,aud)   ### alloctbls.id又は(alloctbls.srctblname,srctblid,trngantts_id)は必須
    alloctbl = {}
    strwhere  = if rec_alloc["trngantts_id"]
                  " and trngantts_id = #{rec_alloc["trngantts_id"]} "
                else
                  ""
                end
    case aud
    when nil  ###recordが存在するときは数量の追加
      if rec_alloc["srctblname"] and rec_alloc["srctblid"]
		    strsql = %Q&
					select * from alloctbls 
									where srctblname = '#{rec_alloc["srctblname"]}' and srctblid = #{rec_alloc["srctblid"]}
                  #{strwhere}  
		        &
      else
        if rec_alloc["id"]
		        strsql = %Q&
					            select * from alloctbls 	where id = #{rec_alloc["id"]} 
		          &
        else
			    Rails.logger.debug"rec_alloc err class #{self} ,line:#{__LINE__} ,rec_alloc,#{rec_alloc}"
          raise
        end
      end
		  alloctbl = ActiveRecord::Base.connection.select_one(strsql)
		  if alloctbl
			  strsql = %Q&
						update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl +  #{rec_alloc["qty_linkto_alloctbl"]},
									remark = '#{rec_alloc["remark"]}'||left(remark,1000)   --- persond_id_upd=0
									where id = #{alloctbl["id"]}
					&
			  ActiveRecord::Base.connection.update(strsql)
        last_lotstk = {"tblname" => alloctbl["srctblname"],"tblid" => alloctbl["srctblid"],"lotno" => "","packno" => ""}
		  else
        alloctbl = {}
			  alloctbl["id"] = proc_get_nextval("alloctbls_seq")
			  strsql = %Q&
				  insert into alloctbls(id,
							srctblname,srctblid,
							trngantts_id,
							qty_linkto_alloctbl,
							created_at,
							updated_at,
							update_ip,persons_id_upd,expiredate,remark,allocfree)
					values(#{alloctbl["id"]},
							'#{rec_alloc["srctblname"]}',#{rec_alloc["srctblid"]},
							#{rec_alloc["trngantts_id"]},
							#{rec_alloc["qty_linkto_alloctbl"]},
					    current_timestamp,current_timestamp,
							' ',0,'2099/12/31','#{rec_alloc["remark"]}',   --- persond_id_upd=0
							'#{rec_alloc["allocfree"]}')
			    &
			  ActiveRecord::Base.connection.insert(strsql)
        last_lotstk = {"tblname" => rec_alloc["srctblname"],"tblid" => rec_alloc["srctblid"],"lotno" => "","packno" => ""}
		  end
      last_lotstk["qty_src"] = rec_alloc["qty_linkto_alloctbl"]
    when "insert","add"
			  alloctbl["id"] = proc_get_nextval("alloctbls_seq")
			  strsql = %Q&
				  insert into alloctbls(id,
							srctblname,srctblid,
							trngantts_id,
							qty_linkto_alloctbl,
							created_at,
							updated_at,
							update_ip,persons_id_upd,expiredate,remark,allocfree)
					values(#{alloctbl["id"]},
							'#{rec_alloc["srctblname"]}',#{rec_alloc["srctblid"]},
							#{rec_alloc["trngantts_id"]},
							#{rec_alloc["qty_linkto_alloctbl"]},
					    current_timestamp,current_timestamp,
							' ',0,'2099/12/31','#{rec_alloc["remark"]}',   --- persond_id_upd=0
							'#{rec_alloc["allocfree"]}')
			    &
			  ActiveRecord::Base.connection.insert(strsql)
        last_lotstk = {"tblname" => rec_alloc["srctblname"],"tblid" => rec_alloc["srctblid"],"qty_src" => rec_alloc["qty_linkto_alloctbl"],
												"lotno" => "","packno" => ""}
    when /update|edit/
      if rec_alloc["id"].nil? or rec_alloc["id"] == ""
		    strsql = %Q&
					select * from alloctbls 
									where srctblname = '#{rec_alloc["srctblname"]}' and srctblid = #{rec_alloc["srctblid"]}
									#{strwhere}  
		      &
		    alloctbl = ActiveRecord::Base.connection.select_one(strsql)
		    if alloctbl
          last_lotstk = {"tblname" => alloctbl["srctblname"],"tblid" => alloctbl["srctblid"],"lotno" => "","packno" => ""}
          if aud == "update+" or  aud == "edit+"
            last_lotstk["qty_src"] = rec_alloc["qty_linkto_alloctbl"]
			      strsql = %Q&
						  update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl + #{rec_alloc["qty_linkto_alloctbl"]},
									remark = '#{rec_alloc["remark"]}'||left(remark,1000)   --- persond_id_upd=0
									where id = #{alloctbl["id"]}
					    &
          else
            last_lotstk["qty_src"] = rec_alloc["qty_linkto_alloctbl"].to_f - alloctbl["qty_linkto_alloctbl"].to_f 
			      strsql = %Q&
						  update alloctbls set qty_linkto_alloctbl = #{rec_alloc["qty_linkto_alloctbl"]},
									remark = '#{rec_alloc["remark"]}'||left(remark,1000)  --- persond_id_upd=0
									where id = #{alloctbl["id"]}&
          end
		      ActiveRecord::Base.connection.update(strsql)
        else
			    raise "alloc_id err class #{self} ,line:#{__LINE__} ,rec_alloc,#{rec_alloc}"
        end
      else
        src = ActiveRecord::Base.connection.select_one(%Q& select * from alloctbls where id = #{rec_alloc["id"]}  &)
        if aud == "update+" or  aud == "edit+"  ###今ある数値に加算
            last_lotstk = {"tblname" => src["srctblname"],"tblid" => src["srctblid"],"qty_src" => rec_alloc["qty_linkto_alloctbl"],"lotno" => "","packno" => ""}
			      strsql = %Q&
						  update alloctbls set qty_linkto_alloctbl = qty_linkto_alloctbl + #{rec_alloc["qty_linkto_alloctbl"]},
									remark = '#{rec_alloc["remark"]}'||left(remark,1000)   --- persond_id_upd=0
									where id = #{rec_alloc["id"]}
                  &
        else   ### そのままの数値で更新
            last_lotstk = {"tblname" => src["srctblname"],"tblid" => src["srctblid"],"lotno" => "","packno" => ""}
            last_lotstk["qty_src"] = rec_alloc["qty_linkto_alloctbl"].to_f - src["qty_linkto_alloctbl"].to_f 
			      strsql = %Q&
						  update alloctbls set qty_linkto_alloctbl = #{rec_alloc["qty_linkto_alloctbl"]},
									remark = '#{rec_alloc["remark"]}'||left(remark,1000)   --- persond_id_upd=0
									where id = #{rec_alloc["id"]}
					    &
        end
			  ActiveRecord::Base.connection.update(strsql)
      end
    ###when "delete"
    end
		return last_lotstk
	end

		###custschs,custords,prdschs,prdords,purschs,purords dvsschs ercschs xxxx(在庫)  の時のみ作成
	def proc_insert_trngantts(gantt,tbldata) ## ###@tblname,@tblid,@gantt・・・・セット
			strsql = %Q&
			insert into trngantts(id,key,
						orgtblname,orgtblid,paretblname,paretblid,
						tblname,tblid,
						mlevel,
						shuffleflg,
						parenum,chilnum,
						qty_sch,qty,qty_stk,
						qty_require,
						qty_pare,qty_sch_pare,
						qty_handover,
						prjnos_id,
						shelfnos_id_to_trn,shelfnos_id_to_pare,
						itms_id_trn,processseq_trn,shelfnos_id_trn,
						itms_id_pare,processseq_pare,shelfnos_id_pare,
						itms_id_org,processseq_org,shelfnos_id_org,
						consumunitqty,
						consumminqty,consumchgoverqty,
					  optfixoterm,maxqty,
					  packqty,
						starttime_trn,optfixodate,  ---開始日、 オーダーの纒可能日 
						starttime_pare,
						starttime_org,
						duedate_trn,
						duedate_pare,
						duedate_org,
						toduedate_trn,
						toduedate_pare,
						toduedate_org,
						consumtype,
						chrgs_id_trn,chrgs_id_pare,chrgs_id_org,
						qty_alloc,qty_pare_alloc,qty_bal,qty_pare_bal,
						created_at,	updated_at,
						update_ip,persons_id_upd,expiredate,remark)
			values(#{gantt["trngantts_id"]},'#{gantt["key"]}',
					'#{gantt["orgtblname"]}',#{gantt["orgtblid"]},'#{gantt["paretblname"]}',#{gantt["paretblid"]},
					'#{gantt["tblname"]}',#{gantt["tblid"]},
					'#{gantt["mlevel"]}',
					'#{gantt["shuffleflg"]}',
					#{gantt["parenum"]},#{gantt["chilnum"]},
					#{gantt["qty_sch"]},#{gantt["qty"]},#{gantt["qty_stk"]},
					#{gantt["qty_require"]},
					#{gantt["qty_pare"]},#{gantt["qty_sch_pare"]},
					#{gantt["qty_handover"]},
					#{gantt["prjnos_id"]},
					#{gantt["shelfnos_id_to_trn"]},#{gantt["shelfnos_id_to_pare"]},
					#{gantt["itms_id_trn"]},#{gantt["processseq_trn"]},#{gantt["shelfnos_id_trn"]},
					#{gantt["itms_id_pare"]},#{gantt["processseq_pare"]},#{gantt["shelfnos_id_pare"]},
					#{gantt["itms_id_org"]},#{gantt["processseq_org"]},#{gantt["shelfnos_id_org"]},
					#{case gantt["consumunitqty"].to_i when 0 then 1 else gantt["consumunitqty"] end},
					#{gantt["consumminqty"]},#{gantt["consumchgoverqty"]},
					#{gantt["optfixoterm"]},#{gantt["maxqty"]},
					#{gantt["packqty"]},
					cast('#{gantt["starttime_trn"]}' as timestamp),	cast('#{gantt["starttime_trn"]}' as timestamp),
					cast('#{gantt["starttime_pare"]}' as timestamp),
					cast('#{gantt["starttime_org"]}' as timestamp),
					cast('#{gantt["duedate_trn"]}' as timestamp),
					cast('#{gantt["duedate_pare"]}' as timestamp),
					cast('#{gantt["duedate_org"]}' as timestamp),
					cast('#{gantt["toduedate_trn"]}' as timestamp),
					cast('#{gantt["toduedate_pare"]}' as timestamp),
					cast('#{gantt["toduedate_org"]}' as timestamp),
					'#{gantt["consumtype"]}',   ---custxxxsの時は""
					#{gantt["chrgs_id_trn"]},#{gantt["chrgs_id_pare"]},#{gantt["chrgs_id_org"]},
					0,0,0,0,   ---qty_alloc,qty_pare_alloc,qty_bal,qty_pare_bal,
					current_timestamp,current_timestamp,
					' ',#{gantt["persons_id_upd"]},'2099/12/31','#{gantt["remark"]}')
				&
			ActiveRecord::Base.connection.insert(strsql)
			src = {"tblname" => gantt["tblname"],"tblid" => gantt["tblid"],"trngantts_id" => gantt["trngantts_id"]}
			qty_src = gantt["qty_sch"].to_f + gantt["qty"].to_f + gantt["qty_stk"].to_f  ###qty_sch,qty,qty_stkの一つのみ有効
			base = {"tblname" => gantt["tblname"],"tblid" => gantt["tblid"],"qty_src" => qty_src,"amt_src" => 0,
					"remark" => "#{self} line #{__LINE__}", "persons_id_upd" => gantt["persons_id_upd"]}
			alloc = {"srctblname" => gantt["tblname"],"srctblid" => gantt["tblid"],"trngantts_id" => gantt["trngantts_id"],
					"qty_linkto_alloctbl" => gantt["qty_sch"].to_f + gantt["qty"].to_f + gantt["qty_stk"].to_f,
					"remark" => "#{self} line #{__LINE__} #{Time.now}","persons_id_upd" => gantt["persons_id_upd"],
					"allocfree" => 	if gantt["tblid"] == gantt["paretblid"] and gantt["tblid"] == gantt["orgtblid"] and
											gantt["tblname"] == gantt["paretblname"] and gantt["tblname"] == gantt["orgtblname"] 
												"free" 
									else
												"alloc"
									end}
      last_lotstks = []
			case gantt["tblname"] 
			when /^pur/   ### shp itmclass,code=mold,ITollの時
				proc_insert_linktbls(src,base)
				last_lotstk = proc_aud_alloctbls(alloc,"insert")
        last_lotstks << last_lotstk
        ###reqparams = {:tbldata => tbldata,:gantt => gantt,:opeitm => {}}
			when /^prd/   ### shp itmclass,code=mold,ITollの時
				proc_insert_linktbls(src,base)
				last_lotstk = proc_aud_alloctbls(alloc,"insert")
        ###
        # gate runner check
        ###
				###Rails.logger.debug" class:#{self},line:#{__LINE__} \n tbldata:#{tbldata}"
        strsql = %Q&select 1 from nditms where opeitms_id = #{tbldata["opeitms_id"]} 
                                          and consumtype = 'run' &
		    gate = ActiveRecord::Base.connection.select_one(strsql)
        if gate.nil? 
          last_lotstks << last_lotstk
        else
          ### runnerのpartsが作成物
        end
        #
        ###reqparams = {:tbldata => tbldata,:gantt => gantt,:opeitm => {}}
			when /^dymschs|^shp/   ### shp itmclass,code=mold,ITollの時
				proc_insert_linktbls(src,base)
				last_lotstk = proc_aud_alloctbls(alloc,"insert")
        last_lotstks << last_lotstk
			when /^erc|^dvs/   ### shp itmclass,code=mold,ITollの時
				proc_insert_linktbls(src,base)
				last_lotstk_tmp = proc_aud_alloctbls(alloc,"insert")
        ###在庫移動無
			when /^con/   ### runnerの時のみtrnganttsを作成
				proc_insert_linktbls(src,base)
				last_lotstk_tmp = proc_aud_alloctbls(alloc,"insert")
			when /^cust/
				proc_insert_linkcusts(src,base)
				last_lotstk = proc_aud_alloctbls(alloc,"insert")
        last_lotstks << last_lotstk
			end
			return last_lotstks
	end
	
	def proc_linktbls_alloctbls_lotstkhists(src,base)
			if src["tblname"] != base["tblname"] ###新規登録　状態変更
				last_lotstks =  status_chng_linktbls_alloctbls(src,base)
			else
				if src["tblid"] == base["tblid"]	###変更のとき
					last_lotstks =  qty_chng_linktbls_alloctbls_trngantts_lotstkhists(src,base)
				else
					last_lotstks = []
				end
			end
			return last_lotstks
	end
  def status_chng_linktbls_alloctbls(src,base)  ###前の状態から現状への変更
		###
		###  今の関係(linktbls.qty_src)は変更しない。履歴として残している。
		###
		###      src["tblname"],src["tblid"] =>変化前tbl,id
		###      src["qty_linkto_alloctbl"]=>変化前のqty
		###      src["trngantts_id"] => 変化前trngantts_id 
		###      src["qty_src"] => freeに引き当った数 又はords-->insts,ords--actsへの移動数
		###
		###      base["tblname"],base["tblid"] =>変化元tbl,id、変更のときはbase["tblid"] = src["tblid"]
		###      base["qty_src"]=> 変化元のqty
		###      base["trngantts_id"] => 引き当て元trngantts_id 
		###
		###################################################################   
		###  
    last_lotstks = []
		if src["qty_linkto_alloctbl"].to_f > base["qty_src"].to_f
			base["remark"] = "=>#{self},line:(#{__LINE__},#{Time.now.to_s})" + base["remark"]
      src["qty_linkto_alloctbl"] = src["qty_linkto_alloctbl"].to_f - base["qty_src"].to_f
      src["qty_src"] =  base["qty_src"] ### 新たに引き合った 
      base["qty_src"] = 0
	  else
      base["qty_src"] = base["qty_src"].to_f - src["qty_linkto_alloctbl"].to_f
			base["remark"] = "#{self} line:(#{__LINE__})" +  base["remark"]
      src["qty_src"] =  src["qty_linkto_alloctbl"] 
      src["qty_linkto_alloctbl"] = 0
		end
    newsrc = {"tblname"=>base["tblname"],"tblid"=>base["tblid"],"qty_src"=>src["qty_src"],
              "amt_src"=>0,"remark"=>base["remark"]}
    proc_insert_linktbls(src,newsrc)  ###linktbls.qty_src作成後free_qty=base["qty_src"] = 0
		###  
		#
		if base["tblname"] =~ /schs|ords/ 
			strsql = %Q%
								select id from linktbls	where tblid  = srctblid 
																				and qty_src >= #{src["qty_src"]}
																				and tblname= '#{base["tblname"]}' and tblid = #{base["tblid"]}
																				order by qty_src
					%
			free_link_id = ActiveRecord::Base.connection.select_value(strsql)
			if free_link_id 
				update_sql = %Q%
									update linktbls set qty_src = qty_src - #{src["qty_src"]}
																,remark = '#{self} line #{__LINE__}'||left(remark,1000)
															where id = #{free_link_id}
					%
				ActiveRecord::Base.connection.update(update_sql)
			else
        3.times{Rails.logger.debug" class:#{self},line:#{__LINE__} ,\n src:#{src},\n base:#{base},\n strsql:#{strsql}"}
        ### raise
			end
		end

		alloc = {"id" => src["alloctbls_id"], "qty_linkto_alloctbl" => src["qty_linkto_alloctbl"],
        "srctblname" => src["tblname"],"srctblid" => src["tblid"],"trngantts_id" => src["trngantts_id"],
        "remark" => base["remark"],"persons_id_upd" => 0}
    last_lotstk = proc_aud_alloctbls(alloc,"update")
    last_lotstks << last_lotstk
		str_qty = case src["tblname"]
		 			when /schs$/
						"qty_sch"
					when /acts$|dlvs$|custinsts$/
						"qty_stk"
					else
						"qty"
					end

		new_str_qty = case base["tblname"]
					when /schs$/
					   "qty_sch"
				   	when /acts$|dlvs$|custinsts$/
					   "qty_stk"
				   	else
					   "qty"
				   	end
    if str_qty != new_str_qty        
		  strsql = %Q&  ---   tblname=xxxschsのqty,qty_sch
			 update trngantts set #{str_qty} = #{str_qty}  - #{src["qty_src"]},
			 						#{new_str_qty} =  #{new_str_qty} + #{src["qty_src"].to_f},
						 updated_at = cast('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp),
						 remark = '#{self} line:(#{__LINE__})'|| left(remark,1000)
					 where id = #{src["trngantts_id"]} 
			  &
		  ActiveRecord::Base.connection.update(strsql)
    end
    
    if src["trngantts_id"] != base["trngantts_id"] ### base free trngantts
      strsql = %Q&  ---   tblname=xxxschsのqty,qty_sch
        update trngantts set  #{new_str_qty} =  #{new_str_qty} - #{src["qty_src"].to_f},
              updated_at = cast('#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}' as timestamp),
              remark = '#{self} line:(#{__LINE__})'||left(remark,1000)
            where id = #{base["trngantts_id"]} 
         &
      ActiveRecord::Base.connection.update(strsql)
			alloc = {"srctblname" => base["tblname"],"srctblid" => base["tblid"],"trngantts_id" => base["trngantts_id"],
        					"qty_linkto_alloctbl" => src["qty_src"] * -1,
        					"remark" => "#{self} line #{__LINE__} #{Time.now}" + (base["remark"]||=""),"persons_id_upd" => 0}
    	last_lotstk = proc_aud_alloctbls(alloc,"update+")  
			###引当の変更はあるが在庫数の変更はない
    end

		alloc = {"trngantts_id" => src["trngantts_id"],"srctblname" => base["tblname"] ,"srctblid" => base["tblid"],
              "allocfree" => "alloc","qty_linkto_alloctbl" => src["qty_src"] ,
							"remark" => "#{self} (line: #{__LINE__} #{Time.now})" + (base["remark"]||="")}
    last_lotstk = proc_aud_alloctbls(alloc,nil)
		if base["tblname"] =~ /schs$|ords$/
				### 
		else
    		last_lotstks << last_lotstk
		end
		return  last_lotstks
	end

	def qty_chng_linktbls_alloctbls_trngantts_lotstkhists(src,base)  ###数量減対応
			###schsが減された時:ords,insts,actsをfreeに　qty_schが増、減されたときshp,conの変更、###在庫の処理を含む
			###trnganttsは修正済  alloctblsは一件のみ
			if base["tblname"] =~ /purords|prdords/
      		###出庫指示済の時はなにもしない　画面でエラーになっているはず
        	strsql = %Q&
                    select '1' from shpords where paretblname = '#{base["tblname"]}' and paretblid =#{base["tblid"]}
																					and qty > 0
              &
        	chk = ActiveRecord::Base.connection.select_value(strsql)
        	return [] if chk == "1"
			end
      ###旧在庫削除　＠＠
      last_lotstks = [] ###prd,purxxxxは数量減のみされているだけだから在庫を減する
			alloc = src.dup
			new_qty = base["qty_src"]
			### freeから
			if base["tblname"] =~ /ords/
					strsql = %Q%
								select l.srctblname,l.srctblid,l.tblname,l.tblid,l.trngantts_id,l.id link_id,a.id alloc_id,
									a.qty_linkto_alloctbl qty_src from linktbls l
									inner join	alloctbls a on l.tblname = a.srctblname and l.tblid = a.srctblid and l.trngantts_id = a.trngantts_id 
									where l.tblname = '#{base["tblname"]}' and l.tblid = #{base["tblid"]} and l.srctblid = l.tblid
					%
					free = ActiveRecord::Base.connection.select_one(strsql)
						if free["qty_src"]   < base["qty_src"]	
								strsql = %Q%
									select sum(a.qty_linkto_alloctbl) alloc_qty from linktbls l
										inner join	alloctbls a on l.tblname = a.srctblname and l.tblid = a.srctblid and l.trngantts_id = a.trngantts_id 
										where l.tblname = '#{base["tblname"]}' and l.tblid = #{base["tblid"]} and l.srctblid != l.tblid
								%
								alloc_qty = ActiveRecord::Base.connection.select_value(strsql)
								if alloc_qty >= base["qty_src"]
										tmp_qty =  free["qty_src"]
								else 
										tmp_qty =  free["qty_src"] + alloc_qty - base["qty_src"] 
								end
						else
								tmp_qty =  free["qty_src"] 
						end
						new_qty += tmp_qty  ### 元の数になるまで加算
						alloc = {"srctblname" => free["tblname"],"srctblid" => free["tblid"],"qty_linkto_alloctbl" => (tmp_qty * -1),
										"remark" => '#{self} line #{__LINE__}',
										"id" => free["alloc_id"],"trngantts_id" => free["trngantts_id"]}
						alloc_id,last_lotstk = proc_aud_alloctbls(alloc,"update+")
						last_lotstks << last_lotstk
						# update_sql = %Q%
						# 									update trngantts set qty = qty - #{tmp_qty},
						# 										remark = '#{self} line #{__LINE__}'||remark
						# 									where id = #{free["trngantts_id"]}
						# 		%
						# ActiveRecord::Base.connection.update(update_sql)
						update_sql = %Q%
									update linktbls set qty_src = qty_src - #{tmp_qty}
																,remark = '#{self} line #{__LINE__}'||left(remark,1000)
															where id = #{free["link_id"]}
						%
						ActiveRecord::Base.connection.update(update_sql)
						return last_lotstks if new_qty >=  src["qty_src"]   ### free だけで数量減完了
			end
      ### 引当変更
			strsql = %Q%
								select l.srctblname,l.srctblid,l.tblname,l.tblid,l.trngantts_id,l.id link_id,a.id alloc_id,
									a.qty_linkto_alloctbl qty_src  from linktbls l
									inner join	alloctbls a on l.tblname = a.srctblname and l.tblid = a.srctblid and l.trngantts_id = a.trngantts_id 
									where l.tblname = '#{base["tblname"]}' and l.tblid = #{base["tblid"]} and l.srctblid != l.tblid
									and a.qty_linkto_alloctbl > 0
									order by l.id desc
			%
			ActiveRecord::Base.connection.select_all(strsql).each do |link|
					if src["qty_src"] >= link["qty_src"] + new_qty
						tmp_qty = link["qty_src"]
					else
						tmp_qty = (link["qty_src"] + new_qty) - src["qty_src"] 
					end
					new_qty += tmp_qty
					alloc = {"srctblname" => link["tblname"],"srctblid" => link["tblid"],"qty_linkto_alloctbl" => (tmp_qty * -1),
									"remark" => "class:#{self}, line:#{__LINE__} #{Time.now}",
									"id" => link["alloc_id"],"trngantts_id" => link["trngantts_id"]}
					alloc_id,last_lotstk = proc_aud_alloctbls(alloc,"update+")
					if link["tblname"] =~ /schs$|ords$|dlvs$/ or (link["srctblname"] !~ /dlvs$/ and link["tblname"] =~ /acts$/)
					 			update_sql = %Q%
					 										update trngantts set
					 										#{case link["tblname"] 
					 												when /ords$/
					 													"qty_sch = qty_sch + #{tmp_qty},qty = qty - #{tmp_qty}" 
					 												when /dlvs$|acts$/
					 													"qty = qty + #{tmp_qty},qty_stk = qty_stk - #{tmp_qty}" 
					 												end}
					 											,remark = '#{self} line #{__LINE__}'||left(remark,100)
					 										where id = #{link["trngantts_id"]}
					 			%
					 	ActiveRecord::Base.connection.update(update_sql)
					end
					update_sql = %Q%
									update linktbls set qty_src = qty_src - #{tmp_qty}
																,remark = '#{self} line #{__LINE__}'||left(remark,1000)
															where id = #{link["link_id"]}
					%
					ActiveRecord::Base.connection.update(update_sql)
					alloc = {"srctblname" => link["srctblname"],"srctblid" => link["srctblid"],"qty_linkto_alloctbl" => tmp_qty,
									"remark" => "class:#{self}, line:#{__LINE__} #{Time.now}",
									"trngantts_id" => link["trngantts_id"]}
					alloc_id,last_lotstk = proc_aud_alloctbls(alloc,"update+")
					###
					##  linktblsの元のデータは履歴として残しているので修正は必要ない
					###
					if link["tblname"] =~ /schs$|ords$|dlvs$/ or (link["srctblname"] !~ /dlvs$/ and link["tblname"] =~ /acts$/)
						  last_lotstks << last_lotstk
					end
					return last_lotstks if new_qty >=  src["qty_src"]   ##
			end
      return last_lotstks
	end

 	def proc_nditmSql(opeitms_id)  
        %Q%
            select pare.itms_id itms_id_pare,pare.processseq processseq_pare,pare.priority priority_pare,
                pare.packqty packqty_pare,pare.id opeitms_id_pare,pare.locas_id_pare locas_id_pare,
                pare.shelfnos_id_opeitm shelfnos_id_pare,pare.shelfnos_id_to_opeitm shelfnos_id_to_pare,
				        ope.duration ,ope.unitofduration ,ope.consumauto,
               		COALESCE(ope.id,0) opeitms_id,ope.packnoproc,
               	COALESCE(ope.prdpur,'xxx') prdpur,ope.units_id_case_shp,itm.units_id,
               	ope.locas_id ,ope.locas_code,ope.locas_name,ope.shelfnos_id,  ---子部品作業場所
               	ope.locas_id_to ,ope.locas_code_to,ope.locas_name_to,ope.shelfnos_id_to,   ---子部品保管場所
                nditm.unitofdvs, nditm.itms_id_nditm itms_id,  ---itms_id = itms_id_nditm
               	nditm.processseq_nditm processseq,ope.packqty,
                ope.priority,    ---代替がある場合は、複数個発生
              	nditm.consumtype,nditm.parenum,nditm.chilnum,
               	nditm.consumunitqty,nditm.consumminqty,nditm.consumchgoverqty,
			   	      nditm.durationfacility ,nditm.requireop,nditm.changeoverlt,nditm.changeoverop,
			   	      nditm.postprocessinglt,nditm.postprocessingop,
			          itm.taxflg, itm.classlist_code,itm.itm_code_nditm,itm.itm_name_nditm,
				        nditm.packqtyfacility,null reverse
            from nditms nditm 
				    inner join (select p.*,s.locas_id_shelfno locas_id_pare from  opeitms p
                              inner join shelfnos s on p.shelfnos_id_opeitm = s.id) pare  on pare.id = nditm.opeitms_id
            inner join (select i.id,i.taxflg,i.units_id,c.code classlist_code,i.code itm_code_nditm,i.name itm_name_nditm,
								                i.units_id itm_unit_id
			   					          from itms i 
				                    inner join classlists c on i.classlists_id = c.id ) itm on itm.id = nditm.itms_id_nditm 
            left join (select o.*,
                            s.locas_id,s.locas_code,s.locas_name,s.shelfnos_id,
                            xto.locas_id_to,xto.locas_code_to,xto.locas_name_to,xto.shelfnos_id_to
                           from opeitms o 
                           inner join (select l1.id locas_id,l1.code locas_code,l1.name locas_name,s1.id shelfnos_id
                                          from shelfnos s1
                                          inner join locas l1  on s1.locas_id_shelfno = l1.id)s on o.shelfnos_id_opeitm = s.shelfnos_id
                           inner join  (select l2.id locas_id_to,l2.code locas_code_to,l2.name locas_name_to,s2.id shelfnos_id_to
                                          from shelfnos s2
                                          inner join locas l2  on s2.locas_id_shelfno = l2.id)xto on o.shelfnos_id_to_opeitm = xto.shelfnos_id_to
						                            --- where  o.priority = 999 ---代替がある場合は、複数個発生
                  ) ope ---完成後の移動場所から親の場所に
                   on  ope.itms_id = nditm.itms_id_nditm  and ope.processseq = nditm.processseq_nditm and ope.priority = nditm.priority_nditm
              where nditm.expiredate > current_date and nditm.opeitms_id = #{opeitms_id} and nditm.consumtype != 'run'
			        order by itm.classlist_code,itm.itm_code_nditm 
        %  
	end
    	
	def proc_reverse_nditmSql(itms_id,processseq,opeitms_id)  
			%Q%
             select #{itms_id} itms_id_pare,#{processseq} processseq_pare,ope.packqty packqty_pare,ope.id opeitms_id_pare,
                ope.shelfnos_id_opeitm shelfnos_id_pare,ope.shelfnos_id_to_opeitm shelfnos_id_to_pare,
				        ope.duration ,ope.unitofduration ,ope.consumauto,
               	ope.id opeitms_id,ope.packnoproc,
               	COALESCE(ope.prdpur,'xxx') prdpur,ope.units_id_case_shp,ope.units_id,
               	ope.locas_id ,ope.locas_code,ope.locas_name,ope.shelfnos_id,  ---子部品作業場所
               	ope.locas_id_to ,ope.locas_code_to,ope.locas_name_to,ope.shelfnos_id_to,   ---子部品保管場所
                nditm.unitofdvs, ope.itms_id itms_id,  ---
               	ope.processseq processseq,ope.packqty,
              	nditm.consumtype,nditm.parenum,nditm.chilnum,
               	nditm.consumunitqty,nditm.consumminqty,nditm.consumchgoverqty,
			   	      nditm.durationfacility ,nditm.requireop,nditm.changeoverlt,nditm.changeoverop,
			   	      nditm.postprocessinglt,nditm.postprocessingop,
			          ope.taxflg, ope.classlist_code,ope.itm_code_nditm,ope.itm_name_nditm,
				        nditm.packqtyfacility,'true' reverse,nditm.itms_id_nditm,nditm.processseq_nditm
           from nditms nditm 
        inner join (select o.*,itm.code itm_code_nditm, itm.name itm_name_nditm,itm.taxflg,
                            s.locas_id,s.locas_code,s.locas_name,s.shelfnos_id,itm.classlist_code ,
                            xto.locas_id_to,xto.locas_code_to,xto.locas_name_to,xto.shelfnos_id_to,itm.units_id
                           from opeitms o 
                           inner join (select l1.id locas_id,l1.code locas_code,l1.name locas_name,s1.id shelfnos_id
                                          from shelfnos s1
                                          inner join locas l1  on s1.locas_id_shelfno = l1.id)s on o.shelfnos_id_opeitm = s.shelfnos_id
                           inner join  (select l2.id locas_id_to,l2.code locas_code_to,l2.name locas_name_to,s2.id shelfnos_id_to
                                          from shelfnos s2
                                          inner join locas l2  on s2.locas_id_shelfno = l2.id)xto on o.shelfnos_id_to_opeitm = xto.shelfnos_id_to
						                            ---where  o.priority = 999
                          inner join (select itm.*,c.code classlist_code from itms itm 
                                        inner join classlists c on c.id = itm.classlists_id) itm on itm.id = o.itms_id
                    ) ope ---完成後の移動場所から親の場所に
                   on  ope.id = nditm.opeitms_id
				where nditm.expiredate > current_date 
					  and nditm.itms_id_nditm = #{itms_id}  and nditm.processseq_nditm = #{processseq}  and nditm.consumtype != 'run'
			union
             select #{itms_id} itms_id_pare,#{processseq} processseq_pare,ope.packqty packqty_pare,ope.id opeitms_id_pare,
                ope.shelfnos_id_opeitm shelfnos_id_pare,ope.shelfnos_id_to_opeitm shelfnos_id_to_pare,
				        ope.duration ,ope.unitofduration ,ope.consumauto,
               	ope.id opeitms_id,ope.packnoproc,
               	COALESCE(ope.prdpur,'xxx') prdpur,ope.units_id_case_shp,ope.units_id,
               	ope.locas_id ,ope.locas_code,ope.locas_name,ope.shelfnos_id,  ---子部品作業場所
               	ope.locas_id_to ,ope.locas_code_to,ope.locas_name_to,ope.shelfnos_id_to,   ---子部品保管場所
                nditm.unitofdvs, nditm.itms_id_nditm itms_id,  ---
               	nditm.processseq_nditm processseq,ope.packqty,
              	nditm.consumtype,nditm.parenum,nditm.chilnum,
               	nditm.consumunitqty,nditm.consumminqty,nditm.consumchgoverqty,
			   	      nditm.durationfacility ,nditm.requireop,nditm.changeoverlt,nditm.changeoverop,
			   	      nditm.postprocessinglt,nditm.postprocessingop,
			          ope.taxflg, ope.classlist_code,ope.itm_code_nditm,ope.itm_name_nditm,
				        nditm.packqtyfacility,'true' reverse,#{itms_id} itms_id_nditm,#{processseq} processseq_nditm
           from nditms nditm 
        inner join (select o.*,itm.code itm_code_nditm, itm.name itm_name_nditm,itm.taxflg,
                            s.locas_id,s.locas_code,s.locas_name,s.shelfnos_id,itm.classlist_code ,
                            xto.locas_id_to,xto.locas_code_to,xto.locas_name_to,xto.shelfnos_id_to,itm.units_id
                           from opeitms o 
                           inner join (select l1.id locas_id,l1.code locas_code,l1.name locas_name,s1.id shelfnos_id
                                          from shelfnos s1
                                          inner join locas l1  on s1.locas_id_shelfno = l1.id)s on o.shelfnos_id_opeitm = s.shelfnos_id
                           inner join  (select l2.id locas_id_to,l2.code locas_code_to,l2.name locas_name_to,s2.id shelfnos_id_to
                                          from shelfnos s2
                                          inner join locas l2  on s2.locas_id_shelfno = l2.id)xto on o.shelfnos_id_to_opeitm = xto.shelfnos_id_to
						                            ---where  o.priority = 999
                          inner join (select itm.*,c.code classlist_code from itms itm 
                                        inner join classlists c on c.id = itm.classlists_id) itm on itm.id = o.itms_id
                    ) ope ---完成後の移動場所から親の場所に
                   on  ope.itms_id = nditm.itms_id_nditm and ope.processseq = nditm.processseq_nditm and ope.priority = 999
				where nditm.expiredate > current_date 
					  and nditm.opeitms_id = #{opeitms_id}   and nditm.consumtype = 'run'
			%  
	end
	
  def proc_pareChildTrnsSqlGroupByChildItem(parent)
         %Q%
             select max(pare.id) pare_trngantts_id,trn.itms_id_trn itms_id, trn.processseq_trn processseq,
                (trn.consumtype) consumtype,max(trn.parenum) parenum,max(trn.chilnum) chilnum,
                max(trn.consumunitqty) consumunitqty,max(trn.consumminqty) consumminqty,max(trn.consumchgoverqty) consumchgoverqty,
                pare.shelfnos_id_trn pare_shelfnos_id,   ---親作業場所
                trn.shelfnos_id_to_trn shelfnos_id_to,   ---子の保管先
								sp.locas_id_shelfno locas_id_pare,
	 		          max(ope.units_id_case_shp) units_id_case_shp,max(trn.qty) qty,max(trn.qty_stk) qty_stk,
	 		          sum(pare.qty_linkto_alloctbl) qty_sch,max(ope.consumauto) consumauto,max(ope.shpordauto) shpordauto
             from trngantts trn
                inner join (select p.id, p.shelfnos_id_trn,alloc.qty_linkto_alloctbl,p.mlevel, 
                                    p.orgtblname,p.orgtblid,p.tblname,p.tblid                                
                            from trngantts p 
                            inner join alloctbls alloc on alloc.trngantts_id = p.id
	 					   			          where alloc.srctblname = '#{parent["tblname"]}' and alloc.srctblid = #{parent["tblid"]} 
	 								            and alloc.qty_linkto_alloctbl > 0) pare 
                    on  trn.orgtblname = pare.orgtblname and   trn.orgtblid = pare.orgtblid  
                    and trn.paretblname = pare.tblname and   trn.paretblid = pare.tblid 
	 			      inner join opeitms ope on trn.itms_id_trn = ope.itms_id and trn.processseq_trn = ope.processseq
	 							and trn.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join shelfnos sp on sp.id = trn.shelfnos_id_pare
	 		        where (trn.paretblname != trn.tblname or trn.paretblid != trn.tblid) and pare.mlevel < trn.mlevel
	 		        group by trn.itms_id_trn ,trn.processseq_trn ,pare.shelfnos_id_trn,trn.shelfnos_id_to_trn,trn.consumtype,sp.locas_id_shelfno
         %  
  end
	
  def proc_pareChildTrnsSql(parent)
         %Q%
            select trn.orgtblname,trn.orgtblid,trn.tblname,trn.tblid,
			 		      trn.qty_sch,trn.qty,trn.qty_stk,
					      trn.mlevel,trn.parenum,trn.chilnum,trn.consumunitqty,trn.consumminqty,
					      trn.consumchgoverqty,pare.qty_linkto_alloctbl  pare_qty_alloc,
					      trn.itms_id_trn itms_id,trn.processseq_trn processseq,
					      ope.duration ,ope.unitofduration,ope.locas_id_shelfno,
								sp.locas_id_shelfno locas_id_pare,
                pare.duedate_trn duedate_pare,pare.starttime_trn starttime_pare, pare.shelfnos_id_trn shelfnos_id_pare    
             	from trngantts trn
                inner join (select p.*, alloc.qty_linkto_alloctbl 
                            from trngantts p 
                            inner join alloctbls alloc on alloc.trngantts_id = p.id
	 					   			where alloc.srctblname = '#{parent["tblname"]}' and alloc.srctblid = #{parent["tblid"]} 
	 								  and alloc.qty_linkto_alloctbl >= 0) pare 
                    on  trn.orgtblname = pare.orgtblname and   trn.orgtblid = pare.orgtblid  
                    and trn.paretblname = pare.tblname and   trn.paretblid = pare.tblid 
	 			      inner join (select o.* , s.locas_id_shelfno from opeitms o 
                                                        inner join shelfnos s on o.shelfnos_id_opeitm = s.id                                   
                            )ope on trn.itms_id_trn = ope.itms_id and trn.processseq_trn = ope.processseq
	 							          and trn.shelfnos_id_trn = ope.shelfnos_id_opeitm
							inner join shelfnos sp on sp.id = trn.shelfnos_id_pare
	 		        where (trn.paretblname != trn.tblname or trn.paretblid != trn.tblid) and pare.mlevel < trn.mlevel
              and trn.tblname in('prdschs','purschs')  ---,'dvsschs','ercschs','shpschs'は二重計上になるので除外
							and trn.qty_sch > 0
            %  
  end
	
  # def proc_PrevConSql(parent,child,prev_contblname)
  #       %Q$
  #           --- select pare.srctblname prev_paretblname,pare.srctblid prev_paretblid,pare.qty_src  ,
	# 		--- 		trn.id trngantts_id ,pare.tblname_pare paretblname,pare.tblid_pare paretblid
	# 		--- 	from trngantts trn 
	# 		--- 	inner join (select link.*,t.orgtblname,t.orgtblid,link.tblname tblname_pare,link.tblid tblid_pare,
	# 		--- 							t.tblname tblname_sch,t.tblid tblid_sch,
	# 		--- 							t.shelfnos_id_trn pare_shelfnos_id from trngantts t 
	# 		--- 				inner join linktbls link on t.id = link.trngantts_id
	# 		--- 				where link.tblname = '#{parent["tblname"]}' and link.tblid = #{parent["id"]}) pare
	# 		--- 		on trn.orgtblid = pare.orgtblid and trn.orgtblname = pare.orgtblname
	# 		--- 		and trn.paretblid = pare.tblid_sch and trn.paretblname = pare.tblname_sch
	# 		--- 	inner join #{prev_contblname} con on con.paretblid  = pare.srctblid 
	# 		--- 	where  con.itms_id = #{child["itms_id"]} and con.processseq = #{child["processseq"]}  
	# 		--- 	and con.shelfnos_id_fm = #{child["shelfnos_id_fm"]}
	# 		--- 	and trn.itms_id_trn = #{child["itms_id"]} and trn.processseq_trn = #{child["processseq"]}  
	# 		--- 	and pare.pare_shelfnos_id = #{child["shelfnos_id_fm"]}

	# 		select prevcon.paretblname prev_paretblname,prevcon.paretblid prev_paretblid,link.qty_src,link.trngantts_id 
	# 				from  #{prev_contblname}  prevcon
	# 			inner join  linktbls link on link.srctblid = prevcon.paretblid
	# 			where  prevcon.itms_id = #{child["itms_id"]} and prevcon.processseq = #{child["processseq"]} 
	# 			and prevcon.shelfnos_id_fm = #{child["shelfnos_id_fm"]}
	# 			and link.tblid =#{parent["id"]} and link.tblname = '#{parent["tblname"]}'
  #       $
  # end
	
  def proc_ChildConSql(parent)  
        %Q&
            select trn.itms_id_trn itms_id, trn.processseq_trn processseq,
               max(trn.consumtype) consumtype,max(trn.parenum) parenum,max(trn.chilnum) chilnum,
               max(trn.consumunitqty) consumunitqty,max(trn.consumminqty) consumminqty,max(trn.consumchgoverqty) consumchgoverqty,
			   sum(pare_qty) qty_stk,max(ope.consumauto) consumauto
           from trngantts trn
               inner join (select p.*,alloc.srctblname,alloc.srctblid,alloc.qty_linkto_alloctbl pare_qty
                           from trngantts p 
                           inner join alloctbls alloc on alloc.trngantts_id = p.id
						   		where  qty_linkto_alloctbl > 0 
								and alloc.srctblname = '#{parent["tblname"]}' and alloc.srctblid = #{parent["id"]}
								and (p.tblname != p.paretblname or p.tblid != p.paretblid)
								and not exists(select 1 from linktbls link where link.tblname = alloc.srctblname
																			and link.tblid = alloc.srctblid and srctblname != tblname
																			and link.srctblname = 'purdlvs' and link.qty_src > 0)) pare 
                   on  trn.orgtblname = pare.orgtblname and   trn.orgtblid = pare.orgtblid  
                   and trn.paretblname = pare.tblname and   trn.paretblid = pare.tblid
				inner join opeitms ope on ope.itms_id = trn.itms_id_trn and ope.processseq = trn.processseq_trn
									and ope.shelfnos_id_opeitm = trn.shelfnos_id_trn     
			where  (trn.tblname != trn.paretblname or trn.tblid != trn.paretblid)   
           and trn.consumtype = 'con'  ---金型、装置,runnerは除外
			group by trn.itms_id_trn , trn.processseq_trn 
		&
  end

  def proc_apparatus_sql(opeitms_id) 
    %Q&
      select n.itms_id_nditm itms_id ,n.processseq_nditm processseq, ic.code classlist_code,n.unitofdvs, 
              o.locas_id_shelfno locas_id_shelfno,
              n.durationfacility,n.changeoverlt,n.postprocessinglt,n.requireop,n.changeoverop,n.postprocessingop
          from nditms n 
          inner join (select i.id itms_id ,c.code from itms i
                    inner join classlists c on c.id = i.classlists_id ) ic
              on ic.itms_id = n.itms_id_nditm
          inner join (select ope.*,s.locas_id_shelfno from opeitms ope 
                                inner join shelfnos s on ope.shelfnos_id_opeitm = s.id ) o 
                                on  o.id = n.opeitms_id
          where ic.code = 'apparatus' and n.opeitms_id = #{opeitms_id}
    &
  end
  def proc_add_update_lotstkhists(last_lotstks,persons_id_upd)
      tmptbls = []
      suppliers_id_fm = suppliers_id_to = save_tblid = -1
      last_lotstks.each do |last_lotstk| 
        next if last_lotstk.nil?
        next if last_lotstk.empty?
          if last_lotstk["set_f"]
              rec = last_lotstk["rec"].dup
          else
            case last_lotstk["tblname"]
            when /^prd|^pur|^cust|^movacts/
                  strsql = %Q& select rec.*,ope.itms_id,ope.processseq from #{last_lotstk["tblname"]} rec 
                          inner join opeitms ope on ope.id = rec.opeitms_id
                          where rec.id = #{last_lotstk["tblid"]}&
                  rec = ActiveRecord::Base.connection.select_one(strsql)
                  case last_lotstk["tblname"]
                  when /^pur/
                      suppliers_id_fm  = rec["suppliers_id"]
                      supp_str = %Q&
                              select supp.id from suppliers supp
                                            inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                            where shelf.id = #{rec["shelfnos_id_to"]}
                      &
                      suppliers_id_to = ActiveRecord::Base.connection.select_value(supp_str)
                      suppliers_id_to ||= -1
                  else
                      suppliers_id_fm = -1
                      suppliers_id_to = -1
                  end
            when /^con/
                      strsql = %Q& select rec.* from #{last_lotstk["tblname"]} rec where rec.id = #{last_lotstk["tblid"]}&
                      rec = ActiveRecord::Base.connection.select_one(strsql)
											case last_lotstk["paretblname"]
												when /pur/ 
                      			supp_str = %Q&
                              select supp.id from suppliers supp
                                            inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                            where shelf.id = #{rec["shelfnos_id_fm"]}
                      				&
                      				suppliers_id_fm = ActiveRecord::Base.connection.select_value(supp_str)
                      				suppliers_id_to = -1
												else
                      				suppliers_id_fm = -1
                      				suppliers_id_to = -1
											end
            when /^shp/
                  		strsql = %Q& select rec.* from #{last_lotstk["tblname"]} rec where rec.id = #{last_lotstk["tblid"]}
                  				&
                  		rec = ActiveRecord::Base.connection.select_one(strsql)
											case last_lotstk["paretblname"]
												when /pur/ 
                    			supp_str = %Q&
                            select supp.id from suppliers supp
                                          inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                          where shelf.id = #{rec["shelfnos_id_to"]}
                    			&
                    			suppliers_id_to = ActiveRecord::Base.connection.select_value(supp_str)
												else
                    			suppliers_id_to ||= -1
											end
                    	supp_str = %Q&
                      select supp.id from suppliers supp
                                          inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                          where shelf.id = #{rec["shelfnos_id_fm"]}
                    			&
                    	suppliers_id_fm = ActiveRecord::Base.connection.select_value(supp_str)
                    	suppliers_id_fm ||= -1
            when /^rejections/
              strsql = %Q&
                          select pa.itms_id,pa.processseq,pa.prjnos_id,'rejections' tblname,rj.id tblid,pa.lotno,pa.packno,
                                  '' shelfnos_id, pa.shelfnos_id shelfnos_id_fm,rj.shelfnos_id_to,rj.acpdate starttime,rj.qty_rejection
                                    from rejections rj
                                    inner join (select p.id pare_id,ope.itms_id,ope.proceeseq,p.prjnos_id ,
                                                        p.shelfnos_id shelfnos_id_fm,p.lotno,p.packno
                                                        from #{last_lotstk["paretblname"]} p
                                                    inner join opeitms ope on ope.id = p.opeitms_id
                                                      where p.id = #{last_lotstk["paretblid"]}) pa 
                                            on pa.pare_id = rj.paretblid
              &
              rec = ActiveRecord::Base.connection.select_one(strsql)
            when /dymschs/
              next
            else
              3.times{Rails.logger.debug" class:#{self} , line:#{__LINE__} ,\n error last_lotstks:#{last_lotstks},\n error last_lotstk:#{last_lotstk}"}
              raise
            end
				
          end
          temp = {"itms_id" => rec["itms_id"],"processseq" => rec["processseq"],"prjnos_id" => rec["prjnos_id"],
                    "tblname" => last_lotstk["tblname"],"tblid" => last_lotstk["tblid"],
                    "qty_sch" => 0.0,"qty" => 0.0,"qty_stk" => 0.0, "qty_real" => 0.0,"qty_rejection" => 0.0,
                    "shelfnos_id" => -1,"suppliers_id_fm" => suppliers_id_fm,"suppliers_id_to" => suppliers_id_to ,"custrcvplcs_id" =>-1 }
          case last_lotstk["tblname"]
            when /purschs|prdschs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                        "qty_sch" => last_lotstk["qty_src"],"lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /custschs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                                "qty_sch" => last_lotstk["qty_src"].to_f*-1,"lotno" => "","packno" => ""})
              tmptbls << xtemp
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"custrcvplcs_id" => rec["custrcvplcs_id"],
                                "qty_sch" => last_lotstk["qty_src"].to_f*-1,"lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /purords|purinsts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty" => last_lotstk["qty_src"],"lotno" => "","packno" => ""})
              tmptbls << xtemp
              # xtemp = temp.dup
              # xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => 0,
              #         "suppliers_id_fm" => rec["suppliers_id"], "qty" => last_lotstk["qty_src" ] * -1,"lotno" => "","packno" => ""})
              # tmptbls << xtemp
            when /prdords|prdinsts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty" => last_lotstk["qty_src"],"lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /custords/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                              "custrcvplcs_id" => -1,"qty" => last_lotstk["qty_src"].to_f*-1,"lotno" => "","packno" => ""})
              tmptbls << xtemp
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => -1,
                      "custrcvplcs_id" => rec["custrcvplcs_id"],"qty_sch" => -1,"qty" => last_lotstk["qty_src"],"lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /purreplyinputs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["replaydate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                        "qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,"lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /custdlvs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                      "custrcvplcs_id" => -1,"qty_stk" => last_lotstk["qty_src"],
                      "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            when /purdlvs/
              xtemp = temp.dup
              temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => "","custrcvplcs_id" =>-1,
                        "suppliers_id_fm" => suppliers_id_fm,"qty_stk" => last_lotstk["qty_src"],
                      	"lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            when /puracts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["rcptdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                      "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            when /prdacts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["cmpldate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                            "qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                              "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            when /custacts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["saledate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => -1,
                        "custrcvplcs_id" => rec["custrcvplcs_id"],
                        "qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                        "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            when /shpests/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                        "qty_sch" => last_lotstk["qty_src"] * -1,
                        "lotno" => "","packno" => ""})
              tmptbls << xtemp
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                         "qty_sch" => last_lotstk["qty_src"], "lotno" => "","packno" => ""})
               tmptbls << xtemp
            when /shpschs/
              xtemp = temp.dup              
              if rec["prdpur"] == "run" or rec["prdpur"] == "BYP"
                ### ruuner or BYP(副産物)では出はない
              else
                xtemp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                                    "qty_sch" => last_lotstk["qty_src"] * -1,"lotno" => "","packno" => ""})
                tmptbls << xtemp
              end
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                                     "qty_sch" => last_lotstk["qty_src"],"lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /shpords/
              if rec["prdpur"] == "run" or rec["prdpur"] == "BYP"
                ### ruuner or BYP(副産物)では出はない
              else
                xtemp = temp.dup
                temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                               "qty" => last_lotstk["qty_src"] * -1,
                                    "lotno" => "","packno" => ""})
                tmptbls << temp
              end
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                                     "qty_sch" => 0,"qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                                     "lotno" => "","packno" => ""})
               tmptbls << xtemp
            when /shpdlvs/
              if rec["prdpur"] == "run" or rec["prdpur"] == "BYP"
                ### ruuner or BYP(副産物)では出はない
              else
                xtemp = temp.dup
                xtemp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                      "qty_stk" => last_lotstk["qty_src"] * -1, "qty_real" => last_lotstk["qty_src"] * -1,
                                    "lotno" =>rec["lotno"],"packno" => rec["packno"]})
                tmptbls << xtemp
              end
            when /shpacts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["rcptdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty_stk" => last_lotstk["qty_src"], "qty_real" => last_lotstk["qty_src"],
                      "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            when /conschs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                     "qty_sch" => last_lotstk["qty_src"] * -1, "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /conords|coninsts/
                xtemp = temp.dup
                xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                     "qty" => last_lotstk["qty_src"] * -1, "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /conacts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                              "qty_stk" => last_lotstk["qty_src"] * -1, "qty_real" => last_lotstk["qty_src"] * -1,
                              "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            when /rejections/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty_rejection" => rec["qty_rejection"] , "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            when /movacts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["cmpldate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                              "qty_rejection" => rec["qty_rejection_fm"].to_f * -1,"qty_stk" => rec["qty_stk_fm"].to_f * -1 ,
                              "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["cmpldate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty_rejection" => rec["qty_rejection_to"].to_f  ,"qty_stk" => rec["qty_stk_to"].to_f ,
                      "lotno" => rec["lotno"],"packno" => rec["packno"]})
              tmptbls << xtemp
            else
              3.times{Rails.logger.debug" error class:#{self} , line:#{__LINE__} ,tblname:'#{last_lotstk["tblname"]}' not support last_lotstk:#{last_lotstk}"}
              raise
          end 
      end
      ###data.sort_by { |h| h.values_at(:k1, :k2, :k3, :k4) }else
      ### Rails.logger.debug" class:#{self} , line:#{__LINE__} ,\n tmptbls:#{tmptbls}"
      tmplotstktbls = tmptbls.sort_by {|h| [h["itms_id"],h["processseq"],h["prjnos_id"],h["starttime"],h["lotno"],h["packno"],
                        h["shelfnos_id"],h["suppliers_id_fm"],h["suppliers_id_to"],h["custrcvplcs_id"]]}
      lotstktbls = []
      save_lotno = save_packno = save_starttime = ""
      save_itms_id = save_processseq = save_shelfnos_id = save_prjnos_id = -1
      save_suppliers_id_fm = save_suppliers_id_to = save_custrcvplcs_id =  -1
      save_qty_sch = save_qty = save_qty_stk = save_qty_real = save_qty_rejection = 0
      tmplotstktbls.each do |tmpl|
        if save_itms_id == tmpl["itms_id"] and save_processseq == tmpl["processseq"] and 
              save_shelfnos_id == tmpl["shelfnos_id"] and
                 save_lotno == tmpl["lotno"] and save_packno == tmpl["packno"]  and 
                  save_prjnos_id == tmpl["prjnos_id"]  and save_starttime == tmpl["starttime"] and 
                     save_suppliers_id_fm == tmpl["suppliers_id_fm"]  and save_suppliers_id_to == tmpl["suppliers_id_to"] and 
                          save_custrcvplcs_id == tmpl["custrcvplcs_id"]
          save_qty_sch += tmpl["qty_sch"].to_f
          save_qty += tmpl["qty"].to_f
          save_qty_stk += tmpl["qty_stk"].to_f
          save_qty_real += tmpl["qty_real"].to_f
          save_qty_rejection += tmpl["qty_rejection"].to_f
        else
          if save_itms_id == -1 and save_processseq == -1 and 
                save_shelfnos_id == -1 and save_lotno == "" and save_packno == ""  and 
                    save_prjnos_id == -1  and save_starttime == "" and 
                      save_suppliers_id_fm == -1 and  save_suppliers_id_to == -1 and  save_custrcvplcs_id == -1
          else
            lotstktbls << {"itms_id" => save_itms_id ,"processseq" => save_processseq ,
                          "shelfnos_id" => save_shelfnos_id ,
                          "suppliers_id_fm" => save_suppliers_id_fm ,"suppliers_id_to" => save_suppliers_id_to , 
                          "custrcvplcs_id" => save_custrcvplcs_id,
                          "lotno" => save_lotno ,"packno" => save_packno,  "persons_id_upd" => persons_id_upd,
                           "prjnos_id" => save_prjnos_id ,"starttime" => save_starttime ,
                          "qty_sch" => save_qty_sch ,"qty" => save_qty ,"qty_stk" => save_qty_stk ,"qty_real" => save_qty_real,
                          "qty_rejection" => save_qty_rejection  }
          end
            save_itms_id = tmpl["itms_id"] 
            save_processseq = tmpl["processseq"] 
            save_shelfnos_id = tmpl["shelfnos_id"] 
            save_suppliers_id_fm = tmpl["suppliers_id_fm"] 
            save_suppliers_id_to = tmpl["suppliers_id_to"] 
            save_custrcvplcs_id = tmpl["custrcvplcs_id"] 
            save_lotno = tmpl["lotno"] 
            save_packno = tmpl["packno"]  
            save_prjnos_id = tmpl["prjnos_id"]  
            save_starttime = tmpl["starttime"]
            save_qty_sch = tmpl["qty_sch"].to_f
            save_qty = tmpl["qty"].to_f
            save_qty_stk = tmpl["qty_stk"].to_f
            save_qty_rejection = tmpl["qty_rejection"].to_f
        end
      	### Rails.logger.debug" class:#{self} , line:#{__LINE__} ,\n tmpl:#{tmpl},\n lotstktbls#{lotstktbls}"
      end
      lotstktbls << {"itms_id" =>save_itms_id ,"processseq" => save_processseq ,
                      "shelfnos_id" => save_shelfnos_id ,"suppliers_id_fm" => save_suppliers_id_fm,"suppliers_id_to" => save_suppliers_id_to,
                      "custrcvplcs_id" => save_custrcvplcs_id,"lotno" => save_lotno ,"packno" => save_packno , 
                      "prjnos_id" => save_prjnos_id ,"starttime" => save_starttime , "persons_id_upd" => persons_id_upd,
                      "qty_sch" => save_qty_sch ,"qty" => save_qty ,"qty_stk" => save_qty_stk ,"qty_real" => save_qty_real,
                      "qty_rejection" => save_qty_rejection}                      
      lotstktbls.each do |lotstktbl|
        if lotstktbl["suppliers_id_fm"] != -1 
            lotstktbl["suppliers_id"] = lotstktbl["suppliers_id_fm"] 
						save_lotstktbl = lotstktbl.dup
            Shipment.proc_mk_supplierwhs_rec "out",lotstktbl
              if lotstktbl["shelfnos_id"] == -1
                if lotstktbl["qty_sch"] == 0 and lotstktbl["qty"] == 0 and lotstktbl["qty_stk"] == 0 and lotstktbl["qty_rejection"] == 0 ###dymschs
                    next
                else
                  3.times{Rails.logger.debug" error shelfnos_id missing class:#{self} , line:#{__LINE__} ,lotstktbl:#{lotstktbl}"}
                  raise
                end
              else
                Shipment.proc_lotstkhists_in_out('in',save_lotstktbl)
              end
        else  
          if lotstktbl["suppliers_id_to"] != -1 
              lotstktbl["suppliers_id"] = lotstktbl["suppliers_id_to"] 
              Shipment.proc_mk_supplierwhs_rec "in",lotstktbl
          else
            if lotstktbl["custrcvplcs_id"] != -1
              Shipment.proc_mk_custwhs_rec "in",lotstktbl
            else
              if lotstktbl["shelfnos_id"] == -1
                if lotstktbl["qty_sch"] == 0 and lotstktbl["qty"] == 0 and lotstktbl["qty_stk"] == 0 and lotstktbl["qty_rejection"] == 0 ###dymschs
                    next
                else
                  3.times{Rails.logger.debug" error shelfnos_id missing class:#{self} , line:#{__LINE__} ,lotstktbl:#{lotstktbl}"}
                  raise
                end
              else
                Shipment.proc_lotstkhists_in_out('in',lotstktbl)
              end
            end
          end
        end
      end
  end
end
