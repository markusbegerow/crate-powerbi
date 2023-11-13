// This file contains your Data Connector logic
section CrateDB;

[DataSource.Kind="CrateDB", Publish="CrateDB.Publish"]
shared CrateDB.Navigate =
    Value.ReplaceType(
        CrateDBNavigate,
        CrateDBNavigateType
    );


 // Definition for the "login dialog".
CrateDBNavigateType = type function (
   ClusterUrl as (type text meta [
            Documentation.FieldCaption = Extension.LoadString("ClusterUrl.Caption"),
            Documentation.FieldDescription = Extension.LoadString("ClusterUrl.Description"),
            Documentation.SampleValues = { Extension.LoadString("ClusterUrl.Sample") }
        ])) as table
    meta
    [
        Documentation.Name = Extension.LoadString("Cluster.Name"),
        Documentation.LongDescription = Extension.LoadString("Cluster.LongDescription"),
        Documentation.Examples = {
            [
                Description = Extension.LoadString("Cluster.Example.Description"),
                Code = Extension.LoadString("Cluster.Example.Code"),
                Result = Extension.LoadString("Cluster.Example.Result")
            ]
        }
    ];


// Navigation table visible for users
CrateDBNavigate =
    (ClusterUrl as text) =>
        let
            credentials = Extension.CurrentCredential(),
            authenticationKind = credentials[AuthenticationKind],
            userName = credentials[Username],
            userPassword = credentials[Password],
            tables =
                CrateDBTablesForNavigation(
                    ClusterUrl,
                    userName,
                    userPassword
                ),
            objects =
                #table(
                    {
                        "Name",
                        "Key",
                        "Data",
                        "ItemKind",
                        "ItemName",
                        "IsLeaf"
                    },
                    {
                        {
                            "CrateDB",
                            "tables",
                            tables,
                            "Folder",
                            "Folder",
                            false
                        }
                     }
                ),
            result =
                Table.ToNavigationTable(
                    objects,
                    {"Key"},
                    "Name",
                    "Data",
                    "ItemKind",
                    "ItemName",
                    "IsLeaf"
                )
        in
            result;

// Get the names of all existing tables
CrateDBTablesForNavigation =
    (ClusterUrl as text, userName as nullable text, userPassword as nullable text) =>
     
let respsonse = 
    let
        URL = Text.TrimEnd(ClusterUrl,"/") & "/_sql" ,
        Credentials = userName & ":" & userPassword,
        EncodedCredentials = "Basic " & Binary.ToText(Text.ToBinary(Credentials), BinaryEncoding.Base64),

        WebRequest =

        let

            Options = 

                [
                    Headers = [ #"Authorization"=EncodedCredentials, 
                    #"Content-Type"="application/x-www-form-urlencoded" ], 
                    Content = Text.ToBinary("{""stmt"":""SELECT table_name FROM information_schema.tables where table_schema = 'doc'""}")    
            
                ],  

            Result = Web.Contents(URL, Options)
            

        in
        Result
    in WebRequest,
    #"Imported JSON" = Json.Document(respsonse,65001),
    rows = #"Imported JSON"[rows],
    #"Converted to Table" = Table.FromList(rows, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandListColumn(#"Converted to Table", "Column1"),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded Column1",{{"Column1", "Name"}}),
    #"Table with NavData" =
                    Table.AddColumn(
                    #"Renamed Columns",
                    "Data",
                    each
                        GetTable(
                            ClusterUrl,
                            userName,
                            userPassword,
                            [Name]
                        )
                        ),
    #"Table with ItemKind" =
                Table.AddColumn(
                    #"Table with NavData",
                    "ItemKind",
                    each "Table"
                ),
            #"Table with ItemName" =
                Table.AddColumn(
                    #"Table with ItemKind",
                    "ItemName",
                    each "Table"
                ),
            #"Table with IsLeaf" =
                Table.AddColumn(
                    #"Table with ItemName",
                    "IsLeaf",
                    each true
                ),
            navTable =
                Table.ToNavigationTable(
                    #"Table with IsLeaf",
                    {"Name"},
                    "Name",
                    "Data",
                    "ItemKind",
                    "ItemName",
                    "IsLeaf"
                )
        in
            navTable;
       

GetTable =
    (ClusterUrl as text, userName as nullable text, userPassword as nullable text,  tableName as text) as table =>
let respsonse = 
    let
        URL = Text.TrimEnd(ClusterUrl,"/") & "/_sql" ,
        Credentials = userName & ":" & userPassword,
        EncodedCredentials = "Basic " & Binary.ToText(Text.ToBinary(Credentials), BinaryEncoding.Base64),

        WebRequest =

        let

            Options = 

                [
                    Headers = [ #"Authorization"=EncodedCredentials, 
                    #"Content-Type"="application/x-www-form-urlencoded" ], 
                    Content = Text.ToBinary("{""stmt"":""SELECT * FROM " & tableName & """}")    
            
                ],  

            Result = Web.Contents(URL, Options)
            

        in
        Result
    in WebRequest,
    #"Imported JSON" = Json.Document(respsonse,65001),
    #"Converted to Table" = Record.ToTable(#"Imported JSON"),
    #"Filtered Rows" = Table.SelectRows(#"Converted to Table", each ([Name] = "cols" or [Name] = "rows")),

    table = Table.Combine(List.Transform(#"Filtered Rows"{1}[Value], each Table.FromRows({_}, #"Filtered Rows"{0}[Value])))
in
    table;


Table.ToNavigationTable =
    (table as table, keyColumns as list, nameColumn as text, dataColumn as text, itemKindColumn as text, itemNameColumn as text, isLeafColumn as text) as table =>
        let
            tableType = Value.Type(table),
            newTableType =
                Type.AddTableKey(
                    tableType,
                    keyColumns,
                    true
                )
                meta
                [
                    NavigationTable.NameColumn = nameColumn,
                    NavigationTable.DataColumn = dataColumn,
                    NavigationTable.ItemKindColumn = itemKindColumn,
                    Preview.DelayColumn = itemNameColumn,
                    NavigationTable.IsLeafColumn = isLeafColumn
                ],
            navigationTable = Value.ReplaceType(table, newTableType)
        in
            navigationTable;

// Data Source Kind description
CrateDB = [
    Authentication = [
        UsernamePassword = [
            UsernameLabel = Extension.LoadString("Authentication.UsernameLabel"),
            PasswordLabel = Extension.LoadString("Authentication.PasswordLabel")
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
CrateDB.Publish = [
    Beta = true,
    Category = "Online Services",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://linktr.ee/markusbegerow",
    SourceImage = CrateDB.Icons,
    SourceTypeImage = CrateDB.Icons
];

CrateDB.Icons = [
    Icon16 = { Extension.Contents("CrateDB16.png"), Extension.Contents("CrateDB20.png"), Extension.Contents("CrateDB24.png"), Extension.Contents("CrateDB32.png") },
    Icon32 = { Extension.Contents("CrateDB32.png"), Extension.Contents("CrateDB40.png"), Extension.Contents("CrateDB48.png"), Extension.Contents("CrateDB64.png") }
];
