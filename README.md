# Cryptocurrency Trading Bot
**The GDAX API used is no longer in service**

# Context
The Python programming language is used by many "bot traders" to conduct these transactions. You may discover links to Python code in several Github repositories if you google "crypto trading bot." Since I am exploring and learning about the world of Data Science, I am using the **R language**.

# Explaination
We'll use the rgdax wrapper to trade the Ethereum — CAD pair on the GDAX exchange through their API. <br>

When a combination of Relative Strength Index (RSI) indicators suggest to a momentarily oversold market, we'll purchase with the expectation that the bulls will drive prices upward again, allowing us to profit. After we buy, the bot will place three limit sell orders: one for 1% profit, another for 4% profit, and the third for 7% profit. With the first two orders, we can rapidly free up cash to join another trade, and the 7% order boosts our total profitability. <br>

We'll begin by calling the libraries: <code>rgdax</code>, <code>mailR</code>, <code>stringi</code>, <code>curl</code>, <code>xts</code>, and <code>TTR</code>. <br>
Here, rgdax provides the interface to the GDAX api, mailR sends email updates with a Gmail account, and stringi helps to parse numbers from JSON and TTR.  <br>

Then, we use the api key, secret, and pass that GDAX generates for you. The functions <code>curr_bal_cad</code> and <code>curr_bal_eth</code> look up the most recent balance in your GDAX account, which we'll utilise in our trading. <br>

For this technique, we'll utilise the Relative Strength Index (RSI), as our primary indicator. <code>curr_rsi14_api</code> uses 15 minute candles to bring in the value of the most recent 14 period RSI. <code>resi14_api</code> less one and similar functions get the RSI for previous periods. <br>

The functions <code>bid</code> and <code>ask</code> return the current bid and ask prices for our strategy. <br>

Now, we need to be able to pull in the current status of our orders already placed, so we'll utilise the rgdax package's "holds" function in <code>cad_hold</code> and <code>eth_hold</code>, and the "cancel_order" function in <code>cancel_orders</code> to cancel orders that have gone too far down the order book to be filled, in order to put limit orders in an iterative way. <br>

The <code>buy_exe</code> function executes the limit orders. It involves several steps: <br>
1. Since we want to acquire as much ETH as feasible each time, the <code>order_size</code> function estimates how much we can buy, less 0.005 ETH to accommodate for rounding mistakes.
2. Our <code>while</code> function places limit orders while we still have zero ETH.
3. The system adds an order at the <code>bid()</code> price, waits 17 seconds for the order to be filled, and then checks to see if the order was filled. If it wasn't, the procedure starts over. <br>

Then, we'll need to save some of our RSI indicator variables as objects so that the trading loop can run faster and we don't go over the API's rate restriction. <br>

Now that we have prepared our functions and variables in order to execute the trading loop, we can proceed to the actual trading loop:

* We will begin the loop if our current CAD account balance is more than $20. Then, if the current RSI is more than or equal to 30, the previous period's RSI was less than or equal to 30, and the RSI in the preceding three periods was less than 30 at least once, we buy as much ETH as we can with our current CAD balance. <br>
* After that, we store the purchase price to a CSV file. <br>
* Then, we send an email to ourselves to alert us of the buy action.
* The loop then prints "buy" in our log file, which we can follow.
* After that, the system goes to sleep for 3 seconds. <br>

To capture profits, we now put three tiered limit sell orders. Our first limit sell order makes a 1% profit, the second one makes a 4% profit, and the last one makes a 7% profit. <br>

With the inclusion of neural networks from the Keras module from Tensorflow for Rstudio, I'm working on enhancing this script. These neural networks make the script considerably more complicated, but they're very effective at uncovering hidden patterns in the data. Furthermore, the TTR package includes a wide variety of financial functions and technical indicators that may be utilised to enhance your model. <br>

Having saying that, **do not gamble with more money than you can afford to lose. The stock market is not a game, and you may and will lose money.**

> To further imporve on this Cryptocurrency Trading Bot and completely remove human error out of the trading process, you may use the Windows Task Scheduler to automate this script. 
