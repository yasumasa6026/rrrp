# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_17_085421) do
  create_schema "bk"
  create_schema "sio"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "alloctbls", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "srctblname", limit: 30
    t.decimal "srctblid", precision: 38
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "updated_at"
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.decimal "trngantts_id", precision: 38
    t.decimal "qty_linkto_alloctbl", precision: 22
    t.string "allocfree", limit: 5

    t.unique_constraint ["srctblid", "srctblname", "trngantts_id"], name: "alloctbls_uky100"
    t.unique_constraint ["srctblname", "srctblid", "trngantts_id"], name: "alloctbls_uky10"
  end

  create_table "asstwhs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "locas_id_asstwh", precision: 38, null: false
    t.decimal "chrgs_id_asstwh", precision: 38, null: false
    t.string "autocreate_inst", limit: 1
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "stktakingproc", limit: 1
    t.string "acceptanceproc", limit: 30
  end

  create_table "billacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "bills_id", precision: 38, null: false
    t.decimal "cash", precision: 22, scale: 2
    t.decimal "taxrate", precision: 2
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "denomination", limit: 15
    t.string "accounttitle", limit: 1
    t.date "paymentdate"
  end

  create_table "billdlvs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.string "denomination", limit: 15
  end

  create_table "billests", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.decimal "tax", precision: 38, scale: 4
    t.decimal "processseq", precision: 38
    t.string "gno", limit: 40
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "taxrate", precision: 2
    t.decimal "bills_id", precision: 38, null: false
    t.decimal "amt_est", precision: 22, scale: 4
    t.string "accounttitle", limit: 1
  end

  create_table "billinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.string "remark", limit: 4000
    t.decimal "bills_id", precision: 38, null: false
    t.decimal "taxrate", precision: 2
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "denomination", limit: 15
    t.string "accounttitle", limit: 1
  end

  create_table "billords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.string "remark", limit: 4000
    t.decimal "bills_id", precision: 38, null: false
    t.string "gno_billsch", limit: 40
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "denomination", limit: 15
    t.date "billingdate"
    t.string "accounttitle", limit: 1
  end

  create_table "bills", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "personname", limit: 30
    t.decimal "locas_id_bill", precision: 38, null: false
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "chrgs_id_bill", precision: 22
    t.decimal "crrs_id_bill", precision: 22
    t.string "termof", limit: 30
    t.string "amtround", limit: 2
    t.decimal "period", precision: 3
    t.string "ratejson", limit: 4000

    t.unique_constraint ["locas_id_bill", "crrs_id_bill"], name: "bills_ukya"
  end

  create_table "billschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "bills_id", precision: 38, null: false
    t.decimal "amt_sch", precision: 22, scale: 4
    t.decimal "processseq", precision: 38
    t.string "gno", limit: 40
    t.decimal "taxrate", precision: 2
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "accounttitle", limit: 1

    t.unique_constraint ["bills_id", "duedate"], name: "billschs_ukypaymentday"
  end

  create_table "blktbs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "pobjects_id_tbl", precision: 38
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.date "expiredate"
    t.datetime "updated_at"
    t.string "seltbls", limit: 4000
    t.string "contents", limit: 4000

    t.unique_constraint ["pobjects_id_tbl"], name: "blktbs_ukys1"
  end

  create_table "blkukys", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "seqno", precision: 38
    t.decimal "tblfields_id", precision: 38
    t.string "grp", limit: 10

    t.unique_constraint ["grp", "tblfields_id"], name: "blkukys_ukys1"
  end

  create_table "boxes", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "persons_id_upd", precision: 38
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.string "boxtype", limit: 20
    t.string "contents", limit: 4000
    t.decimal "depth", precision: 7, scale: 2
    t.date "expiredate"
    t.decimal "height", precision: 22, scale: 2
    t.decimal "outdepth", precision: 7, scale: 2
    t.decimal "outheight", precision: 7, scale: 2
    t.decimal "outwide", precision: 7, scale: 2
    t.string "remark", limit: 4000
    t.decimal "units_id_box", precision: 38
    t.decimal "wide", precision: 7, scale: 2
    t.string "code", limit: 50
    t.string "name", limit: 100

    t.unique_constraint ["code"], name: "boxes_ukys10"
  end

  create_table "buglists", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.datetime "cmpldate"
    t.string "cause", limit: 4000
    t.string "measures", limit: 4000
  end

  create_table "buttons", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "seqno", precision: 38
    t.string "caption", limit: 20
    t.string "title", limit: 30
    t.string "buttonicon", limit: 40
    t.string "onclickbutton", limit: 4000
    t.string "getgridparam", limit: 10
    t.string "editgridrow", limit: 4000
    t.string "aftershowform", limit: 4000
    t.string "code", limit: 50
  end

  create_table "calendars", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "locas_id", precision: 38, default: "0", null: false
    t.string "effectivestarttime", limit: 5
    t.string "effectiveendtime", limit: 5
    t.string "contents", limit: 4000
    t.date "targetdate"
  end

  create_table "chilscreens", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "screenfields_id", precision: 38
    t.decimal "screenfields_id_ch", precision: 38
    t.string "grp", limit: 10
  end

  create_table "chrgs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.datetime "created_at"
    t.date "expiredate"
    t.decimal "persons_id_chrg", precision: 38
    t.decimal "persons_id_upd", precision: 38
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
  end

  create_table "classlists", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40

    t.unique_constraint ["code"], name: "classlists_uky1"
  end

  create_table "conacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.decimal "processseq", precision: 38
    t.decimal "qty_stk", precision: 22, scale: 6
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.string "sno", limit: 50
    t.string "gno", limit: 40
    t.decimal "prjnos_id", precision: 38, default: "0", null: false
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "consumauto", limit: 1
  end

  create_table "coninsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.decimal "processseq", precision: 38
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
  end

  create_table "conords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.decimal "processseq", precision: 38
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.string "sno", limit: 50
    t.string "gno", limit: 40
    t.decimal "prjnos_id", precision: 38, default: "0", null: false
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "consumauto", limit: 1
  end

  create_table "conschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.decimal "processseq", precision: 38
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.string "sno", limit: 50
    t.string "gno", limit: 40
    t.decimal "prjnos_id", precision: 38, default: "0", null: false
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "consumauto", limit: 1
  end

  create_table "crrs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "code", limit: 50
    t.datetime "created_at"
    t.date "expiredate"
    t.string "name", limit: 100
    t.decimal "persons_id_upd", precision: 38
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.decimal "decimal", precision: 1

    t.unique_constraint ["code", "expiredate"], name: "crrs_uky1"
  end

  create_table "custactheads", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "invoiceno", limit: 50
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "amt", precision: 18, scale: 4
    t.datetime "isudate"
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "tax", precision: 38, scale: 4
    t.string "taxjson", limit: 4000
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.string "cno", limit: 40
    t.string "sno_custordhead", limit: 50
    t.string "cno_custordhead", limit: 40
    t.decimal "bills_id", precision: 38, default: "0", null: false
    t.string "packinglistnos", limit: 100
    t.string "gno_custord", limit: 40
    t.datetime "saledate"
  end

  create_table "custacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.string "itm_code_client", limit: 50
    t.datetime "saledate"
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.string "sno_custord", limit: 50
    t.string "cno_custord", limit: 50
    t.string "invoiceno", limit: 50
    t.string "cartonno", limit: 50
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "lotno", limit: 50
    t.string "packinglistno_custdlv", limit: 20
    t.decimal "taxrate", precision: 2
    t.decimal "tax", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.decimal "qty_stk", precision: 22, scale: 6
    t.datetime "duedate_custord"
    t.decimal "bills_id", precision: 38, default: "0", null: false
    t.decimal "transports_id", precision: 38, default: "0", null: false
    t.decimal "duration", precision: 38, scale: 2, default: "0.0", null: false
  end

  create_table "custdlvs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.string "itm_code_client", limit: 50
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.datetime "starttime"
    t.string "gno", limit: 40
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.string "cno_custinst", limit: 50
    t.datetime "depdate"
    t.string "cartonno", limit: 50
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "invoiceno", limit: 50
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "lotno", limit: 50
    t.string "dimension", limit: 20
    t.decimal "boxes_id_custdlv", precision: 38, default: "0", null: false
    t.decimal "weight", precision: 7, scale: 2
    t.string "packno", limit: 10
    t.decimal "units_id_weight", precision: 22, default: "0", null: false
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.decimal "taxrate", precision: 2
    t.decimal "tax", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.string "packinglistno", limit: 40
    t.string "sno_custinst", limit: 50
    t.string "cno_custord", limit: 50
    t.datetime "duedate_custord"
    t.decimal "duration", precision: 38, scale: 2, default: "0.0", null: false
    t.decimal "transports_id", precision: 38, default: "0", null: false
  end

  create_table "custinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.datetime "duedate"
    t.string "itm_code_client", limit: 50
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.datetime "starttime"
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.string "sno_custord", limit: 50
    t.string "cno_custord", limit: 50
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, default: "0", null: false
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.decimal "taxrate", precision: 2
    t.string "contractprice", limit: 1
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "tax", precision: 38, scale: 4
    t.decimal "transports_id", precision: 38, default: "0", null: false
    t.decimal "duration", precision: 38, scale: 2, default: "0.0", null: false

    t.unique_constraint ["sno"], name: "custinsts_ukysno"
  end

  create_table "custordheads", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.decimal "custs_id", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "tax", precision: 38, scale: 4
    t.string "cno", limit: 40
    t.decimal "crrs_id", precision: 22, null: false
    t.datetime "duedate"
    t.decimal "prjnos_id", precision: 38, default: "0", null: false
    t.string "contractprice", limit: 1
    t.decimal "custrcvplcs_id", precision: 38, default: "0", null: false
    t.decimal "chrgs_id", precision: 38, default: "0", null: false

    t.unique_constraint ["custs_id", "cno"], name: "custordheads_ukycno"
  end

  create_table "custords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "itm_code_client", limit: 50
    t.datetime "duedate"
    t.datetime "toduedate"
    t.datetime "isudate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "contents", limit: 4000
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38
    t.datetime "starttime"
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "sno_custsch", limit: 50
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.decimal "taxrate", precision: 2
    t.decimal "masterprice", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.decimal "transports_id", precision: 38, default: "0", null: false
    t.decimal "duration", precision: 38, scale: 2, default: "0.0", null: false

    t.unique_constraint ["custs_id", "cno"], name: "custords_ukycno"
    t.unique_constraint ["sno"], name: "custords_ukysno"
  end

  create_table "custprices", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "price", precision: 38, scale: 4
    t.decimal "custs_id", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "maxqty", precision: 22, scale: 6
    t.decimal "chrgs_id", precision: 38, null: false
    t.string "itm_code_client", limit: 50
    t.decimal "minqty", precision: 22, scale: 6
    t.string "ruleprice", limit: 1
    t.decimal "crrs_id_custprice", precision: 22, default: "0", null: false
  end

  create_table "custrcvplcs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.string "stktaking_proc", limit: 1
    t.decimal "locas_id_custrcvplc", precision: 38, null: false
    t.decimal "transports_id_custrcvplc", precision: 22, default: "0", null: false

    t.unique_constraint ["locas_id_custrcvplc"], name: "custrcvplcs_uky10"
  end

  create_table "custrets", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "cno_custact", limit: 50
    t.string "sno_custact", limit: 50
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.date "retdate"
    t.string "itm_code_client", limit: 50
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.string "lotno", limit: 50
    t.decimal "taxrate", precision: 2
    t.string "contractprice", limit: 1
    t.decimal "qty_stk", precision: 22, scale: 6, default: "0.0", null: false
    t.decimal "transports_id", precision: 38, default: "0", null: false
  end

  create_table "custs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "locas_id_cust", precision: 38, null: false
    t.decimal "chrgs_id_cust", precision: 38, null: false
    t.string "amtround", limit: 2
    t.string "autocreate_custact", limit: 1
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string "personname", limit: 30
    t.string "contractprice", limit: 1
    t.decimal "bills_id_cust", precision: 22, default: "0", null: false

    t.unique_constraint ["locas_id_cust"], name: "custs_uky10"
  end

  create_table "custschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.datetime "duedate"
    t.datetime "isudate"
    t.decimal "price", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.string "cno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.datetime "starttime"
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "amt_sch", precision: 22, scale: 4
    t.string "gno", limit: 40
    t.decimal "custrcvplcs_id", precision: 38, default: "0", null: false
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.decimal "tax", precision: 38, scale: 4
    t.decimal "taxrate", precision: 2
    t.string "contractprice", limit: 1
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.decimal "masterprice", precision: 38, scale: 4
    t.decimal "transports_id", precision: 38, default: "0", null: false
    t.decimal "duration", precision: 38, scale: 2, default: "0.0", null: false
    t.index ["opeitms_id"], name: "aaa"
    t.unique_constraint ["custs_id", "cno"], name: "custschs_uky20"
    t.unique_constraint ["sno"], name: "custschs_uky10"
    t.unique_constraint ["sno"], name: "custschs_ukysno"
  end

  create_table "custwhs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "lotno", limit: 50
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "itms_id", precision: 38, default: "0", null: false
    t.decimal "processseq", precision: 38
    t.datetime "starttime"
  end

  create_table "deflists", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.string "contents", limit: 4000
    t.string "hikisu", limit: 400
    t.decimal "classlists_id", precision: 38, null: false
  end

  create_table "detailcalendars", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "effectivestarttime", limit: 5
    t.string "effectiveendtime", limit: 5
    t.string "holiday", limit: 1
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.decimal "locas_id", precision: 38, null: false
    t.date "datevalue"
  end

  create_table "dlvacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "depdate"
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "sno", limit: 40
    t.string "orgtblname", limit: 30
    t.decimal "orgtblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "asstwhs_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
  end

  create_table "dlvinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.datetime "depdate"
    t.datetime "toduedate"
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "gno", limit: 40
    t.string "cno", limit: 40
    t.string "sno", limit: 40
    t.string "orgtblname", limit: 30
    t.decimal "orgtblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remark", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "asstwhs_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
  end

  create_table "dlvords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "confirm", limit: 1
    t.datetime "isudate"
    t.datetime "duedate"
    t.datetime "depdate"
    t.datetime "toduedate"
    t.decimal "locas_id_fm", precision: 38, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.string "gno", limit: 40
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "sno", limit: 40
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.decimal "custs_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
  end

  create_table "dlvschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.datetime "depdate"
    t.datetime "toduedate"
    t.decimal "locas_id_fm", precision: 38, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 40
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "qty_sch", precision: 22, scale: 6
  end

  create_table "dvsacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "gno", limit: 40
    t.decimal "prdacts_id_dvsact", precision: 22, default: "0", null: false
    t.datetime "cmpldate"
    t.datetime "commencementdate"
    t.decimal "facilities_id", precision: 22, default: "0", null: false
    t.datetime "duedate"
    t.datetime "starttime"
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
  end

  create_table "dvsinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "gno", limit: 40
    t.decimal "prdinsts_id_dvsinst", precision: 22, default: "0", null: false
    t.datetime "duedate"
    t.datetime "commencementdate"
    t.decimal "facilities_id", precision: 22, default: "0", null: false
    t.datetime "starttime"
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
  end

  create_table "dvsords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "gno", limit: 40
    t.decimal "prdords_id_dvsord", precision: 22, default: "0", null: false
    t.datetime "duedate"
    t.datetime "commencementdate"
    t.decimal "facilities_id", precision: 22, default: "0", null: false
    t.datetime "starttime"
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
  end

  create_table "dvsschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "facilities_id", precision: 22, default: "0", null: false
    t.datetime "starttime"
    t.decimal "prdschs_id_dvssch", precision: 22, default: "0", null: false
    t.datetime "duedate"
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
  end

  create_table "dymschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.datetime "isudate"
    t.datetime "starttime"
    t.datetime "duedate"
    t.datetime "toduedate"
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "sno", limit: 50
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.decimal "prjnos_id", precision: 38, null: false
    t.datetime "updated_at"
    t.decimal "processseq", precision: 38
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.decimal "itms_id_dym", precision: 22, default: "0", null: false
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
  end

  create_table "ercacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.datetime "duedate"
    t.datetime "starttime"
    t.string "processname", limit: 30
    t.decimal "fcoperators_id", precision: 22, default: "0", null: false
    t.datetime "cmpldate"
    t.datetime "commencementdate"
    t.decimal "prdacts_id_ercact", precision: 22, default: "0", null: false
  end

  create_table "ercinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.datetime "duedate"
    t.datetime "starttime"
    t.string "processname", limit: 30
    t.decimal "fcoperators_id", precision: 22, default: "0", null: false
    t.datetime "commencementdate"
    t.decimal "prdinsts_id_ercinst", precision: 22, default: "0", null: false
  end

  create_table "ercords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.datetime "duedate"
    t.datetime "starttime"
    t.string "processname", limit: 30
    t.decimal "fcoperators_id", precision: 22, default: "0", null: false
    t.datetime "commencementdate"
    t.decimal "prdords_id_ercord", precision: 22, default: "0", null: false
  end

  create_table "ercschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "prdschs_id_ercsch", precision: 22, default: "0", null: false
    t.datetime "duedate"
    t.datetime "starttime"
    t.decimal "fcoperators_id", precision: 22, default: "0", null: false
    t.string "processname", limit: 30
  end

  create_table "facilities", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.decimal "itms_id", precision: 38, default: "0", null: false
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false
    t.decimal "chrgs_id_facilitie", precision: 22, default: "0", null: false
  end

  create_table "facilitycalendars", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "facilities_id", precision: 22, null: false
    t.date "targetdate"
    t.string "effectivestarttime", limit: 5
    t.string "effectiveendtime", limit: 5
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "locas_id_pare", precision: 38, null: false
    t.string "notchange", limit: 1
  end

  create_table "fcoperators", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "priority", precision: 38
    t.decimal "chrgs_id_fcoperator", precision: 38, default: "0", null: false
    t.decimal "itms_id_fcoperator", precision: 22, default: "0", null: false
  end

  create_table "fieldcodes", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "pobjects_id_fld", precision: 38
    t.string "ftype", limit: 15
    t.decimal "fieldlength", precision: 38
    t.decimal "datascale", precision: 38
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.date "expiredate"
    t.datetime "updated_at"
    t.decimal "dataprecision", precision: 38
    t.decimal "seqno", precision: 38
    t.string "contents", limit: 4000
    t.index ["pobjects_id_fld", "id"], name: "fieldcodes_pobjects_id_fld", unique: true
    t.unique_constraint ["pobjects_id_fld"], name: "fieldcodes_uky10"
  end

  create_table "hcalendars", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "locas_id", precision: 38, null: false
    t.string "dayofweek", limit: 100
    t.string "holidays", limit: 4000
    t.string "workingday", limit: 4000
    t.string "effectivetime", limit: 4000

    t.unique_constraint ["locas_id", "expiredate"], name: "hcalendars_ukya"
  end

  create_table "importexcels", force: :cascade do |t|
    t.string "title"
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inamts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "starttime"
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "crrs_id", precision: 22, null: false
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "locas_id_in", precision: 22
    t.decimal "alloctbls_id", precision: 38
    t.string "inoutflg", limit: 20
  end

  create_table "incustwhs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "custrcvplcs_id", precision: 38, null: false
    t.datetime "duedate"
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty", precision: 22, scale: 6
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "alloctbls_id", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "inoutflg", limit: 20
  end

  create_table "inoutlotstks", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "srctblname", limit: 30
    t.decimal "srctblid", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "trngantts_id", precision: 38, default: "0", null: false
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
  end

  create_table "inspacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate"
    t.datetime "rcptdate"
    t.decimal "qty", precision: 18, scale: 4
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "shelfnos_id_act", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_purord", limit: 50
    t.string "sno_inspord", limit: 50
    t.decimal "qty_fail", precision: 22, scale: 5
    t.decimal "reasons_id", precision: 22
  end

  create_table "inspinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "gno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_puract", limit: 50
    t.decimal "reasons_id", precision: 22
    t.decimal "shelfnos_id_to", precision: 38, null: false
  end

  create_table "inspords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "itm_code_client", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_purord", limit: 50
    t.decimal "reasons_id", precision: 22
    t.decimal "itms_id", precision: 38
    t.decimal "processseq", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "shelfnos_id_fm", precision: 22
  end

  create_table "inspschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 40
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_fail", precision: 22, scale: 5
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contract_price", limit: 1
    t.string "gno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "locas_id_to", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instks", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "starttime"
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_in", precision: 38
    t.string "inoutflg", limit: 20
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
  end

  create_table "itms", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 50
    t.string "name", limit: 100
    t.decimal "units_id", precision: 38
    t.string "std", limit: 50
    t.string "model", limit: 50
    t.string "material", limit: 50
    t.string "design", limit: 50
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "classlists_id", precision: 38
    t.string "taxflg", limit: 1

    t.unique_constraint ["code"], name: "itms_ukys1"
  end

  create_table "linkcusts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "amt_src", precision: 22, scale: 5
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.string "srctblname", limit: 30
    t.decimal "srctblid", precision: 38
    t.decimal "qty_src", precision: 38, scale: 6
    t.decimal "trngantts_id", precision: 38, null: false
  end

  create_table "linkheads", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "tblname", limit: 30
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.decimal "tblid", precision: 38
    t.decimal "amt_src", precision: 22, scale: 5
    t.decimal "qty_src", precision: 38, scale: 6
  end

  create_table "linktbls", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.string "srctblname", limit: 30
    t.decimal "srctblid", precision: 38
    t.decimal "qty_src", precision: 38, scale: 6
    t.decimal "trngantts_id", precision: 38, null: false
    t.decimal "amt_src", precision: 22, scale: 5

    t.unique_constraint ["srctblname", "srctblid", "tblname", "tblid", "trngantts_id"], name: "linktbls_ukya"
  end

  create_table "locas", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 40
    t.string "name", limit: 100
    t.string "abbr", limit: 50
    t.string "zip", limit: 10
    t.string "country", limit: 20
    t.string "prfct", limit: 20
    t.string "addr1", limit: 50
    t.string "addr2", limit: 50
    t.string "tel", limit: 20
    t.string "fax", limit: 20
    t.string "mail", limit: 20
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"

    t.unique_constraint ["code", "expiredate"], name: "locas_23_uk"
  end

  create_table "lotstkhists", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "itms_id", precision: 38, null: false
    t.datetime "starttime"
    t.decimal "processseq", precision: 38
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty", precision: 22, scale: 6
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "shelfnos_id", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "metcounter", precision: 5
    t.decimal "qty_real", precision: 22, scale: 6
    t.decimal "qty_rejection", precision: 22, scale: 2, default: "0.0", null: false
    t.string "stktakingproc", limit: 1
  end

  create_table "mkacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.decimal "runtime", precision: 2
    t.datetime "isudate"
    t.string "prdpurshp", limit: 5
    t.datetime "rcptdate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "locas_id_to", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
  end

  create_table "mkbillinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "isudate"
    t.decimal "custs_id", precision: 38, null: false
    t.string "contents", limit: 4000
    t.datetime "cmpldate"
    t.decimal "runtime", precision: 2
    t.string "result_f", limit: 1
    t.decimal "incnt", precision: 38
    t.decimal "outcnt", precision: 38
    t.decimal "inamt", precision: 38, scale: 4
    t.decimal "outamt", precision: 38, scale: 4
    t.decimal "skipcnt", precision: 38
    t.decimal "skipqty", precision: 22, scale: 6
    t.decimal "skipamt", precision: 38, scale: 4
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "bills_id", precision: 38, null: false
    t.string "termof", limit: 30
  end

  create_table "mkordopeitms", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "mkords_id", precision: 22, null: false
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.string "update_ip", limit: 40
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.datetime "toduedate"
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
  end

  create_table "mkordorgs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "consumminqty", precision: 22, scale: 6
    t.decimal "consumchgoverqty", precision: 22, scale: 6
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "mkprdpurords_id", precision: 22, null: false
    t.decimal "qty_require", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate"
    t.datetime "toduedate"
    t.decimal "packqty", precision: 18, scale: 2
    t.string "contents", limit: 4000
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.datetime "starttime"
    t.decimal "locas_id", precision: 38, null: false
    t.decimal "processseq", precision: 38
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "consumunitqty", precision: 22, scale: 6
    t.decimal "mlevel", precision: 3
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "incnt", precision: 38
    t.decimal "qty_handover", precision: 22, scale: 6
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false

    t.unique_constraint ["itms_id", "locas_id", "processseq", "shelfnos_id_to", "mkprdpurords_id", "duedate"], name: "mkordorgs_uky10"
  end

  create_table "mkords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "cmpldate"
    t.string "result_f", limit: 1
    t.decimal "runtime", precision: 2
    t.datetime "isudate"
    t.string "orgtblname", limit: 30
    t.string "confirm", limit: 1
    t.string "manual", limit: 1
    t.decimal "incnt", precision: 38
    t.decimal "inqty", precision: 22, scale: 6
    t.decimal "inamt", precision: 38, scale: 4
    t.decimal "outcnt", precision: 38
    t.decimal "outqty", precision: 22, scale: 6
    t.decimal "outamt", precision: 38, scale: 4
    t.decimal "skipcnt", precision: 38
    t.decimal "skipqty", precision: 22, scale: 6
    t.decimal "skipamt", precision: 38, scale: 4
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.string "remark", limit: 4000
    t.string "message_code", limit: 256
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "updated_at"
    t.string "sno_org", limit: 50
    t.string "sno_pare", limit: 50
    t.string "tblname", limit: 30
    t.string "paretblname", limit: 30
    t.string "itm_code_pare", limit: 50
    t.string "loca_code_org", limit: 50
    t.datetime "duedate_trn"
    t.datetime "duedate_pare"
    t.datetime "duedate_org"
    t.decimal "processseq_org", precision: 22
    t.decimal "processseq_pare", precision: 38
    t.string "itm_code_trn", limit: 50
    t.string "itm_code_org", limit: 50
    t.string "itm_name_org", limit: 100
    t.string "itm_name_trn", limit: 100
    t.string "itm_name_pare", limit: 100
    t.string "person_code_chrg_org", limit: 50
    t.string "person_code_chrg_pare", limit: 50
    t.string "person_code_chrg_trn", limit: 50
    t.string "person_name_chrg_org", limit: 100
    t.string "person_name_chrg_pare", limit: 100
    t.string "person_name_chrg_trn", limit: 100
    t.string "loca_code_pare", limit: 50
    t.string "loca_code_trn", limit: 50
    t.string "loca_name_trn", limit: 100
    t.string "loca_name_pare", limit: 100
    t.decimal "processseq_trn", precision: 38
    t.string "loca_name_org", limit: 100
    t.string "loca_name_to_trn", limit: 100
    t.datetime "starttime_trn"
  end

  create_table "mkordterms", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.datetime "duedate"
    t.string "contents", limit: 4000
    t.decimal "locas_id", precision: 38, null: false
    t.decimal "processseq", precision: 38
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.decimal "mlevel", precision: 3
    t.decimal "mkprdpurords_id", precision: 22, default: "0", null: false
    t.date "optfixodate"
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false
    t.string "prdpurordauto", limit: 1
    t.decimal "packqty", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "maxqty", precision: 22, scale: 6, default: "0.0", null: false
  end

  create_table "mkordtmpfs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "qty_require", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate"
    t.datetime "toduedate"
    t.decimal "packqty", precision: 18, scale: 2
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "parenum", precision: 22, scale: 6
    t.decimal "chilnum", precision: 22, scale: 6
    t.decimal "itms_id_pare", precision: 38, null: false
    t.decimal "processseq_pare", precision: 38
    t.decimal "mlevel", precision: 3
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty_handover", precision: 22, scale: 6
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.decimal "incnt", precision: 38
    t.decimal "consumminqty", precision: 22, scale: 6
    t.decimal "consumchgoverqty", precision: 22, scale: 6
    t.decimal "consumunitqty", precision: 22, scale: 6
    t.decimal "mkprdpurords_id", precision: 22, default: "0", null: false
    t.datetime "starttime"
    t.decimal "shelfnos_id_trn", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_pare", precision: 22, default: "0", null: false
    t.decimal "locas_id_trn", precision: 38, default: "0", null: false
    t.decimal "itms_id_trn", precision: 38, default: "0", null: false
    t.decimal "shelfnos_id_to_pare", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_to_trn", precision: 22, default: "0", null: false
    t.decimal "processseq_trn", precision: 38
    t.decimal "locas_id_to_trn", precision: 22, default: "0", null: false
    t.decimal "locas_id_pare", precision: 38, default: "0", null: false
    t.date "optfixodate"
  end

  create_table "mkpayinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "suppliers_id", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.datetime "cmpldate"
    t.decimal "runtime", precision: 2
    t.string "result_f", limit: 1
    t.decimal "incnt", precision: 38
    t.decimal "outcnt", precision: 38
    t.decimal "inamt", precision: 38, scale: 4
    t.decimal "outamt", precision: 38, scale: 4
    t.decimal "skipcnt", precision: 38
    t.decimal "skipqty", precision: 22, scale: 6
    t.decimal "skipamt", precision: 38, scale: 4
    t.decimal "payments_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.string "termof", limit: 30
  end

  create_table "mkprdpurords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "processseq_org", precision: 22
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "isudate"
    t.string "tblname", limit: 30
    t.datetime "cmpldate"
    t.decimal "runtime", precision: 2
    t.string "result_f", limit: 1
    t.string "message_code", limit: 256
    t.string "orgtblname", limit: 30
    t.string "manual", limit: 1
    t.decimal "processseq_pare", precision: 38
    t.string "sno_org", limit: 50
    t.datetime "duedate_trn"
    t.string "confirm", limit: 1
    t.decimal "incnt", precision: 38
    t.decimal "outcnt", precision: 38
    t.decimal "inqty", precision: 22, scale: 6
    t.decimal "outqty", precision: 22, scale: 6
    t.decimal "inamt", precision: 38, scale: 4
    t.decimal "outamt", precision: 38, scale: 4
    t.decimal "skipcnt", precision: 38
    t.decimal "skipqty", precision: 22, scale: 6
    t.decimal "skipamt", precision: 38, scale: 4
    t.string "itm_code_pare", limit: 50
    t.string "itm_code_trn", limit: 50
    t.string "sno_pare", limit: 50
    t.datetime "duedate_pare"
    t.string "itm_code_org", limit: 50
    t.string "itm_name_org", limit: 100
    t.string "itm_name_trn", limit: 100
    t.string "itm_name_pare", limit: 100
    t.string "person_code_chrg_org", limit: 50
    t.string "person_code_chrg_pare", limit: 50
    t.string "person_code_chrg_trn", limit: 50
    t.string "person_name_chrg_org", limit: 100
    t.string "person_name_chrg_pare", limit: 100
    t.string "person_name_chrg_trn", limit: 100
    t.string "loca_code_pare", limit: 50
    t.string "loca_code_trn", limit: 50
    t.string "loca_name_trn", limit: 100
    t.string "loca_name_pare", limit: 100
    t.string "paretblname", limit: 30
    t.datetime "duedate_org"
    t.datetime "starttime_trn"
    t.decimal "processseq_trn", precision: 38
    t.string "loca_code_org", limit: 50
    t.string "loca_name_org", limit: 100
    t.string "sno_trn", limit: 50
    t.string "shelfno_code_org", limit: 50
    t.string "shelfno_code_pare", limit: 50
    t.string "shelfno_code_trn", limit: 50
    t.string "shelfno_name_org", limit: 100
    t.string "shelfno_name_pare", limit: 100
    t.string "shelfno_name_trn", limit: 100
  end

  create_table "mkshps", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "cmpldate"
    t.string "result_f", limit: 1
    t.decimal "runtime", precision: 2
    t.datetime "isudate"
    t.string "confirm", limit: 1
    t.string "manual", limit: 1
    t.string "orgtblname", limit: 30
    t.string "sno_org", limit: 50
    t.decimal "itms_id_org", precision: 38, null: false
    t.decimal "locas_id_org", precision: 38, null: false
    t.string "paretblname", limit: 30
    t.string "sno_pare", limit: 50
    t.decimal "itms_id_pare", precision: 38, null: false
    t.decimal "locas_id_pare", precision: 38, null: false
    t.string "tblname", limit: 30
    t.decimal "incnt", precision: 38
    t.decimal "inqty", precision: 22, scale: 6
    t.decimal "inamt", precision: 38, scale: 4
    t.decimal "outcnt", precision: 38
    t.decimal "outqty", precision: 22, scale: 6
    t.decimal "outamt", precision: 38, scale: 4
    t.decimal "skipcnt", precision: 38
    t.decimal "skipqty", precision: 22, scale: 6
    t.decimal "skipamt", precision: 38, scale: 4
    t.string "remark", limit: 4000
    t.string "message_code", limit: 256
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "duedate_pare"
  end

  create_table "mnfacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "gno", limit: 40
  end

  create_table "mnfinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "gno", limit: 40
  end

  create_table "mnfords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "gno", limit: 40
  end

  create_table "mnfschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "gno", limit: 40
  end

  create_table "movacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "locas_id_cause", precision: 22, null: false
    t.decimal "qty_stk_fm", precision: 22, scale: 2
    t.decimal "qty_stk_to", precision: 22, scale: 2
    t.decimal "qty_rejection_fm", precision: 22, scale: 2
    t.decimal "qty_rejection_to", precision: 22, scale: 2
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.datetime "cmpldate"
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.string "reason", limit: 20
  end

  create_table "ndfcts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "changeoverlt", precision: 3, scale: 2
    t.decimal "facilities_id_ndfct", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "priority", precision: 38
    t.decimal "duration", precision: 38, scale: 2
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "chilnum", precision: 22, scale: 6
    t.decimal "maxqty", precision: 22, scale: 6
    t.decimal "requireop", precision: 3, default: "0", null: false
    t.string "unitofduration", limit: 4
  end

  create_table "nditms", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "opeitms_id", precision: 38
    t.decimal "itms_id_nditm", precision: 38
    t.decimal "processseq_nditm", precision: 38
    t.decimal "parenum", precision: 22, scale: 6
    t.decimal "chilnum", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "consumunitqty", precision: 22, scale: 6
    t.string "contents", limit: 4000
    t.string "byproduct", limit: 1
    t.decimal "consumminqty", precision: 22, scale: 6
    t.decimal "consumchgoverqty", precision: 22, scale: 6
    t.string "consumtype", limit: 10
    t.decimal "utilization", precision: 5, scale: 2
    t.decimal "cost", precision: 38, scale: 4
    t.decimal "packqtyfacility", precision: 7, scale: 2, default: "0.0"
    t.decimal "changeoverlt", precision: 5, scale: 2
    t.decimal "durationfacility", precision: 5, scale: 2
    t.decimal "postprocessinglt", precision: 5, scale: 2
    t.decimal "changeoverop", precision: 2
    t.decimal "postprocessingop", precision: 2, default: "0", null: false
    t.decimal "requireop", precision: 3, default: "0", null: false
    t.string "unitofdvs", limit: 4
  end

  create_table "opeitms", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "processseq", precision: 38
    t.decimal "priority", precision: 38
    t.decimal "itms_id", precision: 38
    t.decimal "packqty", precision: 18, scale: 2
    t.decimal "duration", precision: 38, scale: 2
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remark", limit: 4000
    t.string "operation", limit: 40
    t.decimal "maxqty", precision: 22, scale: 6
    t.decimal "safestkqty", precision: 22
    t.string "autocreate_act", limit: 1
    t.string "autocreate_inst", limit: 1
    t.string "contents", limit: 4000
    t.decimal "esttosch", precision: 38
    t.string "mold", limit: 1
    t.decimal "boxes_id", precision: 38
    t.decimal "prjalloc_flg", precision: 38
    t.string "unitofduration", limit: 4
    t.decimal "autoinst_p", precision: 3
    t.decimal "autoact_p", precision: 3
    t.string "chkinst_proc", limit: 1
    t.string "chkord_proc", limit: 3
    t.decimal "optfixoterm", precision: 5, scale: 2
    t.string "optfixflg", limit: 1
    t.decimal "shelfnos_id_to_opeitm", precision: 38, default: "0", null: false
    t.decimal "shelfnos_id_opeitm", precision: 22, default: "0", null: false
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.decimal "units_id_case_prdpur", precision: 38, default: "0", null: false
    t.string "consumauto", limit: 1
    t.string "prdpur", limit: 5
    t.string "shpordauto", limit: 1
    t.string "prdpurordauto", limit: 1
    t.string "itmtype", limit: 1
    t.decimal "changeoverlt", precision: 5, scale: 2, default: "0.0"
    t.decimal "changeoverop", precision: 2, default: "0"
    t.decimal "utilizationchangeover", precision: 5, scale: 2, default: "0.0"
    t.decimal "units_id_weight", precision: 22, default: "0", null: false
    t.decimal "units_id_size", precision: 22, default: "0", null: false
    t.decimal "weight", precision: 7, scale: 2, default: "0.0", null: false
    t.decimal "length", precision: 38, scale: 6, default: "0.0", null: false
    t.decimal "wide", precision: 7, scale: 2, default: "0.0", null: false
    t.decimal "deth", precision: 38, scale: 6, default: "0.0", null: false
    t.decimal "datascale", precision: 38, default: "0", null: false
    t.string "lotnoproc", limit: 3
    t.string "shuffleflg", limit: 1
    t.string "shuffleloca", limit: 1
    t.string "stktakingproc", limit: 1
    t.string "acceptanceproc", limit: 30
    t.string "packnoproc", limit: 1
    t.decimal "expireterm", precision: 5, default: "0", null: false

    t.unique_constraint ["itms_id", "id"], name: "opeitms_uky3"
    t.unique_constraint ["itms_id", "processseq", "priority"], name: "opeitms_uky1"
    t.unique_constraint ["itms_id", "processseq", "shelfnos_id_opeitm"], name: "opeitms_uky2"
  end

  create_table "outamts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "starttime"
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "crrs_id", precision: 22, null: false
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "locas_id_out", precision: 22
    t.decimal "alloctbls_id", precision: 38
    t.string "inoutflg", limit: 20
  end

  create_table "outstks", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "starttime"
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "shelfnos_id_out", precision: 22
    t.string "inoutflg", limit: 20
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
  end

  create_table "payacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.decimal "chrgs_id", precision: 38, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "cash", precision: 22, scale: 2
    t.decimal "taxrate", precision: 2
    t.decimal "payments_id", precision: 38, default: "0", null: false
    t.string "denomination", limit: 15
    t.date "paymentdate"
    t.string "accounttitle", limit: 1
    t.string "sno_payord", limit: 50

    t.unique_constraint ["sno"], name: "payacts_ukysno"
  end

  create_table "payests", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.datetime "starttime"
    t.decimal "payments_id", precision: 38, null: false
  end

  create_table "payinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.decimal "chrgs_id", precision: 38, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.string "remark", limit: 4000
    t.decimal "payments_id", precision: 38, default: "0", null: false
    t.decimal "taxrate", precision: 2
    t.string "denomination", limit: 15
    t.string "gno", limit: 40
    t.string "accounttitle", limit: 1
  end

  create_table "payments", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "personname", limit: 30
    t.decimal "locas_id_payment", precision: 38, null: false
    t.decimal "chrgs_id_payment", precision: 22, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "crrs_id_payment", precision: 22, default: "0", null: false
    t.string "termof", limit: 30
    t.decimal "period", precision: 3
    t.string "ratejson", limit: 4000
    t.string "amtround", limit: 2

    t.unique_constraint ["locas_id_payment", "crrs_id_payment"], name: "payments_ukya"
  end

  create_table "payords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.decimal "chrgs_id", precision: 38, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "gno", limit: 40
    t.decimal "taxrate", precision: 2
    t.decimal "payments_id", precision: 38, default: "0", null: false
    t.string "denomination", limit: 15
    t.date "billingdate"
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
    t.string "accounttitle", limit: 1
  end

  create_table "payschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "tax", precision: 38, scale: 4
    t.decimal "chrgs_id", precision: 38, null: false
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.string "remark", limit: 4000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "amt_sch", precision: 22, scale: 4
    t.string "gno", limit: 40
    t.decimal "payments_id", precision: 38, default: "0", null: false
    t.decimal "taxrate", precision: 2
    t.string "accounttitle", limit: 1
  end

  create_table "personcalendars", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "persons_id", precision: 38, null: false
    t.decimal "locas_id_pare", precision: 38, null: false
    t.date "targetdate"
    t.string "effectivestarttime", limit: 5
    t.string "effectiveendtime", limit: 5
  end

  create_table "persons", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 10
    t.string "name", limit: 50
    t.decimal "usrgrps_id", precision: 38
    t.decimal "sects_id", precision: 38
    t.decimal "scrlvs_id", precision: 38
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", limit: 40
    t.decimal "wage", precision: 22, scale: 3

    t.unique_constraint ["code"], name: "persons_16_uk"
    t.unique_constraint ["email"], name: "persons_uky1"
  end

  create_table "pobjects", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.date "expiredate"
    t.datetime "updated_at"
    t.string "code", limit: 50
    t.string "contents", limit: 4000
    t.string "objecttype", limit: 19
    t.index ["code", "objecttype"], name: "pobjects_ukys1", unique: true
  end

  create_table "pobjgrps", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "pobjects_id", precision: 38
    t.decimal "usrgrps_id", precision: 38
    t.string "name", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.date "expiredate"
    t.datetime "updated_at"

    t.unique_constraint ["usrgrps_id", "name", "expiredate"], name: "pobjgrps_uky1"
  end

  create_table "prdacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "cmpldate"
    t.string "sno", limit: 50
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "lotno", limit: 50
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "qty_stk", precision: 22, scale: 6
    t.string "sno_prdord", limit: 50
    t.string "sno_prdinst", limit: 50
    t.string "cno_prdinst", limit: 50
    t.string "packno", limit: 10
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false
    t.datetime "starttime"
  end

  create_table "prdests", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.datetime "isudate"
    t.datetime "starttime"
    t.decimal "processseq_pare", precision: 38
    t.datetime "duedate"
    t.datetime "toduedate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "tax", precision: 38, scale: 4
    t.datetime "updated_at"
    t.string "sno", limit: 40
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.decimal "chrgs_id", precision: 38, null: false
  end

  create_table "prdinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "qty", precision: 22, scale: 6
    t.string "sno", limit: 50
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_prdord", limit: 50
    t.decimal "shelfnos_id_to", precision: 38
    t.datetime "starttime"
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false
    t.string "cmplflg", limit: 1
  end

  create_table "prdords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "confirm", limit: 1
    t.datetime "isudate"
    t.datetime "starttime"
    t.datetime "duedate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "chrgs_id", precision: 38
    t.string "sno", limit: 50
    t.string "gno", limit: 40
    t.decimal "prjnos_id", precision: 38
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.datetime "toduedate"
    t.decimal "persons_id_upd", precision: 38
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "opeitms_id", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false
    t.string "cmplflg", limit: 1
  end

  create_table "prdreplyinputs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.datetime "isudate"
    t.decimal "qty", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_prdord", limit: 50
    t.string "sno_prdinst", limit: 50
    t.date "replydate"
    t.string "cno", limit: 40
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false
  end

  create_table "prdrets", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.date "retdate"
    t.decimal "locas_id_fm", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_prdact", limit: 50
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
  end

  create_table "prdrsltinputs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.datetime "cmpldate"
    t.decimal "qty", precision: 22, scale: 6
    t.string "cno", limit: 40
    t.string "sno_prdord", limit: 50
    t.string "sno_prdinst", limit: 50
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_prdreplyinput", limit: 50
  end

  create_table "prdschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "starttime"
    t.datetime "isudate"
    t.datetime "duedate"
    t.datetime "toduedate"
    t.datetime "updated_at"
    t.string "sno", limit: 50
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "created_at"
    t.string "update_ip", limit: 40
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "gno", limit: 40
    t.decimal "shelfnos_id", precision: 38, default: "0", null: false
  end

  create_table "prdstrs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "starttime"
    t.decimal "qty", precision: 22, scale: 6
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_prdord", limit: 50
  end

  create_table "pricemsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "tblname", limit: 30
    t.date "expiredate"
    t.decimal "maxqty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amtdecimal", precision: 38
    t.string "amtround", limit: 2
    t.string "contract_price", limit: 1
    t.string "rule_price", limit: 1
    t.string "over_f", limit: 1
    t.string "itm_code_client", limit: 50
    t.string "contents", limit: 4000
    t.string "update_ip", limit: 40
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "locas_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "processseq", precision: 38
  end

  create_table "prjnos", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 100
    t.string "code", limit: 50
    t.decimal "prjnos_id_chil", precision: 38, default: "0", null: false
    t.string "contents", limit: 4000
    t.decimal "priority", precision: 38, default: "0", null: false
  end

  create_table "processcontrols", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "tblname", limit: 30
    t.decimal "seqno", precision: 38
    t.string "destblname", limit: 30
    t.string "segment", limit: 10
    t.string "rubycode", limit: 4000
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "expiredate"
  end

  create_table "processreqs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.string "result_f", limit: 1
    t.string "update_ip", limit: 40
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38
    t.string "reqparams", limit: 8192
    t.decimal "seqno", precision: 38
  end

  create_table "puractheads", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "invoiceno", limit: 50
    t.string "taxjson", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.decimal "tax", precision: 38, scale: 4
    t.decimal "crrs_id", precision: 22, null: false
    t.decimal "chrgs_id", precision: 38, default: "0", null: false
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
  end

  create_table "puracts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.datetime "rcptdate"
    t.string "cno", limit: 40
    t.string "itm_code_client", limit: 50
    t.string "lotno", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_purinst", limit: 50
    t.string "sno_purord", limit: 50
    t.string "sno_purdlv", limit: 50
    t.string "cno_purdlv", limit: 50
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "shelfnos_id_to", precision: 38
    t.string "packno", limit: 10
    t.decimal "amt", precision: 18, scale: 4
    t.string "invoiceno", limit: 50
    t.string "cartonno", limit: 50
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.string "gno", limit: 40
    t.decimal "taxrate", precision: 2
    t.string "sno_purreplyinput", limit: 50
    t.decimal "tax", precision: 38, scale: 4
    t.decimal "price", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.decimal "masterprice", precision: 38, scale: 4
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
  end

  create_table "purdlvs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "depdate"
    t.string "itm_code_client", limit: 50
    t.string "sno", limit: 50
    t.string "cno", limit: 40
    t.string "gno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_purinst", limit: 50
    t.string "cno_purinst", limit: 50
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.string "sno_purord", limit: 50
    t.string "cno_purord", limit: 50
    t.string "sno_purreplyinput", limit: 50
    t.string "cno_purreplyinput", limit: 50
    t.string "invoiceno", limit: 50
    t.string "cartonno", limit: 50
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.string "lotno", limit: 50
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.string "contents", limit: 4000
    t.decimal "masterprice", precision: 38, scale: 4
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
  end

  create_table "purests", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "confirm", limit: 1
    t.decimal "processseq_pare", precision: 38
    t.datetime "isudate"
    t.datetime "starttime"
    t.datetime "duedate"
    t.datetime "toduedate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
  end

  create_table "purinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "duedate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "itm_code_client", limit: 50
    t.string "sno", limit: 50
    t.string "cno", limit: 40
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sno_purord", limit: 50
    t.decimal "shelfnos_id_to", precision: 38
    t.datetime "starttime"
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.string "gno", limit: 40
    t.string "cmplflg", limit: 1
    t.decimal "taxrate", precision: 2
    t.decimal "tax", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.decimal "masterprice", precision: 38, scale: 4
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
  end

  create_table "purords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 50, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.datetime "duedate"
    t.datetime "isudate"
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "amt", precision: 18, scale: 4
    t.datetime "toduedate"
    t.decimal "persons_id_upd", precision: 38
    t.date "expiredate"
    t.decimal "price", precision: 38, scale: 4
    t.string "confirm", limit: 1
    t.decimal "prjnos_id", precision: 38
    t.decimal "chrgs_id", precision: 38
    t.string "gno", limit: 40, null: false
    t.string "itm_code_client", limit: 50
    t.datetime "starttime"
    t.decimal "opeitms_id", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.string "cmplflg", limit: 1
    t.decimal "taxrate", precision: 2
    t.decimal "masterprice", precision: 38, scale: 4
    t.decimal "tax", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.string "contents", limit: 4000
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
  end

  create_table "purreplyinputs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.decimal "qty", precision: 22, scale: 6
    t.string "sno", limit: 50
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "replydate"
    t.string "sno_purinst", limit: 50
    t.string "cno", limit: 40
    t.string "sno_purord", limit: 50
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "masterprice", precision: 38, scale: 4
  end

  create_table "purrets", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.date "retdate"
    t.decimal "locas_id_fm", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "crrs_id", precision: 22, null: false
    t.string "sno_puract", limit: 50
    t.string "lotno", limit: 50
    t.decimal "taxrate", precision: 2
    t.decimal "tax", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
  end

  create_table "purrsltinputs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.datetime "isudate"
    t.datetime "rcptdate"
    t.decimal "qty", precision: 22, scale: 6
    t.string "sno", limit: 50
    t.string "sno_purord", limit: 50
    t.string "sno_purinst", limit: 50
    t.string "cno_purinst", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "crrs_id", precision: 22, null: false
    t.string "sno_purreplyinput", limit: 50
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.string "invoiceno", limit: 50
    t.string "cartonno", limit: 50
  end

  create_table "purschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.datetime "starttime"
    t.datetime "duedate"
    t.datetime "toduedate"
    t.decimal "price", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "opeitms_id", precision: 38
    t.decimal "shelfnos_id_to", precision: 38
    t.decimal "chrgs_id", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "amt_sch", precision: 22, scale: 4
    t.string "gno", limit: 40
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.string "itm_code_client", limit: 50
    t.decimal "tax", precision: 38, scale: 4
    t.decimal "taxrate", precision: 2
    t.string "contents", limit: 4000
    t.string "contractprice", limit: 1
    t.decimal "masterprice", precision: 38, scale: 4
    t.decimal "suppliers_id", precision: 22, default: "0", null: false
  end

  create_table "reasons", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "expiredate"
  end

  create_table "rejections", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "locas_id_cause", precision: 22, null: false
    t.decimal "qty_rejection", precision: 22, scale: 2
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.string "contents", limit: 4000
    t.decimal "opeitms_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.decimal "shelfnos_id_to", precision: 38, null: false
    t.decimal "amt", precision: 18, scale: 4, default: "0.0", null: false
    t.date "acpdate"
    t.string "reason", limit: 20
  end

  create_table "reports", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "filename", limit: 50
    t.decimal "screens_id", precision: 38
    t.decimal "usrgrps_id", precision: 38
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "pobjects_id_rep", precision: 38
    t.string "contents", limit: 4000
  end

  create_table "rubycodings", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "codel", limit: 100
    t.string "contents", limit: 4000
    t.decimal "pobjects_id", precision: 38
    t.string "rubycode", limit: 4000
    t.string "hikisu", limit: 400

    t.unique_constraint ["codel", "expiredate"], name: "rubycodings_ukys1"
  end

  create_table "rules", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "contents", limit: 4000
    t.string "code", limit: 50
    t.string "objecttype", limit: 19
  end

  create_table "schofmkords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "trngantts_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "processseq", precision: 38
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.datetime "created_at"
    t.decimal "mkprdpurords_id", precision: 22, default: "0", null: false
  end

  create_table "screenfields", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "screens_id", precision: 38
    t.string "selection", limit: 1
    t.string "hideflg", limit: 1
    t.decimal "seqno", precision: 38
    t.integer "rowpos"
    t.integer "colpos"
    t.integer "width"
    t.string "type", limit: 12
    t.integer "dataprecision"
    t.integer "datascale"
    t.string "indisp", limit: 1
    t.string "editable", limit: 1
    t.decimal "maxvalue", precision: 38
    t.decimal "minvalue", precision: 22, scale: 6
    t.decimal "edoptsize", precision: 38
    t.decimal "edoptmaxlength", precision: 38
    t.integer "edoptrow"
    t.integer "edoptcols"
    t.string "edoptvalue", limit: 800
    t.string "sumkey", limit: 1
    t.string "crtfield", limit: 100
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "pobjects_id_sfd", precision: 38
    t.decimal "tblfields_id", precision: 38
    t.string "paragraph", limit: 50
    t.string "formatter", limit: 4000
    t.string "contents", limit: 4000
    t.string "subindisp", limit: 512

    t.unique_constraint ["paragraph", "id"], name: "screenfields_uky2"
    t.unique_constraint ["pobjects_id_sfd", "screens_id"], name: "screenfields_uky3"
    t.unique_constraint ["screens_id", "pobjects_id_sfd"], name: "screenfields_uky1"
  end

  create_table "screens", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "strselect", limit: 4000
    t.string "strwhere", limit: 4000
    t.string "strgrouporder", limit: 4000
    t.string "ymlcode", limit: 4000
    t.string "cdrflayout", limit: 10
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "pobjects_id_scr", precision: 38
    t.decimal "pobjects_id_view", precision: 38
    t.decimal "pobjects_id_sgrp", precision: 38
    t.decimal "seqno", precision: 38
    t.decimal "rows_per_page", precision: 38
    t.string "rowlist", limit: 30
    t.decimal "height", precision: 22, scale: 2
    t.string "form_ps", limit: 4000
    t.decimal "scrlvs_id", precision: 38
    t.string "contents", limit: 4000
    t.string "strorder", limit: 4000
    t.decimal "width", precision: 38

    t.unique_constraint ["pobjects_id_scr"], name: "screens_ukys1"
  end

  create_table "scrlvs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 50
    t.datetime "created_at"
    t.date "expiredate"
    t.string "level1", limit: 1
    t.decimal "persons_id_upd", precision: 38
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.string "update_ip", limit: 4
    t.datetime "updated_at"

    t.unique_constraint ["code", "expiredate"], name: "scrlvs_23_uk"
  end

  create_table "sects", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "locas_id_sect", precision: 38
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "locas_id_pare", precision: 38, default: "0", null: false
  end

  create_table "shelfnos", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 50
    t.decimal "locas_id_shelfno", precision: 38
    t.string "name", limit: 100
    t.string "update_ip", limit: 40
    t.decimal "locas_id_alloc", precision: 22, default: "0", null: false

    t.unique_constraint ["locas_id_shelfno", "code"], name: "shelfnos_ukys10"
  end

  create_table "shpacts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 50
    t.datetime "isudate"
    t.string "gno", limit: 40
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.string "cno", limit: 40
    t.string "cartonno", limit: 50
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "box", limit: 50
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.datetime "created_at"
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.decimal "processseq", precision: 38
    t.decimal "itms_id", precision: 38, null: false
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "crrs_id", precision: 22, null: false
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "qty_real", precision: 22, scale: 6
    t.datetime "rcptdate"
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.decimal "qty_shortage", precision: 22, scale: 5
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
    t.decimal "taxrate", precision: 2
    t.string "contractprice", limit: 1
    t.decimal "tax", precision: 38, scale: 4
    t.datetime "duedate"
    t.datetime "depdate"
  end

  create_table "shpests", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "contents", limit: 4000
    t.string "sno", limit: 50
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "created_at"
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
    t.decimal "qty_est", precision: 22, scale: 6
    t.decimal "itms_id", precision: 38, default: "0", null: false
    t.datetime "depdate"
    t.decimal "processseq", precision: 38
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.decimal "transports_id", precision: 38, default: "0", null: false
    t.datetime "isudate"
    t.decimal "prjnos_id", precision: 38, default: "0", null: false
    t.datetime "duedate"
  end

  create_table "shpinsts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "sno", limit: 50
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty_shortage", precision: 22, scale: 5
    t.datetime "isudate"
    t.string "gno", limit: 40
    t.decimal "paretblid", precision: 38
    t.string "paretblname", limit: 30
    t.decimal "qty_case", precision: 22
    t.string "cno", limit: 40
    t.decimal "processseq", precision: 38
    t.string "cartonno", limit: 50
    t.string "box", limit: 50
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.datetime "created_at"
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.datetime "depdate"
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "qty_real", precision: 22, scale: 6
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.datetime "rcptdate"
    t.decimal "taxrate", precision: 2
    t.string "contractprice", limit: 1
    t.decimal "tax", precision: 38, scale: 4
    t.datetime "duedate"
  end

  create_table "shpords", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.date "expiredate"
    t.datetime "depdate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "price", precision: 38, scale: 4
    t.decimal "prjnos_id", precision: 38, null: false
    t.string "lotno", limit: 50
    t.decimal "qty_case", precision: 22
    t.string "packno", limit: 10
    t.string "gno", limit: 40
    t.string "sno", limit: 50
    t.decimal "chrgs_id", precision: 38, null: false
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.decimal "processseq", precision: 38
    t.decimal "amt", precision: 18, scale: 4
    t.datetime "duedate"
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "crrs_id", precision: 22, default: "0", null: false
    t.decimal "qty_shortage", precision: 22, scale: 5
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.decimal "taxrate", precision: 2
    t.decimal "masterprice", precision: 38, scale: 4
    t.string "contractprice", limit: 1
    t.decimal "tax", precision: 38, scale: 4
  end

  create_table "shpreplyinputs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.datetime "isudate"
    t.datetime "starttime"
    t.datetime "duedate"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "qty_case_bal", precision: 38
    t.string "sno", limit: 40
    t.string "box", limit: 50
    t.string "cartonno", limit: 50
    t.string "siosession", limit: 20
    t.string "remark", limit: 4000
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shprets", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.date "retdate"
    t.decimal "qty_case", precision: 22
    t.decimal "price", precision: 38, scale: 4
    t.decimal "amt", precision: 18, scale: 4
    t.string "sno", limit: 50
    t.decimal "crrs_id", precision: 22, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "shelfnos_id_fm", precision: 22, default: "0", null: false
    t.decimal "itms_id", precision: 38, default: "0", null: false
    t.decimal "processseq", precision: 38
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "taxrate", precision: 2
    t.string "contractprice", limit: 1
    t.decimal "tax", precision: 38, scale: 4
  end

  create_table "shprsltinputs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "result_f", limit: 1
    t.datetime "duedate"
    t.datetime "isudate"
    t.datetime "starttime"
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "qty_case_bal", precision: 38
    t.decimal "shelfnos_id_fm", precision: 22, null: false
    t.string "sno", limit: 40
    t.string "box", limit: 50
    t.string "siosession", limit: 20
    t.string "cartonno", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "message_code", limit: 256
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shpschs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.datetime "isudate"
    t.decimal "price", precision: 38, scale: 4
    t.string "sno", limit: 50
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "remark", limit: 4000
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.decimal "prjnos_id", precision: 38, null: false
    t.decimal "chrgs_id", precision: 38, null: false
    t.decimal "transports_id", precision: 38, null: false
    t.decimal "itms_id", precision: 38
    t.datetime "depdate"
    t.string "lotno", limit: 50
    t.string "packno", limit: 10
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.decimal "shelfnos_id_fm", precision: 22
    t.decimal "processseq", precision: 38
    t.decimal "qty_sch", precision: 22, scale: 6
    t.decimal "qty_case", precision: 22
    t.decimal "amt_sch", precision: 22, scale: 4
    t.string "gno", limit: 40
    t.datetime "duedate"
    t.decimal "shelfnos_id_to", precision: 38, default: "0", null: false
    t.decimal "units_id_case_shp", precision: 38, default: "0", null: false
    t.decimal "taxrate", precision: 2
    t.string "contractprice", limit: 1
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "srctbllinks", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "amt_src", precision: 22, scale: 5
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.string "srctblname", limit: 30
    t.decimal "srctblid", precision: 38
  end

  create_table "srctbls", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "srctblname", limit: 30
    t.string "sno", limit: 40
    t.string "cno", limit: 40
    t.decimal "srctblid", precision: 38
    t.decimal "qty_src", precision: 38, scale: 6
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "update_ip", limit: 40
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
  end

  create_table "supplierprices", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "suppliers_id", precision: 22, null: false
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "price", precision: 38, scale: 4
    t.string "contents", limit: 4000
    t.decimal "maxqty", precision: 22, scale: 6
    t.decimal "chrgs_id", precision: 38, null: false
    t.string "itm_code_client", limit: 50
    t.decimal "opeitms_id", precision: 38, default: "0", null: false
    t.decimal "minqty", precision: 22, scale: 6
    t.string "ruleprice", limit: 1
    t.decimal "crrs_id_supplierprice", precision: 22, default: "0", null: false

    t.unique_constraint ["suppliers_id", "opeitms_id", "maxqty"], name: "supplierprices_uky20"
    t.unique_constraint ["suppliers_id", "opeitms_id", "minqty"], name: "supplierprices_uky10"
  end

  create_table "suppliers", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "personname", limit: 30
    t.decimal "crrs_id_supplier", precision: 22, null: false
    t.decimal "locas_id_supplier", precision: 22, null: false
    t.decimal "chrgs_id_supplier", precision: 22, null: false
    t.string "amtround", limit: 2
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "payments_id_supplier", precision: 38, null: false
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string "contractprice", limit: 1
    t.decimal "locas_id_calendar", precision: 22, default: "0", null: false

    t.unique_constraint ["locas_id_supplier"], name: "suppliers_uky10"
  end

  create_table "supplierwhs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "suppliers_id", precision: 22, null: false
    t.decimal "qty_sch", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.decimal "itms_id", precision: 38, null: false
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "processseq", precision: 38
    t.string "lotno", limit: 50
    t.decimal "qty_stk", precision: 22, scale: 6
    t.datetime "starttime"
  end

  create_table "table_opeitms", id: { type: :decimal, precision: 22 }, force: :cascade do |t|
    t.string "itm_code", limit: 50
    t.string "opeitm_processseq", limit: 3
    t.string "opeitm_priority", limit: 3
    t.string "itm_name", limit: 100
    t.string "loca_code", limit: 50
    t.string "loca_name", limit: 100
    t.string "opeitm_prdpurshp", limit: 20
    t.string "opeitm_operation", limit: 20
    t.string "unit_code", limit: 50
    t.string "unit_name", limit: 100
    t.string "unit_code_case", limit: 50
    t.string "unit_name_case", limit: 100
    t.string "unit_code_prdpurshp", limit: 50
    t.string "unit_name_prdpurshp", limit: 100
    t.string "boxe_code", limit: 50
    t.string "boxe_name", limit: 100
    t.string "unit_code_box", limit: 50
    t.string "unit_name_box", limit: 100
    t.string "unit_code_outbox", limit: 50
    t.string "unit_name_outbox", limit: 100
    t.string "shelfno_code", limit: 50
    t.string "shelfno_name", limit: 100
    t.string "loca_code_shelfno", limit: 50
    t.string "loca_name_shelfno", limit: 100
    t.string "classlist_code", limit: 50
    t.string "classlist_name", limit: 100
    t.string "opeitm_duration", limit: 38
    t.string "opeitm_autocreate_ord", limit: 1
    t.string "opeitm_acceptance_proc", limit: 1
    t.string "opeitm_opt_fixoterm", limit: 8
    t.string "opeitm_stktaking_proc", limit: 1
    t.string "opeitm_autoinst_p", limit: 3
    t.string "opeitm_rule_price", limit: 1
    t.string "opeitm_autocreate_act", limit: 1
    t.string "opeitm_shuffle_loca", limit: 1
    t.string "opeitm_shuffle_flg", limit: 1
    t.string "opeitm_autocreate_inst", limit: 1
    t.string "opeitm_packno_flg", limit: 1
    t.string "opeitm_packqty", limit: 38
    t.string "opeitm_minqty", limit: 38
    t.string "opeitm_maxqty", limit: 22
    t.string "opeitm_safestkqty", limit: 38
    t.string "opeitm_units_lttime", limit: 4
    t.string "opeitm_chkord", limit: 1
    t.string "opeitm_chkord_prc", limit: 3
    t.string "opeitm_esttosch", limit: 22
    t.string "itm_std", limit: 50
    t.string "itm_model", limit: 50
    t.string "itm_material", limit: 50
    t.string "itm_design", limit: 50
    t.string "itm_weight", limit: 22
    t.string "itm_length", limit: 22
    t.string "itm_wide", limit: 22
    t.string "itm_deth", limit: 22
    t.string "itm_datascale", limit: 22
    t.string "unit_contents", limit: 4000
    t.string "unit_dataprecision_prdpurshp", limit: 38
    t.string "unit_dataprecision_case", limit: 38
    t.string "opeitm_chkinst", limit: 1
    t.string "opeitm_mold", limit: 1
    t.string "opeitm_prjalloc_flg", limit: 22
    t.string "opeitm_autoord_p", limit: 3
    t.string "opeitm_autoact_p", limit: 3
    t.string "opeitm_opt_fix_flg", limit: 1
    t.string "unit_contents_prdpurshp", limit: 4000
    t.string "unit_contents_case", limit: 4000
    t.string "opeitm_expiredate", limit: 50
    t.string "boxe_boxtype", limit: 20
    t.string "opeitm_contents", limit: 4000
    t.string "opeitm_remark", limit: 4000
    t.decimal "opeitm_created_at", precision: 38
    t.decimal "opeitm_loca_id", precision: 38
    t.decimal "opeitm_id", precision: 38
    t.decimal "opeitm_person_id_upd", precision: 38
    t.string "opeitm_update_ip", limit: 40
    t.decimal "opeitm_unit_id_prdpurshp", precision: 38
    t.decimal "opeitm_itm_id", precision: 38
    t.decimal "boxe_unit_id_outbox", precision: 38
    t.decimal "boxe_unit_id_box", precision: 38
    t.decimal "itm_unit_id", precision: 22
    t.decimal "itm_classlist_id", precision: 38
    t.string "loca_zip_shelfno", limit: 10
    t.decimal "opeitm_shelfno_id", precision: 22
    t.string "opeitm_updated_at", limit: 50
    t.string "loca_abbr_shelfno", limit: 50
    t.string "shelfno_contents", limit: 4000
    t.string "boxe_depth", limit: 7
    t.string "boxe_wide", limit: 7
    t.string "boxe_height", limit: 7
    t.string "boxe_outdepth", limit: 7
    t.string "boxe_outwide", limit: 7
    t.string "boxe_outheight", limit: 7
    t.string "loca_abbr", limit: 50
    t.string "loca_mail", limit: 20
    t.string "loca_mail_shelfno", limit: 20
    t.string "loca_fax", limit: 20
    t.string "loca_fax_shelfno", limit: 20
    t.string "person_code_upd", limit: 50
    t.string "person_name_upd", limit: 100
    t.decimal "shelfno_loca_id_shelfno", precision: 38
    t.string "loca_tel", limit: 20
    t.string "loca_tel_shelfno", limit: 20
    t.string "loca_addr2", limit: 50
    t.string "loca_addr2_shelfno", limit: 50
    t.decimal "opeitm_unit_id_case", precision: 38
    t.string "loca_addr1", limit: 50
    t.string "loca_addr1_shelfno", limit: 50
    t.string "loca_prfct", limit: 20
    t.string "loca_prfct_shelfno", limit: 20
    t.string "boxe_contents", limit: 4000
    t.string "loca_country", limit: 20
    t.decimal "opeitm_boxe_id", precision: 22
    t.string "loca_country_shelfno", limit: 20
    t.string "loca_zip", limit: 10
  end

  create_table "taxtbls", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "contents", limit: 4000
    t.decimal "taxrate", precision: 2
    t.string "taxflg", limit: 1
  end

  create_table "tblfields", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "blktbs_id", precision: 38
    t.decimal "fieldcodes_id", precision: 38
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "seqno", precision: 38
    t.string "contents", limit: 4000
    t.string "viewflmk", limit: 4000

    t.unique_constraint ["blktbs_id", "fieldcodes_id"], name: "tblfields_ukys10"
  end

  create_table "tblinkflds", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "command_c", limit: 4000
    t.decimal "tblinks_id", precision: 38
    t.decimal "tblfields_id", precision: 38
    t.decimal "seqno", precision: 38
    t.string "contents", limit: 4000
    t.string "rubycode", limit: 4000

    t.unique_constraint ["tblinks_id", "tblfields_id"], name: "tblinkflds_ukys10"
  end

  create_table "tblinks", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "blktbs_id_dest", precision: 38
    t.decimal "screens_id_src", precision: 38
    t.decimal "seqno", precision: 38
    t.string "beforeafter", limit: 15
    t.string "contents", limit: 4000
    t.string "hikisu", limit: 400
    t.string "codel", limit: 50

    t.unique_constraint ["screens_id_src", "blktbs_id_dest", "beforeafter", "seqno"], name: "tblinks_ukys1"
  end

  create_table "transports", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 50, null: false
    t.string "name", limit: 100, null: false
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38, null: false
    t.datetime "created_at"
    t.decimal "locas_id_transport", precision: 22, default: "0", null: false
    t.decimal "locas_id_to_transport", precision: 22, default: "0", null: false
    t.decimal "duration", precision: 38, scale: 2, default: "0.0", null: false
    t.decimal "locas_id_fm_transport", precision: 22, default: "0", null: false
    t.string "unitofduration", limit: 4
    t.decimal "priority", precision: 38, default: "0", null: false
  end

  create_table "trngantts", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "key", limit: 250
    t.string "orgtblname", limit: 30
    t.decimal "orgtblid", precision: 38
    t.string "paretblname", limit: 30
    t.decimal "paretblid", precision: 38
    t.string "tblname", limit: 30
    t.decimal "tblid", precision: 38
    t.decimal "qty", precision: 22, scale: 6
    t.decimal "qty_stk", precision: 22, scale: 6
    t.decimal "qty_alloc", precision: 22, scale: 6
    t.decimal "mlevel", precision: 3
    t.decimal "parenum", precision: 22, scale: 6
    t.decimal "chilnum", precision: 22, scale: 6
    t.decimal "consumunitqty", precision: 22, scale: 6
    t.decimal "consumminqty", precision: 22, scale: 6
    t.decimal "consumchgoverqty", precision: 22, scale: 6
    t.string "remark", limit: 4000
    t.datetime "created_at"
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.decimal "persons_id_upd", precision: 38
    t.decimal "prjnos_id", precision: 38
    t.decimal "processseq_pare", precision: 38
    t.decimal "itms_id_pare", precision: 38
    t.decimal "qty_pare", precision: 22, scale: 6
    t.decimal "qty_pare_alloc", precision: 22, scale: 6
    t.decimal "qty_bal", precision: 22, scale: 6
    t.decimal "qty_pare_bal", precision: 22, scale: 6
    t.datetime "duedate_org"
    t.decimal "qty_sch", precision: 22, scale: 6
    t.datetime "starttime_org"
    t.datetime "starttime_pare"
    t.decimal "itms_id_org", precision: 38, default: "0", null: false
    t.datetime "duedate_trn"
    t.datetime "duedate_pare"
    t.decimal "chrgs_id_pare", precision: 22, default: "0", null: false
    t.decimal "chrgs_id_org", precision: 38, default: "0", null: false
    t.decimal "chrgs_id_trn", precision: 38, default: "0", null: false
    t.decimal "processseq_org", precision: 22
    t.decimal "itms_id_trn", precision: 38, default: "0", null: false
    t.decimal "processseq_trn", precision: 38
    t.datetime "starttime_trn"
    t.decimal "qty_require", precision: 22, scale: 6
    t.decimal "qty_handover", precision: 22, scale: 6
    t.decimal "mkprdpurords_id_trngantt", precision: 22, default: "0", null: false
    t.datetime "toduedate_trn"
    t.datetime "toduedate_pare"
    t.datetime "toduedate_org"
    t.string "consumtype", limit: 10
    t.decimal "shelfnos_id_to_pare", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_trn", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_pare", precision: 22, default: "0", null: false
    t.decimal "shelfnos_id_to_trn", precision: 22, default: "0", null: false
    t.decimal "qty_sch_pare", precision: 22, scale: 6
    t.decimal "shelfnos_id_org", precision: 22, default: "0", null: false
    t.date "optfixodate"
    t.decimal "packqty", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "maxqty", precision: 22, scale: 6, default: "0.0", null: false
    t.decimal "optfixoterm", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "duration", precision: 38, scale: 2, default: "0.0", null: false
    t.string "unitofduration", limit: 4
    t.string "shuffleflg", limit: 1

    t.unique_constraint ["orgtblname", "orgtblid", "key", "paretblname", "paretblid", "tblname", "tblid"], name: "trngantts_ukyg1"
  end

  create_table "units", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 50
    t.string "name", limit: 100
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.date "expiredate"
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "contents", limit: 4000
    t.decimal "dataprecision", precision: 38
  end

  create_table "uploads", force: :cascade do |t|
    t.string "title"
    t.string "contents"
    t.string "result"
    t.string "persons_id_upd"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "usebuttons", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "buttons_id", precision: 38
    t.date "expiredate"
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "screens_id_ub", precision: 38
  end

  create_table "userprocs", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "session_counter", precision: 38
    t.string "sio_code", limit: 30
    t.string "status", limit: 256
    t.decimal "cnt", precision: 38
    t.decimal "cnt_out", precision: 38
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.date "expiredate"
    t.datetime "updated_at"

    t.unique_constraint ["session_counter", "sio_code"], name: "userprocs_uk1"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "usrgrps", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.string "code", limit: 10
    t.string "name", limit: 50
    t.string "email", limit: 50
    t.string "contents", limit: 4000
    t.string "remark", limit: 4000
    t.date "expiredate"
    t.decimal "persons_id_upd", precision: 38
    t.string "update_ip", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"

    t.unique_constraint ["code", "expiredate"], name: "usrgrps_16_uk"
  end

  create_table "workplaces", id: { type: :decimal, precision: 38 }, force: :cascade do |t|
    t.decimal "locas_id_workplace", precision: 22, null: false
    t.decimal "chrgs_id_workplace", precision: 22, null: false
    t.string "contents", limit: 4000
    t.date "expiredate"
    t.string "remark", limit: 4000
    t.decimal "persons_id_upd", precision: 38, null: false
    t.string "update_ip", limit: 40
    t.datetime "updated_at"
    t.datetime "created_at"
    t.decimal "locas_id_calendar", precision: 22, default: "0", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alloctbls", "persons", column: "persons_id_upd", name: "alloctbl_persons_id_upd"
  add_foreign_key "alloctbls", "trngantts", column: "trngantts_id", name: "alloctbl_trngantts_id"
  add_foreign_key "asstwhs", "chrgs", column: "chrgs_id_asstwh", name: "asstwh_chrgs_id_asstwh"
  add_foreign_key "asstwhs", "locas", column: "locas_id_asstwh", name: "asstwh_locas_id_asstwh"
  add_foreign_key "asstwhs", "persons", column: "persons_id_upd", name: "asstwh_persons_id_upd"
  add_foreign_key "billacts", "bills", column: "bills_id", name: "billact_bills_id"
  add_foreign_key "billacts", "chrgs", column: "chrgs_id", name: "billact_chrgs_id"
  add_foreign_key "billacts", "persons", column: "persons_id_upd", name: "billact_persons_id_upd"
  add_foreign_key "billests", "bills", column: "bills_id", name: "billest_bills_id"
  add_foreign_key "billests", "chrgs", column: "chrgs_id", name: "billest_chrgs_id"
  add_foreign_key "billests", "persons", column: "persons_id_upd", name: "billest_persons_id_upd"
  add_foreign_key "billinsts", "bills", column: "bills_id", name: "billinst_bills_id"
  add_foreign_key "billinsts", "chrgs", column: "chrgs_id", name: "billinst_chrgs_id"
  add_foreign_key "billinsts", "persons", column: "persons_id_upd", name: "billinst_persons_id_upd"
  add_foreign_key "billords", "bills", column: "bills_id", name: "billord_bills_id"
  add_foreign_key "billords", "chrgs", column: "chrgs_id", name: "billord_chrgs_id"
  add_foreign_key "billords", "persons", column: "persons_id_upd", name: "billord_persons_id_upd"
  add_foreign_key "bills", "chrgs", column: "chrgs_id_bill", name: "bill_chrgs_id_bill"
  add_foreign_key "bills", "crrs", column: "crrs_id_bill", name: "bill_crrs_id_bill"
  add_foreign_key "bills", "locas", column: "locas_id_bill", name: "bill_locas_id_bill"
  add_foreign_key "bills", "persons", column: "persons_id_upd", name: "bill_persons_id_upd"
  add_foreign_key "billschs", "bills", column: "bills_id", name: "billsch_bills_id"
  add_foreign_key "billschs", "chrgs", column: "chrgs_id", name: "billsch_chrgs_id"
  add_foreign_key "billschs", "persons", column: "persons_id_upd", name: "billsch_persons_id_upd"
  add_foreign_key "blktbs", "persons", column: "persons_id_upd", name: "blktb_persons_id_upd"
  add_foreign_key "blktbs", "pobjects", column: "pobjects_id_tbl", name: "blktb_pobjects_id_tbl"
  add_foreign_key "blkukys", "persons", column: "persons_id_upd", name: "blkuky_persons_id_upd"
  add_foreign_key "blkukys", "tblfields", column: "tblfields_id", name: "blkuky_tblfields_id"
  add_foreign_key "boxes", "persons", column: "persons_id_upd", name: "boxe_persons_id_upd"
  add_foreign_key "boxes", "units", column: "units_id_box", name: "boxe_units_id_box"
  add_foreign_key "buglists", "persons", column: "persons_id_upd", name: "buglist_persons_id_upd"
  add_foreign_key "buttons", "persons", column: "persons_id_upd", name: "button_persons_id_upd"
  add_foreign_key "calendars", "locas", column: "locas_id", name: "calendar_locas_id"
  add_foreign_key "calendars", "persons", column: "persons_id_upd", name: "calendar_persons_id_upd"
  add_foreign_key "chilscreens", "persons", column: "persons_id_upd", name: "chilscreen_persons_id_upd"
  add_foreign_key "chilscreens", "screenfields", column: "screenfields_id", name: "chilscreen_screenfields_id"
  add_foreign_key "chilscreens", "screenfields", column: "screenfields_id_ch", name: "chilscreen_screenfields_id_ch"
  add_foreign_key "chrgs", "persons", column: "persons_id_chrg", name: "chrg_persons_id_chrg"
  add_foreign_key "chrgs", "persons", column: "persons_id_upd", name: "chrg_persons_id_upd"
  add_foreign_key "classlists", "persons", column: "persons_id_upd", name: "classlist_persons_id_upd"
  add_foreign_key "conacts", "chrgs", column: "chrgs_id", name: "conact_chrgs_id"
  add_foreign_key "conacts", "itms", column: "itms_id", name: "conact_itms_id"
  add_foreign_key "conacts", "persons", column: "persons_id_upd", name: "conact_persons_id_upd"
  add_foreign_key "conacts", "prjnos", column: "prjnos_id", name: "conact_prjnos_id"
  add_foreign_key "conacts", "shelfnos", column: "shelfnos_id_fm", name: "conact_shelfnos_id_fm"
  add_foreign_key "coninsts", "itms", column: "itms_id", name: "coninst_itms_id"
  add_foreign_key "coninsts", "persons", column: "persons_id_upd", name: "coninst_persons_id_upd"
  add_foreign_key "coninsts", "shelfnos", column: "shelfnos_id_fm", name: "coninst_shelfnos_id_fm"
  add_foreign_key "conords", "chrgs", column: "chrgs_id", name: "conord_chrgs_id"
  add_foreign_key "conords", "itms", column: "itms_id", name: "conord_itms_id"
  add_foreign_key "conords", "persons", column: "persons_id_upd", name: "conord_persons_id_upd"
  add_foreign_key "conords", "prjnos", column: "prjnos_id", name: "conord_prjnos_id"
  add_foreign_key "conords", "shelfnos", column: "shelfnos_id_fm", name: "conord_shelfnos_id_fm"
  add_foreign_key "conschs", "chrgs", column: "chrgs_id", name: "consch_chrgs_id"
  add_foreign_key "conschs", "itms", column: "itms_id", name: "consch_itms_id"
  add_foreign_key "conschs", "persons", column: "persons_id_upd", name: "consch_persons_id_upd"
  add_foreign_key "conschs", "prjnos", column: "prjnos_id", name: "consch_prjnos_id"
  add_foreign_key "conschs", "shelfnos", column: "shelfnos_id_fm", name: "consch_shelfnos_id_fm"
  add_foreign_key "crrs", "persons", column: "persons_id_upd", name: "crr_persons_id_upd"
  add_foreign_key "custactheads", "bills", column: "bills_id", name: "custacthead_bills_id"
  add_foreign_key "custactheads", "custs", column: "custs_id", name: "custacthead_custs_id"
  add_foreign_key "custactheads", "persons", column: "persons_id_upd", name: "custacthead_persons_id_upd"
  add_foreign_key "custacts", "bills", column: "bills_id", name: "custact_bills_id"
  add_foreign_key "custacts", "chrgs", column: "chrgs_id", name: "custact_chrgs_id"
  add_foreign_key "custacts", "custrcvplcs", column: "custrcvplcs_id", name: "custact_custrcvplcs_id"
  add_foreign_key "custacts", "custs", column: "custs_id", name: "custact_custs_id"
  add_foreign_key "custacts", "opeitms", column: "opeitms_id", name: "custact_opeitms_id"
  add_foreign_key "custacts", "persons", column: "persons_id_upd", name: "custact_persons_id_upd"
  add_foreign_key "custacts", "shelfnos", column: "shelfnos_id_fm", name: "custact_shelfnos_id_fm"
  add_foreign_key "custacts", "transports", column: "transports_id", name: "custact_transports_id"
  add_foreign_key "custdlvs", "boxes", column: "boxes_id_custdlv", name: "custdlv_boxes_id_custdlv"
  add_foreign_key "custdlvs", "chrgs", column: "chrgs_id", name: "custdlv_chrgs_id"
  add_foreign_key "custdlvs", "crrs", column: "crrs_id", name: "custdlv_crrs_id"
  add_foreign_key "custdlvs", "custrcvplcs", column: "custrcvplcs_id", name: "custdlv_custrcvplcs_id"
  add_foreign_key "custdlvs", "custs", column: "custs_id", name: "custdlv_custs_id"
  add_foreign_key "custdlvs", "opeitms", column: "opeitms_id", name: "custdlv_opeitms_id"
  add_foreign_key "custdlvs", "persons", column: "persons_id_upd", name: "custdlv_persons_id_upd"
  add_foreign_key "custdlvs", "shelfnos", column: "shelfnos_id_fm", name: "custdlv_shelfnos_id_fm"
  add_foreign_key "custdlvs", "transports", column: "transports_id", name: "custdlv_transports_id"
  add_foreign_key "custdlvs", "units", column: "units_id_weight", name: "custdlv_units_id_weight"
  add_foreign_key "custinsts", "chrgs", column: "chrgs_id", name: "custinst_chrgs_id"
  add_foreign_key "custinsts", "crrs", column: "crrs_id", name: "custinst_crrs_id"
  add_foreign_key "custinsts", "custrcvplcs", column: "custrcvplcs_id", name: "custinst_custrcvplcs_id"
  add_foreign_key "custinsts", "custs", column: "custs_id", name: "custinst_custs_id"
  add_foreign_key "custinsts", "opeitms", column: "opeitms_id", name: "custinst_opeitms_id"
  add_foreign_key "custinsts", "persons", column: "persons_id_upd", name: "custinst_persons_id_upd"
  add_foreign_key "custinsts", "prjnos", column: "prjnos_id", name: "custinst_prjnos_id"
  add_foreign_key "custinsts", "shelfnos", column: "shelfnos_id_fm", name: "custinst_shelfnos_id_fm"
  add_foreign_key "custinsts", "transports", column: "transports_id", name: "custinst_transports_id"
  add_foreign_key "custordheads", "chrgs", column: "chrgs_id", name: "custordhead_chrgs_id"
  add_foreign_key "custordheads", "crrs", column: "crrs_id", name: "custordhead_crrs_id"
  add_foreign_key "custordheads", "custrcvplcs", column: "custrcvplcs_id", name: "custordhead_custrcvplcs_id"
  add_foreign_key "custordheads", "custs", column: "custs_id", name: "custordhead_custs_id"
  add_foreign_key "custordheads", "persons", column: "persons_id_upd", name: "custordhead_persons_id_upd"
  add_foreign_key "custordheads", "prjnos", column: "prjnos_id", name: "custordhead_prjnos_id"
  add_foreign_key "custords", "chrgs", column: "chrgs_id", name: "custord_chrgs_id"
  add_foreign_key "custords", "crrs", column: "crrs_id", name: "custord_crrs_id"
  add_foreign_key "custords", "custrcvplcs", column: "custrcvplcs_id", name: "custord_custrcvplcs_id"
  add_foreign_key "custords", "custs", column: "custs_id", name: "custord_custs_id"
  add_foreign_key "custords", "opeitms", column: "opeitms_id", name: "custord_opeitms_id"
  add_foreign_key "custords", "persons", column: "persons_id_upd", name: "custord_persons_id_upd"
  add_foreign_key "custords", "prjnos", column: "prjnos_id", name: "custord_prjnos_id"
  add_foreign_key "custords", "shelfnos", column: "shelfnos_id_fm", name: "custord_shelfnos_id_fm"
  add_foreign_key "custords", "transports", column: "transports_id", name: "custord_transports_id"
  add_foreign_key "custprices", "chrgs", column: "chrgs_id", name: "custprice_chrgs_id"
  add_foreign_key "custprices", "crrs", column: "crrs_id_custprice", name: "custprice_crrs_id_custprice"
  add_foreign_key "custprices", "custs", column: "custs_id", name: "custprice_custs_id"
  add_foreign_key "custprices", "opeitms", column: "opeitms_id", name: "custprice_opeitms_id"
  add_foreign_key "custprices", "persons", column: "persons_id_upd", name: "custprice_persons_id_upd"
  add_foreign_key "custrcvplcs", "locas", column: "locas_id_custrcvplc", name: "custrcvplc_locas_id_custrcvplc"
  add_foreign_key "custrcvplcs", "persons", column: "persons_id_upd", name: "custrcvplc_persons_id_upd"
  add_foreign_key "custrcvplcs", "transports", column: "transports_id_custrcvplc", name: "custrcvplc_transports_id_custrcvplc"
  add_foreign_key "custrets", "chrgs", column: "chrgs_id", name: "custret_chrgs_id"
  add_foreign_key "custrets", "custrcvplcs", column: "custrcvplcs_id", name: "custret_custrcvplcs_id"
  add_foreign_key "custrets", "custs", column: "custs_id", name: "custret_custs_id"
  add_foreign_key "custrets", "opeitms", column: "opeitms_id", name: "custret_opeitms_id"
  add_foreign_key "custrets", "persons", column: "persons_id_upd", name: "custret_persons_id_upd"
  add_foreign_key "custrets", "shelfnos", column: "shelfnos_id_to", name: "custret_shelfnos_id_to"
  add_foreign_key "custrets", "transports", column: "transports_id", name: "custret_transports_id"
  add_foreign_key "custs", "bills", column: "bills_id_cust", name: "cust_bills_id_cust"
  add_foreign_key "custs", "chrgs", column: "chrgs_id_cust", name: "cust_chrgs_id_cust"
  add_foreign_key "custs", "locas", column: "locas_id_cust", name: "cust_locas_id_cust"
  add_foreign_key "custs", "persons", column: "persons_id_upd", name: "cust_persons_id_upd"
  add_foreign_key "custschs", "chrgs", column: "chrgs_id", name: "custsch_chrgs_id"
  add_foreign_key "custschs", "crrs", column: "crrs_id", name: "custsch_crrs_id"
  add_foreign_key "custschs", "custrcvplcs", column: "custrcvplcs_id", name: "custsch_custrcvplcs_id"
  add_foreign_key "custschs", "custs", column: "custs_id", name: "custsch_custs_id"
  add_foreign_key "custschs", "opeitms", column: "opeitms_id", name: "custsch_opeitms_id"
  add_foreign_key "custschs", "persons", column: "persons_id_upd", name: "custsch_persons_id_upd"
  add_foreign_key "custschs", "prjnos", column: "prjnos_id", name: "custsch_prjnos_id"
  add_foreign_key "custschs", "shelfnos", column: "shelfnos_id_fm", name: "custsch_shelfnos_id_fm"
  add_foreign_key "custschs", "transports", column: "transports_id", name: "custsch_transports_id"
  add_foreign_key "custwhs", "custrcvplcs", column: "custrcvplcs_id", name: "custwh_custrcvplcs_id"
  add_foreign_key "custwhs", "itms", column: "itms_id", name: "custwh_itms_id"
  add_foreign_key "custwhs", "persons", column: "persons_id_upd", name: "custwh_persons_id_upd"
  add_foreign_key "deflists", "classlists", column: "classlists_id", name: "deflist_classlists_id"
  add_foreign_key "deflists", "persons", column: "persons_id_upd", name: "deflist_persons_id_upd"
  add_foreign_key "detailcalendars", "locas", column: "locas_id", name: "detailcalendar_locas_id"
  add_foreign_key "detailcalendars", "persons", column: "persons_id_upd", name: "detailcalendar_persons_id_upd"
  add_foreign_key "dlvacts", "asstwhs", column: "asstwhs_id", name: "dlvact_asstwhs_id"
  add_foreign_key "dlvacts", "custrcvplcs", column: "custrcvplcs_id", name: "dlvact_custrcvplcs_id"
  add_foreign_key "dlvacts", "itms", column: "itms_id", name: "dlvact_itms_id"
  add_foreign_key "dlvacts", "locas", column: "locas_id_to", name: "dlvact_locas_id_to"
  add_foreign_key "dlvacts", "persons", column: "persons_id_upd", name: "dlvact_persons_id_upd"
  add_foreign_key "dlvacts", "prjnos", column: "prjnos_id", name: "dlvact_prjnos_id"
  add_foreign_key "dlvacts", "transports", column: "transports_id", name: "dlvact_transports_id"
  add_foreign_key "dlvinsts", "asstwhs", column: "asstwhs_id", name: "dlvinst_asstwhs_id"
  add_foreign_key "dlvinsts", "custrcvplcs", column: "custrcvplcs_id", name: "dlvinst_custrcvplcs_id"
  add_foreign_key "dlvinsts", "itms", column: "itms_id", name: "dlvinst_itms_id"
  add_foreign_key "dlvinsts", "locas", column: "locas_id_to", name: "dlvinst_locas_id_to"
  add_foreign_key "dlvinsts", "persons", column: "persons_id_upd", name: "dlvinst_persons_id_upd"
  add_foreign_key "dlvinsts", "prjnos", column: "prjnos_id", name: "dlvinst_prjnos_id"
  add_foreign_key "dlvinsts", "transports", column: "transports_id", name: "dlvinst_transports_id"
  add_foreign_key "dlvords", "custs", column: "custs_id", name: "dlvord_custs_id"
  add_foreign_key "dlvords", "itms", column: "itms_id", name: "dlvord_itms_id"
  add_foreign_key "dlvords", "locas", column: "locas_id_fm", name: "dlvord_locas_id_fm"
  add_foreign_key "dlvords", "locas", column: "locas_id_to", name: "dlvord_locas_id_to"
  add_foreign_key "dlvords", "persons", column: "persons_id_upd", name: "dlvord_persons_id_upd"
  add_foreign_key "dlvords", "prjnos", column: "prjnos_id", name: "dlvord_prjnos_id"
  add_foreign_key "dlvords", "transports", column: "transports_id", name: "dlvord_transports_id"
  add_foreign_key "dlvschs", "itms", column: "itms_id", name: "dlvsch_itms_id"
  add_foreign_key "dlvschs", "locas", column: "locas_id_fm", name: "dlvsch_locas_id_fm"
  add_foreign_key "dlvschs", "locas", column: "locas_id_to", name: "dlvsch_locas_id_to"
  add_foreign_key "dlvschs", "persons", column: "persons_id_upd", name: "dlvsch_persons_id_upd"
  add_foreign_key "dlvschs", "prjnos", column: "prjnos_id", name: "dlvsch_prjnos_id"
  add_foreign_key "dlvschs", "transports", column: "transports_id", name: "dlvsch_transports_id"
  add_foreign_key "dvsacts", "chrgs", column: "chrgs_id", name: "dvsact_chrgs_id"
  add_foreign_key "dvsacts", "facilities", column: "facilities_id", name: "dvsact_facilities_id"
  add_foreign_key "dvsacts", "persons", column: "persons_id_upd", name: "dvsact_persons_id_upd"
  add_foreign_key "dvsacts", "prdacts", column: "prdacts_id_dvsact", name: "dvsact_prdacts_id_dvsact"
  add_foreign_key "dvsacts", "prjnos", column: "prjnos_id", name: "dvsact_prjnos_id"
  add_foreign_key "dvsinsts", "chrgs", column: "chrgs_id", name: "dvsinst_chrgs_id"
  add_foreign_key "dvsinsts", "facilities", column: "facilities_id", name: "dvsinst_facilities_id"
  add_foreign_key "dvsinsts", "persons", column: "persons_id_upd", name: "dvsinst_persons_id_upd"
  add_foreign_key "dvsinsts", "prdinsts", column: "prdinsts_id_dvsinst", name: "dvsinst_prdinsts_id_dvsinst"
  add_foreign_key "dvsinsts", "prjnos", column: "prjnos_id", name: "dvsinst_prjnos_id"
  add_foreign_key "dvsords", "chrgs", column: "chrgs_id", name: "dvsord_chrgs_id"
  add_foreign_key "dvsords", "facilities", column: "facilities_id", name: "dvsord_facilities_id"
  add_foreign_key "dvsords", "persons", column: "persons_id_upd", name: "dvsord_persons_id_upd"
  add_foreign_key "dvsords", "prdords", column: "prdords_id_dvsord", name: "dvsord_prdords_id_dvsord"
  add_foreign_key "dvsords", "prjnos", column: "prjnos_id", name: "dvsord_prjnos_id"
  add_foreign_key "dvsschs", "chrgs", column: "chrgs_id", name: "dvssch_chrgs_id"
  add_foreign_key "dvsschs", "facilities", column: "facilities_id", name: "dvssch_facilities_id"
  add_foreign_key "dvsschs", "persons", column: "persons_id_upd", name: "dvssch_persons_id_upd"
  add_foreign_key "dvsschs", "prdschs", column: "prdschs_id_dvssch", name: "dvssch_prdschs_id_dsvsch"
  add_foreign_key "dvsschs", "prdschs", column: "prdschs_id_dvssch", name: "dvssch_prdschs_id_dvssch"
  add_foreign_key "dvsschs", "prjnos", column: "prjnos_id", name: "dvssch_prjnos_id"
  add_foreign_key "dymschs", "chrgs", column: "chrgs_id", name: "dymsch_chrgs_id"
  add_foreign_key "dymschs", "itms", column: "itms_id_dym", name: "dymsch_itms_id_dym"
  add_foreign_key "dymschs", "opeitms", column: "opeitms_id", name: "dymsch_opeitms_id"
  add_foreign_key "dymschs", "persons", column: "persons_id_upd", name: "dymsch_persons_id_upd"
  add_foreign_key "dymschs", "prjnos", column: "prjnos_id", name: "dymsch_prjnos_id"
  add_foreign_key "dymschs", "shelfnos", column: "shelfnos_id", name: "dymsch_shelfnos_id"
  add_foreign_key "dymschs", "shelfnos", column: "shelfnos_id_to", name: "dymsch_shelfnos_id_to"
  add_foreign_key "ercacts", "fcoperators", column: "fcoperators_id", name: "ercact_fcoperators_id"
  add_foreign_key "ercacts", "persons", column: "persons_id_upd", name: "ercact_persons_id_upd"
  add_foreign_key "ercacts", "prdacts", column: "prdacts_id_ercact", name: "ercact_prdacts_id_ercact"
  add_foreign_key "ercacts", "prjnos", column: "prjnos_id", name: "ercact_prjnos_id"
  add_foreign_key "ercinsts", "fcoperators", column: "fcoperators_id", name: "ercinst_fcoperators_id"
  add_foreign_key "ercinsts", "persons", column: "persons_id_upd", name: "ercinst_persons_id_upd"
  add_foreign_key "ercinsts", "prdinsts", column: "prdinsts_id_ercinst", name: "ercinst_prdinsts_id_ercinst"
  add_foreign_key "ercinsts", "prjnos", column: "prjnos_id", name: "ercinst_prjnos_id"
  add_foreign_key "ercords", "fcoperators", column: "fcoperators_id", name: "ercord_fcoperators_id"
  add_foreign_key "ercords", "persons", column: "persons_id_upd", name: "ercord_persons_id_upd"
  add_foreign_key "ercords", "prdords", column: "prdords_id_ercord", name: "ercord_prdords_id_ercord"
  add_foreign_key "ercords", "prjnos", column: "prjnos_id", name: "ercord_prjnos_id"
  add_foreign_key "ercschs", "fcoperators", column: "fcoperators_id", name: "ercsch_fcoperators_id"
  add_foreign_key "ercschs", "persons", column: "persons_id_upd", name: "ercsch_persons_id_upd"
  add_foreign_key "ercschs", "prdschs", column: "prdschs_id_ercsch", name: "ercsch_prdschs_id_ercsch"
  add_foreign_key "ercschs", "prjnos", column: "prjnos_id", name: "ercsch_prjnos_id"
  add_foreign_key "facilities", "chrgs", column: "chrgs_id_facilitie", name: "facilitie_chrgs_id_facilitie"
  add_foreign_key "facilities", "itms", column: "itms_id", name: "facilitie_itms_id"
  add_foreign_key "facilities", "persons", column: "persons_id_upd", name: "facilitie_persons_id_upd"
  add_foreign_key "facilities", "shelfnos", column: "shelfnos_id", name: "facilitie_shelfnos_id"
  add_foreign_key "facilitycalendars", "facilities", column: "facilities_id", name: "facilitycalendar_facilities_id"
  add_foreign_key "facilitycalendars", "locas", column: "locas_id_pare", name: "facilitycalendar_locas_id_pare"
  add_foreign_key "facilitycalendars", "persons", column: "persons_id_upd", name: "facilitycalendar_persons_id_upd"
  add_foreign_key "fcoperators", "chrgs", column: "chrgs_id_fcoperator", name: "fcoperator_chrgs_id"
  add_foreign_key "fcoperators", "chrgs", column: "chrgs_id_fcoperator", name: "fcoperator_chrgs_id_fcoperator"
  add_foreign_key "fcoperators", "itms", column: "itms_id_fcoperator", name: "fcoperator_itms_id_fcoperator"
  add_foreign_key "fcoperators", "persons", column: "persons_id_upd", name: "fcoperator_persons_id_upd"
  add_foreign_key "fieldcodes", "persons", column: "persons_id_upd", name: "fieldcode_persons_id_upd"
  add_foreign_key "fieldcodes", "pobjects", column: "pobjects_id_fld", name: "fieldcode_pobject_id_fld"
  add_foreign_key "hcalendars", "locas", column: "locas_id", name: "hcalendar_locas_id"
  add_foreign_key "hcalendars", "persons", column: "persons_id_upd", name: "hcalendar_persons_id_upd"
  add_foreign_key "inamts", "alloctbls", column: "alloctbls_id", name: "inamt_alloctbls_id"
  add_foreign_key "inamts", "crrs", column: "crrs_id", name: "inamt_crrs_id"
  add_foreign_key "inamts", "locas", column: "locas_id_in", name: "inamt_locas_id_in"
  add_foreign_key "inamts", "persons", column: "persons_id_upd", name: "inamt_persons_id_upd"
  add_foreign_key "incustwhs", "alloctbls", column: "alloctbls_id", name: "incustwh_alloctbls_id"
  add_foreign_key "incustwhs", "custrcvplcs", column: "custrcvplcs_id", name: "incustwh_custrcvplcs_id"
  add_foreign_key "incustwhs", "persons", column: "persons_id_upd", name: "incustwh_persons_id_upd"
  add_foreign_key "inoutlotstks", "persons", column: "persons_id_upd", name: "inoutlotstk_persons_id_upd"
  add_foreign_key "inoutlotstks", "trngantts", column: "trngantts_id", name: "inoutlotstk_trngantts_id"
  add_foreign_key "inspacts", "chrgs", column: "chrgs_id", name: "inspact_chrgs_id"
  add_foreign_key "inspacts", "locas", column: "locas_id_to", name: "inspact_locas_id_to"
  add_foreign_key "inspacts", "opeitms", column: "opeitms_id", name: "inspact_opeitms_id"
  add_foreign_key "inspacts", "persons", column: "persons_id_upd", name: "inspact_persons_id_upd"
  add_foreign_key "inspacts", "prjnos", column: "prjnos_id", name: "inspact_prjnos_id"
  add_foreign_key "inspacts", "reasons", column: "reasons_id", name: "inspact_reasons_id"
  add_foreign_key "inspacts", "shelfnos", column: "shelfnos_id_act", name: "inspact_shelfnos_id_act"
  add_foreign_key "inspacts", "suppliers", column: "suppliers_id", name: "inspact_suppliers_id"
  add_foreign_key "inspinsts", "chrgs", column: "chrgs_id", name: "inspinst_chrgs_id"
  add_foreign_key "inspinsts", "locas", column: "locas_id_to", name: "inspinst_locas_id_to"
  add_foreign_key "inspinsts", "opeitms", column: "opeitms_id", name: "inspinst_opeitms_id"
  add_foreign_key "inspinsts", "persons", column: "persons_id_upd", name: "inspinst_persons_id_upd"
  add_foreign_key "inspinsts", "prjnos", column: "prjnos_id", name: "inspinst_prjnos_id"
  add_foreign_key "inspinsts", "reasons", column: "reasons_id", name: "inspinst_reasons_id"
  add_foreign_key "inspinsts", "suppliers", column: "suppliers_id", name: "inspinst_suppliers_id"
  add_foreign_key "inspords", "chrgs", column: "chrgs_id", name: "inspord_chrgs_id"
  add_foreign_key "inspords", "itms", column: "itms_id", name: "inspord_itms_id"
  add_foreign_key "inspords", "persons", column: "persons_id_upd", name: "inspord_persons_id_upd"
  add_foreign_key "inspords", "reasons", column: "reasons_id", name: "inspord_reasons_id"
  add_foreign_key "inspords", "shelfnos", column: "shelfnos_id_fm", name: "inspord_shelfnos_id_fm"
  add_foreign_key "inspords", "shelfnos", column: "shelfnos_id_to", name: "inspord_shelfnos_id_to"
  add_foreign_key "inspschs", "chrgs", column: "chrgs_id", name: "inspsch_chrgs_id"
  add_foreign_key "inspschs", "locas", column: "locas_id_to", name: "inspsch_locas_id_to"
  add_foreign_key "inspschs", "opeitms", column: "opeitms_id", name: "inspsch_opeitms_id"
  add_foreign_key "inspschs", "persons", column: "persons_id_upd", name: "inspsch_persons_id_upd"
  add_foreign_key "inspschs", "prjnos", column: "prjnos_id", name: "inspsch_prjnos_id"
  add_foreign_key "inspschs", "suppliers", column: "suppliers_id", name: "inspsch_suppliers_id"
  add_foreign_key "instks", "persons", column: "persons_id_upd", name: "instk_persons_id_upd"
  add_foreign_key "instks", "shelfnos", column: "shelfnos_id_in", name: "instk_shelfnos_id_in"
  add_foreign_key "itms", "classlists", column: "classlists_id", name: "itm_classlists_id"
  add_foreign_key "itms", "persons", column: "persons_id_upd", name: "itm_persons_id_upd"
  add_foreign_key "itms", "units", column: "units_id", name: "itm_units_id"
  add_foreign_key "linkcusts", "persons", column: "persons_id_upd", name: "linkcust_persons_id_upd"
  add_foreign_key "linkcusts", "trngantts", column: "trngantts_id", name: "linkcust_trngantts_id"
  add_foreign_key "linkheads", "persons", column: "persons_id_upd", name: "linkhead_persons_id_upd"
  add_foreign_key "linktbls", "persons", column: "persons_id_upd", name: "linktbl_persons_id_upd"
  add_foreign_key "linktbls", "trngantts", column: "trngantts_id", name: "linktbl_trngantts_id"
  add_foreign_key "lotstkhists", "itms", column: "itms_id", name: "lotstkhist_itms_id"
  add_foreign_key "lotstkhists", "persons", column: "persons_id_upd", name: "lotstkhist_persons_id_upd"
  add_foreign_key "lotstkhists", "prjnos", column: "prjnos_id", name: "lotstkhist_prjnos_id"
  add_foreign_key "lotstkhists", "shelfnos", column: "shelfnos_id", name: "lotstkhist_shelfnos_id"
  add_foreign_key "mkbillinsts", "bills", column: "bills_id", name: "mkbillinst_bills_id"
  add_foreign_key "mkbillinsts", "chrgs", column: "chrgs_id", name: "mkbillinst_chrgs_id"
  add_foreign_key "mkbillinsts", "custs", column: "custs_id", name: "mkbillinst_custs_id"
  add_foreign_key "mkbillinsts", "persons", column: "persons_id_upd", name: "mkbillinst_persons_id_upd"
  add_foreign_key "mkordopeitms", "mkords", column: "mkords_id", name: "mkordopeitm_mkords_id"
  add_foreign_key "mkordopeitms", "opeitms", column: "opeitms_id", name: "mkordopeitm_opeitms_id"
  add_foreign_key "mkordopeitms", "persons", column: "persons_id_upd", name: "mkordopeitm_persons_id_upd"
  add_foreign_key "mkordopeitms", "shelfnos", column: "shelfnos_id_to", name: "mkordopeitm_shelfnos_id_to"
  add_foreign_key "mkordorgs", "itms", column: "itms_id", name: "mkordorg_itms_id"
  add_foreign_key "mkordorgs", "locas", column: "locas_id", name: "mkordorg_locas_id"
  add_foreign_key "mkordorgs", "mkprdpurords", column: "mkprdpurords_id", name: "mkordorg_mkprdpurords_id"
  add_foreign_key "mkordorgs", "persons", column: "persons_id_upd", name: "mkordorg_persons_id_upd"
  add_foreign_key "mkordorgs", "prjnos", column: "prjnos_id", name: "mkordorg_prjnos_id"
  add_foreign_key "mkordorgs", "shelfnos", column: "shelfnos_id", name: "mkordorg_shelfnos_id"
  add_foreign_key "mkordorgs", "shelfnos", column: "shelfnos_id_to", name: "mkordorg_shelfnos_id_to"
  add_foreign_key "mkords", "persons", column: "persons_id_upd", name: "mkord_persons_id_upd"
  add_foreign_key "mkordterms", "itms", column: "itms_id", name: "mkordterm_itms_id"
  add_foreign_key "mkordterms", "locas", column: "locas_id", name: "mkordterm_locas_id"
  add_foreign_key "mkordterms", "mkprdpurords", column: "mkprdpurords_id", name: "mkordterm_mkprdpurords_id"
  add_foreign_key "mkordterms", "persons", column: "persons_id_upd", name: "mkordterm_persons_id_upd"
  add_foreign_key "mkordterms", "prjnos", column: "prjnos_id", name: "mkordterm_prjnos_id"
  add_foreign_key "mkordterms", "shelfnos", column: "shelfnos_id", name: "mkordterm_shelfnos_id"
  add_foreign_key "mkordterms", "shelfnos", column: "shelfnos_id_to", name: "mkordterm_shelfnos_id_to"
  add_foreign_key "mkordtmpfs", "itms", column: "itms_id_pare", name: "mkordtmpf_itms_id_pare"
  add_foreign_key "mkordtmpfs", "itms", column: "itms_id_trn", name: "mkordtmpf_itms_id_trn"
  add_foreign_key "mkordtmpfs", "locas", column: "locas_id_pare", name: "mkordtmpf_locas_id_pare"
  add_foreign_key "mkordtmpfs", "locas", column: "locas_id_to_trn", name: "mkordtmpf_locas_id_to_trn"
  add_foreign_key "mkordtmpfs", "locas", column: "locas_id_trn", name: "mkordtmpf_locas_id_trn"
  add_foreign_key "mkordtmpfs", "mkprdpurords", column: "mkprdpurords_id", name: "mkordtmpf_mkprdpurords_id"
  add_foreign_key "mkordtmpfs", "persons", column: "persons_id_upd", name: "mkordtmpf_persons_id_upd"
  add_foreign_key "mkordtmpfs", "prjnos", column: "prjnos_id", name: "mkordtmpf_prjnos_id"
  add_foreign_key "mkordtmpfs", "shelfnos", column: "shelfnos_id_pare", name: "mkordtmpf_shelfnos_id_pare"
  add_foreign_key "mkordtmpfs", "shelfnos", column: "shelfnos_id_to_pare", name: "mkordtmpf_shelfnos_id_to_pare"
  add_foreign_key "mkordtmpfs", "shelfnos", column: "shelfnos_id_to_trn", name: "mkordtmpf_shelfnos_id_to_trn"
  add_foreign_key "mkordtmpfs", "shelfnos", column: "shelfnos_id_trn", name: "mkordtmpf_shelfnos_id_trn"
  add_foreign_key "mkpayinsts", "chrgs", column: "chrgs_id", name: "mkpayinst_chrgs_id"
  add_foreign_key "mkpayinsts", "payments", column: "payments_id", name: "mkpayinst_payments_id"
  add_foreign_key "mkpayinsts", "persons", column: "persons_id_upd", name: "mkpayinst_persons_id_upd"
  add_foreign_key "mkpayinsts", "suppliers", column: "suppliers_id", name: "mkpayinst_suppliers_id"
  add_foreign_key "mkprdpurords", "persons", column: "persons_id_upd", name: "mkprdpurord_persons_id_upd"
  add_foreign_key "mkshps", "itms", column: "itms_id_org", name: "mkshp_itms_id_org"
  add_foreign_key "mkshps", "itms", column: "itms_id_pare", name: "mkshp_itms_id_pare"
  add_foreign_key "mkshps", "locas", column: "locas_id_org", name: "mkshp_locas_id_org"
  add_foreign_key "mkshps", "locas", column: "locas_id_pare", name: "mkshp_locas_id_pare"
  add_foreign_key "mkshps", "persons", column: "persons_id_upd", name: "mkshp_persons_id_upd"
  add_foreign_key "mnfacts", "persons", column: "persons_id_upd", name: "mnfact_persons_id_upd"
  add_foreign_key "mnfacts", "prjnos", column: "prjnos_id", name: "mnfact_prjnos_id"
  add_foreign_key "mnfinsts", "persons", column: "persons_id_upd", name: "mnfinst_persons_id_upd"
  add_foreign_key "mnfinsts", "prjnos", column: "prjnos_id", name: "mnfinst_prjnos_id"
  add_foreign_key "mnfords", "persons", column: "persons_id_upd", name: "mnford_persons_id_upd"
  add_foreign_key "mnfords", "prjnos", column: "prjnos_id", name: "mnford_prjnos_id"
  add_foreign_key "mnfschs", "persons", column: "persons_id_upd", name: "mnfsch_persons_id_upd"
  add_foreign_key "mnfschs", "prjnos", column: "prjnos_id", name: "mnfsch_prjnos_id"
  add_foreign_key "movacts", "chrgs", column: "chrgs_id", name: "movact_chrgs_id"
  add_foreign_key "movacts", "locas", column: "locas_id_cause", name: "movact_locas_id_cause"
  add_foreign_key "movacts", "opeitms", column: "opeitms_id", name: "movact_opeitms_id"
  add_foreign_key "movacts", "persons", column: "persons_id_upd", name: "movact_persons_id_upd"
  add_foreign_key "movacts", "prjnos", column: "prjnos_id", name: "movact_prjnos_id"
  add_foreign_key "movacts", "shelfnos", column: "shelfnos_id_fm", name: "movact_shelfnos_id_fm"
  add_foreign_key "movacts", "shelfnos", column: "shelfnos_id_to", name: "movact_shelfnos_id_to"
  add_foreign_key "ndfcts", "facilities", column: "facilities_id_ndfct", name: "ndfct_facilities_id_ndfct"
  add_foreign_key "ndfcts", "opeitms", column: "opeitms_id", name: "ndfct_opeitms_id"
  add_foreign_key "ndfcts", "persons", column: "persons_id_upd", name: "ndfct_persons_id_upd"
  add_foreign_key "nditms", "itms", column: "itms_id_nditm", name: "nditm_itms_id_nditm"
  add_foreign_key "nditms", "opeitms", column: "opeitms_id", name: "nditm_opeitms_id"
  add_foreign_key "nditms", "persons", column: "persons_id_upd", name: "nditm_persons_id_upd"
  add_foreign_key "opeitms", "boxes", column: "boxes_id", name: "opeitm_boxes_id"
  add_foreign_key "opeitms", "itms", column: "itms_id", name: "opeitm_itms_id"
  add_foreign_key "opeitms", "persons", column: "persons_id_upd", name: "opeitm_persons_id_upd"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_opeitm", name: "opeitm_shelfnos_id_fm"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_opeitm", name: "opeitm_shelfnos_id_fm_opeitm"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_opeitm", name: "opeitm_shelfnos_id_opeitm"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_to_opeitm", name: "opeitm_shelfnos_id_to"
  add_foreign_key "opeitms", "shelfnos", column: "shelfnos_id_to_opeitm", name: "opeitm_shelfnos_id_to_opeitm"
  add_foreign_key "opeitms", "units", column: "units_id_case_prdpur", name: "opeitm_units_id_case_prdpur"
  add_foreign_key "opeitms", "units", column: "units_id_case_shp", name: "opeitm_units_id_case_shp"
  add_foreign_key "opeitms", "units", column: "units_id_size", name: "opeitm_units_id_size"
  add_foreign_key "opeitms", "units", column: "units_id_weight", name: "opeitm_units_id_weight"
  add_foreign_key "outamts", "alloctbls", column: "alloctbls_id", name: "outamt_alloctbls_id"
  add_foreign_key "outamts", "crrs", column: "crrs_id", name: "outamt_crrs_id"
  add_foreign_key "outamts", "locas", column: "locas_id_out", name: "outamt_locas_id_out"
  add_foreign_key "outamts", "persons", column: "persons_id_upd", name: "outamt_persons_id_upd"
  add_foreign_key "outstks", "persons", column: "persons_id_upd", name: "outstk_persons_id_upd"
  add_foreign_key "outstks", "shelfnos", column: "shelfnos_id_out", name: "outstk_shelfnos_id_out"
  add_foreign_key "payacts", "chrgs", column: "chrgs_id", name: "payact_chrgs_id"
  add_foreign_key "payacts", "payments", column: "payments_id", name: "payact_payments_id"
  add_foreign_key "payacts", "persons", column: "persons_id_upd", name: "payact_persons_id_upd"
  add_foreign_key "payinsts", "chrgs", column: "chrgs_id", name: "payinst_chrgs_id"
  add_foreign_key "payinsts", "payments", column: "payments_id", name: "payinst_payments_id"
  add_foreign_key "payinsts", "persons", column: "persons_id_upd", name: "payinst_persons_id_upd"
  add_foreign_key "payments", "chrgs", column: "chrgs_id_payment", name: "payment_chrgs_id_payment"
  add_foreign_key "payments", "crrs", column: "crrs_id_payment", name: "payment_crrs_id_payment"
  add_foreign_key "payments", "locas", column: "locas_id_payment", name: "payment_locas_id_payment"
  add_foreign_key "payments", "persons", column: "persons_id_upd", name: "payment_persons_id_upd"
  add_foreign_key "payords", "chrgs", column: "chrgs_id", name: "payord_chrgs_id"
  add_foreign_key "payords", "payments", column: "payments_id", name: "payord_payments_id"
  add_foreign_key "payords", "persons", column: "persons_id_upd", name: "payord_persons_id_upd"
  add_foreign_key "payords", "suppliers", column: "suppliers_id", name: "payord_suppliers_id"
  add_foreign_key "payschs", "chrgs", column: "chrgs_id", name: "paysch_chrgs_id"
  add_foreign_key "payschs", "payments", column: "payments_id", name: "paysch_payments_id"
  add_foreign_key "payschs", "persons", column: "persons_id_upd", name: "paysch_persons_id_upd"
  add_foreign_key "personcalendars", "locas", column: "locas_id_pare", name: "personcalendar_locas_id_pare"
  add_foreign_key "personcalendars", "persons", column: "persons_id", name: "personcalendar_persons_id"
  add_foreign_key "personcalendars", "persons", column: "persons_id_upd", name: "personcalendar_persons_id_upd"
  add_foreign_key "persons", "persons", column: "persons_id_upd", name: "persons_persons_id_upd"
  add_foreign_key "persons", "scrlvs", column: "scrlvs_id", name: "persons_scrlvs_id"
  add_foreign_key "persons", "sects", column: "sects_id", name: "persons_sects_id"
  add_foreign_key "persons", "usrgrps", column: "usrgrps_id", name: "persons_usrgrps_id"
  add_foreign_key "pobjects", "persons", column: "persons_id_upd", name: "pobject_persons_id_upd"
  add_foreign_key "pobjgrps", "persons", column: "persons_id_upd", name: "pobjgrp_persons_id_upd"
  add_foreign_key "pobjgrps", "pobjects", column: "pobjects_id", name: "pobjgrp_pobjects_id"
  add_foreign_key "pobjgrps", "usrgrps", column: "usrgrps_id", name: "pobjgrp_usrgrps_id"
  add_foreign_key "prdacts", "chrgs", column: "chrgs_id", name: "prdact_chrgs_id"
  add_foreign_key "prdacts", "opeitms", column: "opeitms_id", name: "prdact_opeitms_id"
  add_foreign_key "prdacts", "persons", column: "persons_id_upd", name: "prdact_persons_id_upd"
  add_foreign_key "prdacts", "prjnos", column: "prjnos_id", name: "prdact_prjnos_id"
  add_foreign_key "prdacts", "shelfnos", column: "shelfnos_id", name: "prdact_shelfnos_id"
  add_foreign_key "prdacts", "shelfnos", column: "shelfnos_id_to", name: "prdact_shelfnos_id_to"
  add_foreign_key "prdests", "chrgs", column: "chrgs_id", name: "prdest_chrgs_id"
  add_foreign_key "prdests", "persons", column: "persons_id_upd", name: "prdest_persons_id_upd"
  add_foreign_key "prdinsts", "chrgs", column: "chrgs_id", name: "prdinst_chrgs_id"
  add_foreign_key "prdinsts", "opeitms", column: "opeitms_id", name: "prdinst_opeitms_id"
  add_foreign_key "prdinsts", "persons", column: "persons_id_upd", name: "prdinst_persons_id_upd"
  add_foreign_key "prdinsts", "prjnos", column: "prjnos_id", name: "prdinst_prjnos_id"
  add_foreign_key "prdinsts", "shelfnos", column: "shelfnos_id", name: "prdinst_shelfnos_id"
  add_foreign_key "prdinsts", "shelfnos", column: "shelfnos_id_to", name: "prdinst_shelfnos_id_to"
  add_foreign_key "prdords", "chrgs", column: "chrgs_id", name: "prdord_chrgs_id"
  add_foreign_key "prdords", "opeitms", column: "opeitms_id", name: "prdord_opeitms_id"
  add_foreign_key "prdords", "persons", column: "persons_id_upd", name: "prdord_persons_id_upd"
  add_foreign_key "prdords", "prjnos", column: "prjnos_id", name: "prdord_prjnos_id"
  add_foreign_key "prdords", "shelfnos", column: "shelfnos_id", name: "prdord_shelfnos_id"
  add_foreign_key "prdords", "shelfnos", column: "shelfnos_id_to", name: "prdord_shelfnos_id_to"
  add_foreign_key "prdreplyinputs", "opeitms", column: "opeitms_id", name: "prdreplyinput_opeitms_id"
  add_foreign_key "prdreplyinputs", "persons", column: "persons_id_upd", name: "prdreplyinput_persons_id_upd"
  add_foreign_key "prdreplyinputs", "shelfnos", column: "shelfnos_id", name: "prdreplyinput_shelfnos_id"
  add_foreign_key "prdrets", "chrgs", column: "chrgs_id", name: "prdret_chrgs_id"
  add_foreign_key "prdrets", "locas", column: "locas_id_fm", name: "prdret_locas_id_fm"
  add_foreign_key "prdrets", "opeitms", column: "opeitms_id", name: "prdret_opeitms_id"
  add_foreign_key "prdrets", "persons", column: "persons_id_upd", name: "prdret_persons_id_upd"
  add_foreign_key "prdrets", "prjnos", column: "prjnos_id", name: "prdret_prjnos_id"
  add_foreign_key "prdrsltinputs", "persons", column: "persons_id_upd", name: "prdrsltinput_persons_id_upd"
  add_foreign_key "prdschs", "chrgs", column: "chrgs_id", name: "prdsch_chrgs_id"
  add_foreign_key "prdschs", "opeitms", column: "opeitms_id", name: "prdsch_opeitms_id"
  add_foreign_key "prdschs", "persons", column: "persons_id_upd", name: "prdsch_persons_id_upd"
  add_foreign_key "prdschs", "prjnos", column: "prjnos_id", name: "prdsch_prjnos_id"
  add_foreign_key "prdschs", "shelfnos", column: "shelfnos_id", name: "prdsch_shelfnos_id"
  add_foreign_key "prdschs", "shelfnos", column: "shelfnos_id_to", name: "prdsch_shelfnos_id_to"
  add_foreign_key "prdstrs", "chrgs", column: "chrgs_id", name: "prdstr_chrgs_id"
  add_foreign_key "prdstrs", "persons", column: "persons_id_upd", name: "prdstr_persons_id_upd"
  add_foreign_key "pricemsts", "chrgs", column: "chrgs_id", name: "pricemst_chrgs_id"
  add_foreign_key "pricemsts", "itms", column: "itms_id", name: "pricemst_itms_id"
  add_foreign_key "pricemsts", "locas", column: "locas_id", name: "pricemst_locas_id"
  add_foreign_key "pricemsts", "persons", column: "persons_id_upd", name: "pricemst_persons_id_upd"
  add_foreign_key "prjnos", "persons", column: "persons_id_upd", name: "prjno_persons_id_upd"
  add_foreign_key "prjnos", "prjnos", column: "prjnos_id_chil", name: "prjno_prjnos_id_chil"
  add_foreign_key "prjnos", "prjnos", column: "prjnos_id_chil", name: "prjnos_id_chil"
  add_foreign_key "processcontrols", "persons", column: "persons_id_upd", name: "processcontrol_persons_id_upd"
  add_foreign_key "processreqs", "persons", column: "persons_id_upd", name: "processreq_persons_id_upd"
  add_foreign_key "puractheads", "chrgs", column: "chrgs_id", name: "puracthead_chrgs_id"
  add_foreign_key "puractheads", "crrs", column: "crrs_id", name: "puracthead_crrs_id"
  add_foreign_key "puractheads", "persons", column: "persons_id_upd", name: "puracthead_persons_id_upd"
  add_foreign_key "puractheads", "suppliers", column: "suppliers_id", name: "puracthead_suppliers_id"
  add_foreign_key "puracts", "chrgs", column: "chrgs_id", name: "puract_chrgs_id"
  add_foreign_key "puracts", "crrs", column: "crrs_id", name: "puract_crrs_id"
  add_foreign_key "puracts", "opeitms", column: "opeitms_id", name: "puract_opeitms_id"
  add_foreign_key "puracts", "persons", column: "persons_id_upd", name: "puract_persons_id_upd"
  add_foreign_key "puracts", "prjnos", column: "prjnos_id", name: "puract_prjnos_id"
  add_foreign_key "puracts", "shelfnos", column: "shelfnos_id_to", name: "puract_shelfnos_id_to"
  add_foreign_key "puracts", "suppliers", column: "suppliers_id", name: "puract_suppliers_id"
  add_foreign_key "purdlvs", "chrgs", column: "chrgs_id", name: "purdlv_chrgs_id"
  add_foreign_key "purdlvs", "crrs", column: "crrs_id", name: "purdlv_crrs_id"
  add_foreign_key "purdlvs", "opeitms", column: "opeitms_id", name: "purdlv_opeitms_id"
  add_foreign_key "purdlvs", "persons", column: "persons_id_upd", name: "purdlv_persons_id_upd"
  add_foreign_key "purdlvs", "prjnos", column: "prjnos_id", name: "purdlv_prjnos_id"
  add_foreign_key "purdlvs", "shelfnos", column: "shelfnos_id_to", name: "purdlv_shelfnos_id_to"
  add_foreign_key "purdlvs", "suppliers", column: "suppliers_id", name: "purdlv_suppliers_id"
  add_foreign_key "purests", "chrgs", column: "chrgs_id", name: "purest_chrgs_id"
  add_foreign_key "purests", "persons", column: "persons_id_upd", name: "purest_persons_id_upd"
  add_foreign_key "purests", "suppliers", column: "suppliers_id", name: "purest_suppliers_id"
  add_foreign_key "purinsts", "chrgs", column: "chrgs_id", name: "purinst_chrgs_id"
  add_foreign_key "purinsts", "crrs", column: "crrs_id", name: "purinst_crrs_id"
  add_foreign_key "purinsts", "opeitms", column: "opeitms_id", name: "purinst_opeitms_id"
  add_foreign_key "purinsts", "persons", column: "persons_id_upd", name: "purinst_persons_id_upd"
  add_foreign_key "purinsts", "prjnos", column: "prjnos_id", name: "purinst_prjnos_id"
  add_foreign_key "purinsts", "shelfnos", column: "shelfnos_id_to", name: "purinst_shelfnos_id_to"
  add_foreign_key "purinsts", "suppliers", column: "suppliers_id", name: "purinst_suppliers_id"
  add_foreign_key "purords", "chrgs", column: "chrgs_id", name: "purord_chrgs_id"
  add_foreign_key "purords", "crrs", column: "crrs_id", name: "purord_crrs_id"
  add_foreign_key "purords", "opeitms", column: "opeitms_id", name: "purord_opeitms_id"
  add_foreign_key "purords", "persons", column: "persons_id_upd", name: "purord_persons_id_upd"
  add_foreign_key "purords", "prjnos", column: "prjnos_id", name: "purord_prjnos_id"
  add_foreign_key "purords", "shelfnos", column: "shelfnos_id_to", name: "purord_shelfnos_id_to"
  add_foreign_key "purords", "suppliers", column: "suppliers_id", name: "purord_suppliers_id"
  add_foreign_key "purreplyinputs", "opeitms", column: "opeitms_id", name: "purreplyinput_opeitms_id"
  add_foreign_key "purreplyinputs", "persons", column: "persons_id_upd", name: "purreplyinput_persons_id_upd"
  add_foreign_key "purreplyinputs", "shelfnos", column: "shelfnos_id_to", name: "purreplyinput_shelfnos_id_to"
  add_foreign_key "purrets", "chrgs", column: "chrgs_id", name: "purret_chrgs_id"
  add_foreign_key "purrets", "crrs", column: "crrs_id", name: "purret_crrs_id"
  add_foreign_key "purrets", "locas", column: "locas_id_fm", name: "purret_locas_id_fm"
  add_foreign_key "purrets", "opeitms", column: "opeitms_id", name: "purret_opeitms_id"
  add_foreign_key "purrets", "persons", column: "persons_id_upd", name: "purret_persons_id_upd"
  add_foreign_key "purrets", "prjnos", column: "prjnos_id", name: "purret_prjnos_id"
  add_foreign_key "purrets", "suppliers", column: "suppliers_id", name: "purret_suppliers_id"
  add_foreign_key "purrsltinputs", "crrs", column: "crrs_id", name: "purrsltinput_crrs_id"
  add_foreign_key "purrsltinputs", "persons", column: "persons_id_upd", name: "purrsltinput_persons_id_upd"
  add_foreign_key "purrsltinputs", "shelfnos", column: "shelfnos_id_to", name: "purrsltinput_shelfnos_id_to"
  add_foreign_key "purschs", "chrgs", column: "chrgs_id", name: "pursch_chrgs_id"
  add_foreign_key "purschs", "crrs", column: "crrs_id", name: "pursch_crrs_id"
  add_foreign_key "purschs", "opeitms", column: "opeitms_id", name: "pursch_opeitms_id"
  add_foreign_key "purschs", "persons", column: "persons_id_upd", name: "pursch_persons_id_upd"
  add_foreign_key "purschs", "prjnos", column: "prjnos_id", name: "pursch_prjnos_id"
  add_foreign_key "purschs", "shelfnos", column: "shelfnos_id_to", name: "pursch_shelfnos_id_to"
  add_foreign_key "purschs", "suppliers", column: "suppliers_id", name: "pursch_suppliers_id"
  add_foreign_key "reasons", "persons", column: "persons_id_upd", name: "reason_persons_id_upd"
  add_foreign_key "rejections", "chrgs", column: "chrgs_id", name: "rejection_chrgs_id"
  add_foreign_key "rejections", "locas", column: "locas_id_cause", name: "rejection_locas_id_cause"
  add_foreign_key "rejections", "opeitms", column: "opeitms_id", name: "rejection_opeitms_id"
  add_foreign_key "rejections", "persons", column: "persons_id_upd", name: "rejection_persons_id_upd"
  add_foreign_key "rejections", "shelfnos", column: "shelfnos_id_to", name: "rejection_shelfnos_id_to"
  add_foreign_key "reports", "persons", column: "persons_id_upd", name: "report_persons_id_upd"
  add_foreign_key "reports", "usrgrps", column: "usrgrps_id", name: "report_usrgrps_id"
  add_foreign_key "rubycodings", "persons", column: "persons_id_upd", name: "rubycoding_persons_id_upd"
  add_foreign_key "rules", "persons", column: "persons_id_upd", name: "rule_persons_id_upd"
  add_foreign_key "schofmkords", "itms", column: "itms_id", name: "schofmkord_itms_id"
  add_foreign_key "schofmkords", "persons", column: "persons_id_upd", name: "schofmkord_persons_id_upd"
  add_foreign_key "schofmkords", "trngantts", column: "trngantts_id", name: "schofmkord_trngantts_id"
  add_foreign_key "screenfields", "persons", column: "persons_id_upd", name: "screenfield_persons_id_upd"
  add_foreign_key "screenfields", "pobjects", column: "pobjects_id_sfd", name: "screenfield_pobjects_id_sfd"
  add_foreign_key "screenfields", "screens", column: "screens_id", name: "screenfield_screens_id"
  add_foreign_key "screenfields", "tblfields", column: "tblfields_id", name: "screenfield_tblfields_id"
  add_foreign_key "screens", "persons", column: "persons_id_upd", name: "screen_persons_id_upd"
  add_foreign_key "screens", "pobjects", column: "pobjects_id_scr", name: "screen_pobjects_id_scr"
  add_foreign_key "screens", "pobjects", column: "pobjects_id_sgrp", name: "screen_pobjects_id_sgrp"
  add_foreign_key "screens", "pobjects", column: "pobjects_id_view", name: "screen_pobjects_id_view"
  add_foreign_key "screens", "scrlvs", column: "scrlvs_id", name: "screen_scrlvs_id"
  add_foreign_key "scrlvs", "persons", column: "persons_id_upd", name: "scrlvs_persons_id_upd"
  add_foreign_key "sects", "locas", column: "locas_id_pare", name: "sect_locas_id_pare"
  add_foreign_key "sects", "locas", column: "locas_id_sect", name: "sect_locas_id_sect"
  add_foreign_key "sects", "locas", column: "locas_id_sect", name: "sects_locas_id_sect"
  add_foreign_key "sects", "persons", column: "persons_id_upd", name: "sect_persons_id_upd"
  add_foreign_key "shelfnos", "locas", column: "locas_id_shelfno", name: "shelfno_locas_id_shelfno"
  add_foreign_key "shelfnos", "persons", column: "persons_id_upd", name: "shelfno_persons_id_upd"
  add_foreign_key "shpacts", "chrgs", column: "chrgs_id", name: "shpact_chrgs_id"
  add_foreign_key "shpacts", "crrs", column: "crrs_id", name: "shpact_crrs_id"
  add_foreign_key "shpacts", "itms", column: "itms_id", name: "shpact_itms_id"
  add_foreign_key "shpacts", "persons", column: "persons_id_upd", name: "shpact_persons_id_upd"
  add_foreign_key "shpacts", "prjnos", column: "prjnos_id", name: "shpact_prjnos_id"
  add_foreign_key "shpacts", "shelfnos", column: "shelfnos_id_fm", name: "shpact_shelfnos_id_fm"
  add_foreign_key "shpacts", "shelfnos", column: "shelfnos_id_to", name: "shpact_shelfnos_id_to"
  add_foreign_key "shpacts", "transports", column: "transports_id", name: "shpact_transports_id"
  add_foreign_key "shpacts", "units", column: "units_id_case_shp", name: "shpact_units_id_case_shp"
  add_foreign_key "shpests", "chrgs", column: "chrgs_id", name: "shpest_chrgs_id"
  add_foreign_key "shpests", "itms", column: "itms_id", name: "shpest_itms_id"
  add_foreign_key "shpests", "persons", column: "persons_id_upd", name: "shpest_persons_id_upd"
  add_foreign_key "shpests", "prjnos", column: "prjnos_id", name: "shpest_prjnos_id"
  add_foreign_key "shpests", "shelfnos", column: "shelfnos_id_fm", name: "shpest_shelfnos_id_fm"
  add_foreign_key "shpests", "shelfnos", column: "shelfnos_id_to", name: "shpest_shelfnos_id_to"
  add_foreign_key "shpests", "transports", column: "transports_id", name: "shpest_transports_id"
  add_foreign_key "shpests", "units", column: "units_id_case_shp", name: "shpest_units_id_case_shp"
  add_foreign_key "shpinsts", "chrgs", column: "chrgs_id", name: "shpinst_chrgs_id"
  add_foreign_key "shpinsts", "crrs", column: "crrs_id", name: "shpinst_crrs_id"
  add_foreign_key "shpinsts", "itms", column: "itms_id", name: "shpinst_itms_id"
  add_foreign_key "shpinsts", "persons", column: "persons_id_upd", name: "shpinst_persons_id_upd"
  add_foreign_key "shpinsts", "prjnos", column: "prjnos_id", name: "shpinst_prjnos_id"
  add_foreign_key "shpinsts", "shelfnos", column: "shelfnos_id_fm", name: "shpinst_shelfnos_id_fm"
  add_foreign_key "shpinsts", "shelfnos", column: "shelfnos_id_to", name: "shpinst_shelfnos_id_to"
  add_foreign_key "shpinsts", "transports", column: "transports_id", name: "shpinst_transports_id"
  add_foreign_key "shpinsts", "units", column: "units_id_case_shp", name: "shpinst_units_id_case_shp"
  add_foreign_key "shpords", "chrgs", column: "chrgs_id", name: "shpord_chrgs_id"
  add_foreign_key "shpords", "crrs", column: "crrs_id", name: "shpord_crrs_id"
  add_foreign_key "shpords", "itms", column: "itms_id", name: "shpord_itms_id"
  add_foreign_key "shpords", "persons", column: "persons_id_upd", name: "shpord_persons_id_upd"
  add_foreign_key "shpords", "prjnos", column: "prjnos_id", name: "shpord_prjnos_id"
  add_foreign_key "shpords", "shelfnos", column: "shelfnos_id_fm", name: "shpord_shelfnos_id_fm"
  add_foreign_key "shpords", "shelfnos", column: "shelfnos_id_to", name: "shpord_shelfnos_id_to"
  add_foreign_key "shpords", "transports", column: "transports_id", name: "shpord_transports_id"
  add_foreign_key "shpords", "units", column: "units_id_case_shp", name: "shpord_units_id_case_shp"
  add_foreign_key "shpreplyinputs", "persons", column: "persons_id_upd", name: "shpreplyinput_persons_id_upd"
  add_foreign_key "shpreplyinputs", "transports", column: "transports_id", name: "shpreplyinput_transports_id"
  add_foreign_key "shprets", "chrgs", column: "chrgs_id", name: "shpret_chrgs_id"
  add_foreign_key "shprets", "crrs", column: "crrs_id", name: "shpret_crrs_id"
  add_foreign_key "shprets", "itms", column: "itms_id", name: "shpret_itms_id"
  add_foreign_key "shprets", "persons", column: "persons_id_upd", name: "shpret_persons_id_upd"
  add_foreign_key "shprets", "prjnos", column: "prjnos_id", name: "shpret_prjnos_id"
  add_foreign_key "shprets", "shelfnos", column: "shelfnos_id_fm", name: "shpret_shelfnos_id_fm"
  add_foreign_key "shprets", "shelfnos", column: "shelfnos_id_to", name: "shpret_shelfnos_id_to"
  add_foreign_key "shprsltinputs", "persons", column: "persons_id_upd", name: "shprsltinput_persons_id_upd"
  add_foreign_key "shprsltinputs", "shelfnos", column: "shelfnos_id_fm", name: "shprsltinput_shelfnos_id_fm"
  add_foreign_key "shprsltinputs", "transports", column: "transports_id", name: "shprsltinput_transports_id"
  add_foreign_key "shpschs", "chrgs", column: "chrgs_id", name: "shpsch_chrgs_id"
  add_foreign_key "shpschs", "itms", column: "itms_id", name: "shpsch_itms_id"
  add_foreign_key "shpschs", "persons", column: "persons_id_upd", name: "shpsch_persons_id_upd"
  add_foreign_key "shpschs", "prjnos", column: "prjnos_id", name: "shpsch_prjnos_id"
  add_foreign_key "shpschs", "shelfnos", column: "shelfnos_id_fm", name: "shpsch_shelfnos_id_fm"
  add_foreign_key "shpschs", "shelfnos", column: "shelfnos_id_to", name: "shpsch_shelfnos_id_to"
  add_foreign_key "shpschs", "transports", column: "transports_id", name: "shpsch_transports_id"
  add_foreign_key "shpschs", "units", column: "units_id_case_shp", name: "shpsch_units_id_case_shp"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "srctbllinks", "persons", column: "persons_id_upd", name: "srctbllink_persons_id_upd"
  add_foreign_key "srctbls", "persons", column: "persons_id_upd", name: "srctbl_persons_id_upd"
  add_foreign_key "supplierprices", "chrgs", column: "chrgs_id", name: "supplierprice_chrgs_id"
  add_foreign_key "supplierprices", "crrs", column: "crrs_id_supplierprice", name: "supplierprice_crrs_id_supplierprice"
  add_foreign_key "supplierprices", "opeitms", column: "opeitms_id", name: "supplierprice_opeitms_id"
  add_foreign_key "supplierprices", "persons", column: "persons_id_upd", name: "supplierprice_persons_id_upd"
  add_foreign_key "supplierprices", "suppliers", column: "suppliers_id", name: "supplierprice_suppliers_id"
  add_foreign_key "suppliers", "chrgs", column: "chrgs_id_supplier", name: "supplier_chrgs_id_supplier"
  add_foreign_key "suppliers", "crrs", column: "crrs_id_supplier", name: "supplier_crrs_id_supplier"
  add_foreign_key "suppliers", "locas", column: "locas_id_calendar", name: "supplier_locas_id_calendar"
  add_foreign_key "suppliers", "locas", column: "locas_id_supplier", name: "supplier_locas_id_supplier"
  add_foreign_key "suppliers", "payments", column: "payments_id_supplier", name: "supplier_payments_id"
  add_foreign_key "suppliers", "payments", column: "payments_id_supplier", name: "supplier_payments_id_supplier"
  add_foreign_key "suppliers", "persons", column: "persons_id_upd", name: "supplier_persons_id_upd"
  add_foreign_key "supplierwhs", "itms", column: "itms_id", name: "supplierwh_itms_id"
  add_foreign_key "supplierwhs", "persons", column: "persons_id_upd", name: "supplierwh_persons_id_upd"
  add_foreign_key "supplierwhs", "suppliers", column: "suppliers_id", name: "supplierwh_suppliers_id"
  add_foreign_key "taxtbls", "persons", column: "persons_id_upd", name: "taxtbl_persons_id_upd"
  add_foreign_key "tblfields", "blktbs", column: "blktbs_id", name: "tblfield_blktbs_id"
  add_foreign_key "tblfields", "fieldcodes", column: "fieldcodes_id", name: "tblfield_fieldcodes_id"
  add_foreign_key "tblfields", "persons", column: "persons_id_upd", name: "tblfield_persons_id_upd"
  add_foreign_key "tblinkflds", "persons", column: "persons_id_upd", name: "tblinkfld_persons_id_upd"
  add_foreign_key "tblinkflds", "tblfields", column: "tblfields_id", name: "tblinkfld_tblfields_id"
  add_foreign_key "tblinkflds", "tblinks", column: "tblinks_id", name: "tblinkfld_tblinks_id"
  add_foreign_key "tblinks", "blktbs", column: "blktbs_id_dest", name: "tblink_blktbs_id_dest"
  add_foreign_key "tblinks", "persons", column: "persons_id_upd", name: "tblink_persons_id_upd"
  add_foreign_key "transports", "locas", column: "locas_id_fm_transport", name: "transport_locas_id_fm"
  add_foreign_key "transports", "locas", column: "locas_id_fm_transport", name: "transport_locas_id_fm_transport"
  add_foreign_key "transports", "locas", column: "locas_id_to_transport", name: "transport_locas_id_to"
  add_foreign_key "transports", "locas", column: "locas_id_to_transport", name: "transport_locas_id_to_transport"
  add_foreign_key "transports", "locas", column: "locas_id_transport", name: "transport_locas_id"
  add_foreign_key "transports", "locas", column: "locas_id_transport", name: "transport_locas_id_transport"
  add_foreign_key "transports", "persons", column: "persons_id_upd", name: "transport_persons_id_upd"
  add_foreign_key "trngantts", "chrgs", column: "chrgs_id_org", name: "trngantt_chrgs_id_org"
  add_foreign_key "trngantts", "chrgs", column: "chrgs_id_pare", name: "trngantt_chrgs_id_pare"
  add_foreign_key "trngantts", "chrgs", column: "chrgs_id_trn", name: "trngantt_chrgs_id_trn"
  add_foreign_key "trngantts", "itms", column: "itms_id_org", name: "trngantt_itms_id_org"
  add_foreign_key "trngantts", "itms", column: "itms_id_pare", name: "trngantt_itms_id_pare"
  add_foreign_key "trngantts", "itms", column: "itms_id_trn", name: "trngantt_itms_id_trn"
  add_foreign_key "trngantts", "mkprdpurords", column: "mkprdpurords_id_trngantt", name: "trngantt_mkprdpurords_id_trngantt"
  add_foreign_key "trngantts", "persons", column: "persons_id_upd", name: "trngantt_persons_id_upd"
  add_foreign_key "trngantts", "prjnos", column: "prjnos_id", name: "trngantt_prjnos_id"
  add_foreign_key "trngantts", "shelfnos", column: "shelfnos_id_org", name: "trngantt_shelfnos_id_org"
  add_foreign_key "trngantts", "shelfnos", column: "shelfnos_id_pare", name: "trngantt_shelfnos_id_pare"
  add_foreign_key "trngantts", "shelfnos", column: "shelfnos_id_to_pare", name: "trngantt_shelfnos_id_to_pare"
  add_foreign_key "trngantts", "shelfnos", column: "shelfnos_id_to_trn", name: "trngantt_shelfnos_id_to_trn"
  add_foreign_key "trngantts", "shelfnos", column: "shelfnos_id_trn", name: "trngantt_shelfnos_id_trn"
  add_foreign_key "units", "persons", column: "persons_id_upd", name: "unit_persons_id_upd"
  add_foreign_key "usebuttons", "buttons", column: "buttons_id", name: "usebutton_buttons_id"
  add_foreign_key "usebuttons", "persons", column: "persons_id_upd", name: "usebutton_persons_id_upd"
  add_foreign_key "usebuttons", "screens", column: "screens_id_ub", name: "usebutton_screens_id_ub"
  add_foreign_key "userprocs", "persons", column: "persons_id_upd", name: "userprocs_persons_id_upd"
  add_foreign_key "workplaces", "chrgs", column: "chrgs_id_workplace", name: "workplace_chrgs_id_workplace"
  add_foreign_key "workplaces", "locas", column: "locas_id_calendar", name: "workplace_locas_id_calendar"
  add_foreign_key "workplaces", "locas", column: "locas_id_workplace", name: "workplace_locas_id_workplace"
  add_foreign_key "workplaces", "persons", column: "persons_id_upd", name: "workplace_persons_id_upd"
end
