desc "Domo"

task :upload_domo_csv_files => :environment do
  require 'csv'
  puts "I'm starting...."

  session = RubyBox::Session.new({
                                     client_id: ENV['BOX_CLIENT_ID'],
                                     client_secret: ENV['BOX_CLIENT_SECRET'],
                                     access_token: BoxLogin.first.access_token
                                 })


  @client = RubyBox::Client.new(session)

  folders = @client.root_folder.folders
  destination_folder = folders.select {|i| i.name == 'DOMO_DATA'}.first

  puts "got box.com initialized..."

  #connect this process to our follower DB!

  #setup this ENV locally to connect to your other DB if necessary

  ActiveRecord::Base.establish_connection(ENV['HEROKU_POSTGRESQL_CHARCOAL_URL'])


  #line_items upload
  line_items =  ActiveRecord::Base.connection.execute(<<SQL)

SELECT products.account_id, line_items.cost, line_items.id, line_items.name, line_items.created_at, line_items.discount_percent, line_items.estimate_id,
estimated_quantity, line_items.invoice_bundle_id, line_items.invoice_bundle_line_id,
line_items.invoice_id, line_items.item, line_items.price, (line_items.quantity * line_items.cost) as cost_extended, (line_items.quantity * line_items.price) as price_extended, (line_items.quantity * (line_items.price - line_items.cost)) as net, line_items.product_category, line_items.product_id, line_items.quantity, tax_note,
line_items.tax_rate_id, line_items.taxable, ticket_line_item_id, line_items.updated_at, used_quantity, line_items.quantity, line_items.user_id,
locations.name as location_name, invoices.number as invoice_number, users.full_name as user_name,
(CASE WHEN char_length(customers.business_name) > 1 THEN customers.business_name ELSE (customers.lastname || ', ' || customers.firstname) END) as customer_name,
products.name as product_name
FROM public.line_items

LEFT OUTER JOIN invoices ON invoices.id = line_items.invoice_id
LEFT OUTER JOIN customers ON customers.id = invoices.customer_id
LEFT OUTER JOIN locations ON locations.id = invoices.location_id
LEFT OUTER JOIN users ON users.id = line_items.user_id
LEFT OUTER JOIN products ON products.id = line_items.product_id

WHERE line_items.invoice_id is not null AND line_items.invoice_id != 0
order by id desc
limit 1000000
SQL

  puts "got a lot of line_items..."

  file_name = "domo_line_items.csv"
  csv = CSV.generate() do |csv|
    csv << ["account_id", "cost", "id", "name", "created_at", "discount_percent", "estimate_id", "estimated_quantity", "invoice_bundle_id", "invoice_bundle_line_id", "invoice_id", "item", "price", "cost_extended", "price_extended", "net", "product_category", "product_id", "quantity", "tax_note", "tax_rate_id", "taxable", "ticket_line_item_id", "updated_at", "used_quantity", "quantity", "user_id", "location_name", "invoice_number", "user_name", "customer_name", "product_name"]
    line_items.each do |line|
      csv << line.values
    end
  end

  puts "Made a CSV..."

  File.open(file_name, 'w') do |f|
    f.write(csv)
  end

  puts "Wrote the CSV.."

  file = @client.upload_file_by_folder_id("./#{file_name}", destination_folder.id)

  puts "All set! #{file}"

end
