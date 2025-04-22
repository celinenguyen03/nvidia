-- Total Revenue by Market Segment --
SELECT
    [Market Segment],
    SUM(Revenue) AS TotalRevenue
FROM
    nvidia_sales
GROUP BY
    [Market Segment]
ORDER BY
    TotalRevenue DESC;

-- Unit Sales by Market Segment -- 
SELECT
    [Market Segment],
    SUM([Quantity Sold]) AS TotalUnitsSold
FROM
    nvidia_sales
GROUP BY
    [Market Segment]
ORDER BY
    TotalUnitsSold DESC;

-- Average Selling Price (ASP) by Market Segment --
SELECT
    [Market Segment],
    SUM(Revenue) / SUM([Quantity Sold]) AS AverageSellingPrice
FROM
    nvidia_sales
GROUP BY
    [Market Segment]
ORDER BY
    AverageSellingPrice DESC;

-- Sales (Revenue) Over Time by Market Segment (Yearly) --
WITH YearlySales AS (
    SELECT
        DATEPART(year, [Sale Date]) AS SaleYear,
        [Market Segment],
        SUM(Revenue) AS YearlyRevenue
    FROM
        nvidia_sales
    GROUP BY
        DATEPART(year, [Sale Date]),
        [Market Segment]
)
SELECT
    CurrentYear.SaleYear,
    CurrentYear.[Market Segment],
    CurrentYear.YearlyRevenue AS CurrentYearRevenue,
    LAG(CurrentYear.YearlyRevenue, 1, 0) OVER (PARTITION BY CurrentYear.[Market Segment] ORDER BY CurrentYear.SaleYear) AS PreviousYearRevenue,
    (CurrentYear.YearlyRevenue - LAG(CurrentYear.YearlyRevenue, 1, 0) OVER (PARTITION BY CurrentYear.[Market Segment] ORDER BY CurrentYear.SaleYear)) AS RevenueChange,
    (CurrentYear.YearlyRevenue - LAG(CurrentYear.YearlyRevenue, 1, 0) OVER (PARTITION BY CurrentYear.[Market Segment] ORDER BY CurrentYear.SaleYear)) * 100.0 / NULLIF(LAG(CurrentYear.YearlyRevenue, 1, 0) OVER (PARTITION BY CurrentYear.[Market Segment] ORDER BY CurrentYear.SaleYear), 0) AS YoYGrowthPercentage
FROM
    YearlySales AS CurrentYear
ORDER BY
    CurrentYear.[Market Segment],
    CurrentYear.SaleYear;

-- Top Performing GPU Models within Each Market Segment (by Revenue) --
WITH RankedModels AS (
    SELECT
        [Market Segment],
        [GPU Model],
        SUM(Revenue) AS TotalRevenue,
        ROW_NUMBER() OVER (PARTITION BY [Market Segment] ORDER BY SUM(Revenue) DESC) AS RankWithinSegment
    FROM
        nvidia_sales
    GROUP BY
        [Market Segment],
        [GPU Model]
)
SELECT
    [Market Segment],
    [GPU Model],
    TotalRevenue
FROM
    RankedModels
WHERE
    RankWithinSegment <= 5 -- Get the top 5 models per segment
ORDER BY
    [Market Segment],
    TotalRevenue DESC;

-- Sales Trends by Region and Market Segment (Monthly) -- 
SELECT
    FORMAT([Sale Date], 'yyyy-MM') AS SaleMonth,
    Region,
    [Market Segment],
    SUM(Revenue) AS MonthlyRevenue
FROM
    nvidia_sales
GROUP BY
    FORMAT([Sale Date], 'yyyy-MM'),
    Region,
    [Market Segment]
ORDER BY
    Region,
    [Market Segment],
    SaleMonth;

-- Analyzing Sales by Product Line --
SELECT
    [Product Line],
    SUM(Revenue) AS TotalRevenue
FROM
    nvidia_sales
GROUP BY
    [Product Line]
ORDER BY
    TotalRevenue DESC;

-- Analyzing Sales by Release Year within Market Segments --
SELECT
    [Market Segment],
    [Release Year],
    SUM(Revenue) AS TotalRevenue,
    SUM([Quantity Sold]) AS TotalUnitsSold
FROM
    nvidia_sales
GROUP BY
    [Market Segment],
    [Release Year]
ORDER BY
    [Market Segment],
    [Release Year];

-- Calculating the Percentage Contribution of Each Market Segment to Total Revenue --
WITH TotalRevenue AS (
    SELECT SUM(Revenue) AS OverallRevenue
    FROM nvidia_sales
),
SegmentRevenue AS (
    SELECT
        [Market Segment],
        SUM(Revenue) AS SegmentRevenue
    FROM
        nvidia_sales
    GROUP BY
        [Market Segment]
)
SELECT
    sr.[Market Segment],
    sr.SegmentRevenue,
    tr.OverallRevenue,
    (sr.SegmentRevenue * 100.0 / tr.OverallRevenue) AS PercentageOfTotalRevenue
FROM
    SegmentRevenue sr
CROSS JOIN
    TotalRevenue tr
ORDER BY
    PercentageOfTotalRevenue DESC;

-- Analyzing Sales Channel Performance by Market Segment --
SELECT
    [Market Segment],
    [Sales Channel],
    SUM(Revenue) AS TotalRevenue,
    SUM([Quantity Sold]) AS TotalUnitsSold
FROM
    nvidia_sales
GROUP BY
    [Market Segment],
    [Sales Channel]
ORDER BY
    [Market Segment],
    TotalRevenue DESC;