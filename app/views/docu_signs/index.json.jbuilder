json.array!(@docu_signs) do |docu_sign|
  json.extract! docu_sign, :company_id, :user_id, :envelope_id, :status
  json.url docu_sign_url(docu_sign, format: :json)
end
