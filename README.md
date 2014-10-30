# Hot Dog Princess

![Hot Dog Princess](https://raw.githubusercontent.com/MatthewCallis/HotDogPrincess/master/hdp.png)

_-- "Their message says, Baby... Us... Trouble... Time."_

Integrate with the [Parature](http://www.parature.com/) API. It's gunna be so flippin' awesome!

Currently a WIP.

## Installation

Add this line to your application's Gemfile:

    gem 'hotdogprincess'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hotdogprincess

## Usage

### Setup

You will need your host, the account ID, the department ID and your API token.

### Testing

You will need to make a copy of `spec/hotdogprincess.sample.yml` as `spec/hotdogprincess.yml` with your own testing credentials.

### Examples

You can use the client in two possible way, or more if you're really brave and creative:

```ruby
client = ::HotDogPrincess::Client.new(host: 'sandbox.parature.com', account_id: 123, department_id: 456, token: 'api_token')

OR

HotDogPrincess.client
```

From here you can do all sorts of wonderful things:

```ruby
# Schema, Status, View
client.schema_raw 'Customer'
client.schema_raw 'Ticket'
client.schema_raw 'Sla'
=> {"?xml"=>{"@version"=>"1.0", "@encoding"=>"utf-8"}, "Customer"=> ...

client.status_raw 'Customer'
client.status_raw 'Ticket'
client.status_raw 'Sla'
=> {"?xml"=>{"@version"=>"1.0", "@encoding"=>"utf-8"}, "entities"=> ...


# Well that's neat, but XML? What the hell is wrong with you, is it 2001‽
client.schema 'Customer'
client.schema 'Ticket'
client.schema 'Sla'
=> #<Hash ...

client.schema_json 'Customer'
client.schema_json 'Ticket'
client.schema_json 'Sla'
=> # See below for important details about all JSON returns.

client.status 'Customer'
client.status 'Ticket'
client.status 'Sla'
=> #<Hash ...

client.status_json 'Customer'
client.status_json 'Ticket'
client.status_json 'Sla'
=> "[{\"id\":16,\"uid\":\"123/456/Customer/status/10001\",\"href\":"...

client.view 'Ticket'
=> {"?xml"=>{"@version"=>"1.0", "@encoding"=>"utf-8"}, "Entities"=> ...

client.view_json 'Ticket'
=> "[{\"id\":7,\"uid\":\"123/456/Ticket/view/7\","...

# Working with Customers / Tickets / SLAs
# Raw XML: Page size defaults to 100 records.
page_size = 50
customers = client.fetch_customers(page_size)
tickets   = client.fetch_ticket(page_size)
slas      = client.fetch_slas(page_size)
=> {"?xml"=>{"@version"=>"1.0", "@encoding"=>"utf-8"}, "Entities"=> {"@total"=>"12400", "@results"=>"50"...

customers = client.fetch_customers
tickets   = client.fetch_ticket
slas      = client.fetch_slas
=> {"?xml"=>{"@version"=>"1.0", "@encoding"=>"utf-8"}, "Entities"=> {"@total"=>"12400", "@results"=>"100"...

# We have them cached, so if we need the raw XML again:
customers = client.customers_raw
tickets   = client.tickets_raw
slas      = client.slas_raw
=> {"?xml"=>{"@version"=>"1.0", "@encoding"=>"utf-8"}, "Entities"=> {"@total"=>"12400", "@results"=>"100"...

# Hash: Page size defaults to 100 records, and force update defaults to false.
customers = client.customers
tickets   = client.tickets
slas      = client.slas
=> [#<Hash id="10002", uid="123/456/Customer/10002", href="https:..."] x 100 of 12400

customers = client.customers(50, true)
tickets   = client.tickets(50, true)
slas      = client.slas(50, true)
=> [#<Hash id="10002", uid="123/456/Customer/10002", href="https:..."] x 50 of 12401, we got a new entry since the last call!

# Counts: Just for convenience.
client.customer_count
client.ticket_count
client.sla_count
=> 50

# Fetch a single item by ID.
customer = client.customer 10002
ticket   = client.ticket 10001
sla      = client.sla 1
=> #<Hash id="1", uid="123/456/Sla/1", href="https://sandbox.parature.com/api/v1/123/456/Sla/1", name="System Default">

# Searching: You search email with either exact match or a substring match.
client.find_customer_by_email 'joe@exmaple.comz'
=> [#<Hash id="26553", uid="123/456/Customer/26553",

client.find_customer_by_email 'not_found@brandnewusers.io'
=> []

substring = true
client.find_customer_by_email 'gmail.com', substring
=> [#<Hash id="26553", uid="123/456/Customer/26553", x ~50

# Creating Customers / Tickets: We are using https://github.com/savonrb/gyoku to create XML from Hashes, so see the docs for in-depth XML constructions.
customer_hash = {
  "Customer" => {
    "First_Name" => 'Joe',
    "Last_Name" => 'Blow',
    "Email" => 'joe@example.comz',
    "Password" => 'password',
    "Password_Confirm" => 'password',
    "Sla" => {
      "Sla/" => {
        :@id => "1"
      }
    }
  }
}
customer = client.create_customer customer_hash
=> #<Hash id="10003", uid="123/456/Customer/10003", ...

ticket_hash = {
  "Ticket" => {
    "Ticket_Customer" => {
      "Customer/" => {
        :@id => "10003"
      }
    },
    "Custom_Field" => [
      {
        :@id => 1,
        :content! => "Notes: It's Godzilla, no it's Apptentive!"
      },
      {
        :@id => 2,
        :content! => "Status: Healthy"
      },
    ]
  }
}
ticket = client.create_ticket input_xml
=> #<Hash id="10004", uid="123/456/Ticket/10004", ...

# Update Customers / Tickets: Typically this returns an ID, but we instead fetch that ID and return the entire updated entity.
client.update_customer 10003, customer_hash
=> #<Hash id="10003", uid="123/456/Customer/10003", ...

client.update_ticket 10004, ticket_hash
=> #<Hash id="10004", uid="123/456/Ticket/10004", ...

# For more depth, have a peek at the source code.
```

#### Schema JSON Output

The JSON output has tried to stay readable and match the keys from the XML. Object formats are converted to their native JSON types (Boolean, Integer, Float) when possible. This is particularly useful when you're using this in combination with native forms on a front end.

```json
{
    "customer_role": {
        "display_name": "Customer Role",
        "required": false,
        "editable": true,
        "data_type": "entity",
        "field_type": "entity",
        "customerrole": {
            "name": {
                "display_name": "Name"
            }
        }
    },
    "date_created": {
        "display_name": "Date Created",
        "required": false,
        "editable": false,
        "field_type": "usdate",
        "data_type": "date"
    },
    "date_updated": {
        "display_name": "Date Updated",
        "required": false,
        "editable": false,
        "field_type": "usdate",
        "data_type": "date"
    },
    "date_visited": {
        "display_name": "Date Visited",
        "required": false,
        "editable": false,
        "field_type": "usdate",
        "data_type": "date"
    },
    "email": {
        "display_name": "Email",
        "required": true,
        "editable": true,
        "field_type": "email",
        "data_type": "string",
        "max_length": 256
    },
    "first_name": {
        "display_name": "First Name",
        "required": true,
        "editable": true,
        "field_type": "text",
        "data_type": "string",
        "max_length": 128
    },
    "full_name": {
        "display_name": "Full Name",
        "required": false,
        "editable": true,
        "field_type": "text",
        "data_type": "string",
        "max_length": 256
    },
    "last_name": {
        "display_name": "Last Name",
        "required": true,
        "editable": true,
        "field_type": "text",
        "data_type": "string",
        "max_length": 128
    },
    "password": {
        "display_name": "Password",
        "required": true,
        "editable": true,
        "field_type": "password",
        "data_type": "string",
        "max_length": 96
    },
    "password_confirm": {
        "display_name": "Password (confirm)",
        "required": true,
        "editable": true,
        "field_type": "password",
        "data_type": "string",
        "max_length": 96
    },
    "sla": {
        "display_name": "Service Level Agreement",
        "required": true,
        "editable": true,
        "field_type": "dropdown",
        "data_type": "entity",
        "sla": {
            "name": {
                "display_name": "Name"
            }
        }
    },
    "status": {
        "display_name": "Status",
        "required": true,
        "editable": true,
        "data_type": "entity",
        "field_type": "dropdown",
        "status": {
            "name": {
                "display_name": "Name"
            }
        }
    }
}
```

#### Unimplemented Functionality

Another useful thing about Hot Dog Princess is the GET/PUT/POST/DELETE methods are all available on the client, so any unimplemented feature could be constructed as needed, but it'd be awesome if you would just code and open a pull request.

```ruby
client.get 'Customer', "First_Name_like_" => "joe"
=> {"?xml"=>{"@version"=>"1.0", "@encoding"=>"utf-8"}...
```

## Notes

- Nil values are stripped from hashes to be used, Parature does not accept the `xsi:nil` values.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

![It's gunna be so flippin' awesome!](https://raw.githubusercontent.com/MatthewCallis/HotDogPrincess/master/awesome.gif)
