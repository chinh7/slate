---
title: Quoine Payment API Reference

language_tabs:
  - ruby

toc_footers:
  - <a href='/'>Quoine Exchange API</a>

includes:
  - errors

search: true
---

# Introduction

> The base URL for production is `https://pay.quoine.com/api/v1`. All responses are in JSON format with the following status codes:

```
HTTP 200: OK
  Response is correct. The body of the response will
  include the data requested.

HTTP 400: Bad Request
  There was an error with the request. The body of the response will have more info

HTTP 401: Unauthorized
  Token is invalid. If your API key is wrong a 401 will also be served,
  so check the response body, it might be that the API_KEY is invalid.

HTTP 422: Unprocessable Entity
  There was an error with the request. The body of the response will have more info. Some possible reasons:
  - Missing params
  - The format of data is wrong

HTTP 503: Service Unavailable
  Many reasons, body will include details
  - An internal error on Authy.
  - Your application is accessing an API call you don't have access too.
  - API usage limit. If you reach API usage limits a 503 will be returned,
  please wait until you can do the call again.
```

Quoine Payment API provides a simple REST API that allows merchants to receive payments via bitcoin.
<br><br>
Note that with our Payment System, although buyers pay with bitcoin merchants always receive the payment in their exact quoted amount and currency, eliminating bitcoin's volatility factor.


# 1. Authentication

By default, you need to pass authorized params (in Authentication) for all requests, otherwise, you will get HTTP status 401.

```ruby
require 'uri'
require 'net/http'
require 'time'
require 'securerandom'
require 'base64'
 
uri = URI.parse("https://api.quoine.com")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
 
user_id = 'YOUR_USER_ID'
user_secret = 'YOUR_USER_SECRET'
path = "/profile"
 
nonce = SecureRandom.hex
date = Time.now.httpdate
canonical_string = "application/json,,#{path},#{date},#{nonce}"
signature = Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), user_secret, canonical_string))
 
request = Net::HTTP::Get.new(path)
request.add_field('Content-Type', 'application/json')
request.add_field('Date', date)
request.add_field('NONCE', nonce)
request.add_field('Authorization', "APIAuth #{user_id}:#{signature}")
 
response = http.request(request)
```


Once registered, users can access their `User ID` and `User Secret` in
<a href="https://pay.quoine.com/settings" target="_blank">Settings page</a>

You can manually authenticate using these headers or just use this ruby tool [api_auth (quoine branch)](https://github.com/chinh7/api_auth)

<h4>Request Headers:</h4>

Header   | Optional? | Description
---------|-----------|------------
Content-Type || content type, eg. "application/json"
Content-MD5 | yes | MD5 base 64 hash of the request content
Date || timestamp in http date format, eg. "Sat, 27 Sep 2014 04:55:17 GMT"
NONCE || random **32 chars** alphanumeric string. Each request needs a different NONCE, eg. "0599e5ed6cbb522053f4faf4eccfbd3a"
Authorization || "APIAuth user_id:signature", eg. "APIAuth 1:tq63DFC2IFHLNQb1ACQDNl9kDkw="

<aside class="notice">
   <strong>signature</strong> is a base64 encode of HMAC SHA1 digest of the canonical string.
   The canonical string is a comma-separated join of the following components:
   <br><br><i>content-type,content-MD5,request URI,date,nonce</i>
   <br>e.g. "application/json,1B2M2Y8AsgTpgAmY7PhCfg==,/api/invoices,Sat, 27 Sep 2014 04:55:17 GMT,0599e5ed6cbb522053f4faf4eccfbd3a"
   <br><br><p>It's important to match the string components with request headers. For instance if a Content-MD5 is not included in the header, it should not be in the canonical string as well</p>
</aside>


# 2. Create An Invoice

```
POST /invoices
```

<aside class="notice">
Quoine Invoice allows shoppers to pay with bitcoin and merchants to receive the payment in Fiats (USD, JPY, etc)
<br><br>
Invoice should be created when buyers make an order to be paid via bitcoin. Each invoice includes a bitcoin address where buyer can pay to using bitcoin.
Once the bitcoins are received, Quoine will transfer the payment to merchants using their currency of preference.
<br><br>
Since Quoine locks bitcoin price the time of the payment, merchants are not affected by bitcoin's volatility. Merchants always get the exact quoted price of their items
</aside>



### Parameters:

* `price`: price of the invoice (default to user's currency on Quoine Exchange)
* `name` (optional): any string attached to the invoice
* `data` (optional): any string attached to the invoice

### Sample response:
* Status: success (200)

```
{
  "id": 1,
  "system_status": "account_created",
  "invoice_status": "unpaid",
  "user_id": 2,
  "sub_account_id": 1,
  "bitcoin_address": "1MutST9LxW4JxNVSjyzBV6bVwi64cD9Zoo",
  "name": "invoice name",
  "data": "any data",
  "price": "500.0",
  "btc_price": 0.5,
  "btc_balance": 0,
  "currency": "USD",
  "qrcode_address_url": "http://chart.googleapis.com/chart?chs=500x500&cht=qr&chl=1MutST9LxW4JxNVSjyzBV6bVwi64cD9Zoo",
  "qrcode_protocol_url": "http://chart.googleapis.com/chart?chs=500x500&cht=qr&chl=bitcoin:1MutST9LxW4JxNVSjyzBV6bVwi64cD9Zoo?amount=0.5",
  "paid_at": null,
  "created_at": "2014-08-08T19:40:12.855+09:00",
  "updated_at": "2014-08-08T19:40:12.855+09:00",
  "expired_at": "2014-08-08T20:10:12.855+09:00"
}
```
* `btc_price`: price in BTC
* `bitcoin_address`: a bitcoin address to receive the payment.
* `btc_balance`: current balance in BTC
* `expired_at`: newly created invoice will expire in 30 minutes

### invoice_status:
* `payment_awaited`: An invoice starts with this state, waiting for payment.
* `payment_detected`: Payment is detected in the bitcoin network but not 100% confirmed.
* `payment_confirmed`: Payment is confirmed and fully received.
* `payment_expired`: Payment hasn't been detected 30 minutes since invoice was created.

### system_status:
* `ready`: Invoice is ready to receive bitcoins. (Invoice status: payment_awaited)
* `unconfirmed`: full payment is received with 1 confirmation. (Invoice status: payment_detected)
* `confirmed`: full payment is received and confirmed on the bitcoin network. Ready to be sold to the Exchange. (Invoice status: payment_confirmed)
* `captured`: bitcoin has been successfully convert to fiat. Fiat fund is now available in merchant account
* `complete`: after a captured invoice has been notified to merchant via callback URL 
* `expired`: An expired invoice is one where payment was not received and the 30 minutes payment window has elapsed (Invoice status: payment_expired)
* `invalid`: unconfirmed for more than 3 hours (Invoice status: payment_expired)


### Sample error:
* Status: unprocessable entity (422)

```
{
  "status": "fail",
   "errors": {
     "price": ["can't be blank"]
   }
}
```

# 3. Get An Invoice
```
GET /invoices/{id}
```

### Parameters
* None

### Sample response
* Status: success (200)

```
{
  "id": 1,
  "system_status": "confirmed",
  "invoice_status": "paid",
  "user_id": 1,
  "sub_account_id": 1,
  "bitcoin_address": "19wMMfLQ4Hu2XehHAbR3xY9UMEaaRLUMf4",
  "name": "invoice name",
  "data": "any data",
  "price": "500.0",
  "btc_price": 0.5,
  "btc_balance": 0.5,
  "currency": "USD",
  "status": "btc_sent",
  "qrcode_address_url": "http://chart.googleapis.com/chart?chs=500x500&cht=qr&chl=19wMMfLQ4Hu2XehHAbR3xY9UMEaaRLUMf4",
  "qrcode_protocol_url": "http://chart.googleapis.com/chart?chs=500x500&cht=qr&chl=bitcoin:19wMMfLQ4Hu2XehHAbR3xY9UMEaaRLUMf4?amount=0.5",
  "paid_at": "2014-08-08T20:18:48.813+09:00",
  "created_at": "2014-08-08T20:08:48.813+09:00",
  "updated_at": "2014-08-08T20:08:48.813+09:00",
  "expired_at": "2014-08-08T20:38:48.813+09:00"
}
```

### Sample error:
* Status: not found (404)

```
{
  "status": "fail",
  "message": "Invoice not found"
}
```

# 4. Get All Invoices
```
GET /invoices
GET /invoices?page=2&per=5
```
### Parameters:
* `page`(optional): page number.
* `per`(optional): number of items per page.

### Sample response:
* Status: success (200)

```
{
  "invoices": [
    {
      "id": 1,
      ...
    },
    {
      "id": 2,
      ...
    },
    ...
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 2,
    "total_count": 8
  }
}

```


# 5. Get Profile
Get merchant profile

```
GET /profile
```

```
{
  "id": 2,
  "email": "marjory_spinka@balistreri.name",
  "first_name": "Test",
  "last_name": "Demo",
  "name": "Test Demo",
  "currency": "USD",
  "status": "approved",
  "settings": {
    "payments_callback": "https://merchant.com/callback"
  },
  ...
}
```


# 6. Update Notification URL
```
POST /payments_callback_url
```

> Sample response:

```
{
  "status": "success",
  "callback": "https://merchant.com/callback"
}
```


### Parameters:
* `callback`: Everytime invoice status is updated, Quoine will notify merchant via this web hook.


> Data POSTed to callback url

```
{
  "invoice": {
    "id": 1,
    "system_status": "complete",
    "invoice_status": "payment_confirmed",
    "user_id": 2,
    "sub_account_id": 1,
    "bitcoin_address": "1MutST9LxW4JxNVSjyzBV6bVwi64cD9Zoo",
    "name": "invoice name",
    "data": "any data",
    "price": "500.0",
    "btc_price": 0.5,
    "btc_balance": 0.5,
    "currency": "USD",
    "qrcode_address_url": "http://chart.googleapis.com/chart?chs=500x500&cht=qr&chl=1MutST9LxW4JxNVSjyzBV6bVwi64cD9Zoo",
    "qrcode_protocol_url": "http://chart.googleapis.com/chart?chs=500x500&cht=qr&chl=bitcoin:1MutST9LxW4JxNVSjyzBV6bVwi64cD9Zoo?amount=0.5",
    "paid_at": "2014-08-08T19:50:12.855+09:00",
    "created_at": "2014-08-08T19:40:12.855+09:00",
    "updated_at": "2014-08-08T19:40:12.855+09:00",
    "expired_at": "2014-08-08T20:10:12.855+09:00"
  }
}
```

