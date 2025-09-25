class IntegrityJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ### Rails.logger.debug" test #{args[0]}  "
    error = false
    args.each do |arg|
      if arg["table"]
        arg["table"].each do |tbl|
          case tbl
            when "trngantts"
              strsql = "select * from trngantts t
                                  inner join alloctbls a on a.srctblname = t.tblname and a.srctblid = tblid and t.id = a.trngantts_id
                                  where t.mkprdpurords_id_trngantt  = (select max(mkprdpurords_id_trngantt) from trngantts)
                                  order by a.srctblname" 
              ActiveRecord::Base.connection.select_all(strsql).each do |rec|
                case rec["srctblname"]
                  when /purschs|prdschs/
                    ###
                    #  qty_sch check
                    ###  
                    if rec["qty_sch"]  != rec["qty_linkto_alloctbl"]
                        error = true
                        Rails.logger.debug" LINE:#{__LINE__},   #{rec["tblname"]},id:#{rec["tblid"]} qty_sch unmatch alloctbls:#{rec["qty_linkto_alloctbl"]} ,trngantts:#{rec["qty_sch"]}"
                        next
                    end
                    strsql = %Q&
                                  select srctblname,srctblid,sum(qty_src) qty_src from linktbls 
                                            where  srctblname = '#{rec["srctblname"]}'  and srctblid =  #{rec["srctblid"]} and tblname = srctblname and tblid = srctblid
                                            and trngantts_id =  #{rec["trngantts_id"]}
                                            group by srctblname,srctblid
                    &
                    link = ActiveRecord::Base.connection.select_one(strsql)
                    if rec["qty_sch"]  != link["qty_src"]
                        error = true
                        Rails.logger.debug"error LINE:#{__LINE__}, #{rec["tblname"]},id:#{rec["tblid"]} qty_sch unmatch linktbls:#{link["qty_src"]} ,trngantts:#{rec["qty_sch"]}"
                        next
                    end
                    ###
                    #  opeitms check
                    ###
                    strsql = %Q&
                                select * from opeitms where itms_id = #{rec["itms_id_trn"]} and processseq = #{rec["processseq_trn"]}
                    &  
                    opeitms = ActiveRecord::Base.connection.select_all(strsql)
                    strsql = %Q&
                                select * from #{rec["srctblname"]} where id = #{rec["srctblid"]} 
                             &  
                    schtbl = ActiveRecord::Base.connection.select_one(strsql)
                    matchflg = false
                    ope = nil
                    opeitms.each do |opeitm|
                      if opeitm["id"] == schtbl["opeitms_id"]
                        matchflg = true
                        ope = opeitm.dup
                      end
                    end
                    if matchflg == false
                        error = true
                        Rails.logger.debug"error LINE:#{__LINE__},   trngantts ,#{rec["srctblname"]} opeitm_id unmatch id:#{rec["srctblid"]} "
                        next  
                    end
                    ### parent duedate
                    case rec["paretblname"]
                      when /prdschs|purschs/   ###
                        strsql = %Q&
                                    select sch.* from #{rec["paretblname"]} sch
                                        inner join alloctbls alloc on alloc.srctblid = sch.id and alloc.srctblname = '#{rec["paretblname"]}'
                                        where  sch.id = #{rec["paretblid"]} and sch.qty_sch = alloc.qty_linkto_alloctbl  ---ord 発行分は除く
                        & 
                        paretbl = ActiveRecord::Base.connection.select_one(strsql)
                        if paretbl
                          if paretbl["duedate"] != rec["duedate_pare"] or paretbl["starttime"] != rec["starttime_pare"]
                            error = true
                            Rails.logger.debug"error LINE:#{__LINE__},   trngantts ,paretbl:#{rec["paretblname"]} duedate or starttime unmatch paretblid:#{rec["paretblid"]} "
                            next                                                      
                          end 
                          if schtbl["duedate"] != rec["duedate_trn"] or schtbl["starttime"] != rec["starttime_trn"]
                            error = true
                            Rails.logger.debug"error LINE:#{__LINE__},   trngantts ,tbl:#{rec["srctblname"]} duedate or starttime unmatch tblid:#{rec["tblid"]} "
                            next                                                      
                          end 
                          if schtbl["duedate"] < schtbl["starttime"] 
                            error = true
                            Rails.logger.debug"error LINE:#{__LINE__},  trngantts  duedate:starttime logic error tblid:#{rec["tblid"]},duedate:#{schtbl["duedate"]} < starttime:#{schtbl["starttime"]} "
                            next                                                      
                          end
                          #
                          #  休日の考慮なし  duedate:starttime check
                          #
                          if ope["unitofduration"]  == "Day " and ope["duration"] == ope["duration"].floor
                              if schtbl["starttime"] > (schtbl["duedate"].to_date -  ope["duration"])
                                Rails.logger.debug"error  duedate:starttime logic error tbl:#{rec["srctblname"]},tblid:#{rec["tblid"]} duedate:#{schtbl["duedate"]},starttime:#{schtbl["starttime"]},duration:#{ope["duration"]} "                               
                              end 
                          else
                              if schtbl["starttime"] > (schtbl["duedate"].to_time -  ope["duration"]*60*60)
                                Rails.logger.debug"error LINE:#{__LINE__},   duedate:starttime logic error tbl:#{rec["srctblname"]},tblid:#{rec["tblid"]} duedate:#{schtbl["duedate"]},starttime:#{schtbl["starttime"]},duration:#{ope["duration"]} "                                          
                              end  
                          end
                          #
                          #   qty_sch check
                          #
                          strsql = %Q&
                                select * from #{rec["srctblname"]} where id = #{rec["srctblid"]} 
                              &  
                          schtbl = ActiveRecord::Base.connection.select_one(strsql)
                          strsql = %Q&
                                      select n.* from nditms n
                                                inner join opeitms o on o.id = n.opeitms_id
                                              where n.opeitms_id = #{paretbl["opeitms_id"]} and n.itms_id_nditm = #{rec["itms_id_trn"]} and n.processseq_nditm = #{rec["processseq_trn"]}
                          &
                          nditm = ActiveRecord::Base.connection.select_one(strsql)
                          if nditm ### dummyもある
                            ope["packqty"] = 1 if ope["packqty"].to_i == 0  #
                            tmp_qty_sch = ((paretbl["qty_sch"] / nditm["parenum"]) * nditm["chilnum"]/nditm["consumunitqty"]).ceil * nditm["consumunitqty"] 
                            tmp_qty_sch = ((tmp_qty_sch + nditm["consumchgoverqty"])/ope["packqty"]).ceil * ope["packqty"]  
                            if rec["qty_sch"] != tmp_qty_sch 
                                Rails.logger.debug"error LINE:#{__LINE__},   qty_sch error tbl:#{rec["srctblname"]},tblid:#{rec["tblid"]}, pare_qty_sch:#{paretbl["qty_sch"]}, qty_sch:#{schtbl["qty_sch"]} "                                          
                            end  
                          end
                        end 
                    end
                  when /shpests/
                    #
                    # 金型。工具の出庫予定
                    # 
                  when /dvsschs/
                    #
                    #    装置
                    #    
                  when /ercschs/
                    #
                    #  　人員手配
                    #  
                  when /conschs/
                    #
                    #  　消費
                    #  
                  when /dymschs/
                    #
                    #   dummy　　pur,prd未定
                    #
                  when /custords/
                  when /purords|prdords/  ### ords insts dlv acts 。。。
                    strsql = %Q&
                              select 1 from linktbls where srctblname = '#{rec["srctblname"]}' and  srctblid = #{rec["srctblid"]}   
                                                        and  (srctblname != tblname or srctblid != tblid) 
                    &
                    nexttbl = ActiveRecord::Base.connection.select_one(strsql)
                    if nexttbl.nil?   ### insts,actsには変化してない
                       if rec["srctblname"] =~ /ords$|insts$/
                         strQty = "qty"
                       else
                         strQty = "qty_stk"
                       end
                      strsql = %Q&
                                  select #{strQty} from  #{rec["srctblname"]} where id = #{rec["srctblid"]}   
                      &
                      selfTblQty = ActiveRecord::Base.connection.select_value(strsql)
                      strsql = %Q&
                              select sum(qty_linkto_alloctbl) qty_src from alloctbls where srctblname = '#{rec["srctblname"]}' and  srctblid = #{rec["srctblid"]}  
                              &
                      allocTblQty = ActiveRecord::Base.connection.select_value(strsql) 
                    end
                    if selfTblQty != allocTblQty
                        error = true
                        Rails.logger.debug"error LINE:#{__LINE__},   #{rec["srctblname"]},id:#{rec["srctblid"]} qty unmatch #{rec["srctblname"]}_qty:#{selfTblQty} ,alloctbls_qty:#{allocTblQty}"
                        next                      
                    end
                end
              end
          end
        end
      end
    end
    if error == false
        Rails.logger.debug" ok   "
    end
  end
end
