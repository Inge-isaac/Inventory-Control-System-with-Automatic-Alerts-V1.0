CREATE PROCEDURE sp_GetCurrentStock
    @ProductID INT = NULL  -- NULL -> devuelve todos los productos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProductID,
        p.ProductName,
        p.SKU,
        p.ReorderPoint,
        ISNULL(s.CurrentStock, 0) AS CurrentStock,
        s.LastUpdate
    FROM Products p
    LEFT JOIN InventoryStock s ON p.ProductID = s.ProductID
    WHERE (@ProductID IS NULL OR p.ProductID = @ProductID)
    ORDER BY p.ProductName;
END
