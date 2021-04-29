SELECT '###1. Вывести список всех яхт, отсортировав по алфавиту.###' AS TITLE;
SELECT *
FROM VYacht
ORDER BY Title;

SELECT '2. Вывести все яхты одного класса.' AS TITLE;
SELECT *
FROM VYacht
WHERE ClassId = 'B';

SELECT '###3. Вывести всех клиентов, бравших в прокат одну и ту же яхту, сроки проката.###' AS TITLE;
SELECT Name, YachtId, StartDate, EndDate
FROM VClient JOIN VRent ON VClient.DocumentId = VRent.DocumentId
ORDER BY YachtId, StartDate;

SELECT '###4. Вывести все яхты, последняя проверка состояния которых производилась за последнюю неделю.###' AS TITLE;
SELECT DISTINCT Title
FROM VYacht JOIN VInspection ON VYacht.YachtId = VInspection.YachtId
WHERE (CURRENT_DATE - Date <= 7);

SELECT '###5. Вывести всех клиентов, кто задерживал возвращение яхты.###' AS TITLE;
SELECT Name
FROM VClient JOIN VRent ON VClient.DocumentId = VRent.DocumentId
WHERE ReturnDate > EndDate;

SELECT '###6. Вывести клиента с наибольшим суммарным сроком проката в «Синей птице».###' AS TITLE;
WITH durs AS (SELECT DocumentId, SUM(Duration) AS TotalDuration
    FROM VRent GROUP BY DocumentId)
SELECT Name, TotalDuration
FROM VClient JOIN durs ON VClient.DocumentId = durs.DocumentId
WHERE (TotalDuration = (SELECT MAX(TotalDuration) FROM durs));

SELECT '###7. Вывсети клиента, заплатившего наибольшее количество денег «Синей птице».###' AS TITLE;
WITH pays AS (SELECT DocumentId, SUM(Deposit) AS TotalRevenue
    FROM VInvoice
    GROUP BY DocumentId)
SELECT Name, TotalRevenue
FROM VClient JOIN pays ON VClient.DocumentId = pays.DocumentId
WHERE (TotalRevenue = (SELECT MAX(TotalRevenue) FROM pays));

SELECT Name, SUM(Deposit) AS TotalRevenue
FROM VClient JOIN VInvoice ON VClient.DocumentId = VInvoice.DocumentId
GROUP BY Name
ORDER BY TotalRevenue DESC
LIMIT 1;

SELECT Name, CalculateRevenueFunction(DocumentId) AS TotalRevenue
FROM VClient
WHERE (CalculateRevenueFunction(DocumentId) =
    (SELECT MAX(CalculateRevenueFunction(DocumentId)) FROM VClient));

SELECT '###8. Вывсести список клиентов, которые плохо следили за состоянием яхты. После возвращения ими яхт , проверка состояния яхт неудовлетворительной.###' AS TITLE;
WITH insps AS (SELECT DISTINCT DocumentId
    FROM VRent JOIN VInspection ON VRent.YachtId = VInspection.YachtId
    WHERE (NOT StatusOk) AND (Date - ReturnDate < 3))
SELECT Name
FROM VClient JOIN insps ON VClient.DocumentId = insps.DocumentId;

SELECT Name
FROM VClient JOIN VBadRent ON VClient.DocumentId = VBadRent.DocumentId;

SELECT '###9. Вывести яхты в порядке убывания их популярности у прокатчиков. (Первой должна быть яхта, котрую брали в прокат чаще других.)###' AS TITLE;
WITH popularity AS (SELECT YachtId, COUNT(*) AS Times
    FROM VRent
    GROUP BY YachtId)
SELECT Title, Times
FROM VYacht LEFT JOIN popularity ON VYacht.YachtId = popularity.YachtId
ORDER BY Times DESC;

SELECT Title, COUNT(VRent.YachtId) AS Times
FROM VYacht LEFT JOIN VRent ON VYacht.YachtId = VRent.YachtId
GROUP BY VYacht.Title
ORDER BY Times DESC;

SELECT '###10. Вывести список клиентов и их любимых яхт. Для каждого клиента показать ту яхту, которую он брал в прокат чаще остальных. В случае, когда таких яхт несколько – сравнивать по сроку проката. Если и срок проката одинаков, вернуть обе яхты а разных строках.###' AS TITLE;
WITH VRentAggr AS (SELECT DocumentId, YachtId,
        SUM(Duration) AS TotalDuration, COUNT(*) AS Times
    FROM VRent
    GROUP BY YachtId, DocumentId),
VRentMax AS (SELECT DocumentId,
        MAX(TotalDuration) AS MD,
        MAX(Times) AS MT
    FROM VRentAggr
    GROUP BY DocumentId)
SELECT VRentAggr.DocumentId, Name, YachtId, Times, TotalDuration
FROM VRentMax JOIN VRentAggr
    ON VRentAggr.DocumentId = VRentMax.DocumentId
    JOIN VClient ON VRentAggr.DocumentId = VClient.DocumentId
WHERE (Times = MT OR TotalDuration = MD)
ORDER BY Times DESC, TotalDuration DESC;
