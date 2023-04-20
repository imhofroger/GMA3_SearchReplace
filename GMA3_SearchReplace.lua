-- **************************************************
-- **Scriptname	  : GMA3_SearchReplace.lua
-- **Description  : Search in Sequence or Macro Attribut Command
-- **Author		  : Roger Imhof
-- **Github		  : 
-- **Date		  : 2023.04.20
-- **************************************************

-- Some functions

function foundText(foundmessage,command,searchString,replaceString)
	local returnString = command:gsub(searchString, replaceString)

    -- create inputs:
	local inputs = {
		--{name = "Search", value = command},
		{name = "Replace", value = returnString},
	}
	-- open messagebox:
	local resultTable =
		MessageBox(
		{
			title = "Replace",
			message = foundmessage.."\nCommand:\n"..command,
			message_align_h = Enums.AlignmentH.Left,
			message_align_v = Enums.AlignmentV.Top,
			commands = {{value = 1, name = "Replace"}, {value = 0, name = "no"}, {value = 2, name = "abort"}},
			inputs = inputs,
			backColor = "Global.Default",
			-- timeout = 10000, --milliseconds
			-- timeoutResultCancel = false,
			icon = "logo_small",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text"
		}
	)
	if (resultTable.result == 1) then
		return returnString
    elseif (resultTable.result == 2) then
        return("abort")
    end
end

--main part

local function main()

    -- definitions
    local root = Root();
    local searchObjects
    local searchIn
	local searchBase
	local searchBaseSeq
    local newCommand
    local foundmessage

    -- create inputs:
	local inputs = {
		{name = "Search", value = ""},
		{name = "replace", value = ""}
	}
    local selectors = {
		{ name="Selector", selectedValue=1, values={["Macros"]=1,["Sequences"]=2}, type=1}
	}
	-- open messagebox:
	local resultTable =
		MessageBox(
		{
			title = "Search and Replace",
			message = "Search and Replace in Command Attributes from Macros or Sequences.",
			message_align_h = Enums.AlignmentH.Left,
			message_align_v = Enums.AlignmentV.Top,
			commands = {{value = 1, name = "Ok"}, {value = 0, name = "Cancel"}},
			inputs = inputs,
            selectors = selectors,
			backColor = "Global.Default",
			icon = "logo_small",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text"
		}
	)

	-- print results:
	Printf("Success = "..tostring(resultTable.success))
    local searchSelect=resultTable.selectors.Selector
	Printf("Search in "..searchSelect)
    Printf("Search for "..resultTable.inputs.Search)
	local searchString=resultTable.inputs.Search
	Printf("Replace with = "..resultTable.inputs.replace)
	local replaceString=resultTable.inputs.replace

    -- search in Macros or Sequences
    if (searchSelect == 1) then
        searchObjects = root.ShowData.DataPools.Default.Macros:Children()
        searchIn = "Macro";
    else
        searchObjects = root.ShowData.DataPools.Default.Sequences:Children()
        searchIn = "Sequence";
    end

    -- If searchObjects NULL message nothing found and exit

	for i = 1, #searchObjects do
    	local Commands=searchObjects[i]:Children()
    	for x = 1, #Commands do

            if (searchSelect == 1) then
                searchBase = Commands[x].command
				if string.lower(searchBase):find(string.lower(searchString)) ~= nil then
                    foundmessage = "Found in Macro\nNr.: "..searchObjects[i].no.."\nName: \""..searchObjects[i].name.."\"\nLine Nr.: "..Commands[x].no
                    newCommand = foundText(foundmessage,searchBase,searchString,replaceString);
                    if (newCommand == "abort") then
                        goto abort
                    elseif newCommand ~= nil then
                        Cmd("Set Macro "..searchObjects[i].no.."."..Commands[x].no.." \"command\"=\'"..newCommand .."\'")
                    end
				end
            else
                searchBase = Commands[x]:Children()
                for k = 1, #searchBase do
					searchBaseSeq = searchBase[k].command
                    --if (string.find(searchBaseSeq, searchString) ~= nil) then
					if string.lower(searchBaseSeq):find(string.lower(searchString)) ~= nil then
                        foundmessage = "Found in Sequence\nNr.: "..searchObjects[i].no.."\nName: \""..searchObjects[i].name.."\"\nCue Nr.: "..Commands[x].name
						newCommand = foundText(foundmessage,searchBaseSeq,searchString,replaceString);
                        if (newCommand == "abort") then
                            goto abort
                        elseif (newCommand ~= nil) then
                            Cmd("Set Seq "..searchObjects[i].no.."."..Commands[x].name.." \"command\"=\'"..newCommand .."\'")
                        end
					end
                end
            end
        end
    end
    ::abort::
end

return main

