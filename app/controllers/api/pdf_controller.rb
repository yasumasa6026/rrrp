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

            ## レスポンスヘッダーからcharsetを削除し、バイナリとして扱う
            response.headers['Content-Type'] = 'application/pdf'
            response.headers['Content-Disposition'] = 'attachment; filename="sample.pdf"'
  
            send_data show_pdf,
              filename: "sample.pdf",
              type: 'application/pdf',
              disposition: "attachment"
    end
end
end