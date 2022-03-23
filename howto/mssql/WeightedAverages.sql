/*
How to compute weighted averages.

To find a weighted average, multiply each number by its weight, 
then add the results. 

If the weights don't add up to one, 
find the sum of all the variables multiplied by their weight, 
then divide by the sum of the weights
sum (variable * weight) / sum(variable)
*/

/*
 * In this example the weights don't add to one
 * and the variable is unit_price and its weight is sales_qty
 */
	sum(ap.unit_price*ap.sales_qty) --sales,  -- see validation tab of daily_metrics validation spreadsheet.
	/
	sum(ap.sales_qty) -- shipped,
	sell_price,	