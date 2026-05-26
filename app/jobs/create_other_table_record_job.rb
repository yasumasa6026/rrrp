class CreateOtherTableRecordJob < ApplicationJob
    queue_as :default 
    def perform(pid)
      # 後で実行したい作業をここに書く
      begin
        ActiveRecord::Base.connection.begin_db_transaction()
        perform_strsql = "select * from  processreqs t 
                            where t.result_f = '0'  and t.seqno = #{pid} 
                            and not exists(select 1 from processreqs c where t.seqno = c.seqno and t.id > c.id
                                        and c.result_f != '1')
                            order by t.id limit 1 for update"
        processreq = ActiveRecord::Base.connection.select_one(perform_strsql)
        return if processreq.nil?            
        params = JSON.parse(processreq["reqparams"]).symbolize_keys   
        strsql = %Q% select * from persons where id = #{params[:person_id_upd]}
                    %
        person = ActiveRecord::Base.connection.select_one(strsql) ###
        params[:email] = person["email"]
        params[:person_code_chrg] = person["code"]
        ###params[:person_id_upd] = person["id"]
        until processreq.nil? do
          reqparams = params.dup
          if params[:tbldata]
                      tbldata = params[:tbldata]
          else
            if params[:tblname]
                        strsql = %Q&
                                    select * from #{params[:tblname]} where id = #{params[:tblid]} 
                        &
				                tbldata = ActiveRecord::Base.connection.select_one(strsql)
            else
              tbldata = {}
            end
          end
			    if tbldata["opeitms_id"]
				    strsql = %Q&
										      select o.*,
													  s1.locas_id_shelfno locas_id_shelfno ,s2.locas_id_shelfno locas_id_shelfno_to from opeitms o
													  inner join shelfnos s1 on s1.id = o.shelfnos_id_opeitm 
													  inner join shelfnos s2 on s2.id = o.shelfnos_id_to_opeitm
											  where o.id = #{tbldata["opeitms_id"]}
					            &
				    opeitm = ActiveRecord::Base.connection.select_one(strsql)
			    else
				    opeitm = {}
			    end
          if reqparams[:where_str]
            reqparams[:where_str] = reqparams[:where_str].gsub("#!","'")
          end
          gantt = params[:gantt].dup
          tblname = gantt["tblname"]
          tblid = gantt["tblid"]
          paretblname = gantt["paretblname"]
          strsql = %Q%update processreqs set result_f = '5'  where id = #{processreq["id"]}
                    %
          ActiveRecord::Base.connection.update(strsql)
          result_f = '1'
          remark = ""
          case params[:segment]

            when "createtable"

            when "mkprdpurords"  ###  xxxschsからxxxordsを作成。
              ### 　parent 未使用
              mkordparams = {}
              mkordparams[:incnt] =  mkordparams[:inqty] = mkordparams[:inamt] = 0
              mkordparams[:outcnt] = mkordparams[:outqty] = mkordparams[:outamt] = 0
              ###mkordparams,last_lotstks = MkordinstLib.proc_mkprdpurords params,mkordparams
              mkordparams,last_lotstks = MkordinstLib.proc_mkprdpurordv1 params,mkordparams
              if mkordparams[:message_code] == ""
                mkordparams[:remark] = "  #{self} line:#{__LINE__} "
                strsql = %Q%update mkprdpurords set incnt = #{mkordparams[:incnt]},inqty = #{mkordparams[:inqty]},
                                                inamt = #{mkordparams[:inamt]},outcnt = #{mkordparams[:outcnt]},
                                                outqty = #{mkordparams[:outqty]},outamt = #{mkordparams[:outamt]} ,
                                                message_code = '#{mkordparams[:message_code]}',remark = ' #{mkordparams[:remark]} ',
                                                result_f = '1',cmpldate = now()
                                                where id = #{params[:mkprdpurords_id]}
                                %
                ActiveRecord::Base.connection.update(strsql)
                if !last_lotstks.empty?
                    ArelCtl.proc_add_update_lotstkhists(last_lotstks,params[:person_id_upd])
                end
              else
                ActiveRecord::Base.connection.rollback_db_transaction()
                ActiveRecord::Base.connection.begin_db_transaction()
                mkordparams[:remark] = " error #{self} line:#{__LINE__} error "
                strsql = %Q%update mkprdpurords set message_code = '#{mkordparams[:message_code]}',
                                                                  remark = ' #{mkordparams[:remark]} ',
                                                                   result_f = '9',cmpldate = now()
                                                where id = #{params[:mkprdpurords_id]}
                                %
                ActiveRecord::Base.connection.update(strsql)
                if processreq
                  strsql = %Q%update processreqs set result_f = '5'  where seqno = #{pid} and id < #{processreq["id"]}
                                %
                  ActiveRecord::Base.connection.update(strsql)
                  strsql = %Q%update processreqs set result_f = '9'  where seqno = #{pid} and id = #{processreq["id"]}
                                %
                  ActiveRecord::Base.connection.update(strsql)
                  strsql = %Q%update processreqs set result_f = '8'  where seqno = #{pid} and id > #{processreq["id"]}
                                %
                  ActiveRecord::Base.connection.update(strsql)
                end           
                ActiveRecord::Base.connection.commit_db_transaction()
                return 
              end
            when /mkpayords|mkbillords/
		          ActiveRecord::Base.connection.execute("lock table #{params[:segment][2..-1]} in  SHARE ROW EXCLUSIVE mode")
              ### 　parent 未使用
              if tbldata["amt"].to_f > 0
                ###ArelCtl.proc_createtable は使用しない
                ###bill_loca_id_bill_cust
                isudate = Time.now
                case params[:segment]
                  when "mkpayords"
                    trn_day = tbldata["rcptdate"].to_date.strftime("%d").to_i
                    duedate =  tbldata["rcptdate"].to_date
                    strsql = %Q%select b.* from payments b
                                            inner join suppliers c on c.payments_id_supplier = b.id   
                                            where c.id = #{tbldata["suppliers_id"]}
                                    %
                    mst = ActiveRecord::Base.connection.select_one(strsql)
                    ord_tbldata = {"isudate"=>isudate,"payments_id" => mst["id"],
                                        "last_amt" => params[:last_amt],"last_duedate" => params[:last_duedate],
                                        "termofs" => mst["termof"],"ratejson" => mst["ratejson"],
                                        "persons_id_upd" => person["id"] ,"trngantts_id" => params[:trngantts_id],
                                         "chrgs_id" => mst["chrgs_id_payment"],"crrs_id" => tbldata["crrs_id"],
                                        "srctblname" => params[:srctblname],"srctblid" => params[:srctblid]}
                    ord_tblname = "payords"
                  when "mkbillords"
                    trn_day = tbldata["saledate"].to_date.strftime("%d").to_i
                    duedate =  tbldata["saledate"].to_date
                    strsql = %Q%select b.* from bills b
                                            where b.id = #{tbldata["bills_id"]}
                                      %
                    mst = ActiveRecord::Base.connection.select_one(strsql)
                    ord_tbldata = {"isudate"=>isudate,"bills_id" => mst["id"],
                                        "last_amt" => params[:last_amt],"last_duedate" => params[:last_duedate],
                                        "termofs" => mst["termof"],"ratejson" => mst["ratejson"],
                                        "persons_id_upd" => person["id"] ,"trngantts_id" => params[:trngantts_id],
                                         "chrgs_id" => mst["chrgs_id_bill"],"crrs_id" => tbldata["crrs_id"],
                                        "srctblname" => params[:srctblname],"srctblid" => params[:srctblid]}
                    ord_tblname = "billords"
                end
                ratejsons = JSON.parse(mst["ratejson"])
                saveDuedate = duedate 
                mst["termof"].split(",").each_with_index do |termof,id|
                    if trn_day <= termof.to_i
                        ratejsons[id].each do |rate|
                            if rate["+day"]  
                                duedate =  saveDuedate.since(rate["+day"].day)
                            else 
                              if rate["day"]  
                                duedate =  saveDuedate.since(rate["duration"].month)
                                if rate["day"] < 28
                                  duedate = (saveDuedate.strftime("%Y") + "-" + saveDuedate.strftime("%m") + "-" + rate["day"].to_s).to_date
                                else
                                  duedate =  saveDuedate.since((rate["duration"] + 1).month)
                                  duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "01").to_date.since(-1.day)
                                end
                              else
                                3.times{Rails.logger.debug(%Q%class:#{self},line:#{__LINE__} ,\n mst["ratejson"]:#{mst["ratejson"]},\n termof:#{termof}%)}
                                raise
                              end
                            end
                            ord_tbldata.merge!({"amt_src" => tbldata["amt"].to_f * rate["rate"] / 100,
                                                 "tax" =>  tbldata["tax"].to_f * rate["rate"] / 100,
                                                 "denomination" => rate["denomination"],"duedate" =>duedate})
                            MkordinstLib.proc_create_paybilltbl(ord_tblname,ord_tbldata)
                          break  
                        end
                    else 
                      if termof.to_i < 1   ###随時
                          JSON.parse(mst["ratejson"])[0].each do |rate|
                            if rate["+day"] 
                              duedate = (saveDuedate.strftime("%Y") + "-" + saveDuedate.strftime("%m") + "-" + rate["+day"].to_s).to_date
                              ord_tbldata.merge!({"amt_src" => tbldata["amt"].to_f * rate["rate"] / 100,
                                                 "tax" =>  tbldata["tax"].to_f * rate["rate"] / 100,
                                                 "denomination" => rate["denomination"],"duedate" =>duedate})
                              MkordinstLib.proc_create_paybilltbl(ord_tblname,ord_tbldata)
                            else
                                3.times{Rails.logger.debug(%Q%class:#{self},line:#{__LINE__} ,\n mst["ratejson"]:#{mst["ratejson"]},\n termof:#{termof}%)}
                                raise
                            end
                          end
                      else
                          if  mst["termof"].split(",").length == (id + 1)
                            JSON.parse(mst["ratejson"])[0].each do |rate| 
                              duedate =  saveDuedate.since((rate["duration"] + 1).month)
                              duedate = (saveDuedate.strftime("%Y") + "-" + saveDuedate.strftime("%m") + "-" + rate["day"].to_s).to_date 
                              ord_tbldata.merge!({"amt_src" => tbldata["amt"].to_f * rate["rate"] / 100,
                                                 "tax" =>  tbldata["tax"].to_f * rate["rate"] / 100,
                                                 "denomination" => rate["denomination"],"duedate" =>duedate})
                              MkordinstLib.proc_create_paybilltbl(ord_tblname,ord_tbldata)
                            end
                          end
                      end
                    end
                end
              end 
            when "mkbillinsts"
		            ActiveRecord::Base.connection.execute("lock table #{params[:segment][2..-1]} in  SHARE ROW EXCLUSIVE mode")
                            ### 　parent 未使用
                            mkbillinstparams = {}
                            mkbillinstparams[:incnt] = 0
                            mkbillinstparams[:inamt] = 0
                            mkbillinstparams[:outcnt] = 0
                            mkbillinstparams[:outamt] = 0
                            mkbillinstparams = MkordinstLib.proc_mkbillinsts params,mkbillinstparams
                            mkbillinstparams[:message_code] = ""
                            mkbillinstparams[:remark] = " #{self} line:#{__LINE__} "
                            strsql = %Q%update mkbillinsts set incnt = #{mkbillinstparams[:incnt]},
                                                inamt = #{mkbillinstparams[:inamt]},outcnt = #{mkbillinstparams[:outcnt]},
                                                remark = ' #{mkbillinstparams[:remark]} '
                                                where id = #{params[:mkbillinsts_id]}
                                %
                            ActiveRecord::Base.connection.update(strsql)
            when "mkpayinsts"
		              ActiveRecord::Base.connection.execute("lock table #{params[:segment][2..-1]} in  SHARE ROW EXCLUSIVE mode")
                            ### 　parent 未使用
                            mkpayinstparams = {}
                            mkpayinstparams[:incnt] = 0
                            mkpayinstparams[:inamt] = 0
                            mkpayinstparams[:outcnt] = 0
                            mkpayinstparams[:outamt] = 0
                            mkpayinstparams[:person_id_upd] = params[:person_id_upd]
                            mkpayinstparams = MkordinstLib.proc_mkpayinsts tbldata,mkpayinstparams
                            mkpayinstparams[:remark] = " #{self} line:#{__LINE__} "
                            strsql = %Q%update mkpayinsts set incnt = #{mkpayinstparams[:incnt]},
                                                  inamt = #{mkpayinstparams[:inamt]},outcnt = #{mkpayinstparams[:outcnt]},
                                                  outamt = #{mkpayinstparams[:outamt]} ,
                                                  remark = ' #{mkpayinstparams[:remark]} '
                                                  where id = #{params[:mkpayinsts_id]}
                                  %
                            ActiveRecord::Base.connection.update(strsql)
            when /mkpayschs|mkbillschs|mkbillests|updatepayschs|updatebillschs/
		          ActiveRecord::Base.connection.execute("lock table #{params[:segment][2..-1]} in  SHARE ROW EXCLUSIVE mode")
              ### 　parent 未使用
              if params[:segment] == "updatepayschs" or params[:segment] == "updatebillschs"
                delete_paybillschs(params[:segment],params)
              end
              ###payestsは作成されない。purschsが在庫に引き当っていることがある為。
              ###ArelCtl.proc_createtable は使用しない
              ###bill_loca_id_bill_cust
              amt_src = 0
              isudate = Time.now
              src = {"tblname" => params[:srctblname],"tblid" => params[:srctblid],"trngantts_id" => 0}
              duedate = tbldata["duedate"].to_date
              case params[:segment]
                when "mkpayschs","updatepayschs"
                  strsql = %Q%select b.*,c.id suppliers_id from payments b
                                            inner join suppliers c on c.payments_id_supplier = b.id   
                                            where c.id = #{params[:suppliers_id]}
                                    %
                when "mkbillschs","mkbillests"
                  strsql = %Q%select b.* from bills b
                                                inner join custs c on c.bills_id_cust = b.id   
                                            where c.id = #{params[:custs_id]} 
                                    %
              end
              paybill = ActiveRecord::Base.connection.select_one(strsql)
              case params[:segment]
                when "mkpayschs","updatepayschs"        
                  sch_tbldata = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>0,
                                        "payments_id" => paybill["id"],"suppliers_id" => paybill["suppliers_id"],
                                        "persons_id_upd" => person["id"] ,"trngantts_id" => params[:trngantts_id],
                                        "last_duedate" => params[:last_duedate], "chrgs_id" => paybill["chrgs_id_payment"],
                                        "srctblname" => params[:srctblname],"srctblid" => params[:srctblid]}
                  sch_tblname = "payschs"
                when "mkbillschs","updatebillschs"
                  sch_tbldata = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,
                                        "tax" =>0,
                                        "bills_id" =>paybill["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params[:trngantts_id],
                                        "last_duedate" => params[:last_duedate],"chrgs_id" => paybill["chrgs_id_bill"],
                                        "srctblname" => params[:srctblname],"srctblid" => params[:srctblid]}
                  sch_tblname = "billschs"
              end
                trn_day = duedate.strftime("%d").to_i
                ratejsons = JSON.parse(paybill["ratejson"]) 
                paybill["termof"].split(",").each_with_index do |termof,id|
                    if trn_day <= termof.to_i
                        ratejsons[id].each do |rate|
                            if rate["+day"]  
                                duedate =  duedate.since(rate["+day"].day)
                                duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                            else 
                                if rate["day"] < 28
                                  duedate =  duedate.since(rate["duration"].month)
                                  duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s).to_date
                                else
                                  duedate =  duedate.since((rate["duration"]+ 1).month)
                                  duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "01").to_date
                                  duedate = duedate.to_date.since(-1.day)
                                end
                            end
                            sch_tbldata.merge!({"amt_src" => tbldata["amt"].to_f * rate["rate"] / 100,
                                                 "tax" =>  tbldata["tax"].to_f * rate["rate"] / 100,
                                                 "denomination" => rate["denomination"],"duedate" =>duedate})
                            MkordinstLib.proc_create_paybilltbl(sch_tblname,sch_tbldata)
                            break  
                        end
                    else
                      if termof.to_i < 1   ###随時
                          JSON.parse(mst["ratejson"])[0].each do |rate|
                            if rate["+day"] 
                              duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["+day"].to_s).to_date
                              ord_tbldata.merge!({"amt_src" => tbldata["amt"].to_f * rate["rate"] / 100,
                                                 "tax" =>  tbldata["tax"].to_f * rate["rate"] / 100,
                                                 "denomination" => rate["denomination"],"duedate" =>duedate})
                              MkordinstLib.proc_create_paybilltbl(sch_tblname,ord_tbldata)
                            else
                                3.times{Rails.logger.debug(%Q%class:#{self},line:#{__LINE__} ,\n mst["ratejson"]:#{mst["ratejson"]},\n termof:#{termof}%)}
                                raise
                            end
                          end
                      else  
                        if paybill["termof"].split(",").length == (id + 1)
                          JSON.parse(paybill["ratejson"])[0].each do |rate| 
                            duedate =  duedate.since((rate["duration"] + 1).month)
                            duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s).to_date
                            sch_tbldata.merge!({"amt_src" => tbldata["amt"].to_f * rate["rate"] / 100,
                                                 "tax" =>  tbldata["tax"].to_f * rate["rate"] / 100,
                                                 "denomination" => rate["denomination"],"duedate" =>duedate})
                            MkordinstLib.proc_create_paybilltbl(sch_tblname,sch_tbldata)
                          end
                        end
                      end
                    end
                end
                        #                            
            when "mkschs"  ### XXXXschs,ordsの時prdschs,purschsを作成
              parent = tbldata.dup
              trnganttkey ||= 0  ###keyのカウンター
              gantt = params[:gantt].dup
              gantt_key = gantt["key"]
              gantt["mlevel"] = gantt["mlevel"].to_i+1
              gantt["paretblname"] = parent["tblname"] = tblname
              gantt["paretblid"] = parent["tblid"] =  tblid
              gantt["itms_id_pare"] = gantt["itms_id_trn"]
              gantt["duedate_pare"] = gantt["duedate_trn"]
              gantt["toduedate_pare"] = gantt["toduedate_trn"]
              gantt["starttime_pare"] = gantt["starttime_trn"]
              gantt["processseq_pare"] = gantt["processseq_trn"]
              gantt["qty_sch_pare"] = gantt["qty_sch"] 
              gantt["shelfnos_id_pare"] = gantt["shelfnos_id_trn"]
              gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to_trn"]
              gantt["qty_pare"] = gantt["qty"].to_f  
              parent["qty_handover"] =  gantt["qty_handover"]
              parent["shelfnos_id"] = gantt["shelfnos_id_trn"]
              parent["trngantts_id"] = gantt["trngantts_id"]   ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
              parent["unitofduration"] =  gantt["unitofduration"] 
              reqparams[:parent] = parent.dup
              last_lotstks = []
              ActiveRecord::Base.connection.select_all(ArelCtl.proc_nditmSql(tbldata["opeitms_id"])).each do |nd|
                  trnganttkey += 1
                  gantt["key"] = gantt_key + format('%05d', trnganttkey)
                  gantt["consumunitqty"] = nd["consumunitqty"]
                  gantt["consumminqty"] = nd["consumminqty"]
                  gantt["consumchgoverqty"] = nd["consumchgoverqty"] 
                  case nd["prdpur"]  ###opeitmdが登録されてないとprdords,purordsは作成されない。
                  when "prd","pur"
                      blk = RorBlkCtl::BlkClass.new("r_"+nd["prdpur"]+"schs")
                      command_c = blk.command_init   ###  tblname=paretblname
                      command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,tblname,command_c)  ###tblname = paretblname
                      command_c["#{nd["prdpur"]}sch_created_at"] = Time.now
                      setGanttFromNd(gantt, nd) do
                          gantt["tblname"] = nd["prdpur"] + "schs"
                          gantt["consumtype"] = (nd["consumtype"]||="CON")
                      end
                      ### gantt["qty_handover"] = (qty_require / nd["packqty"]).ceil * nd["packqty"] 
                      gantt["qty_handover"] = qty_require   
                      gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                      gantt["toduedate_trn"] = command_c["#{gantt["tblname"].chop}_toduedate"]
                      gantt["qty_require"] = qty_require
                      gantt["qty_sch"] = command_c["#{gantt["tblname"].chop}_qty_sch"]
                      gantt["starttime_trn"] =  command_c["#{gantt["tblname"].chop}_starttime"]
                      ###作業場所の稼働日考慮要
                      gantt["locas_id_trn"] = command_c["shelfno_loca_id_shelfno"]
                      reqparams[:mkprdpurords_id] = 0
                      gantt["tblid"] = command_c["id"]
                      command_c["#{gantt["tblname"].chop}_person_id_upd"] = gantt["persons_id_upd"] = reqparams[:person_id_upd]
                      reqparams[:gantt] =  gantt.dup
                      reqparams = blk.proc_private_aud_rec(reqparams,command_c) ###create pur,prdschs
                      if gantt["consumtype"] == "CON"  ###出庫 消費と金型・設備の使用
                        reqparams[:child] =  nd.dup
                        reqparams[:screenCode] = "r_conschs"
                        last_lotstks <<  Shipment.proc_create_consume(reqparams)   ###自身の消費を作成
                      end
                  when "run"
                      reqparams[:child] =  nd.dup
                      reqparams[:screenCode] = "r_conschs"
                      last_lotstks <<  Shipment.proc_create_consume(reqparams)   ###自身の消費を作成
                      ###
                      # gantt 作成
                      ###
                      setGanttFromNd(gantt, nd) do
                          gantt["tblname"] = "conschs"
                          gantt["consumtype"] = "CON"
                      end
                      consume_tbldata = reqparams[:tbldata].dup
                      gantt["duedate_trn"] = gantt["toduedate_trn"] = consume_tbldata["duedate"]
                      gantt["qty_require"] = gantt["qty_handover"] = 0
                      gantt["qty_sch"] = consume_tbldata["qty_sch"]
                      strsql = %Q%select locas_id_shelfno from shelfnos where id = #{consume_tbldata["shelfnos_id_fm"]}%
                      locas_id_shelfno = ActiveRecord::Base.connection.select_value(strsql)
                      gantt["locas_id_trn"] = locas_id_shelfno
                      starttime,message = CtlFields.proc_calculate_working_day("run",consume_tbldata["duedate"].to_date,1,"-",locas_id_shelfno)
                      gantt["starttime_trn"] =  starttime
                      ###作業場所の稼働日考慮要
                      reqparams[:mkprdpurords_id] = 0
                      gantt["tblid"] = consume_tbldata["id"]
                      gantt["persons_id_upd"] = reqparams[:person_id_upd]
                      reqparams[:gantt] =  gantt.dup
                      ope = Operation::OpeClass.new(reqparams)
                      ope.proc_trngantts_insert() 
                      ###
                      # runner gateの作成
                      ###
                      createRunnerGate(ope.proc_opeParams)
                  else  ###
                      nd["opeitms_id"] = 0
                      nd["shelfnos_id"] = 0
                      nd["shelfnos_id"] = 0
                      nd["locas_id_to"] = 0
                      nd["locas_id"] = 0
                      case nd["classlist_code"]
                      when "apparatus"  ###
                           dvsParams = reqparams.dup
                           dvsParams[:gantt] = gantt.dup
                           dvsParams[:child] = nd.dup
                           dvsParams[:gantt] = gantt.dup
                           dvsParams[:screenCode] = "r_prdschs"
                           dvs = Operation::OpeClass.new(dvsParams)  ###
                           dvs.proc_add_dvs_data(nd)
                           dvs.proc_add_erc_data(nd)
                      when "mold","ITool"       ###金型 ###工具
                          reqparams[:mkprdpurords_id] = 0
                          gantt["consumtype"] = (nd["consumtype"]||="mold")
                          reqparams[:gantt] = gantt.dup
                          reqparams[:child] = nd.dup
                          reqparams[:gantt] = gantt.dup
                          reqparams[:child]["units_id_case_shp"] = nd["units_id"]
                          strsql = %Q&
                                      select l.shelfnos_id from lotstkhists l 
                                                  inner join shelfnos s on s.id = l.shelfnos_id
                                                  where l.itms_id = #{nd["itms_id"]}  and s.code = '#{nd["classlist_code"]}'
                                                  order by l.starttime desc
                              &
                          shelfnos_id = ActiveRecord::Base.connection.select_value(strsql)
                          reqparams[:child]["shelfnos_id_to"] = (shelfnos_id ||= "0")
                          last_lotstks_parts = Shipment.proc_create_shpxxxs(reqparams) do  ###
                              "shpest"
                          end
                          last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
                      when "installationCharge"   ###設置
                           ercParams = reqparams.dup
                           ercParams[:gantt] = gantt.dup
                           ercParams[:child] = nd.dup
                           ercParams[:gantt] = gantt.dup
                           ercParams[:screenCode] = "r_prdschs"
                           erc = Operation::OpeClass.new(ercParams)  ###
                           erc.proc_add_erc_data(nd)
                      else
                          blk = RorBlkCtl::BlkClass.new("r_dymschs")
                          command_c = blk.command_init
                          nd["prdpur"] = "dym"
                          gantt["tblname"] = 'dymschs'
                          nd["locas_id"] = 0 
                          nd["locas_id_to"] = 0
                          command_c,qty_require = add_update_prdpur_table_from_nditm(nd,parent,tblname,command_c)  ###tblname -->paretblname
                          command_c["dymsch_itm_id_dym"] = nd["itms_id"]
                          command_c["dymsch_shelfno_id"] = 0
                          command_c["dymsch_shelfno_id_to"] = 0
                          gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                          gantt["locas_id_trn"] = 0
                          gantt["shelfnos_id_trn"] = 0
                          gantt["qty_require"] = qty_require
                          gantt["qty_handover"] = qty_require  
                          gantt["processseq_trn"] = command_c["#{gantt["tblname"].chop}_processseq"] = 999
                          gantt["toduedate_trn"] = command_c["#{gantt["tblname"].chop}_toduedate"]
                          gantt["qty_sch"] = command_c["#{gantt["tblname"].chop}_qty_sch"]
                          command_c["#{gantt["tblname"].chop}_person_id_upd"] = gantt["persons_id_upd"] = reqparams[:person_id_upd]
                          command_c["#{gantt["tblname"].chop}_created_at"] = Time.now
                          gantt["starttime_trn"] =  command_c["#{gantt["tblname"].chop}_starttime"]
                          trnganttkey += 1
                          gantt["key"] = gantt_key + format('%05d', trnganttkey)
                          gantt["tblid"] = command_c["id"]
                          gantt["itms_id_trn"] = nd["itms_id"]
                          gantt["locas_id_to_trn"] = 0
                          gantt["consumtype"] = (nd["consumtype"]||="CON")
                          gantt["shelfnos_id_to_trn"] = 0
                          gantt["chilnum"] = nd["chilnum"]
                          gantt["parenum"] = nd["parenum"]
                          ###作業場所の稼働日考慮要
                          reqparams[:mkprdpurords_id] = 0
                          reqparams[:gantt] = gantt.dup
                          reqparams[:child] = nd.dup
                          reqparams = blk.proc_private_aud_rec(reqparams,command_c) ###create pur,prdschs
                          if gantt["consumtype"] == "CON"  ###出庫 消費と金型・設備の使用
                            reqparams[:child] =  nd.dup
                            reqparams[:screenCode] = "r_conschs"
                            last_lotstks << Shipment.proc_create_consume(reqparams)
                          end
                      end
                  end
              end       
              if !last_lotstks.empty?
                ArelCtl.proc_add_update_lotstkhists(last_lotstks,params[:person_id_upd])
              end
            when "mkShpschConord"  ### prd,purordsの時shpschs,conordsを作成
                  ### purords,prdordsでshpordsを作成しないのは xxxinsts等でshpordsを作成したいため
                  parent = tbldata.dup
                  parent["duedate"] = parent["duedate"].to_time
                  parent["starttime"] = parent["starttime"].to_time
                  parent["tblname"] = gantt["tblname"]
                  parent["tblid"] = gantt["tblid"]
                  parent["trngantts_id"] = gantt["trngantts_id"]  ### shpxxxs,conxxxsのtrngantts_idは親のtrngantts_id
                  child = {}
                  last_lotstks = []
                  ActiveRecord::Base.connection.select_all(ArelCtl.proc_pareChildTrnsSqlGroupByChildItem(parent)).each do |nd|
                  reqparams[:mkprdpurords_id] = 0
                  child = nd.dup
                  case child["consumtype"]
                    when "CON"  ###出庫 消費 
                        child["packno"] = ""
                        child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                        reqparams[:parent] = parent.dup
                        reqparams[:child] = child.dup
                        if child["shpordauto"] != "M" and nd["pare_shelfnos_id"] != nd["shelfnos_id_to"]  ###手動出荷ではない、親の作業場所!=部品の保管場所
                            reqparams[:screenCode] = "r_shpschs"    
                            last_lotstks_parts =  Shipment.proc_create_shpxxxs(reqparams) do  ###prd,purordsによる自動作成 
                                            "shpsch"
                            end
                            last_lotstks.concat last_lotstks_parts  if last_lotstks_parts.size > 0  ###nilを避ける
                        end
                        if child["consumauto"] != "M"  ###自動の時
                            reqparams[:screenCode] = "r_conords"    
                            last_lotstks <<  Shipment.proc_create_consume(reqparams)
                        end
                    when "mold","ITool"  ###出庫 金型・工具の使用
                        child["packno"] = ""
                        child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                        reqparams[:parent] = parent.dup
                        reqparams[:child] = child.dup
                        if child["shpordauto"] != "M"
                            reqparams[:screenCode] = "r_shpschs"  
                            last_lotstks_parts =  Shipment.proc_create_shpxxxs(reqparams) do  ###prd,purordsによる自動作成 
                                  "shpsch"
                            end
                            last_lotstks.concat last_lotstks_parts  if last_lotstks_parts.size > 0  ###nilを避ける
                        end    
                    when "BYP" ,"run"  ###副産物,runner
                        ###消費はない
                        child["packno"] = ""
                        child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                        reqparams[:parent] = parent.dup
                        reqparams[:child] = child.dup
                        reqparams[:screenCode] = "r_shpschs"  
                        last_lotstks_parts =  Shipment.proc_create_shpxxxs(reqparams) do  ###prd,purordsによる自動作成 
                          "shpsch"
                        end
                        last_lotstks.concat last_lotstks_parts if last_lotstks_parts.size > 0  ###nilを避ける
                    when "apparatus"  ###設備の使用
                            next
                    end
                  end 
                  if !last_lotstks.empty?
                            ArelCtl.proc_add_update_lotstkhists(last_lotstks,params[:person_id_upd])
                  end
            when "mkprdpurchildFromCustxxxs"  ### custxxxsからpur,purschsに変更"custord_crr_id_custord" 
                            ###　parent 未使用
                            gantt = params[:gantt].dup
                            gantt["mlevel"] = 1
                            gantt["key"] = "00000000"
                            gantt["qty_sch_pare"] = 0 
                            last_lotstks = []
                            case gantt["orgtblname"] ###parent = orgtbl
                            when "custords"
                                qty =  gantt["qty"].to_f
                                ### free custschsへの引き当て
                                get_free_custschs_sql = %Q&
                                     --- free custschsへの引き当て
                                        select  t.id trngantts_id,link.qty_src,t.orgtblname tblname,t.orgtblid tblid,link.id link_id,link.srctblid from trngantts t 
                                                            inner join linkcusts link on link.srctblid = t.tblid  and t.id = link.trngantts_id
                                                                                    and link.srctblname = link.tblname and link.srctblid = link.tblid
                                                                                    and link.srctblname = 'custschs' and link.qty_src > 0 
                                                            where t.orgtblname = 'custschs' and t.paretblname = 'custschs' and t.tblname = 'custschs'
                                                                    and t.orgtblid = t.paretblid and t.tblid = t.paretblid
                                                                    and t.prjnos_id = #{gantt["prjnos_id"]} 
                                                                    and itms_id_pare = #{gantt["itms_id_pare"]} and processseq_pare = #{gantt["processseq_pare"]}
                                                                    and link.srctblname = t.orgtblname 
                                                            order by t.duedate_org

                                &
                                ActiveRecord::Base.connection.select_all(get_free_custschs_sql).each do |sch|
                                    ###  custschsに引き当ててもcustschs.qty_schは減しない
                                    # custsch_blk = RorBlkCtl::BlkClass.new("r_custschs")
                                    # command_c = custsch_blk.command_init
                                    # rec = ActiveRecord::Base.connection.select_one(%Q&  select * from r_custschs where id = #{sch["srctblid"]}  &)
                                    # command_c = command_c.merge(rec)
                                    # command_c["sio_classname"] = %Q&_update_from_custschs &
                                    # command_c["id"] = command_c["custsch_id"] = sch["tblid"]
                                    if qty >= sch["qty_src"].to_f
                                            qty_src = sch["qty_src"].to_f
                                            qty -= qty_src
                                            sch["qty_src"] = 0
                                    else
                                        qty_src = qty
                                        sch["qty_src"] = sch["qty_src"].to_f - qty
                                        qty = 0
                                    end
                                    update_sql = %Q&  --- free custschs 減
                                            update linkcusts set qty_src = #{sch["qty_src"]},remark = '#{self} line:#{__LINE__}'||left(remark,3000),
                                                    updated_at = current_timestamp
                                                    where id = #{sch["link_id"]}
                                            &
                                    ActiveRecord::Base.connection.update(update_sql) ###引き当ったcustschsの減gantt = reqparams[:gantt].dup
                                    src = {"tblname" => "custschs","tblid" => sch["srctblid"],"trngantts_id" => sch["trngantts_id"],"remark" => "#{self},line:#{__LINE__} "}
                                    base = {"tblname" => "custords","tblid" => gantt["orgtblid"],"qty_src" => qty_src,"amt_src" => 0,"persons_id_upd" => reqparams[:person_id_upd]}
                                    ArelCtl.proc_insert_linkcusts(src,base)  ###
                                    last_lotstks << {"tblname" => "custschs","tblid" => sch["srctblid"],"qty_src" => qty_src}
                                end
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"] = qty
                                update_sql = %Q&  --- custords free 引当後
                                        update linkcusts set qty_src = #{qty},remark = ' #{self} line:#{__LINE__} '||left(remark,100),
                                                updated_at = current_timestamp
                                                where tblid = #{gantt["tblid"]} and srctblid = #{gantt["tblid"]} and trngantts_id = #{gantt["trngantts_id"]}
                                                and tblname = 'custords' and srctblname = 'custords'
                                        &
                                ActiveRecord::Base.connection.update(update_sql)  ###custords.linkcusts.qtyの減
                            when "custschs"
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"]
                            else
                                3.times{Rails.logger.debug" class:#{self},line:#{__LINE__} ,orgtblname:#{gantt["orgtblname"]} error "}
                                raise
                            end
                            ###
                            #
                            ###
                            qty_sch = gantt["qty_sch"]
                            gantt["qty"] = 0
                            gantt["qty_require"] = tbldata["qty_require"] = gantt["qty_handover"] 
                            child = {"itms_id_nditm" => gantt["itms_id_trn"],"processseq_nditm" => gantt["processseq_trn"] ,
                                    "opeitms_id"=> tbldata["opeitms_id"],
                                    "parenum" => 1,"chilnum" => 1,"qty_sch" => qty_sch, 
                                    "locas_id" => opeitm["locas_id_shelfno"],"shelfnos_id" => opeitm["shelfnos_id_opeitm"], 
                                    "locas_id_to" => opeitm["locas_id_shelfno_to"],"shelfnos_id_to" => opeitm["shelfnos_id_to_opeitm"],  
                                    "consumunitqty" => 1,"consumminqty" => 0,"consumchgoverqty" => 0}
                            child.merge!(opeitm)
                            blk = RorBlkCtl::BlkClass.new("r_"+ opeitm["prdpur"]+"schs")
                            command_c = blk.command_init
                            command_c["#{opeitm["prdpur"]}sch_person_id_upd"] = reqparams[:person_id_upd]
                            command_c["#{opeitm["prdpur"]}sch_duedate"] = tbldata["starttime"].to_time.strftime("%Y-%m-%d") + " 16:00:00"
                            command_c,qty_require = add_update_prdpur_table_from_nditm(child,tbldata,paretblname,command_c)  ###tbldata--->parent
                            command_c["#{opeitm["prdpur"]}sch_created_at"] = Time.now
                            reqparams[:gantt] = gantt.dup
                            reqparams = blk.proc_private_aud_rec(reqparams,command_c)   
                            result_f = '1'
                            if !last_lotstks.empty?
                              ArelCtl.proc_add_update_lotstkhists(last_lotstks,params[:person_id_upd])
                            end
            else  
                        result_f = '6'
                        3.times{Rails.logger.debug" class:#{self},line:#{__LINE__}  program(segment) nothing  \n reqparams:#{reqparams}"}  
                    end ## process   
                    strsql = %Q%update processreqs set result_f = '#{result_f}',remark = '#{remark}' where id = #{processreq["id"]}
                            %
                    ActiveRecord::Base.connection.update(strsql)
                    processreq = ActiveRecord::Base.connection.select_one(perform_strsql)
                    if processreq
                        params = JSON.parse(processreq["reqparams"]).symbolize_keys  
                    end
          end
        rescue
            ActiveRecord::Base.connection.rollback_db_transaction()
            ActiveRecord::Base.connection.begin_db_transaction()
            remark =  %Q% $@: #{$@[0..200]} :class #{self} : LINE #{__LINE__} $!: #{$!} %  ###evar not defined
            Rails.logger.debug"error class #{self} : #{Time.now}: #{$@} "
            Rails.logger.debug"error class #{self} : $!: #{$!} "
            Rails.logger.debug"error class #{self} : params: #{params} "
            if processreq
                strsql = %Q%update processreqs set result_f = '5'  where seqno = #{pid} and id < #{processreq["id"]}
                        %
                ActiveRecord::Base.connection.update(strsql)
                strsql = %Q%update processreqs set result_f = '9'  where seqno = #{pid} and id = #{processreq["id"]}
                %
                ActiveRecord::Base.connection.update(strsql)

                strsql = %Q%update processreqs set result_f = '8'  where seqno = #{pid} and id > #{processreq["id"]}
                %
                ActiveRecord::Base.connection.update(strsql)
            end           
            ActiveRecord::Base.connection.commit_db_transaction()
        else
            ActiveRecord::Base.connection.commit_db_transaction()
        end  
    end
 
	  ###schsの追加	paretblname =~ /schs$|ords$/の時呼ばれる 
	  def add_update_prdpur_table_from_nditm(nd,parent,paretblname,command_init) ### id processreqsのid child-->nditms  parent ===> r_prd,pur XXXs
            parent["qty_sch"] = parent["qty_sch"].to_f + parent["qty"].to_f 
            if paretblname =~ /ords/   ###ordsから _schを作成
                parent.delete("qty") 
                parent.delete("amt") 
            end
		    command_c,qty_require,err = CtlFields.proc_schs_fields_making(nd,parent,command_init)
		    return command_c,qty_require,err
    end

    def setGanttFromNd(gantt, nd)
        yield
        gantt["itms_id_trn"] = nd["itms_id"]
        gantt["processseq_trn"] = nd["processseq"]
        gantt["shelfnos_id_trn"] = nd["shelfnos_id"]
        gantt["shelfnos_id_to_trn"] = nd["shelfnos_id_to"]
        gantt["chilnum"] = nd["chilnum"]
        gantt["parenum"] = nd["parenum"]
        gantt["consumunitqty"] =  nd["consumunitqty"]
        gantt["consumminqty"]  = nd["consumminqty"]
        gantt["consumchgoverqty"] = nd["consumchgoverqty"]
        gantt["consumauto"] =  (nd["consumauto"]||="")
        gantt["unitofduration"] =  nd["unitofduration"]
    end

    def createRunnerGate(gateParams)
        gantt = gateParams[:gantt].dup 
        strsql = %Q%select o.id opeitms_id,o.itms_id,o.processseq,shelfnos_id_opeitm shelfnos_id,shelfnos_id_to_opeitm shelfnos_id_to,
                            o.locas_id,o.locas_id_to,o.priority,n.parenum ,n.chilnum ,o.packqty
                                from nditms n
                                 inner join (select s.locas_id_shelfno locas_id,tos.locas_id_shelfno locas_id_to,ope.* from opeitms ope
                                                    inner join shelfnos s on s.id = ope.shelfnos_id_opeitm
                                                    inner join shelfnos tos on tos.id = ope.shelfnos_id_to_opeitm
                                            )o on o.id = n.opeitms_id 
                                 where n.itms_id_nditm = #{gantt["itms_id_trn"]} and n.processseq_nditm = #{gantt["processseq_trn"]}
                                   and n.consumtype = 'run'%
        gate = ActiveRecord::Base.connection.select_one(strsql)  ###gate itms_id,processseqを求める
        if gate
          gantt["paretblname"] = gantt["tblname"]
          gantt["paretblid"] = gantt["tblid"] 
          gantt["itms_id_pare"] = gantt["itms_id_trn"]
          gantt["duedate_pare"] = gantt["duedate_trn"]
          gantt["toduedate_pare"] = gantt["toduedate_trn"]
          gantt["starttime_pare"] = gantt["starttime_trn"]
          gantt["processseq_pare"] = gantt["processseq_trn"]
          gantt["qty_sch_pare"] = gantt["qty_sch"] 
          gantt["shelfnos_id_pare"] = gantt["shelfnos_id_trn"]
          gantt["shelfnos_id_to_pare"] = gantt["shelfnos_id_to_trn"]
          nd = {"locas_id_pare" => gantt["locas_id_trn"],
                "itms_id" => gate["itms_id"],"processseq" => gate["processseq"],
                "shelfnos_id" => gate["shelfnos_id"],"shelfnos_id_to" => gate["shelfnos_id_to"],
                "locas_id" => gate["locas_id"],"locas_id_to" => gate["locas_id_to"],"priority" => gate["priority"],
                "opeitms_id"=> gate["opeitms_id"],
                "parenum" => gate["chilnum"],"chilnum" => gate["parenum"],  
                  "packqty" => gate["packqty"],###
                "consumunitqty" => 1,"consumminqty" => 0,"consumchgoverqty" => 0,"consumauto" => ""}
          strsql = %Q%select sum(t.qty_sch) qty_sch from trngantts t  ---runner
                                 where t.orgtblname = '#{gantt["orgtblname"]}' and t.orgtblid = #{gantt["orgtblid"]}
                                  and t.itms_id_trn = #{gate["itms_id"]} and t.processseq_trn = #{gate["processseq"]}
                                  group by t.itms_id_trn,t.processseq_trn
                                   %
          qty_sch = ActiveRecord::Base.connection.select_value(strsql)
          if qty_sch.to_f > 0  ###金型により部品作成済   .to_f:nil --> 0
                if gantt["qty_sch"].to_f < qty_sch.to_f / gate["chilnum"].to_f * gate["parenum"].to_f  ###不足のため新たな親作成
                  parent["qty_sch"] = parent["qty_handover"] = (qty_sch.to_f - gate["qty_sch"].to_f ) / gate["chilnum"].to_f * gate["parenum"].to_f
                  parent = gateParams[:tbldata].dup
                  parent["starttime"] = gantt["starttime_trn"]
                  blk = RorBlkCtl::BlkClass.new("r_prdschs")
                  command_c = blk.command_init
                  command_c["shelfno_loca_id_shelfno"] = gate["locas_id"]
                  command_c["shelfno_loca_id_shelfno_to"] = gate["locas_id_to"]
                  command_c["prdsch_person_id_upd"] = gateParams[:person_id_upd]
		              command_c,qty_require,err = CtlFields.proc_schs_fields_making(nd,parent,command_c)
                  gateParams[:classname] = "_insert_"
                  gantt["mlevel"] = gantt["mlevel"].to_i+1
                  gantt["key"] = gantt["key"] + "10000"
                  gantt["qty_handover"] = command_c["prdsch_qty_handover"]
                  gateParams[:gantt] = gantt.dup
                  gateParams = blk.proc_private_aud_rec(gateParams,command_c) ###
                  return
                else
                  ###gateのtrngantts作成
                  ###
                  # runner prdschsts　登録済
                  ###
                  strsql = %Q%select t.tblname,t.tblid,max(t.key) "key" from trngantts t  ---gate
                                 where t.orgtblname = '#{gantt["orgtblname"]}' and t.orgtblid = #{gantt["orgtblid"]}
                                  and t.itms_id_trn = #{gate["itms_id"]} and t.processseq_trn = #{gate["processseq"]}
                                  group by t.itms_id_trn,t.processseq_trn,t.tblname,t.tblid
                                   %
                  gate_tblname = ActiveRecord::Base.connection.select_one(strsql)
                  strsql = %Q%select prd.*,o.itms_id,o.processseq,o.packqty,o.maxqty
                                          from #{gate_tblname["tblname"]} prd
                                          inner join opeitms o on o.id = prd.opeitms_id
                                        where prd.id = #{gate_tblname["tblid"]} for update%
                  gate_tbldata = ActiveRecord::Base.connection.select_one(strsql)
                  if gate_tbldata.nil?
                    raise " class:#{self} ,line:#{__LINE__} \n strsql:#{strsql} "
                  else
                    gantt["key"] = gate_tblname["key"][0..-7] + format('%05d',(gate_tblname["key"][-6..-1].to_i + 1))
                    gantt["tblname"] = gate_tblname["tblname"]
                    gantt["tblid"] = gate_tblname["tblid"] 
                    gantt["itms_id_trn"] = gate_tbldata["itms_id"]
                    gantt["duedate_trn"] = gate_tbldata["duedate"]
                    gantt["toduedate_trn"] = gate_tbldata["toduedate"]
                    gantt["starttime_trn"] = gate_tbldata["starttime"]
                    gantt["processseq_trn"] = gate_tbldata["processseq"]
                    gantt["packqty"] = gate_tbldata["packqty"]
                    gantt["maxqty"] = gate_tbldata["maxqty"]
                    gantt["qty_sch"] = gantt["qty_handover"] = gate_tbldata["qty_sch"] = 0
                    gantt["shelfnos_id_trn"] = gate_tbldata["shelfnos_id"]
                    gantt["shelfnos_id_to_trn"] = gate_tbldata["shelfnos_id_to"]
                    gantt["chilnum"] = nd["chilnum"]
                    gantt["parenum"] = nd["parenum"]
                    gantt["qty"] = 0 
                    gantt["id"] = gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
                    gantt["remark"] = "runner parts qty_schは代表のqty_schを利用 class:#{self} ,line:#{__LINE__} "
                    ArelCtl.proc_insert_trngantts(gantt,gate_tbldata)
                  end
                end
          else  ### runner 作成
                gantt["mlevel"] = gantt["mlevel"].to_i+1
                gantt["key"] = gantt["key"] + "00000"
                parent = gateParams[:tbldata].dup
                ###parent["qty_sch"] = parent["qty_handover"] = (gantt["qty_sch"].to_f ) / gate["chilnum"].to_f * gate["parenum"].to_f
                parent["qty_sch"] = parent["qty_handover"] = gantt["qty_sch"].to_f 
                parent["starttime"] = gantt["starttime_trn"]
                blk = RorBlkCtl::BlkClass.new("r_prdschs")
                command_c = blk.command_init
                command_c["shelfno_loca_id_shelfno"] = gate["locas_id"]
                command_c["shelfno_loca_id_shelfno_to"] = gate["locas_id_to"]
                command_c["prdsch_person_id_upd"] = gateParams[:person_id_upd]
		            command_c,qty_require,err = CtlFields.proc_schs_fields_making(nd,parent,command_c)
                gateParams[:classname] = "_insert_"
                gantt["qty_handover"] = gantt["qty_sch"] = command_c["prdsch_qty_sch"]
                gantt["remark"] = "runner main class:#{self} ,line:#{__LINE__} "
                gateParams[:gantt] = gantt.dup
                gateParams = blk.proc_private_aud_rec(gateParams,command_c) ###
                return   ### trnganttsの作成は不要
          end
        else
			      raise " class:#{self} ,line:#{__LINE__} runner operation error\n strsql:#{strsql} "
        end
    end


    

    def delete_paybillschs(segment,params)
        ###check billscks exists or not
        case segment
        when "updatebillords"
            # blk = RorBlkCtl::BlkClass.new("r_billords")
            # command_c = blk.command_init
            # command_c["billord_accounttitle"] = "A"  ### 売上
            paybillsch = "billord"
            mst = "bill"
            str_amt = "amt"
        when "updatebillschs"
            # blk = RorBlkCtl::BlkClass.new("r_billschs")
            # command_c = blk.command_init
            # command_c["billsch_accounttitle"] = "A"  ### 売上
            paybillsch = "billsch"
            mst = "bill"
            str_amt = "amt_sch"
        when "updatebillests"
            # blk = RorBlkCtl::BlkClass.new("r_billests")
            # command_c = blk.command_init
            # command_c["billest_accounttitle"] = "A"  ### 売上
            mst = "bill"
            paybillsch = "billest"
            str_amt = "amt_est"
        when "updatepayschs"
            # blk = RorBlkCtl::BlkClass.new("r_payschs")
            # command_c = blk.command_init
            # command_c["paysch_accounttitle"] = "1"  ### 仕入
            mst = "payment"
            paybillsch = "paysch"
            str_amt = "amt_sch"
        when "updatepayords"
            # blk = RorBlkCtl::BlkClass.new("r_payords")
            # command_c = blk.command_init
            # command_c["payord_accounttitle"] = "1"  ### 仕入
            mst = "payment"
            paybillsch = "payord"
            str_amt = "amt"
        end 

        strsql = %Q& --- payxxxsとpurxxxs、billxxxsとcustxxxsの関係
                    select * from srctbllinks where srctblname = '#{params[:srctblname]}' and srctblid = #{params[:srctblid]} 
                &
        link =  ActiveRecord::Base.connection.select_one(strsql)

        update_sql = %Q&
                    update srctbllinks set amt_src = amt_src - #{params[:last_amt]} where id = #{link["id"]}
        &

        ActiveRecord::Base.connection.update(update_sql)
    end

    # def delete_paybillords(params)
    #     strsql = %Q&
    #                   select * from  srctbllinks 
    #                              where tblname = '#{params[:gantt]["tblname"]}' 
    #                              and srctblname = '#{params[:srctblname]}' and tblid = #{params[:srctblid]}
    #              &
    #     ActiveRecord::Base.connection.select_all(strsql).each do |rec|
    #             update_sql = %Q&
    #                     update srctbllinks set amt_src = 0
    #                             where #{rec["id"]}
    #                 &
    #             ActiveRecord::Base.connection.update(update_sql)
    #             update_sql = %Q&
    #                      update payords set amt = amt -  #{rec["amt_src"]}
    #                              where id = #{rec["tblid"]}
    #              &
    #             ActiveRecord::Base.connection.update(update_sql)
    #     end
    # end 
    ###  
    #
    ###
    def getprdpurord_from_linktbls(tblname,tblid,prdpur)  ### xxxactsからxxxordsを求める
        ords = []
        notords = []
        strsql = %Q&
                    select * from linktbls where tblname = '#{tblname}' and tblid = #{tblid}
                                            and srctblname like '#{prdpur}%' and srctblname != tblname
        &
        ActiveRecord::Base.connection.select_all(strsql).each do |rec|
            if rec["srctblname"] == "#{prdpur}ords"
                ords << rec
            else
                notords << rec
            end
        end
        return ords,notords
    end    
    ###  
    #
    # ###     
    # def mk_ercschsords(nd,reqparams,erctblname)
    #     prdtblname = erctblname.sub("erc","prd")
    #     dvstblname = erctblname.sub("erc","dvs")
    #     gantt = reqparams[:gantt].dup
    #     parent = reqparams[:tbldata].dup
    #     reqparams[:mkprdpurords_id] = 0
    #     gantt["tblname"] = erctblname
    #     gantt["qty_require"] = 1
    #     gantt["qty_handover"] = 0
    #     case erctblname
    #     when /schs/
    #         gantt["qty_sch"] = 1 
    #         gantt["qty"] = 0 
    #         gantt["qty_stk"] = 0 
    #     when /ords/
    #         gantt["qty_sch"] = 0
    #         gantt["qty"] = 1 
    #         gantt["qty_stk"] = 0 
    #     else
    #         3.times{Rails.logger.debug"  erctbl not suppurt:#{erctblname},class: #{self} , line:#{__LINE__} "}
    #         raise 
    #     end
    #     gantt["consumtype"] = "apparatus"  ###parenum,chilnumは1
    #     gantt_key = gantt["key"]
    #     trnganttkey = 0
    #     if nd["changeoverlt"].to_f > 0 and nd["changeoverop"].to_i > 0
    #         nd["prdpur"] = "erc"
    #         nd["changeoverop"].to_i.times do
    #             trnganttkey += 1
    #             gantt["key"] = gantt_key + format('%05d', trnganttkey)
    #             blk = RorBlkCtl::BlkClass.new("r_ercschs")
    #             command_c = blk.command_init
    #             command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
    #             command_c["#{erctblname.chop}_created_at"] = Time.now
    #             command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = reqparams[:person_id_upd]
    #             command_c["#{erctblname.chop}_processname"] = "changeover"
    #             command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname(prdschs)
    #             next if 
    #             ### perfotm　実行のため　.to_json日付が"2024-12-17T20:53:26.000Z"になている
    #             command_c["#{erctblname.chop}_starttime"] =  command_c["#{erctblname.chop}_starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S")
    #             command_c["#{erctblname.chop}_duedate"] = command_c["#{erctblname.chop}_duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
    #             gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
    #             gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
    #             reqparams[:gantt] = gantt.dup
    #             reqparams[:child] = nd.dup
    #             reqparams[:gantt] = gantt.dup
    #             reqparams = blk.proc_private_aud_rec(reqparams,command_c) ###
    #         end
    #     end
    #     if nd["durationfacility"].to_f > 0 and nd["requireop"].to_i > 0
    #         nd["prdpur"] = "erc"
    #         nd["requireop"].to_i.times do
    #             trnganttkey += 1
    #             gantt["key"] = gantt_key + format('%05d', trnganttkey)
    #             blk = RorBlkCtl::BlkClass.new("r_ercschs")
    #             command_c = blk.command_init
    #             command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
    #             command_c["#{erctblname.chop}_created_at"] = Time.now
    #             command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = reqparams[:person_id_upd]
    #             command_c["#{erctblname.chop}_processname"] = "require"
    #             command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname
    #             next if err
    #             gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
    #             gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
    #             reqparams[:gantt] = gantt.dup
    #             reqparams[:child] = nd.dup
    #             reqparams[:gantt] = gantt.dup
    #             reqparams = blk.proc_private_aud_rec(reqparams,command_c) ###
    #         end
    #     end
    #     if nd["postprocessinglt"].to_f > 0 and nd["postprocessingop"].to_i > 0
    #         nd["prdpur"] = "erc"
    #         nd["postprocessingop"].to_i.times do
    #             trnganttkey += 1
    #             gantt["key"] = gantt_key + format('%05d', trnganttkey)
    #             blk = RorBlkCtl::BlkClass.new("r_ercschs")
    #             command_c = blk.command_init
    #             command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
    #             command_c["#{erctblname.chop}_created_at"] = Time.now
    #             command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = reqparams[:person_id_upd]
    #             command_c["#{erctblname.chop}_processname"] = "postprocess"
    #             command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname
    #             next if err
    #             gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
    #             gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
    #             reqparams[:gantt] = gantt.dup
    #             reqparams[:child] = nd.dup
    #             reqparams = blk.proc_private_aud_rec(reqparams,command_c) ###
    #         end
    #     end
    #end
    ###
end