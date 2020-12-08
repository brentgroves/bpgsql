select 
i.item_no,
case 
when substring(i.description,50,1) = ' ' then 'space'
else 'no space' 
end space,
len(i.description) lenDescription,
len(rtrim(i.description)) lenRtrimDescription,
len(substring(Description, 50 - (charindex(' ',reverse(substring(Description,1,50))+' ')-2),len(Description))) lenBeyondDescription,
case 
when LEN(Description) <= 50 then 'case1'
when len(i.description) > 50 AND substring(Description,50,1) = ' ' and len(i.description) - 50 < = 195 then 'case2'
when len(i.description) > 50 AND substring(Description,50,1) <> ' ' and len(substring(Description, 50 - (charindex(' ',reverse(substring(Description,1,50))+' ')-2),len(Description))) <= 195 then 'case3'
else 'case4'
end case_no,
substring(description,1,50) first50,
substring(description,51,len(i.description)) greaterThan50,
brief_description,
case
  when LEN(Description) <= 50 then brief_description  -- no need to do any parsing
  -- if last character is a space then no truncation occurs -- i have only seen this case with maintenance items
  when len(i.description) > 50 AND substring(Description,50,1) = ' ' and len(i.description) - 50 < = 195 then substring(Description,51,len(description)) + ' ' + brief_description
  when len(i.description) > 50 AND substring(Description,50,1) <> ' ' and len(substring(Description, 50 - (charindex(' ',reverse(substring(Description,1,50))+' ')-2),len(Description))) <= 195 -- substring is inclusive with respect to indexes
  -- last character in last full word
  -- select (charindex(' ',reverse(substring('12345678 9ABCDEF',1,10))+' '))  -- 2 the index of the space
  -- select substring('12345678 9ABCDEF',10 - (charindex(' ',reverse(substring('12345678 9ABCDEF',1,10))+' ')-2),len('12345678 9ABCDEF')) -- 9ABCDEF -- substring is inclusive with respect to indexes
  -- select len('12345678 9ABCDEF') -- 16
  -- select len(substring('12345678 9ABCDEF',10,16)) -- 7
  -- select len(substring('12345678 9ABCDEF',10 - (charindex(' ',reverse(substring('12345678 9ABCDEF',1,10))+' ')-2),16)) -- substring is inclusive with respect to indexes
  -- select len(substring('12345678 9ABCDEF',10 - (charindex(' ',reverse(substring('12345678 9ABCDEF',1,10))+' ')-2),len('12345678 9ABCDEF'))) -- 7 -- substring is inclusive with respect to indexes
  /* Starting from the last word within the first 50 characters up to the length of item.description is <= 195 characters. */
  -- trim_end_whitespace_from_substring_of_first_50_characters = LEN(rtrim(substring(Description,1,50))) 
  -- LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))
  -- LEN(right(first_50_characters_remove_end_whitespace,find_start_of_last_word_of_the_reverse_of_the_first_50_characters_trim_end_whitespace_add_1_space_to_end-1))
  -- Use the start of the first full word that is not fully with the 50 character boundary of item.description to item.descriptions end and add extra_description to 
  -- the end.
  then substring(Description,
  --LEN(rtrim(substring(Description,1,50))) - LEN(right(rtrim(substring(Description,1,50)),charindex(' ',reverse(rtrim(substring(Description,1,50)))+' ')-1))+1,  -- rtrim not needed because of 2nd case above
  50 - LEN(right(substring(Description,1,50),charindex(' ',reverse(substring(Description,1,50))+' ')-1)),
  len(Description)) + ' ' + brief_description
  when (len(i.description) > 50 AND substring(Description,50,1) = ' ' and len(i.description) - 50 > 195) then substring(Description,51,200) -- case 4
  when (len(i.description) > 50 AND substring(Description,50,1) <> ' ' and len(substring(Description, 50 - (charindex(' ',reverse(substring(Description,1,50))+' ')-2),len(Description))) > 195 ) then -- case 5
  substring(Description,50 - LEN(right(substring(Description,1,50),charindex(' ',reverse(substring(Description,1,50))+' ')-1)),200)
end Extra_Description 
from purchasing_v_item i 
-- where len(i.description) <= 50  -- case 1
-- where len(i.description) > 50 AND substring(Description,50,1) = ' ' and len(i.description) - 50 < = 195 -- case 2
-- and substring(i.item_no,1,2) <> 'BE' -- 0 records
--where len(i.description) > 50 AND substring(Description,50,1) <> ' ' and len(substring(Description, 50 - (charindex(' ',reverse(substring(Description,1,50))+' ')-2),len(Description))) <= 195 -- case 3
-- where (len(i.description) > 50 AND substring(Description,50,1) = ' ' and len(i.description) - 50 > 195) -- case 4
where (len(i.description) > 50 AND substring(Description,50,1) <> ' ' and len(substring(Description, 50 - (charindex(' ',reverse(substring(Description,1,50))+' ')-2),len(Description))) > 195 ) -- case 5


--where len(i.description) <> len(rtrim(i.description))  -- 0 records
-- where len(i.description) > 100 and len(i.description) > 245