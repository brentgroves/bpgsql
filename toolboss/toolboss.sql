SELECT * FROM jobs

SELECT * FROM `Restrictions2`

SELECT top 100 * 
FROM `TransactionLog`
WHERE (TransactionLog.TRANSTARTDATETIME > #3/1/2018 12:00:01 AM#)


SELECT top 100   TransactionLog.JOBNUMBER, Jobs.ALIAS AS PARTNUMBER, TransactionLog.ITEMNUMBER, TransactionLog.QTY, TransactionLog.UNITCOST, 
                      TransactionLog.TRANSTARTDATETIME, TransactionLog.USERNUMBER, Users.DESCR AS USERNAME, 2 AS Plant
FROM         ((TransactionLog INNER JOIN
                      Users ON TransactionLog.USERNUMBER = Users.USERNUMBER) INNER JOIN
                      Jobs ON TransactionLog.JOBNUMBER = Jobs.JOBNUMBER)
WHERE     (TransactionLog.TRANSCODE = 'WN') AND (TransactionLog.TRANSTARTDATETIME > #1/1/2018 12:00:01 AM#)