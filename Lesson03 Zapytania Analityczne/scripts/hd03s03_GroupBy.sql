USE [AdventureworksDW2016CTP3];
GO

--	Przygotowanie tabeli z danymi do dalszej analizy
--	Zaladowanie do tabeli tymczasowej #
------------------------------------------------------------
	
	IF OBJECT_ID('tempdb..#Dane') IS NOT NULL DROP TABLE #Dane

	SELECT 
		a.AccountType		, 
		o.OrganizationName	,
		f.Amount
	INTO #Dane
	FROM 
				[dbo].[FactFinance]		AS	f
	INNER JOIN	[dbo].[DimAccount]		AS	a	ON a.AccountKey			= f.AccountKey
	INNER JOIN	[dbo].[DimOrganization]	AS	o	ON o.OrganizationKey	= f.OrganizationKey

	SELECT TOP 10 *
	FROM #Dane

--	GROUP BY
--	grupuje wiersze w paczki o takim samym komplecie wartosci w kolumnach grupujących
--	dla każdej paczki przekazuje dalej 1 wiersz
--	w części SELECT można używać jedynie:
	--	a) kolumn ujętych w GROUP BY oraz funkcji na tych kolumnach
	--	b) funkcji agregujących
	--	c) stałych oraz funkcji niezależnych od wartości w wierszy np. GETDATE(), RAND()
------------------------------------------------------------
	
    SELECT
        [AccountType]
    ,   COUNT(*)		AS [cnt]
    ,   SUM([Amount])	AS [Amount]
    FROM
        [#Dane]
    GROUP BY
        [AccountType];

-----------------------
	
    SELECT
        [OrganizationName]
    ,   COUNT(*)		AS [cnt]
    ,   SUM([Amount])	AS [Amount]
    FROM
        [#Dane]
    GROUP BY
        [OrganizationName];

-----------------------
	
    SELECT
        [AccountType]
    ,   [OrganizationName]
    ,   COUNT(*)		AS [cnt]
    ,   SUM([Amount])	AS [Amount]
    FROM
        [#Dane]
    GROUP BY
        [AccountType]
    ,   [OrganizationName];

--	GROUP BY ROLLUP
--	kolejne poziomy grupowania
--	po wszystkich kolumnach
--	... jedn mniej
--	... kolejna mniej
--
--	... total
------------------------------------------------------------

	SELECT 
		[OrganizationName]	,
		[AccountType]		, 		
		SUM([Amount])
	FROM #Dane
	GROUP BY ROLLUP([OrganizationName],[AccountType])
	ORDER BY 
		[OrganizationName],
		[AccountType]

--	GROUP BY CUBE
--	wszystkie kombinacje grup
------------------------------------------------------------

	SELECT 
		[OrganizationName]	,
		[AccountType]		, 		
		SUM([Amount])
	FROM #Dane
	GROUP BY CUBE([OrganizationName],[AccountType])
	ORDER BY 
		[OrganizationName],
		[AccountType]

--	GROUPING SETS
--	działa jak UNION ALL kilku select'ów z GROUP BY
------------------------------------------------------------

	SELECT 
		[OrganizationName]	,
		[AccountType]		, 		
		SUM([Amount])
	FROM #Dane
	GROUP BY GROUPING SETS(	([AccountType]), 
							([OrganizationName]),
							()
							)
	ORDER BY 
		[OrganizationName],
		[AccountType]

--	GROUPING() - sprawdzamy czy w danym wierszu na danej kolumnie jest grupowanie
------------------------------------------------------------

	SELECT 
		[OrganizationName]	,
		[AccountType]		,
		GROUPING([OrganizationName]	), 		
		GROUPING([AccountType]		), 	
		SUM([Amount])
	FROM #Dane
	GROUP BY GROUPING SETS(	([AccountType]), 
							([OrganizationName]),
							()
							)

--	GROUPING_ID() - sprawdzamy na komplecie kolumn 
--	po czym dany wiersz jest grupowany
--	zapis binarny np. 101 = 5
------------------------------------------------------------

	SELECT 
		[OrganizationName]	,
		[AccountType]		,
		GROUPING_ID([OrganizationName]	), 		
		GROUPING_ID([AccountType]		), 	
		GROUPING_ID([OrganizationName],[AccountType]	),
		SUM([Amount])
	FROM #Dane
	GROUP BY GROUPING SETS(	([AccountType]), 
							([OrganizationName]),
							()
							)
