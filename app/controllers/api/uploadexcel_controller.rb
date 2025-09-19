module Api
  ###
  ###  rollbackの結果を画面に返せてない。エラー時はlogで確認
  ###　日付は文字タイプ(関数、日付は使用できない。)
  ###
class UploadexcelController < ApplicationController
        #include DeviseTokenAuth::Concerns::SetUserByToken
        # before_action :authenticate_api_user!, except: [:options]

    # GET /api/uploads
    def index
    end

    # PUT /api/recipes/1
    def update
    end
      
    def create   ###自動で作成されたファイル名は変更しないこと。
        ##skip_before_action :verify_authenticity_token
        jparams = params.dup
        tblname = params[:screenCode].split("_")[1]
        strsql = "select code,id from persons where email = '#{params[:email]}'"
        person = ActiveRecord::Base.connection.select_one(strsql)
        if person.nil?
            reqparams[:status] = 403
            reqparams[:err] = "Forbidden paerson code not detect"
            render json: {:params => reqparams}
            return   
        end
        jparams[:person_code_upd] = person["code"]
        jparams[:person_id_upd] = person["id"]
        jparams[:uploadData] = jparams[:uploadexcel] = {}  ###jparamsではuploaddataは使用しない。processreqへの保存対象外
        jparams[:buttonflg] = "import"
        command_c = {}
        screen = ScreenLib::ScreenClass.new(jparams)
        columns_info,page_info,init_where_info,select_fields,fetch_check,dropDownList,@sort_info,nameToCode = 
                screen.proc_create_upload_editable_columns_info jparams,"import" 
        # upload_columns_info = [columns_info,page_info,init_where_info,select_fields.chop,fetch_check,dropDownList,@sort_info,nameToCode]
        
        performSeqNos = []
        results = {}   
        results[:columns] = []
        results[:rows] = []

        columns_info.each do |field|  ### upload_columns_info[0] = columns_info
            if field[:accessor] =~ /_confirm_gridmessage/
                    results[:columns] << field
            else
                    if field[:accessor] =~ /gridmessage$/
                        next
                    else
                        results[:columns] << field
                    end
            end
        end

        rows = []
        uploadError = false
        idx = 0
        idAll = 0

  		fetchCode = YupSchema.proc_create_fetchCode screen.screenCode ##
        checkCode  = YupSchema.proc_create_checkCode screen.screenCode   
        tblid = screen.screenCode.split("_")[1].chop + "_id"
        lines = params[:uploadData][:uploadexcel]
        lines.each do |linevalues|
            parse_linedata = linevalues.dup
            select_fields.split(",").each do |idkey|   ### select_fields.split(","):元keyidsから変更--->view項目
                    parse_linedata[idkey] ||= ""
            end  
            jparams[:screenCode] = screen.screenCode
            jparams[:err] = nil
            parse_linedata["#{tblname.chop}_confirm_gridmessage"] ||= ""
            if linevalues["confirm"] == true
                linevalues.each do |field,val| ###confirmはfunction batchcheckで項目追加している。
                        ##エラーと最初のレコード(confirm="confirm")のname項目行を除く
                    parse_linedata["confirm"] = true
                    if fetchCode[field] 
                        jparams[:fetchCode] = %Q%{"#{field}":"#{val}"}%
                        jparams[:fetchview] = fetchCode[field]
                        jparams = CtlFields.proc_fetch_rec jparams, parse_linedata  
                        if jparams[:err] 
                            parse_linedata["confirm_gridmessage"] = jparams[:err] 
                            parse_linedata["confirm"] = false 
                            parse_linedata[(field+"_gridmessage")] = jparams[:err] 
                            break
                        else
                            parse_linedata = jparams[:parse_linedata].dup 
                        end    
                    end
                end
            else
                uploadError = true  
                parse_linedata["#{tblname.chop}_confirm_gridmessage"] << jparams[:err]
            end
            if parse_linedata["confirm"]  == true 
                parse_linedata.each do |field,val| ###confirmはfunction batchcheckで項目追加している。
                    if checkCode[field] 
                        jparams = CtlFields.proc_judge_check_code jparams,field,checkCode[field],parse_linedata
                    end
                end
            else
                uploadError = true
                parse_linedata["#{tblname.chop}_confirm_gridmessage"] << jparams[:err]
            end
            rows << parse_linedata
        end
        begin
            ActiveRecord::Base.connection.begin_db_transaction()
            rows.each do |parse_linedata|
                blk =  RorBlkCtl::BlkClass.new(screen.screenCode)
                command_c = blk.command_init.dup  ###blkukyはid以外でユニークを保証するkey
                if parse_linedata["confirm"] == true    ###重複keyチェック
                    err = CtlFields.proc_blkuky_check(screen.screenCode.split("_")[1],parse_linedata)
                    tblid = screen.screenCode.split("_")[1].chop + "_id"
                    err.each do |key,recs|
                        recs.each do |rec|
                            if command_c["id"].nil? or command_c["id"] == ""
                                command_c["id"] = rec["id"]
                                parse_linedata[tblid] = parse_linedata["id"] = rec["id"]
                            else
                                if command_c["id"] != rec["id"]
                                    uploadError = true  
                                    parse_linedata["confirm"] = false 
                                    parse_linedata["#{tblname.chop}_confirm_gridmessage"] = "error key:#{key}"
                                end
                            end  
                            if  parse_linedata["aud"] == "add" and  rec["id"] 
                                uploadError = true
                                parse_linedata["confirm"] = false 
                                parse_linedata["#{tblname.chop}_confirm_gridmessage"] = "error already exist key:#{key}"
                            end 
                        end	
                        if recs.empty?
                            if  parse_linedata["aud"] == "update" or parse_linedata["aud"] == "delete"
                                uploadError = true
                                parse_linedata["confirm"] = false 
                                parse_linedata["#{tblname.chop}_confirm_gridmessage"] = "error key not exist key:#{key}"
                            end
                        end  
                    end
                else
                    uploadError = true
                    parse_linedata["confirm"] = false 
                end                
                parse_linedata.each do |key,value|
                    case value.class.to_s  ###画面からの入力はすべてcharとして扱っている。
                    when "Integer"
                        command_c[key]  = value.to_s
                    when "Float"
                        command_c[key]  = value.to_s
                    when "Time"
                        command_c[key]  = value.to_s
                    when "Date"
                        command_c[key] = value.to_s
                    else
                        command_c[key] = (value||="")
                    end
                end
                command_c["#{tblname.chop}_person_id_upd"] = person["id"]
                case command_c["aud"] 
                when "add" 
                    command_c["sio_classname"] = "_add_grid_linedata"
                    command_c["id"] = ArelCtl.proc_get_nextval("#{tblname}_seq")
                    command_c[tblname.chop+"_id"] = command_c["id"] 
                    command_c["#{tblname.chop}_created_at"] = Time.now 
                when "update"         
                    command_c["sio_classname"] = "_update_grid_linedata"
                when "delete"       
                    command_c["sio_classname"] = "_delete_grid_linedata"
                else
                end
                if uploadError == false and parse_linedata["confirm"] == true 
                    setParams = blk.proc_private_aud_rec(jparams,command_c)
                    idx += 1
                    if setParams[:seqno][0]
                        performSeqNos << setParams[:seqno][0]
                    end
                else
                    ActiveRecord::Base.connection.rollback_db_transaction()
                end
                idAll += 1
                results[:rows] << parse_linedata 
            end
        rescue
            ActiveRecord::Base.connection.rollback_db_transaction()
            command_c["sio_result_f"] =   "9"  ##9:error
            command_c["sio_message_contents"] =  "error class #{self} : LINE #{__LINE__} $!: #{$!} "    ###evar not defined
            command_c["sio_errline"] =  "class #{self} : LINE #{__LINE__} $@: #{$@} "[0..3999]
            Rails.logger.debug"error class #{self} : #{Time.now}: #{$@}\n "
            Rails.logger.debug"error class #{self} : $!: #{$!} \n"
            Rails.logger.debug"  idAll = #{idAll} command_init: #{command_c} "
            if rows.empty?
              ###redults excelへの返し
            else
              tmprow = rows[idAll] 
              tmprow["confirm"] = false 
              tmprow["#{tblname.chop}_confirm_gridmessage"] = command_c["sio_message_contents"].to_s[0..1000]
              results[:rows][idAll]  = tmprow
            end
            idx = 0
            uploadError = true
        else
            ActiveRecord::Base.connection.commit_db_transaction()
            performSeqNos.each do |seq|
				        CreateOtherTableRecordJob.perform_later(seq)
            end
            ArelCtl.proc_materiallized tblname
        end
        render json: {:results=>results,:uploadError=>uploadError,:idx=>idx}
    end

    def show
    end
    private
        def uploadexcel_params
            params.require(:uploadexcel).permit(:title, :filename)
        end 
end   ###class
end    ###module