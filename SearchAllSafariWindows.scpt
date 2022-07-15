-- Copyright © 2022 Geek & Dad, LLC
-- All Rights Reserved
-- Permission hereby granted for Personal Non-Commercial use.

set reply to ¬
	display dialog "Enter the string to search for:" default answer "" buttons {"Cancel", "Search"} default button "Search" with title "Safari All Window Text Search" giving up after 30
log reply

if gave up of reply then
	return
end if

set searchString to text returned of reply
log "Searching for: " & searchString


tell application "Safari"
	set foundTabsList to {}
	set foundTabsListRef to a reference to foundTabsList
	
	set windsRef to a reference to windows
	
	set countOfWindows to count of windsRef
	set countOfTabs to 0
	
	repeat with n from 1 to countOfWindows
		set tabsRef to tabs in item n of windsRef
		set countOfTabs to countOfTabs + (count of tabsRef)
		repeat with t from 1 to count of items in tabsRef
			set windTextRef to the text of (item t of tabsRef)
			ignoring case and diacriticals
				if the text of windTextRef contains searchString then
					set tabname to (the name of item t of tabsRef as string)
					copy {|windowIdx|:n, |tabIdx|:t, |tabName|:tabname} to the end of foundTabsListRef
				end if
			end ignoring
		end repeat
	end repeat
	
	tell me to log "Searched " & countOfTabs & " in " & countOfWindows & " windows"
	tell me to log "Found: " & (count of foundTabsListRef) & " matches"
	
	if (count of foundTabsListRef) is 0 then
		return -- didn't find any matches
	end if
	
	-- turn list into a list of strings because that's all choose from list can display
	-- add the item id as " ((id: id))" to the end so we can use that to get back to the record
	set selectList to {}
	set selectListRef to a reference to selectList
	
	repeat with n from 1 to (count of foundTabsListRef)
		set itemRef to (a reference to item n of foundTabsListRef)
		set s to ((tabname of itemRef) & " ((id: " & (n as string) & "))")
		copy s to end of selectListRef
	end repeat
	
	-- ask user which one to activate
	set selectedItem to choose from list selectListRef with prompt "Select window tab to bring to front, or cancel" OK button name "Activate" cancel button name "Cancel"
	if not selectedItem is false then
		set idx to my indexFromListString(selectedItem as string)
		set itm to item idx of foundTabsListRef
		set widx to windowIdx of itm
		set tidx to tabIdx of itm
		
		set targetWindow to window widx
		tell targetWindow
			-- set visible to false	-- older Safari or macOS versions needed this 
			-- set visible to true	-- "trick" to make index change visible (via SO)
			set index to 1
			set current tab to (tab tidx)
		end tell
	end if
end tell

on indexFromListString(s)
	set tids to text item delimiters
	set text item delimiters to {" ((id: ", "))"}
	set a to item 1 of text items of s
	set idx to item 2 of text items of s
	set text item delimiters to tids
	return idx
end indexFromListString
