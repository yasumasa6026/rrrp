# -*- coding: utf-8 -*-
module CtlFields
	extend self
	def proc_fetch_rec params,parse_linedata
		params[:err] = nil
		params[:errFields] = {}
		fetchview = save_fetch = ""  ### save_fetchview:複数項目でkeyを構成するする時の重複処理を避ける
		params[:fetchview].split(",").each do |fetch|
			fetchview,delm = fetch.split(":")   ## YupSchemaでparagrapfをもとに作成済　split(":")拡張子の確認
			next if fetch == save_fetch
			delm ||= ""
			params = detail_fetch_rec(params,fetchview,delm,parse_linedata)
			save_fetch = fetch	
		end
		params[:errFields].each do |k,v|   ###複数error対応
				if params[:err]
					params[:err] << v + ","	
				else
					params[:err] =  v + ","	
				end
		end
		return params
	end
	def  detail_fetch_rec(params,fetchview,delm,parse_linedata)
		params,parseLineData,keyfields,findstatus,mainviewflg,missing = get_fetch_rec(params,fetchview,delm,parse_linedata)
									Rails.logger.debug(%Q%class:#{self},line:#{__LINE__},findstatus:#{findstatus}%)
		params[:parse_linedata] = parseLineData.dup
	  if findstatus  ###true:record found
			if mainviewflg   ##mainviewflg = true:自分自身の登録  false:自身の変更また他のview
				##if 	params[:parse_linedata]["aud"] == "add" or params[:aud] =~ /add/
					params[:errFields]["error1"] =  "error1 duplicate code:#{keyfields},line:#{params[:index]} "
					params[:keys] = []
					keyfields.split(",").each do |key| 
				  	params[:keys] =  [key.split(":")[0].gsub(" ","")] 
						params[:parse_linedata][key+"_gridmessage"] = "error 1a duplicate code #{key} "
						if params[:parse_linedata][:errPath].nil? 
							params[:parse_linedata][:errPath] = [key.split(":")[0]+"_gridmessage"]
						else
							params[:parse_linedata][:errPath] << key.split(":")[0]+"_gridmessage" 
						end
					end  
				# else
				# 	params[:errFields].delete("error1")
        #   viewCode = "#{params[:screenCode].split("_")[1].chop}_code"
				#   params[:parse_linedata].each do |key,val| ###コードが変更されたとき既に使用されている？
				# 	  if key == viewCode
        #       strsql = %Q&
        #                   select code from #{params[:screenCode].split("_")[1]}
        #                               where id = #{params[:parse_linedata][:id]}
        #       &
        #       last_code =ActiveRecord::Base.connection.select_value(strsql)
        #       if params[:parse_linedata][viewCode] ==  last_code  ###変更されていない。
        #         next
        #       else
        #         strsql = %Q&
        #                   select pobject_code_tbl tblname,pobject_code_fld fld from r_tblfields
        #                           where  pobject_code_fld like '#{params[:screenCode].split("_")[1]}_id%'
        #                           and tblfield_expiredate > current_date
        #           &
        #           ActiveRecord::Base.connection.select_all(strsql).each do |tbl|
        #             strsql = %Q&
        #                     select 1 from #{tbl["tblname"]} where #{tbl["fld"]} = #{JSON.parse(params[:lineData])["id"]} 
        #             &  ###params[:lineData] 修正前のデータ
        #             if ActiveRecord::Base.connection.select_value(strsql)  ###既に別tblに登録されている。
				# 						    params[:errFields]["error22"] = params[:parse_linedata][("#{key}_gridmessage")] =  "error22 cannot change ---> code:#{params[:parse_linedata][viewCode]}"
        #                 break
				# 						else
				# 							params[:errFields].delete("error22")
        #             end
        #           end
        #       end
				# 	  end
				#   end
        # end		
			else
					keyfields.split(",").each do |key| 
					  params[:parse_linedata][key.split(":")[0]+"_gridmessage"] = "deteted"
          end
					params[:errFields].delete("error22")
			end
			params[:errFields].delete("error29")
	  else   ###not find
			if mainviewflg   ###自身の登録の時
				###
				### r_tblfieldsの登録でr_blktbsがdetectできなかった時エラーにならない。!!!!!!!!!
				###
				params[:keys] = []
				keyfields.split(",").each do |key| 
				 	params[:keys] =  [key.split(":")[0].gsub(" ","")] 
				 	params[:parse_linedata][key+"_gridmessage"] = nil
				 	if params[:parse_linedata][:errPath] 
				 		params[:parse_linedata][:errPath] = nil
				 	end
				end  
			else
				params[:errFields].delete("error29")
				if missing  ###検索に必要
							params[:errFields]["error29"] =  "error29  --->not find code:#{keyfields},view:#{fetchview},line:#{params[:index]}  "
							params[:parse_linedata]["confirm"] = false
							keyfields.split(",").each do |key| ###コードが変更されたとき既に使用されている？
								params[:parse_linedata][key.split(":")[0]+"_gridmessage"] = "error 2a not find code #{key} "
								if params[:parse_linedata][:errPath].nil? 
									params[:parse_linedata][:errPath] = [key.split(":")[0]+"_gridmessage"]
								else
									params[:parse_linedata][:errPath] << key.split(":")[0]+"_gridmessage"
								end
							end 
				end	  
			end  
	  end 
	  return params 
	end  

	def get_fetch_rec(params,fetchview,delm,parse_linedata)
			parseLineData = parse_linedata.dup   ### loop 中に内容の変更はできない。
			keyfields = ""
			xno = ""
			screentblnamechop = params[:screenCode].split("_")[1].chop   ###main table
			viewtblnamechop = fetchview.split("_")[1].chop   ### sub table
			mainviewflg = true  ##自分自身の登録か？
			findstatus = true
			if params[:aud] !~ /add|insert/
					mainviewflg = false
			else
				if delm != ""   ###自身のテーブルを参照しいるとき
					mainviewflg = false
				end	
			end
			flgfetchview = fetchview + if delm == "" then "" else ":#{delm}" end	  
	    #fetcfieldgetsql = "select pobject_code_sfd,screenfield_paragraph from r_screenfields
			# 					 where pobject_code_scr =  '#{params[:screenCode]}' 
			# 					 and screenfield_paragraph like '%#{flgfetchview}%'"
        fetcfieldgetsql = "select p.code  pobject_code_sfd,s.paragraph screenfield_paragraph  from screenfields s
		                           inner join pobjects p on p.id = s.pobjects_id_sfd -- and p.objecttype = 'view_field' 
	                             where s.screens_id  = (select scr.id from screens scr 
	 		 						                                      inner join pobjects p2   on p2.id = scr.pobjects_id_scr 
	 		 									                              and p2.objecttype  = 'screen' and scr.expiredate > current_date
	 		 									                              and p2.code = '#{params[:screenCode]}'  order by scr.expiredate limit 1) 
			  					              and s.paragraph like '%#{flgfetchview}%' ---先頭の“%”は複数のviewに対応ため"
			missing = false   ###missing:true パラメータが未だ未設定　　false:チェックok
			where_strsql = ""
			fetchs = ActiveRecord::Base.connection.select_all(fetcfieldgetsql)
			cnt = 0
      paragraphs = []
			fetchs.each do |prefetch|
				prefetch["screenfield_paragraph"].split(",").each do |paragraph|
					if paragraph == flgfetchview   
						paragraphs << prefetch["pobject_code_sfd"]
					else
						next
					end
				end
			end	
			currentKeys = {}
			save_fetch = ""
			paragraphs.each do |fetch|  ###viewの複数keyの入力確認
					cnt += 1 
					valOfField = parseLineData[fetch]
					if valOfField =~ /,/				 ###入力項目に「,」が入っていた時
						params[:errFields]["error33"] =  "error33  --->not input comma:#{params[:index]} "
						parseLineData[(fetch+"_gridmessage")] =  "error33 --->not input comma"  ###!!!
						missing = true
						findstatus = false
						break
					else
						params[:errFields].delete("error33") 
						if valOfField == "" or valOfField.nil?   ###未入力
							missing = true
							findstatus = false
							break
						else
							keyfields <<  "#{fetch}: '#{valOfField}',"
							currentKeys[fetch] = valOfField
							case fetch 
								when /_sno_|_cno_|_packinglistno_/
							 		### 
									prefix,xno,srctblnamechop = fetch.split("_") ###xxx_sno_yyyy,xxx_cno_yyy用
									where_strsql << " #{viewtblnamechop}_#{xno} = '#{parseLineData[fetch]}'       and"
								else
									if delm == ""
										where_strsql << "  #{fetch} = '#{parseLineData[fetch]}'        and"
									else
										where_strsql << "  #{fetch.split(delm)[0]} = '#{parseLineData[fetch]}'       and"
									end
							end
							save_fetch = fetch
							missing = false 
						end
					end
			end
      rec = nil
			params[:errFields].delete("error39")			
			if missing == false  ###検索のための入力項目はすべて入力されている。
          	###if 	parseLineData["aud"] =~ /update|edit/ or params[:aud] =~ /update|edit/
          	if 	parseLineData["id"]  and parseLineData["id"] != "" and screentblnamechop == viewtblnamechop
								strsql = %Q&select * from r_#{screentblnamechop}s where id = #{parseLineData["id"]}  --- ##自身の登録のとき
											&
								mainTblRec = ActiveRecord::Base.connection.select_one(strsql)  ### 自身のrecord
								if mainTblRec.nil?  ##
								else
									###strsql = " select * from #{fetchview}  where " + where_strsql[0..-8] 
									###rec =  ActiveRecord::Base.connection.select_one(strsql)				
									currentKeys.each do |k,v|  ###keyが変更されているとき
										case mainTblRec[k].class.to_s
											when "BigDecimal","Float" 
												v= v.to_f
											when "Integer" 
												v= v.to_i
											when "Date"
												v= v.to_date
											when "Time"
												v= v.to_time
										end
										if mainTblRec[k] != v  ###keyが変更されているとき
											sqlForeignKey = %Q%
											               		SELECT
    																			tc.table_name AS child_table, kcu.column_name AS child_column
																				FROM     information_schema.table_constraints AS tc 
    																		JOIN information_schema.key_column_usage AS kcu
      																			ON tc.constraint_name = kcu.constraint_name   AND tc.table_schema = kcu.table_schema
    																		JOIN information_schema.constraint_column_usage AS ccu
      																			ON ccu.constraint_name = tc.constraint_name  AND ccu.table_schema = tc.table_schema
																				WHERE  tc.constraint_type = 'FOREIGN KEY'  AND ccu.table_name = '#{screentblnamechop}s'
																			%
											alreadyUseF = false
											ActiveRecord::Base.connection.select_all(sqlForeignKey).each do |ftbl|
												ftblRec = ActiveRecord::Base.connection.select_one(%Q% select * from #{ftbl["child_table"]} where #{ftbl["child_column"]} = #{mainTblRec["id"]}%)		
												if ftblRec
													### ###keyが変更されているときは、自分自身の登録以外。
													if parseLineData[(screentblnamechop+"_#{k}_gridmessage")]
														parseLineData[(screentblnamechop+"_#{k}_gridmessage")] << ",#{ftbl["child_table"]}"			
														params[:errFields]["error39"] = parseLineData[(screentblnamechop+"_#{k}_gridmessage")] 													
													else
														params[:errFields]["error39"] = parseLineData[(screentblnamechop+"_#{k}_gridmessage")] =  "error39 already used table:#{ftbl["child_table"]} "
													end
													alreadyUseF = true
												end
											end
											if alreadyUseF == false		
											end
										else
												if delm != ""   ###自身のテーブルを参照しいるとき
															mainviewflg = false
												end	
										end
									end
								end	
						else
								strsql = " select * from #{fetchview}  where " + where_strsql[0..-8] 
								rec =  ActiveRecord::Base.connection.select_one(strsql)
								if screentblnamechop != viewtblnamechop
										mainviewflg = false							
								end
						end
			else
						rec = nil
						findstatus = false
			end
									Rails.logger.debug(%Q%class:#{self},line:#{__LINE__},rec:#{rec}%)
			if rec  ###viewレコードあり				
					findstatus = true
          fieldsall = rec.keys 
					allLineKeys = parseLineData.keys
					 ## /_sno$|_cno$|_gno$|_isudate|_created_at|_updated_at|_remark|_contents|_seqno/
					 # new_array = array.reject { |x| x >= 3 }
					fields = fieldsall.reject{|i| i =~ /^id$|_sno$|_cno$|_gno$|_isudate$|_created_at$|_updated_at$|_update_ip$|_remark$|_contents$|_seqno|_upd$/}
					### masterの項目名をセット
					if screentblnamechop =~ /sch$|ord$|inst$|replyinput$|dlv$|act$/ and viewtblnamechop =~ /sch$|ord$|inst$|replyinput$|dlv$|act$/ ###prd,pur,custxxxxのとき
						org = nil
						fields.each do |af|
								mainaf = af + delm  ###
								ix = allLineKeys.index(mainaf)
								if ix    ### schsの項目はords に　ords,instsも同様
										### masterの項目名を自身の項目として
										parseLineData[allLineKeys[ix]] = rec[af].to_s 
								else
										if af == (viewtblnamechop + "_id")
														ix = allLineKeys.index(screentblnamechop + "_" + viewtblnamechop + "_id" + delm)
														if ix   
																	parseLineData[allLineKeys[ix]] = rec[af].to_s
														end
										else
												mainaf = af.sub(/^#{viewtblnamechop}/,"#{screentblnamechop}")  ### schs -> ords  ords -> insts  insts -> dlvs  dlvs -> acts
												mainaf = mainaf + delm  ### 
												next if mainaf == "#{screentblnamechop}_id"  ###idは別途処理
												ix = allLineKeys.index(mainaf)
												if ix   
													### masterの項目名を自身の項目として
													parseLineData[allLineKeys[ix]] = rec[af].to_s
												end
										end
								end
						end 
						case screentblnamechop
							when /prd|pur/
								  str_srctbl_qty = "" ###次のステータスに移行していないqtyを求める。　
								  	### qtyのセット
									lineStrQty = ""
									case screentblnamechop
								  	when /sch$/
											lineStrQty = (screentblnamechop+"_qty_sch")
										when /ord$|inst$|replyinput/   
											lineStrQty = (screentblnamechop+"_qty")
										when /dlv$|act$/   
											lineStrQty = (screentblnamechop+"_qty_stk")
								  end
									viewStrQty = ""
									case viewtblnamechop
								  	when /sch$/
											viewStrQty = "qty_sch"
										when /ord$|inst$|replyinput/   
											viewStrQty = "qty"
										when /dlv$|act$/   
											viewStrQty = "qty_stk"
								  end
									if parseLineData[lineStrQty].to_s == "0"   ###初期値でzeroがセットされていること
									    str_srctbl_qty = "max(srctbl.#{viewStrQty}) srctbl_qty"
											if	xno =~ /_cno/  ###xxx_cnoのとき
						 						if  parseLineData[(screentblnamechop+"_shelfno_id")] != ""  and  !parseLineData[(screentblnamechop+"_shelfno_id")].nil? and
						 							screentblnamechop =~ /pur/
						 								str_loca_code = "and shelfnos_id = #{parseLineData[(screentblnamechop+"_shelfno_id")]}"
									  				strsql = %Q% select sum(COALESCE(link.qty_src,0)) qty_src ,#{str_srctbl_qty},max(ope.packqty) packqty
																					from #{viewtblnamechop}s srctbl 
																		left join  linktbls link  on srctbl.id = link.srctblid	and link.srctblname = '#{viewtblnamechop}s'
																								and (link.srctblname != link.tblname or link.srctblid != link.tblid)
																								and link.tblid != #{rec[(viewtblnamechop+"_id")]} 
																		inner join opeitms ope on opeitms_id = ope.id
																		where srctbl.sno = '#{parseLineData[(screentblnamechop+"_sno_"+viewtblnamechop)]}' ---key.split("_")[1] :sno
																		#{str_loca_code}
																		group by srctbl.id
										  						%
						 						end
											else	####\ sno
									  		strsql = %Q% select sum(COALESCE(link.qty_src,0)) qty_src ,#{str_srctbl_qty},max(ope.packqty) packqty
																					from #{viewtblnamechop}s srctbl 
																		left join  linktbls link  on srctbl.id = link.srctblid	and link.srctblname = '#{viewtblnamechop}s'
																								and (link.srctblname != link.tblname or link.srctblid != link.tblid)
																								and link.tblid != #{rec[(viewtblnamechop+"_id")]}
																		inner join opeitms ope on opeitms_id = ope.id 
																		where srctbl.sno = '#{parseLineData[(screentblnamechop+"_sno_"+viewtblnamechop)]}' ---key.split("_")[1] :sno
																		group by srctbl.id
										  						%
											end  
											org =  ActiveRecord::Base.connection.select_one(strsql)
									end
							when /pay|bill/
								  str_srctbl_amt = ""
								  if 	(viewtblnamechop =~ /ord$/ and screentblnamechop =~ /act$/) or 
									  	(viewtblnamechop =~ /inst$/ and screentblnamechop =~ /act$/) 
									    if parseLineData[(screentblnamechop+"_cash")].to_s == "0"   ###初期値でzeroがセットされていること
										    str_srctbl_amt = "max(srctbl.amt) srctbl_amt"
									    end
									  strsql = %Q% select sum(COALESCE(link.amt_src,0)) amt_src ,#{str_srctbl_amt}
											from #{viewtblnamechop}s srctbl 
											left join  srctbllinks link  on srctbl.id = link.srctblid	and link.srctblname = '#{viewtblnamechop}s'
																		and (link.srctblname != link.tblname or link.srctblid != link.tblid)
											where srctbl.sno = #{parseLineData[(screentblnamechop+"_sno_"+viewtblnamechop)]} ---key.split("_")[1] :sno
											group by srctbl.id
										  %  
									  org =  ActiveRecord::Base.connection.select_one(strsql)
								  end
							when /custord|custdlv|custact/
						end
						if org	###既に状態が変化している
								case screentblnamechop
							  	when /prd|pur/
								  		if org["qty_src"] > org["srctbl_qty"] 
									  		case screentblnamechop
									    		when /ord$|inst$|replyinput/
									  				params[:errFields]["error42"] =  "error42--->over qty  line:#{params[:index]} "
										    		parseLineData[(screentblnamechop+"_qty_gridmessage")] =  "error 42--->over qty"
									    		when /dlv$|act$/
									  					params[:errFields]["error43"] =  "error43 --->over qty  line:#{params[:index]} "
										    			parseLineData[(screentblnamechop+"_qty_case_gridmessage")] =  "error43--->over qty_case"
									  		end
												parseLineData[(screentblnamechop+"_qty_case")] = 0 
											else
												parseLineData[(screentblnamechop+"_qty_case")] = ((org["srctbl_qty"] - org["qty_src"])/org["packqty"]).ceil 
												parseLineData[lineStrQty] = parseLineData[(screentblnamechop+"_qty_case")] * org["packqty"]
												params[:errFields].delete("error42")
												params[:errFields].delete("error43")
											end
									when /custord|custinst|custdlv|custact/
							  	when /pay|bill/
								    	if org["amt_src"] >= org["srctbl_amt"] 
									    	params[:errFields]["error44"] =  "error44--->over cash  line:#{params[:index]} "
									    	case screentblnamechop
									      	when /inst$/
										      	parseLineData[(screentblnamechop+"_amt_gridmessage")] =  "error45 --->over cash"
									      	when /act$/
										      	parseLineData[(screentblnamechop+"_cash_gridmessage")] =  "error46 --->over cash"
									    	end
											else
												params[:errFields].delete("error44")
                    	end
                end
						end		
					else ##/person|pobject|chrg|sect|loca|itm|cust$|custrcv|......../
						if mainviewflg == false
							if delm == "" 
								if  screentblnamechop == viewtblnamechop
										f = 	"#{screentblnamechop}_id"
								else
										f = 	"#{screentblnamechop}_#{viewtblnamechop}_id"
								end
								idx = allLineKeys.index(f)  ###同一viewでkeyが異なる。
								if idx
									parseLineData[allLineKeys[idx] ] = rec["id"].to_s
									parseLineData[(allLineKeys[idx].to_s + "_gridmessage")] = "deteted"
									fields.each do |af|
											ix = allLineKeys.index(af)
											if ix
													### masterの項目名をセット
													parseLineData[allLineKeys[ix] ] = rec[af].to_s
											end
											# mainaf = af.sub(/^#{viewtblnamechop}/,"#{screentblnamechop}")
											# next if mainaf == "#{screentblnamechop}_id"
											# ix = allLineKeys.index(mainaf)
											# 			if ix
											# 				### masterの項目名を自身の項目として
											# 				parseLineData[allLineKeys[ix] ] = rec[af].to_s
											# 			end
											# ###マスターの内容をsfixなしてもセット
											# mainaf = af.sub(/_#{viewtblnamechop}$/,"")
											# ix = allLineKeys.index(mainaf)
											# if ix
											# 		### masterの親項目名を自身の項目として
											# 		parseLineData[allLineKeys[ix] ] = rec[af].to_s
											# end
											if viewtblnamechop =~ /opeitms|nditms|custs/  and screentblnamechop =~ /schs$|ords$|acts$/  ###opeitm,nditmのとき
												mainaf = af.sub(/^#{viewtblnamechop}/,"#{screentblnamechop}").sub(/_#{viewtblnamechop}$/,"")
												next if mainaf == "#{screentblnamechop}_id"
												ix = allLineKeys.index(mainaf)
												if ix
													parseLineData[allLineKeys[ix] ] = rec[af].to_s
												end
											end
									end
									if screentblnamechop =~ /custsch|custord/ and viewtblnamechop =~  /opeitm/ ### custschs,custordsのopeitms_idは出荷場所
										if parseLineData["shelfno_code_fm"] == "" or parseLineData["shelfno_code_fm"].nil? 
								  		 	parseLineData["loca_code_shelfno_fm"] = rec["loca_code_shelfno_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   			parseLineData["shelfno_code_fm"] = rec["shelfno_code_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   			parseLineData["loca_name_shelfno_fm"] = rec["loca_name_shelfno_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   			parseLineData["shelfno_name_fm"] = rec["shelfno_name_to_opeitm"]  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
								   			parseLineData["#{screentblnamechop}_shelfno_id_fm"] = rec["opeitm_shelfno_id_to_opeitm"].to_s  ###opeitm.shelfno_code_to_opeitm 完成後の置き場所゜
												###custord.shelfno_code_fm 客先への出荷のための梱包場所
										end
									end
									params[:errFields].delete("error31")
								else
									params[:errFields]["error31"] =  "error31 logic error  --->not found key:#{f},line:#{params[:index]} "
								end	##idは別途処理
							else
								if  screentblnamechop == viewtblnamechop
										f = 	"#{screentblnamechop}_id" + delm
								else
										f = 	"#{screentblnamechop}_#{viewtblnamechop}_id" + delm
								end
								idx = allLineKeys.index(f)  ###同一viewでkeyが異なる。
								if idx
									parseLineData[allLineKeys[idx] ] = rec["id"]
									parseLineData[(allLineKeys[idx].to_s + "_gridmessage")] = "deteted"
									fields.each do |af|
											afd = af + delm
											ix = allLineKeys.index(afd)
											if ix
													parseLineData[allLineKeys[ix] ] = rec[af].to_s
											end
									end
									params[:errFields].delete("error3")
								else
									params[:errFields]["error3"] =  "error3 logic error --->not found key:#{f},line:#{params[:index]} "
								end
								###
								#  sfixがない項目もあるとき
								###
								if  screentblnamechop =~ /sch$|ord$/   ###opeitm,nditmのとき
									f = 	"#{screentblnamechop}_#{viewtblnamechop}_id}"
									idx = allLineKeys.index(f)  ##。
									if idx
										parseLineData[allLineKeys[idx] ] = rec["id"]
										parseLineData[(allLineKeys[idx].to_s + "_gridmessage")] = "deteted"
										fields.each do |af|
											ix = allLineKeys.index(af)
											if ix
													parseLineData[allLineKeys[ix]] = rec[af].to_s
											end
										end
									else
										### エラーではない
									end
								end		
							end
						end	
					end
			else
						findstatus = false
						##再入力時のNgに対応	
						if missing == false and mainviewflg == false
							if screentblnamechop != viewtblnamechop and xno !~ /_sno|_cno|_packinglistno/ ### omit self table
								### sno,cnoの時は例えば r_puractsにpurord_idを含んでない。(sno_purord,sno_ourdlv等どちらを使用するか不明。)
								field = (screentblnamechop+"_"+viewtblnamechop+"_id"+delm)
								parseLineData[field] =  ""
							end
							parseLineData[(save_fetch+"_gridmessage")] =  "error not detected" 
						end
      end
			return params,parseLineData,keyfields,findstatus,mainviewflg,missing
	end		

	def proc_blkuky_check tbl,parseLineData   ###重複チェック
		save_blkuky_grp = nil
		keyfields = []
		rslt = {}
		strsql = %Q% select blkuky_grp,pobject_code_fld from r_blkukys where pobject_code_tbl = '#{tbl}' 
						and blkuky_expiredate > current_date order by blkuky_grp,blkuky_seqno%
						
		ActiveRecord::Base.connection.select_all(strsql).each do |rec|
			if save_blkuky_grp != rec["blkuky_grp"] 
				if  !save_blkuky_grp.nil? and keyfields.exclude?("id")
					rslt = blkuky_check_detail tbl,keyfields,parseLineData,rslt
					keyfields = []
				end
				save_blkuky_grp = rec["blkuky_grp"]
			end
			keyfields << rec["pobject_code_fld"]
		end
		if !keyfields.empty? and keyfields.exclude?("id")  ### id付きの検索keysはたんなるindexのためskip
			rslt = blkuky_check_detail tbl,keyfields,parseLineData,rslt
		end
		return rslt
	end	

	def blkuky_check_detail tbl,keyfields,parseLineData,rslt
		strwhere = " where "
		keyfields.each do |key|
			symkey = (tbl.chop + "_" + key.gsub("s_id","_id"))
			if parseLineData[symkey].nil? or parseLineData[symkey]  == ""
				if strwhere =~ /where/ 
					strwhere = "       #{symkey} must be select      "
				else
					strwhere << " and #{symkey} must be select"
				end
				break
			else  ### not error
					strwhere << "  #{key} = '#{parseLineData[symkey]}'     and "
			end
		end
		if parseLineData["id"] == "" or parseLineData["id"].nil?  ###新規
			if strwhere =~ /where/ 
				strsql = "select id from #{tbl} " + strwhere[0..-5]
				recs = ActiveRecord::Base.connection.select_all(strsql)
				rslt[strwhere[6..-5]] = recs   ### strwhere[6..-5]  where 以外部分
			else
				rslt[strwhere[6..-5]] = []
			end
		else  ###変更
				strsql = %Q% select * from  #{tbl} where id =  #{parseLineData["id"]}%
				curRec = ActiveRecord::Base.connection.select_one(strsql)
				audEdit = true				
				keyfields.each do |key|
					symkey = (tbl.chop + "_" + key.gsub("s_id","_id"))
					case curRec[key].class.to_s
						when "BigDecimal","Float" 
							audEdit = false  if parseLineData[symkey].to_f != curRec[key].to_f
						when "Integer" 
							audEdit = false  if parseLineData[symkey].to_i != curRec[key]
						when "Date"
							audEdit = false  if parseLineData[symkey].to_date != curRec[key].to_date
						when "Time"
							audEdit = false  if parseLineData[symkey].to_time != curRec[key].to_time
						else
							audEdit = false  if parseLineData[symkey] != curRec[key]
					end
				end
				if audEdit == true  ### keyの変更はない
						rslt[strwhere[6..-5]] = []
				else
						if strwhere =~ /where/ 
								strsql = "select id from #{tbl} " + strwhere[0..-5]
								recs = ActiveRecord::Base.connection.select_all(strsql)
								rslt[strwhere[6..-5]] = recs
						else
								rslt[strwhere[6..-5]] = []
						end
				end
		end
		return rslt
	end

	###未コーディング
	#  screenfields.selection  viewtblchop_tblname_id は必ず選択
	#  nditms 子どものopeitmsへの存在チェック
	### 
	def proc_judge_check_code params,sfd,checkCode,parse_linedata  ###
		err = nil
		params[:err] = nil
		if params[:errFields]
			 	if params[:errFields].class.to_s == "String"
					params[:errFields] = JSON.parse(params[:errFields])		
				end 
		else
			params[:errFields] = {}
		end
		checkCode.split(",").each do |chk|
			chkLineData,err = __send__("proc_judge_check_#{chk}",parse_linedata,sfd,params[:index],params[:screenCode])  ###[1]: nil all,add,updateは画面側で判断
      if err
					if params[:errFields].select{|k,v| k == chk }.empty?
									params[:errFields][chk] = err
					else
									if params[:errFields][chk] == err
											next
									else
										 params[:errFields][chk] = err								
									end
					end
			else 
					if params[:errFields].select{|k,v| k == chk }.empty?
							next
					else
							params[:errFields].delete(chk)			
					end 			
      end
			parse_linedata = chkLineData.dup
		end
		params[:errFields].each do |k,v|
				next if v == nil or v == ""
				if params[:err]
					params[:err] << v + ","
				else
					params[:err] =  v + ","
				end	
		end
		params[:parse_linedata] = parse_linedata.dup
		return params 
	end	

	def proc_judge_check_paragraph parseLineData,item,index,screenCode ### proc_judge_check_codeからcallされる。
		tblname = screenCode.split("_")[1]
		if parseLineData["screenfield_paragraph"] == ""
			if parseLineData["pobject_code_sfd"] =~ /_code/ and tblname.chop == parseLineData["pobject_code_sfd"].split("_")[0]
				err =  "error 5 2   --->view or field  #{parseLineData["screenfield_paragraph"]}　not find line:#{index} "
			else	
				err =  nil
			end
		else	
			if parseLineData["screenfield_paragraph"]
				parseLineData["screenfield_paragraph"].split(",").each do |paragraph|
					screen,delm = paragraph.split(":",2)
					if parseLineData["pobject_code_sfd"] =~ /_sno_|_cno_|_gno_|_packinglistno_/
						if parseLineData["pobject_code_sfd"] !~ /^#{tblname.chop}/   ###目的のtableをsno_目的のtable名で指定
							case parseLineData["pobject_code_sfd"]
								when /_sno_/
									field = parseLineData["pobject_code_sfd"].split("_sno_")[1] + "_sno"
								when /_cno_/
									field = parseLineData["pobject_code_sfd"].split("_cno_")[1] + "_cno"
								when /_gno_/
									field = parseLineData["pobject_code_sfd"].split("_gno_")[1] + "_gno"
								when /_packinglistno_/  ###invoiceに梱包と保守が含まれるときgnoは使用できない。
									field = parseLineData["pobject_code_sfd"].split("_packinglistno_")[1] + "_packinglistno"
								else
							end
						else   ###目的のtableを目的のtable名_id_自身のtable名で指定
							case parseLineData["pobject_code_sfd"]
								when /_sno_/
									field = parseLineData["pobject_code_sfd"].split("_sno_")[0] + "_sno"
								when /_cno_/
									field = parseLineData["pobject_code_sfd"].split("_cno_")[0] + "_cno"
								when /_gno_/
									field = parseLineData["pobject_code_sfd"].split("_gno_")[0] + "_gno"
								when /_packinglistno_/  ###invoiceに梱包と保守が含まれるときgnoは使用できない。
									field = parseLineData["pobject_code_sfd"].split("_packinglistno_")[0] + "_packinglistno"
								else
							end
						end
					else
						if delm
							field =  parseLineData["pobject_code_sfd"].gsub(delm,"")
						else	
							field =  parseLineData["pobject_code_sfd"]
						end
					end
					strsql = %Q%
							SELECT	pg_views.viewname AS view_name,column_name
		   						FROM   pg_views
			   					inner join information_schema.columns on table_name = pg_views.viewname 
		   						WHERE	   schemaname = current_schema() 
			   					and pg_views.viewname = '#{screen}' 
			   					and column_name = '#{field}'
						union --- MATERIALIZED VIEW columns
							SELECT 
							  	mv.relname as view_name  , ---matview_name
										  att.attname as column_name
								from pg_catalog.pg_attribute att
								join pg_catalog.pg_class mv ON mv.oid = att.attrelid
								join pg_catalog.pg_namespace nsp ON nsp.oid = mv.relnamespace
								where mv.relkind = 'm' 
								AND not att.attisdropped 
								and att.attnum > 0
								and mv.relname = '#{screen}'
								and nsp.nspname =  current_schema()
								and att.attname = '#{field}'			   				
						%
					rec = ActiveRecord::Base.connection.select_one(strsql)
					if rec
						err = nil
					else
						err =  "error 5 3   --->view or field  #{parseLineData["screenfield_paragraph"]}　not find line:#{index} "
					end
				end
			end
		end
		return parseLineData,err
	end	

	def proc_judge_check_strorder parseLineData,item,index,screenCode   ###　r_screens(screens)のみで有効
		if parseLineData["screen_strorder"] and parseLineData["screen_strorder"] != ""
			ary_select_fields = parseLineData.keys
			sort_info = {}
			sort_info[:default] = parseLineData["screen_strorder"]
			sort_info[:default].split(/\s*,\s*/).each do |sort_field|
				ok = false
				sort_field.split(" ").each do |chk|
					strsql = "select 1 from r_screenfields where pobject_code_scr =  '#{parseLineData["pobject_code_scr"]}'
															and screenfield_selection  = '1' and pobject_code_sfd = '#{chk}' "
					rec = ActiveRecord::Base.connection.select_one(strsql)
					if !rec.nil?
						ok = true
					else
						if ok==true and (chk.gsub(" ","").downcase=="asc" or chk.gsub(" ","").downcase=="desc")
						else
							sort_info[:default] = nil
							sort_info[:err] = "sort fields  error 6 1"
							break
						end		
					end		
				end	
			end	
			if sort_info[:err] 
				err =  sort_info[:err] + "line:#{index}" 
			else
				err =  nil
			end
		end
		return parseLineData,err
	end

	###社内用　loca_codeは社外で使用できない。
	def proc_judge_check_workplace_loca_code_not_used_suppliers_custwhs parseLineData,item,index,screenCode
		if parseLineData[item] 
			case screenCode
			when /workplaces/
				strsql = %Q%
					select id from r_suppliers where loca_code_supplier = '#{parseLineData[item]}'
												and supplier_expiredate > current_date
						union
					select id from r_custrcvplcs where loca_code_custrcvplc = '#{parseLineData[item]}'
													and custrcvplc_expiredate > current_date
				%
			when /suppliers|custwhs|custrcvplcs/
				strsql = %Q%
					select id from r_workplaces where loca_code_workplace = '#{parseLineData[item]}'
											and workplace_expiredate > current_date%
			end
			if  ActiveRecord::Base.connection.select_value(strsql)
				err =  " #{parseLineData[item]}  cant not use  loca_code_workplace same time (suppliers or custwhs) "
			else
				err =  nil
			end
		end
		return parseLineData,err
	end

	
	def proc_judge_check_workplaces parseLineData,item,index,screenCode
		if parseLineData["loca_code_workplace"] 
			strsql = %Q%
				select id from r_workplaces where loca_code_workplace = '#{parseLineData[item]}'
											and workplace_expiredate > current_date
			%
			if  ActiveRecord::Base.connection.select_value(strsql)
				err = nil
			else
				err =  " #{parseLineData["loca_code_workplace"]} not workplaces"
			end
		end
		return parseLineData,err
	end
	
	def proc_judge_check_suppliers parseLineData,item,index,screenCode
    err = nil
		if parseLineData["loca_code_supplier"] 
			strsql = %Q%
				select id from r_suppliers where loca_code_supplier = '#{parseLineData["loca_code_supplier"]}'
											and supplier_expiredate > current_date
			%
			if  ActiveRecord::Base.connection.select_value(strsql)
				err = nil
			else
				err =  " #{parseLineData["loca_code_supplier"]} not suppliers"
			end
		end
		return parseLineData,err
	end

	
	def proc_judge_check_prdpur parseLineData,item,index,screenCode
    ### shelfnos_idの妥当性チェック prd:workingplaces pur:suppliers その他:制限なし
		case parseLineData["loca_code_supplier"]
		when "pur"
			if parseLineData[item] 
				strsql = %Q%
					select id from r_suppliers where loca_code_supplier = '#{parseLineData["loca_code_supplier"]}'
											and supplier_expiredate > current_date
				%
				if  ActiveRecord::Base.connection.select_value(strsql)
					err = nil
				else
					err =  " #{parseLineData["loca_code_supplier"]} not suppliers"
				end
			end
		when "prd"
			if parseLineData["loca_code_workplace"] 
				strsql = %Q%
					select id from r_workplaces where loca_code_workplace = '#{parseLineData["loca_code_workplace"]}'
												and workplace_expiredate > current_date
				%
				if  ActiveRecord::Base.connection.select_value(strsql)
					err = nil
				else
					err =  " #{parseLineData["loca_code_workplace"]} not workplaces"
				end
			end
    else
      err = nil
		end
    ###
    # classlist_code == "ITool","installationCharge","mold","apparatus" のときは opeitmsは作成できない
    ###
    if parseLineData["classlist_code"] =~ /ITool|installationCharge|mold|apparatus/ and err.nil?
      err =  " #{parseLineData["classlist_code"]} not allow to create opeitms"
    else
      err = nil
    end
		return parseLineData,err
	end

	def proc_judge_check_qty parse_linedata,item,index,screenCode
		###　pur,prd schs,ords,insts,dlvs 数量増 ng
    ###pur,prdacts 条件による
		err = nil
		tblnamechop = screenCode.split("_")[1].chop
		if tblnamechop =~ /act|dlv|ret/
				return parse_linedata,err   ###err= nil
		end
		if parse_linedata["#{tblnamechop}_qty_case"]
		 		if parse_linedata["opeitm_packqty"]
						if parse_linedata["opeitm_packqty"].class.to_s == "String"
								if parse_linedata["opeitm_packqty"] == "0" or parse_linedata["opeitm_packqty"] == ""
				    				opeitm_packqty = "1"
								else		
										opeitm_packqty = parse_linedata["opeitm_packqty"].to_f
								end	
						else
							if parse_linedata["opeitm_packqty"].class.to_s =~ /Integer|Float/   ###when excel upload
										opeitm_packqty = parse_linedata["opeitm_packqty"]
							else
										return parse_linedata,err   ###err= nil
							end
						end
				end
				if parse_linedata["#{tblnamechop}_qty_case"].class.to_s == "String"
								qty_case = parse_linedata["#{tblnamechop}_qty_case"].gsub(",","").to_f
				else
					if parse_linedata["#{tblnamechop}_qty_case"].class.to_s =~ /Integer|Float/
							qty_case = parse_linedata["#{tblnamechop}_qty_case"]		
					else	
							return parse_linedata,err   ###err= nil
					end
				end
		else
			return parse_linedata,err   ###err= nil
		end
		qty = opeitm_packqty * qty_case
		case tblnamechop
				when /sch/	
					parse_linedata["#{tblnamechop}_qty_sch"] = qty.to_s
				else
					parse_linedata["#{tblnamechop}_qty"] = qty.to_s
		end
	 	return parse_linedata,err   ###err= nil
	end	
	
	def proc_judge_check_consumtype parseLineData,item,index,screenCode
		classlist = ""
    err = nil
		case screenCode
			when /nditms/
				strsql = %Q&
						select c.code from itms i
									inner join classlists c	on i.classlists_id = c.id		
									where i.id = #{parseLineData["nditm_itm_id_nditm"]}
				&
				classlist = ActiveRecord::Base.connection.select_value(strsql)
		  	case classlist
					when "pgoods","shikakari","material","parts"  ###半製品,仕掛品,原材料,子部品
			    	parseLineData["nditm_consumtype"] = "CON"
		    	when "ITool","installationCharge","mold","apparatus"
			    	parseLineData["nditm_consumtype"] = classlist
        	else
          	if parseLineData["opeitm_prdpur"] != "prd" and parseLineData["nditm_consumtype"] == "run"
            	err =  "error 6 2  ---> prdpur must be 'prd' when consumtype = 'run' "
          	end 
		  	end
			else
    end 
	 	return parseLineData,err   ###err= nil
	end	

	 def proc_judge_check_loca_code_to parseLineData,item,index,screenCode
	 	tblname =  screenCode.split("_")[1]
	 	id = parseLineData["#{tblname.chop}_id"]
    err = nil
	 	if id != ""  ###更新の時のみ　ords-->insts  insts -->actsに既にどれだけ変化しているか？
	 		sym = "loca_code_to"
	 		if parseLineData[sym] == ""
	 			err =  "error 7   --->#{sym} missing line:#{index} "
	 		else
	 			strsql = %Q%select sum(qty) from trngantts where orgtblname ='#{tblname}' and orgtblid = #{id} 
	 					 and  tblid = #{id} and tblname = '#{tblname}' group by orgtblname,orgtblid,tblname,tblid %
	 			trn_qty = ActiveRecord::Base.connection.select_value(strsql)
	 			chng_qty ||= 0.0  ###すでに次の状態に変化した数値
	 			strsql = %Q%select loca_code_to,#{tblname.chop}_qty from r_#{tblname} where id = #{id} %
	 			rec = ActiveRecord::Base.connection.select_one(strsql)
	 			if (chng_qty != rec["#{tblname.chop}_qty"] or rec["#{tblname.chop}_qty"]  != trn_qty) and 
	 					parseLineData[sym] != rec["loca_code_to"]
	 				checkstatus = false
	 				err =  "error 8   ---> loca_code_to must be >= #{rec["loca_code_to"]} line:#{index} "
				 else
					err =  nil
	 			end 
	 		end
	 	end
	 	return parseLineData,err
	 end	

	def proc_judge_check_already_used parseLineData,item,index,screenCode  ###あるidで登録されたcodeが別のテーブルに既に登録されているとき、codeの変更は不可
		if parseLineData["id"] and parseLineData["id"] != ""  ###変更の時 
      err = nil
			case screenCode
			when /itms/
			when /locas/
			when /pobjects/
				strsql = %Q%select code from pobjects where id = #{parseLineData["id"]}						
				%
				pobject_codes = ActiveRecord::Base.connection.select_values(strsql)
				pobject_codes.each do |pobject_code|
					if pobject_code != parseLineData["pobject_code"]
						strsql = %Q%select tfd.id from tblfields tfd
										inner join fieldcodes fld on tfd.fieldcodes_id  =  fld.id
										where pobjects_id_fld = #{parseLineData["id"]}  and tfd.expiredate > current_date
								%
						value = ActiveRecord::Base.connection.select_value(strsql)
						if value
							err =  "error 9   ---> #{pobject_code} can not change because table:tblfields already used line:#{index} "
						else
							err = nil
						end
					end
				end
			end
		end		
		if screenCode =~ /pobjects/   ###将来　履歴専用のtblを作成しこのチェックはなくす。
			if parseLineData["objecttype"] == "view"
				if parseLineData["code"] =~ /cust|prd|pur|shp/ and parseLineData["code"] =~ /schs$|ords$|oinsts$|replyinputs$|dlvs$|acts$|rets$/
					if parseLineData["code"].split("_")[0]  == "r"
					else
						err =  "error A  ---> view:#{code}   must be r_xxxxxxx 参照  "
					end
				end
			end
		end

		return parseLineData,err	
	end

	def proc_judge_check_same_loca_code_bill parseLineData,item,index,screenCode  ###MkInvoiveNoの時のみ
		err = nil
		return parseLineData,err
	end

	def proc_judge_check_duedate parseLineData,item,index,screenCode  ###
    err = nil
		tblnamechop = screenCode.split("_")[1].chop
		parent = {"starttime" => parseLineData[(tblnamechop+"_starttime")],"duedate" => parseLineData[(tblnamechop+"_duedate")]}
		nd = {"duration" => parseLineData["opeitm_duration"],"unitofduration" => parseLineData["opeitm_unitofduration"],"locas_id_shelfno" => 0 }	
		parseLineData,err =  proc_field_starttime(tblnamechop,parseLineData,parent,nd)
		###return parseLineData.symbolize_keys,err
		return parseLineData,err
	end
	
	def proc_judge_check_supplierprice parse_linedata,item,index,screenCode  ###M
		dupLineData = parse_linedata.dup
		err = nil
		# if dupLineData["purord_contractprice"] =~ /[A-Z]|[a-z]/  ###数字の時マスター単価
		# 	return dupLineData,err
		# end
		ex_date = nil
		case screenCode
		when /pursch/
			strpur = "pursch"
			stramtsym = "pursch_amt_sch"
			strqtysym = "pursch_qty_case"
			strtaxsym = "pursch_tax"
		when /purord/
			strpur = "purord"
			stramtsym = "purord_amt"
			strqtysym = "purord_qty_case"
			strtaxsym = "purord_tax"
		when /purinst/
			strpur = "purinst"
			stramtsym = "purinst_amt"
			strqtysym = "purinst_qty_case"
			strtaxsym = "purinst_tax"
		when /purdlv/
			strpur = "purdlv"
			stramtsym = "purdlv_amt"
			strqtysym = "purdlv_qty_case"
			strtaxsym = "purdlv_tax"
		when /puract/
			strpur = "puract"
			stramtsym = "puract_amt"
			strqtysym = "puract_qty_case"
			strtaxsym = "puract_tax"
		end	
		strcontractpricesym = "#{strpur}_contractprice"
		strmasterpricesym = "#{strpur}_masterprice"
		stropeitmsym = "#{strpur}_opeitm_id"
		strisudatesym = "#{strpur}_isuedate"
		strduedatesym = "#{strpur}_duedate"
		strpricesym = "#{strpur}_price"
		strtaxratesym = "#{strpur}_taxrate"
		strcrrsym = "#{strpur}_crr_id"
		strsuppliersym = "#{strpur}_supplier_id"
		strshpsql = ""
		case screenCode
		when /pursch|purord/
			case dupLineData[strcontractpricesym]
			when "1"
				ex_date = "expiredate >= to_date('#{dupLineData[strisudatesym]}','yyyy/mm/dd')
										 and opeitms_id = #{dupLineData[stropeitmsym]}	" 
			when "2","3"
				ex_date = "expiredate >= to_date('#{dupLineData[strduedatesym]}','yyyy/mm/dd')
											 and opeitms_id = #{dupLineData[stropeitmsym]}"
			when "A"
				ex_date = nil
			when "B"
				ex_date = nil
			else
				ex_date = nil
				dupLineData[strcontractpricesym] = parse_linedata[strcontractpricesym] = "C"
				dupLineData[strmasterpricesym] = dupLineData[strpricesym]  = dupLineData[stramtsym]  = 0
			end
		when /purdlv/ 
			ex_date = case dupLineData[strcontractpricesym] 
						when "1"
							"s.expiredate >= to_date('#{dupLineData["purdlv_depdate"]}','yyyy/mm/dd')
										 and s.opeitms_id = #{dupLineData[stropeitmsym]}"
						else
							nil
						end
		when /puract/ 
			ex_date = case dupLineData[strcontractpricesym] 
						when "2","3"
							"s.expiredate >= to_date('#{dupLineData["puract_rcptdate"]}','yyyy/mm/dd')
										 and s.opeitms_id = #{dupLineData[stropeitmsym]}"
						else
							nil
						end						
		end 
			
		if ex_date
			strsql = %Q&
						select s.* from supplierprices s #{strshpsql}
									where s.suppliers_id = #{dupLineData[strsuppliersym]}
									and s.maxqty >= #{dupLineData[strqtysym].to_i}
									and s.minqty < #{dupLineData[strqtysym].to_i}
									and #{ex_date}
									order by s.maxqty,s.expiredate limit 1
				&								
			price = ActiveRecord::Base.connection.select_one(strsql)	
			if price
				dupLineData[strpricesym] = dupLineData[strmasterpricesym] = price["price"]
				###dupLineData["pursch_contractprice"] = supplier["contractprice"]
				dupLineData[stramtsym] = dupLineData[strqtysym].to_f * price["price"]
				case parse_linedata["itm_taxflg"]
				when "0","1","9"
					base_date =  dupLineData[strduedatesym]
				when "A"
					base_date =   dupLineData[strisudatesym]
				else
					base_date =  dupLineData[strduedatesym]
				end
				strsql = %Q&
							select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
														and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
														order by expiredate limit 1
				&
				dupLineData[strtaxratesym] = ActiveRecord::Base.connection.select_value(strsql)
				dupLineData[strtaxratesym] ||= 0
				dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym] / 100)
				if dupLineData[strcrrsym]
					strsql = %Q&
							select decimal from crrs where id = #{dupLineData[strcrrsym]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case dupLineData["supplier_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						dupLineData[stramtsym] = dupLineData[stramtsym].floor(decimal.to_i )
						dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).floor(decimal.to_i )
					when "2"
						dupLineData[stramtsym] = dupLineData[stramtsym].round(decimal.to_i + 1)
						dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).round(decimal.to_i )
					when "3"
						dupLineData[stramtsym] = dupLineData[stramtsym].ceil(decimal.to_i )
						dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).ceil(decimal.to_i )
					end
				else
					###
				end
			else
				dupLineData[strcontractpricesym] = "C"
				dupLineData[strmasterpricesym] = dupLineData[strpricesym]  = dupLineData[stramtsym]  = 0
				dupLineData[strtaxsym] = dupLineData[strtaxratesym]  = 0
			end
		else
			###dupLineData[strmasterpricesym] =  dupLineData[strpricesym]  = 0
			dupLineData[stramtsym] = dupLineData[strqtysym].to_f * dupLineData[strpricesym].to_f 
			case dupLineData["itm_taxflg"]
			when "0","1","9"
				base_date =  dupLineData[strduedatesym]
			when "A"
				base_date =   dupLineData[strisudatesym]
			else
				base_date =  dupLineData[strduedatesym]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			dupLineData[strtaxratesym] = ActiveRecord::Base.connection.select_value(strsql)
			dupLineData[strtaxratesym] ||= 0
			dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100)
			if dupLineData[strcrrsym]
				strsql = %Q&
						select decimal from crrs where id = #{dupLineData[strcrrsym]}
				&
				decimal = ActiveRecord::Base.connection.select_value(strsql)
				case dupLineData["supplier_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
				when "1"
					dupLineData[stramtsym] = dupLineData[stramtsym].floor(decimal.to_i )
					dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).floor(decimal.to_i )
				when "2"
					dupLineData[stramtsym] = dupLineData[stramtsym].round(decimal.to_i + 1)
					dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).round(decimal.to_i )
				when "3"
					dupLineData[stramtsym] = dupLineData[stramtsym].ceil(decimal.to_i )
					dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).ceil(decimal.to_i )
				end
			else
				###
			end
		end
			parse_linedata[stramtsym] = dupLineData[stramtsym].to_s
			parse_linedata[strqtysym] = dupLineData[strqtysym].to_s
			parse_linedata[strtaxsym] = dupLineData[strtaxsym].to_s
			parse_linedata[strmasterpricesym] =	dupLineData[strmasterpricesym].to_s
			parse_linedata[strpricesym] =	dupLineData[strpricesym].to_s
			parse_linedata[strtaxratesym] = dupLineData[strtaxratesym].to_s
		return parse_linedata,err
	end


	def proc_judge_check_paidsupplierprice parse_linedata,item,index,screenCode  ###M
		dupLineData = parse_linedata.dup
		err = nil
		# if dupLineData["purord_contractprice"] =~ /[A-Z]|[a-z]/  ###数字の時マスター単価
		# 	return dupLineData,err
		# end
		err = false 
		ex_date = nil
		case screenCode
		when /shpsch/
			strpur = "shpsch"
			stramtsym = "shpsch_amt_sch"
			strqtysym = "shpsch_qty_sch"
			strduedatesym = "shpsch_depdate"
		when /shpord/
			strpur = "shpord"
			stramtsym = "shpord_amt"
			strqtysym = "shpord_qty"
			strduedatesym = "shpord_depdate"
		when /shpinst/
			strpur = "shpinst"
			stramtsym = "shpinst_amt"
			strqtysym = "shpinst_qty"
			strtaxsym = "shpinst_tax"
			strduedatesym = "shpinst_depdate"
		when /shpact/
			strpur = "shpact"
			stramtsym = "shpact_amt"
			strqtysym = "shpact_qty_stk"
			strduedatesym = "shpact_rcptdate"
		end	
		strcontractpricesym = "#{strpur}_contractprice"
		strmasterpricesym = "#{strpur}_masterprice"
		strisudatesym = "#{strpur}_isuedate"
		strpricesym = "#{strpur}_price"
		strtaxsym = "#{strpur}_tax"
		strtaxratesym = "#{strpur}_taxrate"
		strcrrsym = "#{strpur}_crr_id"
		strsuppliersym = "#{strpur}_supplier_id"
		strshpsql = ""
			strshpsql = %Q%inner join (select p.id from opeitms p
																			where p.itms_id = #{dupLineData["#{strpur}_itm_id"]}
																			and p.processseq = #{dupLineData["#{strpur}_processseq"]}
																			and p.shelfnos_id_opeitm = #{dupLineData["#{strpur}_shelfno_id_to"]}) ope
																on s.opeitms_id = ope.id%
			ex_date = case dupLineData[strcontractpricesym] 
						when "1"
							"s.expiredate >= to_date('#{dupLineData["#{strpur}_isudate"]}','yyyy/mm/dd')"
						when "2","3"
							if strpur == "shpact"
								"s.expiredate >= to_date('#{dupLineData["#{strpur}_rcptdate"]}','yyyy/mm/dd')"
							else
									nil
							end
						else
							nil
						end
						
		if ex_date
			strsql = %Q&
						select s.* from paidsupplierprices s #{strshpsql}
									inner join opeitms o on o.id = s.opeitms_id
									where s.suppliers_id = #{dupLineData[strsuppliersym]}
									and o.itms_id = #{dupLineData["#{strpur}_itm_id"]}
									and o.processseq = #{dupLineData["#{strpur}_processseq"]}
									and s.maxqty >= #{dupLineData[strqtysym]}
									and s.minqty < #{dupLineData[strqtysym]}
									and #{ex_date}
									order by s.expiredate limit 1
				&								
			price = ActiveRecord::Base.connection.select_one(strsql)	
			if price
				dupLineData[strpricesym] = dupLineData[strmasterpricesym] = price["price"].to_f
				###dupLineData["pursch_contractprice"] = supplier["contractprice"]
				dupLineData[stramtsym] = dupLineData[strqtysym].to_f * price["price"].to_f
				case dupLineData["itm_taxflg"]
				when "0","1","9"
					base_date =  dupLineData[strduedatesym]
				when "A"
					base_date =   dupLineData[strisudatesym]
				else
					base_date =  dupLineData[strduedatesym]
				end
				strsql = %Q&
							select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
														and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
														order by expiredate limit 1
				&
				dupLineData[strtaxratesym] = ActiveRecord::Base.connection.select_value(strsql)
				dupLineData[strtaxratesym] ||= 0
				dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100)
				if dupLineData[strcrrsym]
					strsql = %Q&
							select decimal from crrs where id = #{dupLineData[strcrrsym]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case dupLineData["supplier_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						dupLineData[stramtsym] = dupLineData[stramtsym].floor(decimal.to_i )
						dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).floor(decimal.to_i )
					when "2"
						dupLineData[stramtsym] = dupLineData[stramtsym].round(decimal.to_i + 1)
						dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).round(decimal.to_i )
					when "3"
						dupLineData[stramtsym] = dupLineData[stramtsym].ceil(decimal.to_i )
						dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).ceil(decimal.to_i )
					end
				else
					###
				end
			else
				dupLineData[strcontractpricesym] = "C"
				dupLineData[strmasterpricesym] = dupLineData[strpricesym]  = dupLineData[stramtsym]  = 0
				dupLineData[strtaxsym] = dupLineData[strtaxratesym]  = 0
				err = true
			end
		else
			###dupLineData[strmasterpricesym] =  dupLineData[strpricesym]  = 0
			dupLineData[stramtsym] = dupLineData[strqtysym].to_f * dupLineData[strpricesym].to_f 
			case dupLineData["itm_taxflg"]
			when "0","1","9"
				base_date =  dupLineData[strduedatesym]
			when "A"
				base_date =   dupLineData[strisudatesym]
			else
				base_date =  dupLineData[strduedatesym]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
													and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
													order by expiredate limit 1
			&
			dupLineData[strtaxratesym] = ActiveRecord::Base.connection.select_value(strsql)
			dupLineData[strtaxratesym] ||= 0
			dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100)
			if dupLineData[strcrrsym]
				strsql = %Q&
						select decimal from crrs where id = #{dupLineData[strcrrsym]}
				&
				decimal = ActiveRecord::Base.connection.select_value(strsql)
				case dupLineData["supplier_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
				when "1"
					dupLineData[stramtsym] = dupLineData[stramtsym].floor(decimal.to_i )
					dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).floor(decimal.to_i )
				when "2"
					dupLineData[stramtsym] = dupLineData[stramtsym].round(decimal.to_i + 1)
					dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).round(decimal.to_i )
				when "3"
					dupLineData[stramtsym] = dupLineData[stramtsym].ceil(decimal.to_i )
					dupLineData[strtaxsym] = (dupLineData[stramtsym] * dupLineData[strtaxratesym].to_f / 100).ceil(decimal.to_i )
				end
			else
				###
				err = true
			end
		end
			parse_linedata[stramtsym] = dupLineData[stramtsym].to_s
			parse_linedata[strqtysym] = dupLineData[strqtysym].to_s
			parse_linedata[strtaxsym] = dupLineData[strtaxsym].to_s
			parse_linedata[strmasterpricesym] =	dupLineData[strmasterpricesym].to_s
			parse_linedata[strpricesym] =	dupLineData[strpricesym].to_s
			parse_linedata[strtaxratesym] = dupLineData[strtaxratesym].to_s
		return parse_linedata,err
	end


	def proc_judge_check_custprice parse_linedata,item,index,screenCode  ###
		err = nil
		if parse_linedata["custsch_contractprice"] =~ /[A-Z]|[a-z]/  ###数字の時マスター単価
				return parse_linedata,err
		end
		dupLineData = parse_linedata.dup
		case screenCode
		when /custschs/
			strsql = %Q&
						select * from custprices 
									where custs_id = #{dupLineData["custsch_cust_id"]} and opeitms_id = #{dupLineData["custsch_opeitm_id"]}
									and crrs_id_custprice = #{dupLineData["custsch_crr_id"]}
									and maxqty >= #{dupLineData["custsch_qty_case"]}
									and minqty < #{dupLineData["custsch_qty_case"]}
									and #{case dupLineData["custsch_contractprice"]
											when "1"
												"expiredate >= to_date('#{dupLineData["custsch_isudate"]}','yyyy/mm/dd')" 
											when "2"
												"expiredate >= to_date('#{dupLineData["custsch_duedate"]}','yyyy/mm/dd')"
											when "3"
												"expiredate >= to_date('#{dupLineData["custsch_duedate"]}','yyyy/mm/dd')"
											else
												"expiredate >= to_date('#{dupLineData["custsch_isudate"]}','yyyy/mm/dd')"
											end											
											}
									order by maxqty,expiredate limit 1
			&
			str_price = "custsch_price"
			str_masterprice = "custsch_masterprice"
			str_amt = "custsch_amt_sch"
			str_qty_case = "custsch_qty_case"
			str_crr_id = "custsch_crr_id"
			str_duedate = "custsch_duedate"
			str_isudate = "custsch_isudate"
			str_taxrate = "custsch_taxrate"
			str_tax = "custsch_tax"
			str_contractprice = "custsch_contractprice"
		when /custords/
			strsql = %Q&
						select * from custprices 
									where custs_id = #{dupLineData["custord_cust_id"]} and opeitms_id = #{dupLineData["custord_opeitm_id"]}
									and crrs_id_custprice = #{dupLineData["custord_crr_id"]}
									and maxqty >= #{dupLineData["custord_qty_case"]}
									and minqty < #{dupLineData["custord_qty_case"]}
									and #{case dupLineData["custord_contractprice"]
											when "1"
												"expiredate >= to_date('#{dupLineData["custord_isudate"]}','yyyy/mm/dd')" 
											when "2"
												"expiredate >= to_date('#{dupLineData["custord_duedate"]}','yyyy/mm/dd')"
											when "3"
												"expiredate >= to_date('#{dupLineData["custord_duedate"]}','yyyy/mm/dd')"
											else
												"expiredate >= to_date('#{dupLineData["custord_isudate"]}','yyyy/mm/dd')"
											end											
											}
									order by maxqty,expiredate limit 1
			&
			str_price = "custord_price"
			str_masterprice = "custord_masterprice"
			str_amt = "custord_amt"
			str_qty_case = "custord_qty_case"
			str_crr_id = "custord_crr_id"
			str_duedate = "custord_duedate"
			str_isudate = "custord_isudate"
			str_taxrate = "custord_taxrate"
			str_tax = "custord_tax"
			str_contractprice = "custord_contractprice"
		when /custinsts/
				return parse_linedata,err
		when /custdlvs/
			if params[:custdlv_contractprice]  == "2"  ###出荷日ベース　
				strsql = %Q&
							select * from custprices 
										where custs_id = #{dupLineData["custdlv_cust_id"]} and opeitms_id = #{dupLineData["custdlv_opeitm_id"]}
										and crrs_id_custprice = #{dupLineData["custdlv_crr_id"]}
										and maxqty >= #{dupLineData["custdlv_qty_case"]}
										and minqty < #{dupLineData["custdlv_qty_case"]}
										and  expiredate >= to_date('#{dupLineData["custdlv_depdate"]}','yyyy/mm/dd')
										order by maxqty,expiredate limit 1
				&
			else
				return parse_linedata,err
			end
			str_price = "custdlv_price"
			str_masterprice = "custdlv_masterprice"
			str_amt = "custdlv_amt"
			str_qty_case = "custdlv_qty_case"
			str_crr_id = "custdlv_crr_id"
			str_duedate = "custdlv_depdate"
			str_isudate = "custdlv_isudate"
			str_taxrate = "custdlv_taxrate"
			str_tax = "custdlv_tax"
			str_contractprice = "custdlv_contractprice"
		when /custacts/
			if dupLineData["custact_contractprice"]  == "3"
				strsql = %Q&
					select * from custprices 
							where custs_id = #{dupLineData["custact_cust_id"]} and opeitms_id = #{dupLineData["custact_opeitm_id"]}
							and crrs_id_custprice = #{dupLineData["custact_crr_id"]}
							and maxqty >= #{dupLineData["custact_qty_case"]}
							and minqty < #{dupLineData["custact_qty_case"]}
							and  expiredate >= to_date('#{dupLineData["custact_depdate"]}','yyyy/mm/dd')
							order by maxqty,expiredate limit 1
					&
			else
				return parse_linedata,err
			end	
			str_price = "custact_price"
			str_masterprice = "custact_masterprice"
			str_amt = "custact_amt"
			str_qty_case = "custact_qty_case"
			str_crr_id = "custact_crr_id"
			str_duedate = "custact_rcptdate"
			str_isudate = "custact_isudate"
			str_taxrate = "custact_taxrate"
			str_tax = "custact_tax"
			str_contractprice = "custact_contractprice"
		end
		price = ActiveRecord::Base.connection.select_one(strsql)
		if price
				dupLineData[str_price] =  dupLineData[str_masterprice] = price["price"]
				dupLineData[str_amt] = parse_linedata[str_qty_case].to_f * price["price"]
				if dupLineData[str_crr_id]
          ###税率の取得
          case dupLineData["itm_taxflg"]
          when "0","1","9"
            base_date =  dupLineData[str_duedate]
          when "A"
            base_date =   dupLineData[str_isudate]
          else
            base_date =  dupLineData[str_duedate]
          end
          strsql = %Q&
              select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
                            and expiredate >= to_date('#{base_date}','yyyy/mm/dd')
                            order by expiredate limit 1
          &
          dupLineData[str_taxrate] = ActiveRecord::Base.connection.select_value(strsql)
          dupLineData[str_taxrate] ||= 0
          dupLineData[str_tax] = (dupLineData[str_amt].to_f * dupLineData[str_taxrate] / 100)
          ###通貨の小数点以下の桁数を取得
					strsql = %Q&
							select decimal from crrs where id = #{dupLineData[str_crr_id]}
					&
					decimal = ActiveRecord::Base.connection.select_value(strsql)
					case dupLineData["cust_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
					when "1"
						dupLineData[str_amt_sch] = dupLineData[str_amt].floor(decimal.to_i )
						dupLineData[str_tax] = (dupLineData[str_amt] * dupLineData[str_taxrate] / 100).floor(decimal.to_i )
					when "2"
						dupLineData[str_amt] = dupLineData[str_amt].round(decimal.to_i )
						dupLineData[str_tax] = (dupLineData[str_amt] * dupLineData[str_taxrate] / 100).round(decimal.to_i )
					when "3"
						dupLineData[str_amt] = dupLineData[str_amt].ceil(decimal.to_i )
						dupLineData[str_tax] = (dupLineData[str_amt] * dupLineData[str_taxrate] / 100).ceil(decimal.to_i )
					else
						dupLineData[str_tax] = (dupLineData[str_amt] * dupLineData[str_taxrate] / 100)
					end
				end
		else
				dupLineData[str_price] = dupLineData[str_masterprice] = dupLineData[str_tax] = dupLineData[str_taxrate] = 0
				dupLineData[str_amt] = 0
				parse_linedata[str_contractprice] = "C"  ###C:マスター単価無
		end
		parse_linedata[str_price] = dupLineData[str_price].to_s 
		parse_linedata[str_masterprice] = dupLineData[str_masterprice].to_s
		parse_linedata[str_amt] = dupLineData[str_amt].to_s
		parse_linedata[str_tax] = dupLineData[str_tax].to_s
		parse_linedata[str_taxrate] = dupLineData[str_taxrate].to_s
		return parse_linedata,err
	end

	def proc_judge_check_amt parse_linedata,item,index,screenCode  ###M
		parseLineData = parse_linedata.dup
		decimal = parseLineData["crr_decimal"].to_i 
		tblchop = screenCode.split("_")[1].chop
		err = nil
		case  screenCode 
		when /acts$|dlvs$/
			symqty = (tblchop + "_qty_stk")
			symamt = (tblchop + "_amt")
		when /schs$/ 
			symqty = (tblchop + "_qty_sch")
			symamt = (tblchop + "_amt_sch")
		else 
			symqty = (tblchop + "_qty")
			symamt = (tblchop + "_amt")
		end
		symprice = (tblchop + "_price")
		symtax = (tblchop + "_tax")
		symtaxrate = (tblchop + "_taxrate")
	 	parseLineData[symamt] = parseLineData[symqty].to_f * parseLineData[symprice].to_f
		case parseLineData["cust_amtround"]  ###1:切り捨て　2:四捨五入 3:切り上げ
		when "1"
		 parseLineData[symamt] = parseLineData[symamt].floor(decimal.to_i )
		 parseLineData[symtax] = (parseLineData[symamt] * parseLineData[symtaxrate].to_i / 100).floor(decimal.to_i )
		when "2"
		 parseLineData[symamt] = parseLineData[symamt].round(decimal.to_i )
		 parseLineData[symtax] = (parseLineData[symamt] * parseLineData[symtaxrate].to_i / 100).round(decimal.to_i )
		when "3"
		 parseLineData[symamt] = parseLineData[symamt].ceil(decimal.to_i )
		 parseLineData[symtax] = (parseLineData[symamt] * parseLineData[symtaxrate].to_i / 100).ceil(decimal.to_i )
		else
			parseLineData[symamt] = parseLineData[symamt].ceil(decimal.to_i )
			parseLineData[symtax] = (parseLineData[symamt] * parseLineData[symtaxrate].to_i / 100).ceil(decimal.to_i )
		end
		parse_linedata[symamt] = parseLineData[symamt]
		parse_linedata[symtax] = parseLineData[symtax]
		return parse_linedata,err
	end

	def proc_judge_check_contractprice parseLineData,item,index,screenCode  ###M   
    err = nil
    case screenCode
    when /purords/
      if parseLineData["purord_confirm"] == "1"
        if parseLineData["purprd_contractprice"]  == "C"  ###単価未決
						err =  "error price 1 --->  price not decide"
        end
      end
    when /custords/
      if parseLineData["purprd_contractprice"]  == "C"  ###単価未決
						err =  "error price 2 --->  price not decide"
      end
    when /puracts/
      if parseLineData["puract_contractprice"]  == "C" or parseLineData["puract_contractprice"]  == "Z"  ###仮単価
						err =  "error price 3 --->  price not decide"
      end
    when /custacts/
      if parseLineData["custact_contractprice"]  == "C" or parseLineData["custact_contractprice"]  == "Z"  ###仮単価
          err =  "error price 4 --->  price not decide"
      end
    end 
  end

	def proc_judge_check_taxrate parse_linedata,item,index,screenCode  ###MkInvoiveNoの時のみ
		dupLineData = parse_linedata.dup
		err = nil
		case screenCode
		when /puracts/  ###再度求める
			case dupLineData["itm_taxflg"]
			when "A"
				if dupLineData["puract_sno_purord"] != "" and !dupLineData["puract_sno_purord"].nil?
					strsql = %Q&
						select isudate from purords where sno = #{dupLineData["puract_sno_purord"]}
					&
					base_date =  ActiveRecord::Base.connection.select_value(strsql)
				else  ###purordsを纏めるとき同一taxrateであること
					strsql = %Q&
						select * from linktbls where tblid = #{dupLineData["puract_id"]} and tblname = 'puracts'
					&
					src =  ActiveRecord::Base.connection.select_one(strsql)
					case src["srctblname"]
					when "purords"
						strsql = %Q&
							select isudate from purords where id = #{src["srctblid"]}
						&
						base_date =  ActiveRecord::Base.connection.select_value(strsql)
					when "purinsts"  ### taxflが異なるものを纏めないこと
						strsql = %Q&
							select isudate from purords ord
										inner join linktbls link on link.srctblid = ord.idc
								where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{src["tblid"]}
						&
						base_date =  ActiveRecord::Base.connection.select_value(strsql)
					when "purreplyinputs"
						strsql = %Q&
							select * from linktbls where tblid = #{src["srctblid"]} and tblname = 'purreplyinputs'
						&
						reply =  ActiveRecord::Base.connection.select_one(strsql)
						case reply["srctblname"]
						when "purords"
							strsql = %Q&
								select isudate from purords where id = #{reply["srctblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						when "purinsts"
							strsql = %Q&
								select isudate from purords ord
											inner join linktbls link on link.srctblid = ord.id
									where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{reply["tblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						end
					when "purdlvs"  ###業者出荷。業者からの出荷情報。data受信を想定。
						strsql = %Q&
							select * from linktbls where tblid = #{src["srctblid"]} and tblname = 'purdlvs'
						&
						dlv =  ActiveRecord::Base.connection.select_one(strsql)
						case dlv["srctblname"]
						when "purords"
							strsql = %Q&
								select isudate from purords where id = #{dlv["srctblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						when "purinsts"
							strsql = %Q&
								select isudate from purords ord
											inner join linktbls link on link.srctblid = ord.id
									where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{dlv["tblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						when "purreplyinputs"
							strsql = %Q&
								select * from linktbls where tblid = #{dlv["srctblid"]} and tblname = 'purreplyinputs'
							&
							reply =  ActiveRecord::Base.connection.select_one(strsql)
							case reply["srctblname"]
							when "purords"
								strsql = %Q&
									select isudate from purords where id = #{reply["srctblid"]}
								&
								base_date =  ActiveRecord::Base.connection.select_value(strsql)
							when "purinsts"
								strsql = %Q&
									select isudate from purords ord
												inner join linktbls link on link.srctblid = ord.id
										where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{reply["tblid"]}
								&
								base_date =  ActiveRecord::Base.connection.select_value(strsql)
							end
						end
					end
				end
			when "0","1","9"
				base_date =  dupLineData["puract_rcptdate"]
			else
				raise"taxflg error B paymants_id : #{dupLineData["paymets_id"]} LINE:#{__LINE__} "
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			dupLineData["puract_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /purrets/
			strsql = %Q&
				select taxrate from puracts where sno_puract = #{dupLineData["purret_sno_puract"]}
			&
			dupLineData["puract_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /shpschs/  ###shpacts以外は求めて表示するだけ
			base_date =   dupLineData["shpsch_isudate"]
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			dupLineData["shpsch_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /shpacts/  ###shpacts以外は求めて表示するだけ
			base_date =   dupLineData["shpact_rcptdate"]
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			dupLineData["shpsch_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /custacts/ ###再度求める
			case dupLineData["itm_taxflg"]  #itms[0:非課税・不課税,1:消費税,9:低減税率,A::請負工事・指定役務]
			when "A"
				if dupLineData["custact_sno_custord"] != "" and !dupLineData["custact_sno_custord"].nil?
					strsql = %Q&
						select isudate from custords where sno = #{dupLineData["custact_sno_custord"]}
					&
					base_date =  ActiveRecord::Base.connection.select_value(strsql)
				else  ###purordsを纏めるとき同一taxrateであること
					strsql = %Q&
						select * from linkcusts where tblid = #{dupLineData["custact_id"]} and tblname = 'custacts'
					&
					src =  ActiveRecord::Base.connection.select_one(strsql)
					case src["srctblname"]
					when "custords"
						strsql = %Q&
							select isudate from custords where id = #{src["srctblid"]}
						&
						base_date =  ActiveRecord::Base.connection.select_value(strsql)
					when "custinsts"  ### taxflが異なるものを纏めないこと
						strsql = %Q&
							select isudate from custords ord
										inner join linkcusts link on link.srctblid = ord.id
								where link.srctblname = 'custords' and link.tblname = 'custinsts' and tblid = #{src["tblid"]}
						&
						base_date =  ActiveRecord::Base.connection.select_value(strsql)
					when "custdlvs"
						strsql = %Q&
							select * from linkcusts where tblid = #{src["srctblid"]} and tblname = 'custdlvs'
						&
						dlv =  ActiveRecord::Base.connection.select_one(strsql)
						case dlv["srctblname"]
						when "custords"
							strsql = %Q&
								select isudate from custords where id = #{dlv["srctblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						when "custinsts"
							strsql = %Q&
								select isudate from custords ord
											inner join linktbls link on link.srctblid = ord.id
									where link.srctblname = 'purords' and link.tblname = 'purinsts' and tblid = #{dlv["tblid"]}
							&
							base_date =  ActiveRecord::Base.connection.select_value(strsql)
						end
					end
				end
			when "0","1","9"
				# strsql = %Q&
				# 	select saledate from custacts where  id = #{dupLineData["custact_id"]}
				# &
				base_date =   dupLineData["custact_saledate"]
			else
				raise"taxflg error C 1 paymants_id : #{dupLineData["paymets_id"]} LINE:#{__LINE__} "
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			dupLineData["custact_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)

		when /custrets/
			strsql = %Q&
				select taxrate from custacts where sno_puract = #{dupLineData["custret_sno_custact"]}
			&
			dupLineData["custact_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /custords/
			case dupLineData["itm_taxflg"]
			when "A"
				base_date =  dupLineData["custord_duedate"]
      when "0","1","9"
        base_date =  dupLineData["custord_isudate"]
			else
				base_date =  dupLineData["custord_isudate"]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			dupLineData["custord_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		when /custschs/
			case dupLineData["itm_taxflg"]
			when "A"
				base_date =  dupLineData["custsch_duedate"]
			else
				base_date =  dupLineData["custsch_isudate"]
			end
			strsql = %Q&
						select taxrate from taxtbls where taxflg = '#{dupLineData["itm_taxflg"]}' 
													and expiredate >= cast('#{base_date}' as date)
													order by expiredate limit 1
			&
			dupLineData["custsch_taxrate"] = ActiveRecord::Base.connection.select_value(strsql)
		end
		strTaxRate = screenCode.split("_")[1].chop  + "_taxrate"
		dupLineData[strTaxRate] = dupLineData[strTaxRate].to_s
		return dupLineData,err
	end

	def proc_judge_check_mkprdpurord_code(parseLineData,item,index,screenCode)
    err = nil
		if parseLineData[item] == "dummy" or parseLineData[item] == ""
			return parseLineData, nil
		end
		###
		case item
		when /_org$/
			if parseLineData["mkprdpurord_orgtblname"] !~ /prd|pur|cust/
				parseLineData[item.sub("code","name")] = " not select orgtblname "
				err = "#{parseLineData[item]}  not select orgtable "
				return parseLineData,err
			end
		when /_pare$/
			if parseLineData["mkprdpurord_paretblname"] !~ /prd|pur/
				parseLineData[item.sub("code","name")]  = " not select paretblname"
				err = "#{parseLineData[item]}  not select parent table "
				return parseLineData,err
			end
		end
		case item
		when /loca/
			strsql = %Q&
						select loca_name from r_locas where loca_code = '#{parseLineData[item]}'
						&
		when /itm/
			strsql = %Q&
						select itm_name from r_itms where itm_code = '#{parseLineData[item]}'
						&
		when /shelfno/
			strsql = %Q&
						select shelfno_name from r_chrgs where shelfno_code = '#{parseLineData[item]}'
						&
		when /chrg/
			strsql = %Q&
						select person_code_chrg from r_chrgs where persomn_code_chrg = '#{parseLineData[item]}'
						&
		when /sno/
			strsql = %Q&
						select sno from #{parseLineData["mkprdpurord_paretblname"]} where sno = '#{parseLineData[item]}'
						&
		end
		codeToName = ActiveRecord::Base.connection.select_value(strsql)
		if codeToName
			parseLineData[item.sub("code","name")] = codeToName
			err = nil
		else
			parseLineData[item.sub("code","name")] = "#{parseLineData[item]}  not found"
			err = " #{item}:#{parseLineData[item]}  not found"
		end
				
		return parseLineData,err
	end

	def proc_judge_check_ratejson(parseLineData,item,index,screenCode)
			err = ""
			begin
    			# 1. パース処理を試みる
				ratejsons = JSON.parse(parseLineData[item])
				termofs = parseLineData[item.sub("ratejson","termof")].split(",")
				keystr = "rate,duration,denomination,day"
				ratevalue = 0
				###[{"rate":100,"duration":3,"denomination":"deposit","day":10}]
				if ratejsons.class.to_s == "Array"
					if ratejsons.length ==  termofs.length
							ratejsons.each do |rateary|
								if rateary.class.to_s == "Array" 
										rateary.each do |ratejson|
				          		if ratejson.class.to_s  == "Hash"
													ratejson.each do |k,v|
														case k
															when "rate"
																if v.to_i == 100
																	keystr = keystr.sub("rate,","")
																	ratevalue += v.to_i
																else
																	err =  " rate must be 100"	
																end
															when "duration"
																if v.class.to_s == "Integer"
																	keystr = keystr.sub("duration,","")
																else
																	err =  " duration must be Integer"	
																end
															when "denomination"
																keystr = keystr.sub("denomination,","")
															when "day"
																if v.class.to_s == "Integer" and v.to_i > 0 and v.to_i <= 31
																	keystr = keystr.gsub("day","")
																else
																	err =  " day must be Integer"	
																end
															when "+day"
																if v.class.to_s == "Integer" and v.to_i >= 0 
																	keystr = keystr.gsub("day","")
																else
																	err =  " day must be Integer"	
																end
															else		
																err =  " key must be rate or duration or denomination or day"			
														end
													end
											else		
													err = " format error "
											end
										end
								else		
										err = " format error "
								end
							end	
					else
						err = " termof.size !=  ratejsons.size"
					end	
				else		
					err = " format error "
				end
			rescue JSON::ParserError => e
    			# 2. JSON::ParserErrorが発生した場合の処理
    			err =  " JSONパースエラーが発生しました: #{e.message}"
    			# エラーが発生した場合は nil や空のハッシュなどを返すことが多い
    
  			rescue TypeError => e
    			# 3. JSON::parseは文字列を期待するため、nilや数字などが渡された場合の処理
    			err = "⚠️  JSON::parseは文字列を期待: #{e.message}"

  			end	
				if err == ""
					if 	keystr != ""		
							err = "MISSING #{keystr}"				
					end
				end
		return parseLineData,err
	end

	def proc_judge_check_seqnoOfTblfields(parseLineData,item,index,screenCode)
    err = nil
		case screenCode 
		when /tblfields/
			case parseLineData["pobject_code_tbl"]
			when /ords$|schs$/   ###tranganntsからxxxschs,mkprdpurordsからxxxords作成時利用
				case parseLineData["pobject_code_fld"]
				  when /starttime/ 
					  strsql = %Q&
							select tblfield_seqno from r_tblfields where pobject_code_tbl = '#{parseLineData["pobject_code_tbl"]}'
														and pobject_code_fld = 'duedate' 
					  &
					  duedate_seqno = ActiveRecord::Base.connection.select_value(strsql)
					  if duedate_seqno
						  if duedate_seqno < parseLineData["tblfield_seqno"].to_i
							  return parseLineData, nil
						  else
							  err = "  seqno of starttime > seqno of duedate "
							  return parseLineData, nil
						  end
					  end
				  when /duedate/ 
					  strsql = %Q&
							select tblfield_seqno from r_tblfields where pobject_code_tbl = '#{parseLineData["pobject_code_tbl"]}'
														and pobject_code_fld = 'starttime' 
					    &
					  starttime_seqno = ActiveRecord::Base.connection.select_value(strsql)
					  if starttime_seqno
						  if starttime_seqno < parseLineData["tblfield_seqno"].to_i
							  err = "  seqno of starttime > seqno of duedate "
							  return parseLineData,err 
						  else
							  return parseLineData, nil						
						  end
					  end
				    ###when /qty/
					  ###
					  ##  coding missing
					  ###
		    else
			    return parseLineData, nil 
				end
      else
        return parseLineData, nil
			end
		else
			return parseLineData, nil
		end
    return parseLineData, nil
	end
	def proc_judge_check_screenfield_selection(parseLineData,item,index,screenCode)
									Rails.logger.debug(%Q%class:#{self},line:#{__LINE__},parseLineData:#{parseLineData}}%)
			if parseLineData["screenfield_selection"] == "1"
    			return parseLineData, nil
			else
				if parseLineData["pobject_code_sfd"] =~ /^#{parseLineData["pobject_code_scr"].split("_")[1].chop}/
    					return parseLineData, "table field must be selected"
				else
    					return parseLineData, nil
				end
			end
				
	end
	###
	#
	### prd,pur ・・・schs,ords,insts,acts,retsのレコード作成　	
	def proc_schs_fields_making nd,parent,command_x  ###xxxschsの作成のみ
		err = false
		qty_require = 0
		nd["packqty"] =  if nd["packqty"] == 0 and  nd["packqty"].nil?
									1
								else
									nd["packqty"]
								end
		nd["consumunitqty"] = 1

		tblnamechop = command_x["sio_viewname"].split("_")[1].chop
		command_x["sio_code"] =  command_x["sio_viewname"] 

		strsql =  %Q%select pobject_code_fld from r_tblfields where tblfield_expiredate > current_date and 
						pobject_code_tbl = '#{command_x["sio_code"].split("_")[1]}'
						order by tblfield_seqno
		%
		fields = ActiveRecord::Base.connection.select_all(strsql)
		fields.each do |fd|  ###tblfield_seqnoの順に処理される。tblfield_seqno順に処理するためcommand_xは利用できない。
			###lotnoはpur,prd項目ではないのでここにはない。
			next if !command_x[tblnamechop + "_" + fd["pobject_code_fld"]].nil? and command_x[tblnamechop + "_" + fd["pobject_code_fld"]] != ""
			case fd["pobject_code_fld"]
			when "id"  ###追加または更新の判断
				command_x = field_tblid(tblnamechop,command_x,nd,parent)
			# when "confirm"
			# 	command_x = field_confirm(tblnamechop,command_x,nd,parent)
			when "isudate"
				if command_x ["sio_classname"] =~ /_add_/
					command_x = field_isudate(tblnamechop,command_x,nd) 
				end
			when "opeitms_id"
				command_x = field_opeitms_id(tblnamechop,command_x,nd)
			when "starttime"  ###稼働日計算  seqno.starttime > seqno.duedate > seqno.opeitms_id
				command_x = proc_field_starttime(tblnamechop,command_x,parent,nd)  ###qty_schで計算でする為
			when "depdate"  ###稼働日計算  seqno.starttime > seqno.duedate   ##shpxxxはmold,ITool以外は作成しない
				case tblnamechop
				when "shpest"
					command_x = proc_field_starttime(tblnamechop,command_x,parent,nd)  ###qty_schで計算でする為
				else
				end
			when "shelfnos_id" 
				command_x = field_shelfnos_id(tblnamechop,command_x,nd)
			when "shelfnos_id_to"
				command_x = field_shelfnos_id_to(tblnamechop,command_x,nd)
			when "chrgs_id"
				command_x = field_chrgs_id(tblnamechop,command_x,nd) 
			when "fcoperators_id"
				command_x = proc_field_fcoperators_id(tblnamechop,command_x,parent,nd) 
			when "duedate"  ###稼働日計算
				command_x = proc_field_duedate(tblnamechop,command_x,parent,nd)
			when "endtime"  
				###command_x = field_endtime(tblnamechop,command_x,nd,parent)
			when "toduedate"  ###稼働日計算
				command_x = field_toduedate(tblnamechop,command_x,parent,nd)
			when "facilities_id"  
				command_x = proc_field_facilities_id(tblnamechop,command_x,parent,nd)
			when "qty_sch"   ### 
				command_x,qty_require = field_qty_sch(tblnamechop,command_x,parent,nd)
			### tblfield_seqnoは qty,duedateより大きいと	
			when "price"  ###保留 amt tax  itm_code_client crrs_idを含む
				command_x = field_price_amt_tax_contractprice(tblnamechop,command_x) 
			# when "itm_code_client"  ###保留 amt tax  を含む
			# 	command_x = field_itm_code_client(tblnamechop,command_x,nd,parent) 
			when "gno" ###画面の時用にror_blkctl.create_src_tblでもsetしてる
				command_x["#{tblnamechop}_gno"]  = proc_field_gno(tblnamechop,command_x["id"])
			when "sno"  ###tblfield_seqnoはidの後であること。###画面の時用にror_blkctl.create_src_tblでもsetしてる
				command_x["#{tblnamechop}_sno"]  = proc_field_sno(tblnamechop,command_x["#{tblnamechop}_isudate"] ,command_x["id"])
			when "cno"  ###画面の時用にror_blkctl.crete_src_tblでもsetしてる
			when "prjnos_id"
				command_x = field_prjnos_id(tblnamechop,command_x,parent,nd)
			when "expiredate"
				command_x = field_expiredate(tblnamechop,command_x,parent,nd)
			when "tax"
				### field_price_amt_tax_contractprice
			end	
		end		
		return command_x,qty_require,err
	end	 

	def field_tblid tblnamechop,command_x,nd,parent
		if command_x["id"] == "" or  command_x["id"].nil?
			command_x["sio_classname"] = "_add_grid_linedata"
			command_x["id"] =  ArelCtl.proc_get_nextval("#{tblnamechop}s_seq")
	 	else         
			command_x["sio_classname"] = "_edit_update_grid_linedata"
	 	end   
		command_x["#{tblnamechop}_id"] = command_x["id"]
		return command_x
	end	

	# def field_confirm tblnamechop,command_x,nd,parent
	# 	command_x["#{tblnamechop}_confirm"] = false if command_x["#{tblnamechop}_confirm"].nil? or  command_x["#{tblnamechop}_confirm"] == ""
	# 	return command_x
	# end	

	def field_opeitms_id tblnamechop,command_x,nd
		key = tblnamechop + "_opeitm_id" 
		command_x[key] = nd["opeitms_id"]  ###  
    
		command_x["opeitm_processseq"] = nd["processseq"]
    	command_x["opeitm_priority"] = nd["priority"]   
    	command_x["opeitm_itm_id"] = nd["itms_id"]
    	command_x["opeitm_unitofduration"] = nd["unitofduration"]

		case  tblnamechop 
		 		when /^pur/
		 			command_x["itm_taxflg"] = nd["taxflg"]
          strsql = %Q&select id,contractprice from suppliers where  locas_id_supplier = #{nd["locas_id"]}&
		 			supplier =  ActiveRecord::Base.connection.select_one(strsql)
		 			command_x["pursch_supplier_id"] =  supplier["id"]
		 			command_x["pursch_contractprice"] =  supplier["contractprice"]
        when /^prd/
          ### prdschsにはworkplaces_idはない
		end
		return command_x
	end

	def field_locas_id_to tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_loca_id_to"] = nd["locas_id_to"] ##
		return command_x
	end 

	def field_shelfnos_id tblnamechop,command_x,nd
	 	command_x["#{tblnamechop}_shelfno_id"] = nd["shelfnos_id"] ##
    command_x["shelfno_loca_id_shelfno"] = nd["locas_id"] ##
    return command_x
	end

	def field_shelfnos_id_to tblnamechop,command_x,nd
		command_x["#{tblnamechop}_shelfno_id_to"] = nd["shelfnos_id_to"] ##
		command_x["shelfno_loca_id_shelfno_to"] = nd["locas_id_to"] ##
		return command_x
	end 


	def field_processseq_pare tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_processseq_pare"] = parent["processseq"] 
		return command_x
	end	

	def field_isudate tblnamechop,command_x,nd
		if command_x["#{tblnamechop}_isudate"].nil? or command_x["#{tblnamechop}_isudate"] == ""
			command_x["#{tblnamechop}_isudate"] = Time.now.to_s 
		end
		return command_x
	end	 
  
	###command_x["shelfno_loca_id_shelfno_to"]  :when /^prd|^shp|^dym|^run/
	###command_x["shelfno_loca_id_shelfno"]  :when /^prd/
	###command_x["#{tblnamechop}_cust_id"]      :when /^cust/
	###command_x["#{tblnamechop}_supplier_id"]  :when /^pur/
	###command_x["#{tblnamechop}_facilitie_id"] :when /^dvs/
	###command_x["#{tblnamechop}_fcoperators_id"]:when /^erc/
	### parent = {"starttime" => ,"unitofduration" => ,"duedate" }
	def proc_field_duedate tblnamechop,command_x,parent,nd
    	message = ""
		case tblnamechop
		  when /^pur|^prd|^dymsch|^cust|^con|^run/
        	if parent["shelfnos_id"].to_i  == command_x["#{tblnamechop}_shelfno_id_to"].to_i
          		if parent["unitofduration"] == nd["unitofduration"]
            		if parent["unitofduration"] == "Day "
              			pstarttime = parent["starttime"].to_date
              			case tblnamechop
                			when /^prd|^shp|^dym|^run|^con/
                    			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno_to"])
                			when /^cust/
                    			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
                			when /^pur/
                    			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
              			end
            		else
              			pstarttime = parent["starttime"].to_time  ###3600:1時間
              			case tblnamechop
                			when /^prd|^shp|^dym|^run|^con/
                  				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["shelfno_loca_id_shelfno_to"])
                			when /^cust/
                  				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["#{tblnamechop}_cust_id"])
                			when /^pur/
                  				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["#{tblnamechop}_supplier_id"])
              			end
            		end
          		else
            		pstarttime = parent["starttime"].to_time
            		if  nd["unitofduration"] == "Hour"
            		 		case tblnamechop
              	 			when /^prd|^shp|^dym|^run|^con/
                   			duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno_to"])
              	 			when /^cust/
                     		duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
              	 			when /^pur/
                   			duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
            		 		end
								else
            		 		case tblnamechop
              	 			when /^prd|^shp|^dym|^run|^con/
                   			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno_to"])
              	 			when /^cust/
                     		duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
              	 			when /^pur/
                   			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
											else
												raise " error class:#{self} ,line:#{__LINE__},tblnamechop:#{tblnamechop} not define"
            		 		end
								end
            		# if  nd["unitofduration"] == "Hour"
                		case tblnamechop
                  			when /^dym|^shp|^run|^con/
                    			strsql = %Q&select effectivetime from hcalendars where locas_id = #{command_x["shelfno_loca_id_shelfno_to"]}&
                    			effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  			when /^prd|^con/
                    			strsql = %Q&select effectivetime from hcalendars where locas_id =(
                                        select locas_id_calendar from workplaces where locas_id_workplace = #{command_x["shelfno_loca_id_shelfno"]})&
                    			effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  			when /^cust/
                    			strsql = %Q&select effectivetime from hcalendars where locas_id = (
                                        select locas_id_cust from custs where id = #{command_x["#{tblnamechop}_cust_id"]})&
                    			effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  			when /^pur/
                    			strsql = %Q&select effectivetime from hcalendars where locas_id = (
                                        select locas_id_calendar from suppliers where id = #{command_x["#{tblnamechop}_supplier_id"]})&
                    			effectivetime = ActiveRecord::Base.connection.select_value(strsql)
											else
												raise " error class:#{self} ,line:#{__LINE__},tblnamechop:#{tblnamechop} not define"
                		end
                		if effectivetime.nil?
                   			effectivetime = ActiveRecord::Base.connection.select_value(%Q&select effectivetime from hcalendars where locas_id = 0&)
                		end
                		hhmm = effectivetime.split(",")[-1].split(/-|~/)[0] + ":" + effectivetime.split(",")[-1].split(/-|~/)[1]
                		duedate = (duedate.strftime("%Y-%m-%d") + " " + hhmm).to_time
            		end
          		# end
        	else
          		if nd["locas_id_pare"] == command_x["shelfno_loca_id_shelfno_to"]
            		if parent["unitofduration"] == nd["unitofduration"]
              			# if parent["unitofduration"] == "Day "
                		# 	pstarttime = parent["starttime"].to_date
                		# 	case tblnamechop
                  	# 			when /^prd|^shp|^dym|^run/
                    # 				duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno_to"])
                  	# 			when /^cust/
                    # 				duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
                  	# 			when /^pur/
                    # 				duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
                		# 	end
              			# else
                			pstarttime = parent["starttime"].to_time
                			case tblnamechop
                  				when /^prd|^shp|^dym|^con/
                    				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["shelfno_loca_id_shelfno_to"])
                  				when /^cust/
                    				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["#{tblnamechop}_cust_id"])
                  				when /^pur/
                    				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,3600,"-",command_x["#{tblnamechop}_supplier_id"])
                			end     
              			# end
            		else
              			pstarttime = parent["starttime"].to_date
              			if  nd["unitofduration"] == "Hour"
                  			case tblnamechop
                  				when /^shp|^dym|^run/
                    				strsql = %Q&select effectivetime from hcalendars where locas_id = #{command_x["shelfno_loca_id_shelfno_to"]}&
                    				effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  				when /^prd|^con/
                    				strsql = %Q&select effectivetime from hcalendars where locas_id =(
                                        			select locas_id_calendar from workplaces where locas_id_workplace = #{command_x["shelfno_loca_id_shelfno"]})&
                    				effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  				when /^cust/
                    				strsql = %Q&select effectivetime from hcalendars where locas_id = (
                                        		select locas_id_cust from custs where id = #{command_x["#{tblnamechop}_cust_id"]})&
                    				effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  				when /^pur/
                    				strsql = %Q&select effectivetime from hcalendars where locas_id = (
                                    			    select locas_id_calendar from suppliers where id = #{command_x["#{tblnamechop}_supplier_id"]})&
                    				effectivetime = ActiveRecord::Base.connection.select_value(strsql)
                  			end
                  			if effectivetime.nil?
                     			effectivetime = ActiveRecord::Base.connection.select_value(%Q&select effectivetime from hcalendars where locas_id = 0&)
                  			end
                  			hhmm = effectivetime.split(",")[-1].split(/-|~/)[0] + ":" + effectivetime.split(",")[-1].split(/~|-/)[1]
                  			duedate = (pstarttime.strftime("%Y-%m-%d") + " " + hhmm).to_time
               			end
            		end
          		else
            		strsql = %Q&select * from transports where locas_id_fm_transport = #{command_x["shelfno_loca_id_shelfno_to"]} 
                                            and  locas_id_to_transport = #{nd["locas_id_pare"]}  
                                            and expiredate > current_date
                                            order by priority desc &
            		duration = ActiveRecord::Base.connection.select_one(strsql)
            		if duration
              			if duration["unitofduration"] == "Day " and duration["duration"].to_f == duration["duration"].to_i
                			pstarttime = parent["starttime"].to_date
                			case tblnamechop
                  				when /^prd|^shp|^dym|^run|^con/
                    				duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,duration["duration"].to_i,"-",command_x["shelfno_loca_id_shelfno"])
                  				when /^cust/
                    				duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,duration["duration"].to_i,"-",command_x["#{tblnamechop}_cust_id"])
                  				when /^pur/
                    				duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,duration["duration"].to_i,"-",command_x["#{tblnamechop}_supplier_id"])
                			end
              			else
                			pstarttime = parent["starttime"].to_time
                			duration = duration["duration"].to_f * Constants::Whr * 3600
                			case tblnamechop
                  				when /^prd|^shp|^dym|^con/
                    				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["shelfno_loca_id_shelfno"])
                  				when /^cust/
                    				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["#{tblnamechop}_cust_id"])
                  				when /^pur/
                    				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["#{tblnamechop}_supplier_id"]) 
                			end
              			end
            		else  ###場所違いでtransportsが設定されていない時
              			pstarttime = parent["starttime"].to_date
              			case tblnamechop
                			when /^prd|^shp|^dym|^run|^con/
                    			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["shelfno_loca_id_shelfno"])
                			when /^cust/
                      			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_cust_id"])
                			when /^pur/
                    			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,1,"-",command_x["#{tblnamechop}_supplier_id"])
              			end
            		end
          		end
        	end
		  when /^dvs|^shp/
        	if nd["postprocessinglt"].to_f  > 0
          		if nd["unitofduration"] == "Day " and nd["postprocessinglt"].to_f == nd["postprocessinglt"].to_i
              		pduedate = parent["duedate"].to_date
              		case tblnamechop
                		when /^shp/
                  			duedate,message = proc_calculate_working_day(tblnamechop,pduedate,tduration,"+",command_x["shelfno_loca_id_shelfno_to"])
                		when /^dvs/
                  			duedate,message = proc_calculate_working_day(tblnamechop,pduedate,tduration,"+",command_x["#{tblnamechop}_facilitie_id"]) 
              		end
          		else
            		pduedate = parent["duedate"].to_time
            		if nd["unitofduration"] == "Day "
              			tduration = (nd["postprocessinglt"]).to_f * Constants::Whr * 3600
            		else  
              			tduration = (nd["postprocessinglt"]).to_f * 3600
            		end
            	case tblnamechop
              		when /^shp/
                		duedate,message = proc_calculate_working_time(tblnamechop,pduedate,tduration,"+",command_x["shelfno_loca_id_shelfno_to"])
              		when /^dvs/
                		duedate,message = proc_calculate_working_time(tblnamechop,pduedate,tduration,"+",command_x["#{tblnamechop}_facilitie_id"]) 
            		end
          		end
        	else 
          		if nd["unitofduration"] == "Day "
            		duedate = parent["duedate"].to_date
          		else
            		duedate = parent["duedate"].to_time
          		end
        	end
		  when /^erc/
			  case command_x["#{tblnamechop}_processname"]   ###
			    when "postprocess"
            		if nd["unitofduration"] == "Day " and nd["postprocessinglt"].to_f == nd["postprocessinglt"].to_i
              			pstarttime = parent["duedate"].to_date
              			duedate,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["postprocessinglt"]).to_i,"+",command_x["#{tblnamechop}_fcoperators_id"])
            		else
              			pstarttime = parent["duedate"].to_time
              			if nd["unitofduration"] == "Day "
                			tduration = (nd["postprocessinglt"]).to_f * Constants::Whr * 3600
              			else  
                			tduration = (nd["postprocessinglt"]).to_f * 3600
              			end
              				duedate,message = proc_calculate_working_time(tblnamechop,pstarttime,tduration,"+",command_x["#{tblnamechop}_fcoperator_id"])
            		end
			    when "require"
            		if nd["unitofduration"] == "Day " and nd["postprocessinglt"].to_f == nd["postprocessinglt"].to_i
              			duedate = parent["duedate"].to_date
            		else
              			duedate = parent["duedate"].to_time
            		end
			    when "changeover"
            		if nd["unitofduration"] == "Day " and nd["postprocessinglt"].to_f == nd["postprocessinglt"].to_i
              			duedate = parent["starttime"].to_date
            		else
              			duedate = parent["starttime"].to_time
            		end
        	 end
    	else
			  raise" error class:#{self} ,line:#{__LINE__},tblname error:#{tblnamechop}s,command_x:#{command_x},nd:#{nd} "
		end
		command_x[(tblnamechop+"_duedate")]  = duedate.strftime("%Y-%m-%d %H:%M:%S")
		command_x[(tblnamechop+"_remark")]  = message
		return command_x
	end

	def field_endtime tblnamechop,command_x,nd,parent
		# endtime = parent["starttime"].to_time - 24*3600  ###稼働日
		# command_x["#{tblnamechop}_endtime"] = endtime.strftime("%Y-%m-%d %H:%M:%S")
		# return command_x
	end

	
	def field_toduedate tblnamechop,command_x,parent,nd  ###先行納品可能納期
		command_x["#{tblnamechop}_toduedate"] = command_x["#{tblnamechop}_toduedate"] = command_x["#{tblnamechop}_duedate"]
		return command_x
	end

	def proc_field_facilities_id tblnamechop,command_x,parent,nd
		strsql = %Q& select id,chrgs_id_facilitie from facilities  where itms_id = #{nd["itms_id"]}&
		facilitie = ActiveRecord::Base.connection.select_one(strsql)
		if facilitie
			command_x["#{tblnamechop}_facilitie_id"] = facilitie["id"]
			command_x["#{tblnamechop}_chrg_id"] = facilitie["chrgs_id_facilitie"]
		else
			raise "error  class:#{self} ,line:#{__LINE__} \n command_x:#{command_x} \n nd:#{nd} "
		end
		return command_x
	end

	def proc_field_starttime tblnamechop,command_x,parent,nd  ###parentはdvsschs,ercschsで使用
		message = ""
    if nd["unitofduration"] ==  "Hour"
      		duration = (nd["duration"]||=1) * 3600
      		hourFlg = true 
    else
      		if (nd["duration"]||=1).to_i != (nd["duration"]||=1).to_f  ###小数点がある場合は時間である。
        		hourFlg = true 
        		duration = (nd["duration"]||=1) * Constants::Whr * 3600  ###Whr 壱日の労働時間
      		else
        		hourFlg = false
        		duration = ((nd["duration"]||=1).to_i)   ###Whr 壱日の労働時間
      		end
    end 
    if nd["unitofduration"] ==  "Hour" or hourFlg 
		    pstarttime =  parent["starttime"].to_time  ###dvsxxxs,ercxxxs,shpxxxsで使用。ercschsの親はdvsschs
		    pduedate =  parent["duedate"].to_time  ###dvsxxxs,ercxxxs,shpxxxsで使用。
		    cduedate = command_x["#{tblnamechop}_duedate"].to_time
		    case tblnamechop   ###insts ,reply,dlvs,actsではstarttimeはない
	    		when /pur/
            	starttime,message = proc_calculate_working_time(tblnamechop,cduedate,duration,"-",command_x["#{tblnamechop}_supplier_id"])
	    	 	when /dym/
            	starttime,message = proc_calculate_working_time(tblnamechop,cduedate,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when /cust/  ###前日準備 出荷のためshipになる
							strsql = %Q&
													select * from shelfnos where id = #{command_x["#{tblnamechop}_shelfno_id_fm"]}
							&
							shelfno = ActiveRecord::Base.connection.select_one(strsql)
            	starttime,message  = proc_calculate_working_time("shpsch",cduedate,duration,"-",shelfno["locas_id_shelfno"])
		      when /prd|con/
            	if tblnamechop =~ /sch/
              		str_qty = command_x["#{tblnamechop}_qty_sch"].to_f
            	else
              		str_qty = command_x["#{tblnamechop}_qty"].to_f
            	end
			    		strsql = %Q&
				              select nd.packqtyfacility,nd.durationfacility,itm.classlist_code,op.duration 
					                  from nditms nd
					                  inner join (select i.id itms_id,c.code classlist_code from itms i
										                        inner join classlists c	on i.classlists_id = c.id
													                  where c.code in('apparatus') )								
					                        itm on itm.itms_id = nd.itms_id_nditm
					                  inner join opeitms op on op.id = nd.opeitms_id
					                  where op.itms_id = #{nd["itms_id"]} and op.processseq = #{nd["processseq"]} 
					                  and  op.priority = 999 ---nd["itms_id"],nd["processseq"] = child itms
					              &
			    	appas = ActiveRecord::Base.connection.select_all(strsql)
			    	appas.each do |appa|	###複数の装置のLTがある時
				    	if  (appa["durationfacility"]) > 0   ###装置のlt
					      if (appa["packqtyfacility"]) > 0  ###nd["duration"].nil? --> tbl=dymschs&opeitms無
                  			tduration = appa["durationfacility"]*str_qty/appa["packqtyfacility"]    
					      else
                  			tduration = appa["durationfacility"]
					      end
              	if nd["unitofduration"] ==  "Hour"
                		tduration = tduration * 3600
              	else
                		tduration = tduration * Constants::Whr * 3600
              	end
								
              	if tduration > duration
                		duration = tduration
              	end
				    	end
            end  
            starttime,message = proc_calculate_working_time(tblnamechop,cduedate,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when /^dvs/  ###親はprdschs
            	# strsql = %Q&
				    #           select f.shelfnos_id from facilities f 
            	#                 inner join #{tblnamechop}s d on d.facilities_id = f.id
            	#                 where d.id = #{command_x["id"]} &
			      # shelfnos_id = ActiveRecord::Base.connection.select_value(strsql)
            	if nd["unitofduration"] ==  "Hour"
              		duration = (nd["changeoverlt"]||=0).to_f * 3600
            	else
              			duration = (nd["changeoverlt"]||=0).to_f * Constants::Whr * 3600
            	end
            	if (nd["changeoverlt"]||=0).to_f == 0
              		starttime = pstarttime
            	else
              		starttime,message = proc_calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["#{tblnamechop}_facilitie_id"])
            	end
		      when /^shp/ ###親はprdschs 工具・金型
            	if nd["unitofduration"] ==  "Hour"
              		duration = (nd["changeoverlt"]||=0).to_f * 3600
            	else
              		duration = (nd["changeoverlt"]||=0).to_f * Constants::Whr * 3600
            	end
            	starttime,message = proc_calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["shelfno_loca_id_shelfno_fm"])
		      when /^run/ ###親はprdschs 工具・金型
            	if nd["unitofduration"] ==  "Hour"
              		duration = (nd["changeoverlt"]||=0).to_f * 3600
            	else
              		duration = (nd["changeoverlt"]||=0).to_f * Constants::Whr * 3600
            	end
            	starttime,message = proc_calculate_working_time(tblnamechop,pstarttime,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when "ercsch","ercord" ###親はdvsschs
			      case command_x["#{tblnamechop}_processname"]   ###親はdvsschs
			        when "changeover"
                		starttime,message = proc_calculate_working_time(tblnamechop,pstarttime,(nd["changeoverlt"]||=0).to_f*3600,"-",command_x["#{tblnamechop}_fcoperator_id"])
			        when "require"
				        starttime =  pstarttime 
			        when "postprocess"
				        starttime = pduedate 
              else
                	raise" error class:#{self} ,line:#{__LINE__},processname:#{command_x["#{tblnamechop}_processname"]},command_x:#{command_x} "
			      end
        	else
            	raise"error  class:#{self} ,line:#{__LINE__},  tblnamechop:#{tblnamechop}, command_x:#{command_x} "
    		end
    else
		    pstarttime =  parent["starttime"].to_date  ###ercschsの親はdvsschs
		    pduedate =  parent["duedate"].to_date
		    cduedate = command_x["#{tblnamechop}_duedate"].to_date
		    case tblnamechop   ###insts ,reply,dlvs,actsではstarttimeはない
  	  		when /^pur/
            	starttime,message = proc_calculate_working_day(tblnamechop,cduedate,duration,"-",command_x["#{tblnamechop}_supplier_id"])
		      when /^mnf/
            	starttime,message = proc_calculate_working_day(tblnamechop,cduedate,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when /^cust/
            	starttime,message = proc_calculate_working_day(tblnamechop,cduedate,duration,"-",command_x["#{tblnamechop}_cust_id"])
		      when /^prd|^con/
            	if tblnamechop =~ /sch/
              		str_qty = command_x["#{tblnamechop}_qty_sch"].to_f
            	else
              		str_qty = command_x["#{tblnamechop}_qty"].to_f
            	end
			    	strsql = %Q&  ---装置のLTがある時
				              select nd.packqtyfacility,nd.durationfacility,itm.classlist_code,op.duration,op.shelfnos_id_opeitm shelfnos_id 
					                  from nditms nd
					                  inner join (select i.id itms_id,c.code classlist_code from itms i
										                        inner join classlists c	on i.classlists_id = c.id
													                  where c.code in('apparatus') )								
					                        itm on itm.itms_id = nd.itms_id_nditm
					                  inner join opeitms op on op.id = nd.opeitms_id
					                  where op.itms_id = #{nd["itms_id"]} and op.processseq = #{nd["processseq"]} 
					                  and  op.priority = 999 ---nd["itms_id"],nd["processseq"] = child itms
					              &
			      appas = ActiveRecord::Base.connection.select_all(strsql)
			      appas.each do |appa| 		
				    	if  (appa["durationfacility"].to_f) > 0   ###装置のlt
					      if (appa["packqtyfacility"].to_f) > 0  ###nd["duration"].nil? --> tbl=dymschs&opeitms無
                  			tduration = (appa["durationfacility"].to_f)*str_qty/(appa["packqtyfacility"].to_f).ceil    
					      else
                  			tduration = (appa["durationfacility"].to_f).ceil  
					      end
				    	else
                		tduration = (appa["duration"]||=1).to_f.ceil  ###prdschs.opeitms_id.duration
				    	end
			        if tduration > duration
				        duration = tduration
			        end
			      end
            starttime,message = proc_calculate_working_day(tblnamechop,cduedate,duration,"-",command_x["shelfno_loca_id_shelfno"])
		      when /^dvs/  ###親はprdschs
            	starttime,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["changeoverlt"]).to_f.ceil,"-",command_x["#{tblnamechop}_facilitie_id"])
		      when /^shp/ ###親はprdschs 工具・金型
            	starttime,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["changeoverlt"]).to_f.ceil,"-",command_x["shelfno_loca_id_shelfno_fm"])
		      when /^dym|^run/ ###親はprdschs 工具・金型
            	starttime,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["changeoverlt"]).to_f.ceil,"-",command_x["shelfno_loca_id_shelfno"])
		      when "ercsch","ercord" ###親はdvsschs
			      case command_x["#{tblnamechop}_processname"]   ###親はdvsschs
			        when "changeover"
                		starttime,message = proc_calculate_working_day(tblnamechop,pstarttime,(nd["changeoverlt"]).to_f.ceil,"-",command_x["#{tblnamechop}_fcoperator_id"])
			        when "require"
				        starttime =  pstarttime 
			        when "postprocess"
				        starttime = pduedate 
              	 else
                	raise "error class:#{self} ,line:#{__LINE__},processname :#{command_x["#{tblnamechop}_processname"]},command_x:#{command_x} "
			      end
            else
              raise"error  class:#{self} ,line:#{__LINE__},  tblnamechop :#{tblnamechop} command_x:#{command_x} "
		    end
    end
		case tblnamechop
		 	when /^shp/
		  		command_x["#{tblnamechop}_depdate"] = starttime.strftime("%Y-%m-%d") + " " + parent["starttime"].to_time.strftime("%H:%M:%S")		
		 	else
		  		command_x[(tblnamechop+"_starttime")] =  (starttime.strftime("%Y-%m-%d %H:%M:%S") )
		end
		# end
    	command_x[(tblnamechop+"_remark")] = message 
		return command_x
	end

	def field_chrgs_id tblnamechop,command_x,nd ### seq_noは　chrgs_id > custs_id,suppliers_id,workplaces_idであること
		if command_x["#{tblnamechop}_chrg_id"].nil? or  command_x["#{tblnamechop}_chrg_id"] == ""
				case tblnamechop
					when /^cust/
						strsql = %Q&
							select chrgs_id_cust chrgs_id from custs where id = #{command_x["#{tblnamechop}_cust_id"] }
							&
					when /^pur/
				 		strsql = %Q&
				 			select chrgs_id_supplier chrgs_id ,locas_id_calendar from suppliers 
									where locas_id_supplier = #{nd["locas_id"]}
				 			&
				 	when /^prd|^dvs/
				 		strsql = %Q&
				 			select chrgs_id_workplace chrgs_id from workplaces 
							 		where locas_id_workplace = #{nd["locas_id"]}
				 			&
					when /^erc/
				 		strsql = %Q&
				 			select chrgs_id_fcoperator  chrgs_id from fcoperators
									where itms_id_fcoperator = #{nd["itms_id"]} order by priority desc
				 			&
					when /^dymsch/
						strsql = %Q&
							select 0 chrgs_id 
							&
					else
					raise"get chrgs_id error  e class:#{self}, line:#{__LINE__} ,tblnamechop:#{tblnamechop}"
				end
        chrg = ActiveRecord::Base.connection.select_one(strsql)
				command_x["#{tblnamechop}_chrg_id"] = chrg["chrgs_id"]
		end
		return command_x
	end	

	def proc_field_fcoperators_id(tblnamechop,command_x,parent,nd) 
    	case tblnamechop
    	when "ercsch"
		  strsql = %Q&  ---予定されている担当者
				select fc.id ,fc.itms_id_fcoperator  ,fc.chrgs_id_fcoperator from fcoperators fc
						left join ercschs es1 on fc.id = es1.fcoperators_id and es1.commencementdate  < to_timestamp('#{command_x["ercsch_commencementdate"]}','yyyy-mm-dd hh24:mi:ss') 
																			and es1.duedate  > to_timestamp('#{command_x["ercsch_commencementdate"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercschs es2 on fc.id = es2.fcoperators_id and es2.commencementdate  < to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
																			and es2.duedate > to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercords eo1 on fc.id = eo1.fcoperators_id and eo1.commencementdate  < to_timestamp('#{command_x["ercsch_commencementdate"]}','yyyy-mm-dd hh24:mi:ss') 
																			and eo1.duedate  > to_timestamp('#{command_x["ercsch_commencementdate"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercords eo2 on fc.id = eo2.fcoperators_id and eo2.commencementdate  < to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
																			and eo2.duedate > to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercinsts ei1 on fc.id = ei1.fcoperators_id and ei1.commencementdate  < to_timestamp('#{command_x["ercsch_commencementdate"]}','yyyy-mm-dd hh24:mi:ss') 
																			and ei1.duedate  > to_timestamp('#{command_x["ercsch_commencementdate"]}','yyyy-mm-dd hh24:mi:ss')
						left join ercinsts ei2 on fc.id = ei2.fcoperators_id and ei2.commencementdate  < to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
																			and ei2.duedate > to_timestamp('#{command_x["ercsch_duedate"]}','yyyy-mm-dd hh24:mi:ss')
						where fc.itms_id_fcoperator = #{nd["itms_id"]} and fc.expiredate > current_date
		    &
		  ids = ActiveRecord::Base.connection.select_all(strsql)
		  if ids.to_ary.size > 0
			  str = ""
			  ids.each do |id|
				str << "'" + id["id"].to_s + "',"
			  end
			  strsql = %Q&
				  select fc.id  ,fc.chrgs_id_fcoperator from fcoperators fc
						where fc.id not in (#{str.chop}) and fc.itms_id_fcoperator = #{ids[0]["itms_id_fcoperator"]} 
            and expiredate > current_date                     order by fc.priority desc&
			  fcoperator = ActiveRecord::Base.connection.select_one(strsql)
        	###　空きがなければ主担当を採用
			  if fcoperator.nil?
          strsql = %Q&
            select fc.id ,fc.chrgs_id_fcoperator from fcoperators fc
						where fc.itms_id_fcoperator = #{nd["itms_id"] } and fc.expiredate > current_date
              order by fc.priority desc&
          fcoperator = ActiveRecord::Base.connection.select_one(strsql)
			  end
		  else
			  strsql = %Q&
				  select fc.id ,fc.chrgs_id_fcoperator from fcoperators fc
						where f.itms_id_fcoperator = #{nd["itms_id"] } and fc.expiredate > current_date
            order by fc.priority desc&
			  fcoperator = ActiveRecord::Base.connection.select_one(strsql)
		  end
		  if fcoperator
			  command_x["#{tblnamechop}_fcoperator_id"] = fcoperator["id"]
		  else
			  raise " error class:#{self} ,line:#{__LINE__}, can not get fcoperators_id \n nd:#{nd} \n command_x:#{command_x} "
		  end
    	when "ercord"
			strsql = %Q&
				  select fc.id  ,fc.chrgs_id_fcoperator from fcoperators fc
						where fc.itms_id_fcoperator = #{nd["itms_id"] } and fc.expiredate > current_date 
            order by fc.priority desc&
			fcoperator = ActiveRecord::Base.connection.select_one(strsql)
		  if fcoperator
			  command_x["#{tblnamechop}_fcoperator_id"] = fcoperator["id"]
		  else
        	raise " error class:#{self} ,line:#{__LINE__},tblnamechop:#{tblnamechop},\n command_x:#{command_x},\n nd:#{nd} "
		  end
    	else
      		raise " error class:#{self} ,line:#{__LINE__},tblnamechop:#{tblnamechop} error\n command_x:#{command_x},\n nd:#{nd} "
    	end
		return command_x
	end

	def field_qty_sch tblnamechop,command_x,parent,nd
		qty_require = proc_cal_qty_sch(parent["qty_handover"].to_f,
										nd["chilnum"],nd["parenum"])
		command_x["#{tblnamechop}_qty_sch"]  = qty_require
		command_x["#{tblnamechop}_qty_case"]  = (qty_require / nd["packqty"]).ceil 
		return command_x,qty_require
	end	
########  オーダ作成時纏められるので　nd["consumunitqty"],nd["consumminqty"],nd["consumchgoverqty"]は意味なし
	# def proc_cal_qty_sch(parent_qty,chilnum,parenum,consumunitqty,consumminqty,consumchgoverqty)
  #   	parenum == 0 ? parenum = 1.0 : parenum = parenum
	# 		consumunitqty == 0 ? consumunitqty = 1.0 : consumunitqty = consumunitqty
	# 	qty_require = parent_qty * chilnum / parenum
	# 	# consumunitqty等については親に合わせて計算する。
	# 	qty_require = (qty_require / consumunitqty).ceil *  consumunitqty  
	# 	if consumminqty > qty_require
	# 		qty_require = consumminqty  ###最小消費数
	# 	end	
	# 	qty_require = (qty_require + consumchgoverqty)## consumchgoverqty    ###段取り時に余分に使用(消費)される数量
	# end
	def proc_cal_qty_sch(parent_qty,chilnum,parenum)
    	parenum == 0 ? parenum = 1.0 : parenum = parenum
		qty_require = parent_qty * chilnum / parenum
		# consumunitqty等については親に合わせて計算する。
		# qty_require = (qty_require / consumunitqty).ceil *  consumunitqty  
		# if consumminqty > qty_require
		# 	qty_require = consumminqty  ###最小消費数
		# end	
		# qty_require = (qty_require + consumchgoverqty)## consumchgoverqty    ###段取り時に余分に使用(消費)される数量
		return qty_require
	end

	def field_price_amt_tax_contractprice tblnamechop,command_x
		case tblnamechop
		when /pur/  ###supplierprices
			command_x,err = proc_judge_check_supplierprice(command_x,"",0,"r_#{tblnamechop}s")
		when  /shp/  ###shpprices
		end
		###  command_x = PriceLib.proc_price_amt(tblnamechop,command_x)
		return command_x
	end

	def proc_field_sno(tblnamechop,isudate,id)  ###id=tbl.id
		(proc_snolist["#{tblnamechop}s"]||="") + (isudate||=Time.now).to_time.strftime("%y")[1] + 
					["0","1","2","3","4","5","6","7","8","9","A","B","C"][(isudate||=Time.now).to_time.strftime("%m").to_i]  + format('%04d', id) 
	end

	def proc_field_cno tblnamechop,id 
		 format('%07d', id)
	end

	def proc_field_gno(tblnamechop,id)
		(proc_gnolist["#{tblnamechop}s"]||="") + format('%07d', id) 
	end	

	def field_prjnos_id tblnamechop,command_x,parent,nd
		command_x["#{tblnamechop}_prjno_id"] = parent["prjnos_id"] 
		return command_x
	end	

	def field_consumauto tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_consumauto"] = (nd["consumauto"]||="")
		return command_x
	end

	def field_autocreate tblnamechop,command_x,nd,parent
		command_x["#{tblnamechop}_autocreate"] = (nd["autocreate"] ||="")
		return command_x
	end		
	
	def field_expiredate tblnamechop,command_x,parent,nd
		if command_x["#{tblnamechop}_expiredate"].nil? or command_x["#{tblnamechop}_expiredate"] == ""
			command_x["#{tblnamechop}_expiredate"] =  Constants::EndDate  
		end
		return command_x
	end
	
	def proc_billord_exists(lineData)  ###既に請求書発行済?
		false
	end

  def proc_calculate_working_day(tblnamechop,base_date,calculate_day,plusminus,calendars_id)
    ###base_date (型:Date からcalculate_day日後の稼働日を考慮して計算する  
    ###dayofweek = "0":日曜日,"1":月曜日,"2":火曜日,"3":水曜日,"4":木曜日,"5":金曜日,"6":土曜日　休日がarrayで渡される
    ###holidays = "mmdd"でarray 型で休日を渡す
    ###workingday = "yyyymmdd"でarray 型で稼働日を渡す
    ###calendars_id prd,shp:locas_id, pur:suppliers_id, cust: 客先:custs_id , 出荷:shelfnos_id_fm
    message = ""
    case tblnamechop
      when /^pur/
            strsql = %Q&
                    select dayofweek,holidays,workingday from hcalendars 
                        where locas_id = (select locas_id_calendar from suppliers 
                                                where id = #{calendars_id}    ---calendars_id = suppliers_id
                                                and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                        order by expiredate limit 1
              &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
            if calendar.nil?
              message = "suppliers_id:#{calendars_id}  calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
              # if calendar.nil?
              #   raise"error e2 calendar missing \n supplier:#{calendars_id}  calendar missing"
              # end
            end
      when /^prd/
            strsql = %Q&
                select h.dayofweek,h.holidays,workingday from hcalendars h
                    where h.locas_id = (select locas_id_calendar from workplaces w
                                         --- inner join shelfnos s on w.locas_id_workplace = s.locas_id_shelfno
                                       ---   where s.id = #{calendars_id})   --- calendars_id = shelfnos_id
                                          where w.locas_id_workplace = #{calendars_id})   --- calendars_id = shelfnos_id
                                          and h.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                        order by h.expiredate limit 1
            &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
            if calendar.nil?
              message = "workplaces locas_id:#{calendars_id}  calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                raise"error e3calendar missing \n workplaces locas_id:#{calendars_id}  calendar missing"
              end
            end
      when /^cust/
                strsql = %Q&
                        select dayofweek,holidays,workingday from hcalendars 
                            where locas_id = (select locas_id_cust from custs s 
                                               where s.id = #{calendars_id})  
                            and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                            order by expiredate limit 1
                &
                calendar = ActiveRecord::Base.connection.select_one(strsql)
                if calendar.nil?
                  message = "shipping shelfnos_id:#{calendars_id}  calendar missing"
                  strsql = %Q&
                          select dayofweek,holidays,workingday from hcalendars 
                              where locas_id = 0
                              order by expiredate limit 1
                    &
                  calendar = ActiveRecord::Base.connection.select_one(strsql)
                  # if calendar.nil?
                  #   raise"error e4calendar missing \n locas_id = 0  calendar missing"
                  # end
                end
      when /^dvs/
            strsql = %Q&  ---休日を求める　facilitycalendars:日別カレンダーから年次カレンダーを求める
                    select * from facilitycalendars f 
                          where f.facilities_id = #{calendars_id}
                           and f.targetdate > current_date
										        and f.expiredate > current_date and f.effectivestarttime = ''
										        and not exists(select 1 from facilitycalendars f2  where f.facilities_id = f2.facilities_id 
														                and f.targetdate  = f2.targetdate  and f2.effectivestarttime != '')										
									          order by f.targetdate 
            &
            timeCalendars = ActiveRecord::Base.connection.select_all(strsql)
            if timeCalendars.length == 0
              message = "facilities_id:#{calendars_id}  facilities calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
            else
              calendar = {"workingday" => "","dayofweek" => "","holidays" => ""}
              timeCalendars.each do |clndr|
                calendar["holidays"] << clndr["targetdate"].to_date.strftime("%m%d") + ","
              end              
            end
      when /^erc/
            strsql = %Q&
                    select p.* from chrgs c 
			                  inner join personcalendars p  on p.persons_id = c.persons_id_chrg
			                  where p.persons_id = #{calendars_id} 		and p.expiredate > current_date 
            &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
            if calendar.nil?
              message = "persons_id:#{calendars_id}  persons calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
            end
      when /^shp|^run/ 
        strsql = %Q&
            select h.dayofweek,h.holidays,workingday from hcalendars h
                ---where h.locas_id = (select locas_id_shelfno from shelfnos s
                ---                     where s.id = #{calendars_id})   --- calendars_id = shelfnos_id
                where h.locas_id =  #{calendars_id}
                and h.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                    order by h.expiredate limit 1
        &
        calendar = ActiveRecord::Base.connection.select_one(strsql)
        if calendar.nil?
            strsql = %Q&
             select dayofweek,holidays,workingday from hcalendars 
               where locas_id = 0
               and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
               order by expiredate limit 1
              &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
              # if calendar.nil?
              #   raise"error e5 calendar missing "
              # end
              message = "calendars_id:#{calendars_id}   calendar missing"
        end
      else
        strsql = %Q&
         select dayofweek,holidays,workingday from hcalendars 
           where locas_id = 0
           and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
           order by expiredate limit 1
          &
        calendar = ActiveRecord::Base.connection.select_one(strsql)
          if calendar.nil?
            raise"error e6 calendar missing "
          end
    end
    workingday = calendar["workingday"].gsub(/-|\//,"").split(",")  ###稼働日
    dayofweek = calendar["dayofweek"].split(",")  ###曜日
    holidays = calendar["holidays"].split(",")  ###休日
    degcnt = 0
    if calculate_day < 0
      if plusminus == "+"
        plusminus = "-"
      else
        plusminus = "+"
      end
      calculate_day = calculate_day * -1
    end  
    until calculate_day < 0
        if !workingday.include?(base_date.strftime("%Y%m%d"))&&(dayofweek.include?(base_date.wday.to_s)||holidays.include?(base_date.strftime("%m%d")))
          degcnt += 1
          raise"error  e7 LINE:#{__LINE__},degcnt:#{degcnt},calculate_day:#{calculate_day},base_date:#{base_date}, plusminus:#{plusminus},workingday:#{workingday},dayofweek:#{dayofweek},holidays:#{holidays}"  if degcnt > 1000
        else
          calculate_day -= 1
          return base_date,message if calculate_day < 0
        end
        if  plusminus == "-"
          base_date = base_date.to_date - 1
        else
          base_date = base_date.to_date + 1
        end
    end
    return base_date,message
  end

  def proc_calculate_working_time(tblnamechop,base_date,calculate_time,plusminus,calendars_id)  ###custsには対応しない
    ###base_date (型:Time)からcalculate_time時間後の稼働時間を考慮して計算する 
    ###calculate_time (型:numeric) 移動時間 秒数
    ###plusminus "+" or "-" で加算または減算する
    ###dayofweek = "0":日曜日,"1":月曜日,"2":火曜日,"3":水曜日,"4":木曜日,"5":金曜日,"6":土曜日　休日がarrayで渡される
    ###holidays = "mmdd"でarray 型で休日を渡す
    ###workingday = "yyyymmdd"でarray 型で稼働日を渡す
    ## return base_date(型TTime)
    message = ""
    calendars = []
    calendar = {}
    ###
    # 日別カレンダーか年次カレンダーの判断
    case tblnamechop
      when /^pur/
        strsql = %Q&
                 select * from calendars 
                        where locas_id = (select locas_id_calendar from suppliers 
                                                where id = #{calendars_id}    ---calendars_id = suppliers_id
                                                and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                        												and targetdate  #{if plusminus == "-" then "<=" else ">=" end} cast('#{base_date.strftime("%Y-%m-%d")}' as date)
																								and targetdate > current_date
																								)
                        order by targetdate #{if plusminus == "-" then "desc" else "asc" end},
                                  effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}  
                    &
          calendars = ActiveRecord::Base.connection.select_all(strsql)
          if calendars.length == 0          
              strsql = %Q&
                    select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                        where locas_id = (select locas_id_calendar from suppliers 
                                      where id = #{calendars_id}    ---calendars_id = suppliers_is
                        and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                        order by expiredate limit 1
              &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                message = "suppliers_id:#{calendars_id}  calendar missing"
                strsql = %Q&
                      select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
                calendar = ActiveRecord::Base.connection.select_one(strsql)
                if calendar.nil?
                  raise"error e8 calendar missing \n supplier:#{calendars_id}  calendar missing"
                end
              end
          end
      when /^prd/
        strsql = %Q&
                 select * from calendars c
                        where c.locas_id = (select locas_id_calendar from workplaces w
                                                ---  inner join shelfnos s on w.locas_id_workplace = s.locas_id_shelfno
                                                 --- where s.id = #{calendars_id}    --- calendars_id = shelfnos_id
                                                  where w.locas_id_workplace = #{calendars_id}    --- 
                                                  and w.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
																								and targetdate > current_date)
                        and c.targetdate #{if plusminus == "-" then "<=" else ">=" end} cast('#{base_date.strftime("%Y-%m-%d")}' as date)
                        order by c.targetdate #{if plusminus == "-" then "desc" else "asc" end},
                                  c.effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}  
                    &
          calendars = ActiveRecord::Base.connection.select_all(strsql)
          if calendars.length == 0          
              strsql = %Q&
                    select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                        where locas_id = (select locas_id_calendar from workplaces w
                                           --- inner join shelfnos s on w.locas_id_workplace = s.locas_id_shelfno
                                            where w.locas_id_workplace = #{calendars_id})   ---
                        and hcalendars.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
                        order by hcalendars.expiredate limit 1
            &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
            if calendar.nil?
              message = "locas_id:#{calendars_id}  workplaces calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
							# if calendar.nil?
              #   raise"error e9 calendar missing \n workplaces shelfnos_id:#{calendars_id}  calendar missing"
							# end
            end
          end
      when /^dvs/
            strsql = %Q&  
                    select * from facilitycalendars f 
                          where f.facilities_id = #{calendars_id}
                           and f.targetdate #{if plusminus == "-" then "<=" else ">=" end} cast('#{base_date.strftime("%Y-%m-%d")}' as date)
                           and f.expiredate > current_date 	and targetdate > current_date				
									         order by targetdate #{if plusminus == "-" then "desc" else "asc" end},
                                    effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}
            &
            calendars = ActiveRecord::Base.connection.select_all(strsql)
            if calendars.length == 0
              message = "facilities_id:#{calendars_id}  facilities calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
            	# if calendar.nil?
              # 	  raise"error e91 calendar missing \n workplaces shelfnos_id:#{calendars_id}  calendar missing"
            	# end
            end
      when /^erc/
            strsql = %Q&
                    select p.* from chrgs c 
			                  inner join personcalendars p  on p.persons_id = c.persons_id_chrg
			                  where p.persons_id = #{calendars_id} 		and p.expiredate > current_date 	and targetdate > current_date
                        order by targetdate,effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}  
            &
            calendars = ActiveRecord::Base.connection.select_all(strsql)
            if calendars.length == 0
              message = "persons_id:#{calendars_id}  persons calendar missing"
              strsql = %Q&
                      select dayofweek,holidays,workingday,effectivetime from hcalendars 
                          where locas_id = 0
                          order by expiredate limit 1
                &
              calendar = ActiveRecord::Base.connection.select_one(strsql)
            	# if calendar.nil?
              #   raise"error e92 calendar missing \n workplaces shelfnos_id:#{calendars_id}  calendar missing"
            	# end
            end
      when /^shp/
              strsql = %Q&
                     select * from calendars c
                            where c.locas_id = #{calendars_id}  
                                ---(select locas_id_shelfno from shelfnod s
                                ---                      where s.id = #{calendars_id}    --- calendars_id = shelfnos_id
                                ---                      and w.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                            and c.targetdate #{if plusminus == "-" then "<=" else ">=" end} cast('#{base_date.strftime("%Y-%m-%d")}' as date)
														and targetdate > current_date
                            order by targetdate #{if plusminus == "-" then "desc" else "asc" end},
                                      effectivestarttime #{if plusminus == "-" then "desc" else "asc" end}  
                        &
              calendars = ActiveRecord::Base.connection.select_all(strsql)
              if calendars.length == 0          
                  strsql = %Q&
                        select dayofweek,holidays,workingday,effectivetime  from hcalendars 
                            where locas_id = (select locas_id_shelfno from shelfnos s
                                                      where s.id = #{calendars_id}    --- calendars_id = shelfnos_id
                                                      and s.expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date))
                            order by expiredate limit 1
                &
                calendar = ActiveRecord::Base.connection.select_one(strsql)
                # if calendar.nil?
                #     raise"error ea calendar missing \n workplaces shelfnos_id:#{calendars_id}  calendar missing"
                # end
              end
      else
            strsql = %Q&
             select dayofweek,holidays,workingday,effectivetime  from hcalendars 
               where locas_id = 0
               and expiredate > cast('#{Date.today.strftime("%Y-%m-%d")}' as date)
               order by expiredate limit 1
              &
            calendar = ActiveRecord::Base.connection.select_one(strsql)
              if calendar.nil?
                raise"error eb calendar missing "
              end
    end
    degcnt = 0
    if calendars.length == 0  ###日別カレンダーがない場合は年次カレンダーを使用する
    	workingday = calendar["workingday"].gsub(/-|\//,"").split(",")  ###稼働日
    	dayofweek = calendar["dayofweek"].split(",")  ###曜日
    	holidays = calendar["holidays"].split(",")  ###休日
      wkHour = 0
      calendar["effectivetime"].split(",").each do |effectivetime|  ###effectivetime = "09:00-17:00"又は"09:00-12:00","13:00-17:00"
        wkHour = effectivetime.split(/-|~/)[1].to_time - effectivetime.split(/-|~/)[0].to_time 
      end
      until calculate_time < 0
        if !workingday.include?(base_date.strftime("%Y%m%d"))&&(dayofweek.include?(base_date.wday.to_s)||holidays.include?(base_date.strftime("%m%d")))
          degcnt += 1
          raise"error LINE:#{__LINE__},degcnt:#{degcnt},base_date:#{base_date},workingday:#{workingday},dayofweek:#{dayofweek},holidays:#{holidays}"  if degcnt > 1000
        else
          if  calculate_time < wkHour
            if  plusminus == "-"
              base_date = base_date - 86400 ###1日分の秒数を引く
              calendar["effectivetime"].split(",").reverse_each do |eff|  ###effectivetime = "09:00-17:00"又は"09:00-12:00","13:00-17:00"
                if  calculate_time  > (eff.split(/-|~/)[1].to_time - eff.split(/-|~/)[0].to_time) 
                    calculate_time -=  (eff.split(/-|~/)[1].to_time - eff.split(/-|~/)[0].to_time)
                    next
                else
                  base_date = (base_date.strftime("%Y-%m-%d") + " " + eff.split(/-|~/)[1] + ":00").to_time.ago(calculate_time) 
                end
              end
            else
              base_date = base_date + 86400  ###1日分の秒数を足す
              calendar["effectivetime"].split(",").each do |eff|  ###effectivetime = "09:00-17:00"又は"09:00-12:00","13:00-17:00"
                if  calculate_time  > (eff.split(/-|~/)[1].to_time - eff.split(/-|~/)[0].to_time) 
                    calculate_time -=  (eff.split(/-|~/)[1].to_time - eff.split(/-|~/)[0].to_time) 
                    next
                else
                    base_date = (base_date.strftime("%Y-%m-%d") + " " + eff.split(/-|~/)[0] + ":00").to_time.since(calculate_time) 
                end
              end
            end
            return base_date,message 
          else
            calculate_time -= wkHour
          end
        end
        if  plusminus == "-"
          base_date = base_date - 86400  ###1日分の秒数を引く
        else
          base_date = base_date + 86400
        end
      end
    else ###日別カレンダーがある場合は日別カレンダーを使用する
      if plusminus == "-"
        calendars.each do |calendar|
          if calendar["effectivestarttime"].to_time.nil? or calendar["effectivestarttime"].to_time.nil?
            degcnt += 1
            raise"error LINE:#{__LINE__},degcnt:#{degcnt},base_date:#{base_date},calendar:#{calendar}"  if degcnt > 1000
            next
          else
            if  base_date.to_date == calendar["targetdate"].to_date
                if base_date.strftime("%H:%M") < calendar["effectivestarttime"] or base_date.strftime("%H:%M") > calendar["effectiveendtime"]
                  next
                else
                  wkHour =  calendar["effectivestarttime"].to_time - base_date.strftime("%H:%M").to_time
                  if calculate_time < wkHour
                    base_date = (calendar["targetdate"].to_time.strftime("%Y-%m-%d") + " " + calendar["effectivestarttime"] + ":00").to_time.since(calculate_time) 
                    break
                  else
                    calculate_time -= wkHour
                    next
                  end
                end
            else
              wkHour = calendar["effectiveendtime"].to_time - calendar["effectivestarttime"].to_time
              if calculate_time < wkHour
                base_date = (calendar["targetdate"].to_time.strftime("%Y-%m-%d") + " " + calendar["effectivestarttime"] + ":00").to_time.since(calculate_time) 
                break
              else
                calculate_time -= wkHour
                next
              end
            end
          end
        end
      else
        calendars.each do |calendar|
          if calendar["effectivestarttime"].to_time.nil? or calendar["effectivestarttime"].to_time.nil?
            degcnt += 1
            raise"error LINE:#{__LINE__},degcnt:#{degcnt},base_date:#{base_date},calendar:#{calendar}"  if degcnt > 1000
            next
          else
            if  base_date.to_date == calendar["targetdate"].to_date
                if base_date.strftime("%H:%M") < calendar["effectivestarttime"] or base_date.strftime("%H:%M") > calendar["effectiveendtime"]
                  next
                else
                  wkHour = base_date.strftime("%H:%M").to_time - calendar["effectivestarttime"].to_time
                  if calculate_time < wkHour
                    base_date = (calendar["targetdate"].to_time.strftime("%Y-%m-%d") + " " + calendar["effectivestarttime"] + ":00").to_time.since(calculate_time) 
                    break
                  else
                    calculate_time -= wkHour
                    next
                  end
                end
            else
              wkHour = calendar["effectiveendtime"].to_time - calendar["effectivestarttime"].to_time						
              if calculate_time < wkHour
                base_date = (calendar["targetdate"].to_time.strftime("%Y-%m-%d") + " " + calendar["effectivestarttime"] + ":00").to_time.since(calculate_time) 
                break
              else
                calculate_time -= wkHour
                next
              end
            end
          end
        end
      end
    end
    return base_date,message
  end
    
	def proc_snolist   ###reqparams[:segment] = ["trn_org"]の対象でもある。
		{"purschs"=>"PS","purords"=>"PO","purinsts"=>"PH","purdlvs"=>"PV","puracts"=>"PA","dymschs"=>"DY",
			"purreplyinputs"=>"PL","prdreplyinputs"=>"ML",
			"prdschs"=>"MS","prdords"=>"MO","prdinsts"=>"MH","prdacts"=>"MA","prdrets"=>"MR",
			"dvsschs"=>"DS","dvsords"=>"DO","dvsacts"=>"DA",
			"billschs"=>"BS","billords"=>"BO","billinsts"=>"BH","billacts"=>"BA","billrets"=>"BR",
			"payschs"=>"YS","payords"=>"YO","payinsts"=>"YH","payacts"=>"YA","payrets"=>"YR",
			"custschs"=>"CS","custords"=>"CO","custinsts"=>"CJ","custdlvs"=>"CV","custacts"=>"CA","custrets"=>"CR",
			"ercschs"=>"ES","ercords"=>"EO","ercinsts"=>"EJ","ercacts"=>"CA",
			"custordheads"=>"CH","custactheads"=>"CB",
			"shpests"=>"ST","shpschs"=>"SS","shpords"=>"SO","shpinsts"=>"SH","shpacts"=>"SA","shprets"=>"SR",
      "rejections" =>"RJ","movacts" => "MV"}
	end

	
	def proc_gnolist   ###reqparams[:segment] = ["trn_org"]の対象でもある。
		{"purschs"=>"GPS","purords"=>"GPE","purinsts"=>"GPH","purdlvs"=>"GPV","puracts"=>"GPA",
			"purreplyinputs"=>"GPL","prdreplyinputs"=>"GML",
			"prdschs"=>"GMS","prdords"=>"GME","prdinsts"=>"GMH","prdacts"=>"GMA","prdrets"=>"GMR",
			"billschs"=>"GBS","billords"=>"GBE","billinsts"=>"GBH","billacts"=>"GBA","billrets"=>"GBR",
			"payschs"=>"GYS","payords"=>"GYE","payinsts"=>"GYH","payacts"=>"GYA","payrets"=>"GYR",
			"custschs"=>"GCS","custords"=>"GCQ","custinsts"=>"GCJ","custdlvs"=>"GCV","custacts"=>"GCA","custrets"=>"GCR",
			"shpschs"=>"GSS","shpords"=>"GSE","shpinsts"=>"GSH","shpacts"=>"GSA","shprets"=>"GSR"}
	end

	def proc_get_endtime tblname,tbldata
	 	case tblname		
	 	when /dlvs/
	 		tbldata["depdate"]
	 	when /^puracts/
	 		tbldata["rcptdate"]
	 	when /^prdacts/
	 		tbldata["cmpldate"]
	 	when /rets/
	 		tbldata["retdate"]
	 	when /reply/
	 		tbldata["replydate"]
	 	when /^dvs/
	 		tbldata["duedate"]
	 	else
	 		tbldata["duedate"]
	 	end	
	end

  def proc_judge_check_opeitms? parseLineData,item,index,screenCode
    err = nil
    if screenCode =~ /nditms/
      if parseLineData["itm_code_nditm"] and parseLineData["itm_code_nditm"] != ""
        strsql = %Q%
          SELECT * FROM itms WHERE code = '#{parseLineData["itm_code_nditm"]}' and expiredate > current_date
        %
        itm = ActiveRecord::Base.connection.select_one(strsql)
        if itm.nil?
            err = " itms #{parseLineData["itm_code_nditm"]} not found"
		        return parseLineData,err
        else
          strsql = %Q%
                      SELECT code FROM classlists WHERE id = #{itm["classlists_id"]}  and expiredate > current_date
                    %
          classlist = ActiveRecord::Base.connection.select_value(strsql)
          case classlist
            when /ITool|installationCharge|ship|outsourcing|mold/  ###道具、設置費、出荷、外注、金型opeitms必要ない
		          return parseLineData,err
            when /apparatus/  ###装置はopeitms必要ないがfacilitiesは必要
                  strsql = %Q%
                      SELECT id FROM facilities WHERE itms_id = #{itm["id"]}  and expiredate > current_date
                    %
                facilitie = ActiveRecord::Base.connection.select_value(strsql)
                if facilitie.nil?
                  err = " facilities for apparatus #{parseLineData["itm_code_nditm"]} not found"
                end
                return parseLineData,err
          else
            if parseLineData["processseq_nditm"] or parseLineData["processseq_nditm"] == ""
              if parseLineData["processseq_nditm"] == "999"
		            return parseLineData,err  ###dymschs とする
              else
                strsql = %Q%
                            SELECT 1 FROM opeitms WHERE itms_id = #{itm["id"]} and processseq = #{parseLineData["processseq_nditm"]} and expiredate > current_date
                      %
                opeitm = ActiveRecord::Base.connection.select_value(strsql)
                if opeitm.nil?
                  err = " opeitms #{parseLineData["itm_code_nditm"]} not found"
		              return parseLineData,err
                else
		              return parseLineData,err  ###ok
                end
              end
            else
		            return parseLineData,err  ###未入力
            end
          end
        end
      else
		    return parseLineData,err  ###未入力
      end
    else
      err = "logic error: proc_judge_check_opeitms?  screenCode:#{screenCode} not nditms"
		  return parseLineData,err  
    end
  end  ###proc_judge_check_opeitms?
  def proc_judge_check_opeitm_maxqty parseLineData,item,index,screenCode
			###packqtyの整数倍又は999999999
			err = nil
			if parseLineData["opeitm_packqty"]	
				if parseLineData["opeitm_packqty"].to_f != 0
						if parseLineData["opeitm_maxqty"].to_f < 999999999
							 	if (parseLineData["opeitm_maxqty"].to_f /  parseLineData["opeitm_packqty"].to_f).ceil * 
								  			parseLineData["opeitm_packqty"].to_f != parseLineData["opeitm_packqty"].to_f
									err = " opeitm_maxqty must be integer_multiple of  packqty "
								end					
						end
				end	
			end
		  return parseLineData,err  
  end
	def proc_judge_check_opeitm_consumminqty parseLineData,item,index,screenCode
			###packqtyの整数倍又は999999999
			err = nil
			if parseLineData["opeitm_packqty"]	
				if parseLineData["opeitm_packqty"].to_f != 0
						if parseLineData["opeitm_consumminqty"].to_f > 0
							 	if (parseLineData["opeitm_consumminqty"].to_f /  parseLineData["opeitm_packqty"].to_f).ceil * 
								  			parseLineData["opeitm_packqty"].to_f != parseLineData["opeitm_packqty"].to_f
									err = " opeitm_consumminqty must be integer_multiple of  packqty "
								end					
						end
				end	
			end
		  return parseLineData,err  				
	end
end   ##module
