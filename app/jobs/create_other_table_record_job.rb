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
                    setParams = params.dup
                    if params[:tbldata] and !params[:tbldata].empty?
                      tbldata = params[:tbldata]
                    else
                      if params[:tblname]
                        strsql = %Q&
                                    select * from #{params[:tblname]} where id = #{params[:tblid]} 
                        &
				                tbldata = ActiveRecord::Base.connection.select_one(strsql)
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
                    if setParams[:where_str]
                        setParams[:where_str] = setParams[:where_str].gsub("#!","'")
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
                        when "link_lotstkhists_update" ###/insts$|acts$|dlvs$|rets$/のとき  
                            # ###parent：在庫移送を発生させたprd,pur
                          add_update_lotstkhists(params[:last_lotstks],params[:person_id_upd])

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
                                                message_code = '#{mkordparams[:message_code]}',remark = ' #{mkordparams[:remark]} '
                                                where id = #{params[:mkprdpurords_id]}
                                %
                              ActiveRecord::Base.connection.update(strsql)
                              if !last_lotstks.empty?
                                add_update_lotstkhists(last_lotstks,params[:person_id_upd])
                              end
                            else
                              ActiveRecord::Base.connection.rollback_db_transaction()
                              ActiveRecord::Base.connection.begin_db_transaction()
                              mkordparams[:remark] = " error #{self} line:#{__LINE__} error "
                              strsql = %Q%update mkprdpurords set message_code = '#{mkordparams[:message_code]}',
                                                                  remark = ' #{mkordparams[:remark]} '
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
                            end
                        when /mkpayords|mkbillords/
                            ### 　parent 未使用
                            if params[:last_amt] and (params[:last_amt].to_f != tbldata["amt"].to_f or params[:last_tax].to_f != tbldata["tax"].to_f )
                                delete_paybillords(params)
                            end
                            if tbldata["amt"].to_f > 0
                                ###ArelCtl.proc_createtable は使用しない
                                ###bill_loca_id_bill_cust
                                isudate = Time.now
                                duedate = Time.now
                                case params[:segment]
                                when "mkpayords"
                                  trn_day = duedate =  params[:tbldata]["rcptdate"].to_date.strftime("%d").to_i
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
                                when "mkbillords"
                                  trn_day = duedate =  params[:tbldata]["saledate"].to_date.strftime("%d").to_i
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
                                end  
                                termofs = mst["termof"].split(",")            
                                termofs.each_with_index do |termof,idx| 
                                  case termof
                                  when "0","00"   ###随時
                                    JSON.parse(mst["ratejson"]).each do |rate|   ###rate["duration"] 0:同月　1:翌月
                                      duedate =  trn_day.to_date.since(rate["duration"].month)
                                      if rate["day"].to_i >= 28
                                        duedate =  duedate.since(1.month)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                      else
                                        if rate["day"] =~ /^+/ 
                                          tmpday = rate["day"][1..-1].to_i 
                                          duedate =  duedate.since(tmpday.day)
                                          duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                        else 
                                          duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                                        end
                                      end
                                      ord_tbldata.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100,
                                                "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                                                "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                      MkordinstLib.proc_create_paybilltbl("payords",ord_tbldata)
                                    end
                                  when "28","29","30","31" ###月末締め
                                    JSON.parse(payment["ratejson"]).each do |rate|
                                      duedate =  params[:tbldata]["rcptdate"].to_date.since(rate["duration"].to_i.month)
                                      if rate["day"].to_i >= 28
                                        duedate =  duedate.since(1.month)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                      else
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                                      end
                                      payord_tbldata.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100 ,
                                                "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                                                "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                      MkordinstLib.proc_create_paybilltbl(params[:srctblname],ord_tbldata)
                                    end
                                  else
                                    if trn_day > termof.to_i and (idx + 1) >= termofs.size
                                      JSON.parse(payment["ratejson"]).each do |rate|
                                        duedate =  Time.now.to_date.since((rate["duration"].to_i + 1).month)
                                        if rate["day"].to_i >= 28
                                          duedate =  duedate.since(1.month)
                                          duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                          duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                        else
                                          duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                                        end
                                        payord_tbldata.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100 ,
                                                  "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                                                  "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                        MkordinstLib.proc_create_paybilltbl(params[:srctblname],ord_tbldata)
                                      end
                                    else
                                      if  trn_day <= termof.to_i
                                        JSON.parse(payment["ratejson"]).each do |rate|
                                          duedate =  params[:tbldata]["rcptdate"].to_date.since(rate["duration"].to_i.month)
                                          if rate["day"].to_i >= 28
                                            duedate =  duedate.since(1.month)
                                            duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                            duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                          else
                                            duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                                          end
                                          payord_tbldata.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100 ,
                                                "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                                                "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                          MkordinstLib.proc_create_paybilltbl(params[:srctblname],ord_tbldata)
                                        end
                                      end
                                    end
                                  end
                                end
                            end 
                        when "mkbillinsts"
                            ### 　parent 未使用
                            mkbillinstparams = {}
                            mkbillinst = tbldata.dup
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
                            ### 　parent 未使用
                            mkpayinstparams = {}
                            mkpayinst = tbldata.dup
                            mkpayinstparams[:incnt] = 0
                            mkpayinstparams[:inamt] = 0
                            mkpayinstparams[:outcnt] = 0
                            mkpayinstparams[:outamt] = 0
                            mkpayinstparams = MkordinstLib.proc_mkpayinsts params,mkpayinstparams
                            mkpayinstparams[:remark] = " #{self} line:#{__LINE__} "
                            strsql = %Q%update mkpayinsts set incnt = #{mkpayinstparams[:incnt]},
                                                  inamt = #{mkpayinstparams[:inamt]},outcnt = #{mkpayinstparams[:outcnt]},
                                                  outamt = #{mkpayinstparams[:outamt]} ,
                                                  remark = ' #{mkpayinstparams[:remark]} '
                                                  where id = #{params[:mkpayinsts_id]}
                                  %
                            ActiveRecord::Base.connection.update(strsql)
                        when /mkpayschs|mkbillschs|mkbillests|updatepayschs/
                            ### 　parent 未使用
                            if params[:segment] == "updatepayschs"
                                delete_paybillschs(params[:segment],params)
                            end
                            ###payestsは作成されない。purschsが在庫に引き当っていることがある為。
                            ###ArelCtl.proc_createtable は使用しない
                            ###bill_loca_id_bill_cust
                            amt_src = 0
                            isudate = Time.now
                            duedate = Time.now
                            trn_day = duedate =  params[:duedate].to_date.strftime("%d").to_i
                            src = {"tblname" => params[:srctblname],"tblid" => params[:srctblid],"trngantts_id" => 0}
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
                                paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,"tax" =>0,
                                        "payments_id" => paybill["id"],"suppliers_id" => paybill["suppliers_id"],
                                        "persons_id_upd" => person["id"] ,"trngantts_id" => params[:trngantts_id],
                                        "last_duedate" => params[:last_duedate], "chrgs_id" => paybill["chrgs_id_payment"],
                                        "tblname" => params[:srctblname],"tblid" => params[:srctblid]}
                              when "mkbillschs","mkbillests"
                                paybillschs = {"amt_src" =>amt_src,"isudate"=>isudate,"duedate" =>duedate,
                                        "tax" =>0,
                                        "bills_id" =>paybill["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params[:trngantts_id],
                                        "last_duedate" => params[:last_duedate],"chrgs_id" => paybill["chrgs_id_bill"],
                                        "tblname" => params[:srctblname],"tblid" => params[:srctblid]}
                            end
                            termofs = paybill["termof"].split(",")
                            termofs.each_with_index do |termof,idx| 
                              case termof
                                when "28","29","30","31" ###前月を対象
                                  JSON.parse(paybill["ratejson"]).each do |rate|
                                    duedate =  params[:duedate].to_date.since(rate["duration"].to_i.month)
                                    if rate["day"].to_i >= 28
                                      duedate =  duedate.since(1.month)
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                    else
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                                    end
                                    paybillschs.merge!({"amt_src" => params[:amt].to_f * rate["rate"] / 100 ,
                                              "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                                              "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                    create_paybillschs(src,paybillschs,paybill)
                                  end
                                
                                when "0","00"   ###随時
                                  JSON.parse(paybill["ratejson"]).each do |rate|   ###rate["duration"] 0:同月　1:翌月
                                    duedate =  params[:duedate].to_date.since(rate["duration"].month)
                                    if rate["day"].to_i >= 28
                                      duedate =  duedate.since(1.month)
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                      duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                    else
                                      if rate["day"] =~ /^+/ 
                                        tmpday = rate["day"][1..-1].to_i 
                                        duedate =  duedate.since(tmpday.day)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                      else 
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                                      end
                                    end
                                    paybillschs.merge!({"amt_src" => params[:amt].to_f * rate["rate"] / 100,
                                              "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                                              "denomination" => rate["denomination"],
                                              "isudate" =>duedate.to_date,"duedate" =>duedate.to_date})
                                    create_paybillschs(src,paybillschs,paybill)
                                  end
                                else
                                  if trn_day > termof.to_i and (idx + 1) >= termofs.size
                                    JSON.parse(paybill["ratejson"]).each do |rate|
                                      duedate =  Time.now.to_date.since((rate["duration"].to_i + 1).month)
                                      if rate["day"].to_i >= 28
                                        duedate =  duedate.since(1.month)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                      else
                                        duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                                      end
                                      paybillschs.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100 ,
                                                "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                                                "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                      create_paybillschs(src,paybillschs,paybill)
                                    end
                                  else
                                    if  trn_day <= termof.to_i
                                      JSON.parse(paybill["ratejson"]).each do |rate|
                                        duedate =  params[:duedate].to_date.since(rate["duration"].to_i.month)
                                        if rate["day"].to_i >= 28
                                          duedate =  duedate.since(1.month)
                                          duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                                          duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                                        else
                                          duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                                        end
                                        paybillschs.merge!({"amt_src" => params[:amt].to_f * rate["rate"] / 100 ,
                                              "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                                              "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                                        create_paybillschs(src,paybillschs,paybill)
                                      end
                                    end
                                  end
                              end
                            end 
                        # when /mkbillords/
                        #     ###ArelCtl.proc_createtable は使用しない
                        #     ###bill_loca_id_bill_cust
                        #     ### 　parent 未使用
                        #     amt_src = 0
                        #     isudate = duedate = Time.now
                        #     src = {"tblname" => params[:srctblname],"tblid" => params[:srctblid],"trngantts_id" => 0}
                        #     strsql = %Q%select b.* from bills b   
                        #                     where b.id = #{tbldata["bills_id"]}
                        #             %
                        #     billmst = ActiveRecord::Base.connection.select_one(strsql)
                        #     billord_tbldata = {"isudate"=>isudate,
                        #                 "bills_id" =>billmst["id"],"persons_id_upd" => person["id"] ,"trngantts_id" => params[:trngantts_id],
                        #                 "last_duedate" => tbldata["last_saledate"],"chrgs_id" => billmst["chrgs_id_bill"],
                        #                 "srctblname" => params[:srctblname],"srctblid" => params[:srctblid]}
                        #     termofs = billmst["termof"].split(",")
                        #     termofs.each_with_index do |termof,idx| 
                        #       case termof
                        #       when "0","00"   ###随時
                        #           JSON.parse(billmst["ratejson"]).each do |rate|   ###rate["duration"] 0:同月　1:翌月
                        #               duedate =  params[:tbldata]["saledate"].to_date.since(rate["duration"].to_i.month)
                        #               if rate["day"].to_i >= 28
                        #                           duedate =  duedate.since(1.month)
                        #                           duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                        #                           duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                        #               else
                        #                   if rate["day"] =~ /^+/ 
                        #                     tmpday = rate["day"][1..-1].to_i 
                        #                     duedate =  duedate.since(tmpday.day)
                        #                     duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                        #                   else 
                        #                     duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                        #                   end
                        #               end
                        #               billord_tbldata.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100,
                        #                                     "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                        #                                     "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                        #               MkordinstLib.proc_create_paybilltbl("billords",billord_tbldata)
                        #           end
                        #       when "28","29","30","31" ###月末締め
                        #           JSON.parse(billmst["ratejson"]).each do |rate|
                        #              duedate =  params[:tbldata]["saledate"].to_date.since(rate["duration"].to_i.month)
                        #               if rate["day"].to_i >= 28
                        #                 duedate =  duedate.since(1.month)
                        #                 duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                        #                 duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                        #               else
                        #                  duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                        #               end
                        #           billord_tbldata.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100 ,
                        #                                    "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                        #                                    "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                        #           MkordinstLib.proc_create_paybilltbl("billords",billord_tbldata)
                        #           end
                        #       else
                        #          if trn_day > termof.to_i and (idx + 1) >= termofs.size
                        #              JSON.parse(billmst["ratejson"]).each do |rate|
                        #                 duedate =  Time.now.to_date.since((rate["duration"].to_i + 1).month)
                        #                 if rate["day"].to_i >= 28
                        #                             duedate =  duedate.since(1.month)
                        #                             duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                        #                             duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                        #                 else
                        #                             duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"].to_s)
                        #                 end
                        #                 billord_tbldata.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100 ,
                        #                                       "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                        #                                       "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                        #                 MkordinstLib.proc_create_paybilltbl("billords",billord_tbldata)
                        #               end
                        #           else
                        #               if  trn_day <= termof.to_i
                        #                    duedate =  params[:tbldata]["saledate"].to_date.since(rate["duration"].to_i.month)
                        #                 JSON.parse(billmst["ratejson"]).each do |rate|
                        #                   if rate["day"].to_i >= 28
                        #                                 duedate =  duedate.since(1.month)
                        #                                 duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + "1").since(-1.day)
                        #                              duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + duedate.strftime("%d"))
                        #                   else
                        #                     duedate = (duedate.strftime("%Y") + "-" + duedate.strftime("%m") + "-" + rate["day"])
                        #                   end
                        #                   billord_tbldata.merge!({"amt_src" => params[:tbldata]["amt"].to_f * rate["rate"] / 100 ,
                        #                                     "tax" =>  params[:tax].to_f * rate["rate"] / 100,
                        #                                     "denomination" => rate["denomination"],"duedate" =>duedate.to_date})
                        #                   MkordinstLib.proc_create_paybilltbl("billords",billord_tbldata)
                        #                 end
                        #               end
                        #           end
                        #       end 
                        #     end                        
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
                            setParams[:parent] = parent.dup
                            last_lotstks = []
                            ActiveRecord::Base.connection.select_all(ArelCtl.proc_nditmSql(tbldata["opeitms_id"])).each do |nd|
                                trnganttkey += 1
                                gantt["key"] = gantt_key + format('%05d', trnganttkey)
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
                                    gantt["qty_handover"] = (qty_require / nd["packqty"]).ceil * nd["packqty"] 
                                    gantt["duedate_trn"] = command_c["#{gantt["tblname"].chop}_duedate"]
                                    gantt["toduedate_trn"] = command_c["#{gantt["tblname"].chop}_toduedate"]
                                    gantt["qty_require"] = qty_require
                                    gantt["qty_sch"] = command_c["#{gantt["tblname"].chop}_qty_sch"]
                                    gantt["starttime_trn"] =  command_c["#{gantt["tblname"].chop}_starttime"]
                                    ###作業場所の稼働日考慮要
                                    gantt["locas_id_trn"] = command_c["shelfno_loca_id_shelfno"]
                                    setParams[:mkprdpurords_id] = 0
                                    gantt["tblid"] = command_c["id"]
                                    command_c["#{gantt["tblname"].chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams[:person_id_upd]
                                    setParams[:gantt] =  gantt.dup
                                    setParams = blk.proc_private_aud_rec(setParams,command_c) ###create pur,prdschs
                                    if gantt["consumtype"] == "CON"  ###出庫 消費と金型・設備の使用
                                      setParams[:child] =  nd.dup
                                      setParams[:screenCode] = "r_conschs"
                                      last_lotstks <<  Shipment.proc_create_consume(setParams)   ###自身の消費を作成
                                    end
                                when "run"
                                    setParams[:child] =  nd.dup
                                    setParams[:screenCode] = "r_conschs"
                                    last_lotstks <<  Shipment.proc_create_consume(setParams)   ###自身の消費を作成
                                    ###
                                    # gantt 作成
                                    ###
                                    setGanttFromNd(gantt, nd) do
                                        gantt["tblname"] = "conschs"
                                        gantt["consumtype"] = "CON"
                                    end
                                    consume_tbldata = setParams[:tbldata].dup
                                    gantt["duedate_trn"] = gantt["toduedate_trn"] = consume_tbldata["duedate"]
                                    gantt["qty_require"] = gantt["qty_handover"] = 0
                                    gantt["qty_sch"] = consume_tbldata["qty_sch"]
                                    strsql = %Q%select locas_id_shelfno from shelfnos where id = #{consume_tbldata["shelfnos_id_fm"]}%
                                    locas_id_shelfno = ActiveRecord::Base.connection.select_value(strsql)
                                    gantt["locas_id_trn"] = locas_id_shelfno
                                    starttime,message = CtlFields.proc_calculate_working_day("run",consume_tbldata["duedate"].to_date,1,"-",locas_id_shelfno)
                                    gantt["starttime_trn"] =  starttime
                                    ###作業場所の稼働日考慮要
                                    setParams[:mkprdpurords_id] = 0
                                    gantt["tblid"] = consume_tbldata["id"]
                                    gantt["persons_id_upd"] = setParams[:person_id_upd]
                                    setParams[:gantt] =  gantt.dup
                                    ope = Operation::OpeClass.new(setParams)
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
                                         dvsParams = setParams.dup
                                         dvsParams[:gantt] = gantt.dup
                                         dvsParams[:child] = nd.dup
                                         dvsParams[:gantt] = gantt.dup
                                         dvsParams[:screenCode] = "r_prdschs"
                                         dvs = Operation::OpeClass.new(dvsParams)  ###
                                         dvs.proc_add_dvs_data(nd)
                                         dvs.proc_add_erc_data(nd)
                                    when "mold","ITool"       ###金型 ###工具
                                        setParams[:mkprdpurords_id] = 0
                                        gantt["consumtype"] = (nd["consumtype"]||="mold")
                                        setParams[:gantt] = gantt.dup
                                        setParams[:child] = nd.dup
                                        setParams[:gantt] = gantt.dup
                                        setParams[:child]["units_id_case_shp"] = nd["units_id"]
                                        strsql = %Q&
                                                    select l.shelfnos_id from lotstkhists l 
                                                                inner join shelfnos s on s.id = l.shelfnos_id
                                                                where l.itms_id = #{nd["itms_id"]}  and s.code = '#{nd["classlist_code"]}'
                                                                order by l.starttime desc
                                            &
                                        shelfnos_id = ActiveRecord::Base.connection.select_value(strsql)
                                        setParams[:child]["shelfnos_id_to"] = (shelfnos_id ||= "0")
                                        last_lotstks_parts = Shipment.proc_create_shpxxxs(setParams) do  ###
                                            "shpest"
                                        end
                                        last_lotstks.concat last_lotstks_parts
                                    when "installationCharge"   ###設置
                                         ercParams = setParams.dup
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
                                        command_c["#{gantt["tblname"].chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams[:person_id_upd]
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
                                        setParams[:mkprdpurords_id] = 0
                                        setParams[:gantt] = gantt.dup
                                        setParams[:child] = nd.dup
                                        setParams = blk.proc_private_aud_rec(setParams,command_c) ###create pur,prdschs
                                        if gantt["consumtype"] == "CON"  ###出庫 消費と金型・設備の使用
                                          setParams[:child] =  nd.dup
                                          setParams[:screenCode] = "r_conschs"
                                          last_lotstks << Shipment.proc_create_consume(setParams)
                                        end
                                    end
                                end
                            end       
                            if !last_lotstks.empty?
                              add_update_lotstkhists(last_lotstks,params[:person_id_upd])
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
                                setParams[:mkprdpurords_id] = 0
                                child = nd.dup
                                case child["consumtype"]
                                when "CON"  ###出庫 消費 
                                    child["packno"] = ""
                                    child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                                    setParams[:parent] = parent.dup
                                    setParams[:child] = child.dup
                                    if child["shpordauto"] != "M" and nd["pare_shelfnos_id"] != nd["shelfnos_id_to"]  ###手動出荷ではない、親の作業場所!=部品の保管場所
                                      setParams[:screenCode] = "r_shpschs"    
                                      last_lotstks_parts =  Shipment.proc_create_shpxxxs(setParams) do  ###prd,purordsによる自動作成 
                                            "shpsch"
                                      end
                                      last_lotstks.concat last_lotstks_parts
                                    end
                                    if child["consumauto"] != "M"  ###自動の時
                                      setParams[:screenCode] = "r_conords"    
                                      last_lotstks <<  Shipment.proc_create_consume(setParams)
                                    end
                                when "mold","ITool"  ###出庫 金型・工具の使用
                                    child["packno"] = ""
                                    child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                                    setParams[:parent] = parent.dup
                                    setParams[:child] = child.dup
                                    if child["shpordauto"] != "M"
                                      setParams[:screenCode] = "r_shpschs"  
                                      last_lotstks_parts =  Shipment.proc_create_shpxxxs(setParams) do  ###prd,purordsによる自動作成 
                                            "shpsch"
                                        end
                                      last_lotstks.concat last_lotstks_parts
                                    end    
                                when "BYP" ,"run"  ###副産物,runner
                                    ###消費はない
                                    child["packno"] = ""
                                    child["lotno"] = ""   ### shpschs,shpordsの時はlotnoは""  
                                    setParams[:parent] = parent.dup
                                    setParams[:child] = child.dup
                                    setParams[:screenCode] = "r_shpschs"  
                                    last_lotstks_parts =  Shipment.proc_create_shpxxxs(setParams) do  ###prd,purordsによる自動作成 
                                            "shpsch"
                                    end
                                    last_lotstks.concat last_lotstks_parts
                                when "apparatus"  ###設備の使用
                                    next
                                end
                            end 
                            if !last_lotstks.empty?
                              add_update_lotstkhists(last_lotstks,params[:person_id_upd])
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
                                    ActiveRecord::Base.connection.update(update_sql) ###引き当ったcustschsの減gantt = setParams[:gantt].dup
                                    src = {"tblname" => "custschs","tblid" => sch["srctblid"],"trngantts_id" => sch["trngantts_id"]}
                                    base = {"tblname" => "custords","tblid" => gantt["orgtblid"],"qty_src" => qty_src,"amt_src" => 0,"persons_id_upd" => setParams[:person_id_upd]}
                                    ArelCtl.proc_insert_linkcusts(src,base)  ###
                                    last_lotstks << {"tblname" => "custschs","tblid" => sch["srctblid"],"qty_src" => qty_src}
                                end
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"] = qty
                                update_sql = %Q&  --- custords free 引当後
                                        update linkcusts set qty_src = #{qty},remark = ' #{self} line:#{__LINE__} '||left(remark,3000),
                                                updated_at = current_timestamp
                                                where tblid = #{gantt["tblid"]} and srctblid = #{gantt["tblid"]} and trngantts_id = #{gantt["trngantts_id"]}
                                                and tblname = 'custords' and srctblname = 'custords'
                                        &
                                ActiveRecord::Base.connection.update(update_sql)  ###custords.linkcusts.qtyの減
                            when "custschs"
                                gantt["qty_handover"] = tbldata["qty_handover"] =  gantt["qty_sch"]
                            else
                                3.times{Rails.logger.debug" orgtblname:#{gantt["orgtblname"]} error "}
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
                            command_c["#{opeitm["prdpur"]}sch_person_id_upd"] = setParams[:person_id_upd]
                            command_c["#{opeitm["prdpur"]}sch_duedate"] = tbldata["starttime"].to_time.strftime("%Y-%m-%d") + " 16:00:00"
                            command_c,qty_require = add_update_prdpur_table_from_nditm(child,tbldata,paretblname,command_c)  ###tbldata--->parent
                            command_c["#{opeitm["prdpur"]}sch_created_at"] = Time.now
                            setParams[:gantt] = gantt.dup
                            setParams = blk.proc_private_aud_rec(setParams,command_c)   
                            result_f = '1'
                            if !last_lotstks.empty?
                              add_update_lotstkhists(last_lotstks,params[:person_id_upd])
                            end
                    else  
                        result_f = '6'
                        3.times{Rails.logger.debug" class:#{self},line:#{__LINE__}  program(segment) nothing  "}  
                        3.times{Rails.logger.debug" setParams:#{setParams}"}
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
          nd = {"locas_id_pare" => gantt["locas_id_trn"].to_i,
                "itms_id" => gate["itms_id"],"processseq" => gate["processseq"],
                "shelfnos_id" => gate["shelfnos_id"],"shelfnos_id_to" => gate["shelfnos_id_to"],
                "locas_id" => gate["locas_id"],"locas_id_to" => gate["locas_id_to"],"priority" => gate["priority"],
                "opeitms_id"=> gate["opeitms_id"],"parenum" => 1,"chilnum" => 1,  "packqty" => gate["packqty"],###
                "consumunitqty" => 1,"consumminqty" => 0,"consumchgoverqty" => 0,"consumauto" => ""}
          strsql = %Q%select sum(t.qty_sch) qty_sch from trngantts t  ---runner
                                 where t.orgtblname = '#{gantt["orgtblname"]}' and t.orgtblid = #{gantt["orgtblid"]}
                                  and t.itms_id_trn = #{gate["itms_id"]} and t.processseq_trn = #{gate["processseq"]}
                                  group by t.itms_id_trn,t.processseq_trn
                                   %
          qty_sch = ActiveRecord::Base.connection.select_value(strsql)
          if qty_sch.to_f > 0  ###金型により部品作成済
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
                  ###gate の作成
                end
          else
                gantt["mlevel"] = gantt["mlevel"].to_i+1
                gantt["key"] = gantt["key"] + "00000"
                parent = gateParams[:tbldata].dup
                parent["qty_sch"] = parent["qty_handover"] = (gantt["qty_sch"].to_f ) / gate["chilnum"].to_f * gate["parenum"].to_f
                parent["starttime"] = gantt["starttime_trn"]
                blk = RorBlkCtl::BlkClass.new("r_prdschs")
                command_c = blk.command_init
                command_c["shelfno_loca_id_shelfno"] = gate["locas_id"]
                command_c["shelfno_loca_id_shelfno_to"] = gate["locas_id_to"]
                command_c["prdsch_person_id_upd"] = gateParams[:person_id_upd]
		            command_c,qty_require,err = CtlFields.proc_schs_fields_making(nd,parent,command_c)
                gateParams[:classname] = "_insert_"
                gantt["qty_handover"] = command_c["prdsch_qty_handover"]
                gateParams[:gantt] = gantt.dup
                gateParams = blk.proc_private_aud_rec(gateParams,command_c) ###
                return
          end
        else
			      raise " class:#{self} ,line:#{__LINE__} \n strsql:#{strsql} "
        end
        ###
        # runner prdschsts　登録済
        ###
        strsql = %Q%select t.tblname,t.tblid,max(t.key) "key" from trngantts t  ---gate
                                 where t.orgtblname = '#{gantt["orgtblname"]}' and t.orgtblid = #{gantt["orgtblid"]}
                                  and t.itms_id_trn = #{gate["itms_id"]} and t.processseq_trn = #{gate["processseq"]}
                                  group by t.itms_id_trn,t.processseq_trn,t.tblname,t.tblid
                                   %
        gate_tblname = ActiveRecord::Base.connection.select_one(strsql)
        strsql = %Q%select prd.*,o.itms_id,o.processseq from #{gate_tblname["tblname"]} prd
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
            gantt["qty_sch"] = gantt["qty_handover"] = gate_tbldata["qty_sch"] = 0
            gantt["shelfnos_id_trn"] = gate_tbldata["shelfnos_id"]
            gantt["shelfnos_id_to_trn"] = gate_tbldata["shelfnos_id_to"]
            gantt["qty"] = 0 
            gantt["id"] = gantt["trngantts_id"] = ArelCtl.proc_get_nextval("trngantts_seq")
            gantt["remark"] = "line:#{__LINE__} class:#{self} " + (gantt["remark"]||="")
            ArelCtl.proc_insert_trngantts(gantt,gate_tbldata)
        end
    end

    def create_paybillschs(src,sch,billpay)
        ###check billscks exists or not
        case sch["tblname"]
        when "custords"
            paybillsch =  "billsch"
            blk = RorBlkCtl::BlkClass.new("r_billschs")
            command_c = blk.command_init
            command_c["billsch_accounttitle"] = "A"  ### 売上
            mst = "bill"
            str_amt = "amt_sch"
		        ActiveRecord::Base.connection.execute("lock table billschs in  SHARE ROW EXCLUSIVE mode")
        when "custschs"
            paybillsch =  "billest"
            blk = RorBlkCtl::BlkClass.new("r_billests")
            command_c = blk.command_init
            command_c["billest_accounttitle"] = "A"  ### 売上
            mst = "bill"
            str_amt = "amt_est"
		        ActiveRecord::Base.connection.execute("lock table billests in  SHARE ROW EXCLUSIVE mode")
        when "purords"
            paybillsch = "paysch"
            blk = RorBlkCtl::BlkClass.new("r_payschs")
            command_c = blk.command_init
            command_c["paysch_accounttitle"] = "1"  ### 仕入
            mst = "payment"
            str_amt = "amt_sch"
		        ActiveRecord::Base.connection.execute("lock table payschs in  SHARE ROW EXCLUSIVE mode")
        end 

        command_c["#{paybillsch}_person_id_upd"] = sch["persons_id_upd"]
        command_c["#{paybillsch}_duedate"] = sch["duedate"]
        command_c["#{paybillsch}_isudate"] = sch["isudate"]
        command_c["#{paybillsch}_expiredate"] =  Constants::EndDate 
        command_c["#{paybillsch}_chrg_id"] = billpay["chrgs_id_#{mst}"]
        command_c["#{paybillsch}_tax"] = 0 
        command_c["#{paybillsch}_updated_at"] = Time.now
        command_c["#{paybillsch}_#{mst}_id"] = sch["#{mst}s_id"]
        strsql = %Q&
                    select * from #{paybillsch}s where #{mst}s_id = #{sch["#{mst}s_id"]} 
                                            and to_char(duedate,'yyyy-mm-dd') = '#{sch["duedate"].strftime("%Y-%m-%d")}'
                                            and accounttitle = '#{case mst 
                                                                when "payment"  
                                                                    "1"
                                                                when "bill"
                                                                    "A"
                                                                end}'   for update
        &
        rec = ActiveRecord::Base.connection.select_one(strsql)
        if rec
		        command_c["sio_classname"] = %Q&_update_from_#{paybillsch}s &
		        command_c["#{paybillsch}_remark"] = "auto update "
		        command_c["id"] = command_c["#{paybillsch}_id"] = rec["id"]
            strsql = %Q&
                        select * from srctbllinks where srctblname = '#{sch["tblname"]}' and srctblid = #{sch["tblid"]}  
                                and tblname = '#{paybillsch}s' and tblid = #{rec["id"]}
                    &
            link = ActiveRecord::Base.connection.select_one(strsql)
            if link 
                command_c["#{paybillsch}_#{str_amt}"] = rec[str_amt].to_f + (sch[str_amt].to_f - sch[str_amt].to_f )
                strsql = %Q&
                            update srctbllinks set amt_src = #{sch["amt_src"]} ,
                                updated_at = current_timestamp
                                where id = #{link["id"]}
                &
                ActiveRecord::Base.connection.update(strsql)
            else
                command_c["#{paybillsch}_#{str_amt}"] = rec["amt_sch"].to_f + sch["amt_src"].to_f 
                base = {"tblname" => "#{paybillsch}s","tblid" => command_c["id"],"amt_src" => sch["amt_src"],
                         "persons_id_upd" => sch["persons_id_upd"]} 
                ArelCtl.proc_insert_srctbllinks(sch,base)
            end
        else
		        command_c["sio_classname"] = %Q&_add_from_#{case mst
                                                        when "bill"
                                                            'custords'
                                                        when "payment"
                                                            "purords"
                                                        end } &
		        command_c["#{paybillsch}_remark"] = "auto add "
		        command_c["id"] = command_c["#{paybillsch}_id"] = ArelCtl.proc_get_nextval("#{paybillsch}s_seq")
		        command_c["#{paybillsch}_created_at"] = Time.now  ###
		        command_c["#{paybillsch}_sno"] = CtlFields.proc_field_sno(paybillsch,sch["isudate"],command_c["id"]) 
		        command_c["#{paybillsch}_#{str_amt}"] = sch["amt_src"] 
            base = {"tblname" => "#{paybillsch}s","tblid" => command_c["id"],"qty_src" => 0,"amt_src" => sch["amt_src"],
                     "persons_id_upd" => sch["persons_id_upd"]} 
            ArelCtl.proc_insert_srctbllinks(src,base)
        end
        strsql = %Q&
                    select * from r_chrgs where id = #{billpay["chrgs_id_#{mst}"]} 
        &
        chrg = ActiveRecord::Base.connection.select_one(strsql)
        command_c["chrg_person_id_chrg_#{mst}"] = chrg["chrg_person_id_chrg"] 
        command_c["person_sect_id_chrg_#{mst}"] =  chrg["person_sect_id_chrg"]
        billParams = blk.proc_private_aud_rec({},command_c)
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

    def delete_paybillords(params)
        strsql = %Q&
                      select * from  srctbllinks 
                                 where tblname = '#{params[:gantt]["tblname"]}' 
                                 and srctblname = '#{params[:srctblname]}' and tblid = #{params[:srctblid]}
                 &
        ActiveRecord::Base.connection.select_all(strsql).each do |rec|
                update_sql = %Q&
                        update srctbllinks set amt_src = 0
                                where #{rec["id"]}
                    &
                ActiveRecord::Base.connection.update(update_sql)
                update_sql = %Q&
                         update payords set amt = amt -  #{rec["amt_src"]}
                                 where id = #{rec["tblid"]}
                 &
                ActiveRecord::Base.connection.update(update_sql)
        end
    end 
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
    ###     
    def mk_ercschsords(nd,setParams,erctblname)
        prdtblname = erctblname.sub("erc","prd")
        dvstblname = erctblname.sub("erc","dvs")
        gantt = setParams[:gantt].dup
        parent = setParams[:tbldata].dup
        setParams[:mkprdpurords_id] = 0
        gantt["tblname"] = erctblname
        gantt["qty_require"] = 1
        gantt["qty_handover"] = 0
        case erctblname
        when /schs/
            gantt["qty_sch"] = 1 
            gantt["qty"] = 0 
            gantt["qty_stk"] = 0 
        when /ords/
            gantt["qty_sch"] = 0
            gantt["qty"] = 1 
            gantt["qty_stk"] = 0 
        else
            3.times{Rails.logger.debug"  erctbl not suppurt:#{erctblname},class: #{self} , line:#{__LINE__} "}
            raise 
        end
        gantt["consumtype"] = "apparatus"  ###parenum,chilnumは1
        gantt_key = gantt["key"]
        trnganttkey = 0
        if nd["changeoverlt"].to_f > 0 and nd["changeoverop"].to_i > 0
            nd["prdpur"] = "erc"
            nd["changeoverop"].to_i.times do
                trnganttkey += 1
                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                blk = RorBlkCtl::BlkClass.new("r_ercschs")
                command_c = blk.command_init
                command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
                command_c["#{erctblname.chop}_created_at"] = Time.now
                command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams[:person_id_upd]
                command_c["#{erctblname.chop}_processname"] = "changeover"
                command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname(prdschs)
                next if 
                ### perfotm　実行のため　.to_json日付が"2024-12-17T20:53:26.000Z"になている
                command_c["#{erctblname.chop}_starttime"] =  command_c["#{erctblname.chop}_starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S")
                command_c["#{erctblname.chop}_duedate"] = command_c["#{erctblname.chop}_duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S")
                gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
                gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
                setParams[:gantt] = gantt.dup
                setParams[:child] = nd.dup
                setParams[:gantt] = gantt.dup
                setParams = blk.proc_private_aud_rec(setParams,command_c) ###
            end
        end
        if nd["durationfacility"].to_f > 0 and nd["requireop"].to_i > 0
            nd["prdpur"] = "erc"
            nd["requireop"].to_i.times do
                trnganttkey += 1
                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                blk = RorBlkCtl::BlkClass.new("r_ercschs")
                command_c = blk.command_init
                command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
                command_c["#{erctblname.chop}_created_at"] = Time.now
                command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams[:person_id_upd]
                command_c["#{erctblname.chop}_processname"] = "require"
                command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname
                next if err
                gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
                gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
                setParams[:gantt] = gantt.dup
                setParams[:child] = nd.dup
                setParams[:gantt] = gantt.dup
                setParams = blk.proc_private_aud_rec(setParams,command_c) ###
            end
        end
        if nd["postprocessinglt"].to_f > 0 and nd["postprocessingop"].to_i > 0
            nd["prdpur"] = "erc"
            nd["postprocessingop"].to_i.times do
                trnganttkey += 1
                gantt["key"] = gantt_key + format('%05d', trnganttkey)
                blk = RorBlkCtl::BlkClass.new("r_ercschs")
                command_c = blk.command_init
                command_c["#{erctblname.chop}_#{prdtblname.chop}_id_#{erctblname.chop}"] = parent["#{prdtblname}_id_#{dvstblname.chop}"]
                command_c["#{erctblname.chop}_created_at"] = Time.now
                command_c["#{erctblname.chop}_person_id_upd"] = gantt["persons_id_upd"] = setParams[:person_id_upd]
                command_c["#{erctblname.chop}_processname"] = "postprocess"
                command_c,qty_require,err = add_update_prdpur_table_from_nditm(nd,parent,prdtblname,command_c)  ###tblname = paretblname
                next if err
                gantt["starttime_trn"] = command_c["#{erctblname.chop}_starttime"]
                gantt["duedate_trn"] = command_c["#{erctblname.chop}_duedate"]
                setParams[:gantt] = gantt.dup
                setParams[:child] = nd.dup
                setParams = blk.proc_private_aud_rec(setParams,command_c) ###
            end
        end
    end
    ###
    def add_update_lotstkhists(last_lotstks,persons_id_upd)
      tmptbls = []
      save_tblname = save_tblid = ""
      suppliers_id_fm = suppliers_id_to = 0
      last_lotstks.each do |last_lotstk| 
        next if last_lotstk.nil?
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
                      suppliers_id_to ||= 0
                  else
                      suppliers_id_fm = 0
                      suppliers_id_to = 0
                  end
            when /^con/
                      strsql = %Q& select rec.* from #{last_lotstk["tblname"]} rec where rec.id = #{last_lotstk["tblid"]}&
                      rec = ActiveRecord::Base.connection.select_one(strsql)
                      supp_str = %Q&
                              select supp.id from suppliers supp
                                            inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                            where shelf.id = #{rec["shelfnos_id_fm"]}
                      &
                      suppliers_id_fm = ActiveRecord::Base.connection.select_value(supp_str)
                      suppliers_id_fm ||= 0
                      suppliers_id_to = 0
            when /^shp/
                  strsql = %Q& select rec.*,o.prdpur from #{last_lotstk["tblname"]} rec
                                            left join opeitms o on o.itms_id = rec.itms_id and o.processseq = rec.processseq
                                                                  and o.priority = 999
                                            where rec.id = #{last_lotstk["tblid"]}
                  &
                  rec = ActiveRecord::Base.connection.select_one(strsql)
                    supp_str = %Q&
                            select supp.id from suppliers supp
                                          inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                          where shelf.id = #{rec["shelfnos_id_to"]}
                    &
                    suppliers_id_to = ActiveRecord::Base.connection.select_value(supp_str)
                    suppliers_id_to ||= "" 
                    supp_str = %Q&
                            select supp.id from suppliers supp
                                          inner join shelfnos shelf on shelf.locas_id_shelfno = supp.locas_id_supplier
                                          where shelf.id = #{rec["shelfnos_id_fm"]}
                    &
                    suppliers_id_fm = ActiveRecord::Base.connection.select_value(supp_str)
                    suppliers_id_fm ||= 0
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
              3.times{Rails.logger.debug" class:#{self} , line:#{__LINE__} ,error last_lotstk:#{last_lotstk}"}
              raise
            end
          end
          temp = {"itms_id" => rec["itms_id"],"processseq" => rec["processseq"],"prjnos_id" => rec["prjnos_id"],
                    "tblname" => last_lotstk["tblname"],"tblid" => last_lotstk["tblid"],
                    "qty_sch" => 0,"qty" => 0,"qty_stk" => 0, "qty_real" => 0,"qty_rejection" => 0,
                    "shelfnos_id" => 0,"suppliers_id_fm" => suppliers_id_fm,"suppliers_id_to" => suppliers_id_to ,"custrcvplcs_id" => 0 }
          case last_lotstk["tblname"]
            when /purschs|prdschs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                        "qty_sch" => last_lotstk["qty_src"],
                      "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /custschs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                                "qty_sch" => last_lotstk["qty_src"].to_f*-1,
                              "lotno" => "","packno" => ""})
              tmptbls << xtemp
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"custrcvplcs_id" => rec["custrcvplcs_id"],
                                "qty_sch" => last_lotstk["qty_src"].to_f*-1,
                                "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /purords|purinsts/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty" => last_lotstk["qty_src"],
                      "lotno" => "","packno" => ""})
              tmptbls << xtemp
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => 0,
                      "suppliers_id_fm" => rec["suppliers_id"],
                      "qty" => last_lotstk["qty_src" ] * -1,
                      "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /prdords|prdinsts/
              xtemp = temp.dup
              xemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                      "qty" => last_lotstk["qty_src"],
                      "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /custords/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["starttime"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                              "custrcvplcs_id" => 0,
                              "qty" => last_lotstk["qty_src"].to_f*-1,
                              "lotno" => "","packno" => ""})
              tmptbls << xtemp
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => 0,
                      "custrcvplcs_id" => rec["custrcvplcs_id"],
                      "qty_sch" => 0,"qty" => last_lotstk["qty_src"],
                      "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /purreplyinputs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["replaydate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                        "qty" => last_lotstk["qty_src"],"qty_stk" => 0, "qty_real" => 0,
                      "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /custdlvs/
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                      "custrcvplcs_id" => 0,
                        "qty_stk" => last_lotstk["qty_src"],
                      "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /purdlvs/
              xtemp = temp.dup
              temp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => "","custrcvplcs_id" => 0,
                        "suppliers_id_fm" => suppliers_id_fm,
                        "qty_stk" => last_lotstk["qty_src"], 
                      "lotno" => "","packno" => ""})
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
              xtemp.merge!({"starttime" => rec["saledate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => 0,
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
                         "qty_sch" => last_lotstk["qty_src"],
                         "lotno" => "","packno" => ""})
               tmptbls << xtemp
            when /shpschs/
              xtemp = temp.dup              
              if rec["prdpur"] == "run" or rec["prdpur"] == "BYP"
                ### ruuner or BYP(副産物)では出はない
              else
                xtemp.merge!({"starttime" => rec["depdate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                                    "qty_sch" => last_lotstk["qty_src"] * -1,
                                    "lotno" => "","packno" => ""})
                tmptbls << xtemp
              end
              xtemp = temp.dup
              xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_to"],
                                     "qty_sch" => last_lotstk["qty_src"],
                                     "lotno" => "","packno" => ""})
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
            when /shpinsts/
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
                     "qty_sch" => last_lotstk["qty_src"] * -1,
                     "lotno" => "","packno" => ""})
              tmptbls << xtemp
            when /conords|coninsts/
                xtemp = temp.dup
                xtemp.merge!({"starttime" => rec["duedate"].to_time.strftime("%Y-%m-%d %H:%M:%S"),"shelfnos_id" => rec["shelfnos_id_fm"],
                     "qty" => last_lotstk["qty_src"] * -1,
                     "lotno" => "","packno" => ""})
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
              3.times{Rails.logger.debug" error class:#{self} , line:#{__LINE__} ,tblname not support last_lotstk:#{last_lotstk}"}
              raise
          end 
      end
      ###data.sort_by { |h| h.values_at(:k1, :k2, :k3, :k4) }else
      Rails.logger.debug" class:#{self} , line:#{__LINE__} ,\n tmptbls:#{tmptbls}"
      tmplotstktbls = tmptbls.sort_by {|h| [h["itms_id"],h["processseq"],h["prjnos_id"],h["starttime"],h["lotno"],h["packno"],
                        h["shelfnos_id"],h["suppliers_id_fm"],h["suppliers_id_to"],h["custrcvplcs_id"]]}
      lotstktbls = []
      save_itms_id = save_processseq = save_shelfnos_id = save_lotno = save_packno = save_prjnos_id = save_starttime = ""
      save_suppliers_id_fm = save_suppliers_id_to = save_custrcvplcs_id = save_tblname = save_tblid = ""
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
          if save_itms_id == "" and save_processseq == "" and 
                save_shelfnos_id == "" and save_lotno == "" and save_packno == ""  and 
                    save_prjnos_id == ""  and save_starttime == "" and 
                      save_suppliers_id_fm == "" and  save_suppliers_id_to == "" and  save_custrcvplcs_id == ""
          else
            lotstktbls << {"itms_id" => save_itms_id ,"processseq" => save_processseq ,
                          "shelfnos_id" => save_shelfnos_id ,
                          "suppliers_id_fm" => save_suppliers_id_fm ,"suppliers_id_to" => save_suppliers_id_to , 
                          "custrcvplcs_id" => save_custrcvplcs_id,
                          "tblname" => save_tblname,"tblid" => save_tblid,
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
            save_tblname = tmpl["tblname"]
            save_tblid = tmpl["tblid"]
        end
      end
      lotstktbls << {"itms_id" =>save_itms_id ,"processseq" => save_processseq ,
                      "shelfnos_id" => save_shelfnos_id ,"suppliers_id_fm" => save_suppliers_id_fm,"suppliers_id_to" => save_suppliers_id_to,
                      "custrcvplcs_id" => save_custrcvplcs_id,"lotno" => save_lotno ,"packno" => save_packno , 
                      "prjnos_id" => save_prjnos_id ,"starttime" => save_starttime , "persons_id_upd" => persons_id_upd,
                      "tblname" => save_tblname,"tblid" => save_tblid,
                      "qty_sch" => save_qty_sch ,"qty" => save_qty ,"qty_stk" => save_qty_stk ,"qty_real" => save_qty_real,
                      "qty_rejection" => save_qty_rejection}                      
      lotstktbls.each do |lotstktbl|
        if lotstktbl["suppliers_id_fm"] and lotstktbl["suppliers_id_fm"] != ""
            lotstktbl["suppliers_id"] = lotstktbl["suppliers_id_fm"] 
            Shipment.proc_mk_supplierwhs_rec "in",lotstktbl
        else  
          if lotstktbl["suppliers_id_to"] and lotstktbl["suppliers_id_to"] != ""
              lotstktbl["suppliers_id"] = lotstktbl["suppliers_id_to"] 
              Shipment.proc_mk_supplierwhs_rec "in",lotstktbl
          else
            if lotstktbl["custrcvplcs_id"] and lotstktbl["custrcvplcs_id"] != "" 
              Shipment.proc_mk_custwhs_rec "in",lotstktbl
            else
              if lotstktbl["shelfnos_id"].nil? or lotstktbl["shelfnos_id"] == ""
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