# encoding: utf-8
module Api
class PdfController < ApplicationController  
    def index
    end
    def show
    end
    def create
      rec = {}
            case params[:buttonflg] 
              when 'samplePdf'   
                rec["code"] = "test"
                show_pdf = SamplePdf.new(rec).render
            end

            send_data show_pdf,
            filename: "sample.pdf",
            type: 'application/pdf', ####,
            disposition: "attachment"
            ###disposition: 'inline' # 外すとアクセス時に自動ダウンロードされるようになる
    end
end
end