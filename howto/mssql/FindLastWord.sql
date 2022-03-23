
Declare @YourTable Table ([ID] varchar(50),[ProjectDescription] varchar(50))  Insert Into @YourTable Values 
 (1,'Some Project Item or Description') -- Multiword strubg
,(2,'OneWord    ')                      -- One word with trailing blanks
,(3,NULL)                               -- A NULL value
,(4,'')                                 -- An Empty String

Select * 
      ,LengthOfLastWord = LEN(right(rtrim([ProjectDescription]),charindex(' ',reverse(rtrim([ProjectDescription]))+' ')-1))
      ,StartOfLastWord = LEN(rtrim([ProjectDescription])) - LEN(right(rtrim([ProjectDescription]),charindex(' ',reverse(rtrim([ProjectDescription]))+' ')-1))
      ,UpToLastWord = rtrim(substring(rtrim([ProjectDescription]),1,LEN(rtrim([ProjectDescription])) - LEN(right(rtrim([ProjectDescription]),charindex(' ',reverse(rtrim([ProjectDescription]))+' ')-1))))
      ,LastWord = right(rtrim([ProjectDescription]),charindex(' ',reverse(rtrim([ProjectDescription]))+' ')-1)
      ,reverse(rtrim([ProjectDescription]))
 From  @YourTable 