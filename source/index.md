---
title: Quoine API Reference

language_tabs:
  - ruby

toc_footers:
  - <a href='https://www.quoine.com'>Quoine</a>

includes:
  - errors

search: true
---

# Introduction

> The base URL for production is `https://api.quoine.com/`. All responses are in JSON format with the following status codes:

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

Quoine API provides a simple REST API to retrieve information about our markets and user data.
Quoine provides access to two types of API consumer:

* User API is recommended if you want to access your own account's features, like creating an order.
* App API is for accessing Quoine integrated features directly from your application.

Both JSON and XML formats are supported by all API calls
You always need to specify a format (json | xml)
By default, you need to pass authorized params (in Authentication) for all requests, otherwise, you will get HTTP status 401.

# I. User API

# 1. Authentication
## 1.1 Token-based (DEPRECATED)

Authentication is done using 3 parameters: `Device`, `UserId`, `Token`. These parameters can be obtained from
<a href="https://www.quoine.com/app/#/app/settings" target="_blank">Quoine settings page</a>

These parameters need to be supplied in header of all requests as: `X-Quoine-Device`, `X-Quoine-User-Id`, `X-Quoine-User-Token`

This authentication method is no longer available to new API users. Existing users should move to Secret-based as soon as possible. Token-based version will be removed
entirely in our feature release.

## 1.2 Secret-based
```ruby
require 'uri'
require 'net/http'
require 'time'
require 'securerandom'
require 'base64'
 
uri = URI.parse("https://api.quoine.com")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
 
user_id = ''
user_secret = ''
path = "/orders?currency_pair_code=BTCUSD"
 
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


Authentication is executed by 2 parameters: `User ID` and `User Secret`. These parameters can be obtained from
<a href="#{root_url}app/#/app/settings" target="_blank">Settings page</a>

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


# 2. Markets

## 2.1. Markets (Products) Summary

```
GET /products
```

```json
[
  {
   "id": "5",
   "product_type": "CASH",
   "code": "CASH",
   "name": " CASH Trading",
   "market_ask": 40039.753722,
   "market_bid": 39300,
   "indicator": 0,
   "currency_pair_id": "3",
   "currency": "JPY",
   "currency_pair_code": "BTCJPY",
   "symbol": "¥",
   "btc_minimum_withdraw": 0.02,
   "fiat_minimum_withdraw": 1500,
   "taker_fee": 0.005,
   "low_market_bid": 39300,
   "high_market_ask": 40039.753722,
   "volume_24h": 0,
   "last_price_24h": 0
  },
  ...
]
```

#### Parameters:

* `fetch`: `all` to fetch all live markets, otherwise, your accessiable markets are returned.


## 2.2. Specific Market (Product) Summary

```
GET /products/:product_id
```

#### Parameters:

* `id`: Product Id

Or

```
GET /products/code/:code/:currency_pair_code
```

#### Parameters:

* `currency_pair_code`: BTCUSD, BTCEUR, BTCJPY, BTCSGD, BTCHKD, BTCIDR, BTCAUD, BTCPHP, BTCCNY, BTCINR.
* `code`: CASH (We will support more codes like FUTURES in the future)



```json
{
  "id": "5",
  "product_type": "CASH",
  "code": "CASH",
  "name": " CASH Trading",
  "market_ask": 40039.753722,
  "market_bid": 39300,
  "indicator": 0,
  "currency_pair_id": "3",
  "currency": "JPY",
  "currency_pair_code": "BTCJPY",
  "symbol": "¥",
  "btc_minimum_withdraw": 0.02,
  "fiat_minimum_withdraw": 1500,
  "taker_fee": 0.005,
  "low_market_bid": 39300,
  "high_market_ask": 40039.753722,
  "volume_24h": 0,
  "last_price_24h": 0,
  "last_traded_price": 236.07
}
```

## 2.3. Market Price Ladder

```
GET /products/:product_id/price_levels
```

#### Parameters:

* `product_id`: You might retrieve from `id` field of list of products in 2.1 and 2.2.


```json
{
  "buy_price_levels": [
    [
      "49849.00000",
      "0.69500"
    ],
    ...
  ],
  "sell_price_levels": [
    [
      "50533.00000",
      "1.47470"
    ],
    ...
  ]
}
```

* Price ladders is followed format: [`bid/ask price`, `amount of Bitcoin`]

# 3. Orders

## 3.1. Create Order

```
POST /orders/
```
> Sample payload

```json

{
  "order": {
    "order_type": "limit",
    "product_code": "CASH",
    "currency_pair_code": "BTCJPY",
    "side": "sell",
    "quantity": 5.0,
    "price": 500
  }
}
```

> Success Response 

```
{
  "order": {
   "id": "1",
   "order_type": "limit",
   "product_code": "CASH",
   "currency_pair_code": "BTCJPY",
   "side": "sell",
   "quantity": 5.0,
   "price": 500
  }
}
```

> Error Response

```
{
  "error": {
    "msg": "Limit order price is lower than market bid"
  }
}
```

#### Parameters:

* `order_type`: Values: `limit`, `market` or `range`.
* `product_code`: Values: `CASH`
* `currency_pair_code`: BTCUSD, BTCEUR, BTCJPY, BTCSGD, BTCHKD, BTCIDR, BTCAUD, BTCPHP, BTCCNY, BTCINR
* `side`: Type of order. Values: `sell` or `buy`.
* `quantity`: Amount of BTC you want to trade.
* `price`: Price of BTC you want to trade.
* `leverage_level`: (optional) used for margin trading. Valid values: 2,4,5,10,25 


## 3.2. Cancel Order

```
PUT /orders/:id/cancel
```

> Success Response

```
{
  "order": {
  "id": "1",
  "order_type": "limit",
  "side": "sell",
  "quantity": 5.0,
  "filled_quantity": 2.5,
  "price": 500,
  "product_code": "CASH",
  "currency_pair_code": "BTCJPY",
  "status": "cancelled"
  }
}
```

> Error Response

```
{
  "error": {
    "msg": "Order has already been completely filled and cannot be cancelled"
  }
}
```

#### Parameters:

* `id`: Order ID. You might retrieve from 3.1.

## 3.3. Get Order Details

#### Parameters:

* `id`: Order ID. You might retrieve from 2.1.

```
GET /orders/:id
```

> Success Response

```
{
  "order": {
   "id": 1,
   "order_type": "limit",
   "side": "sell",
   "quantity": 5.0,
   "filled_quantity": 2.5,
   "price": 500,
   "status": "cancelled",
   "executions": [
     {
      "id": 1,
      "price": 500,
      "quantity": 2,
      "created_at": "2014-06-18 15:31:42 UTC"
     },
     {
      "id": 2,
      "price": 500,
      "quantity": 0.5,
      "created_at": "2014-06-18 15:31:42 UTC"
     }
   ]
  }
}
```

> * available statuses are "live", "filled", "cancelled".

## 3.4. Get Orders

```
GET /orders?currency_pair_code=:currency_pair_code
```

#### Parameters:

* `currency_pair_code`: BTCUSD, BTCEUR, BTCJPY, BTCSGD, BTCHKD, BTCIDR, BTCAUD, BTCPHP, BTCCNY, BTCINR.

*(`currency_pair_code` are used to filter results and can be omitted)*



> Success Response

```json
{
  "models": [
    {
    "id": "1",
    "order_type": "limit",
    "side": "sell",
    "quantity": 5.0,
    "filled_quantity": 2.5,
    "currency_pair_code": "BTCJPY",
    "product_code": "CASH",
    "price": 500,
    "status": "cancelled"
    },
    {
    "id": "2",
    "order_type": "market",
    "side": "buy",
    "quantity": 1.0,
    "filled_quantity": 1.0,
    "currency_pair_code": "BTCJPY",
    "product_code": "CASH",
    "price": 501,
    "status": "filled"
    },
    {
    "id": "3",
    "order_type": "limit",
    "side": "buy",
    "quantity": 1.0,
    "filled_quantity": 0.5,
    "currency_pair_code": "BTCJPY",
    "product_code": "CASH",
    "price": 500.5,
    "status": "partially_filled"
    },
    {
    "id": "4",
    "order_type": "limit",
    "side": "buy",
    "quantity": 1.0,
    "filled_quantity": 0.0,
    "currency_pair_code": "BTCJPY",
    "product_code": "CASH",
    "price": 500.5,
    "status": "live"
    }
  ]
}
```

# 4. Accounts

## 4.1. Listing Accounts


```
GET /accounts
```



> Success Response

```
{
  "bitcoin_account": {
    "id": 2,
    "balance": 0.0804,
    "address": "1MZdSntaasKPU25WFXBZespYxKz7VrhuzN",
    "currency": "BTC",
    "currency_symbol": "฿",
    "btc_minimum_withdraw": 0.02,
    "bitcoin_transactions": [
      {
        "id": 310,
        "created_at": "2014-09-18T04:37:24Z",
        "gross_amount": 0.0049,
        "net_amount": 0.0049,
        "exchange_fee": 0,
        "network_fee": 0,
        "transaction_type": "funding",
        "from_bitcoin_account_id": null,
        "to_bitcoin_account_id": 2,
        "from_role": null,
        "to_role": null
      },
      ...
    ]
  },
  "fiat_accounts": [
    {
      "id": 2,
      "currency": "USD",
      "currency_symbol": "$",
      "balance": 12.3337625,
      "send_to_btc_address": null,
      "pusher_channel": "User-2-Account-USD",
      "fiat_transactions": [
        {
         "id": 147,
         "created_at": "2014-08-15T16:06:37Z",
         "transaction_type": null,
         "notes": null,
         "gross_amount": 5,
         "net_amount": 4.975,
         "fee": 0.025,
         "from_fiat_account_id": 2,
         "to_fiat_account_id": 19,
         "from_role": "maker",
         "to_role": "maker"
        },
        ...
      ]
    },
    ...
  ]
}
```

# 5. Upload Document

```
POST /users/upload_documents
```
#### Parameters:

* `id_document`: Id document file
* `proof_address`: Proof of address file
* `bank_statement`: Bank statement file



> Success Response

```
{
  "success": true
}
```

> Error Response

```
{
  "success": false,
  "message": "Invalid params"
}
```

# II. App API
App API is currently only available to our partners. For more information about partnership, please contact us directly

# 1. Onboarding
## 1.1. Create onboarding user

```
POST /users/onboarding
```
#### Parameters:

* `first_name*`:
* `last_name*`:
* `first_furi_name`: for Japanese name
* `last_furi_name`: for Japanese name
* `phone*`: phone number, can be with or without country code, e.g +819017901357, 09017901357
* `email*`:
* `address`:
* `city`:
* `country*`: country code, e.g 'JP', 'VN', 'US'
* `postcode`:
* `password*`:
* `id_document*`: Id document file
* `proof_address*`: Proof of address file
* `bank_statement*`: Bank statement file



> Success Response

```
{
  "success": true,
  "user_id": 25
}
```

> Error Response

```
{
  "success": false,
  "message": "Password cannot be blank"
}
```

## 1.2. Check onboarding user status

```
POST /users/onboarding_status
```
#### Parameters:

* `user_id*`: user id
* `password*`: user password



* `status`: valid values 'PENDING', 'APPROVED', 'DECLINED'

> Success Response

```
{
  "success": true,
  "status": "APPROVED",
  "api_id": "25",
  "api_secret": "XMDwUjclch9IVNfuVjep23tMZRhPk0GId0mwFO2N1RPF8WZQ=="
}
```

```
{
  "success": true,
  "status": "DECLINED",
  "reason": "Mismatched first name"
}
```


> Error Response

```
{
  "success": false,
  "message": "Unauthorized access"
}
```