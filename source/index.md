---
title: Quoine Exchange API Reference

language_tabs:
  - ruby

toc_footers:
  - <a href='/payment.html'>Quoine Payment API</a>

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

HTTP 429: Too Many Requests
  This status indicates that the user has sent too many requests in a given amount of time  

HTTP 503: Service Unavailable
  Many reasons, body will include details
  - An internal error on Authy.
  - Your application is accessing an API call you don't have access too.
  - API usage limit. If you reach API usage limits a 503 will be returned,
  please wait until you can do the call again.
```

Quoine API provides a simple REST API to retrieve information about our markets and user data. By default, you need to pass authorized params (in Authentication) for all requests, otherwise, you will get HTTP status 401.

<aside class="notice">
RATE LIMITING
<br>
API users should not make more than 300 requests per 5 minute. Requests go beyond the limit will return with a 429 status
</aside>


# Authentication
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

# Types

## Timestamps

```
1457974024 (for 2016-03-14T16:47:04 in ISO 8601)
```

Unless otherwise specified, all timestamps from API are returned in <a href="https://en.wikipedia.org/wiki/Unix_time" target="_blank">Unix Time</a>.

## Numbers
* Decimal numbers are returned as strings to avoid floating precision errors.
* Integer numbers (including IDs) are unquoted.

# Errors

# Pagination

```json
{
    "models": [ "<json objects>" ],
    "current_page": "<current page>",
    "total_pages": "<number of pages>"
}
```

Unless otherwise specified, all API requesting lists will be paginated with the following format


# I. Public API

<aside class="notice">
  Public API does not require authentication
</aside>

# Products

## Get Products

> GET /products

```json
[
  {
      "id": 5,
      "market_ask": "47684.84",
      "market_bid": "47674.65",
      "base_currency": "BTC",
      "quoted_currency": "JPY",
      "btc_minimum_withdraw": "0.02",
      "fiat_minimum_withdraw": "1500.0",
      "low_market_bid": "47391.0",
      "high_market_ask": "48080.0",
      "volume_24h": "5047.493628919999999998",
      "last_price_24h": "47616.86",
      "last_traded_price": "47684.84",
      "last_traded_quantity": "0.0525"
  },  
  ...
]
```
Get the list of all available products.


## Get a Product

> GET /products/:id

```json
{
    "id": 5,
    "market_ask": "47684.84",
    "market_bid": "47674.65",
    "base_currency": "BTC",
    "quoted_currency": "JPY",
    "btc_minimum_withdraw": "0.02",
    "fiat_minimum_withdraw": "1500.0",
    "low_market_bid": "47391.0",
    "high_market_ask": "48080.0",
    "volume_24h": "5047.493628919999999998",
    "last_price_24h": "47616.86",
    "last_traded_price": "47684.84",
    "last_traded_quantity": "0.0525"
}
```

#### Parameters:

Parameters   | Optional? | Description
---------|-----------|------------
id || Product ID

## Get Order Book

> GET /products/:id/price_levels

#### Parameters:

```json
{
  "buy_price_levels": [
    ["416.23000", "1.75000"],   ...
  ],
  "sell_price_levels": [
    ["416.47000", "0.28675"],   ...
  ]
}
```

Parameters   | Optional? | Description
---------|-----------|------------
id || Product ID

#### Format
* Each price level follows: [`price`, `amount`]


# Executions

## Get Executions

> GET /executions?product_id=1&limit=2&page=2

```
Success Response:
```

```json
{
    "models": [
        {
            "id": "190342",
            "quantity": 0.01,
            "price": 295.07,
            "taker_side": "buy",
            "created_at": 1438083311
        },
        {
            "id": "190341",
            "quantity": 0.01,
            "price": 295.07,
            "taker_side": "buy",
            "created_at": 1438083275
        }
    ],
    "current_page": 2,
    "total_pages": 2630
}
```

Get a list of recent executions from a product (Executions are sorted in DESCENDING order - Latest first)

Parameters   | Optional? | Description
---------|-----------|------------
product_id || Product ID
limit | yes | How many executions should be returned. Must be <= 1000. Default is 20
page | yes | From what page the executions should be returned, e.g if limit=20 and page=2, the response would start from the 21st execution. Default is 1


## Get Executions by Timestamp

> GET /executions?product_id=1&timestamp=1430630863&limit=2

```
Success Response:
```

```json
[
    {
        "id": "25148",
        "quantity": 9.82,
        "price": 242.01,
        "taker_side": "buy",
        "created_at": 1430656664
    },
    {
        "id": "25151",
        "quantity": 0.1,
        "price": 241,
        "taker_side": "buy",
        "created_at": 1430658400
    }
]
```

Get a list of executions after a particular time (Executions are sorted in ASCENDING order)

Parameters   | Optional? | Description
---------|-----------|------------
currency_pair_code || e.g. BTCJPY
timestamp || Only show executions at or after this timestamp (Unix timestamps in seconds)
limit | yes | How many executions should be returned. Must be <= 1000. Default is 20

<aside class="notice">
Since the timestamp is in second, there could be several executions with the same timestamp.
The server will make the effort to include those with the same timestamps in one response. So users won't miss any execution in subsequent API calls (where new timestamp should = last execution timestamp + 1)
<br>
As a result, the number of executions returned could be larger than `limit` in some cases.
</aside>


# II Authenticated API

All requests to Authenticated endpoints must be properly signed as shown in [Authentication](#authentication),

# Orders

## 3.1. Create an Order

> POST /orders/

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

```
Success Response:
```

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

#### Parameters:

* `order_type`: Values: `limit`, `market` or `market_with_range`.
* `product_code`: Values: `CASH`
* `currency_pair_code`: BTCUSD, BTCEUR, BTCJPY, BTCSGD, BTCHKD, BTCIDR, BTCAUD, BTCPHP, BTCCNY, BTCINR
* `side`: Type of order. Values: `sell` or `buy`.
* `quantity`: Amount of BTC you want to trade.
* `price`: Price of BTC you want to trade.
* `leverage_level`: (optional) used for margin trading. Valid values: 2,4,5,10,25
* `settings`: (optional) set to hash {"collateralized": true} to fund trade with BTC, to {"multi_currency": true, "multi_currency_code": "USD"} to fund trade with other currency (USD in this case)

<aside class="notice">
To trade at any specific leverage level, users will need to go to margin trading dashboard,
click on that leverage level and then confirm to get authorized.
</aside>


## 3.2. Cancel an Order

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

## 3.3. Get an Order

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
      "created_at": 1438083311
     },
     {
      "id": 2,
      "price": 500,
      "quantity": 0.5,
      "created_at": 1438092200
     }
   ]
  }
}
```

> * available statuses are "live", "filled", "cancelled".

## 3.4. List Orders

```
GET /orders?currency_pair_code=:currency_pair_code?status=:status?product_code=:product_code
```

#### Parameters:

* `currency_pair_code`: BTCUSD, BTCEUR, BTCJPY, BTCSGD, BTCHKD, BTCIDR, BTCAUD, BTCPHP, BTCCNY, BTCINR.
* `status`: live, filled, cancelled
* `product_code`: CASH, FUTURE

*(Those parameters are used to filter results and can be omitted)*



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


## 4.3. List Executions by User


<aside class="notice">
This endpoint requires user to be authenticated
<br>
Please refer to 4.1 & 4.2 for parameters
</aside>


```
GET /executions/me?currency_pair_code=BTCUSD&limit=2&page=2
```

```json
{
    "models": [
        {
            "id": "194442",
            "quantity": 0.01,
            "price": 295.07,
            "taker_side": "buy",
            "created_at": 1438083311
        },
        {
            "id": "194440",
            "quantity": 0.01,
            "price": 295.07,
            "taker_side": "sell",
            "created_at": 1438083175
        },
    ],
    "current_page": 2,
    "total_pages": 2030
}
```



# 5. Accounts

## 5.1. List Accounts Balances

```
GET /accounts/balance
```

> Success Response

```json
[
    {
        "currency": "BTC",
        "balance": 0.04925688
    },
    {
        "currency": "USD",
        "balance": 7.17696
    },
    {
        "currency": "JPY",
        "balance": 356.01377
    }
]
```

## 5.2. Available Balances

<aside class="notice">
DEPRECATED: This method is no longer available
</aside>

```
GET /accounts/free_balances?currency=USD
```
#### Parameters:

* `currency*`: Fiat currency (USD, EUR, SGD, etc.)

> Success Response

```json
{
    "free_fiat_balance": 157.5,
    "free_btc_balance": 0.256
}
```

## 5.3. List Accounts


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
         "created_at": 1438052531,
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

# 6. Upload Document

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


# 7. Lending

## 7.1. Create a loan bid

```
POST /loan_bids
```
#### Parameters:

* `rate`: daily interest rate, e.g 0.0002 (0.02%), must be <= 0.07%
* `currency`: currency e.g 'USD', 'BTC', etc (all available in the system except JPY)
* `quantity`: quantity to lend


> Success Response

```
{
  "id": "4849",
  "quantity": 0.01,
  "filled_quantity": 0.0,
  "currency": "BTC",
  "status": "live",
  "rate": 0.0002
}
```

> Error Response

```
{
  "error": "Currency missing"
}
```

## 7.2. Get live loan bids

```
GET /loan_bids
```
#### Parameters:

* `currency`: currency e.g 'USD', 'BTC'
* `all`: true, to get all live loan bids

> Success Response

```
{
  "models":
    [
      {
        "id":"4854",
        "quantity":1.0,
        "currency":"BTC",
        "filled_quantity":0.0,
        "status":"live",
        "rate":0.00035
      }
    ]
}
```

> Error Response

```
{
  "error": "Currency missing"
}
```


## 7.3. Cancel loan bid

```
POST /loan_bids/:id/close
```
#### Parameters:

* `id`: loan bid id to close

> Success Response

```
{
  "id": "4849",
  "quantity": 0.01,
  "filled_quantity": 0.0,
  "currency": "BTC",
  "status": "closed",
  "rate": 0.0002
}
```

# 8. Trading Accounts

## 8.1. List Trading Accounts

```
GET /trading_accounts
```

> Success Response

```json
[
  {
    "id": "3501",
    "leverage_level": 25,
    "max_leverage_level": 25,
    "pnl": 0,
    "equity": 9999.80668,
    "margin": 0,
    "free_margin": 9999.80668,
    "trader_id": 6441,
    "status": "active",
    "product_code": "CASH",
    "currency_pair_code": "BTCUSD",
    "position": 0,
    "balance": 9999.80668,
    "margin_percent": 0.1
  },
  ...
]
```

## 8.2. Get a Trading Account

```
GET /trading_accounts/:currency_pair_code
```
#### Parameters:

* `currency_pair_code`: BTCUSD, BTCEUR, BTCJPY, BTCSGD, BTCHKD, BTCIDR, BTCAUD, BTCPHP, BTCCNY, BTCINR.

> Success Response

```
{
  "id": "3501",
  "leverage_level": 25,
  "max_leverage_level": 25,
  "pnl": 0,
  "equity": 9999.80668,
  "margin": 0,
  "free_margin": 9999.80668,
  "trader_id": 6441,
  "status": "active",
  "product_code": "CASH",
  "currency_pair_code": "BTCUSD",
  "position": 0,
  "balance": 9999.80668,
  "margin_percent": 0.1
}
```

## 8.3. Update Leverage Level

```
PUT /trading_accounts/:id
```

> Payload

```
{
  "trading_account": {
    "leverage_level": 5
  }
}
```
#### Parameters:
* `id`: can be retrieved in trading account object

#### Payload:
* `leverage_level`: new leverage_level

> Success Response

```
{
  "id": "3501",
  "leverage_level": 5,
  "max_leverage_level": 25,
  "pnl": 0,
  "equity": 9999.80668,
  "margin": 0,
  "free_margin": 9999.80668,
  "trader_id": 6441,
  "status": "active",
  "product_code": "CASH",
  "currency_pair_code": "BTCUSD",
  "position": 0,
  "balance": 9999.80668,
  "margin_percent": 0.1
}
```

# 9. Trades

## 9.1. List Trades

```
GET /trades
```

> Success Response

```json
{
  "models": [
    {
      "id": "3906",
      "currency_pair_code": "BTCUSD",
      "status": "open",
      "side": "long",
      "margin_used": 2335.7376002,
      "quantity": 0.1,
      "leverage_level": 2,
      "product_code": "CASH",
      "open_price": 403.31,
      "close_price": 0,
      "trader_id": 4807,
      "pnl": 157,
      "stop_loss": 0,
      "take_profit": 0,
      "funding_currency": "JPY",
      "created_at": 1455607142,
      "updated_at": 1456285826
    }
  ],
  "current_page": 1,
  "total_pages": 1
}
```

## 9.2. Close a trade

```
POST /trades/:id/close
```

> Success Response

```
{
  "id": "3906",
  "currency_pair_code": "BTCUSD",
  "status": "closed",
  "side": "long",
  "margin_used": 2335.7376002,
  "quantity": 0.1,
  "leverage_level": 2,
  "product_code": "CASH",
  "open_price": 403.31,
  "close_price": 405.31,
  "trader_id": 4807,
  "pnl": 2,
  "stop_loss": 0,
  "take_profit": 0,
  "funding_currency": "JPY",
  "created_at": 1455607142,
  "updated_at": 1456285826
}
```

## 9.3. Update a trade

```
PUT /trades/:id
```
#### Payload:
* `stop_loss`: Stop Loss price
* `take_profit`: Take Profit price,

> Success Response

```
{
  "id": "3906",
  "currency_pair_code": "BTCUSD",
  "status": "closed",
  "side": "long",
  "margin_used": 2335.7376002,
  "quantity": 0.1,
  "leverage_level": 2,
  "product_code": "CASH",
  "open_price": 403.31,
  "close_price": 405.31,
  "trader_id": 4807,
  "pnl": 2,
  "stop_loss": 0,
  "take_profit": 0,
  "funding_currency": "JPY",
  "created_at": 1455607142,
  "updated_at": 1456285826
}
```
