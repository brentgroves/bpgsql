select 
D.Plexus_Customer_No,
D.Account_No AS Account_No,
D.Debit AS Debit,
D.Credit AS Credit
from accounting_v_ap_invoice_dist as d
inner join accounting_v_ap_invoice i 
ON I.Plexus_Customer_No = D.Plexus_Customer_No 
AND I.Invoice_Link = D.Invoice_Link
WHERE D.Plexus_Customer_No = @PCN
AND I.Period = @Period
and d.account_no = '10120-000-0000'

union

SELECT
jd.Plexus_Customer_No,
jd.Account_No AS Account_No,
jd.Debit AS Debit,
jd.Credit AS Credit
from accounting_v_gl_journal_dist_e jd 
inner join accounting_v_gl_journal_e j 
on jd.plexus_customer_no= j.plexus_customer_no
and jd.journal_link=j.journal_link
where jd.plexus_customer_no = @PCN
and j.period = 202109
and jd.account_no = '10120-000-0000'




/*
    SELECT
      D.Plexus_Customer_No,
      D.Account_No AS Account_No,
      D.Debit AS Debit,
      D.Credit AS Credit
    FROM dbo.AP_Invoice_Dist AS D 
    JOIN dbo.AP_Invoice AS I 
      ON I.Plexus_Customer_No = D.Plexus_Customer_No 
      AND I.Invoice_Link = D.Invoice_Link
    WHERE D.Plexus_Customer_No = @PCN
      AND I.Period = @Period
*/


/*
    SELECT
      D.Plexus_Customer_No,
      D.Account_No AS Account_No,
      D.Debit AS Debit,
      D.Credit AS Credit
    FROM dbo.GL_Journal_Dist AS D 
    JOIN dbo.GL_Journal AS I 
      ON I.Plexus_Customer_No = D.Plexus_Customer_No 
      AND I.Journal_Link = D.Journal_Link
    WHERE D.Plexus_Customer_No = @PCN      
      AND I.Period = @Period
      AND I.Period_Adjustment = 0
*/
