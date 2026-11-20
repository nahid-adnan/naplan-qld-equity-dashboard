// Model queries and named expressions. Set the folder parameter to the input workbook directory.
section Dashboard;

shared #"School_Profile1" = let
    Source = Excel.Workbook(File.Contents(DataFolderPath & "\school_profile_2014_Queensland.xlsx"), null, true),
    #"School Profile1_Sheet" = Source{[Item="School Profile1",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"School Profile1_Sheet", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Calendar Year", Int64.Type}, {"ACARA SML ID", Int64.Type}, {"AGE ID", Int64.Type}, {"School Name", type text}, {"Suburb", type text}, {"State", type text}, {"Postcode", Int64.Type}, {"School Sector", type text}, {"School Type", type text}, {"Campus Type", type text}, {"Rolled Reporting Description", type text}, {"School URL", type text}, {"Governing Body", type text}, {"Governing Body URL", type text}, {"Year Range", type text}, {"Geolocation", type text}, {"ICSEA", Int64.Type}, {"Bottom SEA Quarter (%)", Int64.Type}, {"Lower Middle SEA Quarter (%)", Int64.Type}, {"Upper Middle SEA Quarter (%)", Int64.Type}, {"Top SEA Quarter (%)", Int64.Type}, {"Teaching Staff", Int64.Type}, {"Full Time Equivalent Teaching Staff", type number}, {"Non-Teaching Staff", Int64.Type}, {"Full Time Equivalent Non-Teaching Staff", type number}, {"Total Enrolments", Int64.Type}, {"Girls Enrolments", Int64.Type}, {"Boys Enrolments", Int64.Type}, {"Full Time Equivalent Enrolments", type number}, {"Indigenous Enrolments (%)", Int64.Type}, {"Language Background Other Than English (%)", Int64.Type}})
in
    #"Changed Type";

shared #"DataFolderPath" = "C:\Data" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"NAPLAN_Scores" = let
    Source = Excel.Workbook(File.Contents(DataFolderPath & "\school_stats_naplan_2014_Queensland.xlsx"), null, true),
    Data_Sheet = Source{[Item="Data",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Data_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"ACARA SML ID", Int64.Type}, {"SCHOOL", type text}, {"Suburb", type text}, {"YR3ENR", type text}, {"YR5ENR", type text}, {"YR7ENR", type text}, {"YR9ENR", type text}, {"YR3READMEAN", type text}, {"YR3WRITMEAN", type text}, {"YR3SPELMEAN", type text}, {"YR3GPMEAN", type text}, {"YR3NMCYMEAN", type text}, {"YR5READMEAN", type text}, {"YR5WRITMEAN", type text}, {"YR5SPELMEAN", type text}, {"YR5GPMEAN", type text}, {"YR5NMCYMEAN", type text}, {"YR7READMEAN", type text}, {"YR7WRITMEAN", type text}, {"YR7SPELMEAN", type text}, {"YR7GPMEAN", type text}, {"YR7NMCYMEAN", type text}, {"YR9READMEAN", type text}, {"YR9WRITMEAN", type text}, {"YR9SPELMEAN", type text}, {"YR9GPMEAN", type text}, {"YR9NMCYMEAN", type text}, {"YR3READPCTNMS", type text}, {"YR3WRITPCTNMS", type text}, {"YR3SPELPCTNMS", type text}, {"YR3GPPCTNMS", type text}, {"YR3NMCYPCTNMS", type text}, {"YR5READPCTNMS", type text}, {"YR5WRITPCTNMS", type text}, {"YR5SPELPCTNMS", type text}, {"YR5GPPCTNMS", type text}, {"YR5NMCYPCTNMS", type text}, {"YR7READPCTNMS", type text}, {"YR7WRITPCTNMS", type text}, {"YR7SPELPCTNMS", type text}, {"YR7GPPCTNMS", type text}, {"YR7NMCYPCTNMS", type text}, {"YR9READPCTNMS", type text}, {"YR9WRITPCTNMS", type text}, {"YR9SPELPCTNMS", type text}, {"YR9GPPCTNMS", type text}, {"YR9NMCYPCTNMS", type text}}),
    #"Unpivoted Other Columns" = Table.UnpivotOtherColumns(#"Changed Type", {"ACARA SML ID", "SCHOOL", "Suburb"}, "Attribute", "Value"),
    #"Replaced Value" = Table.ReplaceValue(#"Unpivoted Other Columns","%","",Replacer.ReplaceText,{"Value"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Replaced Value",{{"Value", type number}}),
    #"Replaced Errors" = Table.ReplaceErrorValues(#"Changed Type1", {{"Value", null}}),
    #"Inserted First Characters" = Table.AddColumn(#"Replaced Errors", "First Characters", each Text.Start([Attribute], 3), type text),
    #"Renamed Columns" = Table.RenameColumns(#"Inserted First Characters",{{"First Characters", "Year Level"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Domain", each let r = Text.Range([Attribute], 3) in
if Text.EndsWith(r, "PCTNMS") then Text.Start(r, Text.Length(r) - 6)
else if Text.EndsWith(r, "MEAN") then Text.Start(r, Text.Length(r) - 4)
else null),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "Measure Type", each if Text.EndsWith([Attribute], "PCTNMS") then "Percent NMS"
else if Text.EndsWith([Attribute], "MEAN") then "Mean Score"
else "Enrolment"),
    #"Changed Type2" = Table.TransformColumnTypes(#"Added Custom1",{{"Domain", type text}, {"Measure Type", type text}})
in
    #"Changed Type2";

shared #"School_Locations" = let
    Source = Excel.Workbook(File.Contents(DataFolderPath & "\school_locations_2014_Queensland.xlsx"), null, true),
    #"School Locations_Sheet" = Source{[Item="School Locations",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"School Locations_Sheet", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"ACARA SML ID", Int64.Type}, {"AGE ID", Int64.Type}, {"School Name", type text}, {"Suburb", type text}, {"State", type text}, {"Postcode", Int64.Type}, {"School Sector", type text}, {"School Type", type text}, {"Campus Type", type text}, {"Rolled Reporting Description", type text}, {"Latitude", type number}, {"Longitude", type number}, {"Statistical Area 1", Int64.Type}, {"Statistical Area 2", Int64.Type}, {"Name of Statistical Area 2", type text}, {"Statistical Area 3", Int64.Type}, {"Name of Statistical Area 3", type text}, {"Statistical Area 4", Int64.Type}, {"Name of Statistical Area 4", type text}, {"ABS Remoteness Area", type text}}),
    #"Merged Queries" = Table.NestedJoin(#"Changed Type", {"ACARA SML ID"}, School_Profile1, {"ACARA SML ID"}, "School_Profile1", JoinKind.LeftOuter),
    #"Expanded School_Profile1" = Table.ExpandTableColumn(#"Merged Queries", "School_Profile1", {"School URL", "Governing Body", "Year Range", "ICSEA", "Bottom SEA Quarter (%)", "Lower Middle SEA Quarter (%)", "Upper Middle SEA Quarter (%)", "Top SEA Quarter (%)", "Teaching Staff", "Full Time Equivalent Teaching Staff", "Non-Teaching Staff", "Full Time Equivalent Non-Teaching Staff", "Total Enrolments", "Girls Enrolments", "Boys Enrolments", "Full Time Equivalent Enrolments", "Indigenous Enrolments (%)", "Language Background Other Than English (%)"}, {"School URL", "Governing Body", "Year Range", "ICSEA", "Bottom SEA Quarter (%)", "Lower Middle SEA Quarter (%)", "Upper Middle SEA Quarter (%)", "Top SEA Quarter (%)", "Teaching Staff", "Full Time Equivalent Teaching Staff", "Non-Teaching Staff", "Full Time Equivalent Non-Teaching Staff", "Total Enrolments", "Girls Enrolments", "Boys Enrolments", "Full Time Equivalent Enrolments", "Indigenous Enrolments (%)", "Language Background Other Than English (%)"}),
    #"Set Profile Column Types" = Table.TransformColumnTypes(#"Expanded School_Profile1",{{"ICSEA", Int64.Type}, {"Bottom SEA Quarter (%)", Int64.Type}, {"Lower Middle SEA Quarter (%)", Int64.Type}, {"Upper Middle SEA Quarter (%)", Int64.Type}, {"Top SEA Quarter (%)", Int64.Type}, {"Total Enrolments", Int64.Type}, {"Girls Enrolments", Int64.Type}, {"Boys Enrolments", Int64.Type}, {"Teaching Staff", Int64.Type}, {"Non-Teaching Staff", Int64.Type}, {"Indigenous Enrolments (%)", Int64.Type}, {"Language Background Other Than English (%)", Int64.Type}, {"Full Time Equivalent Teaching Staff", type number}, {"Full Time Equivalent Non-Teaching Staff", type number}, {"Full Time Equivalent Enrolments", type number}, {"School URL", type text}, {"Governing Body", type text}, {"Year Range", type text}})
in
    #"Set Profile Column Types";
