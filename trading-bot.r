# Prints to distinguish enteries in logfiles
print("***************** Start Log Entry *****************")

library(rgdax)        # provides the interface to the GDAX api
library(mailR)        # to send us email updates with a Gmail account
library(stringi)      # to parse numbers from JSON
library(curl)
library(xts)
library(TTR)          # to perform techincal indicator calculations

# Functions:

# curr_cad_bal and curr_eth_bal check the GDAX account for the most recent balance
curr_cad_bal <- function(x) {
  y <- accounts(api.key = "api_key", secret = "secret", passphrase = "passphrase")
  y <- subset(y$available, y$currency == 'CAD')
  y
}
curr_eth_bal <- function(x) {
  z <- accounts(api.key = "api_key", secret = "secret", passphrase = "passphrase")
  z <- subset(z$available, z$currency == 'ETH')
  z
}
curr_api_ema13 <- function(x) {
  df <- rgdax::public_candles(product_id = "ETH-CAD", granularity = 900)
  ema13_gdax <- tail(TTR::EMA(df[, 5], n = 13), n = 1)
  ema13_gdax
}
curr_api_ema34 <- function(x) {
  df <- rgdax::public_candles(product_id = "ETH-CAD", granularity = 900)
  ema34_gdax <- tail(TTR::EMA(df[, 5], n = 34), n = 1)
  ema34_gdax
}

# curr_api_rsi14 pulls in the value of the most recent 14 period RSI, using 15 minute candles
curr_api_rsi14 <- function(x) {
  df <- rgdax::public_candles(product_id = "ETH-CAD", granularity = 900)
  rsi_gdax <- tail(TTR::RSI(df[, 5], n = 14), n = 1)
  rsi_gdax
}

# v.2
# rsi14_api_one_less and so forth pull in the RSI for the periods prior
rsi14_api_one_less <- function(x) {
  df <- rgdax::public_candles(product_id = "ETH-CAD", granularity = 900)
  rsi_gdax_less_one <- head(tail(TTR::RSI(df[, 5], n = 14), n = 2), n = 1)
  rsi_gdax_less_one
}
rsi14_api_two_less <- function(x) {
  df <- rgdax::public_candles(product_id = "ETH-CAD", granularity = 900)
  rsi_gdax_less_two <- head(tail(TTR::RSI(df[,5], n = 14), n = 3), n = 1)
  rsi_gdax_less_two
}
rsi14_api_three_less <- function(x) {
  df <- rgdax::public_candles(product_id = "ETH-CAD", granularity = 900)
  rsi_gdax_less_three <- head(tail(TTR::RSI(df[, 5], n = 14), n = 4), n = 1)
  rsi_gdax_less_three
}
rsi14_api_four_less <- function(x) {
  df <- rgdax::public_candles(product_id = "ETH-CAD", granularity = 900)
  rsi_gdax_less_four <- head(tail(TTR::RSI(df[, 5], n = 14), n = 5), n = 1)
  rsi_gdax_less_four
}

# v.2
# curr_bid and ask_price evaluate the current bid and ask prices for our strategy
curr_bid <- function(x) {
  curr_bid <- public_orderbook(product_id = "ETH-CAD", level = 1)
  curr_bid <- curr_bid$curr_bids[1]
  curr_bid
}
ask_price <- function(x) {
  ask_price <- public_orderbook(product_id = "ETH-CAD", level = 1)
  ask_price <- ask_price$ask_prices[1]
  ask_price
}

# hold_cad and hold_eth pull in the current status of our orders already placed to place limit orders
hold_cad <- function(x) {
  holds(currency = "CAD", "api_key", "secret", "passphrase")
}  
hold_eth <- function(x) {
  holds <- holds(currency = "ETH", "api_key", "secret", "passphrase")
  holds
}

# cancel_order cancels the orders that have moved too far down the order book
cancel_order <- function(x) {
  cancel_order <- cancel_order("api_key", "secret", "passphrase")
  cancel_order
}

# buy_exe actually executes our limit orders
buy_exe <- function(x) {
  # get order size in iterative manner

  # order_size calculates how much eth we can buy
  order_size <- round(curr_cad_bal() / ask_price(), 3)[1] - 0.005
  # place initial order
  while(curr_eth_bal() == 0) {
    # order_size <- curr_cad_bal() / ask_price() - 0.009
    # add_order adds order at the bid() price
    add_order(product_id = "ETH-CAD", api.key = "api_key", secret = "secret", passphrase = "passphrase", type = "limit", price = curr_bid(), side = "b", size = order_size )
    # sleep to see if order takes
    Sys.sleep(17)
    # check to see if ETH bal >= order amt
    if (curr_eth_bal() > 0) {
      "buysuccess"
    } else {
      cancel_order()    # if curr_eth_bal not > 0, cancel order and start over 
    }
  }
}
sell_exe <- function(x) {
  # place initial order
  while (curr_eth_bal() > 0) {
    add_order("ETH-CAD", api.key = "api_key", secret = "secret", passphrase = "passphrase", type = "limit", price = ask_price(), side = "s", size = curr_eth_bal())
    # sleep to see if order takes
    Sys.sleep(17)
    # check to see if ETH bal >= order amt
    if (curr_eth_bal() == 0) {
      "buysuccess"
      } else {
        cancel_order()    # if curr_eth_bal not > 0, cancel order and start over
    }
  }
}
position <- (read.csv("C:/R_Directory/position.csv", header = TRUE))[1, 2]

# v.2
# Store variables so don't exceed rate limit of API
curr_api_rsi14 <- curr_api_rsi14()
Sys.sleep(2)
rsi14_api_one_less <- rsi14_api_one_less()
Sys.sleep(2)
rsi14_api_two_less <- rsi14_api_two_less()
Sys.sleep(2)
rsi14_api_three_less <- rsi14_api_three_less()
Sys.sleep(2)
rsi14_api_four_less <- rsi14_api_four_less()

order_price_tiered3 <- 99999
order_price_tiered5 <- 99999
order_price_tiered8 <- 99999
#v.2

# Actual Trading Loop
if (curr_cad_bal() >= 20) {        # if have more than $20 CAD start loop
  if (curr_api_rsi14 >= 30 &       # and current rsi >= 35  # v.2
     rsi14_api_one_less <= 30 &    # previous close RSI <= 35  # v.2
     rsi14_api_two_less < 30 | rsi14_api_three_less < 30 | rsi14_api_four_less < 30) {    # i - 2, i - 3 or i - 4 RSI < 35  # v.2
    
    # 1 Buy
    buy_exe()
    Sys.sleep(180)
    # 2 save buy price in csv on desktop
    position <- write.csv(curr_bid(), file = "C:/R_Directory/position.csv")    
    # 3 send email
    send.mail(from = "your_username@gmail.com",
              to = c("your_username@gmail.com"),
              replyTo = c("Reply to someone else <your_username@gmail.com>"),
              subject = "GDAX ETH Test - Buy",
              body = paste("Your model says buy right now at price", curr_bid()),
              smtp = list(host.name = "smtp.gmail.com", port = 465, user.name = "username", passwd = "password", ssl = TRUE),
              authenticate = TRUE,
              send = TRUE)
    # 4 print for logs
    print("buy")
    Sys.sleep(3)

    # v.5
    # 5 Enter tiered limit sell orders
    ## Order 1: take 1/3 profits at 1% gain
    order_size_tiered3 <- round(curr_eth_bal() / 3, 3)
    order_price_tiered3 <- round(curr_bid() * 1.01, 2)
    Sys.sleep(1)
    add_order(product_id = "ETH-CAD", api.key = "api_key", secret = "secret", passphrase = "passphrase", type = "limit", price = order_price_tiered3, side = "s",  size = order_size_tiered3 )
    Sys.sleep(20)
    ## Order 2: take 1/3 profits at 4% gain
    order_size_tiered5 <- round(curr_eth_bal() / 2, 3)
    order_price_tiered5 <- round(curr_bid() * 1.04, 2)
    add_order(product_id = "ETH-CAD", api.key = "api_key", secret = "secret", passphrase = "passphrase", type = "limit", price = order_price_tiered5, side = "s",  size = order_size_tiered5)
    Sys.sleep(20)
    ## Order 3: take 1/3 profits at 7% gain
    order_size_tiered8 <- round(curr_eth_bal(), 3)
    order_price_tiered8 <- round(curr_bid() * 1.07, 2)
    add_order(product_id = "ETH-CAD", api.key = "api_key", secret = "secret", passphrase = "passphrase", type = "limit", price = order_price_tiered8, side = "s", size = order_size_tiered8 )
    # v.5
  } else {
    "nobuy"
    }
} else {
"nobuy"
}

# print systime for logs
Sys.time()
print("***************** End Log Entry *****************")
