# ma60test

This a back-test code of an improved moving average(MA) strategy for treasury bond futures in China market, which can show the accumulated return and maximum drawdown.

The strategy is based on a classic MA strategy which decide long/short signal based on the position of a MA60 and a one-minute close price. But if the price fluctuates greatly in a short period, the classic strategy may send long/short signal too frequently, causing huge friction cost. Thus, I enhanced the model:

I divided the time period into many five-minute intervals which each one can be considered as a five-minute price bar. If the five-minute price bar upcross MA60, long it, and then holding the position till this five-minute price bar ends. If the close price of this five-minute bar is still above MA60, then hold the position into next 5 minute. If the close price of this five-minute bar is lower than MA60, then change the position to that of the previous five-minute bar. 


To run the code, you should first connect MATLAB to Wind finance terminal(WTF), a database in China similar to Bloomberg. You can refer to 'Wind量化平台-用户手册(MATLAB).pdf' to finish the connection.

After the connection, you can run the code: ma60test(inputcode,startdate,enddate,a,b)

inputcode: enter the code of the selected security. exp:'T1806'    
startdate/enddate: enter the back-test date. exp:'2018-01-01 09:30:01' 
a: a=1 for outputting a excel file recording the trade history.   
b: b=1 for printing a plot showing the long/short point.   
