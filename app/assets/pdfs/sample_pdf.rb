# encoding: utf-8
# frozen_string_literal: true
class SamplePdf < Prawn::Document
  def initialize(rec)
    # 1. 最初に日本語フォントを定義
    # Rails.root を使って絶対パスを指定してください
    font_path_g = Rails.root.join('app/assets/fonts/ipag.ttf').to_s
    font_path_p = Rails.root.join('app/assets/fonts/ipagp.ttf').to_s

    super(page_size: 'A4')

    font_families.update('IPA' => {
                           normal: font_path_g,
                           bold: font_path_p
                         })
    font 'IPA'

    # 座標軸（デバッグ用）
    stroke_axis

    # -------- ↓描画処理 ----------
    text "タイトル", size: 20, align: :center
    move_down 20

    text "◉サブタイトル", size: 14
    move_down 10

    schedule = [
      ["項目", "詳細"],
      ["(1)", "#{rec["code"]}"],
      ["(2)", ""],
      ["(3)", ""],
      ["(4)", ""],
      ["(5)", ""],
    ]

    table schedule, cell_style: { height: 30 },
          column_widths: [120, 400] do
      cells.size = 10
      row(0).border_top_width = 2
      row(0).border_bottom_width = 2
      columns(0).row(0..5).border_left_width = 2
      columns(-1).row(0..5).border_right_width = 2
      row(-1).border_bottom_width = 2
    end
  end
end