json.array!(@box_logins) do |box_login|
  json.extract! box_login, :id, :name, :details
  json.url box_login_url(box_login, format: :json)
end
